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

private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::queue<device::TelemetrySample> queue_;
};

} // namespace telemetryhub::gateway
