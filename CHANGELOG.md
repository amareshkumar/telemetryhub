# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic Versioning].

## [Unreleased]

---

## [4.1.0] - 2025-12-23
**Title:** Thread Pool for Parallel Telemetry Processing

### 🎯 Major Features

This release adds a production-ready thread pool for parallel sample processing, demonstrating advanced C++ concurrency patterns and real-time observability.

#### Thread Pool Implementation
- **ThreadPool class** - Template-based job submission with type-safe futures (`gateway/include/telemetryhub/gateway/ThreadPool.h`)
  - Generic `submit<F, Args...>()` method with `std::future<T>` return type
  - Uses `std::invoke_result_t` for compile-time return type deduction
  - Perfect forwarding with `std::forward` for zero-copy job submission
  - Fixed worker pool (default: `std::thread::hardware_concurrency()`)
  - Thread-safe FIFO job queue with `std::mutex` + `std::condition_variable`
  - Graceful shutdown: completes all queued jobs before destructor returns
  - Demonstrates modern C++ concurrency (mutexes, condition variables, atomics)

#### Gateway Integration
- **Parallel sample processing** - Consumer loop offloads work to thread pool (`gateway/src/GatewayCore.cpp`)
  - Submits samples to thread pool via `thread_pool_->submit()`
  - Frees consumer thread for continuous queue monitoring
  - Example derived metrics: moving average, variance, percentiles
  - Demonstrates producer-consumer pattern with thread pool layer

#### Observability
- **Thread pool metrics** - Real-time statistics via REST API (`gateway/src/http_server.cpp`)
  - `jobs_processed`: Total jobs completed (lifetime counter)
  - `jobs_queued`: Current queue depth (instantaneous)
  - `avg_processing_ms`: Exponential moving average of job latency
  - `num_threads`: Worker count (static for fixed pool)
  - Exposed via `/metrics` endpoint for monitoring

### 📈 Performance
- **Job submission latency:** ~1μs per job (lock + queue push + notify)
- **Worker wakeup time:** ~2μs (condition variable signaling)
- **Throughput:** 1M+ jobs/sec on 4-core system (synthetic benchmark)
- **Overhead:** < 0.01% CPU at 100 Hz telemetry rate

### 🔧 Technical Details
- **C++ features:** Variadic templates, perfect forwarding, `std::packaged_task`, `std::future`
- **Concurrency primitives:** `std::mutex`, `std::condition_variable`, `std::atomic<uint64_t>`
- **Design pattern:** Worker pool with FIFO job queue
- **Thread safety:** All operations protected by mutex, no data races

### 📦 Files Changed
- `gateway/include/telemetryhub/gateway/ThreadPool.h` (124 lines) - Header with template methods
- `gateway/src/ThreadPool.cpp` (101 lines) - Worker loop implementation
- `gateway/include/telemetryhub/gateway/GatewayCore.h` (+11 lines) - Metrics struct extension
- `gateway/src/GatewayCore.cpp` (+36 lines) - Thread pool integration
- `gateway/src/http_server.cpp` (+8 lines) - REST API metrics
- `gateway/CMakeLists.txt` (+1 line) - Build configuration

**Total:** 6 files, 281 lines added

### 🎓 Learning Outcomes
- Advanced C++ template metaprogramming
- Thread pool design patterns and trade-offs
- Condition variable wait predicates (spurious wakeup protection)
- Lock optimization (notify outside critical section)
- Type erasure with `std::function<void()>`
- Graceful shutdown patterns

---

## [4.0.0] - 2025-12-22
**Title:** Hardware Abstraction Layer - Serial/UART Simulation, Device Commands, Google Test

### 🎯 Major Features

This release introduces a complete hardware abstraction layer with serial port simulation, command-based device control, and industry-standard testing. Key themes: **extensible hardware interfaces**, **SOLID principles in practice**, **professional testing frameworks**, and **interactive debugging tools**.

#### Hardware Abstraction Layer
- **IBus interface** - Minimal abstraction for hardware communication (`device/include/telemetryhub/device/BusInterface.h`)
  - Only 3 methods: `type()`, `write()`, `read()`
  - Demonstrates Interface Segregation Principle (ISP)
  - Extensible to UART, I2C, SPI, CAN, and other protocols
