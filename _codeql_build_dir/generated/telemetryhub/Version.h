#pragma once
#include <iostream>

namespace telemetryhub {

inline const char* version()  { return "0.9.0"; }
inline const char* git_tag()  { return "c6cf9a3-dirty"; }
inline const char* git_sha()  { return "c6cf9a3"; }

static inline void print_version() {
  std::cout << "TelemetryHub " << version()
            << " (git: " << git_tag()
            << ", " << git_sha() << ")\n";
}

static inline void print_help(const char* prog) {
  std::cout << "Usage: " << (prog ? prog : "gateway_app") << " [options]\n"
            << "  -v, --version    Print version and git info\n"
            << "  -h, --help       Show this help\n";
}

} // namespace telemetryhub
