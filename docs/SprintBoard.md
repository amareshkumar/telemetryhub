# TelemetryHub – 21-Day Sprint Board

## Legend
- [ ] = To do  
- [~] = In progress (update manually)  
- [x] = Done  

---

## High-Level Buckets

### Architecture & Core
- [ ] Device state machine (Idle/Measuring/Error/SafeState)
- [ ] TelemetryQueue producer–consumer
- [ ] GatewayCore threading model
- [ ] Config system (sampling interval, queue sizing, log level)
- [ ] Error handling & safe-state transitions

### Gateway & REST
- [ ] Local REST API (`/status`, `/start`, `/stop`)
- [ ] Input validation & logging
- [ ] Cloud client interface (`ICloudClient`) + dummy implementation

### GUI (Qt)
- [ ] Basic Qt window: state + value
- [ ] Start/Stop controls
- [ ] Periodic status refresh
- [ ] Non-blocking background work

### Embedded-ish & Robustness
- [ ] Simulated serial/UART driver
- [ ] Fault injection and safe-state logic
- [ ] Metrics & basic monitoring

### Tooling & Performance
- [ ] Unit tests (Device, queue, error flows)
- [ ] Perf harness & profiling
- [ ] CI-style scripts
- [ ] Docs & interview mapping

---

## Week 1 – Core Library, RAII, State Machine, Queue, Tests

### ✅ Day 1 – Repo, CMake, RAII (already done)

- [x] Create repo `telemetryhub/` and initialise git
- [x] Add base structure:
  - [x] `CMakeLists.txt` (top-level)
  - [x] `device/`, `device/include/telemetryhub/device`, `device/src`
  - [x] `tools/`, `docs/`
- [x] Add `device/CMakeLists.txt` to build `device` static library
- [x] Implement `FileHandle` RAII wrapper:
  - [x] Move-only (no copy)
  - [x] Automatically closes file in destructor
- [x] Add `raii_demo` executable in `tools/`:
  - [x] Open `telemetry_demo.log`
  - [x] Write a message
  - [x] Test move semantics of `FileHandle`
- [x] Build & run demo on at least one platform (Windows or WSL)
- [x] Write `docs/day01_notes.md` with:
  - [x] Short RAII explanation
  - [x] Why move-only
  - [x] How this maps to your past experience

---

### ✅ Day 2 – Device Class with pImpl (start tomorrow)

- [ ] Add `Device.h` + `Device.cpp`:
  - [ ] `enum class DeviceState { Idle, Measuring, Error, SafeState };`
  - [ ] `class Device` with pImpl (`std::unique_ptr<Impl>`)
  - [ ] Public API: `start()`, `stop()`, `state()`, `read_sample()`
- [ ] Add `TelemetrySample` struct (timestamp, value, unit, sequence_id)
- [ ] Implement basic constructor/destructor/move for `Device`
- [ ] Add a minimal console test (in `tools/` as `device_smoke.cpp`) that:
  - [ ] Creates `Device`
  - [ ] Prints initial state
- [ ] Build and run to confirm everything links and runs

**Interview note (Day 2):**
- [ ] `docs/day02_notes.md`: API vs ABI, why pImpl is useful (and where you’ve used it)

---

### Day 3 – State Machine Implementation (Idle/Measuring/Error/SafeState)

- [ ] Implement `Device::start()` and `Device::stop()` transitions:
  - [ ] `Idle -> Measuring` on `start()`
  - [ ] `Measuring -> Idle` on `stop()`
- [ ] Implement `read_sample()`:
  - [ ] Return `std::nullopt` unless in `Measuring`
  - [ ] Generate sample values (e.g. sine/noise)
  - [ ] Increment `sequence_id`
- [ ] Add basic error simulation:
  - [ ] Occasionally set state to `Error`
  - [ ] From `Error`, go to `SafeState`
- [ ] Extend console test to:
  - [ ] Start device, read a few samples, stop device
  - [ ] Print observed states

**Interview note (Day 3):**
- [ ] Add to `docs/day03_notes.md`: how you design state machines in embedded systems

---

### Day 4 – TelemetryQueue: Producer–Consumer

- [ ] Add `TelemetryQueue` class:
  - [ ] `push(const TelemetrySample&)`
  - [ ] `std::optional<TelemetrySample> pop()`
  - [ ] Use `std::mutex` + `std::condition_variable` + `std::queue`
- [ ] Small test utility (or main) to:
  - [ ] Start one producer thread pushing N samples
  - [ ] Start one consumer thread popping until done
  - [ ] Print basic log to stdout
- [ ] Check clean shutdown without deadlocks

**Interview note (Day 4):**
- [ ] Notes on data races, deadlocks, why condition variables

---

### Day 5 – GatewayCore Skeleton + Debugging Hooks

