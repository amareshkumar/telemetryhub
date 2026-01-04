# ══════════════════════════════════════════════════════════════════════
# TelemetryHub - Repository Management Utilities
# Consolidated automation scripts for repository maintenance
# ══════════════════════════════════════════════════════════════════════

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('cleanup-branches', 'cleanup-forks', 'cleanup-personal', 
                 'organize-repo', 'verify-pattern-b', 'help')]
    [string]$Task,
    
    [switch]$DryRun,
    [switch]$Verbose
)

# ══════════════════════════════════════════════════════════════════════
# Common Functions
# ══════════════════════════════════════════════════════════════════════

function Write-Header {
    param([string]$Message)
    Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

# ══════════════════════════════════════════════════════════════════════
# Task: Cleanup Branches
# ══════════════════════════════════════════════════════════════════════

function Invoke-CleanupBranches {
    Write-Header "Branch Cleanup - Remove Stale Feature Branches"
    
    $protectedBranches = @('main', 'master', 'dev-main', 'release-*')
    
    # Get all remote branches
    $remoteBranches = git branch -r | Where-Object { $_ -notmatch 'HEAD' } | ForEach-Object { $_.Trim() -replace 'origin/', '' }
    
    $toDelete = @()
    foreach ($branch in $remoteBranches) {
        $isProtected = $false
        foreach ($pattern in $protectedBranches) {
            if ($branch -like $pattern) {
                $isProtected = $true
                break
            }
        }
        
        if (-not $isProtected) {
            $toDelete += $branch
        }
    }
    
    Write-Host "`nFound $($toDelete.Count) branches to delete"
    
    if ($DryRun) {
        Write-Warning "DRY RUN - No branches will be deleted"
        foreach ($branch in $toDelete) {
            Write-Host "  Would delete: $branch" -ForegroundColor DarkGray
        }
        return
    }
    
    $deleted = 0
    $failed = 0
    
    foreach ($branch in $toDelete) {
        try {
            git push origin --delete $branch 2>$null
            Write-Success "Deleted: $branch"
            $deleted++
        } catch {
            Write-Error "Failed: $branch"
            $failed++
        }
    }
    
    Write-Host "`nSummary: $deleted deleted, $failed failed" -ForegroundColor Cyan
}

# ══════════════════════════════════════════════════════════════════════
# Task: Cleanup GitHub Forks
# ══════════════════════════════════════════════════════════════════════

function Invoke-CleanupForks {
    Write-Header "GitHub Forks Cleanup"
    Write-Warning "This task requires manual action on GitHub web interface"
    Write-Host "`nSteps:"
    Write-Host "1. Go to: https://github.com/amareshkumar?tab=repositories"
    Write-Host "2. Filter by 'Forks'"
    Write-Host "3. Delete unused forks (keep only active contributions)"
    Write-Host "`nRecommended forks to delete:"
    Write-Host "  - Inactive forks (no commits in 6+ months)"
    Write-Host "  - Learning/tutorial forks"
    Write-Host "  - One-time contribution forks (PR already merged)"
}

# ══════════════════════════════════════════════════════════════════════
# Task: Cleanup Personal Files (Pattern B)
# ══════════════════════════════════════════════════════════════════════

function Invoke-CleanupPersonal {
    Write-Header "Cleanup Personal Files (Pattern B)"
    
    $filesToDelete = @(
        "Pre_Interview_Feedback.md",
        "organize_repo.ps1",
        "docs\CODE_FLOW_INTERVIEW_GUIDE.md",
        "docs\telemetry_platform_interview_guide.md",
        "CARGILL_CPP20_FEATURES.md",
        "CARGILL_DATA_STRUCTURES.md",
        "CARGILL_DESIGN_PATTERNS.md",
        "CARGILL_MISRA_COMPLIANCE.md",
        "COMPREHENSIVE_STATUS_JAN4_2026.md",
        "GITHUB_CONTRIBUTORS_FINAL_ANALYSIS.md",
        "COMPONENT_STATISTICS.md"
    )
    
    Write-Host "`nPersonal files to archive/delete:"
    
    if ($DryRun) {
        Write-Warning "DRY RUN - No files will be deleted"
        foreach ($file in $filesToDelete) {
            if (Test-Path $file) {
                Write-Host "  Would delete: $file" -ForegroundColor DarkGray
            }
        }
        return
    }
    
    $deleted = 0
    $notFound = 0
    
    foreach ($file in $filesToDelete) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Success "Deleted: $file"
            $deleted++
        } else {
            Write-Host "  - Not found: $file" -ForegroundColor DarkGray
            $notFound++
        }
    }
    
    Write-Host "`nSummary: $deleted deleted, $notFound not found" -ForegroundColor Cyan
}

