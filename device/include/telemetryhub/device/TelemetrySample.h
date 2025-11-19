#pragma once

#include <chrono>
#include <cstdint>
#include <string>

namespace telemetryhub::device {

struct TelemetrySample
{
    std::chrono::system_clock::time_point timestamp{};
    double value = 0.0;
    std::string unit{"unitless"};
    std::uint32_t sequence_id = 0;
};

} // namespace telemetryhub::device
