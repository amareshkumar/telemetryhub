#pragma once
#include "telemetryhub/device/TelemetrySample.h"
#include "telemetryhub/device/Device.h"

namespace telemetryhub::gateway {
class ICloudClient
{
public:
    virtual ~ICloudClient() = default;
    
    virtual void push_sample(const telemetryhub::device::TelemetrySample& sample) = 0;

    virtual void push_status (device::DeviceState state) = 0;
};

enum class UploadResult {
    Success,
    TransientFailure,  // Retry
    PermanentFailure   // Circuit breaker
};

class CloudClientWithRetry : public ICloudClient {
    CircuitBreaker breaker_;
    RetryPolicy retry_{ExponentialBackoff{100ms, 5s}};
    // ...
};
} // namespace telemetryhub::gateway