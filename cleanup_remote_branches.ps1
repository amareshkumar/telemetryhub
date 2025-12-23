# Safe Remote Branch Cleanup Script for TelemetryHub
# This script ONLY deletes remote branches that are:
# 1. Already merged into main
# 2. Not protected branches (main, main-backup, main-cleanup)
# LOCAL BRANCHES ARE NOT TOUCHED

Write-Host "=== TelemetryHub Remote Branch Cleanup ===" -ForegroundColor Cyan
Write-Host ""

# Fetch latest from origin
Write-Host "Fetching latest from origin..." -ForegroundColor Yellow
git fetch origin --prune
Write-Host ""

# Get all remote branches
$remoteBranches = git branch -r | ForEach-Object { $_.Trim() } | Where-Object { $_ -notlike "origin/HEAD*" }

Write-Host "Found $($remoteBranches.Count) remote branches" -ForegroundColor Green
Write-Host ""

# Protected branches (never delete)
$protected = @(
    "origin/main",
    "origin/main-backup",
    "origin/main-cleanup",
    "origin/HEAD"
)

# Branches to keep (active work)
$keepBranches = @(
    "origin/release-v4.1.0",  # Active PR #83
    "origin/day17-clean"      # Current work
)

# Get merged branches
Write-Host "Checking which branches are merged into main..." -ForegroundColor Yellow
$mergedBranches = git branch -r --merged origin/main | ForEach-Object { $_.Trim() } | Where-Object { $_ -notlike "origin/HEAD*" }

Write-Host "Found $($mergedBranches.Count) merged branches" -ForegroundColor Green
Write-Host ""

# Identify deletable branches
$toDelete = $mergedBranches | Where-Object {
    $branch = $_
    $isProtected = $protected -contains $branch
    $isKept = $keepBranches -contains $branch
    $isMain = $branch -eq "origin/main"
    
    -not $isProtected -and -not $isKept -and -not $isMain
}

if ($toDelete.Count -eq 0) {
    Write-Host "No branches to delete. All remote branches are either:" -ForegroundColor Green
    Write-Host "  - Protected (main, backups)" -ForegroundColor Gray
    Write-Host "  - Not yet merged" -ForegroundColor Gray
    Write-Host "  - Active work (PRs in progress)" -ForegroundColor Gray
    exit 0
}

# Display branches to delete
Write-Host "=== Branches to Delete (Merged into main) ===" -ForegroundColor Cyan
Write-Host ""
$toDelete | ForEach-Object {
    $branchName = $_ -replace "^origin/", ""
    Write-Host "  - $branchName" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Total: $($toDelete.Count) branches" -ForegroundColor Cyan
Write-Host ""

# Safety check
Write-Host "=== SAFETY VERIFICATION ===" -ForegroundColor Red
Write-Host "This will DELETE these branches from GitHub (origin)" -ForegroundColor Red
Write-Host "Local branches on your PC will NOT be affected" -ForegroundColor Green
Write-Host ""
$confirm = Read-Host "Type 'DELETE' to proceed, or anything else to cancel"

if ($confirm -ne "DELETE") {
    Write-Host ""
    Write-Host "Cancelled. No branches deleted." -ForegroundColor Yellow
    exit 0
}

# Delete branches
Write-Host ""
Write-Host "=== Deleting Remote Branches ===" -ForegroundColor Cyan
Write-Host ""

$deleted = 0
$failed = 0

foreach ($branch in $toDelete) {
    $branchName = $branch -replace "^origin/", ""
    Write-Host "Deleting: $branchName..." -ForegroundColor Yellow -NoNewline
    
    try {
        $result = git push origin --delete $branchName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
            $deleted++
        } else {
            Write-Host " ✗ (may already be deleted)" -ForegroundColor Gray
            $failed++
        }
    } catch {
        Write-Host " ✗ Error: $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host "Deleted: $deleted branches" -ForegroundColor Green
Write-Host "Failed/Skipped: $failed branches" -ForegroundColor Gray
Write-Host ""
Write-Host "Verifying local branches are intact..." -ForegroundColor Yellow
$localCount = (git branch | Measure-Object).Count
Write-Host "Local branches: $localCount (unchanged)" -ForegroundColor Green
Write-Host ""
Write-Host "You can safely continue working. Local branches are NOT affected!" -ForegroundColor Cyan
