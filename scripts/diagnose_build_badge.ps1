# Fix Red Build Badge - Diagnostic and Fix Script

Write-Host "=== Build Badge Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Badge URLs from README
$badges = @{
    "C++ CI" = "https://github.com/amareshkumar/telemetryhub/workflows/C++%20CI/badge.svg"
    "Windows CI" = "https://github.com/amareshkumar/telemetryhub/workflows/Windows%20C++%20CI/badge.svg"
}

Write-Host "Current Badges in README:" -ForegroundColor Yellow
$badges.Keys | ForEach-Object {
    Write-Host "  • $_" -ForegroundColor White
}
Write-Host ""

# Common reasons for red badges
Write-Host "Common Reasons for Red Build Badges:" -ForegroundColor Yellow
Write-Host "  1. Workflow file has syntax errors" -ForegroundColor Gray
Write-Host "  2. Tests are failing" -ForegroundColor Gray
Write-Host "  3. Build dependencies missing" -ForegroundColor Gray
Write-Host "  4. Workflow references moved/deleted files" -ForegroundColor Gray
Write-Host "  5. Branch protection preventing workflow runs" -ForegroundColor Gray
Write-Host ""

# Check if gh CLI is available
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Checking GitHub Actions status..." -ForegroundColor Cyan
    Write-Host ""
    
    # Try to get workflow runs
    $runsOutput = gh run list --limit 10 --json status,conclusion,name,createdAt,displayTitle 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $runs = $runsOutput | ConvertFrom-Json
        
        Write-Host "Recent Workflow Runs:" -ForegroundColor Green
        $runs | ForEach-Object {
            $icon = switch ($_.conclusion) {
                "success" { "✓" }
                "failure" { "✗" }
                "cancelled" { "⊘" }
                default { "•" }
            }
            $color = switch ($_.conclusion) {
                "success" { "Green" }
                "failure" { "Red" }
                "cancelled" { "Yellow" }
                default { "Gray" }
            }
            Write-Host "  $icon $($_.name) - $($_.conclusion)" -ForegroundColor $color
        }
        Write-Host ""
        
        # Check for failures
        $failures = $runs | Where-Object { $_.conclusion -eq "failure" }
        if ($failures) {
            Write-Host "Found $($failures.Count) failed runs!" -ForegroundColor Red
            Write-Host ""
            Write-Host "To view logs:" -ForegroundColor Yellow
            Write-Host "  gh run view <run-id> --log-failed" -ForegroundColor White
            Write-Host "  Or visit: https://github.com/amareshkumar/telemetryhub/actions" -ForegroundColor White
        }
    } else {
        Write-Host "GitHub CLI not authenticated. Run: gh auth login" -ForegroundColor Yellow
        Write-Host "Or check manually: https://github.com/amareshkumar/telemetryhub/actions" -ForegroundColor White
    }
} else {
    Write-Host "GitHub CLI not installed. Install with:" -ForegroundColor Yellow
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor White
    Write-Host ""
    Write-Host "Or check manually: https://github.com/amareshkumar/telemetryhub/actions" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Potential Fixes ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Check Workflow Files:" -ForegroundColor Yellow
Write-Host "   • Ensure no syntax errors in .github/workflows/*.yml" -ForegroundColor White
Write-Host "   • Verify all referenced files exist" -ForegroundColor White
Write-Host ""

Write-Host "2. Script Organization Impact:" -ForegroundColor Yellow
Write-Host "   • We moved .ps1 files to scripts/" -ForegroundColor White
Write-Host "   • Check if workflows reference old paths" -ForegroundColor White
Write-Host "   • Example: configure_fbuild.ps1 → scripts/configure_fbuild.ps1" -ForegroundColor White
Write-Host ""

Write-Host "3. Recent Commits:" -ForegroundColor Yellow
Write-Host "   • Repository reorganization may have broken workflows" -ForegroundColor White
Write-Host "   • Check if tests pass locally:" -ForegroundColor White
Write-Host "     cmake --preset vs2026-release" -ForegroundColor Gray
Write-Host "     cmake --build build_vs26 --config Release" -ForegroundColor Gray
Write-Host "     ctest --test-dir build_vs26 -C Release" -ForegroundColor Gray
Write-Host ""

Write-Host "4. Branch Protection:" -ForegroundColor Yellow
Write-Host "   • Main branch has protection (we saw this earlier)" -ForegroundColor White
Write-Host "   • This might prevent workflow runs on main" -ForegroundColor White
Write-Host "   • Check: https://github.com/amareshkumar/telemetryhub/settings/branches" -ForegroundColor White
Write-Host ""

Write-Host "=== Action Items ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[ ] 1. Visit: https://github.com/amareshkumar/telemetryhub/actions" -ForegroundColor White
Write-Host "       See which workflows are failing" -ForegroundColor Gray
Write-Host ""

Write-Host "[ ] 2. Click on failed run → View logs" -ForegroundColor White
Write-Host "       Identify specific error" -ForegroundColor Gray
Write-Host ""

Write-Host "[ ] 3. Common fixes:" -ForegroundColor White
Write-Host "       • Update workflow paths if they reference moved scripts" -ForegroundColor Gray
Write-Host "       • Re-run failed workflows (if it was a temporary issue)" -ForegroundColor Gray
Write-Host "       • Fix failing tests locally first" -ForegroundColor Gray
Write-Host ""

Write-Host "[ ] 4. If issue is script paths:" -ForegroundColor White
Write-Host "       • Search workflows for '.ps1' references" -ForegroundColor Gray
Write-Host "       • Update paths: configure_fbuild.ps1 → scripts/configure_fbuild.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Quick Links ===" -ForegroundColor Cyan
Write-Host "Actions: https://github.com/amareshkumar/telemetryhub/actions" -ForegroundColor White
Write-Host "Workflows: https://github.com/amareshkumar/telemetryhub/tree/main/.github/workflows" -ForegroundColor White
Write-Host "Settings: https://github.com/amareshkumar/telemetryhub/settings" -ForegroundColor White
Write-Host ""

Write-Host "Once you identify the issue, I can help fix the workflow files!" -ForegroundColor Green
