#include "telemetryhub/device/Device.h"
#include "telemetryhub/device/DeviceUtils.h"

#include <iostream>
#include <thread>
#include <chrono>

using telemetryhub::device::Device;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;
using telemetryhub::device::to_string;


int main(int argc, char* argv[])
{
    Device dev;
    int num_samples = 20;

    if (argc >= 2)
    {
        try
        {
            num_samples = std::stoi(argv[1]);
        }
        catch (const std::exception& ex)
        {
            std::cerr << "Invalid number of samples argument: " << argv[1] 
                    << "': " << ex.what() << "\n"
                    << "Using default: " << num_samples << "\n";
            return 1;
        }
    }

    std::cout << "Initial state: " << to_string(dev.state()) << "\n";

    std::cout << "Starting device...\n";
    dev.start();
    std::cout << "State after start: " << to_string(dev.state()) << "\n";

    using namespace std::chrono_literals;

    for (int i = 0; i < num_samples; ++i)
    {
        auto st = dev.state();
        auto sample_opt = dev.read_sample();
        
        std::cout << "[Loop " << i << "] state=" << to_string(st);
        
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
        // If device has gone to SafeState, try to start again
        if (dev.state() == DeviceState::SafeState)
        {
            std::cout << "Device in SafeState, attempting to restart...\n";
            dev.start();
            std::cout << "State after restart attempt: " << to_string(dev.state()) << "\n";
            break;
        }   
    }

    std::cout << "Stopping device...\n";
    dev.stop();
    std::cout << "State after stop: " << to_string(dev.state()) << "\n";

    return 0;
}
