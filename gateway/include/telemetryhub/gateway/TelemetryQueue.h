#pragma once

#include <condition_variable>
#include <mutex>
#include <queue>
#include <optional>
#include <atomic>
#include "telemetryhub/device/TelemetrySample.h"

namespace telemetryhub::gateway {
struct QueueMetrics {
  std::atomic<uint64_t> pushes{0}, pops{0}, drops{0};
  std::atomic<uint32_t> highWatermark{0};
};

class TelemetryQueue {
public:
  explicit TelemetryQueue(size_t capacity = 1024);
  // Non-blocking push/pop with timeout variants
  bool try_push(const telemetryhub::device::TelemetrySample& s);
  bool try_pop(telemetryhub::device::TelemetrySample& out, uint32_t timeout_ms);

  // Blocking variants used by existing code
  void push(const device::TelemetrySample& sample);
  std::optional<device::TelemetrySample> pop();

  size_t size() const;
  size_t capacity() const noexcept { return capacity_; }

  // Signal that no more items will be produced; unblocks waiting consumers.
  void shutdown();

  const QueueMetrics& metrics() const noexcept { return metrics_; }

private:
  void update_hwm_();

  mutable std::mutex mutex_;
  std::condition_variable cv_;
  std::queue<device::TelemetrySample> queue_;
  bool shutdown_ = false;
  size_t capacity_ = 0;
  QueueMetrics metrics_;
};

} // namespace telemetryhub::gateway
