# TelemetryHub – Week 1 Architecture (Device + Queue + GatewayCore)

## 1. Scope of Week 1

This document describes the architecture of TelemetryHub as of the end of Week 1 (Day 1–6):

- RAII resource handling for file handles.
- Simulated device with explicit state machine and fault + SafeState.
- Thread-safe telemetry queue.
- GatewayCore with producer/consumer threads and latest_sample.
- Tools for manual exploration (raii_demo, device_smoke, queue_smoke, gateway_app).
- Initial unit tests for Device and TelemetryQueue.

## 2. Modules and Responsibilities

### 2.1 device/ (Device library)

- **Device**
  - Public API:
    - `start()`, `stop()`
    - `state() -> DeviceState`
    - `read_sample() -> std::optional<TelemetrySample>`
  - Uses pImpl to hide internal fields and keep ABI stable.
  - Encapsulates the DeviceState state machine.
- **Device::Impl**
  - Fields:
    - `DeviceState state`
    - `sequence`
    - `samples_before_fault`
    - `error_count`, `max_errors`
    - RNG + noise for fake signal.
  - Behaviour:
    - Generates TelemetrySample (42 + sin + noise).
    - After N samples, injects a fault -> Error -> SafeState.
- **DeviceState**
  - `Idle`, `Measuring`, `Error`, `SafeState`.
- **TelemetrySample**
  - `timestamp`, `value`, `unit`, `sequence_id`.
- **FileHandle**
  - RAII wrapper around `FILE*`.
  - Move-only, closes in destructor.
- **DeviceUtils**
  - `to_string(DeviceState)` for logging.

### 2.2 gateway/ (Gateway library)

- **TelemetryQueue**
  - Thread-safe queue of TelemetrySample.
  - API:
    - `push(const TelemetrySample&)`
    - `pop() -> std::optional<TelemetrySample>`
    - `shutdown()`
  - Internals:
    - `std::mutex`, `std::condition_variable`, `std::queue<TelemetrySample>`.
    - `shutting_down_` flag to signal end-of-stream.
- **GatewayCore**
  - Owns:
    - `Device device_`
    - `TelemetryQueue queue_`
  - Threads:
    - Producer thread:
      - Reads samples from Device while Measuring.
      - Pushes into TelemetryQueue.
      - Exits when Device enters SafeState or Error.
    - Consumer thread:
      - Pops from TelemetryQueue.
      - Updates `latest_` sample.
      - Exits when queue shutdown and empty.
  - Public API:
    - `start()`, `stop()`
    - `device_state()`
    - `latest_sample()`.

## 3. Tools / Executables

### 3.1 raii_demo

- Purpose: demonstrate RAII via FileHandle.
- Behaviour:
  - Opens `telemetry_demo.log`.
  - Writes a line or two.
  - Shows move-only semantics (moving FileHandle).

### 3.2 device_smoke

- Purpose: exercise Device state machine from the command line.
- Behaviour:
  - Optional CLI arg: `number_of_samples`.
  - Starts Device, reads samples in a loop.
  - Prints DeviceState and samples.
  - Demonstrates transition to SafeState and failed restart attempt.

### 3.3 queue_smoke

- Purpose: exercise TelemetryQueue with producer + consumer threads.
- Behaviour:
  - Producer pushes N synthetic samples and calls `shutdown()`.
  - Consumer pops until it receives `std::nullopt`.
  - Demonstrates clean termination (no deadlock).

### 3.4 gateway_app

- Purpose: run GatewayCore as a mini telemetry service.
- Behaviour:
  - Starts GatewayCore, which starts Device and threads.
  - Periodically prints DeviceState and latest sample (#sequence, value, unit).
  - When Device reaches SafeState, breaks monitoring loop and stops core.
  - Shows clean shutdown of producer/consumer threads.

## 4. Data & Control Flow (Week 1)

### 4.1 Telemetry path (data flow)

- `Device` generates `TelemetrySample` in Measuring state.
- Producer thread in `GatewayCore` calls `Device::read_sample()`.
- Samples are pushed into `TelemetryQueue`.
- Consumer thread pops samples and updates `latest_`.
- `gateway_app` calls `GatewayCore::latest_sample()` to display data.

### 4.2 Control path (start/stop & faults)

- `gateway_app`:
  - Calls `GatewayCore::start()`:
    - Starts Device (Idle -> Measuring).
    - Launches producer and consumer threads.
  - Polls `GatewayCore::device_state()`:
    - As long as state is Measuring, continues monitoring.
    - When state is SafeState, breaks and calls `GatewayCore::stop()`.
- Fault behaviour:
  - After `samples_before_fault` samples, Device injects a fault.
  - Device transitions Measuring -> Error -> SafeState.
  - Producer sees SafeState and exits its loop.
  - `stop()` calls `queue_.shutdown()` and `device_.stop()`, joining both threads.

## 5. Testing (Day 6)

- **Device tests**:
  - Initial state is Idle.
  - `start()` from Idle -> Measuring.
  - `stop()` from Measuring -> Idle.
  - `read_sample()` returns data only in Measuring.
  - After N samples (small threshold), Device transitions to Error/SafeState.
  - SafeState is latched; `start()` does not recover to Measuring.
- **TelemetryQueue tests**:
  - Push/pop order preserved in single-thread case.
  - After `shutdown()` and an empty queue, `pop()` returns `std::nullopt`.
  - Single-producer/single-consumer concurrent test:
    - Producer pushes total_samples then calls shutdown().
    - Consumer pops until `nullopt`.
    - Produced == consumed == total_samples.

## 6. Design Motivations (Talking Points)

- pImpl in Device to keep ABI stable and hide implementation details.
- Explicit DeviceState enum and SafeState to model real embedded fault handling.
- TelemetryQueue as a minimal, testable producer–consumer primitive.
- GatewayCore as a thin orchestration layer separating:
  - hardware-ish behaviour (Device),
  - threading/queue concerns (TelemetryQueue),
  - presentation (CLI for now, REST/GUI later).

## 7. Next Steps (Week 2 Preview)

- Expose GatewayCore via a small REST API (`/status`, `/start`, `/stop`).
- Add GUI client (Qt) on top of REST.
- Add simple input validation and logging for control commands.
- Profile a hot path (e.g., sample processing loop) and document gains.
