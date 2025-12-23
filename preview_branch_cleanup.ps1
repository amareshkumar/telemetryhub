# Preview Remote Branch Cleanup (Dry Run)
# Shows what WOULD be deleted without actually deleting anything

Write-Host "=== TelemetryHub Remote Branch Preview (DRY RUN) ===" -ForegroundColor Cyan
Write-Host "This script only SHOWS what would be deleted. Nothing is actually deleted." -ForegroundColor Green
Write-Host ""

# Change to repo directory
Set-Location C:\code\telemetryhub

# Fetch latest
Write-Host "Fetching latest from origin..." -ForegroundColor Yellow
git fetch origin --prune 2>&1 | Out-Null
Write-Host ""

# Get all remote branches
$allRemote = git branch -r | ForEach-Object { $_.Trim() } | Where-Object { $_ -notlike "origin/HEAD*" }
Write-Host "📊 Total remote branches: $($allRemote.Count)" -ForegroundColor Cyan
Write-Host ""

# Protected branches
$protected = @(
    "origin/main",
    "origin/main-backup", 
    "origin/main-cleanup",
    "origin/HEAD"
)

# Active work
$active = @(
    "origin/release-v4.1.0",  # PR #83
    "origin/day17-clean"
)

# Get merged branches
$merged = git branch -r --merged origin/main | ForEach-Object { $_.Trim() } | Where-Object { $_ -notlike "origin/HEAD*" }

# Categorize branches
$willDelete = @()
$willKeepProtected = @()
$willKeepActive = @()
$willKeepUnmerged = @()

foreach ($branch in $allRemote) {
    $name = $branch -replace "^origin/", ""
    
    if ($protected -contains $branch) {
        $willKeepProtected += $name
    }
    elseif ($active -contains $branch) {
        $willKeepActive += $name
    }
    elseif ($merged -contains $branch -and $branch -ne "origin/main") {
        $willDelete += $name
    }
    else {
        $willKeepUnmerged += $name
    }
}

# Display results
Write-Host "=== PROTECTED BRANCHES (Never Deleted) ===" -ForegroundColor Green
$willKeepProtected | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }
Write-Host ""

Write-Host "=== ACTIVE WORK (Keep for now) ===" -ForegroundColor Yellow
$willKeepActive | ForEach-Object { Write-Host "  🔨 $_" -ForegroundColor Yellow }
Write-Host ""

Write-Host "=== NOT YET MERGED (Keep) ===" -ForegroundColor Cyan
if ($willKeepUnmerged.Count -gt 0) {
    $willKeepUnmerged | ForEach-Object { Write-Host "  ⏳ $_" -ForegroundColor Cyan }
} else {
    Write-Host "  (none)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=== WOULD BE DELETED (Merged into main) ===" -ForegroundColor Red
if ($willDelete.Count -gt 0) {
    $willDelete | ForEach-Object { Write-Host "  ❌ $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Total to delete: $($willDelete.Count) branches" -ForegroundColor Red
} else {
    Write-Host "  (none - all branches are needed!)" -ForegroundColor Green
}
Write-Host ""

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total remote: $($allRemote.Count)" -ForegroundColor White
Write-Host "Protected: $($willKeepProtected.Count)" -ForegroundColor Green
Write-Host "Active work: $($willKeepActive.Count)" -ForegroundColor Yellow
Write-Host "Not merged: $($willKeepUnmerged.Count)" -ForegroundColor Cyan
Write-Host "Deletable: $($willDelete.Count)" -ForegroundColor Red
Write-Host ""

Write-Host "=== LOCAL BRANCHES (Always Safe) ===" -ForegroundColor Green
$localBranches = git branch | ForEach-Object { $_.Trim() -replace "^\* ", "" }
Write-Host "You have $($localBranches.Count) local branches that will NOT be affected" -ForegroundColor Green
Write-Host ""

if ($willDelete.Count -gt 0) {
    Write-Host "To actually delete these branches, run:" -ForegroundColor Yellow
    Write-Host "  .\cleanup_remote_branches.ps1" -ForegroundColor White
} else {
    Write-Host "✓ No cleanup needed! Your remote branches are well organized." -ForegroundColor Green
}
