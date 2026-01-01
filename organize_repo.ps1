# Organize TelemetryHub Repository Structure
# Move .ps1 files to scripts/ and .md files to docs/

cd C:\code\telemetryhub

Write-Host "=== TelemetryHub Repository Organization ===" -ForegroundColor Cyan
Write-Host ""

# Create scripts directory if it doesn't exist
if (-not (Test-Path "scripts")) {
    New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
    Write-Host "✓ Created scripts/ directory" -ForegroundColor Green
} else {
    Write-Host "✓ scripts/ directory exists" -ForegroundColor Green
}

Write-Host ""

# Move .ps1 files to scripts/
Write-Host "Moving PowerShell scripts to scripts/..." -ForegroundColor Yellow
$ps1Files = Get-ChildItem -Path . -Filter *.ps1 -File | Where-Object { $_.Name -ne "organize_repo.ps1" }

foreach ($file in $ps1Files) {
    Move-Item $file.FullName "scripts/" -Force
    Write-Host "  ✓ Moved: $($file.Name)" -ForegroundColor Green
}

Write-Host ""

# Move .md files to docs/ (except ReadMe.md - keep in root)
Write-Host "Moving Markdown files to docs/..." -ForegroundColor Yellow
$mdFiles = Get-ChildItem -Path . -Filter *.md -File | Where-Object { $_.Name -ne "ReadMe.md" }

foreach ($file in $mdFiles) {
    Move-Item $file.FullName "docs/" -Force
    Write-Host "  ✓ Moved: $($file.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Organization Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  • PowerShell scripts: C:\code\telemetryhub\scripts\" -ForegroundColor White
Write-Host "  • Documentation: C:\code\telemetryhub\docs\" -ForegroundColor White
Write-Host "  • ReadMe.md kept in root for GitHub" -ForegroundColor White
Write-Host ""
Write-Host "Going forward:" -ForegroundColor Green
Write-Host "  • New .ps1 files → scripts/" -ForegroundColor White
Write-Host "  • New .md files → docs/" -ForegroundColor White
Write-Host "  • Exceptions: ReadMe.md, LICENSE, .gitignore stay in root" -ForegroundColor Gray
Write-Host ""

# Show organized structure
Write-Host "Organized files:" -ForegroundColor Cyan
Write-Host ""
Write-Host "scripts/ (PowerShell):" -ForegroundColor Yellow
Get-ChildItem scripts\*.ps1 -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor White }
$scriptCount = (Get-ChildItem scripts\*.ps1 -ErrorAction SilentlyContinue | Measure-Object).Count
if ($scriptCount -gt 10) {
    Write-Host "  ... and $($scriptCount - 10) more" -ForegroundColor Gray
}

Write-Host ""
Write-Host "docs/ (Documentation):" -ForegroundColor Yellow
Get-ChildItem docs\*.md -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Host "  • $($_.Name)" -ForegroundColor White }
$docCount = (Get-ChildItem docs\*.md -ErrorAction SilentlyContinue | Measure-Object).Count
if ($docCount -gt 10) {
    Write-Host "  ... and $($docCount - 10) more" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✓ Repository hygiene maintained!" -ForegroundColor Green