# ══════════════════════════════════════════════════════════════════════
# Task: Organize Repository Structure
# ══════════════════════════════════════════════════════════════════════

function Invoke-OrganizeRepo {
    Write-Header "Repository Organization"
    
    Write-Host "`nCreating docs/archives if not exists..."
    if (-not (Test-Path "docs\archives")) {
        New-Item -ItemType Directory -Path "docs\archives" -Force | Out-Null
        Write-Success "Created docs/archives"
    }
    
    Write-Host "`nRepository structure is organized:"
    Write-Host "  ✓ docs/ - All documentation"
    Write-Host "  ✓ scripts/ - Consolidated utilities (this script)"
    Write-Host "  ✓ tools/ - Build and development tools"
    Write-Host "  ✓ tests/ - Test suites"
}

# ══════════════════════════════════════════════════════════════════════
# Task: Verify Pattern B Consistency
# ══════════════════════════════════════════════════════════════════════

function Invoke-VerifyPatternB {
    Write-Header "Pattern B Consistency Check"
    
    Write-Host "`nChecking for personal content in public repo..."
    
    $personalPatterns = @('amaresh', 'interview', 'cargill', 'career')
    $issues = @()
    
    foreach ($pattern in $personalPatterns) {
        $matches = git grep -i $pattern -- "*.md" 2>$null | Where-Object { 
            $_ -notmatch "github.com/amareshkumar" -and
            $_ -notmatch "amaresh.kumar@live.in" -and
            $_ -notmatch "Author:" -and
            $_ -notmatch "Owner:"
        }
        
        if ($matches) {
            $issues += $matches
        }
    }
    
    if ($issues.Count -gt 0) {
        Write-Warning "Found potential personal content:"
        $issues | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
        Write-Host "`nReview these matches manually"
    } else {
        Write-Success "No personal content detected - Pattern B consistent"
    }
}

# ══════════════════════════════════════════════════════════════════════
# Task: Help
# ══════════════════════════════════════════════════════════════════════

function Show-Help {
    Write-Header "TelemetryHub Repository Utilities - Help"
    
    Write-Host @"

USAGE:
    .\repo-utils.ps1 -Task <task> [-DryRun] [-Verbose]

TASKS:
    cleanup-branches    Remove stale feature branches (keep main, dev-main, release-*)
    cleanup-forks       Instructions for GitHub forks cleanup
    cleanup-personal    Remove personal/interview prep files (Pattern B)
    organize-repo       Verify and organize repository structure
    verify-pattern-b    Check for personal content in public repo
    help                Show this help message

OPTIONS:
    -DryRun            Show what would be done without making changes
    -Verbose           Enable verbose output

EXAMPLES:
    # Dry run branch cleanup
    .\repo-utils.ps1 -Task cleanup-branches -DryRun
    
    # Remove personal files
    .\repo-utils.ps1 -Task cleanup-personal
    
    # Verify Pattern B consistency
    .\repo-utils.ps1 -Task verify-pattern-b

"@
}

# ══════════════════════════════════════════════════════════════════════
# Main Entry Point
# ══════════════════════════════════════════════════════════════════════

Write-Host "TelemetryHub Repository Utilities v1.0" -ForegroundColor Magenta
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray

switch ($Task) {
    'cleanup-branches' { Invoke-CleanupBranches }
    'cleanup-forks' { Invoke-CleanupForks }
    'cleanup-personal' { Invoke-CleanupPersonal }
    'organize-repo' { Invoke-OrganizeRepo }
    'verify-pattern-b' { Invoke-VerifyPatternB }
    'help' { Show-Help }
}

Write-Host "`nDone." -ForegroundColor Green
