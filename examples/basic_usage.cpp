// TelemetryHub Basic Usage Example
//
// Demonstrates how to integrate TelemetryHub components into a C++ application.
// This example shows:
// - Creating and configuring a GatewayCore instance
// - Starting/stopping measurement
// - Polling for device state and samples
// - Clean shutdown
//
// Build:
//   Add to CMakeLists.txt or compile manually:
//   g++ -std=c++20 basic_usage.cpp -I../gateway/include -I../device/include \
//       -L../build/gateway -L../build/device -lgateway_core -ldevice

#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"
#include <iostream>
#include <thread>
#include <chrono>

using namespace telemetryhub;
using namespace std::chrono_literals;

int main()
{
    std::cout << "TelemetryHub Basic Usage Example\n";
    std::cout << "================================\n\n";

    // Create gateway instance
    gateway::GatewayCore gateway;
    
    // Configure queue capacity (optional)
    gateway.set_queue_capacity(256);  // Bounded queue with 256 samples
    gateway.set_sampling_interval(100ms);  // Sample every 100ms
    
    std::cout << "[1] Starting gateway...\n";
    gateway.start();
    
    // Wait for device to reach Measuring state
    std::cout << "[2] Waiting for device to start measuring...\n";
    for (int i = 0; i < 10; ++i) {
        auto state = gateway.device_state();
        std::cout << "    State: " << device::to_string(state) << "\n";
        if (state == device::DeviceState::Measuring) {
            break;
        }
        std::this_thread::sleep_for(100ms);
    }
    
    // Poll for samples
    std::cout << "\n[3] Collecting 10 samples...\n";
    for (int i = 0; i < 10; ++i) {
        auto sample = gateway.latest_sample();
        if (sample.has_value()) {
            std::cout << "    Sample #" << sample->sequence_id << ": "
                      << sample->value << " " << sample->unit << "\n";
        } else {
            std::cout << "    (no sample yet)\n";
        }
        std::this_thread::sleep_for(200ms);
    }
    
    // Check final state
    std::cout << "\n[4] Final state check...\n";
    auto final_state = gateway.device_state();
    std::cout << "    Device state: " << device::to_string(final_state) << "\n";
    
    auto last_sample = gateway.latest_sample();
    if (last_sample.has_value()) {
        std::cout << "    Last sample: #" << last_sample->sequence_id << " = "
                  << last_sample->value << " " << last_sample->unit << "\n";
    }
    
    // Clean shutdown
    std::cout << "\n[5] Stopping gateway...\n";
    gateway.stop();
    
    std::cout << "\n✓ Example completed successfully!\n";
    return 0;
}
