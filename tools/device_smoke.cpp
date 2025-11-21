#include "../device/include/telemetryhub/device/Device.h"
#include "DeviceUtils.h"
#include <iostream>
#include <thread>
#include <chrono>

using telemetryhub::device::Device;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;


int main(int argc, char* argv[])
{
    Device dev;
    if (argc < 2)
    {
        std::cerr << "Usage: device_smoke <number_of_samples>\n";
        return 1;
    }

    int num_samples = std::stoi(argv[1]);

    std::cout << "Initial state: " << to_string(dev.state()) << "\n";

    std::cout << "Starting device...\n";
    dev.start();
    std::cout << "State after start: " << to_string(dev.state()) << "\n";

    using namespace std::chrono_literals;

    for (int i = 0; i < num_samples; ++i)
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
