# Verify REST Endpoints

This guide shows quick, copy-paste steps to verify the gateway’s HTTP server and the `/status`, `/start`, and `/stop` endpoints.

## Prerequisites
- Built binaries using the provided CMake presets (see README for details).
- Port `8080` available locally.

## Windows (PowerShell, local VS 2026)

1) Build via preset:
```powershell
cmake --preset vs2026-release
cmake --build --preset vs2026-release -v
```

2) Start server (background):
```powershell
$app = "${PWD}\build_vs26\gateway\Release\gateway_app.exe"
Start-Process -FilePath $app -PassThru -WindowStyle Hidden | Set-Variable proc
```

3) Wait for port 8080:
```powershell
$deadline = [DateTime]::UtcNow.AddSeconds(5)
do {
  $up = Test-NetConnection -ComputerName localhost -Port 8080 -InformationLevel Quiet
  Start-Sleep -Milliseconds 200
} while (-not $up -and [DateTime]::UtcNow -lt $deadline)
if (-not $up) { throw "Server did not start on port 8080" }
```

4) Exercise endpoints:
```powershell
# Status (pre-start)
(Invoke-WebRequest -UseBasicParsing http://localhost:8080/status).Content

# Start
(Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/start).Content

# Status (should show latest_sample once measuring)
(Invoke-WebRequest -UseBasicParsing http://localhost:8080/status).Content

# Stop
(Invoke-WebRequest -UseBasicParsing -Method POST http://localhost:8080/stop).Content
```

5) Cleanup:
```powershell
try { Stop-Process -Id $proc.Id -Force } catch {}
```

Quick automated check:
```powershell
ctest --preset vs2026-release -R http_integration --output-on-failure
```

## Linux (bash)

1) Build via preset:
```bash
cmake --preset linux-ninja-asan-ubsan
cmake --build --preset linux-ninja-asan-ubsan -v
```

2) Start server (background):
```bash
./build_asan/gateway/gateway_app > /tmp/gateway.log 2>&1 &
PID=$!
```

3) Wait for port 8080:
```bash
for i in {1..25}; do nc -z localhost 8080 && break; sleep 0.2; done
nc -z localhost 8080 || { echo "server not up"; kill $PID; exit 1; }
```

4) Exercise endpoints:
```bash
curl -s http://localhost:8080/status
curl -s -X POST http://localhost:8080/start
curl -s http://localhost:8080/status
curl -s -X POST http://localhost:8080/stop
```

5) Cleanup:
```bash
kill $PID || true
```

## Notes
- On Windows CI, runners use Visual Studio 2022 (`vs2022-release-ci` preset) but the steps above are equivalent.
- The HTTP server currently disables SSL and compression in `cpp-httplib` to keep builds dependency-light; HTTPS is not enabled.
