/**
 * @file bus_comparison_example.cpp
 * @brief Demonstrates Interface Segregation with multiple IBus implementations
 * 
 * This example shows how Device works with ANY IBus implementation without
 * knowing the details. Each bus type has unique configuration needs, but
 * all share the same core interface.
 * 
 * Compile: (header-only stubs, no need to compile)
 * This is a demonstration file for interview discussions.
 */

#include "telemetryhub/device/Device.h"
#include "telemetryhub/device/SerialPortSim.h"
#include "telemetryhub/device/I2CBus.h"
#include "telemetryhub/device/SPIBus.h"
#include <iostream>
#include <memory>

using namespace telemetryhub::device;

/**
 * @brief Generic function that works with ANY IBus implementation
 * 
 * This demonstrates Liskov Substitution Principle—any IBus implementation
 * can be passed without changing this function.
 */
void send_device_command(Device& device, const std::string& command_text) {
    // Device doesn't know if it's using UART, I2C, or SPI
    // It only knows it has "some IBus"
    device.process_serial_commands();
}

int main() {
    std::cout << "=== IBus Interface Segregation Demo ===\n\n";
    
    // Example 1: UART (SerialPortSim)
    {
        std::cout << "1. UART Example:\n";
        SerialPortSim uart;
        
        // UART-specific configuration (NOT in IBus interface)
        uart.set_baud_rate(115200);
        std::cout << "   Configured baud rate: " << uart.get_baud_rate() << "\n";
        
        Device device;
        device.set_serial_bus(&uart);
        device.start();
        
        uart.inject_command("GET_STATUS");
        device.process_serial_commands();
        
        if (auto response = uart.get_response()) {
            std::cout << "   Response: " << *response << "\n";
        }
    }
    
    // Example 2: I2C (I2CBus stub)
    {
        std::cout << "\n2. I2C Example:\n";
        I2CBus i2c(0x50);  // I2C device at address 0x50
        
        // I2C-specific configuration (NOT in IBus interface)
        std::cout << "   Device address: 0x" << std::hex 
                  << static_cast<int>(i2c.get_device_address()) << std::dec << "\n";
        
        Device device;
        device.set_serial_bus(&i2c);  // Device doesn't care it's I2C!
        device.start();
        
        // In real implementation, would send I2C transactions
        std::cout << "   I2C uses addressing, not baud rate\n";
    }
    
    // Example 3: SPI (SPIBus stub)
    {
        std::cout << "\n3. SPI Example:\n";
        SPIBus spi(10);  // SPI with chip select on pin 10
        
        // SPI-specific configuration (NOT in IBus interface)
        std::cout << "   Chip select pin: " << spi.get_chip_select_pin() << "\n";
        
        Device device;
        device.set_serial_bus(&spi);  // Device doesn't care it's SPI!
        device.start();
        
        // In real implementation, would assert CS and clock data
        std::cout << "   SPI uses chip select, not baud rate or addressing\n";
    }
    
    std::cout << "\n=== Key Interview Points ===\n";
    std::cout << "1. All three buses implement IBus::write()/read()\n";
    std::cout << "2. Each has unique configuration (baud/address/CS)\n";
    std::cout << "3. Unique config stays in concrete classes (ISP)\n";
    std::cout << "4. Device works with any bus (DIP + Polymorphism)\n";
    std::cout << "5. No shared implementation = interface > inheritance\n";
    
    return 0;
}
