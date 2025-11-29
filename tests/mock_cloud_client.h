#pragma once
#include "telemetryhub/gateway/RestCloudClient.h"
#include <vector>

namespace telemetryhub::gateway {

    class MockCloudClient : public ICloudClient
    {
    public:
        MockCloudClient() = default;
        ~MockCloudClient() override = default;

        void push_sample(const telemetryhub::device::TelemetrySample& sample) override
        {
            // Mock implementation: do nothing or log to console
        }

        void push_status(telemetryhub::device::DeviceState state) override
        {
            // Mock implementation: do nothing or log to console
        }
        private:
        std::vector<telemetryhub::device::TelemetrySample> samples_;
    };
}