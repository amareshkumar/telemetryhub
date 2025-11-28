#pragma once

#include <atomic>
#include <thread>
#include <optional>
#include "telemetryhub/device/Device.h"
#include "telemetryhub/gateway/TelemetryQueue.h"

namespace telemetryhub::gateway {

// Public snapshot of gateway metrics (plain integers)
struct GatewayMetrics {
  uint64_t produced{0}, accepted{0}, consumed{0};
};

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
    
    TelemetryQueue& queue();  
    // Returns a snapshot of metrics (does not expose atomics)
    GatewayMetrics metrics() const;

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
    // Internal atomic metrics storage
    struct AtomicGatewayMetrics {
      std::atomic<uint64_t> produced{0};
      std::atomic<uint64_t> accepted{0};
      std::atomic<uint64_t> consumed{0};
    } metrics_;
};

} // namespace telemetryhub::gateway
