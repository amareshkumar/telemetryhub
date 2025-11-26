#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"
#include "telemetryhub/Version.h"
#include "telemetryhub/version.hpp"

#include <chrono>
#include <iostream>
#include <thread>
#include <string_view>

using telemetryhub::gateway::GatewayCore;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;
using telemetryhub::device::to_string;

int main()
{
    // Quick flag check before heavier init
    for (int i = 1; i < argc; ++i) {
        std::string_view arg = argv[i];
        if (arg == "--version" || arg == "-v") {
        std::cout
            << "TelemetryHub gateway_app "
            << thub::project_version()
            << " (git: " << thub::git_tag() << ", " << thub::git_sha() << ")\n";
        return 0;
        }
        if (arg == "--help" || arg == "-h") {
        std::cout
            << "Usage: gateway_app [options]\n"
            << "  -v, --version   Print version and git info\n"
            << "  -h, --help      Show this help\n";
        return 0;
        }
    }

    using namespace std::chrono_literals;

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
