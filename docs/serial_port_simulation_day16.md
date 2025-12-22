# Serial/UART Simulation - Day 16

## Overview

This implementation adds a simulated serial port (UART) communication layer to the TelemetryHub project, demonstrating hardware abstraction and command-based device control.

## Components Added

### 1. SerialPortSim Class
**Location:** `device/include/telemetryhub/device/SerialPortSim.h`, `device/src/SerialPortSim.cpp`

A thread-safe simulated serial port implementing the `IBus` interface.

**Features:**
- Dual buffer architecture (input/output)
- Thread-safe operations using `std::mutex`
- Buffer overflow protection (4KB limit)
- Line-based protocol (newline-terminated commands)

**Key Methods:**
```cpp
bool write(const std::vector<std::uint8_t>& data);  // Device -> External
bool read(std::vector<std::uint8_t>& out, size_t max_len);  // External -> Device
void inject_command(const std::string& command);  // Simulate external sender
std::optional<std::string> get_response();  // Read device response
```

### 2. Device Command Interface
**Location:** `device/include/telemetryhub/device/Device.h`, `device/src/Device.cpp`

Extended the `Device` class with serial communication support.

**New Methods:**
```cpp
void set_serial_bus(IBus* bus);  // Connect serial port
std::optional<std::string> process_serial_commands();  // Process pending commands
```

**Supported Commands:**
| Command | Description | Response |
|---------|-------------|----------|
| `CALIBRATE` | Reset sequence counter | `OK: Calibrated` or error |
| `GET_STATUS` | Query device state | `STATUS: <state>, Seq=<n>` |
| `SET_RATE=<ms>` | Set sampling rate (10-10000 ms) | `OK: Rate set to <ms> ms` |
| `RESET` | Reset device to Idle state | `OK: Reset to Idle` |

**Error Responses:**
- `ERROR: Empty command`
- `ERROR: Device not measuring`
- `ERROR: Unknown command`
- `ERROR: Rate must be 10-10000 ms`

### 3. Device Simulator CLI Tool
**Location:** `tools/device_simulator_cli.cpp`

Interactive command-line tool demonstrating serial communication.

**Usage:**
```bash
cd build
./tools/device_simulator_cli

# Commands
start                  # Start device measurement
stop                   # Stop device measurement
sample                 # Read one telemetry sample
CALIBRATE             # Recalibrate device
GET_STATUS            # Get device state
SET_RATE=500          # Set rate to 500ms
RESET                 # Reset device
help                  # Show help
quit                  # Exit
```

### 4. Unit Tests
**Location:** `tests/test_serial_port_sim.cpp`

Comprehensive test suite covering:
- Basic read/write operations
- Command injection and processing
- Device state transitions via commands
- Error handling (invalid commands, buffer overflow)
- All supported commands (CALIBRATE, GET_STATUS, SET_RATE, RESET)

## Architecture

### Communication Flow

```
External Application
        ↓
   inject_command()
        ↓
[SerialPortSim Input Buffer]
        ↓
   Device::process_serial_commands()
        ↓
   read() → parse → execute
        ↓
   write() response
        ↓
[SerialPortSim Output Buffer]
        ↓
   get_response()
        ↓
External Application receives response
```

### Thread Safety

- **SerialPortSim**: All operations protected by `std::mutex`
- **Buffer Management**: Automatic overflow protection
- **Safe for producer-consumer patterns**

## Interview Talking Points

### 1. Hardware Abstraction
**Q:** "How would you test hardware-dependent code without actual hardware?"

**A:** "I implemented a hardware abstraction layer using the `IBus` interface. The `SerialPortSim` class simulates UART behavior with thread-safe buffers, allowing complete testing of device communication logic without physical hardware. This follows the Dependency Inversion Principle - high-level Device logic depends on the IBus abstraction, not concrete hardware."

### 2. Protocol Design
**Q:** "How did you design the command protocol?"

**A:** "I chose a simple text-based protocol with newline delimiters for readability and debuggability. Each command follows a predictable pattern: `COMMAND [ARGS]\\n` with responses in format `STATUS: message` or `OK: message` or `ERROR: message`. This makes the protocol easy to test, debug with standard tools, and extend with new commands."

### 3. Embedded Systems Experience
**Q:** "Do you have experience with embedded systems or hardware interfaces?"

**A:** "Yes, this implementation demonstrates several embedded concepts: buffer management with overflow protection, line-based protocol parsing, state machine integration, and serial communication patterns. The dual-buffer design (input/output) mimics real UART hardware behavior, and the thread-safe implementation handles concurrent access typical in embedded systems."

### 4. Testing Strategy
**Q:** "How do you ensure reliability?"

**A:** "I implemented multiple testing layers:
1. **Unit tests** - Test individual components (SerialPortSim operations, command parsing)
2. **Integration tests** - Test Device + SerialPortSim interaction
3. **Interactive tool** - Manual testing and demonstration (device_simulator_cli)
4. **Error cases** - Invalid commands, buffer overflow, state validation"

## Building and Running

### Build
```bash
cmake --preset=release
cmake --build build_vs --config Release
```

### Run Tests
```bash
cd build
ctest -R test_serial_port_sim -V
```

### Run Interactive Tool
```bash
cd build/tools/Release
./device_simulator_cli
```

## Example Session

```
[Idle] > start
Device started. State: Measuring

[Measuring] > GET_STATUS
Response: STATUS: Measuring, Seq=0

[Measuring] > sample
Sample: value=42.1234 arb.units, seq=0

[Measuring] > CALIBRATE
Response: OK: Calibrated

[Measuring] > SET_RATE=500
Response: OK: Rate set to 500 ms

[Measuring] > RESET
Response: OK: Reset to Idle

[Idle] > quit
```

## Design Decisions

### Why Text Protocol Instead of Binary?
- **Debuggability**: Easy to test with standard tools (telnet, netcat)
- **Human-readable**: Clear what's happening during development
- **Simplicity**: No byte-order or alignment concerns
- **Extensibility**: Easy to add new commands

### Why Dual Buffers?
- **Separation of Concerns**: Input (commands) separate from output (responses)
- **Mimics Real Hardware**: Real UART has separate TX/RX buffers
- **Thread Safety**: Independent locks possible if needed (currently shared mutex)

### Why IBus Interface?
- **Testability**: Easy to mock for unit tests
- **Flexibility**: Support I2C, SPI in future with same interface
- **SOLID Principles**: Dependency inversion, interface segregation

## Future Enhancements

1. **Async Command Processing**: Background thread for command handling
2. **Binary Protocol Support**: More efficient for high-throughput scenarios
3. **Command History**: Track and replay commands
4. **Real Hardware Integration**: Replace SerialPortSim with actual UART driver
5. **Command Validation**: Schema-based validation for complex commands

## Related Files

- Architecture diagrams: `docs/mermaid/High level diagram_day16.mmd`
- Communication flow: `docs/mermaid/Device Communication_day16.mmd`
- Day 16 task list: See attachment in project documentation

## Summary

This implementation demonstrates professional embedded systems development practices:
- ✅ Hardware abstraction layer (IBus interface)
- ✅ Thread-safe buffer management
- ✅ Command protocol design and parsing
- ✅ Comprehensive testing (unit + integration)
- ✅ Interactive demonstration tool
- ✅ Clear documentation and diagrams

Perfect for discussing in technical interviews about embedded systems, hardware interfaces, and production-ready code design.
