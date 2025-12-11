# Day 14 – Perf Harness & Simple Optimization

## Goals
- Add `perf_tool.cpp` under `tools/` that repeatedly exercises a hot path.
- Capture before/after runtime and basic throughput metrics.
- Apply one small optimisation (e.g., move instead of copy, reserve capacity, avoid temporary allocations).

## Plan
- Hot path focus: `TelemetryQueue::push/pop` with producer/consumer threads.
- Two runs:
  - Copy path: `push(const TelemetrySample&)`.
  - Move path: `push(TelemetrySample&&)` using `emplace(std::move(sample))`.
- Metrics: total ops, elapsed seconds, ops/sec, and computed speedup.
- Optional: write results to CSV for later comparison.

## Implementation Notes
- Added rvalue overload to `TelemetryQueue` to reduce copies on push.
- Created `tools/perf_tool.cpp` to run copy vs move scenarios with configurable N.
- Wired target `perf_tool` in `tools/CMakeLists.txt` linking `gateway_core`.

## How to Run (Windows, PowerShell)
```powershell
cmake --build "c:\code\telemetryhub\build_vs" --target perf_tool --config Release
"c:\code\telemetryhub\build_vs\tools\Release\perf_tool.exe" 2000000
```

## Interview Notes
- Log the measured numbers (ops, seconds, ops/sec) and the speedup.
- Connect the optimisation story to prior experience (AMD/McAfee):
  - Identify the bottleneck via profiling/measurement.
  - Apply minimal, targeted change (move semantics / allocation reduction).
  - Validate impact with before/after metrics and guard against regressions.
