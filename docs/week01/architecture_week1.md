High-level architecture

One paragraph on how device, gateway, gui, tests, tools fit together.

GatewayCore & threads

Explain the producer–consumer pattern:

Producer thread reads from Device, pushes to TelemetryQueue

Consumer thread pops from queue, processes samples (e.g. prints, sends to cloud)

Main thread runs monitoring loop and watches device state

Key interfaces / classes

Device / TelemetrySample

GatewayCore

TelemetryQueue

ICloudClient / RestCloudClient

Key design decisions

Why use a queue instead of calling cloud directly from the device thread

Why use interfaces (ICloudClient)

How you keep things testable (tests/test_device.cpp, tests/test_queue.cpp)