# Day 2 – Device + pImpl Notes

## pImpl: Why I used it in Device

- Keeps `Device`'s public header stable even if internal data changes.
- Reduces compile-time dependencies – consumers only see a pointer, not full internals.
- Helps with ABI stability if `Device` is part of a shared library.
- Makes it easier to hide implementation details (encapsulation).

## How I'd explain this in an interview

- “In TelemetryHub, the `Device` class uses the pImpl idiom: the header only exposes an opaque `Impl` pointer and the public API. Internals like RNG, sequence counters, config, etc. live in the `.cpp`. That means I can add fields or change the implementation without breaking users that are already compiled against the header, which is important for libraries and long-lived systems.”

## Device API design

- Methods: `start()`, `stop()`, `state()`, `read_sample()`.
- `read_sample()` returns `std::optional<TelemetrySample>`:
  - No sample if device is not measuring.
  - Clean, explicit representation of “no data”.
- State is an explicit enum, which will later grow behaviour for Error/SafeState.
