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
pwsh -File tools/run_gui.ps1 -ApiBase "http://127.0.0.1:8080" -WaitTimeoutSec 40
Invoke-WebRequest -UseBasicParsing http://localhost:8080/status | Select-Object -ExpandProperty Content
Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start | Select-Object -ExpandProperty Content
Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop  | Select-Object -ExpandProperty Content
ctest -C Release -R http_integration --output-on-failure
```