- [ ] Add `GatewayCore` class in `gateway/` with:
  - [ ] Owns `Device` and `TelemetryQueue`
  - [ ] `start()` to:
    - [ ] Start producer thread (polls `Device::read_sample()` and pushes to queue)
    - [ ] Start consumer thread (pops and stores `latest_sample`)
  - [ ] `stop()` to stop threads cleanly
  - [ ] `device_state()` and `latest_sample()` accessors
- [ ] Implement `main_gateway.cpp`:
  - [ ] Construct `GatewayCore`
  - [ ] Call `start()`
  - [ ] Wait for Enter key
  - [ ] Call `stop()`
- [ ] Intentionally add a small bug in debug build (e.g., wrong state check) and:
  - [ ] Use debugger to step through and inspect behaviour
  - [ ] Fix the bug

**Interview note (Day 5):**
- [ ] `docs/day05_notes.md`: small “bug story” and debugging steps

---

### Day 6 – Unit Tests: Device + Queue

- [ ] Add `tests/` folder with `CMakeLists.txt`
- [ ] Integrate GoogleTest (FetchContent or local):
  - [ ] `unit_tests` target
- [ ] `test_device.cpp`:
  - [ ] Test initial state is `Idle`
  - [ ] Test `start()` and `stop()` transitions
  - [ ] Test `read_sample()` only valid in `Measuring`
- [ ] `test_queue.cpp`:
  - [ ] Test single-thread push/pop
  - [ ] Optionally test simple multi-thread scenario
- [ ] Run `ctest` to confirm tests pass

**Interview note (Day 6):**
- [ ] Jot down how this reflects your Bosch/dGB TDD/CI experience

---

### Day 7 – Week 1 Architecture Doc

- [ ] Create `docs/architecture_week1.md`:
  - [ ] Explain `Device`, states, and sampling
  - [ ] Explain `TelemetryQueue` and producer–consumer
  - [ ] Explain `GatewayCore` threading model
- [ ] Draw a simple ASCII or Mermaid diagram of Week 1 flow:
  - [ ] Device → GatewayCore → Queue → GatewayCore.latest_sample
- [ ] Quick self-review (10–15 min): explain Week 1 aloud

---

## Week 2 – REST, Security, Qt GUI, Profiling

### Day 8 – ICloudClient Interface and Dummy Implementation

- [ ] Add `ICloudClient` interface:
  - [ ] `push_sample(const TelemetrySample&)`
  - [ ] `push_status(DeviceState)`
- [ ] Add `RestCloudClient` (dummy):
  - [ ] For now: just log JSON-like strings to console
- [ ] Make `GatewayCore` optionally hold a pointer/reference to `ICloudClient`
  - [ ] Call `push_sample()` every N samples

**Interview note (Day 8):**
- [ ] Explain why you hide REST/cloud behind an interface

---

### Day 9 – Local REST API (Status + Control)

- [ ] Choose minimal HTTP server tech (Poco or simple library/stub)
- [ ] Implement endpoints:
  - [ ] `GET /status` → returns device state + latest sample
  - [ ] `POST /start` → start device
  - [ ] `POST /stop` → stop device
- [ ] Integrate into `gateway_app`
  - [ ] GatewayApp runs HTTP server and `GatewayCore` together
- [ ] Manual test with `curl` or browser

**Interview note (Day 9):**
- [ ] Document API routes and example responses

---

### Day 10 – Input Validation & Basic Security Hygiene

- [ ] Validate `POST` requests:
  - [ ] Reject unknown actions
  - [ ] Handle malformed JSON/body cleanly
- [ ] Add simple logging mechanism:
  - [ ] Log every control request and outcome
  - [ ] Log errors and suspicious inputs
- [ ] Consider failure modes:
  - [ ] What happens if device fails while handling request?

**Interview note (Day 10):**
- [ ] Write core secure coding practices you applied here

---

### Day 11 – Qt GUI Skeleton

- [ ] Create `gui/` target:
  - [ ] `MainWindow` with:
    - [ ] Label: Device State
    - [ ] Label: Latest Value
    - [ ] Buttons: Start, Stop, Refresh
- [ ] Implement a thin C++ client to talk to REST API:
  - [ ] `get_status()`
  - [ ] `send_start()`, `send_stop()`
- [ ] Wire buttons to REST calls

**Interview note (Day 11):**
- [ ] Document how you separate UI and backend logic

---

### Day 12 – Background Updates & Non-blocking UI

- [ ] Add a timer to periodically refresh status (e.g., every 1s)
- [ ] Ensure HTTP calls run off the UI thread:
  - [ ] Use worker thread / async mechanism
- [ ] Update labels with latest state/value
- [ ] Verify UI stays responsive while gateway is busy

