#include "../include/telemetryhub/device/Device.h"
#include <random>
#include <cmath>

namespace telemetryhub::device {

struct Device::Impl
{
    DeviceState state = DeviceState::Idle;
    std::uint32_t sequence = 0;
    std::mt19937_64 rng{std::random_device{}()}; // random number generator
    std::normal_distribution<double> noise_dist{0.0, 0.1}; // Gaussian noise

    // Fault simulation
    std::uint32_t samples_before_fault = 8; // e.g., fault after 8 samples/. Default, can be overridden
    int error_counter = 0;
    int max_errors = 1; // allow only one error before safe state


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
        state = DeviceState::Error;
        error_counter++;

        if (error_counter > max_errors)
        {
            state = DeviceState::SafeState;
        }   
    }

    void reset_sequence()
    {
        sequence = 0;
        error_counter = 0;
    }
};

Device::Device(int fault_after_samples)
    : impl_(std::make_unique<Impl>())
{
    impl_->samples_before_fault = fault_after_samples;
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

    // Simulate fault condition
    if (impl_->sequence >= impl_->samples_before_fault){
        // simulate device error
        impl_->enter_error_state();
        return std::nullopt;
    }

    // For demonstration, we generate a new sample on each call
    return impl_->make_sample();
}

} // namespace telemetryhub::device
