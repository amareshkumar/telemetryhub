#define CPPHTTPLIB_ZSTD_SUPPORT 0
#define CPPHTTPLIB_BROTLI_SUPPORT 0
#define CPPHTTPLIB_ZLIB_SUPPORT 0
#define CPPHTTPLIB_OPENSSL_SUPPORT 0
#define CPPHTTPLIB_NO_ZSTD 1
#define CPPHTTPLIB_NO_BROTLI 1
#define CPPHTTPLIB_NO_ZLIB 1
#define CPPHTTPLIB_NO_OPENSSL 1
#include <httplib.h>

#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/gateway/Log.h"
#include "telemetryhub/device/DeviceUtils.h"

#include <sstream>
#include <memory>

// minimal server exposing GatewayCore control/status via HTTP REST API
namespace telemetryhub::gateway {

static std::shared_ptr<GatewayCore> g_gateway;

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
  if (!g_gateway) g_gateway = std::make_shared<GatewayCore>();
  httplib::Server svr;

  svr.Get("/status", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    auto body = json_status();
    res.set_content(body, "application/json");
  });

  svr.Post("/start", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    g_gateway->start();
    res.set_content("{\"ok\":true}", "application/json");
  });

  svr.Post("/stop", [](const httplib::Request& req, httplib::Response& res){
    (void)req;
    g_gateway->stop();
    res.set_content("{\"ok\":true}", "application/json");
  });

  TELEMETRYHUB_LOGI("http", (std::string("Listening on port ") + std::to_string(port)).c_str());
  svr.listen("0.0.0.0", static_cast<int>(port));
  return 0;
}

} // namespace telemetryhub::gateway