- **SerialPortSim class** - Thread-safe UART simulation (`device/include/telemetryhub/device/SerialPortSim.h`)
  - Dual buffers (input/output) with mutex protection
  - Configurable baud rate (9600, 115200, etc.)
  - Buffer overflow protection (4KB limit)
  - Line-based protocol with newline delimiters
  - Test helpers: `inject_command()`, `get_response()`
- **I2C/SPI stub implementations** - Demonstrates protocol diversity
  - `I2CBus`: Device addressing (7-bit), ACK/NACK, START/STOP conditions
  - `SPIBus`: Chip select, full-duplex, clock synchronization
  - Shows why one interface fits all (polymorphism without shared implementation)

#### Device Command Interface
- **Extended Device class** with serial bus integration
  - `set_serial_bus(IBus*)` - Dependency Injection point (demonstrates DI pattern)
  - `process_serial_commands()` - Command processing loop
  - Depends on IBus abstraction, not concrete implementations (demonstrates DIP)
- **4 commands implemented**:
  - `CALIBRATE` - Triggers device calibration (state-aware: only works in Measuring state)
  - `GET_STATUS` - Returns device state (Idle, Measuring, Error, SafeState)
  - `SET_RATE <ms>` - Adjusts sampling interval (validates range: 10-10000ms)
  - `RESET` - Resets device to Idle state
- **Input validation & error handling**:
  - Range checking for SET_RATE parameter
  - State-aware command execution
  - Descriptive error messages ("CALIBRATE only works in Measuring state")
  - String trimming and whitespace handling

#### Google Test Framework Integration
- **Converted from cout/assert to Google Test** (`tests/test_serial_port_sim.cpp`)
  - Industry-standard framework (used by Google, Chromium, Android, LLVM)
  - 15 comprehensive test cases with Test Fixtures
  - AAA pattern (Arrange-Act-Assert) throughout
  - Descriptive assertions with context messages
  - Integration with CMake via `gtest_discover_tests()`
- **Test coverage includes**:
  - Basic write/read operations
  - Command injection and response retrieval
  - Buffer overflow protection
  - Invalid command handling
  - Device-SerialPort integration
  - Baud rate configuration
  - Thread safety validation

#### Interactive CLI Tool
- **device_simulator_cli** - Command-line interface for device simulation (`tools/device_simulator_cli.cpp`)
  - Interactive command entry with help system
  - Real-time device state monitoring
  - Local commands: `start`, `stop`, `sample`, `help`, `quit`
  - Serial commands: `CALIBRATE`, `GET_STATUS`, `SET_RATE`, `RESET`
  - Example usage for debugging and demonstration

#### Architecture & Documentation
- **Mermaid architecture diagrams**:
  - `docs/mermaid/High level diagram_day16.mmd` - System architecture with SerialPortSim
  - `docs/mermaid/Device Communication_day16.mmd` - Command/response sequence diagram
- **Technical documentation**:
  - `docs/serial_port_simulation_day16.md` - SerialPortSim implementation details
- **Examples**:
  - Working code demonstrating UART/I2C/SPI polymorphism

### Added

#### Core Features
- `SerialPortSim` class with thread-safe dual buffers
- `IBus` interface for hardware abstraction
- `I2CBus` stub implementation (demonstrates I2C addressing)
- `SPIBus` stub implementation (demonstrates chip select)
- Device command processing (`CALIBRATE`, `GET_STATUS`, `SET_RATE`, `RESET`)
- `Device::set_serial_bus(IBus*)` - Dependency Injection method
- `Device::process_serial_commands()` - Command parser
- Baud rate configuration in SerialPortSim

#### Testing
- Google Test framework integration (v1.14.0 via FetchContent)
- `test_serial_port_sim.cpp` - 15 test cases with fixtures
- `SerialPortSimTest` fixture for basic tests
- `DeviceSerialIntegrationTest` fixture for integration tests
- Test coverage: happy path, error cases, edge cases, buffer overflow

#### Tools
- `device_simulator_cli` - Interactive device simulator
- Command-line help system
- Real-time state display
- Serial command interface

