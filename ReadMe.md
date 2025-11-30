![C++ CI](https://github.com/amareshkumar/telemetryhub/actions/workflows/cpp-ci.yml/badge.svg)

# TelemetryHub

**TelemetryHub** is a small but realistic C++ project to keep embedded/systems skills sharp and prep for interviews. It models a simple telemetry pipeline with clear, testable C++20 code.

## About

It simulates a pipeline with:

- **Device** — explicit state machine (`Idle → Measuring → Error → SafeState`) emitting `TelemetrySample`.
- **TelemetryQueue** — thread-safe producer/consumer with clean shutdown.
- **GatewayCore** — runs background threads, owns device + queue, exposes a status API.
- **CLI tools** — `raii_demo`, `device_smoke`, `queue_smoke`, `gateway_app`.
- **Tests** — GoogleTest + CTest, including a basic multithreaded test.

Focus areas: RAII, pImpl, state machines, producer–consumer queues, thread coordination, safe shutdown.

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

## Build with CMake Presets (recommended)

Cross-platform builds and CI use `CMakePresets.json` for consistent configuration.

- Linux (ASAN+UBSAN):
   ```bash
   cmake --preset linux-ninja-asan-ubsan
   cmake --build --preset linux-ninja-asan-ubsan -v
   ctest --preset linux-ninja-asan-ubsan --output-on-failure
   ```
- Linux (TSan):
   ```bash
   cmake --preset linux-ninja-tsan
   cmake --build --preset linux-ninja-tsan -v
   ctest --preset linux-ninja-tsan --output-on-failure
   ```
- Windows (local VS 2026):
   ```powershell
   cmake --preset vs2026-release
   cmake --build --preset vs2026-release -v
   ctest --preset vs2026-release --output-on-failure
   ```
- Windows (CI on GitHub runners):
   The runners provide Visual Studio 2022, so CI uses the `vs2022-release-ci` preset:
   ```powershell
   cmake --preset vs2022-release-ci
   cmake --build --preset vs2022-release-ci -v
   ctest --preset vs2022-release-ci --output-on-failure
   ```

Notes:
- If you switch presets or toolchains, start from a clean build folder (remove `build*` directories) to avoid stale CMake cache or `_deps` artifacts.
- The HTTP server currently disables optional `cpp-httplib` features (OpenSSL/zlib/brotli/zstd) to keep builds dependency-light across platforms.

See also: `docs/verify_rest.md` for step-by-step REST verification on Windows and Linux.

### Windows (Developer PowerShell) quick start

- Prereqs: Visual Studio with C++ toolchain, use Developer PowerShell.
- `cpp-httplib` is fetched via CMake FetchContent; no vendor folder needed.

Build and run:
- Configure with `-DUSE_HTTPLIB_STUB=OFF` and `-T host=x64`.
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

## Quick HTTP verification

Windows (Release preset):
```powershell
cmake --preset vs2026-release
cmake --build --preset vs2026-release -v
ctest --preset vs2026-release -R http_integration --output-on-failure
```

Linux (ASAN+UBSAN preset):
```bash
cmake --preset linux-ninja-asan-ubsan
cmake --build --preset linux-ninja-asan-ubsan -v
ctest --preset linux-ninja-asan-ubsan -R test_gateway_e2e --output-on-failure
```