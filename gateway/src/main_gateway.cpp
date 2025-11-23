// TelemetryHub gateway main application
// Uses to_string(DeviceState) and to_string(TelemetrySample) for concise logging.

#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"      // to_string(DeviceState)
#include "telemetryhub/device/telemetryUtils.h"    // to_string(TelemetrySample)

#include <chrono>
#include <iostream>
#include <thread>

using telemetryhub::gateway::GatewayCore;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;

namespace {
    // Pretty-print latest sample or placeholder if missing
    std::string latest_sample_str(const std::optional<TelemetrySample>& opt)
    {
        if (!opt)
            return "(none)";
        return telemetryhub::device::to_string(*opt);
    }
}

int main()
{
    using namespace std::chrono_literals;
    std::cout << "Starting TelemetryHub gateway_app...\n";

    GatewayCore core;
    core.start();

    std::cout << "Monitoring device for a while...\n";

    const int max_ticks = 50;
    for (int tick = 0; tick < max_ticks; ++tick)
    {
        auto state = core.device_state();
        auto latest = core.latest_sample();

        std::cout << "[tick " << tick << "] state=" << telemetryhub::device::to_string(state)
                  << " | sample=" << latest_sample_str(latest) << "\n";

        if (state == DeviceState::SafeState)
        {
            std::cout << "Device reached SafeState, stopping early.\n";
            break;
        }

        std::this_thread::sleep_for(200ms);
    }

    std::cout << "Stopping core...\n";
    core.stop();
    std::cout << "gateway_app exiting.\n";
    return 0;
}
