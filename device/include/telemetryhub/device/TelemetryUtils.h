#pragma once

#include "TelemetrySample.h"
#include <sstream>
#include <iomanip>

namespace telemetryhub::device {

inline std::string format_timestamp(
    std::chrono::system_clock::time_point tp)
{
    using namespace std::chrono;
    auto t = system_clock::to_time_t(tp);
    std::tm tm{};
#if defined(_WIN32)
    gmtime_s(&tm, &t);
#else
    gmtime_r(&tm, &t);
#endif
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%dT%H:%M:%SZ");
    return oss.str();
}

inline std::string to_string(const TelemetrySample& s)
{
    std::ostringstream oss;
    oss << "id=" << s.sequence_id
        << " ts=" << format_timestamp(s.timestamp)
        << " value=" << s.value << " " << s.unit;
    return oss.str();
}

} // namespace telemetryhub::device
