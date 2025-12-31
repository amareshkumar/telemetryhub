# Windows Build Troubleshooting (MSVC + CMake)

This note summarizes recurring Windows/MSVC issues we hit and the fixes, so future builds are faster and cleaner.

## 1) MSYS headers leaking into MSVC builds

- Symptoms:
  - MSBuild errors referencing `C:\msys64\ucrt64\include\...`
  - Errors like `error C3646: '__asm__': unknown override specifier`, `__builtin_va_list`, or `#error: No supported target architecture` inside MSYS headers.
- Root cause:
  - MSYS paths present in environment variables (`INCLUDE`, `LIB`, `LIBPATH`, `CPATH`, `C_INCLUDE_PATH`, `CPLUS_INCLUDE_PATH`, `PKG_CONFIG_PATH`).
  - Visual Studio generator may add `/external:I` entries and pick up non-MSVC headers.
- Fixes we applied:
  - In `CMakeLists.txt` (root), during configure:
    - Unset env vars that contain `msys64`: `INCLUDE`, `LIB`, `LIBPATH`, `CPATH`, `C_INCLUDE_PATH`, `CPLUS_INCLUDE_PATH`, `PKG_CONFIG_PATH`.
    - `set(CMAKE_MSVC_INCLUDE_EXTERNAL_HEADERS OFF)` to stop `/external:I` injection.
    - `set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH OFF)` to prevent find_* from using system env paths.
    - `list(APPEND CMAKE_SYSTEM_IGNORE_PATH ...)` to ignore `C:/msys64` (and common subfolders) globally.
  - Disabled optional `cpp-httplib` backends (zstd/openssl/zlib/brotli) via compile definitions to avoid inadvertent third-party linkage.
- Operational tips:
  - Always use “Developer PowerShell for VS” (x64).
  - Start from a clean build folder when switching environments.
  - Inspect generated `.vcxproj` for any `C:/msys64` in `<AdditionalOptions>`, `<AdditionalIncludeDirectories>`, `<AdditionalDependencies>`.

## 2) LNK1136: invalid or corrupt file

- Symptoms:
  - `fatal error LNK1136: invalid or corrupt file` while linking `gateway_app` against `gateway_core.lib`.
- Likely causes:
  - Mixed architectures (x86 vs x64), mixed toolsets, or stale partial artifacts.
- Quick checks:
  - Verify `.lib` machine type:
    - From Dev PowerShell:
      ```powershell
      $dumpbin = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio\*\*\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe" | Select-Object -Last 1
      & $dumpbin.FullName /headers .\build_vs_real\gateway\Debug\gateway_core.lib | Select-String -Pattern 'machine'
      ```
    - Expect `8664 machine (x64)`.
- Remedies:
  - Clean outputs and rebuild both library and app with the same configuration:
    ```powershell
    Remove-Item -Recurse -Force .\build_vs_real\gateway\Debug, .\build_vs_real\device\Debug
    cmake --build .\build_vs_real --config Debug -- /m
    ```
  - Force non-incremental link (optional):
    ```powershell
    cmake --build .\build_vs_real --config Debug -- /p:LinkIncremental=false
    ```

## 3) Minimal verification checklist

- Configure with x64:
  ```powershell
  cmake -S . -B .\build_vs_real -G "Visual Studio 18 2026" -A x64
  ```
- Build and run:
  ```powershell
  cmake --build .\build_vs_real --target gateway_app --config Debug -- /m
  .\build_vs_real\gateway\Debug\gateway_app.exe
  ```
- Test endpoints:
  ```powershell
  Invoke-WebRequest http://localhost:8080/status
  Invoke-WebRequest -Method Post http://localhost:8080/start
  Invoke-WebRequest -Method Post http://localhost:8080/stop
  ```

## 4) When to suspect environment contamination

- You see MSYS paths in compiler or linker logs.
- MSVC complains about GCC/Clang-only constructs (`__asm__` attribute style, `__builtin_*`).
- `.vcxproj` lists `/external:I` entries pointing at `C:/msys64/...`.

Keep this doc updated when new symptoms or fixes are discovered.

---

## 5) FASTBuild Issues

### Worker Connectivity Problems

- **Symptoms**:
  - `fbuild` reports "No workers available" or "Connection refused"
  - Builds fall back to local compilation only
  - Firewall warnings in Event Viewer

- **Causes**:
  - Firewall blocking ports 31392-31393
  - Worker machines not running FBuildWorker service
  - Network routing issues

- **Fixes**:
  ```powershell
  # Allow FASTBuild through Windows Firewall
  New-NetFirewallRule -DisplayName "FASTBuild Coordinator" `
    -Direction Inbound -Protocol TCP -LocalPort 31392 -Action Allow
  
  New-NetFirewallRule -DisplayName "FASTBuild Worker" `
    -Direction Inbound -Protocol TCP -LocalPort 31392-31393 -Action Allow
  
  # Verify worker is running
  Test-NetConnection -ComputerName 192.168.1.10 -Port 31392
  
  # Check worker status (on worker machine)
  Get-Service FBuildWorker
  # Should show "Running"
  ```

