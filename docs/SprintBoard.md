# TelemetryHub – Sprint Board

## Legend
- [ ] = To do
- [~] = In progress (change manually)
- [x] = Done

---

## Backlog

### Architecture & Core
- [ ] Clean up Device state machine transitions
- [ ] Add error injection and SafeState logic
- [ ] Add configuration loader (JSON/TOML) for sampling interval

### Gateway & REST
- [ ] Implement basic REST server with /status, /start, /stop
- [ ] Validate incoming commands and log invalid requests
- [ ] Add ICloudClient mock + dummy RestCloudClient

### GUI
- [ ] Basic Qt window with state + value labels
- [ ] Wire Start/Stop buttons to REST client
- [ ] Add timer to refresh status every 1s

---

## This Week (Focus)

### Day 1–3: Device & RAII
- [x] Create repo and base CMake structure
- [x] Implement FileHandle RAII wrapper
- [ ] Implement Device class with pImpl
- [ ] Implement basic Idle/Measuring/Error/SafeState transitions
- [ ] Add tiny console test driving Device

### Day 4–7: Queue, GatewayCore, Tests
- [ ] Implement TelemetryQueue (producer–consumer)
- [ ] Implement GatewayCore with producer/consumer threads
- [ ] Add unit tests for Device state transitions
- [ ] Add unit tests for TelemetryQueue push/pop
- [ ] Document Week 1 in docs/architecture_week1.md

---

## In Progress

- [~] Device state machine (Idle/Measuring/Error/SafeState)
- [~] GatewayCore threading model

---

## Done

- [x] Repo initialised
- [x] CMake top-level + device/ + tools/
- [x] RAII FileHandle + raii_demo utility
