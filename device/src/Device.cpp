#include "../telemetryhub/device/Device.h"
#include <random>

namespace telemetryhub::device {

struct Device::Impl
{
    DeviceState state = DeviceState::Idle;
    std::uint32_t sequence = 0;
    // random engine, config, etc.
};

Device::Device()
    : impl_(std::make_unique<Impl>())
{}

Device::~Device() = default;

Device::Device(Device&&) noexcept = default;
Device& Device::operator=(Device&&) noexcept = default;

void Device::start()
{
    // TODO: enforce Idle->Measuring etc.
}

void Device::stop()
{
    // TODO
}

DeviceState Device::state() const
{
    return impl_->state;
}

std::optional<TelemetrySample> Device::read_sample()
{
    // TODO: generate fake data only if Measuring
    return std::nullopt;
}

} // namespace telemetryhub::device
