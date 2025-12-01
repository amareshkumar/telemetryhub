# Day 11 — GUI: Separating UI and Backend

This note documents how the Qt GUI (UI) is cleanly separated from the backend (REST API and Gateway), along with interview-ready talking points.

## High-level Separation

- UI (`gui/`): Widgets, layout, and presentation logic in `MainWindow`. No network or device control code lives here.
- Backend access: A thin `RestClient` in `gui/src/RestClient.{h,cpp}` encapsulates HTTP calls to `/status`, `/start`, `/stop`.
- Runtime gateway: `gateway_app` exposes the REST API (cpp-httplib). The GUI is a client of that API, same as any other tool.

This keeps responsibilities clear: the GUI renders state and sends simple commands, while the gateway handles the actual device state machine and telemetry pipeline.

## Design Principles (SOLID applied)

- Single Responsibility: UI updates labels/buttons; `RestClient` performs networking; gateway handles control/telemetry.
- Open/Closed: The UI can gain new widgets without changing how HTTP is performed; `RestClient` can add endpoints without changing the window.
- Liskov Substitution: `RestClient` could be swapped for a mock/test double with the same interface to simulate server behavior.
- Interface Segregation: `RestClient` exposes narrowly scoped methods (`getStatus`, `sendStart`, `sendStop`), not a generic, leaky transport.
- Dependency Inversion: UI depends on a small client interface (compile-time), not on concrete gateway internals.

## Explicit Boundaries

- Contract: REST HTTP JSON over `THUB_API_BASE` (default `http://127.0.0.1:8080`).
- Data Model: `/status` returns `{ "state": string, "latest_sample": { "seq": int, "value": double, "unit": string } | null }`.
- Commands: `/start` and `/stop` are `POST` with empty `{}` body; return `{ "ok": true }` on success.

The GUI never reaches into gateway/device headers; it only consumes this stable contract.

## Threading and Responsiveness

- Qt async I/O: `QNetworkAccessManager` is used with signals/slots.
- The UI thread never blocks on networking (no waits in slots).
- A `QTimer` triggers periodic refresh (1s). This is simple, predictable, and avoids coupling the UI to internal gateway events.

If later we need push updates, we can add server-sent events or WebSockets in a new client module, without changing how the UI renders state.

## Error Handling & Resilience

- `RestClient` maps network errors and HTTP failures to clear callbacks (success + error string).
- `MainWindow` surfaces transient errors in the status bar and keeps the UI usable.
- Button states derive from `/status`:
  - Idle → Start enabled, Stop disabled
  - Measuring → Start disabled, Stop enabled
  - Error/SafeState → both disabled
- Optimistic UX: After a successful `start/stop` call, buttons flip immediately; the next refresh confirms the persisted state.

## Testability Strategy

- Unit tests (device/queue/core) run under CTest/GoogleTest.
- REST integration test (PowerShell) boots `gateway_app`, calls `/status`, `/start`, `/stop`, and verifies state transitions. This validates the same contract the GUI uses.
- GUI compile-only in CI: A dedicated workflow installs Qt (MSVC kit) and builds `gui_app`. GUI functional tests can be added later with Qt Test or Squish; for now, the REST contract guards the most important behavior.

### Mocking the Client (for future unit tests)

- Define a small abstract interface (e.g., `IRestClient` with `getStatus/ sendStart/ sendStop`).
- Implement `RestClient : IRestClient` for production and a `FakeRestClient` for tests.
- The UI constructor can accept an `IRestClient*` (default to the real one). Then write Qt tests that simulate state transitions without a running server.

## Interview Talking Points (Concise)

- Boundary: The GUI is a client of a stable REST contract. It does not link to backend internals. This allows independent evolution and testing.
- SRP: Each layer has one reason to change — UI for presentation, client for transport, gateway for domain and state.
- Asynchrony: Use Qt’s async networking so the UI stays responsive; periodic refresh avoids hidden coupling.
- Error surfaces: Fail gracefully, inform users via status bar, and avoid inconsistent UI states with optimistic toggles validated by the next status poll.
- Testability: REST contract verified by CI integration test; device/queue/core covered by unit tests. GUI build is validated in CI with Qt install.
- Extensibility: Can add SSE/WebSockets later behind a new client module without touching UI widgets.

## How to Run Locally

- Build GUI using a preset (VS 2026) or the VS 2022 Qt kit in CI.
- Use `tools/run_gui.ps1` to set Qt PATH, start `gateway_app` if needed, and launch the GUI.

```powershell
$env:THUB_QT_ROOT = "C:\\Qt\\6.10.1\\msvc2022_64"
cmake --preset vs2026-gui
cmake --build --preset vs2026-gui
pwsh -File tools/run_gui.ps1 -ApiBase "http://127.0.0.1:8080"
```

## Future Enhancements

- Input validation hardening in the server (Day 10 extension): method checks, JSON body size limits, content-type enforcement, structured error responses, suspicious input logging.
- GUI improvements: base-URL selector, status color badges, last-error tooltip, and retry/backoff strategy.
- Expand CI: headless GUI smoke via Qt’s platform plugins or a minimal Qt Test to exercise `RestClient` with a mock server.
