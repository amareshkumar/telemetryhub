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
};

Device::Device()
    : impl_(std::make_unique<Impl>())
{}

Device::~Device() = default;

Device::Device(Device&&) noexcept = default;
Device& Device::operator=(Device&&) noexcept = default;

void Device::start()
{
    if (impl_->state == DeviceState::Idle){
        impl_->sequence = 0;
        impl_->state = DeviceState::Measuring;
    }
}

void Device::stop()
{
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

    // For demonstration, we generate a new sample on each call
    return impl_->make_sample();
}

} // namespace telemetryhub::device
