# Build and Test Guide - Day 18 Robustness Features

## Prerequisites

- CMake 3.15+ installed
- Visual Studio 2019/2022 with C++ development tools
- Git (for version control)
- PowerShell or Command Prompt

---

## Build Steps

### 1. Navigate to Project Root
```powershell
cd C:\code\telemetryhub
```

### 2. Configure Build (First Time Only)
```powershell
# Create build directory if it doesn't exist
cmake -S . -B build_vs_ci -DCMAKE_BUILD_TYPE=Release
```

### 3. Build the Project
```powershell
# Build all targets (device, gateway, tests, tools)
cmake --build build_vs_ci --config Release

# OR build specific target
cmake --build build_vs_ci --config Release --target unit_tests
```

**Expected Output:**
```
[100/100] Linking CXX executable tests\Release\unit_tests.exe
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### 4. Verify Build Artifacts
```powershell
# Check that executables were created
Get-ChildItem build_vs_ci\device\Release\*.exe
Get-ChildItem build_vs_ci\gateway\Release\*.exe
Get-ChildItem build_vs_ci\tests\Release\*.exe
```

**Expected Files:**
- `build_vs_ci\device\Release\device_app.exe`
- `build_vs_ci\gateway\Release\gateway_app.exe`
- `build_vs_ci\tests\Release\unit_tests.exe`

---

## Test Steps

### 1. Run All Tests
```powershell
cd build_vs_ci
ctest -C Release --output-on-failure
```

**Expected Output:**
```
Test project C:/code/telemetryhub/build_vs_ci
    Start 1: DeviceTests
1/3 Test #1: DeviceTests ......................   Passed    0.12 sec
    Start 2: GatewayTests
2/3 Test #2: GatewayTests .....................   Passed    0.08 sec
    Start 3: RobustnessTests
3/3 Test #3: RobustnessTests ..................   Passed    0.15 sec

100% tests passed, 0 tests failed out of 3
```

### 2. Run Specific Test Suites

#### Run Only Robustness Tests (Day 18)
```powershell
.\tests\Release\unit_tests.exe --gtest_filter=RobustnessTests.*
```

**Expected Output:**
```
[==========] Running 15 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 15 tests from RobustnessTests
[ RUN      ] RobustnessTests.NoFaultInjectionMode_BehavesNormally
[       OK ] RobustnessTests.NoFaultInjectionMode_BehavesNormally (10 ms)
[ RUN      ] RobustnessTests.RandomSensorErrors_CausesIntermittentFailures
[       OK ] RobustnessTests.RandomSensorErrors_CausesIntermittentFailures (105 ms)
...
[----------] 15 tests from RobustnessTests (250 ms total)

[==========] 15 tests from 1 test suite ran. (250 ms total)
[  PASSED  ] 15 tests.
```

#### Run Device Tests
```powershell
.\tests\Release\unit_tests.exe --gtest_filter=DeviceTests.*
```

#### Run Gateway Tests
```powershell
.\tests\Release\unit_tests.exe --gtest_filter=GatewayTests.*
```

### 3. Verbose Test Output
```powershell
# See detailed test output including console logs
.\tests\Release\unit_tests.exe --gtest_filter=RobustnessTests.* --gtest_print_time=1
```

---

## Troubleshooting

### Build Fails - Missing Dependencies
**Error:** `Could not find package: GTest`

**Solution:**
```powershell
# CMake will fetch GoogleTest automatically
# Ensure you have internet connection during first build
cmake --build build_vs_ci --config Release --clean-first
```

### Build Fails - Compiler Errors
**Error:** `error C2065: 'FaultInjectionMode' : undeclared identifier`

**Solution:**
```powershell
# Clean and reconfigure
Remove-Item -Recurse -Force build_vs_ci\CMakeCache.txt
cmake -S . -B build_vs_ci
cmake --build build_vs_ci --config Release
```

### Tests Fail - Statistical Tests
**Error:** `RobustnessTests.Interview_StatisticalValidation` fails intermittently

**Root Cause:** Statistical tests use random distributions with tolerance ranges

**Solution:**
```powershell
# Run multiple times to verify consistency
for ($i=1; $i -le 5; $i++) {
    Write-Host "Run $i"
    .\tests\Release\unit_tests.exe --gtest_filter=RobustnessTests.Interview_StatisticalValidation
}
```

**Expected:** Should pass 4-5 out of 5 runs (1 failure acceptable due to randomness)

### Tests Timeout
**Error:** Test takes longer than 30 seconds

**Solution:**
```powershell
# Increase timeout for specific test
ctest -C Release --timeout 60 --output-on-failure
```

---

## Quick Verification Commands

### Full Build + Test Cycle
```powershell
# One-liner to build and test
cd C:\code\telemetryhub; cmake --build build_vs_ci --config Release && cd build_vs_ci && ctest -C Release --output-on-failure
```

### Check Git Status
```powershell
# See what files changed
git status

# See diff summary
git diff --stat

# See detailed changes
git diff device/src/Device.cpp
```

### Build Specific Targets Only
```powershell
# Build only device library
cmake --build build_vs_ci --config Release --target device_lib

# Build only gateway
cmake --build build_vs_ci --config Release --target gateway_lib

# Build only tests
cmake --build build_vs_ci --config Release --target unit_tests
```

---

## Performance Benchmarks

### Expected Build Times (Release Mode)
- **Clean build:** ~2-3 minutes (includes GoogleTest fetch)
- **Incremental build:** ~10-20 seconds (only changed files)
- **Test execution:** ~0.5 seconds (all tests)

### Expected Test Times
- **DeviceTests:** ~100-150 ms
- **GatewayTests:** ~80-120 ms
- **RobustnessTests:** ~200-300 ms (statistical tests run 1000 iterations)

---

## CI/CD Integration

### GitHub Actions / Azure DevOps
```yaml
- name: Build TelemetryHub
  run: cmake --build build_vs_ci --config Release

- name: Run Tests
  run: |
    cd build_vs_ci
    ctest -C Release --output-on-failure --timeout 60
```

### Jenkins
```groovy
stage('Build') {
    steps {
        bat 'cmake --build build_vs_ci --config Release'
    }
}
stage('Test') {
    steps {
        bat 'cd build_vs_ci && ctest -C Release --output-on-failure'
    }
}
```

---

## Next Steps After Successful Build

1. ✅ Verify all tests pass
2. ✅ Review git diff for changes
3. ✅ Commit changes to branch
4. ✅ Push to remote repository
5. ✅ Create pull request to merge into main

---

## Contact & Support

- **Documentation:** See `docs/` folder for architecture and API docs
- **Troubleshooting:** See `docs/troubleshooting.md` and `docs/windows_build_troubleshooting.md`
- **Day 18 Changes:** See `docs/day18_progress.md` for detailed implementation notes
