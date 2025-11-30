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
