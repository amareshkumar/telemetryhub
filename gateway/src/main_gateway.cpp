#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"
#include "telemetryhub/Version.h"
#include "telemetryhub/gateway/Log.h"

#include <chrono>
#include <iostream>
#include <thread>
#include <csignal>
#include <atomic>

using telemetryhub::gateway::GatewayCore;
using telemetryhub::device::DeviceState;
using telemetryhub::device::TelemetrySample;
using telemetryhub::device::to_string;

static std::atomic<bool> g_stop{false};
static void on_sigint(int){ g_stop.store(true); }

static telemetryhub::LogLevel parse_level(std::string_view s){
  if (s=="error") return telemetryhub::LogLevel::Error;
  if (s=="warn")  return telemetryhub::LogLevel::Warn;
  if (s=="info")  return telemetryhub::LogLevel::Info;
  if (s=="debug") return telemetryhub::LogLevel::Debug;
  return telemetryhub::LogLevel::Trace;
}

int main(int argc, char* argv[])
{
    using namespace std::chrono_literals;
    std::optional<telemetryhub::LogLevel> lvl;
    std::string log_file;

    for (int i=1;i<argc;i++){
        std::string_view a = argv[i];
        if (a=="--log-level" && i+1<argc) { 
            lvl = parse_level(argv[++i]); 
        }
        else if (a=="--log-file" && i+1<argc) { 
            log_file = argv[++i]; 
        }
    }
    if (lvl) telemetryhub::Logger::instance().set_level(*lvl);
    if (!log_file.empty()) {
        if (!telemetryhub::Logger::instance().open_file(log_file))
        TELEMETRYHUB_LOGW("main", "failed to open log file; continuing with stdout");
    }

    std::signal(SIGINT, on_sigint); // Ctrl-C (Windows console gets SIGINT too)

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
