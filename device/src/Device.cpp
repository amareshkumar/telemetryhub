#include "telemetryhub/device/Device.h"
#include "telemetryhub/device/BusInterface.h"
#include <random>
#include <cmath>
#include <sstream>
#include <algorithm>

namespace telemetryhub::device {

struct Device::Impl
{
    DeviceState state = DeviceState::Idle;
    std::uint32_t sequence = 0;
    std::mt19937_64 rng{std::random_device{}()}; // random number generator
    std::normal_distribution<double> noise_dist{0.0, 0.1}; // Gaussian noise
    std::uniform_real_distribution<double> error_dist{0.0, 1.0}; // For random errors

    // Fault simulation - deterministic threshold
    std::uint32_t samples_before_fault = 0; // 0 = disabled, >0 = fault after N samples
    int error_counter = 0;
    int max_errors = 1; // allow only one error before safe state

    // Fault injection - random/intermittent failures
    FaultInjectionMode fault_mode = FaultInjectionMode::None;
    double error_probability = 0.1; // Probability of random error (10% default)
    int consecutive_failures = 0;   // Track consecutive read failures

    // Serial communication
    IBus* serial_bus = nullptr;
    std::uint32_t sampling_rate_ms = 100; // default 100ms between samples


    TelemetrySample make_sample()
    {
        using clock = std::chrono::system_clock;

        TelemetrySample s;
        s.timestamp = clock::now();
        // Simple fake waveform: 42 + small sine + random noise
        const double t = static_cast<double>(sequence) / 10.0;
        s.value = 42.0 + std::sin(t) + noise_dist(rng);
        s.unit = "arb.units";
        s.sequence_id = sequence++;
        return s;
    }

    void enter_error_state()
    {
        // Latch directly to SafeState on any error
        state = DeviceState::SafeState;
        error_counter++;
    }

    void reset_sequence()
    {
        sequence = 0;
        error_counter = 0;
        consecutive_failures = 0;
    }

    /**
     * @brief Check if random error should be injected
     * 
     * Interview Note: Probabilistic fault injection—simulates real-world
     * intermittent failures. Used in chaos engineering and reliability testing.
     */
    bool should_inject_random_error()
    {
        if (fault_mode == FaultInjectionMode::None)
            return false;

        if (fault_mode == FaultInjectionMode::CommunicationFailure)
            return false; // Only affects serial, not sensor reads

        // RandomSensorErrors or Both
        return error_dist(rng) < error_probability;
    }

    /**
     * @brief Check if communication should fail
     */
    bool should_inject_comm_failure()
    {
        if (fault_mode == FaultInjectionMode::None)
            return false;

        if (fault_mode == FaultInjectionMode::RandomSensorErrors)
            return false; // Only affects sensor, not serial

        // CommunicationFailure or Both
        return error_dist(rng) < error_probability;
    }

