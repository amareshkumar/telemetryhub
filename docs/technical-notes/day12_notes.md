### Day 12 — Background Updates & Non-blocking UI

Goals
- Add a timer to periodically refresh status (every ~1s)
- Ensure HTTP calls run off the UI thread (async)
- Update labels with latest state/value
- Verify UI stays responsive while gateway is busy

Current State
- `MainWindow` uses `QTimer` with 1000 ms interval to call `onRefresh()`.
- `RestClient` is built on `QNetworkAccessManager` with signal/slot async; no blocking on the UI thread.
- UI updates are applied in callbacks via safe `QPointer<MainWindow>` guards.

Plan
- Keep `QTimer` at ~1s; ensure errors don’t spam the status bar.
- Confirm `RestClient` callbacks never block; avoid any `waitForFinished()`.
- Add minimal backoff on consecutive errors (optional) to reduce noise.
- Manual test: start gateway, open GUI, click Start/Stop while continuous refresh runs; ensure window remains responsive.

Interview Notes (Threading & Responsiveness)
- Qt’s GUI must be updated on the main thread; long tasks belong in worker threads or async I/O.
- `QNetworkAccessManager` is asynchronous by design; its signals fire on the thread owning the object (here: main/UI), but without blocking.
- Use `QPointer` or weak references for safety in async callbacks when widgets might be destroyed.
- Avoid blocking calls like `processEvents()` misuse or synchronous network calls; prefer timers, signals, and state machines.
- Backpressure: if updates are faster than the UI can render, coalesce updates (e.g., throttle with `QTimer` or use a single-flight request pattern).

Validation Checklist
- GUI remains interactive while status polls are active.
- Start/Stop transitions reflect within ~1–2s.
- Error paths (network down) show transient messages but don’t freeze UI.
- No blocking calls in `RestClient` or `MainWindow` handlers.
