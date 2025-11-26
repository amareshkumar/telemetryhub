#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"
#include "telemetryhub/Version.h"

#include <chrono>
#include <iostream>
#include <thread>

using telemetryhub::gateway::GatewayCore;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;
using telemetryhub::device::to_string;

int main(int argc, char* argv[])
{
    using namespace std::chrono_literals;

    for (int i = 1; i < argc; ++i) {
        std::string_view a = argv[i];
        if (a == "--version" || a == "-v") {
        telemetryhub::print_version();     // <-- call it
        return 0;
        }
        if (a == "--help" || a == "-h") {
        telemetryhub::print_help(argv[0]); // <-- call it
        return 0;
        }
    }

    GatewayCore core;
    
    std::cout << "TelemetryHub " << telemetryhub::version() << "\n";

    std::cout << "Starting TelemetryHub gateway_app...\n";
    core.start();

    std::cout << "Monitoring device for a while...\n";

    for (int i = 0; i < 50; ++i)
    {
        auto state = core.device_state();
        auto latest = core.latest_sample();

        std::cout << "[tick " << i << "] state=" << to_string(state);

        if (latest)
        {
            const TelemetrySample& s = *latest;
            std::cout << " | latest sample #" << s.sequence_id
                      << " value=" << s.value
                      << " " << s.unit;
        }
        else
        {
            std::cout << " | no sample yet";
        }

        std::cout << "\n";

        if (state == DeviceState::SafeState)
        {
            std::cout << "Device reached SafeState, breaking monitoring loop.\n";
            break;
        }

        std::this_thread::sleep_for(200ms);
    }

    std::cout << "Stopping core...\n";
    core.stop();
    std::cout << "gateway_app exiting.\n";

    return 0;
}
