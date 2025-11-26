![C++ CI](https://github.com/amareshkumar/telemetryhub/actions/workflows/cpp-ci.yml/badge.svg)

```text
## About

TelemetryHub is a small but realistic C++ project I use to keep my embedded and systems skills sharp and to prepare for technical interviews.

It models a simple telemetry pipeline:

- A **simulated device** with an explicit state machine (`Idle → Measuring → Error → SafeState`), generating `TelemetrySample` data.
- A **thread-safe TelemetryQueue** that implements a classic producer–consumer pattern with clean shutdown.
- A **GatewayCore** that runs background threads (producer/consumer), owns the device and queue, and exposes a simple status API.
- A set of small **CLI tools** (`raii_demo`, `device_smoke`, `queue_smoke`, `gateway_app`) to exercise RAII, state machines and concurrency from the command line.
- A **GoogleTest + CTest** test suite covering the device behaviour and queue semantics, including a basic multithreaded test.

The focus is on clean, testable C++20 code with patterns that frequently show up in embedded / backend interviews: RAII, pImpl, state machines, producer–consumer queues, thread coordination and safe shutdown.

Following is the folder structure of the project:

telemetryhub/
├─ CMakeLists.txt
├─ cmake/
│  └─ ConfigWarnings.cmake        # (optional) warning flags, etc.
├─ docs/
│  ├─ architecture_week1.md
│  ├─ system_overview.md
│  └─ interview_mapping.md
├─ device/
│  ├─ CMakeLists.txt
│  ├─ include/
│  │  └─ telemetryhub/
│  │     └─ device/
│  │        ├─ Device.h
│  │        └─ TelemetrySample.h
│  └─ src/
│     ├─ Device.cpp
│     └─ DeviceConfig.cpp        # later
├─ gateway/
│  ├─ CMakeLists.txt
│  ├─ include/
│  │  └─ telemetryhub/
│  │     └─ gateway/
│  │        ├─ GatewayCore.h
│  │        ├─ TelemetryQueue.h
│  │        ├─ ICloudClient.h
│  │        └─ RestCloudClient.h
│  └─ src/
│     ├─ GatewayCore.cpp
│     ├─ TelemetryQueue.cpp
│     ├─ RestCloudClient.cpp
│     └─ main_gateway.cpp        # console/REST gateway app
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

