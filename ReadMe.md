[![C++ CI](https://github.com/amareshkumar/telemetryhub/actions/workflows/cpp-ci.yml/badge.svg?branch=main)](https://github.com/amareshkumar/telemetryhub/actions/workflows/cpp-ci.yml)
[![Windows C++ CI](https://github.com/amareshkumar/telemetryhub/actions/workflows/windows-ci.yml/badge.svg)](https://github.com/amareshkumar/telemetryhub/actions/workflows/windows-ci.yml)

# TelemetryHub

> **Production-ready C++20 telemetry pipeline demonstrating:**  
> Modern C++ (RAII, move semantics), concurrent programming (8.8M ops/sec),  
> and enterprise-grade engineering (CI/CD, sanitizers, comprehensive docs)

## Why This Project?
TelemetryHub showcases real-world systems programming patterns used in:
- **IoT data collection** (sensor data aggregation)
- **Financial systems** (market data processing)
- **Observability platforms** (metrics collection)

**Key Differentiators:**
- 🚀 **Performance**: 9.1M ops/sec with move semantics (measured, not claimed)
- 🛡️ **Safety**: Thread sanitizers in CI catch race conditions
- 📊 **Professionalism**: Architecture docs, API specs, runnable examples

**TelemetryHub** is a high-performance telemetry data acquisition and distribution system showcasing modern C++20 design patterns, concurrent programming, and production-quality engineering practices.

![C++20](https://img.shields.io/badge/C%2B%2B-20-blue)
![CMake](https://img.shields.io/badge/CMake-3.20+-green)
![Qt](https://img.shields.io/badge/Qt-6.10-brightgreen)
![License](https://img.shields.io/badge/license-MIT-green)
[![codecov](https://codecov.io/gh/amareshkumar/telemetryhub/branch/main/graph/badge.svg)](https://codecov.io/gh/amareshkumar/telemetryhub)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey)

## 🚀 Quick Start

To get started with TelemetryHub:

```bash
# Clone and build (3 commands)
git clone https://github.com/amareshkumar/telemetryhub
cd telemetryhub
cmake --preset linux-ninja-release && cmake --build --preset linux-ninja-release
```

### Run the Gateway App: 
   ```bash
   ./build/gateway/gateway_app --config docs/config.example.ini
   ```
### Send a Test Request:
   ```bash
   curl -X POST http://localhost:8080/start
   ```
   This starts the telemetry data flow. Check the status with:
   ```bash
   curl http://localhost:8080/status
   ```

## About

It simulates a pipeline with:

- **Device** — explicit state machine (`Idle → Measuring → Error → SafeState`) emitting `TelemetrySample`.
- **TelemetryQueue** — thread-safe producer/consumer with clean shutdown and optional bounded capacity.
- **GatewayCore** — runs background threads, owns device + queue, exposes a status API.
- **Configuration System** — INI-style config file for runtime settings (sampling interval, queue size, log level).
- **CLI tools** — `gateway_app` with config support, `perf_tool` for benchmarking.
- **Tests** — GoogleTest + CTest, including unit tests for config parsing and bounded queue behavior.

Focus areas: RAII, pImpl, state machines, producer–consumer queues, thread coordination, safe shutdown, externalized configuration.

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

## Folder Structure
```text
telemetryhub/
├─ CMakeLists.txt
├─ cmake/
│  └─ ConfigWarnings.cmake           # optional warnings, flags, etc.
├─ docs/
│  ├─ architecture_week1.md
│  ├─ system_overview.md
│  └─ interview_mapping.md
├─ device/
│  ├─ CMakeLists.txt
│  ├─ include/telemetryhub/device/
│  │  ├─ Device.h
│  │  └─ TelemetrySample.h
│  └─ src/
│     ├─ Device.cpp
│     └─ DeviceConfig.cpp           # later
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
│     └─ main_gateway.cpp           # console/REST gateway app
├─ gui/
│  ├─ CMakeLists.txt
│  └─ src/
│     ├─ main_gui.cpp
│     ├─ MainWindow.h
│     └─ MainWindow.cpp
├─ tests/
│  ├─ CMakeLists.txt
│  ├─ test_device.cpp
│  └─ test_queue.cpp
└─ tools/
   ├─ perf_tool.cpp
   ├─ run_ci.sh
   └─ run_ci.bat
```

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
- **[docs/day15_notes.md](docs/day15_notes.md)**: Senior engineer interview notes covering configuration management, bounded queues, thread safety, and testing strategies
- **[docs/config.example.ini](docs/config.example.ini)**: Example configuration file
- **[docs/steps_to_verify.md](docs/steps_to_verify.md)**: Detailed build and verification commands

## Release Notes

See the [CHANGELOG](CHANGELOG.md) for full version history.

Latest release: **v1.1.0**


📜 Rights & Usage Notice

This repository is publicly visible for portfolio and evaluation purposes.
All rights to the source code and associated materials are reserved.

You may:

View and read the code for personal or evaluation purposes.

You may not, without explicit written permission:

Copy, reuse, modify, or redistribute any portion of the code

Use the code in commercial, academic, or production projects

Create derivative works based on this project

Publish or mirror the code elsewhere

Unauthorized use of this code is strictly prohibited.
For permissions or inquiries, please contact: amaresh.kumar@live.in

### 6. **Add Code Quality Metrics**

**Integrate tools to show professionalism**:

**a) Code Coverage**:
```yaml
# Add to .github/workflows/cpp-ci.yml
- name: Generate coverage
  run: |
    cmake --preset linux-ninja-coverage
    cmake --build --preset linux-ninja-coverage
    ctest --preset linux-ninja-coverage
    lcov --capture --directory . --output-file coverage.info
    
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3

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