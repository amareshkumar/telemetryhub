# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic Versioning].

## [Unreleased]

## [0.9.0] - 2025-11-30
- Added: Local REST API in gateway_app using real cpp-httplib (/status, /start, /stop).
- Fixed: Windows/MSVC build contamination from MSYS headers; standardized Developer PowerShell and x64 host.
- Added: Windows quick start in ReadMe.md with PowerShell examples.
- Added: Integration test http_integration validating HTTP endpoints.
- Changed: Removed httplib stub toggle and vendor includes; rely on CMake FetchContent.

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
