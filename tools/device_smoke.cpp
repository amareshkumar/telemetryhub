#include "../device/include/telemetryhub/device/Device.h"

#include <iostream>
#include <thread>
#include <chrono>

using telemetryhub::device::Device;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;

static const char* to_string(DeviceState s)
{
    switch (s)
    {
    case DeviceState::Idle:      return "Idle";
    case DeviceState::Measuring: return "Measuring";
    case DeviceState::Error:     return "Error";
    case DeviceState::SafeState: return "SafeState";
    }
    return "Unknown";
}

int main()
{
    Device dev;

    std::cout << "Initial state: " << to_string(dev.state()) << "\n";

    std::cout << "Starting device...\n";
    dev.start();
    std::cout << "State after start: " << to_string(dev.state()) << "\n";

    using namespace std::chrono_literals;

    for (int i = 0; i < 5; ++i)
    {
        auto sample_opt = dev.read_sample();
        if (sample_opt)
        {
            const TelemetrySample& s = *sample_opt;
            std::cout << "Sample #" << s.sequence_id
                      << " value=" << s.value
                      << " unit=" << s.unit
                      << "\n";
        }
        else
        {
            std::cout << "No sample (state=" << to_string(dev.state()) << ")\n";
        }

        std::this_thread::sleep_for(200ms);
    }

    std::cout << "Stopping device...\n";
    dev.stop();
    std::cout << "State after stop: " << to_string(dev.state()) << "\n";

    return 0;
}