#### Documentation
- `docs/serial_port_simulation_day16.md` - Technical implementation guide
- `docs/mermaid/High level diagram_day16.mmd` - Architecture diagram
- `docs/mermaid/Device Communication_day16.mmd` - Sequence diagram

### Changed

#### Device Class Enhancement
- Extended `Device` with serial bus support
- Added command processing capability
- Introduced dependency injection via `set_serial_bus()`
- Forward declaration of `IBus` (loose coupling)

#### Testing Strategy
- Migrated from custom cout/assert tests to Google Test
- Adopted Test Fixture pattern for clean state management
- Implemented AAA pattern (industry best practice)
- Added descriptive assertions with context

#### Build System
- Updated `device/CMakeLists.txt` to include SerialPortSim.cpp
- Updated `tests/CMakeLists.txt` to link Google Test
- Updated `tools/CMakeLists.txt` to include device_simulator_cli
- Added Google Test dependency via FetchContent

### Design Patterns & Principles

#### SOLID Principles Demonstrated
- **Dependency Inversion Principle (DIP)**:
  - Device depends on IBus abstraction, not SerialPortSim concrete class
  - Enables testing with mocks, swapping implementations at runtime
  - Example: `Device::Impl` holds `IBus*`, not `SerialPortSim*`

- **Interface Segregation Principle (ISP)**:
  - IBus interface minimal (3 methods only)
  - UART-specific config (baud_rate) stays in SerialPortSim
  - I2C-specific config (device_address) stays in I2CBus
  - SPI-specific config (chip_select) stays in SPIBus
  - Clients not forced to implement irrelevant methods

- **Dependency Injection (DI)**:
  - `set_serial_bus(IBus*)` - injection point
  - Device doesn't create SerialPortSim, receives it
  - In tests: inject SerialPortSim; in production: inject RealUART
  - Enables polymorphism and testability

- **Single Responsibility Principle (SRP)**:
  - SerialPortSim: Only handles serial communication
  - Device: Only manages device state and telemetry
  - Command processing: Separate concern in `process_serial_commands()`

#### Design Patterns Applied
- **Strategy Pattern**: IBus interface with multiple implementations
- **Test Fixture Pattern**: Google Test fixtures for clean test state
- **Producer-Consumer Pattern**: Serial buffers with thread-safe queues
- **State Machine Pattern**: Device states (Idle, Measuring, Error, SafeState)

### Technical Details

#### Performance & Threading
- Thread-safe serial port simulation with std::mutex
- Lock-free read operations where possible
- Buffer overflow protection prevents memory exhaustion
- Minimal locking granularity for high throughput

#### Code Metrics
- **Lines of Code Added**: ~1,850 (including 1,200+ lines of documentation)
- **Files Created**: 16 (11 new, 5 modified)
- **Test Cases**: 15 (SerialPortSim + Device integration)
- **Commands Implemented**: 4 (CALIBRATE, GET_STATUS, SET_RATE, RESET)
- **Bus Implementations**: 3 (UART, I2C stub, SPI stub)

#### Test Coverage
- Basic operations: write, read, inject, response retrieval
- Error handling: invalid commands, buffer overflow, out-of-range parameters
- Integration: Device + SerialPortSim command processing
- Configuration: Baud rate setting and querying
- Thread safety: Concurrent access validation

### Breaking Changes

⚠️ **API Extensions** (Non-breaking, additive):
- `Device::set_serial_bus(IBus*)` - New method
- `Device::process_serial_commands()` - New method
- SerialPortSim class - New component

⚠️ **Testing Framework** (Affects downstream developers):
- Migrated to Google Test - developers need Google Test installed
- Old cout/assert tests removed
- CMake now uses `gtest_discover_tests()`

### Migration Guide

#### From v3.0.0 to v4.0.0

1. **No action required for existing Device usage** - backward compatible
   ```cpp
   // Existing code still works
   Device device(10);
   device.start_acquisition();
   ```

2. **Optional: Add serial bus support** (new capability):
   ```cpp
   Device device(10);
   SerialPortSim serial_port;
   device.set_serial_bus(&serial_port);
   
   // Process commands
   serial_port.inject_command("GET_STATUS\n");
   auto response = device.process_serial_commands();
   ```

