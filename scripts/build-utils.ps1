# ══════════════════════════════════════════════════════════════════════
# TelemetryHub - Build & Development Utilities
# Consolidated build, test, and development automation
# ══════════════════════════════════════════════════════════════════════

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('clean-reconfigure', 'run-gui', 'render-diagrams', 
                 'configure-fastbuild', 'help')]
    [string]$Task,
    
    [string]$Preset = "vs2026-release",
    [string]$QtRoot = $env:THUB_QT_ROOT,
    [string]$ApiBase = "http://127.0.0.1:8080",
    [int]$WaitTimeoutSec = 40,
    [switch]$DeployLocal,
    [switch]$RemoveRootCache,
    [switch]$EnableFastBuild,
    [switch]$Chatty
)

# ══════════════════════════════════════════════════════════════════════
# Common Functions
# ══════════════════════════════════════════════════════════════════════

function Write-Header {
    param([string]$Message)
    Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

# ══════════════════════════════════════════════════════════════════════
# Task: Clean Reconfigure
# ══════════════════════════════════════════════════════════════════════

function Invoke-CleanReconfigure {
    Write-Header "Clean Reconfigure - $Preset"
    
    $buildDir = "build_vs26"
    if ($Preset -match "linux") { $buildDir = "build" }
    
    Write-Host "`nStep 1: Clean build directory"
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force
        Write-Success "Removed $buildDir"
    }
    
    if ($RemoveRootCache -and (Test-Path "CMakeCache.txt")) {
        Remove-Item "CMakeCache.txt" -Force
        Write-Success "Removed CMakeCache.txt"
    }
    
    Write-Host "`nStep 2: Configure with preset"
    cmake --preset $Preset
    
    Write-Host "`nStep 3: Build"
    cmake --build --preset $Preset -v
    
    Write-Success "Clean reconfigure complete"
}

# ══════════════════════════════════════════════════════════════════════
# Task: Run GUI
# ══════════════════════════════════════════════════════════════════════

function Invoke-RunGui {
    Write-Header "Launch TelemetryHub GUI"
    
    if (-not $QtRoot) {
        Write-Error "Qt root not specified. Set -QtRoot or THUB_QT_ROOT environment variable"
        return
    }
    
    $env:THUB_API_BASE = $ApiBase
    $guiExe = "build_vs26\gui\Release\gui_app.exe"
    $gatewayExe = "build_vs26\gateway\Release\gateway_app.exe"
    
    Write-Host "`nStarting gateway..."
    Start-Process -FilePath $gatewayExe -NoNewWindow
    Start-Sleep -Seconds 2
    
    Write-Host "Launching GUI..."
    if ($DeployLocal) {
        Write-Host "Deploying Qt DLLs locally..."
        & "$QtRoot\bin\windeployqt.exe" $guiExe
    }
    
    Start-Process -FilePath $guiExe
    Write-Success "GUI launched. API base: $ApiBase"
}

# ══════════════════════════════════════════════════════════════════════
# Task: Render Mermaid Diagrams
# ══════════════════════════════════════════════════════════════════════

function Invoke-RenderDiagrams {
    Write-Header "Render Mermaid Diagrams to PNG"
    
    if (-not (Get-Command "npx" -ErrorAction SilentlyContinue)) {
        Write-Warning "Node.js not found. Installing..."
        winget install OpenJS.NodeJS.LTS
    }
    
    $mmdFiles = Get-ChildItem -Path "docs\mermaid" -Filter "*.mmd" -Recurse
    Write-Host "`nFound $($mmdFiles.Count) Mermaid files"
    
    foreach ($file in $mmdFiles) {
        $outFile = $file.FullName -replace '\.mmd$', '.png'
        Write-Host "  Rendering: $($file.Name)"
        
        npx -y @mermaid-js/mermaid-cli mmdc -i $file.FullName -o $outFile 2>$null
        
        if (Test-Path $outFile) {
            Write-Success "Created: $($file.Name -replace '\.mmd$', '.png')"
        }
    }
}

# ══════════════════════════════════════════════════════════════════════
# Task: Configure FASTBuild
# ══════════════════════════════════════════════════════════════════════

function Invoke-ConfigureFastBuild {
    Write-Header "FASTBuild Configuration"
    
    if ($EnableFastBuild) {
        Write-Host "`nEnabling FASTBuild distributed compilation..."
        Write-Host "See docs/fastbuild_guide.md for setup instructions"
        
        $fbuildConfig = @"
# FASTBuild Configuration
.Settings {
    .CachePluginDLL = 'FBuildCachePlugin'
    .Workers = { '127.0.0.1', 'worker1', 'worker2' }
}
"@
        
        Set-Content -Path "fbuild.bff" -Value $fbuildConfig
        Write-Success "Created fbuild.bff configuration"
    } else {
        Write-Warning "FASTBuild not enabled. Use -EnableFastBuild flag"
    }
}

# ══════════════════════════════════════════════════════════════════════
# Task: Help
# ══════════════════════════════════════════════════════════════════════

function Show-Help {
    Write-Header "TelemetryHub Build Utilities - Help"
    
    Write-Host @"

USAGE:
    .\build-utils.ps1 -Task <task> [options]

TASKS:
    clean-reconfigure      Clean and reconfigure CMake build
    run-gui               Launch Qt GUI with gateway
    render-diagrams       Convert Mermaid .mmd to PNG images
    configure-fastbuild   Setup FASTBuild distributed compilation
    help                  Show this help message

OPTIONS:
    -Preset <name>        CMake preset (default: vs2026-release)
    -QtRoot <path>        Qt installation path
    -ApiBase <url>        Gateway API URL (default: http://127.0.0.1:8080)
    -WaitTimeoutSec <n>   Health check timeout (default: 40)
    -DeployLocal          Copy Qt DLLs beside exe
    -RemoveRootCache      Delete CMakeCache.txt in root
    -EnableFastBuild      Enable FASTBuild configuration
    -Chatty               Verbose output

EXAMPLES:
    # Clean reconfigure with GUI preset
    .\build-utils.ps1 -Task clean-reconfigure -Preset vs2026-gui
    
    # Launch GUI with custom API
    .\build-utils.ps1 -Task run-gui -QtRoot "C:\Qt\6.10.1\msvc2022_64" -ApiBase "http://localhost:9000"
    
    # Render all Mermaid diagrams
    .\build-utils.ps1 -Task render-diagrams -Chatty

"@
}

# ══════════════════════════════════════════════════════════════════════
# Main Entry Point
# ══════════════════════════════════════════════════════════════════════

Write-Host "TelemetryHub Build Utilities v1.0" -ForegroundColor Magenta
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray

switch ($Task) {
    'clean-reconfigure' { Invoke-CleanReconfigure }
    'run-gui' { Invoke-RunGui }
    'render-diagrams' { Invoke-RenderDiagrams }
    'configure-fastbuild' { Invoke-ConfigureFastBuild }
    'help' { Show-Help }
}

Write-Host "`nDone." -ForegroundColor Green
