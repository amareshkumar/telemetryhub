# Final Cleanup - Remove remaining feature branches
cd C:\code\telemetryhub

Write-Host "=== Final Branch Cleanup ===" -ForegroundColor Cyan

$branchesToDelete = @("headers_vs", "show_headers_option_C", "dev-main")

foreach ($branch in $branchesToDelete) {
    Write-Host "Deleting: $branch" -ForegroundColor Yellow
    git push origin --delete $branch
}

# Try to delete v6.0.0 (might be a tag)
Write-Host "`nAttempting to delete v6.0.0 tag..." -ForegroundColor Yellow
git push origin :refs/tags/v6.0.0

Write-Host "`n=== Final Status ===" -ForegroundColor Cyan
Write-Host "Remaining branches:" -ForegroundColor Green
git branch -r | Where-Object { $_ -match "origin/" }

Write-Host "`nCheck: https://github.com/amareshkumar/telemetryhub/branches" -ForegroundColor Cyan
