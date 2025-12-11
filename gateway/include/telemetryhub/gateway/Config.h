#pragma once
#include <string>
#include <chrono>
#include "telemetryhub/gateway/Log.h"

namespace telemetryhub::gateway {

struct AppConfig {
  std::chrono::milliseconds sampling_interval{std::chrono::milliseconds(100)};
  size_t queue_size{0}; // 0 = unbounded
  ::telemetryhub::LogLevel log_level{::telemetryhub::LogLevel::Info};
};

// Returns true on success; false if file unreadable or parse error.
bool load_config(const std::string& path, AppConfig& out);

}
