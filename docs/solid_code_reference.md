# Day 16 - SOLID Principles Code Examples

## Quick Reference: Where to Find Each Principle

### Dependency Inversion Principle (DIP)
**Files:**
- [device/include/telemetryhub/device/Device.h](../device/include/telemetryhub/device/Device.h) - Device depends on IBus*
- [device/include/telemetryhub/device/BusInterface.h](../device/include/telemetryhub/device/BusInterface.h) - IBus abstraction

**Interview point:**
"Device class depends on IBus abstraction, not concrete SerialPortSim. I can inject any IBus implementation via `set_serial_bus()` method."

---

### Interface Segregation Principle (ISP)
**Files:**
- [device/include/telemetryhub/device/BusInterface.h](../device/include/telemetryhub/device/BusInterface.h) - Minimal interface
- [device/include/telemetryhub/device/SerialPortSim.h](../device/include/telemetryhub/device/SerialPortSim.h) - UART-specific: `set_baud_rate()`
- [device/include/telemetryhub/device/I2CBus.h](../device/include/telemetryhub/device/I2CBus.h) - I2C-specific: `set_device_address()`
- [device/include/telemetryhub/device/SPIBus.h](../device/include/telemetryhub/device/SPIBus.h) - SPI-specific: `set_chip_select_pin()`

**Interview point:**
"IBus has only 3 methods: type(), write(), read(). Bus-specific config like baud_rate (UART), device_address (I2C), or chip_select (SPI) stays in concrete classes. This way I2C doesn't need meaningless baud rate stubs."

---

### Dependency Injection (DI)
**Files:**
- [device/include/telemetryhub/device/Device.h](../device/include/telemetryhub/device/Device.h) - `void set_serial_bus(IBus* bus)`
- [tests/test_serial_port_sim.cpp](../tests/test_serial_port_sim.cpp) - Test fixture SetUp() shows injection

**Interview point:**
"I inject dependencies via `set_serial_bus()` method. The Device doesn't create its own serial port—that would be tight coupling. In tests I inject SerialPortSim, in production I could inject RealUART."

---

### Complete Working Example
**File:** [examples/bus_comparison_example.cpp](../examples/bus_comparison_example.cpp)

Shows all three bus types with Device, demonstrating:
- DIP: Device works with any IBus
- ISP: Each bus has unique configuration
- Polymorphism: Same interface, different implementations

---

## Quick Interview Prep

**If asked about DIP:**
Point to Device.h → "Depends on IBus interface, not SerialPortSim"

**If asked about ISP:**
Point to BusInterface.h → "Only 3 universal methods"
Then show SerialPortSim.h → "UART-specific baud rate NOT in interface"

**If asked about DI:**
Point to set_serial_bus() → "Injection method" 
Then show test fixture → "Tests inject SerialPortSim"

**If asked for proof:**
Show bus_comparison_example.cpp → "Device works with UART, I2C, SPI without changes"
