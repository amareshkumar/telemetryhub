<#!
.SYNOPSIS
  Launch TelemetryHub GUI with Qt runtime configured and gateway health check.

.DESCRIPTION
  - Ensures Qt (msvc) runtime DLLs are discoverable by adding Qt\bin to PATH.
  - Starts the gateway if it's not already listening on the target API base.
  - Waits until /status responds, then launches the GUI.

.PARAMETER QtRoot
  Path to Qt MSVC kit root (e.g., C:\Qt\6.10.1\msvc2022_64 or msvc2026_64).
  Defaults to $env:Qt6_DIR (VS2022) then $env:THUB_QT_ROOT (VS2026). If not provided,
  attempts simple auto-detection under C:\Qt.

.PARAMETER ApiBase
  Base URL for the REST API. Default: http://127.0.0.1:8080

.PARAMETER GatewayExe
  Path to gateway executable. Default: build_vs26\\gateway\\Release\\gateway_app.exe (VS2026).
  If missing, falls back to build_vs_gui\\gateway\\Release\\gateway_app.exe (VS2022).

.PARAMETER GuiExe
  Path to GUI executable. Default: build_vs26\\gui\\Release\\gui_app.exe (VS2026).
  If missing, falls back to build_vs_gui\\gui\\Release\\gui_app.exe (VS2022).

.PARAMETER WaitTimeoutSec
  Seconds to wait for /status to become ready. Default: 20

.EXAMPLE
  pwsh -File tools/run_gui.ps1 -QtRoot C:\Qt\6.10.1\msvc2022_64 -ApiBase http://127.0.0.1:8080
#>

[CmdletBinding()]
param(
  [string]$QtRoot = $(if ($env:Qt6_DIR) { $env:Qt6_DIR } else { $env:THUB_QT_ROOT }),
  [string]$ApiBase = 'http://127.0.0.1:8080',
  [string]$GatewayExe = 'build_vs26\gateway\Release\gateway_app.exe',
  [string]$GuiExe = 'build_vs26\gui\Release\gui_app.exe',
  [int]$WaitTimeoutSec = 20,
  [switch]$DeployLocal
)

function Write-Info($msg){ Write-Host "[run_gui] $msg" }
function Fail($msg){ Write-Error $msg; exit 1 }

function UrlJoin([string]$base, [string]$rel){
  $b = $base.TrimEnd('/')
  $r = $rel.TrimStart('/')
  return "$b/$r"
}

# Resolve repo root
$repoRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName

# Auto-detect Qt if not provided
if (-not $QtRoot -or -not (Test-Path $QtRoot)) {
  Write-Info "QtRoot not provided or invalid. Trying to auto-detect under C:\\Qt..."
  $candidates = Get-ChildItem -Path 'C:\Qt' -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match 'msvc.*_64$' -and (Test-Path (Join-Path $_.FullName 'bin\Qt6Core.dll')) } |
    Sort-Object FullName -Descending
  if ($candidates) { $QtRoot = $candidates[0].FullName }
}
if (-not $QtRoot -or -not (Test-Path $QtRoot)) {
  Fail "Could not locate a valid Qt MSVC kit. Set -QtRoot or THUB_QT_ROOT."
}

# Prepare Qt runtime environment (PATH + plugin path) or deploy locally
$qtBin = Join-Path $QtRoot 'bin'
$qtPlugins = Join-Path $QtRoot 'plugins'
if (-not $DeployLocal) {
  $env:PATH = "$qtBin;$env:PATH"
  if (Test-Path $qtPlugins) { $env:QT_PLUGIN_PATH = $qtPlugins }
  Write-Info "Qt runtime configured from: $QtRoot"
}

# Ensure gateway is running/healthy
$gatewayFull = Join-Path $repoRoot $GatewayExe
# Fallback: if default path doesn't exist, try typical VS2022 GUI path
if (-not (Test-Path $gatewayFull)) {
  $fallback = Join-Path $repoRoot 'build_vs_gui\gateway\Release\gateway_app.exe'
  if (Test-Path $fallback) {
    $GatewayExe = 'build_vs_gui\gateway\Release\gateway_app.exe'
    $gatewayFull = $fallback
  }
}
$guiFull = Join-Path $repoRoot $GuiExe
if (-not (Test-Path $guiFull)) {
  $guiFallback = Join-Path $repoRoot 'build_vs_gui\gui\Release\gui_app.exe'
  if (Test-Path $guiFallback) {
    $GuiExe = 'build_vs_gui\gui\Release\gui_app.exe'
    $guiFull = $guiFallback
  }
}
if (-not (Test-Path $guiFull)) { Fail "GUI exe not found at $guiFull" }
if (-not (Test-Path $gatewayFull)) { Write-Info "Gateway exe not found at $gatewayFull (will only attempt to connect)." }

# If requested, deploy Qt DLLs next to the GUI so it can run standalone
if ($DeployLocal) {
  $windeployqt = @(
    (Join-Path $qtBin 'windeployqt6.exe'),
    (Join-Path $qtBin 'windeployqt.exe')
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $windeployqt) { Fail "windeployqt not found under $qtBin. Install Qt tools or unset -DeployLocal." }
  Write-Info "Deploying Qt runtime via: $windeployqt"
  & $windeployqt --release --compiler-runtime --verbose=1 "$guiFull" | Write-Host
}

# Check health
$healthy = $false
try {
  $null = Invoke-RestMethod -Uri (UrlJoin $ApiBase '/status') -TimeoutSec 2 -ErrorAction Stop
  $healthy = $true
} catch {}

if (-not $healthy -and (Test-Path $gatewayFull)) {
  Write-Info "Starting gateway..."
  Start-Process -FilePath $gatewayFull -ArgumentList @('--log-level','info') | Out-Null
  Start-Sleep -Seconds 1
}

# Wait for health
$deadline = (Get-Date).AddSeconds($WaitTimeoutSec)
while (-not $healthy -and (Get-Date) -lt $deadline) {
  try {
    $null = Invoke-RestMethod -Uri (UrlJoin $ApiBase '/status') -TimeoutSec 2 -ErrorAction Stop
    $healthy = $true
  } catch {
    Start-Sleep -Milliseconds 500
  }
}
if (-not $healthy) { Fail "Gateway did not become healthy at $ApiBase within $WaitTimeoutSec seconds." }

# Launch GUI with THUB_API_BASE
$env:THUB_API_BASE = $ApiBase
Write-Info "Launching GUI $guiFull"
Start-Process -FilePath $guiFull | Out-Null
Write-Host "GUI launched."
