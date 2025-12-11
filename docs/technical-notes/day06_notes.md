# Day 6 – Unit Tests for Device & TelemetryQueue

## What I added

- Integrated GoogleTest via CMake FetchContent.
- Added unit_tests target with CTest integration.
- Tests for Device:
  - Starts in Idle.
  - start()/stop() transitions.
  - read_sample() only returns data in Measuring.
  - Fault path: after N samples → Error/SafeState.
  - SafeState is latched: start() does not recover.

- Tests for TelemetryQueue:
  - Single-thread push/pop order preserved.
  - After shutdown and empty queue, pop() returns std::nullopt.

## How I'd explain this in an interview

- "I wired up GoogleTest + CTest so I can run `ctest` for the whole project.
- The Device tests confirm the state machine behaves as expected, including a latched SafeState after faults.
- The TelemetryQueue tests validate the producer–consumer primitive: order is preserved and shutdown is handled cleanly so consumers can exit without hanging."
