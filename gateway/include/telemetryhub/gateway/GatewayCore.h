#pragma once

#include <atomic>
#include <thread>
#include <optional>
#include "telemetryhub/device/Device.h"
#include "telemetryhub/gateway/TelemetryQueue.h"
#include "telemetryhub/gateway/ICloudClient.h"

namespace telemetryhub::gateway {

class GatewayCore
{
public:
    GatewayCore();
    ~GatewayCore();

    GatewayCore(const GatewayCore&) = delete;
    GatewayCore& operator=(const GatewayCore&) = delete;

    void start();
    void stop();

    device::DeviceState device_state() const;
    std::optional<device::TelemetrySample> latest_sample() const;

    void set_cloud_client(std::shared_ptr<ICloudClient> client, size_t interval = 4){    
        cloud_client_ = std::move(client); 
        cloud_sample_interval_ = std::max<size_t>(1, interval); 
    }

private:
    void producer_loop();
    void consumer_loop();

    mutable std::mutex latest_mutex_;
    std::optional<device::TelemetrySample> latest_;

    device::Device device_;
    TelemetryQueue queue_;

    std::atomic<bool> running_{false};
    std::thread producer_thread_;
    std::thread consumer_thread_;
    // Cloud client integration
    size_t cloud_sample_interval_{5};
    std::shared_ptr<ICloudClient> cloud_client_{nullptr};
    uint64_t accepted_counter_{0};
    device::DeviceState prev_state_{device::DeviceState::Idle};
};

} // namespace telemetryhub::gateway
