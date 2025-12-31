# PowerShell Script: Rename DistQueue → TelemetryTaskProcessor
# Date: December 26, 2025
# Purpose: Reframe project with C++ backend performance focus

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Renaming DistQueue → TelemetryTaskProcessor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Rename main folder
Write-Host "[1/8] Renaming project folder..." -ForegroundColor Yellow
cd c:\code
if (Test-Path "DistQueue") {
    Rename-Item -Path "DistQueue" -NewName "TelemetryTaskProcessor"
    Write-Host "✅ Renamed: c:\code\DistQueue → c:\code\TelemetryTaskProcessor" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: c:\code\DistQueue not found (already renamed?)" -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Navigate to new folder
cd c:\code\TelemetryTaskProcessor

# Step 3: Update CMakeLists.txt (root)
Write-Host "[2/8] Updating CMakeLists.txt..." -ForegroundColor Yellow
if (Test-Path "CMakeLists.txt") {
    (Get-Content "CMakeLists.txt") `
        -replace 'project\(DistQueue', 'project(TelemetryTaskProcessor' `
        -replace 'distqueue', 'telemetry_processor' `
        -replace 'DistQueue', 'TelemetryTaskProcessor' `
        | Set-Content "CMakeLists.txt"
    Write-Host "✅ Updated: CMakeLists.txt" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: CMakeLists.txt not found" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Update README.md
Write-Host "[3/8] Updating README.md..." -ForegroundColor Yellow
if (Test-Path "README.md") {
    (Get-Content "README.md") `
        -replace '# DistQueue', '# TelemetryTaskProcessor' `
        -replace 'DistQueue', 'TelemetryTaskProcessor' `
        -replace 'distqueue', 'telemetry_processor' `
        -replace 'Distributed Task Queue in C\+\+', 'High-Performance Task Processing in C++' `
        | Set-Content "README.md"
    Write-Host "✅ Updated: README.md" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: README.md not found" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Rename include directory
Write-Host "[4/8] Renaming include/distqueue → include/telemetry_processor..." -ForegroundColor Yellow
if (Test-Path "include\distqueue") {
    Rename-Item -Path "include\distqueue" -NewName "telemetry_processor"
    Write-Host "✅ Renamed: include\distqueue → include\telemetry_processor" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: include\distqueue not found (already renamed?)" -ForegroundColor Yellow
}
Write-Host ""

# Step 6: Update all header files
Write-Host "[5/8] Updating header files (namespace, include guards)..." -ForegroundColor Yellow
$headerFiles = Get-ChildItem -Path "include\telemetry_processor" -Filter "*.h" -ErrorAction SilentlyContinue
foreach ($file in $headerFiles) {
    (Get-Content $file.FullName) `
        -replace 'DISTQUEUE_', 'TELEMETRY_PROCESSOR_' `
        -replace 'namespace distqueue', 'namespace telemetry_processor' `
        -replace 'distqueue::', 'telemetry_processor::' `
        | Set-Content $file.FullName
    Write-Host "  ✅ Updated: $($file.Name)" -ForegroundColor Green
}
Write-Host ""

# Step 7: Update all source files
Write-Host "[6/8] Updating source files (namespace)..." -ForegroundColor Yellow
$sourceFiles = Get-ChildItem -Path "src" -Filter "*.cpp" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $sourceFiles) {
    (Get-Content $file.FullName) `
        -replace '#include "distqueue/', '#include "telemetry_processor/' `
        -replace 'namespace distqueue', 'namespace telemetry_processor' `
        -replace 'distqueue::', 'telemetry_processor::' `
        | Set-Content $file.FullName
    Write-Host "  ✅ Updated: $($file.Name)" -ForegroundColor Green
}
Write-Host ""

# Step 8: Update test files
Write-Host "[7/8] Updating test files..." -ForegroundColor Yellow
$testFiles = Get-ChildItem -Path "tests" -Filter "*.cpp" -ErrorAction SilentlyContinue
foreach ($file in $testFiles) {
    (Get-Content $file.FullName) `
        -replace '#include "distqueue/', '#include "telemetry_processor/' `
        -replace 'namespace distqueue', 'namespace telemetry_processor' `
        -replace 'distqueue::', 'telemetry_processor::' `
        -replace 'using namespace distqueue', 'using namespace telemetry_processor' `
        | Set-Content $file.FullName
    Write-Host "  ✅ Updated: $($file.Name)" -ForegroundColor Green
}
Write-Host ""

# Step 9: Update documentation files
Write-Host "[8/8] Updating documentation files..." -ForegroundColor Yellow
$docFiles = Get-ChildItem -Path "docs" -Filter "*.md" -ErrorAction SilentlyContinue
foreach ($file in $docFiles) {
    (Get-Content $file.FullName) `
        -replace 'DistQueue', 'TelemetryTaskProcessor' `
        -replace 'distqueue', 'telemetry_processor' `
        | Set-Content $file.FullName
    Write-Host "  ✅ Updated: $($file.Name)" -ForegroundColor Green
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Renaming Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Rebuild project: cmake -B build -S . && cmake --build build" -ForegroundColor White
Write-Host "2. Run tests: cd build && ctest" -ForegroundColor White
Write-Host "3. Commit changes: git add -A && git commit -m 'Reframe: DistQueue → TelemetryTaskProcessor'" -ForegroundColor White
Write-Host ""
Write-Host "New project location: c:\code\TelemetryTaskProcessor" -ForegroundColor Cyan
