# TelemetryHub Development Guide

## Table of Contents
1. [Development Environment Setup](#development-environment-setup)
2. [Build Workflows](#build-workflows)
3. [FASTBuild Integration](#fastbuild-integration)
4. [Code Style & Guidelines](#code-style--guidelines)
5. [Testing & Debugging](#testing--debugging)
6. [Contributing](#contributing)

---

## Development Environment Setup

### Prerequisites

**Required:**
- Visual Studio 2022 (17.10+) or 2026 (18.0+)
- CMake 3.20+
- Qt 6.10.1 (MSVC 2022 64-bit) for GUI development
- Git 2.30+

**Optional:**
- FASTBuild 1.18+ for distributed compilation (optional, 1.18 or later required)
- k6 for performance testing
- Python 3.8+ for test scripts

### Initial Setup

1. **Clone Repository**:
   ```powershell
   git clone https://github.com/yourorg/telemetryhub.git
   cd telemetryhub
   ```

2. **Set Qt Environment Variable**:
   ```powershell
   $env:THUB_QT_ROOT = "C:\Qt\6.10.1\msvc2022_64"
   ```

3. **Configure Build**:
   ```powershell
   cmake --preset vs2026-gui
   ```

4. **Build**:
   ```powershell
   cmake --build build_vs26 --config Release -j8
   ```

---

## Build Workflows

### Standard Build (CMake + MSBuild)

**Development Build (Debug)**:
```powershell
cmake --preset vs2026-gui
cmake --build build_vs26 --config Debug -j8
```

**Release Build**:
```powershell
cmake --preset vs2026-release
cmake --build build_vs26 --config Release -j8
```

**Clean Rebuild**:
```powershell
cmake --build build_vs26 --config Release --clean-first
```

### Building Specific Targets

**Gateway Only**:
```powershell
cmake --build build_vs26 --target gateway_app --config Release
```

**GUI Only**:
```powershell
cmake --build build_vs26 --target gui_app --config Release
```

**Device Library**:
```powershell
cmake --build build_vs26 --target device --config Release
```

**All Tests**:
```powershell
cmake --build build_vs26 --target RUN_TESTS --config Release
```

### VS Code Integration

**tasks.json** example:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Gateway",
      "type": "shell",
      "command": "cmake",
      "args": [
        "--build", "build_vs26",
        "--target", "gateway_app",
        "--config", "Debug",
        "-j8"
      ],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": "$msCompile"
    },
    {
      "label": "Run Gateway",
      "type": "shell",
      "command": "${workspaceFolder}/build_vs26/gateway/Debug/gateway_app.exe",
      "args": [
        "--config", "${workspaceFolder}/examples/custom_config.ini",
        "--port", "8080"
      ],
      "dependsOn": "Build Gateway"
    }
  ]
}
```

**launch.json** example:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Gateway",
      "type": "cppvsdbg",
      "request": "launch",
      "program": "${workspaceFolder}/build_vs26/gateway/Debug/gateway_app.exe",
      "args": [
        "--config", "${workspaceFolder}/examples/custom_config.ini",
        "--port", "8080"
      ],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
```

### Visual Studio Integration

**Open Solution**:
```powershell
start build_vs26\TelemetryHub.sln
```

**Set Startup Project**: Right-click `gateway_app` → Set as Startup Project

**Debug Configuration**:
- Configuration Properties → Debugging → Command Arguments:
  ```
  --config $(SolutionDir)..\examples\custom_config.ini --port 8080
  ```

---

## FASTBuild Integration

FASTBuild provides 4-10× faster builds through distributed compilation and caching.

### Setup FASTBuild

1. **Install FASTBuild**:
   ```powershell
   # Download from https://www.fastbuild.org/docs/download.html
   # Extract to C:\tools\FASTBuild\
   $env:PATH += ";C:\tools\FASTBuild"
   ```

2. **Configure with FASTBuild Enabled**:
   ```powershell
   .\configure_fbuild.ps1 -EnableFastBuild
   ```

3. **Build with FASTBuild**:
   ```powershell
   fbuild -config build_vs26\fbuild.bff -dist -cache
   ```

### FASTBuild Workflows

**Local Compile (Parallel)**:
```powershell
fbuild -config build_vs26\fbuild.bff -j16
```

**Distributed Compile (4 Workers)**:
```powershell
fbuild -config build_vs26\fbuild.bff -dist -cache
```

**Clean Build**:
```powershell
Remove-Item -Recurse -Force build_vs26\generated, .fbuild.cache
fbuild -config build_vs26\fbuild.bff -dist -cache
```

**Debug FASTBuild**:
```powershell
fbuild -config build_vs26\fbuild.bff -verbose -showcmds
```

### Integration with VS Code

**tasks.json with FASTBuild**:
```json
{
  "label": "Build (FASTBuild)",
  "type": "shell",
  "command": "fbuild",
  "args": [
    "-config", "build_vs26/fbuild.bff",
    "-dist", "-cache"
  ],
  "group": {
    "kind": "build",
    "isDefault": true
  },
  "problemMatcher": "$msCompile"
}
```

### Performance Comparison

| Build Type | MSBuild | FASTBuild (local) | FASTBuild (4 workers) | FASTBuild (cached) |
|------------|---------|-------------------|----------------------|--------------------|
| Clean build | 180s | 145s (1.2× faster) | 42s (4.3× faster) | 15s (12× faster) |
| Incremental (1 file) | 8s | 7s | 5s | 1s |
| Full rebuild | 185s | 150s | 45s | 18s |

See [docs/fastbuild_guide.md](fastbuild_guide.md) for complete FASTBuild documentation.

---

## Code Style & Guidelines

### C++ Standards

- **C++20** standard (CMAKE_CXX_STANDARD 20)
- MSVC `/permissive-` (strict conformance)
- Warnings as errors: `/W4 /WX`

### Naming Conventions

**Classes**: PascalCase
```cpp
class TelemetryDevice {};
class GatewayCore {};
```

**Functions**: camelCase
```cpp
void startMeasurement();
void stopMeasurement();
```

**Private Members**: trailing underscore
```cpp
class Example {
private:
    int count_;
    std::string name_;
};
```

**Constants**: ALL_CAPS
```cpp
constexpr int MAX_SAMPLES = 1000;
constexpr double PI = 3.14159;
```

### File Organization

**Headers**:
- Include guards: `#pragma once`
- Forward declarations preferred over includes
- Public API first, private last

**Source Files**:
- Corresponding header first
- System headers
- Third-party headers
- Project headers

Example:
```cpp
#include "MyClass.h"  // Own header first

#include <vector>      // System headers
#include <string>

#include <httplib.h>   // Third-party headers

#include "Device.h"    // Project headers
#include "Gateway.h"
```

### Error Handling

**Use exceptions for exceptional conditions**:
```cpp
if (!file.open()) {
    throw std::runtime_error("Failed to open file");
}
```

**Return values for expected failures**:
```cpp
std::optional<Sample> Device::readSample() {
    if (error_condition) {
        return std::nullopt;
    }
    return sample;
}
```

**Log errors before throwing**:
```cpp
if (port.open() != 0) {
    std::cerr << "[ERROR] Failed to open serial port: " << port.errorString() << "\n";
    throw std::runtime_error("Serial port error");
}
```

---

## Testing & Debugging

### Running Tests

**All Tests**:
```powershell
cd build_vs26
ctest -C Release --output-on-failure
```

**Specific Test**:
```powershell
ctest -R test_device -C Release --verbose
```

**E2E Tests**:
```powershell
.\tests\scripts\e2e_happy_path.ps1
.\tests\scripts\e2e_error_cases.ps1
```

**Performance Tests**:
```powershell
k6 run tests\k6_load_test.js
```

See [docs/e2e_testing_guide.md](e2e_testing_guide.md) for complete testing documentation.

### Debugging Tips

**Gateway Debugging**:
```powershell
# Start gateway with verbose logging
.\gateway_app.exe --config ..\..\..\examples\custom_config.ini --port 8080 --verbose

# Check logs
Get-Content gateway.log -Tail 50 -Wait
```

**GUI Debugging**:
```powershell
# Enable Qt debug output
$env:QT_LOGGING_RULES = "qt.*=true"
.\gui_app.exe
```

**Visual Studio Debugging**:
- Set breakpoint in source
- F5 to start debugging
- F10 to step over, F11 to step into
- Watch window: Add `this`, `samples_`, etc.

**Memory Leaks**:
```powershell
# Use AddressSanitizer (MSVC 2022+)
cmake --preset vs2026-gui -DCMAKE_CXX_FLAGS="/fsanitize=address"
cmake --build build_vs26 --config Debug
.\build_vs26\gateway\Debug\gateway_app.exe
```

---

## Contributing

### Workflow

1. **Create Feature Branch**:
   ```powershell
   git checkout -b feature/my-new-feature
   ```

2. **Make Changes**:
   - Follow code style guidelines
   - Add unit tests for new features
   - Update documentation

3. **Build & Test**:
   ```powershell
   cmake --build build_vs26 --config Release -j8
   ctest -C Release --output-on-failure
   ```

4. **Commit**:
   ```powershell
   git add .
   git commit -m "feat: Add new feature X"
   ```

5. **Push & Create PR**:
   ```powershell
   git push origin feature/my-new-feature
   ```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Test additions/changes
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `chore:` Build/tooling changes

Examples:
```
feat: Add metrics dashboard to Qt GUI
fix: Resolve queue overflow in GatewayCore
docs: Update FASTBuild setup instructions
test: Add E2E test for circuit breaker
```

### PR Review Checklist

- [ ] Code builds without warnings (`/W4 /WX`)
- [ ] All tests pass (`ctest -C Release`)
- [ ] E2E tests pass (happy path + error cases)
- [ ] Documentation updated (if API changed)
- [ ] Commit messages follow convention
- [ ] No MSYS header contamination (`C:/msys64` in logs)

---

## Additional Resources

- [Architecture Documentation](architecture.md)
- [FASTBuild Guide](fastbuild_guide.md)
- [E2E Testing Guide](e2e_testing_guide.md)
- [Windows Build Troubleshooting](windows_build_troubleshooting.md)
- [Performance Analysis](../PERFORMANCE.md)