<#!
.SYNOPSIS
  Render Mermaid .mmd diagrams (PNG/SVG/PDF) using mermaid-cli via npx.

.DESCRIPTION
  Ensures Node.js + npx are available (installs Node LTS via winget if absent and permitted),
  then iterates over matching .mmd files and invokes mermaid-cli to produce image outputs.
  Intended for local developer use so CI can remain lean.

.PARAMETER SourceDir
  Root directory containing .mmd files. Default: docs/mermaid relative to repo root.

.PARAMETER Pattern
  File glob to select diagrams. Default: *_day10.mmd (current iteration set).

.PARAMETER OutputFormat
  mermaid-cli output format (png|svg|pdf). Default: png.

.PARAMETER OutDir
  Directory for rendered images. Defaults to same folder as each source file.

.PARAMETER ForceInstallNode
  If set, attempt Node installation even if a partial Node exists.

.PARAMETER SkipInstall
  If set, do not attempt Node install; fail fast if npx missing.

.PARAMETER Verbose
  Emit extra progress messages.

.EXAMPLE
  pwsh -File tools/render_mermaid.ps1
  Renders all *_day10.mmd files under docs/mermaid to PNG.

.EXAMPLE
  pwsh -File tools/render_mermaid.ps1 -Pattern '*.mmd' -OutputFormat svg -OutDir rendered

.NOTES
  - Uses winget for installation if available; fallback instruction if missing.
  - mermaid-cli pulls Chromium (via puppeteer); corporate firewalls may block that.
  - If Chromium download fails, try setting PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 and install a system Chrome, then re-run.
#>

[CmdletBinding()]
param(
  [string]$SourceDir = "docs/mermaid",
  [string]$Pattern = "*_day10.mmd",
  [ValidateSet('png','svg','pdf')][string]$OutputFormat = 'png',
  [string]$OutDir,
  [switch]$ForceInstallNode,
  [switch]$SkipInstall,
  [switch]$Verbose
)

function Write-Info($msg) { if ($Verbose) { Write-Host "[mermaid] $msg" } }
function Fail($msg) { Write-Error $msg; exit 1 }

# Resolve source directory relative to repo root
$repoRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName
$absSource = Join-Path $repoRoot $SourceDir
if (-not (Test-Path $absSource)) { Fail "SourceDir '$absSource' not found." }

# Discover files
$files = Get-ChildItem -Path $absSource -Filter $Pattern -File -Recurse
if (-not $files) { Fail "No .mmd files matched pattern '$Pattern' under '$absSource'." }
Write-Info "Found $($files.Count) diagram(s)."

# Locate npx
$npx = $null
$defaultNpx = Join-Path $Env:ProgramFiles 'nodejs' 'npx.cmd'
if (Test-Path $defaultNpx) { $npx = $defaultNpx }
elseif (Get-Command npx -ErrorAction SilentlyContinue) { $npx = 'npx' }

if (-not $npx) {
  if ($SkipInstall) { Fail "npx not found and SkipInstall specified." }
  Write-Host "npx not found. Attempting Node.js LTS installation via winget..."
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget not available; install Node.js manually then re-run."
  }
  winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
  if (Test-Path $defaultNpx) { $npx = $defaultNpx } elseif (Get-Command npx -ErrorAction SilentlyContinue) { $npx = 'npx' }
  if (-not $npx) { Fail "Node install finished but npx still not found." }
}
elseif ($ForceInstallNode) {
  Write-Host "ForceInstallNode specified; reinstalling Node LTS via winget..."
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
  } else {
    Write-Warning "winget unavailable; skipping reinstall."
  }
}

Write-Info "Using npx at '$npx'." 

# Ensure output directory if provided
if ($OutDir) {
  $absOut = Join-Path $repoRoot $OutDir
  if (-not (Test-Path $absOut)) { New-Item -ItemType Directory -Path $absOut | Out-Null }
} else { $absOut = $null }

# Set a temp env to skip chromium if desired by user (uncomment to force):
# $Env:PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = 'true'

$failures = @()
foreach ($f in $files) {
  $targetDir = if ($absOut) { $absOut } else { $f.Directory.FullName }
  $outFile = Join-Path $targetDir ([System.IO.Path]::GetFileNameWithoutExtension($f.Name) + ".${OutputFormat}")
  Write-Host "Rendering: $($f.FullName) -> $outFile"
  # Use mermaid-cli; install per-run with -y; optional args for puppeteer config could be added
  & $npx @mermaid-js/mermaid-cli -i $f.FullName -o $outFile 2>&1 | Tee-Object -Variable renderLog | Out-Null
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0 -or -not (Test-Path $outFile)) {
    Write-Warning "Failed rendering '$($f.Name)' (exit $exitCode)."
    $failures += [pscustomobject]@{ File=$f.FullName; ExitCode=$exitCode; Log=$renderLog -join "`n" }
  } else {
    Write-Info "Rendered $outFile"
  }
}

if ($failures.Count -gt 0) {
  Write-Error "Rendering completed with $($failures.Count) failure(s)."
  foreach ($f in $failures) {
    Write-Host "--- Failure: $($f.File) (exit $($f.ExitCode)) ---" -ForegroundColor Yellow
    Write-Host $f.Log
  }
  exit 1
} else {
  Write-Host "All diagrams rendered successfully." -ForegroundColor Green
}
