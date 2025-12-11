#include "http_config.h"
#include <httplib.h>

#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/gateway/Log.h"
#include "telemetryhub/gateway/Config.h"
#include "telemetryhub/device/DeviceUtils.h"

#include <sstream>
#include <memory>
#include <mutex>

// minimal server exposing GatewayCore control/status via HTTP REST API
namespace telemetryhub::gateway {

// Note: run_http_server must only be called once from a single thread.
// The g_gateway pointer is initialized once and then read by HTTP handlers.
static std::shared_ptr<GatewayCore> g_gateway;
static std::once_flag g_init_flag;

static std::string json_status() {
  if (!g_gateway) {
    return "{\"error\":\"Gateway not initialized\"}";
  }
  std::ostringstream os;
  auto state = g_gateway->device_state();
  auto latest = g_gateway->latest_sample();
  os << "{\"state\":\"" << device::to_string(state) << "\",";
  os << "\"latest_sample\":";
  if (latest) {
    os << "{\"seq\":" << latest->sequence_id
       << ",\"value\":" << latest->value
       << ",\"unit\":\"" << latest->unit << "\"}";
  } else {
    os << "null";
  }
  os << "}";
  return os.str();
}

static void apply_cfg_if_any(const telemetryhub::gateway::AppConfig* cfg){
  if (!cfg) return;
  if (!g_gateway) return;
  g_gateway->set_sampling_interval(cfg->sampling_interval);
  g_gateway->set_queue_capacity(cfg->queue_size);
  ::telemetryhub::Logger::instance().set_level(cfg->log_level);
}

int run_http_server(unsigned short port) {
  std::call_once(g_init_flag, []{ g_gateway = std::make_shared<GatewayCore>(); });
  httplib::Server svr;

  svr.Get("/status", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    if (!g_gateway) {
      res.status = 500;
      res.set_content("{\"error\":\"Gateway not initialized\"}", "application/json");
      return;
    }
    auto body = json_status();
    res.set_content(body, "application/json");
  });

  svr.Post("/start", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    if (!g_gateway) {
      res.status = 500;
      res.set_content("{\"error\":\"Gateway not initialized\"}", "application/json");
      return;
    }
    g_gateway->start();
    res.set_content("{\"ok\":true}", "application/json");
  });

  svr.Post("/stop", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    if (!g_gateway) {
      res.status = 500;
      res.set_content("{\"error\":\"Gateway not initialized\"}", "application/json");
      return;
    }
    g_gateway->stop();
    res.set_content("{\"ok\":true}", "application/json");
  });

  svr.Get("/metrics", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    if (!g_gateway) {
      res.status = 500;
      res.set_content("{\"error\":\"Gateway not initialized\"}", "application/json");
      return;
    }
    auto metrics = g_gateway->get_metrics();
    std::ostringstream os;
    os << "{";
    os << "\"samples_processed\":" << metrics.samples_processed << ",";
    os << "\"samples_dropped\":" << metrics.samples_dropped << ",";
    os << "\"queue_depth\":" << metrics.queue_depth << ",";
    os << "\"latency_p99_ms\":" << metrics.latency_p99_ms << ",";
    os << "\"uptime_seconds\":" << metrics.uptime_seconds;
    os << "}";
    res.set_content(os.str(), "application/json");
  });

  TELEMETRYHUB_LOGI("http", (std::string("Listening on port ") + std::to_string(port)).c_str());
  svr.listen("0.0.0.0", static_cast<int>(port));
  return 0;
}

int run_http_server_with_config(unsigned short port, const telemetryhub::gateway::AppConfig& cfg) {
  std::call_once(g_init_flag, []{ g_gateway = std::make_shared<GatewayCore>(); });
  apply_cfg_if_any(&cfg);
  return run_http_server(port);
}

} // namespace telemetryhub::gateway
