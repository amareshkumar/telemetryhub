# Safe Local Git Branch Cleanup Script
# Removes local branches that are already merged to main

Write-Host "=== Local Branch Cleanup ===" -ForegroundColor Cyan
Write-Host ""

# Get current branch
$currentBranch = git rev-parse --abbrev-ref HEAD

# Branches to ALWAYS keep
$protectedBranches = @(
    "main",
    "repo-organization-jan2026"
)

Write-Host "Current branch: $currentBranch" -ForegroundColor Green
Write-Host "Protected branches: $($protectedBranches -join ', ')" -ForegroundColor Green
Write-Host ""

# Get all local branches
$allBranches = git branch | ForEach-Object { $_.Trim().Replace('* ', '') }

# Filter out protected branches and current branch
$candidateForDeletion = $allBranches | Where-Object {
    $_ -notin $protectedBranches -and $_ -ne $currentBranch
}

if ($candidateForDeletion.Count -eq 0) {
    Write-Host "✓ No branches to delete!" -ForegroundColor Green
    exit 0
}

Write-Host "Analyzing $($candidateForDeletion.Count) branches..." -ForegroundColor Yellow
Write-Host ""

# Categorize branches
$merged = @()
$notMerged = @()

foreach ($branch in $candidateForDeletion) {
    # Check if branch is merged into main
    $isMerged = git branch --merged main | ForEach-Object { $_.Trim().Replace('* ', '') } | Where-Object { $_ -eq $branch }
    
    if ($isMerged) {
        $merged += $branch
        Write-Host "  ✓ $branch (merged)" -ForegroundColor Green
    } else {
        $notMerged += $branch
        Write-Host "  ⚠ $branch (has unique commits)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  • $($merged.Count) branches merged to main (SAFE to delete)" -ForegroundColor Green
Write-Host "  • $($notMerged.Count) branches NOT merged (may lose work)" -ForegroundColor Yellow
Write-Host ""

# Delete merged branches
if ($merged.Count -gt 0) {
    Write-Host "Delete $($merged.Count) merged branches? (y/N): " -ForegroundColor Cyan -NoNewline
    $confirm = Read-Host
    
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        Write-Host ""
        Write-Host "Deleting merged branches..." -ForegroundColor Cyan
        $deleted = 0
        
        foreach ($branch in $merged) {
            git branch -d $branch 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Deleted: $branch" -ForegroundColor Green
                $deleted++
            } else {
                Write-Host "  ✗ Failed: $branch" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "✓ Deleted $deleted/$($merged.Count) branches" -ForegroundColor Green
    } else {
        Write-Host "Cancelled." -ForegroundColor Yellow
    }
}

# Handle unmerged branches
if ($notMerged.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠ Unmerged branches found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  1. Keep them (safe, recommended)" -ForegroundColor Green
    Write-Host "  2. Force delete (WILL LOSE unique commits)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Your choice (1/2): " -ForegroundColor Cyan -NoNewline
    $choice = Read-Host
    
    if ($choice -eq '2') {
        Write-Host ""
        Write-Host "Type 'DELETE UNMERGED' to confirm force deletion: " -ForegroundColor Red -NoNewline
        $forceConfirm = Read-Host
        
        if ($forceConfirm -eq 'DELETE UNMERGED') {
            Write-Host ""
            Write-Host "Force deleting..." -ForegroundColor Red
            $forceDeleted = 0
            
            foreach ($branch in $notMerged) {
                git branch -D $branch 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Force deleted: $branch" -ForegroundColor Yellow
                    $forceDeleted++
                }
            }
            
            Write-Host ""
            Write-Host "Force deleted $forceDeleted branches" -ForegroundColor Yellow
        } else {
            Write-Host "Cancelled." -ForegroundColor Green
        }
    } else {
        Write-Host "Keeping unmerged branches (safe choice!)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Remaining local branches:" -ForegroundColor Cyan
git branch
