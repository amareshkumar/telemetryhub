#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"

#include <iostream>
#include <mutex>
#include <thread>
#include <chrono>
using namespace std::chrono_literals; // enable 100ms duration literal

namespace telemetryhub::gateway {

GatewayCore::GatewayCore()
    : device_{} // default Device (e.g. fault after 8 samples)
{
}

GatewayCore::~GatewayCore()
{
    stop();
}

void GatewayCore::start()
{
    bool expected = false;
    if (!running_.compare_exchange_strong(expected, true))
    {
        // already running
        return;
    }

    std::cout << "[GatewayCore] starting device...\n";
    device_.start();

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

    
    std::cout << "[GatewayCore] stopping...\n";

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

    std::cout << "[GatewayCore] stopped.\n";
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
    std::cout << "[GatewayCore::producer] thread started\n";

    while (running_)
    {
        auto state = device_.state();

        if (state != device::DeviceState::Measuring)
        {
            if (state == device::DeviceState::SafeState ||
                state == device::DeviceState::Error)
            {
                std::cout << "[producer] device state="
                          << device::to_string(state)
                          << ", exiting producer loop\n";
                break;
            }

            // Idle or transitioning – wait a bit
            std::this_thread::sleep_for(100ms);
            continue;
        }

        auto sample_opt = device_.read_sample();
        if (sample_opt)
        {
            queue_.push(*sample_opt);
        }
        else
        {
            std::this_thread::sleep_for(100ms);
        }
    }

    std::cout << "[GatewayCore::producer] exiting\n";
}

void GatewayCore::consumer_loop()
{
    std::cout << "[GatewayCore::consumer] thread started\n";

    while (true)
    {
        auto sample_opt = queue_.pop();
        if (!sample_opt)
        {
            std::cout << "[consumer] queue shutdown, exiting consumer loop\n";
            break;
        }

        {
            std::lock_guard lock(latest_mutex_);
            latest_ = *sample_opt;
        }

        std::cout << "[consumer] got sample #" << sample_opt->sequence_id
                  << " value=" << sample_opt->value
                  << " " << sample_opt->unit << "\n";
    }

    std::cout << "[GatewayCore::consumer] exiting\n";
}

}   // namespace telemetryhub::gateway 