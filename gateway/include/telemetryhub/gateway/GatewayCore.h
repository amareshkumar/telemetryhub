#pragma once

#include <atomic>
#include <chrono>
#include <algorithm>
#include <thread>
#include <optional>
#include "telemetryhub/device/Device.h"
#include "telemetryhub/gateway/TelemetryQueue.h"
#include "telemetryhub/gateway/ICloudClient.h"
#include "telemetryhub/gateway/ThreadPool.h"

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

    // Runtime knobs
    void set_sampling_interval(std::chrono::milliseconds ms) { sample_interval_ = ms; }
    void set_queue_capacity(size_t cap) { queue_capacity_ = cap; }

    struct Metrics {
        uint64_t samples_processed{0};
        uint64_t samples_dropped{0};
        size_t queue_depth{0};
        double latency_p99_ms{0.0};
        uint64_t uptime_seconds{0};
        
        // Thread pool metrics
        uint64_t pool_jobs_processed{0};
        uint64_t pool_jobs_queued{0};
        double pool_avg_processing_ms{0.0};
        size_t pool_num_threads{0};
    };
    Metrics get_metrics() const;

private:
    void producer_loop();
    void consumer_loop();
    void process_sample_with_metrics(const device::TelemetrySample& sample);

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
    std::chrono::milliseconds sample_interval_{std::chrono::milliseconds(100)};
    size_t queue_capacity_{0};
    
    // Metrics tracking
    std::atomic<uint64_t> metrics_samples_processed_{0};
    std::atomic<uint64_t> metrics_samples_dropped_{0};
    
    // Thread pool for processing (Day 17)
    std::unique_ptr<ThreadPool> thread_pool_;
    std::chrono::steady_clock::time_point start_time_;
};

} // namespace telemetryhub::gateway
