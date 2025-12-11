**Scope & Goals**
- Build a thin Qt6 GUI for a C++20 telemetry gateway.
- Integrate REST (/status, /start, /stop) via a minimal client.
- Make local runs frictionless and CI guardrails reliable.

**Architecture**
- GUI: Qt6 Widgets + Network; single-window `MainWindow` with Start/Stop/Refresh and 1s auto-refresh.
- Client: `RestClient` uses `QNetworkAccessManager` async calls, returns `QJsonObject`/bool+error.
- Backend contract: REST endpoints return `state` and optional `latest_sample`. GUI is intentionally dumb: no device logic in UI, only reflect server state.

**Key Design Decisions**
- Separation of concerns: UI consumes REST; no shared headers beyond data shape assumptions. Enables independent iteration of backend.
- Optimistic toggles: After a successful start/stop POST, UI toggles buttons immediately, then reconciles on the next `/status` poll. Improves UX; errors re-enable buttons.
- Defensive async: Use `QPointer<MainWindow>` in callbacks to avoid use-after-free when closing the window mid-request.
- Version guardrail: Pin Qt to 6.10.1. `find_package(Qt6 6.10.1 ...)` fails fast if mismatched. CI job verifies `Qt6_DIR`/`qtpaths`.

**Tooling & Presets**
- CMakePresets: 
  - `vs2026-gui`: enables `BUILD_GUI`, uses `THUB_QT_ROOT` for `CMAKE_PREFIX_PATH`.
  - `vs2022-gui`: same idea with `Qt6_DIR` (CI-oriented).
  - Non-GUI presets on Linux/Windows set `BUILD_GUI=OFF` to avoid Qt detection in standard test runs.
- Scripts:
  - run_gui.ps1: 
    - Sets Qt PATH/plugins, health-check `/status`, starts gateway if present.
    - `-DeployLocal` runs `windeployqt` so EXE can run standalone.
    - Fallback detects gateway path in build_vs26 or `build_vs_gui`.
  - clean_reconfigure.ps1: Purges build dirs, reconfigures a preset cleanly.

**CI/Verification**
- Windows CI (non-GUI): Builds/tests with `BUILD_GUI=OFF`.
- Windows GUI CI job:
  - Installs Qt (probe via `aqt list-qt` and fallback to 6.10.0 if 6.10.1 arch unavailable).
  - Builds GUI, runs `windeployqt`, uploads `gui_app_windows_bundle` artifact.
- HTTP integration test (PowerShell):
  - Boots `gateway_app`, checks `/status`, POST `/start`, waits for `Measuring`, POST `/stop`, ensures not `Measuring`.
  - Stabilization: Increased port wait and measuring window; single retry on SafeState.

**Notable Fixes**
- PowerShell URL joining: Replaced filesystem `Join-Path` misuse with `UrlJoin`.
- Qt `__cplusplus`: Enabled `/Zc:__cplusplus` for MSVC to satisfy Qt checks.
- Lambda capture bug: Ensured lambdas don’t implicitly use `this`; used `QPointer self->...`.
- Flaky integration timing: Increased waits, added interim state logging to aid diagnosis.

**Trade-offs & Rationale**
- GUI simplicity over feature-richness: Minimal controls + constant polling keep complexity low and highlight contract clarity.
- DeployLocal vs global Qt runtime: Prioritized developer/reviewer experience; artifact can run without Qt install.
- CI resilience: Probe and fallback for Qt versions avoids brittle failures due to mirror/metadata variability.

**How to Demo Quickly**
- Build with `vs2026-gui`, run launcher, click Start/Stop, confirm REST via `Invoke-WebRequest`.
- Show `gui_app_windows_bundle` artifact running standalone.
- Run `ctest -R http_integration` and point to stabilization logs if needed.

**Future Enhancements**
- UI base-URL selector and status color-coding.
- Error envelope and device failure surfacing in `/status`.
- Structured logging and telemetry for GUI actions (user, timing, outcomes).
- Add Linux GUI job using Qt packages or containerized Qt build, if desired.

This captures the intent, engineering choices, and operational reliability work around Qt GUI, REST integration, and CI hardening.