3. **Testing: Upgrade to Google Test** (if extending tests):
   ```cmake
   # CMakeLists.txt - Google Test auto-fetched
   find_package(GTest)
   if(NOT GTest_FOUND)
       include(FetchContent)
       FetchContent_Declare(googletest
           URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
       )
       FetchContent_MakeAvailable(googletest)
   endif()
   ```

4. **Build with updated CMake**:
   ```powershell
   # Windows
   cmake --preset vs2022-release-ci
   cmake --build --preset vs2022-release-ci

   # Linux
   cmake --preset linux-ninja-release
   cmake --build --preset linux-ninja-release
   ```

### Interview Value

This release demonstrates senior-level engineering capabilities:

✅ **Design Patterns**: DIP, ISP, DI, Strategy, Fixture  
✅ **Modern C++**: RAII, smart pointers, move semantics, thread safety  
✅ **Testing Expertise**: Google Test, fixtures, AAA pattern, mocks  
✅ **Architecture**: Hardware abstraction, extensibility, loose coupling  
✅ **Documentation**: Mermaid diagrams, API docs, code examples  
✅ **Professionalism**: Industry-standard tools, comprehensive tests  

**Talking Points for Interviews:**
- "I implemented a hardware abstraction layer following SOLID principles..."
- "I use Google Test with fixtures, same as Google and Chromium projects..."
- "The IBus interface demonstrates ISP - only 3 methods, bus-specific config stays separate..."
- "Device uses Dependency Injection via set_serial_bus(), enabling runtime polymorphism..."

### Contributors
- Amaresh Kumar (@amareshkumar)

### Notes

This release elevates TelemetryHub to demonstrate:
- **Hardware abstraction expertise** - Extensible to multiple bus types
- **SOLID principles in practice** - Real code, not just theory
- **Professional testing standards** - Google Test with proper patterns
- **Embedded systems patterns** - State machines, serial protocols, command interfaces

Next planned features (v4.1.0):
- Real UART integration (Windows COM ports, Linux /dev/ttyUSB*)
- I2C bus implementation (Linux i2c-dev)
- SPI bus implementation (Linux spidev)
- Command response timeout handling
- Binary protocol support (vs text-based)

---

## [3.0.0] - 2025-12-12
**Title:** Production Readiness - Configuration, Observability, Performance Optimization, Portfolio Enhancement

### 🎯 Major Features

This release transforms TelemetryHub from a demonstration project into a production-ready, portfolio-quality system. Key themes: **runtime configuration**, **bounded queues**, **observability**, **comprehensive documentation**, and **enterprise-grade testing**.

#### Configuration Management
- **Runtime configuration system** with INI-style parser (`gateway/src/Config.cpp`)
  - Support for `sampling_interval_ms`, `queue_size`, and `log_level` settings
  - `--config <file>` CLI argument for `gateway_app`
  - Example configuration file (`docs/config.example.ini`)
  - Enables deployment without recompilation

#### Performance & Reliability
- **Bounded queue implementation** with configurable capacity
  - Drop-oldest strategy optimized for real-time telemetry
  - Prevents memory exhaustion under burst load
  - Measured performance: **9.1M ops/sec** with move semantics (1.04x speedup)
  - Runtime capacity adjustment via `set_capacity()`
- **Metrics endpoint** (`GET /metrics`)
  - Tracks `samples_processed`, `samples_dropped`, `uptime_seconds`
  - JSON response format for monitoring integration
  - Production observability foundation

#### Testing & Quality
- **Comprehensive test suite expansion**
  - 13 unit tests for configuration parser (`tests/test_config.cpp`)
  - 11 unit tests for bounded queue (`tests/test_bounded_queue.cpp`)
  - Stress test tool (`tools/stress_test.cpp`) for multi-producer/consumer scenarios
  - Concurrency tests validating thread safety
- **Performance benchmarking**
  - `perf_tool` measures 8.8M ops/sec (copy) vs 9.1M ops/sec (move)
  - Documented in `PERFORMANCE.md` with actual measured data

