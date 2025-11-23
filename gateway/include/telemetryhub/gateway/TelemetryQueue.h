#pragma once

#include <condition_variable>
#include <mutex>
#include <queue>
#include <optional>
#include "../telemetryhub/device/TelemetrySample.h"

namespace telemetryhub::gateway {

class TelemetryQueue
{
public:
    void push(const device::TelemetrySample& sample);
    std::optional<device::TelemetrySample> pop();

    // Signal that no more items will be produced; unblocks waiting consumers.
    void shutdown();

private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::queue<device::TelemetrySample> queue_;
    bool shutdown_ = false;
};

} // namespace telemetryhub::gateway