**Interview note (Day 12):**
- [ ] Notes on Qt threading and responsiveness

---

### Day 13 – Perf Harness & Simple Optimisation

- [ ] Add `perf_tool.cpp` under `tools/`:
  - [ ] Calls a “hot path” repeatedly (e.g., filtering / rolling average)
- [ ] Run profiler (perf/uProf/Valgrind or platform equivalent)
- [ ] Apply one small optimisation (e.g., reserve, avoid copies)
- [ ] Capture before/after runtime

**Interview note (Day 13):**
- [ ] Log numbers and connect to AMD/McAfee experience

---

### Day 14 – System Overview & Interview Dry-Run

- [ ] Create `docs/system_overview.md`:
  - [ ] Diagram: Device → GatewayCore → REST → GUI & Cloud
  - [ ] Threading overview
  - [ ] Error handling/safe-state overview
- [ ] Practise a 3–5 minute explanation of TelemetryHub as if to a hiring manager

---

## Week 3 – Embedded Flavour, Config, Metrics, CI, Polish

### Day 15 – Config System & Logging Improvements

- [ ] Add a config file (JSON/TOML/YAML/simple INI):
  - [ ] Sampling interval
  - [ ] Queue size
  - [ ] Log level
- [ ] Implement a small config loader
- [ ] Improve logging:
  - [ ] Include timestamps and severity
  - [ ] Respect log level (info/warn/error)

**Interview note (Day 15):**
- [ ] Notes on externalised configuration and environments

---

### Day 16 – Serial/UART Simulation

- [ ] Add `SerialPortSim` class:
  - [ ] Simulates read/write from a buffer or file
- [ ] Allow `Device` to respond to “commands” via simulated serial:
  - [ ] Example: “CALIBRATE”, “SET_RATE=1000”
- [ ] Optional: tool to send commands to the device through the simulator

**Interview note (Day 16):**
- [ ] Capture how this maps to real UART/I²C experiences

---

### Day 17 – Thread Pool & Metrics

- [ ] Implement a simple thread pool (in gateway):
  - [ ] Queue of jobs
  - [ ] N worker threads
- [ ] Use it for:
  - [ ] Processing telemetry samples (e.g., derived metrics)
- [ ] Add metrics:
  - [ ] Samples processed
  - [ ] Average processing time per sample

**Interview note (Day 17):**
- [ ] Write down trade-offs of adding a thread pool

---

### Day 18 – Robustness & Safe-State Logic

- [ ] Add fault injection to Device:
  - [ ] Random sensor errors
  - [ ] Communication failures
- [ ] Implement policy in GatewayCore:
  - [ ] After N failures → Device goes to SafeState
- [ ] Add tests for:
  - [ ] Error → SafeState transitions
  - [ ] Recovery behaviour (if any)

**Interview note (Day 18):**
- [ ] Explain safe-state in context of medical/industrial devices

---

### Day 19 – CI Scripts & YAML Skeleton

- [ ] Add `tools/run_ci.sh`:
  - [ ] Configure Release build
  - [ ] Build
  - [ ] Run tests
- [ ] Add `tools/run_ci.bat` for Windows
- [ ] Optional: add GitHub Actions / Azure DevOps YAML skeleton

**Interview note (Day 19):**
- [ ] Notes on how you’d scale this to a full CI pipeline

---

### Day 20 – Cleanup & README Polish

- [ ] Clean up:
  - [ ] Remove dead code
  - [ ] Ensure consistent naming and formatting
- [ ] Update README:
  - [ ] Build instructions
  - [ ] Run instructions for gateway and GUI
  - [ ] Short “Why I built TelemetryHub” story
- [ ] Tag a “v0.1” in git (local tag)

**Interview note (Day 20):**
- [ ] Summarise TelemetryHub as a portfolio piece (2–3 bullet points)

---

### Day 21 – Interview Mapping & Final Rehearsal

- [ ] Create/complete `docs/interview_mapping.md`:
  - [ ] Map each job experience (Bosch, McAfee, Priva, Movella, RR, Visteon, dGB) to:
    - [ ] Relevant TelemetryHub feature or pattern
    - [ ] At least one story you can tell
- [ ] Write 5–10 likely interview questions and bullet answers using TelemetryHub
- [ ] Do a 20–30 minute mock interview with yourself:
  - [ ] System design: TelemetryHub architecture
  - [ ] Debugging story
  - [ ] Performance story
  - [ ] Security/robustness story
  - [ ] Embedded/Qt story
- [ ] Mark any weak answers for another practice round later

---

## In Progress

- [ ] (Update this section as you work)

---

## Done

- [x] Day 1 – Repo bootstrap + RAII `FileHandle`
- [x] Day 2 – Device Class with pImpl
