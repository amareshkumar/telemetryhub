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
