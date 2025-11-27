#pragma once
#include <atomic>
#include <chrono>
#include <cstdio>
#include <ctime>
#include <mutex>
#include <string>

namespace telemetryhub {

enum class LogLevel { Error=0, Warn=1, Info=2, Debug=3, Trace=4 };

class Logger {
public:
  static Logger& instance() { static Logger L; return L; }

  void set_level(LogLevel lvl) { level_.store((int)lvl, std::memory_order_relaxed); }
  LogLevel level() const { return (LogLevel)level_.load(std::memory_order_relaxed); }

  // optional file sink
  bool open_file(const std::string& path) {
    std::lock_guard<std::mutex> lk(mu_);
    if (file_) { std::fclose(file_); file_ = nullptr; }
    file_ = std::fopen(path.c_str(), "w");
    return file_ != nullptr;
  }

  void log(LogLevel lvl, const char* cat, const std::string& msg) {
    if ((int)lvl > level_.load(std::memory_order_relaxed)) return;

    char ts[24];
    std::time_t t = std::time(nullptr);
    std::strftime(ts, sizeof(ts), "%Y-%m-%d %H:%M:%S", std::localtime(&t));

    const char* L = lvl_name(lvl);
    std::lock_guard<std::mutex> lk(mu_);
    std::fprintf(stdout, "%s [%s] (%s) %s\n", ts, L, cat, msg.c_str());
    if (file_) std::fprintf(file_, "%s [%s] (%s) %s\n", ts, L, cat, msg.c_str());
  }

private:
  static const char* lvl_name(LogLevel l){
    switch(l){
      case LogLevel::Error: return "ERROR";
      case LogLevel::Warn:  return "WARN";
      case LogLevel::Info:  return "INFO";
      case LogLevel::Debug: return "DEBUG";
      default:              return "TRACE";
    }
  }

  std::atomic<int> level_{(int)LogLevel::Info};
  std::mutex mu_;
  std::FILE* file_{nullptr};
};

// convenience macros (telemetryhub-prefixed)
#define TELEMETRYHUB_LOG(lvl, cat, msg) ::telemetryhub::Logger::instance().log((lvl),(cat),(msg))
#define TELEMETRYHUB_LOGE(cat, msg) TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Error, (cat), (msg))
#define TELEMETRYHUB_LOGW(cat, msg) TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Warn,  (cat), (msg))
#define TELEMETRYHUB_LOGI(cat, msg) TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Info,  (cat), (msg))
#define TELEMETRYHUB_LOGD(cat, msg) TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Debug, (cat), (msg))

} // namespace telemetryhub
