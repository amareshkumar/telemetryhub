# Final Setup Script - TelemetryTaskProcessor
# Execute these commands to complete reframing

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Final Setup - TelemetryTaskProcessor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Copy GitHub README
Write-Host "[1/5] Copying GitHub-ready README..." -ForegroundColor Yellow
Copy-Item -Path "c:\code\telemetryhub\docs\github_ready_README.md" -Destination "c:\code\TelemetryTaskProcessor\README.md" -Force
Write-Host "✅ README.md updated" -ForegroundColor Green
Write-Host ""

# Step 2: Rebuild project
Write-Host "[2/5] Rebuilding project..." -ForegroundColor Yellow
cd c:\code\TelemetryTaskProcessor
cmake --build build --config Release
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
}
Write-Host ""

# Step 3: Run tests
Write-Host "[3/5] Running tests..." -ForegroundColor Yellow
cd build
ctest -C Release --output-on-failure
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All tests passed" -ForegroundColor Green
} else {
    Write-Host "❌ Tests failed" -ForegroundColor Red
}
Write-Host ""

# Step 4: Git status check
Write-Host "[4/5] Checking git status..." -ForegroundColor Yellow
cd c:\code\TelemetryTaskProcessor
git status --short
Write-Host ""

# Step 5: Summary
Write-Host "[5/5] Summary" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Reframing Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Commit changes:" -ForegroundColor White
Write-Host "   git add -A" -ForegroundColor Gray
Write-Host '   git commit -m "Reframe: TelemetryTaskProcessor (performance focus)"' -ForegroundColor Gray
Write-Host ""
Write-Host "2. Update ResumeGenius (5 min):" -ForegroundColor White
Write-Host "   Open: c:\code\telemetryhub\docs\resume_content_updated_telemetrytaskprocessor.md" -ForegroundColor Gray
Write-Host "   Copy-paste: Professional Summary, TelemetryTaskProcessor, all projects, Skills" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Ready for Day 2 (Dec 27):" -ForegroundColor White
Write-Host "   - Producer API implementation" -ForegroundColor Gray
Write-Host "   - Python baseline comparison" -ForegroundColor Gray
Write-Host "   - Benchmark: C++ vs Python (target 8x faster)" -ForegroundColor Gray
Write-Host ""
Write-Host "Project Location: c:\code\TelemetryTaskProcessor" -ForegroundColor Cyan
Write-Host "Documentation: c:\code\telemetryhub\docs\reframing_complete_summary.md" -ForegroundColor Cyan
Write-Host ""
