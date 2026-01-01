# Branch Cleanup Script for TelemetryHub
# Removes all branches except: main, release-v4.1.1, dev-main

Write-Host "=== TelemetryHub Branch Cleanup ===" -ForegroundColor Cyan
Write-Host ""

# Branches to KEEP
$keepBranches = @(
    "main",
    "release-v4.1.1",
    "dev-main"
)

Write-Host "Branches to KEEP:" -ForegroundColor Green
$keepBranches | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }
Write-Host ""

# Get all remote branches (excluding HEAD)
$allBranches = git branch -r | Where-Object { $_ -match "origin/" -and $_ -notmatch "HEAD" } | ForEach-Object {
    $_.Trim() -replace "origin/", ""
}

# Filter branches to delete
$branchesToDelete = $allBranches | Where-Object { $_ -notin $keepBranches }

Write-Host "Found $($branchesToDelete.Count) branches to DELETE:" -ForegroundColor Yellow
$branchesToDelete | Sort-Object | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
Write-Host ""

# Confirm before deletion
Write-Host "This will permanently delete $($branchesToDelete.Count) remote branches!" -ForegroundColor Red
$confirmation = Read-Host "Type 'DELETE' to proceed (anything else to cancel)"

if ($confirmation -ne "DELETE") {
    Write-Host "Cancelled. No branches deleted." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Deleting branches..." -ForegroundColor Cyan

$successCount = 0
$failCount = 0
$errors = @()

foreach ($branch in $branchesToDelete) {
    Write-Host "Deleting: $branch" -ForegroundColor Gray
    
    $result = git push origin --delete $branch 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $successCount++
        Write-Host "  ✓ Deleted: $branch" -ForegroundColor Green
    } else {
        $failCount++
        $errors += "  ✗ Failed: $branch - $result"
        Write-Host "  ✗ Failed: $branch" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Cleanup Summary ===" -ForegroundColor Cyan
Write-Host "✓ Successfully deleted: $successCount branches" -ForegroundColor Green
Write-Host "✗ Failed to delete: $failCount branches" -ForegroundColor Red
Write-Host ""

if ($errors.Count -gt 0) {
    Write-Host "Errors encountered:" -ForegroundColor Yellow
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

# Show remaining branches
Write-Host ""
Write-Host "Remaining remote branches:" -ForegroundColor Cyan
git branch -r | Where-Object { $_ -match "origin/" } | Sort-Object | ForEach-Object {
    Write-Host "  $_" -ForegroundColor Green
}

Write-Host ""
Write-Host "✓ Cleanup complete! Check: https://github.com/amareshkumar/telemetryhub/branches" -ForegroundColor Green

# Clean up local tracking branches
Write-Host ""
Write-Host "Cleaning up local tracking branches..." -ForegroundColor Cyan
git fetch --prune
git remote prune origin
Write-Host "✓ Local cleanup complete!" -ForegroundColor Green
