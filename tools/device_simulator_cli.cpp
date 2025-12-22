/**
 * @file device_simulator_cli.cpp
 * @brief Interactive CLI tool to demonstrate serial command interface with Device
 * 
 * This tool shows how to:
 * - Create a simulated serial port (SerialPortSim)
 * - Connect it to a Device instance
 * - Send commands and receive responses
 * - Simulate real UART communication patterns
 * 
 * Usage:
 *   device_simulator_cli
 *   Commands: CALIBRATE, GET_STATUS, SET_RATE=<ms>, RESET, help, quit
 */

#include "telemetryhub/device/Device.h"
#include "telemetryhub/device/SerialPortSim.h"
#include <iostream>
#include <string>
#include <thread>
#include <chrono>

using namespace telemetryhub::device;

void print_help()
{
    std::cout << "\n=== Device Simulator CLI ===\n"
              << "Available commands:\n"
              << "  CALIBRATE       - Recalibrate device (resets sequence, only when measuring)\n"
              << "  GET_STATUS      - Get current device state and sequence number\n"
              << "  SET_RATE=<ms>   - Set sampling rate (10-10000 ms)\n"
              << "  RESET           - Reset device to Idle state\n"
              << "  start           - Start device measurement\n"
              << "  stop            - Stop device measurement\n"
              << "  sample          - Read one telemetry sample\n"
              << "  help            - Show this help message\n"
              << "  quit            - Exit program\n"
              << "\n";
}

std::string state_to_string(DeviceState state)
{
    switch (state) {
        case DeviceState::Idle: return "Idle";
        case DeviceState::Measuring: return "Measuring";
        case DeviceState::Error: return "Error";
        case DeviceState::SafeState: return "SafeState";
        default: return "Unknown";
    }
}

int main()
{
    std::cout << "TelemetryHub Device Simulator with Serial/UART Interface\n";
    std::cout << "Type 'help' for available commands\n\n";

    // Create device with fault after 10 samples
    Device device(10);
    
    // Create simulated serial port
    SerialPortSim serial_port;
    
    // Connect serial port to device
    device.set_serial_bus(&serial_port);

    print_help();

    std::string input;
    while (true) {
        std::cout << "[" << state_to_string(device.state()) << "] > ";
        std::getline(std::cin, input);

        if (input.empty()) {
            continue;
        }

        // Handle local commands
        if (input == "quit" || input == "exit") {
            std::cout << "Exiting...\n";
            break;
        }

        if (input == "help") {
            print_help();
            continue;
        }

        if (input == "start") {
            device.start();
            std::cout << "Device started. State: " << state_to_string(device.state()) << "\n";
            continue;
        }

        if (input == "stop") {
            device.stop();
            std::cout << "Device stopped. State: " << state_to_string(device.state()) << "\n";
            continue;
        }

        if (input == "sample") {
            auto sample = device.read_sample();
            if (sample) {
                std::cout << "Sample: value=" << sample->value 
                         << " " << sample->unit 
                         << ", seq=" << sample->sequence_id << "\n";
            } else {
                std::cout << "No sample available (device state: " 
                         << state_to_string(device.state()) << ")\n";
            }
            continue;
        }

        // Handle serial commands
        // Inject command into serial port
        serial_port.inject_command(input);

        // Give device time to process (simulate async behavior)
        std::this_thread::sleep_for(std::chrono::milliseconds(10));

        // Process commands through device
        auto response = device.process_serial_commands();

        // Get response from serial port
        auto serial_response = serial_port.get_response();

        if (serial_response) {
            std::cout << "Response: " << *serial_response << "\n";
        } else if (response) {
            std::cout << "Response: " << *response;
        } else {
            std::cout << "No response from device\n";
        }
    }

    return 0;
}
