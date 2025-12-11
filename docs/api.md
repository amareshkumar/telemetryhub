# TelemetryHub REST API

## Base URL

```
http://localhost:8080
```

Default port is 8080. Override with `--port <port>` command-line argument.

---

## Endpoints

### GET /status

Returns current device state and latest telemetry sample.

**Request:**
```bash
curl http://localhost:8080/status
```

**Response:**
```json
{
  "state": "Measuring",
  "sample": {
    "sequence_id": 42,
    "value": 42.527,
    "unit": "arb.units",
    "timestamp": "2025-12-11T14:30:15Z"
  }
}
```

**Device States:**
- `Idle`: Device is ready but not measuring
- `Measuring`: Actively acquiring telemetry data
- `Error`: Device fault detected
- `SafeState`: Device has shut down safely after completing measurement cycle

**Sample Field:**
- May be `null` if no samples have been collected yet
- Updates continuously while device is in `Measuring` state
- Preserves last sample after stopping

**Status Codes:**
- `200 OK`: Success
- `500 Internal Server Error`: Gateway communication failure

---

### POST /start

Starts device measurement. Transitions device from `Idle` to `Measuring` state.

**Request:**
```bash
curl -X POST http://localhost:8080/start
```

**Response:**
```json
{
  "status": "started",
  "state": "Measuring"
}
```

**Behavior:**
- If already measuring: Returns current state (idempotent, no error)
- If in `Error` or `SafeState`: Cannot restart (returns error)
- Begins producer thread polling device
- Samples begin appearing in `/status` after ~100ms

**Status Codes:**
- `200 OK`: Successfully started (or already running)
- `400 Bad Request`: Device in terminal state (Error/SafeState)
- `500 Internal Server Error`: Failed to start device

---

### POST /stop

Stops device measurement. Transitions device from `Measuring` to `Idle` state.

**Request:**
```bash
curl -X POST http://localhost:8080/stop
```

**Response:**
```json
{
  "status": "stopped",
  "state": "Idle"
}
```

**Behavior:**
- Gracefully stops measurement and returns to `Idle`
- Producer/consumer threads shut down cleanly
- Queue is flushed (remaining samples processed)
- Last sample remains available in `/status`

**Status Codes:**
- `200 OK`: Successfully stopped (or already idle)
- `500 Internal Server Error`: Shutdown error

---

## Usage Examples

### cURL (Linux/macOS/Windows)

```bash
# Get current status
curl http://localhost:8080/status

# Start measurement
curl -X POST http://localhost:8080/start

# Poll for samples (repeat)
curl http://localhost:8080/status | jq '.sample'

# Stop measurement
curl -X POST http://localhost:8080/stop
```

### PowerShell (Windows)

```powershell
# Get status
Invoke-WebRequest -Uri http://localhost:8080/status | 
    Select-Object -ExpandProperty Content | ConvertFrom-Json

# Start measurement
Invoke-WebRequest -Method POST -Uri http://localhost:8080/start

# Stop measurement
Invoke-WebRequest -Method POST -Uri http://localhost:8080/stop
```

### Python

See `examples/rest_client_example.py` for a complete working example.

```python
import requests

BASE_URL = "http://localhost:8080"

# Get status
status = requests.get(f"{BASE_URL}/status").json()
print(f"State: {status['state']}")

# Start measurement
requests.post(f"{BASE_URL}/start")

# Poll for samples
import time
for _ in range(10):
    status = requests.get(f"{BASE_URL}/status").json()
    if status["sample"]:
        print(f"Sample: {status['sample']}")
    time.sleep(0.5)

# Stop
requests.post(f"{BASE_URL}/stop")
```

### JavaScript/TypeScript (Node.js)

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:8080';

async function main() {
  // Get status
  const status = await axios.get(`${BASE_URL}/status`);
  console.log('State:', status.data.state);
  
  // Start measurement
  await axios.post(`${BASE_URL}/start`);
  
  // Poll for samples
  for (let i = 0; i < 10; i++) {
    const status = await axios.get(`${BASE_URL}/status`);
    if (status.data.sample) {
      console.log('Sample:', status.data.sample);
    }
    await new Promise(r => setTimeout(r, 500));
  }
  
  // Stop
  await axios.post(`${BASE_URL}/stop`);
}

main();
```

---

## Error Handling

All endpoints return JSON error responses on failure:

```json
{
  "error": "Device in terminal state",
  "state": "SafeState"
}
```

**Common Error Scenarios:**
- **Connection refused**: Gateway not running
- **404 Not Found**: Invalid endpoint
- **500 Internal Server Error**: Gateway internal failure
- **Timeout**: Gateway hung (check logs)

**Debugging:**
- Check gateway logs: `gateway_app --log-level debug`
- Verify port: `netstat -an | grep 8080` (Linux) or `netstat -an | findstr 8080` (Windows)
- Test with verbose curl: `curl -v http://localhost:8080/status`

---

## Rate Limiting

**Current implementation:** No rate limiting.

**Recommended usage:**
- `/status` polling: 1-10 Hz (avoid excessive polling)
- `/start`, `/stop`: Low-frequency control commands

**Production considerations:**
- Add rate limiting middleware for exposed deployments
- Implement API keys for authentication
- Use WebSocket for real-time streaming (future enhancement)

---

## CORS

**Current implementation:** No CORS headers (localhost only).

**For web app integration:**
Add CORS middleware or configure reverse proxy (nginx, traefik).

---

## Future Enhancements

Planned API extensions:
- `GET /metrics`: Prometheus-format metrics (queue depth, drop rate, etc.)
- `GET /config`: Runtime configuration inspection
- `POST /config`: Dynamic configuration updates
- `GET /health`: Kubernetes-style health check endpoint
- `WebSocket /stream`: Real-time sample streaming
- Authentication: API key or JWT token support