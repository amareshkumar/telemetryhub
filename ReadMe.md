# TelemetryHub

**High-Performance IoT Gateway with Modern C++20 and Real-Time Qt6 Visualization**

[![C++ CI](https://github.com/amareshkumar/telemetryhub/workflows/C++%20CI/badge.svg)](https://github.com/amareshkumar/telemetryhub/actions)
[![Windows CI](https://github.com/amareshkumar/telemetryhub/workflows/Windows%20C++%20CI/badge.svg)](https://github.com/amareshkumar/telemetryhub/actions)
[![Release](https://img.shields.io/github/v/release/amareshkumar/telemetryhub)](https://github.com/amareshkumar/telemetryhub/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![C++20](https://img.shields.io/badge/C%2B%2B-20-blue.svg)](https://en.cppreference.com/w/cpp/20)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey.svg)](.)

> **Production-ready C++20 telemetry pipeline demonstrating:**  
> Modern C++ (RAII, move semantics), concurrent programming (9.1M ops/sec),  
> hardware abstraction (UART/I2C/SPI), and enterprise-grade engineering  
> (CI/CD, sanitizers, Google Test, comprehensive docs)

---

## 🔗 Related Project

**[Telemetry-Platform](https://github.com/amareshkumar/telemetry-platform)** - Microservices architecture companion project demonstrating distributed systems design (separate ingestion/processing services with Redis coordination). While TelemetryHub focuses on **implementation excellence** (C++20 features, Qt GUI, build optimization), Telemetry-Platform showcases **architectural patterns** (service separation, distributed coordination, scalability). See [PROJECT_STRATEGY.md](PROJECT_STRATEGY.md) for details.

## Why This Project?
TelemetryHub showcases real-world systems programming patterns used in:
- **IoT data collection** (sensor data aggregation with serial protocols)
- **Embedded systems** (hardware abstraction for UART/I2C/SPI buses)
- **Financial systems** (market data processing)
- **Observability platforms** (metrics collection)

**Key Differentiators:**
- 🚀 **Performance**: 9.1M ops/sec with move semantics (measured, not claimed)
- 🛡️ **Safety**: Thread sanitizers in CI catch race conditions
- 🔌 **Hardware Abstraction**: Extensible IBus interface for UART, I2C, SPI
- 🧪 **Testing Excellence**: Google Test framework with 50+ test cases
- 📊 **Professionalism**: Architecture docs, API specs, runnable examples
- 🎯 **SOLID Principles**: DIP, ISP, and DI demonstrated with real code

## 🚀 Quick Start

To get started with TelemetryHub:

```bash
# Clone and build (3 commands)
git clone https://github.com/amareshkumar/telemetryhub
cd telemetryhub
cmake --preset linux-ninja-release && cmake --build --preset linux-ninja-release
```

### Build Options

**Standard Build (CMake + MSBuild/Ninja):**
```powershell
# Windows with Visual Studio
cmake --preset vs2026-release
cmake --build build_vs26 --config Release -j8

# Linux with Ninja
cmake --preset linux-ninja-release
cmake --build --preset linux-ninja-release
```

**FASTBuild (Distributed Compilation - 10× faster):**
```powershell
# Configure with FASTBuild enabled
.\configure_fbuild.ps1 -EnableFastBuild

# Build with distribution and caching
fbuild -config build_vs26\fbuild.bff -dist -cache

# See docs/fastbuild_guide.md for setup instructions
```

---

## 🧪 Testing

### Run All Tests

**Windows:**
```powershell
# Build with tests
cmake --preset vs2026-release
cmake --build build_vs26 --config Release

# Run all tests
ctest --test-dir build_vs26 -C Release --output-on-failure

# Run specific test
ctest --test-dir build_vs26 -C Release -R test_device --output-on-failure
```

**Linux:**
```bash
# Build with tests
cmake --preset linux-ninja-release
cmake --build --preset linux-ninja-release

# Run all tests (50+ test cases)
ctest --test-dir build --output-on-failure

# Run specific test category
ctest --test-dir build -R test_queue --output-on-failure

# Verbose output
ctest --test-dir build --verbose
```

### Integration Test (HTTP)

**Windows:**
```powershell
# Start gateway in one terminal
.\build_vs26\gateway\Release\gateway_app.exe

# Run integration test in another terminal
ctest -C Release -R http_integration --output-on-failure
```

**Linux:**
```bash
# Start gateway in one terminal
./build/gateway/gateway_app &

# Run integration test
ctest --test-dir build -R http_integration --output-on-failure

# Stop gateway
pkill gateway_app
```

### Manual API Testing

**Linux/macOS:**
```bash
# Run the gateway
./build/gateway/gateway_app --config docs/config.example.ini

# In another terminal, test endpoints
curl http://localhost:8080/status
curl -X POST http://localhost:8080/start
curl -X POST http://localhost:8080/stop
curl http://localhost:8080/samples | jq  # Pretty-print JSON
```

**Windows:**
```powershell
# Run the gateway
.\build_vs26\gateway\Release\gateway_app.exe --config docs\config.example.ini

# Test endpoints
Invoke-WebRequest -UseBasicParsing http://localhost:8080/status
Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start
Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop
```

---

## About

It simulates a pipeline with:

- **Device** — explicit state machine (`Idle → Measuring → Error → SafeState`) emitting `TelemetrySample`.
- **Hardware Abstraction** — IBus interface with SerialPortSim (UART), I2CBus, SPIBus implementations.
- **Device Commands** — CALIBRATE, GET_STATUS, SET_RATE, RESET via serial interface.
- **TelemetryQueue** — thread-safe producer/consumer with clean shutdown and optional bounded capacity.
- **GatewayCore** — runs background threads, owns device + queue, exposes a status API.
- **Configuration System** — INI-style config file for runtime settings (sampling interval, queue size, log level).
- **CLI tools** — `gateway_app` with config support, `device_simulator_cli` for interactive testing, `perf_tool` for benchmarking.
- **Tests** — Google Test framework with 50+ tests, including unit tests for serial simulation, config parsing, and bounded queue behavior.

Focus areas: RAII, pImpl, state machines, hardware abstraction, SOLID principles (DIP, ISP, DI), producer–consumer queues, thread coordination, safe shutdown, externalized configuration.

## Configuration

TelemetryHub supports runtime configuration via a simple INI-style file.

### Configuration File Format

Create a config file (e.g., `config.ini`) with the following keys:

```ini
# Sampling interval in milliseconds
sampling_interval_ms = 100

# Max items in the in-memory queue (0 = unbounded)
queue_size = 256

# Log level: error | warn | info | debug | trace
log_level = info
```

See `docs/config.example.ini` for a complete example.

### Using Configuration

Run `gateway_app` with the `--config` flag:

```powershell
# Windows
.\build_vs_ci\gateway\Release\gateway_app.exe --config docs\config.example.ini

# Linux
./build/gateway/gateway_app --config docs/config.example.ini
```

Configuration values override defaults but can still be overridden by command-line arguments like `--log-level`.

### Bounded Queue Behavior

When `queue_size` is set to a non-zero value, the telemetry queue operates in bounded mode:
- **Drop-oldest strategy**: When the queue is full, the oldest sample is dropped to make room for new data
- **Use case**: Real-time telemetry where the most recent data is most valuable
- **Default**: `queue_size = 0` (unbounded queue)

Example bounded queue configuration:
```ini
queue_size = 100  # Keep only the 100 most recent samples
```

## Diagrams
- High-Level Architecture: `docs/mermaid/High level diagram_day12.mmd`
- Control Flow: `docs/mermaid/Control flow_day12.mmd`
- Telemetry Path: `docs/mermaid/Telemetry Path_day12.mmd`

Tip: Open these `.mmd` files directly in VS Code with a Mermaid extension to preview, or render to images using your existing scripts in `docs/mermaid`.

Render locally (not in CI)
```powershell
# Render Day 12 diagrams to PNG in-place
pwsh -File tools\render_mermaid.ps1 -Pattern "*_day12.mmd" -OutputFormat png -Chatty

# Optionally render all .mmd to a separate folder
pwsh -File tools\render_mermaid.ps1 -Pattern "*.mmd" -OutputFormat png -OutDir docs\mermaid\rendered -Chatty
```
Notes:
- This script uses `npx @mermaid-js/mermaid-cli` and may install Node.js LTS via `winget` if missing.
- Keep these renders local; CI does not run this step.

## add log and e2e test
./build/gateway/gateway_app --log-level debug
./build/gateway/gateway_app --log-level trace --log-file thub.log

## Device Simulator CLI

Interactive command-line tool for testing device commands and serial communication:

```powershell
# Windows
.\build_vs_ci\tools\Release\device_simulator_cli.exe

# Linux
./build/tools/device_simulator_cli
```

**Available Commands:**
- **Local commands**: `start`, `stop`, `sample`, `help`, `quit`
- **Serial commands**: `CALIBRATE`, `GET_STATUS`, `SET_RATE <ms>`, `RESET`

**Example Session:**
```
TelemetryHub Device Simulator CLI
Type 'help' for commands, 'quit' to exit

Device State: Idle
> start
Starting device acquisition...
Device State: Measuring

> GET_STATUS
Response: STATE=Measuring

> CALIBRATE
Response: OK: Calibration in progress

> SET_RATE 200
Response: OK: Sampling rate set to 200 ms

> stop
Stopping device acquisition...
Device State: SafeState
```

**Use Cases:**
- Test device commands without REST API
- Debug serial command parsing
- Demonstrate hardware abstraction (UART simulation)
- Rapid prototyping and development

## Folder Structure
```text
telemetryhub/
├─ CMakeLists.txt
├─ CMakePresets.json                # Build presets (linux-ninja-release, vs2026, etc.)
├─ ReadMe.md                        # This file
├─ LICENSE
├─ cmake/
│  └─ ConfigWarnings.cmake          # Compiler warnings configuration
├─ scripts/                         # PowerShell automation scripts
│  ├─ configure_fbuild.ps1          # FASTBuild configuration
│  ├─ cleanup_branches.ps1          # Branch cleanup automation
│  └─ organize_repo.ps1             # Repository organization
├─ docs/                            # Documentation (66+ files)
│  ├─ PROJECT_STRATEGY.md           # Dual-project rationale
│  ├─ PROJECT_BOUNDARIES.md         # Feature boundaries
│  ├─ REPOSITORY_STRUCTURE.md       # This folder structure guide
│  ├─ architecture.md
│  ├─ system_overview.md
│  └─ configuration.md
├─ device/
│  ├─ CMakeLists.txt
│  ├─ include/telemetryhub/device/
│  │  ├─ Device.h
│  │  └─ TelemetrySample.h
│  └─ src/
│     ├─ Device.cpp
│     └─ DeviceConfig.cpp
├─ gateway/
│  ├─ CMakeLists.txt
│  ├─ include/telemetryhub/gateway/
│  │  ├─ GatewayCore.h
│  │  ├─ TelemetryQueue.h
│  │  ├─ ICloudClient.h
│  │  └─ RestCloudClient.h
│  └─ src/
│     ├─ GatewayCore.cpp
│     ├─ TelemetryQueue.cpp
│     ├─ RestCloudClient.cpp
│     └─ main_gateway.cpp
├─ gui/
│  ├─ CMakeLists.txt
│  └─ src/
│     ├─ main_gui.cpp
│     ├─ MainWindow.h
│     └─ MainWindow.cpp
├─ tests/
│  ├─ CMakeLists.txt
│  ├─ test_device.cpp
│  ├─ test_queue.cpp
│  └─ scripts/
│     └─ http_integration.ps1       # Integration test scripts
└─ tools/
   ├─ perf_tool.cpp
   ├─ device_simulator_cli.cpp
   ├─ run_gui.ps1                   # Tool-specific scripts
   └─ render_mermaid.ps1
```

**Note:** All PowerShell scripts in root have been moved to `scripts/`. All markdown files (except ReadMe.md) moved to `docs/`. See [docs/REPOSITORY_STRUCTURE.md](docs/REPOSITORY_STRUCTURE.md) for guidelines.

## cpp-httplib integration

### Windows (Developer PowerShell) quick start

- Prereqs: Visual Studio with C++ toolchain, use Developer PowerShell.
- `cpp-httplib` is fetched via CMake FetchContent; no vendor folder needed.

Build and run:
- Use CMake presets (recommended) or configure a VS generator with `-T host=x64`.
- Build `gateway_app`.
- Use `Invoke-WebRequest` to call `/status`, `/start`, `/stop`.

Test the REST API in another PowerShell window.

### Notes
- Prefer Developer PowerShell to avoid MSYS paths leaking into MSVC builds.
- PowerShell's `curl` may be an alias; use `Invoke-WebRequest` for consistency on Windows.

## Troubleshooting (Windows/MSVC)

If you see MSYS header errors (e.g., `C:/msys64/ucrt64/include/...` and `__asm__ unknown override specifier`) or linker issues like `LNK1136`, check `docs/windows_build_troubleshooting.md` for:

- Sanitizing environment variables that contain `msys64`
- Disabling MSVC external headers and CMake finder system paths
- Verifying library architecture via `dumpbin`/`link.exe`
- Clean rebuild steps and quick verification commands

## Verifying Real HTTP Integration

For a concise walkthrough on Windows and Linux, see `docs/verify_rest.md`.

Steps to confirm the gateway uses the real `cpp-httplib` and integration tests pass:

1. Configure a build directory:
   ```powershell
   cmake -G "Visual Studio 18 2026" -A x64 -T host=x64 .. -DCMAKE_BUILD_TYPE=Debug
   ```
2. Ensure FetchContent pulled httplib (look for `httplib` messages or `_deps/httplib-src/httplib.h` in the build directory).
3. Verify http_server uses the real header only: `gateway/src/http_server.cpp` should include `#include <httplib.h>`.
4. Build target:
   ```powershell
   cmake --build . --config Debug --target gateway_app
   ```
5. Manual run:
   ```powershell
   .\gateway\Debug\gateway_app.exe
   ```
   Expect log: `Listening on port 8080`.
6. Manual endpoint check (separate shell):
   ```powershell
   Invoke-WebRequest -UseBasicParsing http://localhost:8080/status | Select-Object -ExpandProperty Content
   Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start | Select-Object -ExpandProperty Content
   Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop  | Select-Object -ExpandProperty Content
   ```
7. Integration test (Windows):
   ```powershell
   ctest -C Debug -R http_integration --output-on-failure
   ```
   Pass criteria: script prints `HTTP integration test passed`.
8. Confirm build artifacts link against `httplib` target (check `gateway_app.vcxproj` IncludePath contains `_deps/httplib-src`).

If failures occur:
- Check PATH for stray `C:\msys64` entries; re-open Developer PowerShell if present.
 - Re-run configure after deleting `CMakeCache.txt` if the `httplib` target is missing.

## Mermaid .mmd and image files 
Refer to @render_mermaid.ps1 for generation of images and steps

## GUI Quick Start (Qt)
- Prereqs: Qt6 MSVC kit (e.g., `C:\Qt\6.10.1\msvc2022_64`). Set once per shell:
   ```powershell
   $env:THUB_QT_ROOT = "C:\Qt\6.10.1\msvc2022_64"
   ```
- Configure & build with preset:
   ```powershell
   cmake --preset vs2022-gui
   cmake --build --preset vs2022-gui
   ```
- Run gateway + GUI with helper:
   ```powershell
   pwsh -File tools/run_gui.ps1 -ApiBase "http://127.0.0.1:8080"
   ```
Notes: The GUI reads `THUB_API_BASE` and polls `/status` every second. Buttons enable/disable based on device state.

## GUI Verification / Smoke Tests
After building with a GUI preset you can validate end-to-end:

1. Clean + configure (optional fresh start):
   ```powershell
   pwsh -File tools/clean_reconfigure.ps1 -Preset vs2026-gui -RemoveRootCache
   ```
2. Build (if not already built by the clean script):
   ```powershell
   cmake --build --preset vs2026-gui -v
   ```
3. Launch via helper (auto-starts gateway if present):
   ```powershell
   pwsh -File tools/run_gui.ps1 -QtRoot "C:\Qt\6.10.1\msvc2022_64" -ApiBase "http://127.0.0.1:8080" -WaitTimeoutSec 40
   ```
   Add `-DeployLocal` to copy Qt DLLs beside `gui_app.exe` for double-click runs without a global Qt install.
4. Observe initial state label matches `/status` (usually `Idle`).
5. Click Start:
   - GUI should disable Start, enable Stop.
   - `/status` should eventually report `"state":"Measuring"`.
6. Click Stop:
   - GUI should disable Stop, re-enable Start.
   - `/status` should return to `Idle` (or `SafeState` if an internal error was surfaced).
7. Manual REST cross-check in separate shell:
   ```powershell
   Invoke-WebRequest -UseBasicParsing http://localhost:8080/status | Select-Object -ExpandProperty Content
   Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start | Select-Object -ExpandProperty Content
   Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop  | Select-Object -ExpandProperty Content
   ```
8. Integration test (HTTP) against current build tree (Windows only):
   ```powershell
   ctest -C Release -R http_integration --output-on-failure
   ```
   Pass criteria: prints `HTTP integration test passed`. (Timeout increased to 40s to reduce flakiness.)
9. Qt version guardrail check (optional):
   ```powershell
   $qtpaths = "C:\Qt\6.10.1\msvc2022_64\bin\qtpaths6.exe"
   & $qtpaths --qt-version   # Expect 6.10.1
   ```
10. Artifact run (CI bundle): Download `gui_app_windows_bundle` artifact from GitHub Actions, unzip, and run `gui_app.exe` directly; it should locate its deployed Qt plugins (no Qt install required).

Troubleshooting:
- If GUI health check fails: ensure `gateway_app.exe` exists (rebuild) or supply a running gateway endpoint via `-ApiBase`.
- If `/start` never reaches Measuring: run in Debug (`cmake --preset vs2026-debug`) and inspect gateway logs; transient `SafeState` may indicate a simulated device fault.
- If Qt plugins missing on standalone launch: re-run helper with `-DeployLocal` or ensure `platforms/` and `styles/` folders were copied.

## Combined Smoke (Gateway + GUI + REST)
For a quick all-in-one verification (Windows):
```powershell
$env:THUB_QT_ROOT = "C:\Qt\6.10.1\msvc2022_64"
pwsh -File tools/clean_reconfigure.ps1 -Preset vs2026-gui
cmake --build --preset vs2026-gui -v

# Option 1: Default settings
pwsh -File tools/run_gui.ps1 -ApiBase "http://127.0.0.1:8080" -WaitTimeoutSec 40

# Option 2: With custom configuration
pwsh -File tools/run_gui.ps1 -ApiBase "http://127.0.0.1:8080" -WaitTimeoutSec 40 -ConfigFile docs\config.example.ini

Invoke-WebRequest -UseBasicParsing http://localhost:8080/status | Select-Object -ExpandProperty Content
Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start | Select-Object -ExpandProperty Content
Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop  | Select-Object -ExpandProperty Content
ctest -C Release -R http_integration --output-on-failure
```

## Testing

TelemetryHub uses **Google Test** for unit and integration testing:

```powershell
# Windows - Run all tests
ctest -C Release --output-on-failure

# Run specific test suites
ctest -C Release -R unit_tests --output-on-failure       # Core unit tests
ctest -C Release -R test_config --output-on-failure      # Configuration parser tests
ctest -C Release -R test_bounded_queue --output-on-failure  # Bounded queue tests
ctest -C Release -R test_gateway_e2e --output-on-failure # End-to-end gateway tests
```

### Test Coverage

- **`unit_tests`**: Device state machine, telemetry queue, RAII wrappers
- **`test_config`**: Config file parsing (INI format), default values, error handling
- **`test_bounded_queue`**: Drop-oldest policy, capacity changes, concurrent producer-consumer
- **`test_gateway_e2e`**: Full gateway lifecycle, device polling, queue operations
- **`cloud_client_tests`**: Cloud connectivity mocks
- **`http_integration`**: REST API endpoints (requires running gateway)

## Documentation

- **[docs/system_overview.md](docs/system_overview.md)**: Architecture diagrams, threading model, error handling strategies
- **[docs/config.example.ini](docs/config.example.ini)**: Example configuration file
- **[docs/steps_to_verify.md](docs/steps_to_verify.md)**: Detailed build and verification commands

## Release Notes

See the [CHANGELOG](CHANGELOG.md) for full version history.

Latest release: **v4.0.0** - Hardware Abstraction & Device Commands

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Author:** Amaresh Kumar  
**Contact:** amaresh.kumar@live.in  
**Repository:** https://github.com/amareshkumar/telemetryhub

## 🔧 Troubleshooting

### Build Issues
- **Qt not found**: Set `THUB_QT_ROOT` environment variable
- **MSVC header conflicts**: Use Developer PowerShell, not MSYS/Cygwin

### Runtime Issues
- **Port 8080 in use**: Change with `--port 8081`
- **Config not loading**: Check file path and permissions

See [full troubleshooting guide](docs/troubleshooting.md)

# ![Demo](docs/demo.gif) coming soon...

## 🚀 Roadmap

- [ ] Prometheus metrics export
- [ ] OpenTelemetry tracing
- [ ] Grafana dashboard example
- [ ] Kubernetes deployment manifests
- [ ] Load balancing multiple gateways