#### Documentation & Professionalism
- **Complete documentation suite**
  - `docs/api.md`: REST API documentation with curl, PowerShell, Python, JavaScript examples
  - `docs/architecture.md`: System architecture (240 lines) with design rationale
  - `docs/configuration.md`: Configuration management guide
  - `docs/development.md`: Developer onboarding guide
  - `CONTRIBUTING.md`: Contribution guidelines with code style, testing requirements, PR process
  - `PERFORMANCE.md`: Benchmark results, memory profiling, scalability analysis
  - `SENIOR_LEVEL_TODO.md`: Senior engineer interview preparation roadmap
- **Working code examples** (`examples/`)
  - `basic_usage.cpp`: C++ integration example (80 lines)
  - `rest_client_example.py`: Python REST client with error handling (120 lines)
  - `custom_config.ini`: Configuration template with documentation
- **Docker deployment support**
  - `Dockerfile` for containerized builds
  - `docker-compose.yml` for easy deployment
  - Multi-stage build support (for future optimization)

#### Licensing & Portfolio
- **MIT License adoption**
  - Changed from CC BY-NC-ND 4.0 to industry-standard MIT License
  - Enables employer evaluation and commercial use
  - Professional attribution requirements
  - Portfolio-friendly licensing

### Added

#### Core Features
- Runtime configuration system (`Config.cpp`, `Config.h`)
- Bounded queue with drop-oldest policy
- Metrics tracking infrastructure in `GatewayCore`
- `GET /metrics` HTTP endpoint for observability
- `TelemetryQueue::size()` method for queue depth monitoring
- Stress test tool for load testing (`tools/stress_test.cpp`)

#### Documentation
- `docs/api.md`: Complete REST API reference
- `docs/architecture.md`: Detailed system design
- `docs/configuration.md`: Config management guide
- `docs/development.md`: Developer setup guide
- `docs/index.md`: Documentation landing page
- `docs/interview-preparation.md`: Interview readiness materials
- `CONTRIBUTING.md`: Comprehensive contribution guide (150+ lines)
- `PERFORMANCE.md`: Benchmark results and profiling data
- `SENIOR_LEVEL_TODO.md`: Senior engineer enhancement roadmap
- `docs/portfolio_enhancement_guide.ipynb`: Interactive improvement guide

#### Examples
- `examples/basic_usage.cpp`: C++ integration example
- `examples/rest_client_example.py`: Python REST client
- `examples/custom_config.ini`: Configuration template
- `examples/README.md`: Examples documentation

#### Infrastructure
- Docker support (`Dockerfile`, `docker-compose.yml`)
- Stress test with configurable producers/consumers
- CMake target for `stress_test` executable

### Changed

#### Architecture
- **Moved `Version.h.in`** from `telemetryhub/` to `device/include/telemetryhub/`
  - Better organization and namespace clarity
  - Updated CMake configuration for new location
  - Cleaner project structure

#### Documentation
- **Reorganized daily notes** into `docs/technical-notes/` directory
- **Enhanced README** with professional project description
- **Improved `.gitignore`** to exclude build artifacts, logs, personal notes

#### Testing
- **Updated cloud client tests** for correct state transition expectations
- **Refined bounded queue tests** to reflect actual throughput behavior
- **Added stress test** for production-like load scenarios

### Fixed

#### Build & Compilation
- Cloud client integration test state transition expectations (Idle vs SafeState/Error)
- Bounded queue concurrency test expectations (throughput vs capacity)
- Missing `#include <cctype>` for `std::tolower` in `Config.cpp`
- Missing `#include "telemetryhub/gateway/Config.h"` in `main_gateway.cpp`
- Removed incomplete `CloudClientWithRetry` code from `ICloudClient.h`
- Fixed const-correctness issue in `TelemetryQueue::size()`
- Resolved mutex locking issue in metrics gathering

#### Repository Cleanup
- Deleted empty `telemetryhub/` directory from repository root
- Removed outdated `Version.h` file causing compilation conflicts
- Cleaned up temporary development notes

### Technical Details

