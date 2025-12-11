#include "telemetryhub/gateway/TelemetryQueue.h"

namespace telemetryhub::gateway {

void TelemetryQueue::push(const device::TelemetrySample& sample)
{
    {
        std::lock_guard lock(mutex_);
        if (shutdown_) {
            return; // Do not accept new samples after shutdown
        }
        if (max_size_ > 0 && queue_.size() >= max_size_) {
            // Drop oldest to make room
            queue_.pop();
        }
        queue_.push(sample);
    }
    cv_.notify_one();
}

void TelemetryQueue::push(device::TelemetrySample&& sample)
{
    {
        std::lock_guard lock(mutex_);
        if (shutdown_) {
            return; // Do not accept new samples after shutdown
        }
        if (max_size_ > 0 && queue_.size() >= max_size_) {
            queue_.pop();
        }
        // Avoid copy by constructing in-place
        queue_.emplace(std::move(sample));
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

} // namespace telemetryhub::gateway