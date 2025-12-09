# Steps to Verify TelemetryHub Builds

This document provides the commands to build and test the various configurations of the TelemetryHub project on both Windows and Linux. The project uses CMake Presets to standardize the build process.

## Verifying on Windows (MSVC)

**Prerequisites**:
*   Visual Studio 2022
*   Ninja (install via Chocolatey: `choco install ninja`)
*   Qt 6.5.3 (for the GUI build) with the `Qt6_DIR` environment variable set.

### 1. Standard Release Build (Non-GUI)

This preset (`vs2022-release-ci`) is used for the core application and tests in a release configuration.

```powershell
# 1. Configure the project
cmake --preset vs2022-release-ci

# 2. Build the executables and libraries
cmake --build --preset vs2022-release-ci

# 3. Run the tests
ctest --preset vs2022-release-ci
```

### 2. GUI Release Build

This preset (`vs2022-gui`) is specifically for building the Qt-based GUI.

```powershell
# 1. Configure the project for the GUI
cmake --preset vs2022-gui

# 2. Build the GUI and gateway apps
cmake --build --preset vs2022-gui
```

## Verifying on Linux (Ninja)

**Prerequisites**:
*   `build-essential`
*   `cmake`
*   `ninja-build`

### 1. Standard Debug Build

This uses the `linux-ninja-debug` preset for a standard debug build.

```bash
# 1. Configure the project
cmake --preset linux-ninja-debug

# 2. Build the code
cmake --build --preset linux-ninja-debug

# 3. Run the tests
ctest --preset linux-ninja-debug --output-on-failure
```

### 2. Sanitizer Build (ASan + UBSan)

This build (`linux-ninja-asan-ubsan`) is crucial for detecting memory errors and undefined behavior.

```bash
# 1. Configure the project with sanitizers
cmake --preset linux-ninja-asan-ubsan

# 2. Build the code
cmake --build --preset linux-ninja-asan-ubsan

# 3. Run the tests (the sanitizers will report errors here)
ctest --preset linux-ninja-asan-ubsan --output-on-failure
```
