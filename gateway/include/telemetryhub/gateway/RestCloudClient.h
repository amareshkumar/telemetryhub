#pragma once
#include "ICloudClient.h"

namespace telemetryhub::gateway {

    class RestCloudClient : public ICloudClient
    {
    public:
        RestCloudClient(const std::string& endpoint_url = "http://localhost:0")
            : endpoint_url_(endpoint_url)
        {
        };
        ~RestCloudClient() override = default;

        void push_sample(const telemetryhub::device::TelemetrySample& sample) override;
        void push_status(device::DeviceState state) override;
    private:
        std::string endpoint_url_;
    };

}