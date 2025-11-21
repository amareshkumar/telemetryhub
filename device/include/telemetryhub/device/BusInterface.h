#pragma once

#include <cstdint>
#include <vector>

namespace telemetryhub::device {

enum class BusType { UART, I2C, SPI };

class IBus
{
public:
    virtual ~IBus() = default;

    virtual BusType type() const = 0;

    // Simple API – fine for a demo.
    virtual bool write(const std::vector<std::uint8_t>& data) = 0;
    virtual bool read(std::vector<std::uint8_t>& out, std::size_t max_len) = 0;
};

} // namespace telemetryhub::device
