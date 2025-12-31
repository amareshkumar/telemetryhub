# configure_fbuild.ps1 - FASTBuild Configuration Script for TelemetryHub
# This script sets up FASTBuild with CMake for distributed compilation

param(
    [string]$BuildType = "Release",
    [string]$Generator = "Visual Studio 17 2022",
    [switch]$EnableFastBuild = $false,
    [string]$WorkerList = "127.0.0.1",
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Usage: .\configure_fbuild.ps1 [OPTIONS]

Options:
  -BuildType <type>        Build type: Debug or Release (default: Release)
  -Generator <gen>         CMake generator (default: Visual Studio 17 2022)
  -EnableFastBuild         Enable FASTBuild .bff generation
  -WorkerList <workers>    Comma-separated list of worker IPs (default: 127.0.0.1)
  -Help                    Show this help message

Examples:
  # Configure with FASTBuild enabled
  .\configure_fbuild.ps1 -EnableFastBuild

  # Configure with remote workers
  .\configure_fbuild.ps1 -EnableFastBuild -WorkerList "192.168.1.10,192.168.1.11"

  # Build with FASTBuild after configuration
  fbuild -config build_vs26\fbuild.bff -dist -cache

More info: See docs/fastbuild_guide.md
"@
    exit 0
}

Write-Host "=== TelemetryHub FASTBuild Configuration ===" -ForegroundColor Cyan
Write-Host ""

# Check for FASTBuild installation
$fbuildPath = Get-Command fbuild -ErrorAction SilentlyContinue
if (-not $fbuildPath -and $EnableFastBuild) {
    Write-Host "WARNING: fbuild.exe not found in PATH" -ForegroundColor Yellow
    Write-Host "Download from: https://fastbuild.org/downloads" -ForegroundColor Yellow
    Write-Host "Continuing with CMake-only configuration..." -ForegroundColor Yellow
    $EnableFastBuild = $false
}

# Detect Qt installation
$qtPath = $env:THUB_QT_ROOT
if (-not $qtPath) {
    $qtPath = "C:\Qt\6.10.1\msvc2022_64"
    if (Test-Path $qtPath) {
        Write-Host "Found Qt at: $qtPath" -ForegroundColor Green
        $env:THUB_QT_ROOT = $qtPath
    } else {
        Write-Host "Qt not found. GUI will be disabled." -ForegroundColor Yellow
    }
}

# Configure CMake with FASTBuild support
$cmakeArgs = @(
    "--preset", "vs2026-gui",
    "-DTHUB_ENABLE_FASTBUILD=$($EnableFastBuild.ToString().ToLower())",
    "-DCMAKE_BUILD_TYPE=$BuildType"
)

Write-Host "Running CMake configuration..." -ForegroundColor Cyan
Write-Host "  Build Type: $BuildType"
Write-Host "  Generator: $Generator"
Write-Host "  FASTBuild: $EnableFastBuild"
if ($EnableFastBuild) {
    Write-Host "  Workers: $WorkerList"
}
Write-Host ""

& cmake @cmakeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: CMake configuration failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Configuration Complete ===" -ForegroundColor Green
Write-Host ""

if ($EnableFastBuild) {
    Write-Host "FASTBuild configuration generated at: build_vs26\fbuild.bff" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To build with FASTBuild:" -ForegroundColor Yellow
    Write-Host "  fbuild -config build_vs26\fbuild.bff -dist -cache" -ForegroundColor White
    Write-Host ""
    Write-Host "To build specific target:" -ForegroundColor Yellow
    Write-Host "  fbuild -config build_vs26\fbuild.bff gateway_app" -ForegroundColor White
    Write-Host ""
    Write-Host "To monitor build progress:" -ForegroundColor Yellow
    Write-Host "  fbuild -config build_vs26\fbuild.bff -dist -cache -monitor" -ForegroundColor White
} else {
    Write-Host "To build with MSBuild:" -ForegroundColor Yellow
    Write-Host "  cmake --build build_vs26 --config $BuildType -j8" -ForegroundColor White
}

Write-Host ""
Write-Host "For more information, see: docs/fastbuild_guide.md" -ForegroundColor Cyan
