#pragma once

#include "BusInterface.h"
#include <string>
#include <queue>
#include <mutex>
#include <optional>

namespace telemetryhub::device {

/**
 * @brief Simulated serial port (UART) implementing the IBus interface.
 * 
 * Provides a thread-safe buffer-based simulation of a serial communication port.
 * Supports write operations (device sends data) and read operations (device receives commands).
 * 
 * Use cases:
 * - Testing device communication without hardware
 * - Simulating command/response protocols
 * - Demonstrating hardware abstraction in interviews
 */
class SerialPortSim : public IBus
{
public:
    SerialPortSim();
    ~SerialPortSim() override = default;

    // IBus interface implementation
    BusType type() const override { return BusType::UART; }
    
    /**
     * @brief Write data to the serial port (device -> external)
     * @param data Bytes to write
     * @return true if successful
     */
    bool write(const std::vector<std::uint8_t>& data) override;
    
    /**
     * @brief Read data from the serial port (external -> device)
     * @param out Buffer to store read data
     * @param max_len Maximum bytes to read
     * @return true if data was available and read
     */
    bool read(std::vector<std::uint8_t>& out, std::size_t max_len) override;

    // Simulation-specific methods

    /**
     * @brief Inject command data into the serial port (simulates external sender)
     * @param command String to inject (will be converted to bytes)
     */
    void inject_command(const std::string& command);

    /**
     * @brief Read response data from the serial port (simulates external receiver)
     * @return Response string if available, or empty optional
     */
    std::optional<std::string> get_response();

    /**
     * @brief Check if there is data available to read
     * @return Number of bytes in the input buffer
     */
    std::size_t available() const;

    /**
     * @brief Clear all buffers
     */
    void clear();

    /**
     * @brief Configure simulated baud rate
     * @param rate Baud rate (e.g., 9600, 115200)
     * 
     * Note: This is UART-specific configuration, NOT in IBus interface.
     * This demonstrates Interface Segregation—UART details stay in SerialPortSim.
     * 
     * Why not in IBus?
     * - I2C uses clock speed, not baud rate
     * - SPI uses clock frequency, not baud rate
     * - Only UART has "baud rate" concept
     * 
     * Interview point: "I kept IBus minimal. Bus-specific configuration like
     * baud rate stays in the concrete class. This follows Interface Segregation—
     * I2C implementations don't need meaningless set_baud_rate() stubs."
     */
    void set_baud_rate(int rate) { baud_rate_ = rate; }
    
    /**
     * @brief Get current baud rate
     */
    int get_baud_rate() const { return baud_rate_; }

private:
    mutable std::mutex mutex_;
    std::queue<std::uint8_t> input_buffer_;   // Commands from external -> device
    std::queue<std::uint8_t> output_buffer_;  // Responses from device -> external

    static constexpr std::size_t MAX_BUFFER_SIZE = 4096;
    int baud_rate_ = 115200;  // Default baud rate (typical for modern UART)
};

} // namespace telemetryhub::device
