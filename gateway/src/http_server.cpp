#include <httplib.h>

#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/gateway/Log.h"
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

  TELEMETRYHUB_LOGI("http", (std::string("Listening on port ") + std::to_string(port)).c_str());
  svr.listen("0.0.0.0", static_cast<int>(port));
  return 0;
}

} // namespace telemetryhub::gateway
