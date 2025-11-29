#pragma once
#include "telemetryhub/gateway/ICloudClient.h"
#include <vector>
#include <mutex>

namespace telemetryhub::gateway {

    class MockCloudClient : public ICloudClient
    {
    public:
        MockCloudClient() = default;
        ~MockCloudClient() override = default;

        void push_sample(const telemetryhub::device::TelemetrySample& sample) override
        {
            std::lock_guard<std::mutex> lock(mutex_);
            samples_.push_back(sample);
        }

        void push_status(telemetryhub::device::DeviceState state) override
        {
            std::lock_guard<std::mutex> lock(mutex_);
            statuses_.push_back(state);
        }
        private:
        std::vector<telemetryhub::device::TelemetrySample> samples_;
        std::vector<telemetryhub::device::DeviceState> statuses_;
        std::mutex mutex_;
    };
}