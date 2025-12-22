#pragma once

#include <memory>
#include <optional>
#include <string>
#include "TelemetrySample.h"

namespace telemetryhub::device {

class IBus;

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
    explicit Device(int fault_after_samples = 8);
    ~Device();

    Device(Device&&) noexcept;
    Device& operator=(Device&&) noexcept;

    Device(const Device&) = delete;
    Device& operator=(const Device&) = delete;

    // Control
    void start();  // request start of measurement
    void stop();   // request stop of measurement

    DeviceState state() const;

    // Returns a new sample if available, otherwise std::nullopt
    std::optional<TelemetrySample> read_sample();

    // Serial/Command interface
    /**
     * @brief Set the serial bus interface for command communication
     * @param bus Pointer to IBus implementation (e.g., SerialPortSim)
     */
    void set_serial_bus(IBus* bus);

    /**
     * @brief Process pending commands from the serial bus
     * @return Response string if a command was processed
     * 
     * Supported commands:
     * - "CALIBRATE" - Recalibrate the device (resets sequence)
     * - "SET_RATE=<ms>" - Set sampling rate (future use)
     * - "GET_STATUS" - Returns current state and sequence
     * - "RESET" - Reset to idle state
     */
    std::optional<std::string> process_serial_commands();

private:
    struct Impl;
    std::unique_ptr<Impl> impl_;
};

} // namespace telemetryhub::device
