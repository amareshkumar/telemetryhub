# Day 3 – State Machine & SafeState Notes

## State machine design in Device

States:
- Idle: device is not measuring; `read_sample()` returns no data.
- Measuring: device actively generates TelemetrySample periodically.
- Error: internal failure detected (e.g., after N samples).
- SafeState: latched safe state; device will not restart without external intervention.

Transitions:
- Idle -> Measuring: on `start()` (normal start).
- Measuring -> Idle: on `stop()` (normal stop).
- Measuring -> Error -> SafeState: fault detected while measuring.
- SafeState: `start()` and `stop()` calls are ignored, representing a latched fault.

## Why this is realistic for embedded/medical/industrial

- Many devices enter a safe-state after repeated or severe faults.
- Restart is intentionally not trivial (requires reset/service) to avoid unsafe behaviour.
- State machine makes behaviour explicit and testable.

## How I’d explain this in an interview

- “In TelemetryHub, I modeled the device as an explicit state machine with Idle/Measuring/Error/SafeState. While measuring, it simulates a fault after a number of samples and transitions into a SafeState, where further `start()` calls are ignored. This matches patterns I’ve seen in medical and industrial devices, where the system must fail safe and not silently continue after serious errors.”
