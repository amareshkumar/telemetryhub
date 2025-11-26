#pragma once

#include <string_view>
#include <iostream>

namespace telemetryhub {

inline constexpr std::string_view version() noexcept
{
    return "0.1.0";
}

static void print_version() {
  std::cout << "TelemetryHub gateway_app "
            << telemetryhub::project_version()
            << " (git: " << telemetryhub::git_tag()
            << ", " << telemetryhub::git_sha() << ")\n";
}

static void print_help(const char* prog) {
  std::cout << "Usage: " << prog << " [options]\n"
            << "  -v, --version    Print version and git info\n"
            << "  -h, --help       Show this help\n";
}

} // namespace telemetryhub