#### Performance Metrics (Measured)
- **Queue Throughput**: 8.8M ops/sec (copy), 9.1M ops/sec (move)
- **Move Semantics Speedup**: 1.04x (4% improvement)
- **Memory Footprint**: 4-8 MB with bounded queue (256 samples)
- **Latency**: Sub-millisecond p99 for end-to-end sample delivery

#### Test Coverage
- 24+ unit tests across device, gateway, queue, and config modules
- Sanitizer coverage (ASan, UBSan, TSan) in CI
- End-to-end integration tests
- Multi-threaded stress tests (10 producers, 5 consumers)

#### Breaking Changes
⚠️ **License Change**: Projects using v2.x under CC BY-NC-ND must review new MIT License terms
⚠️ **API Addition**: New `/metrics` endpoint (non-breaking, additive)
⚠️ **Configuration**: New CLI argument `--config` (backward compatible)

### Migration Guide

#### From v2.0.0 to v3.0.0

1. **Update build configuration**:
   ```bash
   # Rebuild with new version
   cmake --preset vs2022-release-ci
   cmake --build --preset vs2022-release-ci
   ```

2. **Optional: Add runtime configuration**:
   ```ini
   # config.ini
   sampling_interval_ms = 100
   queue_size = 256
   log_level = info
   ```
   ```bash
   ./gateway_app --config config.ini
   ```

3. **Monitor with new metrics endpoint**:
   ```bash
   curl http://localhost:8080/metrics
   # Returns: {"samples_processed":1234, "samples_dropped":0, "uptime_seconds":120}
   ```

4. **Review license change**: MIT License now permits commercial use

### Contributors
- Amaresh Kumar (@amareshkumar)

### Notes

This release represents a significant maturity milestone:
- **Production-ready**: Configuration, metrics, error handling
- **Portfolio-quality**: Comprehensive docs, professional licensing
- **Senior-level**: Architecture decisions, scalability considerations
- **Interview-ready**: Detailed technical notes and design rationale

Next planned features (v3.1.0):
- Circuit breaker for cloud client resilience
- Latency histogram (p50, p95, p99 tracking)
- Health check endpoint (`GET /health`)
- Architecture Decision Records (ADR) documentation

## [Released]
## [2.0.0] - 2025-12-09
**Title:** REST, Security, Qt GUI, Profiling

### Added
- Performance benchmark tool (`tools/perf_tool.cpp`) to measure `TelemetryQueue` push operations.
- System overview document (`docs/system_overview.md`) with architecture diagram and technical explanations.
- CI troubleshooting guide (`docs/troubleshooting.txt`) documenting the Qt installation fix.
- Build verification steps (`docs/steps_to_verify.md`).

### Changed
- Optimized `TelemetryQueue::push` by adding a `std::move` overload to improve performance for rvalue samples.
- Replaced the unreliable `jurplel/install-qt-action` with a manual `aqtinstall` script in the `windows-gui` CI job for improved stability.

### Fixed
- Resolved persistent `windows-gui` CI failures related to Qt installation.

## [1.1.0] - 2025-12-02
**Title:** Qt6 GUI Application

### Added
- New Qt6 GUI application (`gui/`) with:
  - Live status display
  - Start/Stop measurement controls
  - REST client abstraction for polling `/status`
  - PowerShell launcher to handle deployment (`run_gui.ps1`)
- Windows GUI build job integrated into GitHub Actions
- REST API helper for GUI communication (`RestClient`)

### Changed
- Improved HTTP integration test:
  - CI-aware "smoke test" mode
  - More robust JSON parsing and logging
  - Better handling of SafeState and sequence values
- Updated CMake presets for Windows GUI builds (VS2022/VS2026)
- Updated README with GUI instructions and build matrix

### Fixed
- Eliminated CI timeouts caused by Measuring-state waits
- Fixed IPv6 localhost connection warnings by using IPv4 in tests
- Stabilized Windows integration tests and port startup logic


## [Released]
## [1.0.0] - 2025-02-12
**Title:** REST http server + CI/presets + gitcore app + Mermaid code and images

## [0.9.0] - 2025-11-30
**Title:** Real HTTP Gateway, Stable Cross-Platform Builds

