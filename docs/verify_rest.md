# Verify REST Endpoints (Presets)

Validate that `gateway_app` runs with real `cpp-httplib` and that `/status`, `/start`, and `/stop` work using CMake Presets. These steps mirror what we finalized previously for both Windows and Linux.

Prerequisites:
- CMake 3.23+ and a C++20 toolchain
- Internet access for CMake FetchContent to pull `cpp-httplib`

Quick verify (Windows, Developer PowerShell):
```powershell
cmake --preset vs2026-debug
cmake --build --preset vs2026-debug --target gateway_app
ctest --preset vs2026-debug -R http_integration --output-on-failure
```

If the test passes, you should see “HTTP integration test passed”.

## Windows (Developer PowerShell)

Two standard presets exist: a local VS 2026 preset and a CI-aligned VS 2022 preset.

- Local preset (VS 2026, Debug):
	```powershell
	cmake --preset vs2026-debug
	cmake --build --preset vs2026-debug --target gateway_app
	# Run manual verification
	cd build_vs26
	.\gateway\Debug\gateway_app.exe
	```
	In another PowerShell window:
	```powershell
	Invoke-WebRequest -UseBasicParsing http://localhost:8080/status | Select-Object -ExpandProperty Content
	Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start | Select-Object -ExpandProperty Content
	Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop  | Select-Object -ExpandProperty Content
	```

- CI preset (VS 2022, Release):
	```powershell
	cmake --preset vs2022-release-ci
	cmake --build --preset vs2022-release-ci
	# Automated integration test (Windows-only)
	ctest --preset vs2022-release-ci -R http_integration --output-on-failure
	```

Notes
- Prefer Developer PowerShell. It avoids MSYS headers/libs leaking into MSVC.
- If the server doesn’t start, ensure port 8080 is free.
- Visual Studio generator layouts place binaries under `gateway/Debug` or `gateway/Release` inside the preset’s `binaryDir` (e.g., `build_vs26` or `build_vs_ci`).

## Linux (Ninja)

Build and verify with the Ninja preset:
```bash
cmake --preset linux-ninja-debug
cmake --build --preset linux-ninja-debug -j
```

Run and verify endpoints:
```bash
./build/gateway/gateway_app &
sleep 1
curl -s http://localhost:8080/status
curl -s -X POST http://localhost:8080/start
curl -s -X POST http://localhost:8080/stop
pkill -f gateway_app || true
```

CTest note: `http_integration` is registered only on Windows. On Linux, validate manually as above or add a similar shell script test.

## Expected Responses
- `GET /status`: JSON with current device state and optional latest_sample.
- `POST /start`: `{"ok":true}` and device transitions to measuring.
- `POST /stop`: `{"ok":true}` and device stops gracefully.

## Troubleshooting
- MSYS headers on Windows: if you see paths like `C:\msys64\...`, see `docs/windows_build_troubleshooting.md`.
- Missing `cpp-httplib`: delete the build directory (or `CMakeCache.txt`) and re-configure so FetchContent repopulates.
- Optional features: project hard-disables OpenSSL/zlib/brotli/zstd in `cpp-httplib`; HTTPS/compression aren’t enabled.
