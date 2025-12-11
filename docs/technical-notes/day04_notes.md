# Day 4 – TelemetryQueue (Producer–Consumer)

## Design

- TelemetryQueue is a thread-safe queue of TelemetrySample.
- Internals:
  - std::mutex + std::condition_variable + std::queue.
  - bool shutting_down_ flag to signal end-of-stream.

## Behaviour

- push():
  - Locks, pushes sample, notifies one waiting consumer.
  - Ignores pushes after shutdown (no new data after shutdown).

- pop():
  - Waits until:
    - queue is non-empty, or
    - shutting_down_ is true.
  - If shutdown && queue empty -> returns std::nullopt (end-of-stream).
  - Otherwise, pops and returns one sample.

- shutdown():
  - Sets shutting_down_ flag.
  - Notifies all waiting threads so they can exit cleanly.

## How I'd explain this

- “I implemented a TelemetryQueue using std::mutex, std::condition_variable, and a std::queue. It supports multiple producers and consumers, with a shutdown() call that cleanly unblocks pop() calls. I tested it with a small queue_smoke tool that has one producer thread and one consumer thread, similar to typical logging/telemetry queues in embedded and backend systems.”
