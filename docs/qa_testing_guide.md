# QA Testing Guide - Robustness & Fault Recovery Features

**Target Audience:** QA Engineers, Manual Testers, Non-Developers  
**Feature:** Day 18 - Fault Injection and Recovery Mechanisms  
**Version:** 1.0  
**Date:** December 23, 2025

---

## Overview

This guide explains how to test the new **robustness features** added to TelemetryHub. These features make the system more reliable by:
1. Simulating sensor failures to test error handling
2. Automatically stopping when too many errors occur (circuit breaker)
3. Allowing manual recovery from error states

**No coding knowledge required** - all testing is done through REST API calls and command-line tools.

---

## Prerequisites

### Required Software
- ✅ **Web browser** (Chrome, Firefox, Edge) OR **Postman/Insomnia**
- ✅ **PowerShell** (comes with Windows)
- ✅ **TelemetryHub built** (ask developer to run build if needed)

### Starting the Gateway Application
```powershell
# Open PowerShell and navigate to project folder
cd C:\code\telemetryhub\build_vs_ci\gateway\Release

# Start the gateway server
.\gateway_app.exe
```

**Expected Output:**
```
[INFO] Gateway started on http://localhost:8080
[INFO] REST API ready at /start, /stop, /status
```

**Keep this window open** - the gateway must run during testing.

---

## Test Scenarios

### Scenario 1: Normal Operation (No Faults) ✅

**Objective:** Verify system works correctly without any injected faults.

**Steps:**
1. Open web browser
2. Navigate to: `http://localhost:8080/start`
3. Wait 5 seconds
4. Navigate to: `http://localhost:8080/status`

**Expected Result:**
```json
{
  "status": "measuring",
  "device_state": "Measuring",
  "samples_processed": 50,
  "metrics": {
    "samples_dropped": 0
  }
}
```

**✅ PASS Criteria:**
- `device_state` is `"Measuring"`
- `samples_processed` increases over time
- `samples_dropped` is 0

**❌ FAIL Criteria:**
- `device_state` is `"SafeState"` or `"Error"`
- `samples_processed` stays at 0

---

### Scenario 2: Random Sensor Failures 🎲

**Objective:** Test system handles intermittent sensor glitches gracefully.

**Configuration:**
Edit `config.ini` file (in same folder as `gateway_app.exe`):
```ini
[Device]
fault_injection_mode = RandomSensorErrors
error_probability = 0.2
max_consecutive_failures = 5
```

**Steps:**
1. Stop gateway if running (Ctrl+C in PowerShell window)
2. Edit `config.ini` as shown above
3. Restart: `.\gateway_app.exe`
4. Start measurement: `http://localhost:8080/start`
5. Monitor for 10 seconds: `http://localhost:8080/status` (refresh multiple times)

