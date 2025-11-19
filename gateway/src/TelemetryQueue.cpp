#include "../telemetryhub/gateway/TelemetryQueue.h"

namespace telemetryhub::gateway {

void TelemetryQueue::push(const device::TelemetrySample& sample)
{
    {
        std::lock_guard lock(mutex_);
        queue_.push(sample);
    }
    cv_.notify_one();
}

std::optional<device::TelemetrySample> TelemetryQueue::pop()
{
    std::unique_lock lock(mutex_);
    cv_.wait(lock, [this] { return !queue_.empty(); });

    auto sample = queue_.front();
    queue_.pop();
    return sample;
}

} // namespace telemetryhub::gateway