    std::string process_command(const std::string& cmd)
    {
        // Trim whitespace
        std::string trimmed = cmd;
        trimmed.erase(trimmed.find_last_not_of(" \t\n\r") + 1);
        trimmed.erase(0, trimmed.find_first_not_of(" \t\n\r"));

        if (trimmed.empty()) {
            return "ERROR: Empty command";
        }

        // CALIBRATE command
        if (trimmed == "CALIBRATE") {
            if (state == DeviceState::Measuring) {
                reset_sequence();
                return "OK: Calibrated";
            }
            return "ERROR: Device not measuring";
        }

        // GET_STATUS command
        if (trimmed == "GET_STATUS") {
            std::ostringstream oss;
            oss << "STATUS: ";
            switch (state) {
                case DeviceState::Idle: oss << "Idle"; break;
                case DeviceState::Measuring: oss << "Measuring"; break;
                case DeviceState::Error: oss << "Error"; break;
                case DeviceState::SafeState: oss << "SafeState"; break;
            }
            oss << ", Seq=" << sequence;
            return oss.str();
        }

        // RESET command
        if (trimmed == "RESET") {
            state = DeviceState::Idle;
            reset_sequence();
            return "OK: Reset to Idle";
        }

        // SET_RATE=<value> command
        if (trimmed.substr(0, 9) == "SET_RATE=") {
            try {
                std::uint32_t rate = std::stoul(trimmed.substr(9));
                if (rate < 10 || rate > 10000) {
                    return "ERROR: Rate must be 10-10000 ms";
                }
                sampling_rate_ms = rate;
                std::ostringstream oss;
                oss << "OK: Rate set to " << rate << " ms";
                return oss.str();
            } catch (...) {
                return "ERROR: Invalid rate value";
            }
        }

        return "ERROR: Unknown command";
    }
};

Device::Device(int fault_after_samples, FaultInjectionMode mode, double error_probability)
    : impl_(std::make_unique<Impl>())
{
    impl_->samples_before_fault = fault_after_samples;
    impl_->fault_mode = mode;
    impl_->error_probability = std::clamp(error_probability, 0.0, 1.0);
}

Device::~Device() = default;

Device::Device(Device&&) noexcept = default;
Device& Device::operator=(Device&&) noexcept = default;

void Device::start()
{
    // Only allow starting from Idle.
    // If we are in Error or SafeState, we do NOT auto-recover here.
    if (impl_->state == DeviceState::Idle){
        impl_->reset_sequence();
        impl_->state = DeviceState::Measuring;
    }
}

void Device::stop()
{
    // Only allow stopping from Measuring; otherwise ignore.
    if (impl_->state == DeviceState::Measuring){
        impl_->state = DeviceState::Idle;
    }
}

DeviceState Device::state() const
{
    return impl_->state;
}

std::optional<TelemetrySample> Device::read_sample()
{
    if (impl_->state != DeviceState::Measuring){
        return std::nullopt;
    }

    // Random error injection (simulates intermittent sensor failures)
    if (impl_->should_inject_random_error()) {
        impl_->consecutive_failures++;
        // Don't enter_error_state here—let GatewayCore decide policy
        return std::nullopt;
    }

    // Deterministic fault threshold (simulates cumulative wear/degradation)
    if (impl_->samples_before_fault > 0 && 
        impl_->sequence >= impl_->samples_before_fault) {
        impl_->enter_error_state();
        return std::nullopt;
    }

    // Successful read—reset consecutive failure counter
    impl_->consecutive_failures = 0;

    return impl_->make_sample();
}

bool Device::reset()
{
    // Can only reset from Error or SafeState (explicit recovery)
    if (impl_->state == DeviceState::Error || 
        impl_->state == DeviceState::SafeState) {
        impl_->state = DeviceState::Idle;
        impl_->reset_sequence();
        return true;
    }
    return false; // Already in valid state
}

int Device::consecutive_failure_count() const
{
    return impl_->consecutive_failures;
}

void Device::set_serial_bus(IBus* bus)
{
    impl_->serial_bus = bus;
}

std::optional<std::string> Device::process_serial_commands()
{
    if (!impl_->serial_bus) {
        return std::nullopt;
    }

    // Communication failure injection (simulates bus timeout/garbled data)
    if (impl_->should_inject_comm_failure()) {
        return std::nullopt; // Simulate timeout/no response
    }

    std::vector<std::uint8_t> buffer;
    if (!impl_->serial_bus->read(buffer, 256)) {
        return std::nullopt; // No data available
    }

    if (buffer.empty()) {
        return std::nullopt;
    }

    // Convert bytes to string
    std::string command(buffer.begin(), buffer.end());

    // Process command
    std::string response = impl_->process_command(command);

    // Write response back to serial bus
    response += "\n";
    std::vector<std::uint8_t> response_bytes(response.begin(), response.end());
    impl_->serial_bus->write(response_bytes);

    return response;
}

} // namespace telemetryhub::device
