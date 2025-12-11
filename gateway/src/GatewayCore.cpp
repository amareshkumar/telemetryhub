#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"
#include "telemetryhub/gateway/Log.h"

#include <iostream>
#include <mutex>
#include <thread>
#include <chrono>
using namespace std::chrono_literals; // enable 100ms duration literal

namespace telemetryhub::gateway {

GatewayCore::GatewayCore()
    : device_{}, // default Device (e.g. fault after 8 samples)
      start_time_(std::chrono::steady_clock::now())
{
}

GatewayCore::~GatewayCore()
{
    stop();
}

GatewayCore::Metrics GatewayCore::get_metrics() const
{
    Metrics m;
    m.samples_processed = metrics_samples_processed_.load();
    m.samples_dropped = metrics_samples_dropped_.load();
    m.queue_depth = queue_.size();
    m.latency_p99_ms = 0.0; // TODO: Implement latency tracking with histogram
    
    auto now = std::chrono::steady_clock::now();
    auto uptime = std::chrono::duration_cast<std::chrono::seconds>(now - start_time_);
    m.uptime_seconds = static_cast<uint64_t>(uptime.count());
    
    return m;
}

void GatewayCore::start()
{
    bool expected = false;
    if (!running_.compare_exchange_strong(expected, true))
    {
        // already running
        return;
    }

    TELEMETRYHUB_LOGI("GatewayCore","starting device...");
    TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Info, "GatewayCore", "starting device...");

    prev_state_ = device_.state();
    device_.start();

    // Apply queue capacity if requested
    if (queue_capacity_ > 0) {
        queue_.set_capacity(queue_capacity_);
    }
    producer_thread_ = std::thread(&GatewayCore::producer_loop, this);
    consumer_thread_ = std::thread(&GatewayCore::consumer_loop, this);
}

void GatewayCore::stop()
{
    bool expected = true;
    if (!running_.compare_exchange_strong(expected, false))
    {
        // already stopped
        return;
    }

    // std::cout << "[GatewayCore] stopping...\n";
    TELEMETRYHUB_LOGI("GatewayCore","stopping device...");

    // Tell queue no more pushes are coming
    
    queue_.shutdown();
    
    // Stop device if still measuring
    device_.stop();

    if (producer_thread_.joinable())
    {
        producer_thread_.join();
    }
    if (consumer_thread_.joinable())
    {
        consumer_thread_.join();
    }

    // std::cout << "[GatewayCore] stopped.\n";
    TELEMETRYHUB_LOGI("GatewayCore","stopped.");
}

device::DeviceState GatewayCore::device_state() const
{
    return device_.state();
}

std::optional<device::TelemetrySample> GatewayCore::latest_sample() const
{
    std::lock_guard lock(latest_mutex_);
    return latest_;
}

void GatewayCore::producer_loop()
{
    // std::cout << "[GatewayCore::producer] thread started\n";
    TELEMETRYHUB_LOGI("GatewayCore","[producer] thread started");

    while (running_)
    {
        auto state = device_.state();
        // Push status on transitions
        if (cloud_client_ && state != prev_state_)
        {
            try { cloud_client_->push_status(state); }
            catch (const std::exception& e) {
                TELEMETRYHUB_LOGI("GatewayCore", (std::string("cloud push_status failed: ") + e.what()).c_str());
            }
            prev_state_ = state;
        }

        if (state != device::DeviceState::Measuring)
        {
            if (state == device::DeviceState::SafeState ||
                state == device::DeviceState::Error)
            {
                // std::cout << "[producer] device state="
                //           << device::to_string(state)
                //           << ", exiting producer loop\n";
                TELEMETRYHUB_LOGI("GatewayCore", (std::string("[producer] device state=") + device::to_string(state) + ", exiting producer loop").c_str());
                break;
            }

            // Idle or transitioning – wait a bit
            std::this_thread::sleep_for(sample_interval_);
            continue;
        }

        auto sample_opt = device_.read_sample();
        if (sample_opt)
        {
            // Blocking push in current queue implementation; treat as accepted
            queue_.push(*sample_opt);
            metrics_samples_processed_++;
            accepted_counter_++;
            if (cloud_client_ && (accepted_counter_ % cloud_sample_interval_ == 0))
            {
                try { cloud_client_->push_sample(*sample_opt); }
                catch (const std::exception& e) {
                    TELEMETRYHUB_LOGI("GatewayCore", (std::string("cloud push_sample failed: ") + e.what()).c_str());
                }
            }
        }
        // Pace sampling irrespective of whether we produced a sample
        std::this_thread::sleep_for(sample_interval_);
    }

    // std::cout << "[GatewayCore::producer] exiting\n";
    TELEMETRYHUB_LOGI("GatewayCore","[producer] exiting");
}

void GatewayCore::consumer_loop()
{
    // std::cout << "[GatewayCore::consumer] thread started\n";
    TELEMETRYHUB_LOGI("GatewayCore","[consumer] thread started");

    while (true)
    {
        auto sample_opt = queue_.pop();
        if (!sample_opt)
        {
            // std::cout << "[consumer] queue shutdown, exiting consumer loop\n";
            TELEMETRYHUB_LOGI("GatewayCore","[consumer] queue shutdown, exiting consumer loop");
            break;
        }

        {
            std::lock_guard lock(latest_mutex_);
            latest_ = *sample_opt;
        }

        // std::cout << "[consumer] got sample #" << sample_opt->sequence_id
        //           << " value=" << sample_opt->value
        //           << " " << sample_opt->unit << "\n";
        TELEMETRYHUB_LOGI("GatewayCore",
            (std::string("[consumer] got sample #") + std::to_string(sample_opt->sequence_id) +
             " value=" + std::to_string(sample_opt->value) + " " + sample_opt->unit).c_str());  
                  
    }

    // std::cout << "[GatewayCore::consumer] exiting\n";
    TELEMETRYHUB_LOGI("GatewayCore","[consumer] exiting");
}

}   // namespace telemetryhub::gateway 