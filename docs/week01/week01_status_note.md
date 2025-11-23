✅ Overall repo & tooling

Created the telemetryhub/ repo with a clean CMake structure:

CMakeLists.txt (top-level)

device/ for the simulated embedded device

tools/ for small demo/utility programs

docs/ for overview, sprint board, diagrams, notes

CMake is wired so:

device is a static library exporting device/include as a PUBLIC include path.

raii_demo and device_smoke link against device and use clean includes like:

#include "telemetryhub/device/Device.h"


You’ve also:

Added TelemtryHub overview README in docs.

Added a SprintBoard.md for your 21-day plan.

Created three extra Mermaid diagrams:

High level diagram flowchart.mmd

Telemetry Path.mmd

Control path.mmd

Installed VS Code Markdown/Mermaid extensions → so your docs + diagrams now feel like a real project portal.

✅ Day 1 – RAII foundation

Implemented telemetryhub::device::FileHandle:

RAII wrapper around FILE*.

Move-only, no copy.

Closes the file automatically in destructor.

Created raii_demo in tools/:

Opens telemetry_demo.log.

Writes a line.

Demonstrates move semantics (FileHandle f2 = std::move(f);).

This gave you:

A concrete C++ RAII example.

A nice small story for resource management in interviews.

✅ Day 2 – Device class with pImpl + TelemetrySample + smoke test

Defined TelemetrySample:

struct TelemetrySample {
    std::chrono::system_clock::time_point timestamp;
    double value;
    std::string unit;
    std::uint32_t sequence_id;
};


Implemented Device using pImpl:

Public API:

Device(int samples_before_fault = 8);

void start();

void stop();

DeviceState state() const;

std::optional<TelemetrySample> read_sample();

Internals hidden in Device::Impl in Device.cpp.

read_sample() generates a fake waveform (42 + sin + noise).

Created DeviceUtils.h with to_string(DeviceState) for pretty printing.

Added device_smoke tool:

Parses an optional CLI argument (num_samples).

Starts the device, reads samples in a loop, prints them.

This gives you:

A clean ABI-stable device interface.

A real example of using pImpl you can explain in interviews.

✅ Day 3 – Real state machine, fault & SafeState

Extended Device::Impl with:

DeviceState state (Idle / Measuring / Error / SafeState).

std::uint32_t sequence.

std::uint32_t samples_before_fault;

int error_count, int max_errors.

Device constructor now:

Device::Device(int samples_before_fault)
    : impl_(std::make_unique<Impl>())
{
    impl_->samples_before_fault = samples_before_fault;
}


State machine rules:

Idle -> Measuring on start() (resets sequence, error count).

Measuring -> Idle on stop().

While measuring:

read_sample() returns samples until sequence >= samples_before_fault.

Then triggers enter_error(), which sets Error and then SafeState after max errors.

In SafeState, start()/stop() effectively do nothing → latched safe-state.

Updated device_smoke:

Optional num_samples argument with default (e.g. 20).

Each loop:

Prints loop index, state, sample info or “no sample”.

When state becomes SafeState:

Attempts to restart.

Shows that state stays SafeState.

Finally calls stop() and prints final state.

This gives you:

A realistic safe-state model like industrial/medical devices.

A solid “mini story”: fault → safe-state → restart blocked.

And now you also have:

Docs + Mermaid diagrams + a sprint board in VS Code 🧠📈
→ You’re basically running a small product team of one.

