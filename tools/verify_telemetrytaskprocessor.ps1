# Verification Checklist - TelemetryTaskProcessor Reframe
# Date: December 26, 2025
# Purpose: Verify all renaming and reframing is complete

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TelemetryTaskProcessor Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$checks = @()

# Check 1: Folder renamed
Write-Host "[1/10] Checking folder name..." -ForegroundColor Yellow
if (Test-Path "c:\code\TelemetryTaskProcessor") {
    Write-Host "✅ Folder exists: c:\code\TelemetryTaskProcessor" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Folder NOT found: c:\code\TelemetryTaskProcessor" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 2: include directory renamed
Write-Host "[2/10] Checking include directory..." -ForegroundColor Yellow
cd c:\code\TelemetryTaskProcessor
if (Test-Path "include\telemetry_processor") {
    Write-Host "✅ Include directory renamed: include\telemetry_processor" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Old directory still exists: include\distqueue" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 3: No distqueue references in headers
Write-Host "[3/10] Checking header files..." -ForegroundColor Yellow
$headerRefs = Select-String -Path "include\telemetry_processor\*.h" -Pattern "distqueue" -CaseSensitive
if ($headerRefs.Count -eq 0) {
    Write-Host "✅ No 'distqueue' references in headers" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Found $($headerRefs.Count) 'distqueue' references in headers" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 4: No distqueue references in source files
Write-Host "[4/10] Checking source files..." -ForegroundColor Yellow
$srcRefs = Select-String -Path "src\**\*.cpp" -Pattern "distqueue" -CaseSensitive
if ($srcRefs.Count -eq 0) {
    Write-Host "✅ No 'distqueue' references in source files" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Found $($srcRefs.Count) 'distqueue' references in source" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 5: CMakeLists.txt updated
Write-Host "[5/10] Checking CMakeLists.txt..." -ForegroundColor Yellow
$cmakeContent = Get-Content "CMakeLists.txt" -Raw
if ($cmakeContent -match "TelemetryTaskProcessor" -and $cmakeContent -notmatch "DistQueue") {
    Write-Host "✅ CMakeLists.txt updated correctly" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ CMakeLists.txt still contains 'DistQueue'" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 6: README.md updated
Write-Host "[6/10] Checking README.md..." -ForegroundColor Yellow
$readmeContent = Get-Content "README.md" -Raw
if ($readmeContent -match "TelemetryTaskProcessor" -and $readmeContent -match "10,000\+ tasks/sec") {
    Write-Host "✅ README.md updated with new positioning" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ README.md not updated correctly" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 7: Build succeeds
Write-Host "[7/10] Checking build..." -ForegroundColor Yellow
if (Test-Path "build") {
    $buildLog = Get-Content "build\CMakeCache.txt" -ErrorAction SilentlyContinue
    if ($buildLog -match "TelemetryTaskProcessor") {
        Write-Host "✅ Build configured correctly" -ForegroundColor Green
        $checks += $true
    } else {
        Write-Host "⚠️  Build may need reconfiguration" -ForegroundColor Yellow
        $checks += $false
    }
} else {
    Write-Host "⚠️  Build directory not found (run cmake -B build -S .)" -ForegroundColor Yellow
    $checks += $false
}
Write-Host ""

# Check 8: Test files updated
Write-Host "[8/10] Checking test files..." -ForegroundColor Yellow
$testRefs = Select-String -Path "tests\*.cpp" -Pattern "distqueue" -CaseSensitive
if ($testRefs.Count -eq 0) {
    Write-Host "✅ No 'distqueue' references in tests" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Found $($testRefs.Count) 'distqueue' references in tests" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 9: Documentation updated
Write-Host "[9/10] Checking documentation..." -ForegroundColor Yellow
$docRefs = Select-String -Path "docs\*.md" -Pattern "DistQueue" -CaseSensitive
if ($docRefs.Count -eq 0) {
    Write-Host "✅ No 'DistQueue' references in docs" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Found $($docRefs.Count) 'DistQueue' references in docs" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Check 10: Example files updated
Write-Host "[10/10] Checking example files..." -ForegroundColor Yellow
$exampleRefs = Select-String -Path "examples\*.cpp" -Pattern "distqueue" -CaseSensitive
if ($exampleRefs.Count -eq 0) {
    Write-Host "✅ No 'distqueue' references in examples" -ForegroundColor Green
    $checks += $true
} else {
    Write-Host "❌ Found $($exampleRefs.Count) 'distqueue' references in examples" -ForegroundColor Red
    $checks += $false
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
$passedChecks = ($checks | Where-Object { $_ -eq $true }).Count
$totalChecks = $checks.Count
$percentage = [math]::Round(($passedChecks / $totalChecks) * 100)

if ($passedChecks -eq $totalChecks) {
    Write-Host "✅ ALL CHECKS PASSED ($passedChecks/$totalChecks)" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 Reframing Complete! Next steps:" -ForegroundColor Green
    Write-Host "1. Rebuild: cmake --build build --config Release" -ForegroundColor White
    Write-Host "2. Test: cd build && ctest -C Release" -ForegroundColor White
    Write-Host "3. Commit: git add -A && git commit -m 'Reframe: TelemetryTaskProcessor'" -ForegroundColor White
    Write-Host "4. Copy GitHub README: Copy c:\code\telemetryhub\docs\github_ready_README.md to c:\code\TelemetryTaskProcessor\README.md" -ForegroundColor White
} elseif ($percentage -ge 80) {
    Write-Host "⚠️  MOSTLY COMPLETE ($passedChecks/$totalChecks = $percentage%)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Some checks failed. Review failed items above." -ForegroundColor Yellow
} else {
    Write-Host "❌ INCOMPLETE ($passedChecks/$totalChecks = $percentage%)" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Multiple checks failed. Please review and fix." -ForegroundColor Red
}
Write-Host ""