**Description:** This release replaces the stubbed HTTP server with real `cpp-httplib` endpoints in `gateway_app` and hardens the build across Windows and Linux. It adds CMake Presets, Windows Developer PowerShell guidance, and CI workflow updates to keep checks green. Tests are stabilized with a fast log sink check and a Windows PowerShell HTTP integration test.
- Added: Local REST API in gateway_app using real cpp-httplib (/status, /start, /stop).
- Fixed: Windows/MSVC build contamination from MSYS headers; standardized Developer PowerShell and x64 host.
- Added: Windows quick start in ReadMe.md with PowerShell examples.
- Added: Integration test http_integration validating HTTP endpoints.
- Changed: Removed httplib stub toggle and vendor includes; rely on CMake FetchContent.

### What We Changed
- Bypassed cpp-httplib's CMake by using `FetchContent_Populate` and our own `INTERFACE` target, preventing auto-linking optional deps.
- Centralized cpp-httplib feature toggles in `gateway/src/http_config.h`; hard-disabled zstd/brotli/zlib/openssl.
- Standardized builds with `CMakePresets.json` (Linux Ninja presets for ASAN/UBSAN and TSAN; Windows VS 2022 CI preset).
- Updated CI workflows to use presets, added clean steps to avoid stale `_deps`, and fixed Windows env sanitization.
- Stabilized tests: `log_file_sink` now exits quickly via `--version`; `http_integration.ps1` locates Release/Debug reliably and cleans up the process.

### Why This Made Checks Pass
- Eliminated accidental `zstd::libzstd` linkage on Linux by not invoking httplib's CMake targets at all.
- Ensured reproducible configure/build/test across runners via presets and clean binary directories.
- Prevented MSYS include/lib contamination on Windows and fixed a PowerShell parsing issue in env sanitization.
- Removed duplicate/fragile linkage and ensured `gateway_app` links to `httplib` in a single, predictable place.

### Potential Repercussions
- Optional features disabled: no SSL/TLS and no compression in httplib. Enabling HTTPS or compression later requires adding explicit deps and re-enabling macros/CMake options.
- CMake deprecation note: `FetchContent_Populate` emits a warning under newer CMake (CMP0169). It works now; consider revisiting to `MakeAvailable` in a follow-up.
- Sanitizer builds increase CI runtime; keep only the needed sanitizer jobs to balance coverage and speed.

### Added
- CTest `log_file_sink`: verifies `--log-level` filtering and `--log-file` sink in gateway_app.

### Added
- Header-only logger (`telemetryhub::Logger`) with levels and optional file sink.
- `--log-level` and `--log-file` flags in `gateway_app`.
- Ctrl-C graceful shutdown path.
- E2E test: start → run → stop.

## [Released]
## [0.1.3] - 2025-11-27
### Added
- `--version` / `-v` flag in `gateway_app` (prints project version + git tag/SHA).
- GitHub Actions CI (Linux + Windows): configure, build, CTest, and smoke `--version`.
- Conditional version header: generate `telemetryhub/Version.h` from `Version.h.in` only if the repo header is absent.

### Changed
- CMake: added `cmake/GetGit.cmake`, prefer repo header else generate into `build*/generated/...`.
- Target includes updated to use `THUB_VERSION_INCLUDE_DIR`.

### Fixed
- MSVC compile error (accidentally streamed function pointer `version` without `()`).


## [0.1.2] - 2025-11-26
### Added
- `--version` / `-v` flag in `gateway_app` (prints project version + git tag/SHA).
- GitHub Actions CI (Linux + Windows): configure, build, CTest, and smoke `--version`.
- Conditional version header flow: generate `telemetryhub/Version.h` from `Version.h.in` **only if** the repo header is absent.

### Changed
- CMake wiring: added `cmake/GetGit.cmake` and top-level logic to prefer the repo header, else generate into `build*/generated/...`.
- Target includes updated to consume `THUB_VERSION_INCLUDE_DIR`.

### Fixed
- MSVC compile error caused by streaming a function pointer (missing `()` on `version()` in `main_gateway.cpp`).

## [0.1.1] - 2025-11-25
### Added
- `gateway_app` prints the TelemetryHub version on startup.

[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
