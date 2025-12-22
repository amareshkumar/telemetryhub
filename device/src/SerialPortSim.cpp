#include "telemetryhub/device/SerialPortSim.h"
#include <algorithm>
#include <sstream>

namespace telemetryhub::device {

SerialPortSim::SerialPortSim() = default;

bool SerialPortSim::write(const std::vector<std::uint8_t>& data)
{
    if (data.empty()) {
        return true;
    }

    std::lock_guard<std::mutex> lock(mutex_);

    // Check buffer overflow
    if (output_buffer_.size() + data.size() > MAX_BUFFER_SIZE) {
        return false; // Buffer full
    }

    // Write data to output buffer
    for (auto byte : data) {
        output_buffer_.push(byte);
    }

    return true;
}

bool SerialPortSim::read(std::vector<std::uint8_t>& out, std::size_t max_len)
{
    std::lock_guard<std::mutex> lock(mutex_);

    if (input_buffer_.empty()) {
        return false; // No data available
    }

    out.clear();
    std::size_t bytes_to_read = std::min(max_len, input_buffer_.size());

    for (std::size_t i = 0; i < bytes_to_read; ++i) {
        out.push_back(input_buffer_.front());
        input_buffer_.pop();
    }

    return true;
}

void SerialPortSim::inject_command(const std::string& command)
{
    std::lock_guard<std::mutex> lock(mutex_);

    // Check buffer overflow
    if (input_buffer_.size() + command.size() > MAX_BUFFER_SIZE) {
        return; // Buffer full, drop command
    }

    // Add command to input buffer (including newline if not present)
    for (char c : command) {
        input_buffer_.push(static_cast<std::uint8_t>(c));
    }

    // Ensure command ends with newline
    if (!command.empty() && command.back() != '\n') {
        input_buffer_.push(static_cast<std::uint8_t>('\n'));
    }
}

std::optional<std::string> SerialPortSim::get_response()
{
    std::lock_guard<std::mutex> lock(mutex_);

    if (output_buffer_.empty()) {
        return std::nullopt;
    }

    std::ostringstream oss;
    
    // Read until newline or buffer empty
    while (!output_buffer_.empty()) {
        std::uint8_t byte = output_buffer_.front();
        output_buffer_.pop();

        if (byte == '\n') {
            break;
        }

        oss << static_cast<char>(byte);
    }

    std::string response = oss.str();
    return response.empty() ? std::nullopt : std::optional<std::string>(response);
}

std::size_t SerialPortSim::available() const
{
    std::lock_guard<std::mutex> lock(mutex_);
    return input_buffer_.size();
}

void SerialPortSim::clear()
{
    std::lock_guard<std::mutex> lock(mutex_);
    
    // Clear both buffers
    std::queue<std::uint8_t> empty_input;
    std::queue<std::uint8_t> empty_output;
    std::swap(input_buffer_, empty_input);
    std::swap(output_buffer_, empty_output);
}

} // namespace telemetryhub::device
