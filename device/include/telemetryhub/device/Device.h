#pragma once

#include <memory>
#include <optional>
#include "TelemetrySample.h"

namespace telemetryhub::device {

enum class DeviceState
{
    Idle,
    Measuring,
    Error,
    SafeState
};

class Device
{
public:
    Device();
    ~Device();

    Device(Device&&) noexcept;
    Device& operator=(Device&&) noexcept;

    Device(const Device&) = delete;
    Device& operator=(const Device&) = delete;

    void start();
    void stop();

    DeviceState state() const;

    // Returns a new sample if available, otherwise std::nullopt
    std::optional<TelemetrySample> read_sample();

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

} // namespace telemetryhub::device
