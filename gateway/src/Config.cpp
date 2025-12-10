#include "telemetryhub/gateway/Config.h"

#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>

namespace {
inline std::string trim(std::string s){
  auto notspace = [](int ch){ return !std::isspace(ch); };
  s.erase(s.begin(), std::find_if(s.begin(), s.end(), notspace));
  s.erase(std::find_if(s.rbegin(), s.rend(), notspace).base(), s.end());
  return s;
}

inline ::telemetryhub::LogLevel parse_level(const std::string& s){
  if (s == "error") return ::telemetryhub::LogLevel::Error;
  if (s == "warn" || s=="warning")  return ::telemetryhub::LogLevel::Warn;
  if (s == "info")  return ::telemetryhub::LogLevel::Info;
  if (s == "debug") return ::telemetryhub::LogLevel::Debug;
  return ::telemetryhub::LogLevel::Trace;
}
}

namespace telemetryhub::gateway {

bool load_config(const std::string& path, AppConfig& out)
{
  std::ifstream f(path);
  if (!f.is_open()) return false;
  std::string line;
  while (std::getline(f, line)){
    auto hash = line.find('#');
    if (hash != std::string::npos) line = line.substr(0, hash);
    auto semi = line.find(';');
    if (semi != std::string::npos) line = line.substr(0, semi);
    line = trim(line);
    if (line.empty()) continue;
    auto eq = line.find('=');
    if (eq == std::string::npos) continue;
    auto key = trim(line.substr(0, eq));
    auto val = trim(line.substr(eq+1));
    std::transform(key.begin(), key.end(), key.begin(), ::tolower);
    if (key == "sampling_interval_ms"){
      out.sampling_interval = std::chrono::milliseconds(std::stoll(val));
    } else if (key == "queue_size"){
      out.queue_size = static_cast<size_t>(std::stoull(val));
    } else if (key == "log_level"){
      out.log_level = parse_level(val);
    }
  }
  return true;
}

}
