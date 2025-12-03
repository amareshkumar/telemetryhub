# Requires: PowerShell, built gateway_app
# Steps:
# - Start gateway_app
# - Wait for it to listen
# - Validate /status, /start, /stop endpoints
# - Exit with code 0 on success, non-zero otherwise

$ErrorActionPreference = 'Stop'
$ciMode = $env:GITHUB_ACTIONS -eq "true"

# Resolve app path from build tree
$binRoot = "$PSScriptRoot" | Split-Path -Parent
# Prefer configured working dir if invoked directly under build root
if (-not (Test-Path "$binRoot/gateway/Debug/gateway_app.exe") -and -not (Test-Path "$binRoot/gateway/Release/gateway_app.exe")) {
  $binRoot = "$PWD"
}

# Try Release first, then Debug
$candidatePaths = @(
  (Join-Path $binRoot "gateway/Release/gateway_app.exe"),
  (Join-Path $binRoot "gateway/Debug/gateway_app.exe")
)
$appPath = $null
foreach ($p in $candidatePaths) {
  if (Test-Path $p) { $appPath = $p; break }
}
if (-not $appPath) {
  Write-Error "gateway_app.exe not found in Release or Debug under $binRoot"
}

# Start app
$proc = Start-Process -FilePath $appPath -PassThru -WindowStyle Hidden

# Wait for port up (allow slower CI boots)
$tn = $false
$deadline = [DateTime]::UtcNow.AddSeconds(15)
while ([DateTime]::UtcNow -lt $deadline) {
  # force IPv4 to avoid (::1) issues
  $tn = Test-NetConnection -ComputerName 127.0.0.1 -Port 8080 -InformationLevel Quiet
  if ($tn) { break }
  Start-Sleep -Milliseconds 250
}
if (-not $tn) {
  try { Stop-Process -Id $proc.Id -Force } catch {}
  Write-Error "Server did not start on port 8080"
}

try {
  # Status (parse JSON)
  $statusRaw = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8080/status | Select-Object -ExpandProperty Content
  if (-not $statusRaw) { throw "Empty status response" }
  $status = $statusRaw | ConvertFrom-Json
  if (-not $status.state) { throw "Missing 'state' in status JSON: $statusRaw" }

  if ($ciMode) {
    Write-Host "CI mode: running HTTP smoke test"

    # In CI, just ensure endpoints respond and basic flow works.

    $startResp = Invoke-WebRequest -UseBasicParsing -Method POST http://127.0.0.1:8080/start | Select-Object -ExpandProperty Content
    if ($startResp -notmatch '"ok":true') { throw "Start failed: $startResp" }

    $stopResp = Invoke-WebRequest -UseBasicParsing -Method POST http://127.0.0.1:8080/stop | Select-Object -ExpandProperty Content
    if ($stopResp -notmatch '"ok":true') { throw "Stop failed: $stopResp" }

    $srFinal = (Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8080/status | Select-Object -ExpandProperty Content) | ConvertFrom-Json
    $latestSeq =
      if ($null -ne $srFinal.latest_sample -and $srFinal.latest_sample.PSObject.Properties.Name -contains 'seq') {
        $srFinal.latest_sample.seq
      } else {
        "N/A"
      }

    Write-Host "CI HTTP integration smoke test passed: state=$($srFinal.state) latest_seq=$latestSeq"
    exit 0
  }
  else {
    Write-Host "Local mode: running full Measuring scenario"

    # Start and wait for Measuring (with one retry if SafeState)
    $attempts = 0
    $measuring = $false
    while ($attempts -lt 2 -and -not $measuring) {
      $attempts++
      $startResp = Invoke-WebRequest -UseBasicParsing -Method POST http://127.0.0.1:8080/start | Select-Object -ExpandProperty Content
      if ($startResp -notmatch '"ok":true') { throw "Start failed: $startResp" }

      $deadline2 = [DateTime]::UtcNow.AddSeconds(20)
      while ([DateTime]::UtcNow -lt $deadline2) {
        $srRaw = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8080/status | Select-Object -ExpandProperty Content
        $sr = $srRaw | ConvertFrom-Json

        $latestSeq =
          if ($null -ne $sr.latest_sample -and $sr.latest_sample.PSObject.Properties.Name -contains 'seq') {
            $sr.latest_sample.seq
          } else {
            "N/A"
          }

        Write-Host "state=$($sr.state) latest_seq=$latestSeq" -ForegroundColor DarkGray

        if ($sr.state -eq 'Measuring') { $measuring = $true; break }
        Start-Sleep -Milliseconds 250
      }
      if (-not $measuring) {
        Write-Host "Not Measuring after attempt $attempts; retrying start once..." -ForegroundColor Yellow
      }
    }
    if (-not $measuring) { throw "State did not become Measuring after start attempts" }

    # Stop and verify not Measuring
    $stopResp = Invoke-WebRequest -UseBasicParsing -Method POST http://127.0.0.1:8080/stop | Select-Object -ExpandProperty Content
    if ($stopResp -notmatch '"ok":true') { throw "Stop failed: $stopResp" }
    $sr2 = (Invoke-WebRequest -UseBasicParsing http://127.0.0.1:8080/status | Select-Object -ExpandProperty Content) | ConvertFrom-Json
    if ($sr2.state -eq 'Measuring') { throw "State still Measuring after stop" }

    Write-Host "HTTP integration test passed (full scenario)"
    exit 0
  }
}
catch {
  Write-Error "HTTP integration test failed: $_"
  exit 1
}
finally {
  try { Stop-Process -Id $proc.Id -Force } catch {}
}
