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

// Forward declare HTTP server runner
namespace telemetryhub { namespace gateway { 
    struct AppConfig; 
    int run_http_server(unsigned short port); 
    int run_http_server_with_config(unsigned short port, const AppConfig& cfg);
}}

int main(int argc, char* argv[])
{
    using namespace std::chrono_literals;
    std::optional<telemetryhub::LogLevel> lvl;
    std::string log_file;
    std::string config_path;

    for (int i=1;i<argc;i++){
        std::string_view a = argv[i];
        if (a=="--log-level" && i+1<argc) { 
            lvl = parse_level(argv[++i]); 
        }
        else if (a=="--log-file" && i+1<argc) { 
            log_file = argv[++i]; 
        }
        else if (a=="--config" && i+1<argc) {
            config_path = argv[++i];
        }
    }
    // Load config if provided
    if (!config_path.empty()) {
        telemetryhub::gateway::AppConfig cfg;
        if (telemetryhub::gateway::load_config(config_path, cfg)){
            lvl = cfg.log_level; // override from config
            telemetryhub::Logger::instance().set_level(cfg.log_level);
            // Apply runtime knobs to core
            // We'll set on an instance below after it's created
        } else {
            TELEMETRYHUB_LOGW("main","failed to load config file; continuing with defaults");
        }
    }
    if (lvl) telemetryhub::Logger::instance().set_level(*lvl);
    if (!log_file.empty()) {
        if (!telemetryhub::Logger::instance().open_file(log_file))
        TELEMETRYHUB_LOGW("main", "failed to open log file; continuing with stdout");
    }
    TELEMETRYHUB_LOGI("main","gateway starting");
    // after setting level and opening file:
TELEMETRYHUB_LOGI("main", "logger online (console)");
TELEMETRYHUB_LOGD("main", "debug visible only at --log-level debug+");
TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Trace, "main", "trace visible only at --log-level trace or below");
    telemetryhub::print_version();

    std::signal(SIGINT, on_sigint); // Ctrl-C (Windows console gets SIGINT too)

    telemetryhub::gateway::AppConfig cfg_apply; // default
    bool have_cfg = false;
    if (!config_path.empty()) {
        have_cfg = telemetryhub::gateway::load_config(config_path, cfg_apply);
    }

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

    std::cout << "TelemetryHub " << telemetryhub::version() << "\n";
    TELEMETRYHUB_LOGI("main","Starting HTTP server on port 8080");
    // Start server (non-blocking in stub; blocking with real cpp-httplib)
    if (have_cfg) telemetryhub::gateway::run_http_server_with_config(8080, cfg_apply);
    else telemetryhub::gateway::run_http_server(8080);

    // Wait for Ctrl-C
    while (!g_stop.load()) {
        std::this_thread::sleep_for(200ms);
    }
    TELEMETRYHUB_LOGI("main","Shutdown requested; stopping gateway.");
    // Graceful shutdown is handled via HTTP /stop endpoint or when run_http_server exits.
    std::cout << "gateway_app exiting.\n";

    return 0;
}