### Cache Corruption

- **Symptoms**:
  - `fbuild` reports "Cache verification failed"
  - Linker errors after cached build: `LNK1136: invalid or corrupt file`
  - Builds succeed after cache clear

- **Causes**:
  - Network share corruption (power loss, disk full)
  - Version mismatch between FASTBuild versions
  - Partial writes to cache

- **Fixes**:
  ```powershell
  # Clear local cache
  Remove-Item -Recurse -Force .fbuild.cache
  
  # Clear network cache (as admin, on file server)
  Remove-Item -Recurse -Force \\fileserver\FBCache\*
  
  # Rebuild with clean cache
  fbuild -config build_vs26\fbuild.bff -dist -cache
  ```

### Firewall Configuration Issues

- **Symptoms**:
  - FASTBuild works on some machines but not others
  - `fbuild -dist` shows "Timeout waiting for workers"
  - Windows Security alerts for fbuild.exe

- **Fixes**:
  ```powershell
  # Add exception for FASTBuild executable
  New-NetFirewallRule -DisplayName "FASTBuild Executable" `
    -Direction Outbound -Program "C:\tools\FASTBuild\fbuild.exe" -Action Allow
  
  # Verify rule exists
  Get-NetFirewallRule -DisplayName "FASTBuild*"
  
  # Test connectivity to worker pool
  Test-NetConnection -ComputerName worker1.local -Port 31392 -InformationLevel Detailed
  ```

### .bff Version Mismatch

- **Symptoms**:
  - `fbuild` reports "Unknown compiler option"
  - MSVC version mismatch errors
  - Missing Qt MOC files

- **Causes**:
  - CMake generated .bff with different Visual Studio version
  - Qt path changed after .bff generation
  - FASTBuild version updated (incompatible .bff syntax)

- **Fixes**:
  ```powershell
  # Regenerate .bff files with updated configuration
  Remove-Item build_vs26\fbuild.bff
  .\configure_fbuild.ps1 -EnableFastBuild
  
  # Verify MSVC version in .bff
  Select-String -Path build_vs26\fbuild.bff -Pattern "Compiler\('MSVC-Compiler'\)"
  # Should show correct Visual Studio version
  
  # Rebuild from scratch
  cmake --build build_vs26 --clean-first --config Release
  fbuild -config build_vs26\fbuild.bff -dist -cache
  ```

### Linker Errors After Distributed Build

- **Symptoms**:
  - `fatal error LNK2001: unresolved external symbol`
  - Libraries built successfully but linking fails
  - Works with MSBuild but fails with FASTBuild

- **Causes**:
  - Object files compiled with different compiler flags
  - Library order incorrect in .bff Executable() section
  - Missing dependencies in FASTBuild target definition

- **Fixes**:
  ```powershell
  # Check .bff Executable() configuration
  Select-String -Path build_vs26\fbuild.bff -Pattern "Executable\('gateway_app'\)" -Context 10
  
  # Verify .Libraries order matches CMake target_link_libraries
  # In .bff:
  #   .Libraries = { 'gateway_core', 'device' }  # Correct order
  # NOT:
  #   .Libraries = { 'device', 'gateway_core' }  # Wrong order (unresolved symbols)
  
  # Rebuild libraries explicitly
  fbuild -config build_vs26\fbuild.bff device gateway_core -clean
  fbuild -config build_vs26\fbuild.bff gateway_app
  ```

### Performance Not Improved

- **Symptoms**:
  - FASTBuild build time similar to MSBuild
  - No distribution happening (all local builds)
  - Cache hit rate 0%

- **Causes**:
  - Workers not configured (`-dist` flag missing)
  - Cache path incorrect or inaccessible
  - Network share too slow (cache writes timeout)

- **Fixes**:
  ```powershell
  # Verify worker list in configure_fbuild.ps1
  .\configure_fbuild.ps1 -EnableFastBuild -WorkerList "192.168.1.10,192.168.1.11,192.168.1.12"
  
  # Enable verbose logging
  fbuild -config build_vs26\fbuild.bff -dist -cache -verbose
  # Check for:
  #   "Distributing to X workers"
  #   "Cache hit: Y/Z files"
  
  # Benchmark cache performance
  Measure-Command {
    Copy-Item build_vs26\generated\device.obj \\fileserver\FBCache\test.obj
  }
  # Should be < 100ms for local network
  
  # Use local cache if network is slow
  # In build_vs26\fbuild.bff, change:
  #   Settings { .CachePath = '.fbuild.cache' }  # Local cache only
  ```
