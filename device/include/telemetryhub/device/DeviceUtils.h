#pragma once
#include "Device.h"

namespace telemetryhub::device {

static const char* to_string(DeviceState s)
{
    switch (s)
    {
    case DeviceState::Idle:      return "Idle";
    case DeviceState::Measuring: return "Measuring";
    case DeviceState::Error:     return "Error";
    case DeviceState::SafeState: return "SafeState";
    }
    return "Unknown";
}

} // namespace telemetryhub::device