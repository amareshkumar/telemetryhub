#include "telemetryhub/gateway/TelemetryQueue.h"
#include <chrono>

namespace telemetryhub::gateway {

TelemetryQueue::TelemetryQueue(size_t capacity) : capacity_(capacity) {}

void TelemetryQueue::push(const device::TelemetrySample& sample) {
  {
    std::lock_guard lock(mutex_);
    if (shutdown_) {
      return; // Do not accept new samples after shutdown
    }
    if (queue_.size() >= capacity_) {
      metrics_.drops++;
      return;
    }
    queue_.push(sample);
    metrics_.pushes++;
    update_hwm_();
  }
  cv_.notify_one();
}

std::optional<device::TelemetrySample> TelemetryQueue::pop()
{
    std::unique_lock lock(mutex_);
    cv_.wait(lock, [this] { return shutdown_ || !queue_.empty(); });

    if (shutdown_ && queue_.empty()) {
        return std::nullopt;
    }

    auto sample = queue_.front();
    queue_.pop();
    metrics_.pops++;
    return sample;
}

void TelemetryQueue::shutdown()
{
    {
        std::lock_guard lock(mutex_);
        shutdown_ = true;
    }
    cv_.notify_all();
}

using telemetryhub::device::TelemetrySample;
bool TelemetryQueue::try_push(const TelemetrySample& s) {
    std::unique_lock lk(mutex_);
    if (shutdown_) return false;
    if (queue_.size() >= capacity_) {
        metrics_.drops++;
        return false;
    }
    queue_.push(s); // std::queue::push
    metrics_.pushes++;
    update_hwm_();
    lk.unlock();
    cv_.notify_one();
    return true;
}

bool TelemetryQueue::try_pop(TelemetrySample& out, uint32_t timeout_ms) {
    std::unique_lock lk(mutex_);
    if (!cv_.wait_for(lk, std::chrono::milliseconds(timeout_ms), [&]{ return !queue_.empty() || shutdown_; })) {
        return false;
    }
    if (queue_.empty()) {
        return false; // shutdown or spurious
    }
    out = queue_.front();
    queue_.pop();
    metrics_.pops++;
    return true;
}

size_t TelemetryQueue::size() const {
  std::lock_guard lk(mutex_);
  return queue_.size();
}

void TelemetryQueue::update_hwm_() {
  uint32_t sz = static_cast<uint32_t>(queue_.size());
  uint32_t prev = metrics_.highWatermark.load(std::memory_order_relaxed);
  while (sz > prev && !metrics_.highWatermark.compare_exchange_weak(prev, sz, std::memory_order_relaxed)) {
    // retry until updated or another thread raised it further
  }
}
} // namespace telemetryhub::gateway