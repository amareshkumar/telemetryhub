# Verify Qt GUI

This guide shows how to build and run the Qt Widgets GUI (`gui_app`) and the gateway (`gateway_app`) across common setups.

Prerequisites
- Qt 6.10.1 installed (e.g., `C:\Qt\6.10.1`)
- CMake 3.23+ and a C++20 toolchain
- Ninja recommended for non-Visual Studio flows

## Command Line (Visual Studio 2022)
```powershell
$env:Qt6_DIR = 'C:\Qt\6.10.1\msvc2022_64'
cmake --preset vs2022-gui
cmake --build --preset vs2022-gui -v

# Terminal A
.\u005cbuild_vs_gui\gateway\Release\gateway_app.exe
# Terminal B
.\u005cbuild_vs_gui\gui\Release\gui_app.exe
```

## Command Line (Visual Studio 2026)
```powershell
$env:THUB_QT_ROOT = 'C:\Qt\6.10.1\msvc2026_64'
cmake --preset vs2026-gui
cmake --build --preset vs2026-gui -v

# Terminal A
.\u005cbuild_vs26\gateway\Release\gateway_app.exe
# Terminal B
.
.
build_vs26\gui\Release\gui_app.exe
```

## Quick Launch (Recommended)
Use the helper script to configure the Qt runtime, check gateway health, and bundle DLLs:
```powershell
# VS2022 example
$env:Qt6_DIR = 'C:\Qt\6.10.1\msvc2022_64'
pwsh -File tools\run_gui.ps1 -ApiBase http://127.0.0.1:8080 -DeployLocal
```
For VS2026, set `THUB_QT_ROOT` instead of `Qt6_DIR`.

## Qt Creator (No Visual Studio)
Use the Ninja-based preset for consistency:
```powershell
cmake --preset qtcreator-ninja
cmake --build --preset qtcreator-ninja -v
ctest --preset qtcreator-ninja --output-on-failure
```
In Qt Creator:
- Open `CMakeLists.txt`, select a Qt 6.10.1 Ninja kit (MinGW or MSVC Build Tools).
- Set build directory to `build_qtcreator`.
- Ensure `BUILD_GUI=ON`. If the kit doesn’t auto-provide Qt, add `-DCMAKE_PREFIX_PATH=<QtKitRoot>`.
- Build `gui_app` and `gateway_app`.
- Run `gateway_app` first, then `gui_app`. If DLLs are missing, add kit `bin` to PATH or run `tools\run_gui.ps1 -DeployLocal` once.

## Expected Behavior
- GUI shows current device state.
- Start/Stop actions reflect in Status; latest sample updates while measuring.

## Troubleshooting
- If `gui_app` fails to start, try `-DeployLocal` to bundle Qt.
- Ensure port 8080 is free for the gateway.
- If tests fail, check `build_*/Testing/Temporary/LastTest.log`.
