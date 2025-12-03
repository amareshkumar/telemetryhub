<#!
.SYNOPSIS
  Clean build folders and reconfigure the workspace with a chosen CMake preset.

.DESCRIPTION
  - Removes common build directories (build*, build_vs*, build_asan/tsan, etc.)
  - Optionally removes root CMakeCache.txt and CMakeFiles if present.
  - Runs `cmake --preset <Preset>` to reconfigure.

.PARAMETER Preset
  CMake configure preset to run after cleaning. Default: vs2026-gui

.PARAMETER RemoveRootCache
  Also delete root-level CMakeCache.txt and CMakeFiles.

.EXAMPLE
  pwsh -File tools/clean_reconfigure.ps1 -Preset vs2026-gui -RemoveRootCache

.EXAMPLE
  pwsh -File tools/clean_reconfigure.ps1 -Preset vs2022-gui
#>

[CmdletBinding()]
param(
  [string]$Preset = 'vs2026-gui',
  [switch]$RemoveRootCache
)

function Write-Info($msg){ Write-Host "[clean_reconfigure] $msg" }
function Fail($msg){ Write-Error $msg; exit 1 }

# Repo root is parent of this script dir
$repoRoot = (Get-Item -Path $PSScriptRoot).Parent.FullName
Push-Location $repoRoot

try {
  $patterns = @('build', 'build_*', 'build_vs*')
  $dirs = @()
  foreach($p in $patterns){
    $dirs += Get-ChildItem -Directory -Name $p -ErrorAction SilentlyContinue
  }
  $dirs = $dirs | Sort-Object -Unique
  if ($dirs.Count -eq 0) {
    Write-Info 'No build directories found to remove.'
  } else {
    foreach ($d in $dirs) {
      Write-Info "Removing directory: $d"
      Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $d
    }
  }

  if ($RemoveRootCache) {
    if (Test-Path 'CMakeCache.txt') { Write-Info 'Removing root CMakeCache.txt'; Remove-Item -Force 'CMakeCache.txt' }
    if (Test-Path 'CMakeFiles') { Write-Info 'Removing root CMakeFiles'; Remove-Item -Recurse -Force 'CMakeFiles' }
  }

  Write-Info "Configuring with preset: $Preset"
  $cmake = Get-Command cmake -ErrorAction Stop
  & $cmake --preset $Preset
}
catch {
  Fail $_
}
finally {
  Pop-Location
}
