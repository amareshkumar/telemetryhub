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

// device = fake embedded device, gateway = service/daemon, gui = Qt monitor, tests + tools = infra.