# TelemetryHub – Week 1 Interview Snippets

## 1. Explain TelemetryHub in 60 seconds

- A small C++ project I built to simulate an embedded telemetry device.
- It has:
  - A Device with an explicit state machine (Idle/Measuring/Error/SafeState).
  - A thread-safe TelemetryQueue.
  - A GatewayCore that runs producer/consumer threads and tracks the latest sample.
  - A couple of small tools (device_smoke, gateway_app) to drive and observe the system.
- It’s meant as a miniature version of the kind of systems I worked on in medical, automation and security products.

## 2. How does the Device state machine work?

- States: Idle, Measuring, Error, SafeState.
- start() from Idle:
  - Resets sequence, goes to Measuring.
- While Measuring:
  - read_sample() generates TelemetrySample (timestamp, value, unit, sequence_id).
  - After N samples, a simulated fault is injected.
  - Device transitions Measuring -> Error -> SafeState.
- SafeState is latched:
  - Further start() calls are ignored, representing a device that must be serviced/reset.

## 3. How do you move telemetry samples from the device to the application?

- Producer thread in GatewayCore:
  - Polls Device in Measuring state using read_sample().
  - Pushes samples into TelemetryQueue.
- TelemetryQueue:
  - Uses std::mutex + std::condition_variable + std::queue.
  - push() wakes consumers; shutdown() unblocks waiting pops.
- Consumer thread:
  - Pops samples and stores the latest one in GatewayCore.
- gateway_app:
  - Polls device_state() and latest_sample() and prints them to the console.

## 4. How do you handle shutdown and avoid deadlocks?

- GatewayCore::stop():
  - Sets running_ to false to stop the producer loop.
  - Calls queue_.shutdown() so consumer threads wake up and exit.
  - Calls device_.stop() if still in Measuring.
  - Joins both threads so no detached or zombie threads remain.
- I actually validated this by temporarily removing shutdown() and observing that the consumer blocked forever on pop(), then fixing it.

## 5. What testing do you have?

- Device tests:
  - Verify initial state, start/stop transitions, and sample generation in Measuring.
  - Test fault behaviour and that SafeState is latched.
- TelemetryQueue tests:
  - Single-threaded push/pop.
  - Shutdown behaviour (pop() returns nullopt when empty+shutdown).
  - One producer and one consumer concurrently pushing/popping 100 samples.
- All tests are integrated via GoogleTest + CTest so I can run them with a single ctest command.
