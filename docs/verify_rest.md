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

## Qt GUI Verification (Windows)

Verify the Qt Widgets GUI (`gui_app`) against the running `gateway_app` on both VS 2022 and VS 2026 setups, via command line and Qt Creator.

Prerequisites
- Qt 6.10.1 installed locally.
- For VS 2022 preset, set `Qt6_DIR` to your Qt prefix (e.g., `C:\Qt\6.10.1\msvc2022_64`).
- For VS 2026 preset, set `THUB_QT_ROOT` to your Qt prefix (e.g., `C:\Qt\6.10.1\msvc2026_64`).

### VS 2022 (Command Line)
```powershell
# Open Developer PowerShell for VS 2022
$env:Qt6_DIR = 'C:\Qt\6.10.1\msvc2022_64'

# Configure & build (GUI + gateway)
cmake --preset vs2022-gui
cmake --build --preset vs2022-gui -v

# Terminal A: run the gateway server
& .\build_vs_gui\gateway\Release\gateway_app.exe
```
In a second terminal:
```powershell
# Terminal B: launch the GUI (talks to http://localhost:8080)
& .\build_vs_gui\gui\Release\gui_app.exe
```
Quick launch with `run_gui.ps1` (recommended):
```powershell
# One command: sets Qt runtime, waits for gateway health, bundles Qt DLLs
$env:Qt6_DIR = 'C:\Qt\6.10.1\msvc2022_64'
pwsh -File tools\run_gui.ps1 -ApiBase http://127.0.0.1:8080 -DeployLocal
```
Expected: GUI starts, Status shows current state. Click Start, then Stop; Status updates accordingly. If it can’t connect, confirm the gateway is running on port 8080.

### VS 2026 (Command Line)
```powershell
# Open Developer PowerShell for VS 2026
$env:THUB_QT_ROOT = 'C:\Qt\6.10.1\msvc2026_64'

# Configure & build (GUI + gateway)
cmake --preset vs2026-gui
cmake --build --preset vs2026-gui -v

# Terminal A: run the gateway server
& .\build_vs26\gateway\Release\gateway_app.exe
```
In a second terminal:
```powershell
# Terminal B: launch the GUI
& .\build_vs26\gui\Release\gui_app.exe
```

Notes
- You can also bundle dependencies with `windeployqt` for a self-contained folder if launching outside the build tree.
- The repo includes `tools/run_gui.ps1` as a helper; run it from a Developer PowerShell if you prefer a scripted launch.

### Qt Creator (MSVC 2022 Kit)
1) Open Qt Creator → File → Open File or Project → select the repository `CMakeLists.txt`.
2) When prompted for a kit, select “Desktop Qt 6.10.1 MSVC 2022 64-bit”. Ensure the Qt version points at `C:\Qt\6.10.1\msvc2022_64`.
3) Configure the project. Qt Creator will generate build files (you can map to the `vs2022-gui` Release configuration if desired).
4) Build the `gui_app` target.
5) Run `gateway_app` first (from the Projects pane or an external terminal), then run `gui_app`.

### Qt Creator (MSVC 2026 Kit)
1) Ensure a kit exists for MSVC 2026 with Qt 6.10.1 (Qt Creator → Preferences/Options → Kits). Point the Qt version to `C:\Qt\6.10.1\msvc2026_64`.
2) Open the project `CMakeLists.txt` and select this kit.
3) Configure and build the `gui_app` target (Release is recommended).
4) Run `gateway_app`, then run `gui_app` from Qt Creator.

If your Qt Creator version doesn’t provide a 2026 kit, use the 2022 kit or the command-line presets above.

### Qt Creator (No Visual Studio)
You can build and run the project entirely inside Qt Creator without relying on Visual Studio 2022/2026 generators. Use a Ninja-based kit (MSVC Build Tools or MinGW) and CMake.

Prerequisites
- Qt 6.10.1 installed (e.g., `C:\Qt\6.10.1\`)
- One of the following compilers configured in Qt Creator Kits:
  - MSVC Build Tools (x64) with Ninja
  - MinGW (x64) with Ninja
- CMake 3.23+ and Ninja available in PATH (Qt Creator usually bundles these)

Steps
1) Open Qt Creator → File → Open File or Project → select the repo `CMakeLists.txt`.
2) When prompted for a Kit, choose a Qt 6.10.1 kit that uses Ninja (e.g., “Desktop Qt 6.10.1 MinGW 64-bit” or “Desktop Qt 6.10.1 MSVC Build Tools 64-bit”).
3) In the Configure Project page:
	- Ensure “Build directory” is inside the repo (e.g., `build_qtcreator`).
	- Set CMake options:
	  - `-DBUILD_TESTING=ON`
	  - `-DBUILD_GUI=ON`
	  - If needed, add `-DCMAKE_PREFIX_PATH=<QtKitRoot>` (e.g., `C:\Qt\6.10.1\mingw_64` or `C:\Qt\6.10.1\msvc2022_64`).
4) Click “Configure Project”. Qt Creator will run CMake and generate Ninja files.
5) In the left pane (Projects/Targets), mark `gui_app` and `gateway_app` as build targets.
6) Build the project (hammer icon). Artifacts appear under the chosen build directory, e.g., `build_qtcreator\gui\<config>\gui_app.exe` and `build_qtcreator\gateway\<config>\gateway_app.exe`.
7) Run sequence:
	- First, run `gateway_app` (from the Run button or open a terminal and run it from the build folder).
	- Then, run `gui_app`. Set the environment variable `THUB_API_BASE` to `http://127.0.0.1:8080` in the Run configuration if you changed ports.
8) If `gui_app` cannot find Qt DLLs, either:
	- Add the kit’s `bin` folder to PATH in the Run configuration, or
	- Use `tools\run_gui.ps1 -DeployLocal` once to bundle Qt next to the exe, then run directly.

Notes
- MinGW vs MSVC: The project targets C++20 and doesn’t require MSVC-specific features in the GUI; either MinGW or MSVC Build Tools works. Keep `BUILD_GUI=ON` in CMake.
- Tests: You can add a Test configuration to run `ctest -V` from Qt Creator’s “Add Build Step → Custom Process Step”, or run tests in a terminal: `ctest --test-dir <build_qtcreator> --output-on-failure`.

See also
- `docs/verify_qt_gui.md` for a dedicated GUI verification guide.
- The Ninja preset `qtcreator-ninja` provides consistent CLI and Qt Creator behavior.