**Expected Result:**
- Some samples fail randomly (~20% based on `error_probability`)
- System continues running (doesn't stop)
- After several successful samples, failure counter resets

**✅ PASS Criteria:**
- Gateway stays in `"measuring"` status
- Some failures logged in console (see PowerShell window)
- System doesn't enter `"SafeState"` unless 5 failures happen consecutively

**❌ FAIL Criteria:**
- System enters `"SafeState"` immediately
- No failures occur (check config was applied)
- System crashes

**Example Console Log (PowerShell Window):**
```
[INFO] Read failed, consecutive failures: 1
[INFO] Sample collected successfully
[INFO] Read failed, consecutive failures: 1
[INFO] Sample collected successfully
```

---

### Scenario 3: Circuit Breaker Trigger 🔴

**Objective:** Verify system enters safe state after too many consecutive failures.

**Configuration:**
Edit `config.ini`:
```ini
[Device]
fault_injection_mode = RandomSensorErrors
error_probability = 0.9
max_consecutive_failures = 5
```

**Steps:**
1. Restart gateway with updated config
2. Start measurement: `http://localhost:8080/start`
3. Wait 3-5 seconds
4. Check status: `http://localhost:8080/status`

**Expected Result:**
```json
{
  "status": "stopped",
  "device_state": "SafeState",
  "samples_processed": 5,
  "metrics": { ... }
}
```

**Console Log:**
```
[ERROR] Read failed, consecutive failures: 1
[ERROR] Read failed, consecutive failures: 2
[ERROR] Read failed, consecutive failures: 3
[ERROR] Read failed, consecutive failures: 4
[ERROR] Read failed, consecutive failures: 5
[CRITICAL] Circuit breaker triggered - stopping device
```

**✅ PASS Criteria:**
- Device enters `"SafeState"` after 5 consecutive failures
- Gateway status becomes `"stopped"`
- Console shows "Circuit breaker triggered" message

**❌ FAIL Criteria:**
- System continues running despite failures
- Device crashes instead of entering safe state
- No console logs

---

### Scenario 4: Manual Recovery (Reset) 🔄

**Objective:** Test that operators can manually recover device from safe state.

**Prerequisites:** Complete Scenario 3 first (device in SafeState)

**Steps Using Browser:**
1. Verify device in SafeState: `http://localhost:8080/status`
2. Send reset command:
   - Open new browser tab
   - Navigate to: `http://localhost:8080/reset` (use POST method)

**Steps Using PowerShell:**
```powershell
# Open new PowerShell window (keep gateway running)
Invoke-WebRequest -Uri http://localhost:8080/reset -Method POST
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Device reset successfully"
}
```

3. Check status again: `http://localhost:8080/status`

**Expected Result:**
```json
{
  "status": "stopped",
  "device_state": "Idle",
  "samples_processed": 0
}
```

**✅ PASS Criteria:**
- Device transitions from `"SafeState"` → `"Idle"`
- `samples_processed` resets to 0
- Can call `/start` again to resume measurement

**❌ FAIL Criteria:**
- Reset fails with error message
- Device stays in `"SafeState"`
- Cannot restart measurement after reset

---

### Scenario 5: Invalid Reset (Negative Test) ❌

**Objective:** Verify reset is blocked when device is running or in normal state.

**Test Case A: Reset While Running**

**Steps:**
1. Start measurement: `http://localhost:8080/start`
2. Try to reset: `Invoke-WebRequest -Uri http://localhost:8080/reset -Method POST`

**Expected Response:**
```json
{
  "success": false,
  "error": "Gateway must be stopped before reset"
}
```

**✅ PASS:** Reset blocked with error message  
**❌ FAIL:** Reset succeeds (dangerous - could reset running system)

---

**Test Case B: Reset from Idle State**

**Steps:**
1. Ensure device is idle (never started)
2. Try to reset: `Invoke-WebRequest -Uri http://localhost:8080/reset -Method POST`

**Expected Response:**
```json
{
  "success": false,
  "error": "Device must be in SafeState or Error to reset"
}
```

**✅ PASS:** Reset blocked (no need to reset already-idle device)  
**❌ FAIL:** Reset succeeds

---

### Scenario 6: Communication Failures 📡

**Objective:** Test system handles serial port/network communication timeouts.

**Configuration:**
Edit `config.ini`:
```ini
[Device]
fault_injection_mode = CommunicationFailure
error_probability = 0.3
max_consecutive_failures = 5
```

**Steps:**
1. Restart gateway with updated config
2. Start measurement: `http://localhost:8080/start`
3. Monitor status every 2 seconds for 20 seconds

**Expected Console Log:**
```
[WARN] Communication timeout - no data from sensor bus
[WARN] Communication timeout - no data from sensor bus
[INFO] Communication restored
```

**✅ PASS Criteria:**
- Random communication timeouts occur
- System recovers automatically after timeout clears
- If 5 consecutive timeouts, enters SafeState (same as Scenario 3)

---

### Scenario 7: Combined Failures (Both Modes) ⚡

**Objective:** Test system handles both sensor errors AND communication failures.

**Configuration:**
```ini
[Device]
fault_injection_mode = Both
error_probability = 0.2
max_consecutive_failures = 5
```

**Expected Behavior:**
- Mix of sensor read failures and communication timeouts
- System should handle both types gracefully
- Circuit breaker triggers on either type reaching threshold

---

## Automated Test Suite

For regression testing, developers provide an automated test suite:

```powershell
cd C:\code\telemetryhub\build_vs_ci\tests\Release
.\unit_tests.exe --gtest_filter=RobustnessTests.*
```

**Expected Output:**
```
[==========] Running 15 tests from 1 test suite.
...
[  PASSED  ] 15 tests.
```

**QA Note:** If automated tests pass but manual tests fail, check configuration files.

---

## Test Matrix

| Scenario | Fault Mode | Error Rate | Expected Outcome | Pass/Fail |
|----------|-----------|------------|------------------|-----------|
| 1. Normal | None | 0% | Continuous measurement | ☐ |
| 2. Random Errors | RandomSensorErrors | 20% | Intermittent failures, no SafeState | ☐ |
| 3. Circuit Breaker | RandomSensorErrors | 90% | SafeState after 5 failures | ☐ |
| 4. Reset Success | N/A | N/A | SafeState → Idle | ☐ |
| 5A. Reset Blocked (Running) | N/A | N/A | Error response | ☐ |
| 5B. Reset Blocked (Idle) | N/A | N/A | Error response | ☐ |
| 6. Comm Failures | CommunicationFailure | 30% | Timeouts with recovery | ☐ |
| 7. Combined | Both | 20% | Both failure types | ☐ |

---

## Configuration Reference

### Fault Injection Modes
- `None` - Production mode (no faults)
- `RandomSensorErrors` - Simulate bad sensor reads
- `CommunicationFailure` - Simulate bus/network timeouts
- `Both` - Simulate both types

### Error Probability
- Range: `0.0` to `1.0`
- `0.2` = 20% chance of failure per sample
- `0.5` = 50% chance (coin flip)
- `1.0` = 100% (always fails)

### Max Consecutive Failures (Circuit Breaker Threshold)
- Default: `5`
- Range: `1` to `100`
- Recommendation: 3-10 for testing, 5-15 for production

---

## Troubleshooting

### Gateway Won't Start
**Error:** `Address already in use: 0.0.0.0:8080`

**Solution:**
```powershell
# Kill existing gateway process
Get-Process gateway_app -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Cannot Access REST API
**Error:** Browser shows "Connection refused"

**Solution:**
1. Check gateway is running (PowerShell window should show logs)
2. Verify port: `http://localhost:8080` (not 8081, 8082)
3. Check firewall isn't blocking port 8080

### Config Changes Not Applied
**Solution:**
1. Stop gateway (Ctrl+C)
2. Verify `config.ini` saved correctly
3. Restart gateway
4. Confirm logs show new config values

### Tests Pass But Manual Testing Fails
**Root Cause:** Automated tests use in-memory device, manual testing uses real config

**Solution:**
1. Check `config.ini` exists in gateway folder
2. Verify configuration syntax (no typos)
3. Check logs for config parsing errors

---

## Reporting Bugs

When reporting issues, provide:
1. **Scenario number** (e.g., "Scenario 3 failed")
2. **Configuration** (`config.ini` contents)
3. **Console logs** (copy from PowerShell window)
4. **API responses** (copy JSON from browser)
5. **Expected vs Actual** behavior

**Example Bug Report:**
```
Title: Circuit breaker doesn't trigger after 5 failures

Scenario: 3 (Circuit Breaker Trigger)
Config:
  fault_injection_mode = RandomSensorErrors
  error_probability = 0.9
  max_consecutive_failures = 5

Expected: Device enters SafeState after 5 consecutive failures
Actual: Device continues running after 10+ failures

Console Log:
[ERROR] Read failed, consecutive failures: 1
[ERROR] Read failed, consecutive failures: 2
... (paste logs)

Status Response:
{ "status": "measuring", "device_state": "Measuring" }
```

---

## Success Criteria Summary

✅ **All 7 scenarios pass**  
✅ **Automated tests pass** (`unit_tests.exe`)  
✅ **No crashes or hangs**  
✅ **Logs show expected error messages**  
✅ **Configuration changes take effect**  
✅ **Reset works only when appropriate**  
✅ **System recovers after reset and resumes measurement**

---

## Appendix: REST API Quick Reference

| Endpoint | Method | Purpose | Expected Response |
|----------|--------|---------|-------------------|
| `/start` | POST | Begin measurement | `{"status": "measuring"}` |
| `/stop` | POST | Stop measurement | `{"status": "stopped"}` |
| `/status` | GET | Check current state | `{"status": "...", "device_state": "..."}` |
| `/reset` | POST | Recover from SafeState | `{"success": true}` |
| `/metrics` | GET | Get performance stats | `{"samples_processed": 123, ...}` |

---

**Questions?** Contact development team or see `docs/day18_progress.md` for technical details.
