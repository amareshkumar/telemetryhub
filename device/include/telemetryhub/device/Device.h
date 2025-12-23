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

/**
 * @brief Fault injection modes for testing robustness
 * 
 * Interview Note: Demonstrates systematic fault injection for testing
 * error handling paths—critical for safety-critical systems.
 */
enum class FaultInjectionMode
{
    None,                    // No faults injected (default production mode)
    RandomSensorErrors,      // Intermittent sensor read failures (simulates flaky hardware)
    CommunicationFailure,    // Serial/bus communication timeouts
    Both                     // Combined failure modes (worst case)
};

class Device
{
public:
    /**
     * @brief Construct device with configurable fault injection
     * @param fault_after_samples Number of successful samples before triggering fault (0 = disabled)
     * @param mode Type of faults to inject (default: None for production)
     * @param error_probability Probability [0.0-1.0] of random errors (for Random modes)
     */
    explicit Device(int fault_after_samples = 0, 
                    FaultInjectionMode mode = FaultInjectionMode::None,
                    double error_probability = 0.1);
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
    // May return nullopt due to: not measuring, fault threshold, or random errors
    std::optional<TelemetrySample> read_sample();

    /**
     * @brief Reset device from Error/SafeState back to Idle
     * 
     * Interview Note: Explicit recovery mechanism—devices don't auto-recover
     * from faults without operator intervention (safety requirement).
     * 
     * @return true if reset successful, false if already in valid state
     */
    bool reset();

    /**
     * @brief Get count of consecutive failures
     * Useful for monitoring system health before SafeState
     */
    int consecutive_failure_count() const;

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
