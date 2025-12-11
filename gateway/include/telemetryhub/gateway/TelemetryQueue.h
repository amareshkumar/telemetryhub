#pragma once

#include <condition_variable>
#include <mutex>
#include <queue>
#include <optional>
#include "telemetryhub/device/TelemetrySample.h"

namespace telemetryhub::gateway {

class TelemetryQueue
{
public:
    // max_size=0 means unbounded. If bounded and full, oldest item is dropped.
    explicit TelemetryQueue(size_t max_size = 0) : max_size_(max_size) {}
    void set_capacity(size_t cap) { max_size_ = cap; }
    void push(const device::TelemetrySample& sample);
    // Optimized path to avoid extra copy when the caller can move
    void push(device::TelemetrySample&& sample);
    std::optional<device::TelemetrySample> pop();

    // Signal that no more items will be produced; unblocks waiting consumers.
    void shutdown();

private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::queue<device::TelemetrySample> queue_;
    bool shutdown_ = false;
    size_t max_size_ = 0;
};

} // namespace telemetryhub::gateway
