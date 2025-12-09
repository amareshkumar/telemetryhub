# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic Versioning].

## [Released]
## [2.0.0] - 2025-12-09
**Title:** REST, Security, Qt GUI, Profiling

### Added
- Performance benchmark tool (`tools/perf_tool.cpp`) to measure `TelemetryQueue` push operations.
- System overview document (`docs/system_overview.md`) with architecture diagram and technical explanations.
- CI troubleshooting guide (`docs/troubleshooting.txt`) documenting the Qt installation fix.
- Build verification steps (`docs/steps_to_verify.md`).

### Changed
- Optimized `TelemetryQueue::push` by adding a `std::move` overload to improve performance for rvalue samples.
- Replaced the unreliable `jurplel/install-qt-action` with a manual `aqtinstall` script in the `windows-gui` CI job for improved stability.

### Fixed
- Resolved persistent `windows-gui` CI failures related to Qt installation.

## [1.1.0] - 2025-12-02
**Title:** Qt6 GUI Application

### Added
- New Qt6 GUI application (`gui/`) with:
  - Live status display
  - Start/Stop measurement controls
  - REST client abstraction for polling `/status`
  - PowerShell launcher to handle deployment (`run_gui.ps1`)
- Windows GUI build job integrated into GitHub Actions
- REST API helper for GUI communication (`RestClient`)

### Changed
- Improved HTTP integration test:
  - CI-aware "smoke test" mode
  - More robust JSON parsing and logging
  - Better handling of SafeState and sequence values
- Updated CMake presets for Windows GUI builds (VS2022/VS2026)
- Updated README with GUI instructions and build matrix

### Fixed
- Eliminated CI timeouts caused by Measuring-state waits
- Fixed IPv6 localhost connection warnings by using IPv4 in tests
- Stabilized Windows integration tests and port startup logic


## [Released]
## [1.0.0] - 2025-02-12
**Title:** REST http server + CI/presets + gitcore app + Mermaid code and images

## [0.9.0] - 2025-11-30
**Title:** Real HTTP Gateway, Stable Cross-Platform Builds

**Description:** This release replaces the stubbed HTTP server with real `cpp-httplib` endpoints in `gateway_app` and hardens the build across Windows and Linux. It adds CMake Presets, Windows Developer PowerShell guidance, and CI workflow updates to keep checks green. Tests are stabilized with a fast log sink check and a Windows PowerShell HTTP integration test.
- Added: Local REST API in gateway_app using real cpp-httplib (/status, /start, /stop).
- Fixed: Windows/MSVC build contamination from MSYS headers; standardized Developer PowerShell and x64 host.
- Added: Windows quick start in ReadMe.md with PowerShell examples.
- Added: Integration test http_integration validating HTTP endpoints.
- Changed: Removed httplib stub toggle and vendor includes; rely on CMake FetchContent.

### What We Changed
- Bypassed cpp-httplib's CMake by using `FetchContent_Populate` and our own `INTERFACE` target, preventing auto-linking optional deps.
- Centralized cpp-httplib feature toggles in `gateway/src/http_config.h`; hard-disabled zstd/brotli/zlib/openssl.
- Standardized builds with `CMakePresets.json` (Linux Ninja presets for ASAN/UBSAN and TSAN; Windows VS 2022 CI preset).
- Updated CI workflows to use presets, added clean steps to avoid stale `_deps`, and fixed Windows env sanitization.
- Stabilized tests: `log_file_sink` now exits quickly via `--version`; `http_integration.ps1` locates Release/Debug reliably and cleans up the process.

### Why This Made Checks Pass
- Eliminated accidental `zstd::libzstd` linkage on Linux by not invoking httplib's CMake targets at all.
- Ensured reproducible configure/build/test across runners via presets and clean binary directories.
- Prevented MSYS include/lib contamination on Windows and fixed a PowerShell parsing issue in env sanitization.
- Removed duplicate/fragile linkage and ensured `gateway_app` links to `httplib` in a single, predictable place.

### Potential Repercussions
- Optional features disabled: no SSL/TLS and no compression in httplib. Enabling HTTPS or compression later requires adding explicit deps and re-enabling macros/CMake options.
- CMake deprecation note: `FetchContent_Populate` emits a warning under newer CMake (CMP0169). It works now; consider revisiting to `MakeAvailable` in a follow-up.
- Sanitizer builds increase CI runtime; keep only the needed sanitizer jobs to balance coverage and speed.

### Added
- CTest `log_file_sink`: verifies `--log-level` filtering and `--log-file` sink in gateway_app.

### Added
- Header-only logger (`telemetryhub::Logger`) with levels and optional file sink.
- `--log-level` and `--log-file` flags in `gateway_app`.
- Ctrl-C graceful shutdown path.
- E2E test: start → run → stop.

## [Released]
## [0.1.3] - 2025-11-27
### Added
- `--version` / `-v` flag in `gateway_app` (prints project version + git tag/SHA).
- GitHub Actions CI (Linux + Windows): configure, build, CTest, and smoke `--version`.
- Conditional version header: generate `telemetryhub/Version.h` from `Version.h.in` only if the repo header is absent.

### Changed
- CMake: added `cmake/GetGit.cmake`, prefer repo header else generate into `build*/generated/...`.
- Target includes updated to use `THUB_VERSION_INCLUDE_DIR`.

### Fixed
- MSVC compile error (accidentally streamed function pointer `version` without `()`).


## [0.1.2] - 2025-11-26
### Added
- `--version` / `-v` flag in `gateway_app` (prints project version + git tag/SHA).
- GitHub Actions CI (Linux + Windows): configure, build, CTest, and smoke `--version`.
- Conditional version header flow: generate `telemetryhub/Version.h` from `Version.h.in` **only if** the repo header is absent.

### Changed
- CMake wiring: added `cmake/GetGit.cmake` and top-level logic to prefer the repo header, else generate into `build*/generated/...`.
- Target includes updated to consume `THUB_VERSION_INCLUDE_DIR`.

### Fixed
- MSVC compile error caused by streaming a function pointer (missing `()` on `version()` in `main_gateway.cpp`).

## [0.1.1] - 2025-11-25
### Added
- `gateway_app` prints the TelemetryHub version on startup.

[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
