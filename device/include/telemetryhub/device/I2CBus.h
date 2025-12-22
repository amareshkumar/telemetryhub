#pragma once

#include "BusInterface.h"
#include <cstdint>

namespace telemetryhub::device {

/**
 * @brief Stub implementation of I2C bus interface
 * 
 * This is a demonstration stub showing how I2C would implement IBus differently
 * than UART. In a real system, this would interface with I2C hardware registers.
 * 
 * Key I2C concepts:
 * - Device addressing (7-bit or 10-bit addresses)
 * - START/STOP conditions
 * - ACK/NACK protocol
 * - Clock stretching
 * 
 * Interview talking point: "I2C and UART are fundamentally different protocols.
 * I2C uses addressing and acknowledgments, while UART is a simple byte stream.
 * They both implement IBus::write()/read(), but the internal implementation
 * is completely different—proving why interface over inheritance is correct."
 */
class I2CBus : public IBus
{
public:
    /**
     * @brief Construct I2C bus with device address
     * @param device_addr 7-bit I2C device address (0x00-0x7F)
     */
    explicit I2CBus(std::uint8_t device_addr = 0x50)
        : device_address_(device_addr)
    {
    }

    BusType type() const override { return BusType::I2C; }

    /**
     * @brief Write data to I2C device
     * 
     * Real implementation would:
     * 1. Send START condition
     * 2. Send device address + write bit
     * 3. Wait for ACK
     * 4. Send data bytes
     * 5. Wait for ACK after each byte
     * 6. Send STOP condition
     */
    bool write(const std::vector<std::uint8_t>& data) override
    {
        if (data.empty()) return true;
        
        // Stub implementation - would interface with I2C hardware here
        // e.g., writing to I2C controller registers:
        // I2C_CTRL_REG |= I2C_START;
        // I2C_DATA_REG = (device_address_ << 1) | 0; // Write bit
        // while (!(I2C_STATUS_REG & I2C_ACK)) { /* wait */ }
        
        // For now, just simulate success
        return true;
    }

    /**
     * @brief Read data from I2C device
     * 
     * Real implementation would:
     * 1. Send START condition
     * 2. Send device address + read bit
     * 3. Wait for ACK
     * 4. Read data bytes, sending ACK after each
     * 5. Send NACK after last byte
     * 6. Send STOP condition
     */
    bool read(std::vector<std::uint8_t>& out, std::size_t max_len) override
    {
        // Stub implementation - would read from I2C hardware here
        out.clear();
        return false; // No data in stub
    }

    /**
     * @brief Get the I2C device address
     * 
     * Note: This is I2C-specific functionality, NOT in IBus interface.
     * This demonstrates Interface Segregation—I2C details stay in I2CBus.
     */
    std::uint8_t get_device_address() const { return device_address_; }

    /**
     * @brief Set I2C device address
     * 
     * I2C-specific configuration method. Compare to SerialPortSim which has
     * inject_command() and get_response()—different buses need different
     * auxiliary methods, but all share the core write()/read() interface.
     */
    void set_device_address(std::uint8_t addr) { device_address_ = addr; }

private:
    std::uint8_t device_address_;  // 7-bit I2C address
};

} // namespace telemetryhub::device
