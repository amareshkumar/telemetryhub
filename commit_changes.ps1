# Commit all today's changes
cd C:\code\telemetryhub

Write-Host "=== Committing TelemetryHub Changes ===" -ForegroundColor Cyan

git add ReadMe.md
git add TASKS_COMPLETED_JAN1_PART2.md
git add ACTION_ITEMS_JAN2026.md
git add REPOSITORY_STATUS_JAN2026.md
git add cleanup_branches.ps1
git add final_branch_cleanup.ps1

Write-Host "`nChanges staged:" -ForegroundColor Green
git status --short

Write-Host "`nCommitting..." -ForegroundColor Yellow
git commit -m "docs: Fix CI badges + add comprehensive Linux test instructions

- Fix build badges: Add separate C++ CI and Windows CI badges  
- Add Testing section with Linux and Windows instructions
- Document ctest usage for both platforms
- Add curl examples for Linux, Invoke-WebRequest for Windows
- Include integration test workflow for both platforms
- Add task completion tracking documents"

Write-Host "`nPushing to origin/main..." -ForegroundColor Yellow
git push origin main

Write-Host "`n✓ Complete! Check: https://github.com/amareshkumar/telemetryhub" -ForegroundColor Green
