#pragma once

#include "BusInterface.h"
#include <cstdint>

namespace telemetryhub::device {

/**
 * @brief Stub implementation of SPI bus interface
 * 
 * This is a demonstration stub showing how SPI would implement IBus differently
 * than UART or I2C. In a real system, this would interface with SPI hardware.
 * 
 * Key SPI concepts:
 * - Chip Select (CS) pin for device selection
 * - Full-duplex communication (simultaneous TX/RX)
 * - Master/Slave architecture
 * - Clock polarity (CPOL) and phase (CPHA)
 * - Typically much faster than I2C or UART
 * 
 * Interview talking point: "SPI is full-duplex with chip select, I2C uses
 * addressing, and UART is a simple asynchronous stream. All three implement
 * IBus::write()/read() but their internal mechanisms are completely different.
 * This proves the value of programming to an interface—Device doesn't need
 * to know about chip select pins or I2C addresses."
 */
class SPIBus : public IBus
{
public:
    /**
     * @brief Construct SPI bus with chip select pin
     * @param cs_pin GPIO pin number for chip select
     */
    explicit SPIBus(int cs_pin = 10)
        : chip_select_pin_(cs_pin)
    {
    }

    BusType type() const override { return BusType::SPI; }

    /**
     * @brief Write data via SPI
     * 
     * Real implementation would:
     * 1. Assert chip select (CS low)
     * 2. Clock out data bits on MOSI
     * 3. Simultaneously read MISO (full-duplex)
     * 4. De-assert chip select (CS high)
     */
    bool write(const std::vector<std::uint8_t>& data) override
    {
        if (data.empty()) return true;
        
        // Stub implementation - would interface with SPI hardware here
        // e.g., asserting chip select and clocking data:
        // GPIO_CLEAR(chip_select_pin_);  // Assert CS (active low)
        // for (auto byte : data) {
        //     SPI_DATA_REG = byte;
        //     while (!(SPI_STATUS_REG & SPI_TRANSFER_COMPLETE)) { /* wait */ }
        // }
        // GPIO_SET(chip_select_pin_);    // De-assert CS
        
        // For now, just simulate success
        return true;
    }

    /**
     * @brief Read data via SPI
     * 
     * Real implementation would:
     * 1. Assert chip select (CS low)
     * 2. Clock out dummy bytes on MOSI
     * 3. Read incoming data on MISO
     * 4. De-assert chip select (CS high)
     * 
     * Note: SPI is full-duplex, so "read" often means clocking dummy data
     * while capturing the response.
     */
    bool read(std::vector<std::uint8_t>& out, std::size_t max_len) override
    {
        // Stub implementation - would read from SPI hardware here
        out.clear();
        return false; // No data in stub
    }

    /**
     * @brief Get the chip select pin number
     * 
     * Note: This is SPI-specific functionality, NOT in IBus interface.
     * This demonstrates Interface Segregation—SPI details stay in SPIBus.
     * I2C doesn't have chip select, UART doesn't have chip select, so it
     * doesn't belong in the shared interface.
     */
    int get_chip_select_pin() const { return chip_select_pin_; }

    /**
     * @brief Set chip select pin (for multi-device SPI bus)
     * 
     * SPI-specific configuration method. Each bus type has its own
     * configuration needs:
     * - SerialPortSim: inject_command(), get_response()
     * - I2CBus: get_device_address(), set_device_address()
     * - SPIBus: get_chip_select_pin(), set_chip_select_pin()
     * 
     * But all share the universal write()/read() interface!
     */
    void set_chip_select_pin(int pin) { chip_select_pin_ = pin; }

private:
    int chip_select_pin_;  // GPIO pin for chip select
};

} // namespace telemetryhub::device
