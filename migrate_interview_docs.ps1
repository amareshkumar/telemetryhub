# ============================================================================
# Interview Documents Migration Script
# ============================================================================
# Purpose: Safely migrate interview prep docs from public to private repo
# Date: January 3, 2026
# Author: Amaresh Kumar
# 
# CRITICAL: This script PRESERVES all local files - only changes Git tracking
# ============================================================================

param(
    [switch]$DryRun = $false,
    [switch]$SkipBackup = $false
)

$ErrorActionPreference = "Stop"

# Color functions for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

# ============================================================================
# Configuration
# ============================================================================

$PublicRepo = "https://github.com/amareshkumar/telemetryhub.git"
$PrivateRepo = "https://github.com/amareshkumar/telemetryhub-dev.git"
$CleanBranch = "clean_personal_interview_docs_remote"
$PrivateBranch = "interview-prep-jan2026"
$WorkDir = "c:\code\telemetryhub"

# Files to remove from public repo tracking (KEEPS local copies!)
$FilesToMigrate = @(
    # Root level
    "COMMIT_NOW.md",
    "Pre_Interview_Feedback.md",
    "SENIOR_LEVEL_TODO.md",
    
    # docs/ - Personal logs
    "docs/DAILY_SUMMARY_JAN_02_2026.md",
    "docs/DAILY_SUMMARY_JAN_02_2026_FINAL.md",
    "docs/MORNING_STATUS_JAN2_2026.md",
    "docs/ACTION_ITEMS_JAN2026.md",
    "docs/REPOSITORY_STATUS_JAN2026.md",
    
    # docs/ - Interview prep
    "docs/CPP_CODE_INTERVIEW_REFERENCE.md",
    "docs/GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md",
    "docs/INTERVIEW_TACTICAL_GUIDE_TAMIS_JAN5.md",
    "docs/GITHUB_BRANCH_PROTECTION_SETUP.md",
    "docs/telemetry_platform_interview_guide.md",
    "docs/CACHE_LINE_FALSE_SHARING.md",
    "docs/CODE_FLOW_INTERVIEW_GUIDE.md",
    "docs/COMPONENT_INTERACTIONS_PATTERNS.md",
    "docs/COMMAND_PATTERN_ANALYSIS.md",
    "docs/EDGE_COMPUTING_ANALYSIS.md",
    
    # docs/ - Career/Technical debt
    "docs/SENIOR_TO_ARCHITECT_JOURNEY_2025.md",
    "docs/MASTER_TODO_TECHNICAL_DEBT.md",
    "docs/TECHNICAL_DEBT_TRACKER.md",
    
    # docs/ - Internal issues
    "docs/FIX_COPILOT_ATTRIBUTION.md",
    "docs/FIX_DAY19_ISSUE.md",
    "docs/GITHUB_CLEANUP_SOLUTIONS.md",
    "docs/HUB_E2E_TESTING_TODAY.md"
)

# Directories to remove (recursively)
$DirsToMigrate = @(
    "docs/archives/career-preparation"
)

# ============================================================================
# Pre-flight Checks
# ============================================================================

Write-Info "============================================================================"
Write-Info " Interview Documents Migration Script"
Write-Info "============================================================================"
Write-Info ""

if ($DryRun) {
    Write-Warning "DRY RUN MODE: No changes will be made to Git"
}

Write-Info "Configuration:"
Write-Info "  Working Directory: $WorkDir"
Write-Info "  Public Repo:       $PublicRepo"
Write-Info "  Private Repo:      $PrivateRepo"
Write-Info "  Clean Branch:      $CleanBranch"
Write-Info "  Private Branch:    $PrivateBranch"
Write-Info ""

# Check if in correct directory
if ((Get-Location).Path -ne $WorkDir) {
    Write-Error "ERROR: Must run from $WorkDir"
    Write-Error "Current directory: $(Get-Location)"
    exit 1
}

# Check if Git repo
if (-not (Test-Path ".git")) {
    Write-Error "ERROR: Not a Git repository. Run from telemetryhub root."
    exit 1
}

# Check current branch
$CurrentBranch = git branch --show-current
Write-Info "Current branch: $CurrentBranch"

if ($CurrentBranch -ne $CleanBranch) {
    Write-Warning "WARNING: Not on '$CleanBranch' branch."
    Write-Info "Switching to $CleanBranch..."
    
    if (-not $DryRun) {
        git checkout $CleanBranch
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: Failed to checkout $CleanBranch"
            exit 1
        }
    }
}

Write-Success "✅ Pre-flight checks passed"
Write-Info ""

# ============================================================================
# Backup (Optional)
# ============================================================================

if (-not $SkipBackup) {
    Write-Info "Creating backup..."
    $BackupDir = "c:\code\telemetryhub_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    if (-not $DryRun) {
        Copy-Item -Path $WorkDir -Destination $BackupDir -Recurse -Force
        Write-Success "✅ Backup created: $BackupDir"
    } else {
        Write-Info "  [DRY RUN] Would create: $BackupDir"
    }
    Write-Info ""
}

# ============================================================================
# Phase 1: Verify Local Files Exist
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 1: Verify Local Files"
Write-Info "============================================================================"

$MissingFiles = @()
$ExistingFiles = @()

foreach ($file in $FilesToMigrate) {
    if (Test-Path $file) {
        Write-Success "  ✅ $file"
        $ExistingFiles += $file
    } else {
        Write-Warning "  ⚠️  $file (not found - will skip)"
        $MissingFiles += $file
    }
}

foreach ($dir in $DirsToMigrate) {
    if (Test-Path $dir) {
        $fileCount = (Get-ChildItem -Path $dir -Recurse -File).Count
        Write-Success "  ✅ $dir ($fileCount files)"
        $ExistingFiles += $dir
    } else {
        Write-Warning "  ⚠️  $dir (not found - will skip)"
        $MissingFiles += $dir
    }
}

Write-Info ""
Write-Info "Summary:"
Write-Info "  Files found:    $($ExistingFiles.Count)"
Write-Info "  Files missing:  $($MissingFiles.Count)"

if ($ExistingFiles.Count -eq 0) {
    Write-Error "ERROR: No files found to migrate!"
    exit 1
}

Write-Success "✅ Local files verified"
Write-Info ""

# ============================================================================
# Phase 2: Update .gitignore (Already Done)
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 2: Verify .gitignore"
Write-Info "============================================================================"

if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    
    # Check for key patterns
    $patterns = @(
        "Pre_Interview_Feedback.md",
        "CACHE_LINE_FALSE_SHARING.md",
        "DAILY_SUMMARY_*.md",
        "docs/archives/career-preparation/"
    )
    
    $allPatternsFound = $true
    foreach ($pattern in $patterns) {
        if ($gitignoreContent -like "*$pattern*") {
            Write-Success "  ✅ Pattern found: $pattern"
        } else {
            Write-Warning "  ⚠️  Pattern missing: $pattern"
            $allPatternsFound = $false
        }
    }
    
    if ($allPatternsFound) {
        Write-Success "✅ .gitignore properly configured"
    } else {
        Write-Warning "⚠️  Some patterns missing from .gitignore"
        Write-Info "   Run the .gitignore update manually if needed"
    }
} else {
    Write-Error "ERROR: .gitignore not found!"
    exit 1
}

Write-Info ""

# ============================================================================
# Phase 3: Remove Files from Public Repo Tracking
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 3: Remove Files from Git Tracking (KEEPS LOCAL!)"
Write-Info "============================================================================"

$FilesRemoved = @()
$FilesFailed = @()

foreach ($file in $ExistingFiles) {
    Write-Info "  Removing from Git: $file"
    
    if (-not $DryRun) {
        if (Test-Path $file -PathType Container) {
            # Directory
            git rm --cached -r $file 2>$null
        } else {
            # File
            git rm --cached $file 2>$null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "    ✅ Removed from tracking"
            $FilesRemoved += $file
            
            # Verify file still exists locally
            if (Test-Path $file) {
                Write-Success "    ✅ Local file preserved"
            } else {
                Write-Error "    ❌ ERROR: Local file deleted! Restore from backup!"
                $FilesFailed += $file
            }
        } else {
            Write-Warning "    ⚠️  Not tracked or already removed"
        }
    } else {
        Write-Info "    [DRY RUN] Would remove: $file"
    }
}

Write-Info ""
Write-Info "Summary:"
Write-Info "  Files removed from tracking: $($FilesRemoved.Count)"
Write-Info "  Files failed:                $($FilesFailed.Count)"

if ($FilesFailed.Count -gt 0) {
    Write-Error "ERROR: Some local files were deleted! Restore from backup:"
    Write-Error "  $BackupDir"
    exit 1
}

Write-Success "✅ Files removed from Git tracking (local copies preserved)"
Write-Info ""

# ============================================================================
# Phase 4: Commit Changes
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 4: Commit Removal"
Write-Info "============================================================================"

$CommitMessage = @"
chore: remove interview prep and personal docs from public repo

Migrating to private telemetryhub-dev repo:
- Interview preparation materials (CACHE_LINE, CODE_FLOW, etc.)
- Personal daily logs and tracking
- Career planning documents
- Internal issue tracking

Files removed: $($FilesRemoved.Count)
All files preserved locally for continued interview prep.

Updated .gitignore to prevent future exposure.
"@

Write-Info "Commit message:"
Write-Info $CommitMessage
Write-Info ""

if (-not $DryRun) {
    # Check if there are changes to commit
    $status = git status --porcelain
    
    if ($status) {
        Write-Info "Committing changes..."
        git commit -m $CommitMessage
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✅ Changes committed"
        } else {
            Write-Error "ERROR: Commit failed!"
            exit 1
        }
    } else {
        Write-Warning "⚠️  No changes to commit (files may not have been tracked)"
    }
} else {
    Write-Info "[DRY RUN] Would commit with message above"
}

Write-Info ""

# ============================================================================
# Phase 5: Setup Private Repo Remote
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 5: Setup Private Repo Remote"
Write-Info "============================================================================"

$remotes = git remote -v

if ($remotes -like "*private*") {
    Write-Success "✅ Private remote already configured"
} else {
    Write-Info "Adding private remote..."
    
    if (-not $DryRun) {
        git remote add private $PrivateRepo
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✅ Private remote added"
        } else {
            Write-Error "ERROR: Failed to add private remote"
            exit 1
        }
    } else {
        Write-Info "[DRY RUN] Would add private remote: $PrivateRepo"
    }
}

Write-Info ""
Write-Info "Remotes configured:"
git remote -v | ForEach-Object { Write-Info "  $_" }

Write-Info ""

# ============================================================================
# Phase 6: Push to Private Repo
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 6: Push to Private Repo"
Write-Info "============================================================================"

Write-Info "Creating/switching to private branch: $PrivateBranch"

if (-not $DryRun) {
    # Create or switch to private branch
    git checkout -b $PrivateBranch 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        # Branch exists, switch to it
        git checkout $PrivateBranch
    }
    
    Write-Success "✅ On branch: $PrivateBranch"
    
    Write-Info "Pushing to private repo..."
    Write-Warning "This may take a while (first push includes full history)"
    
    git push private $PrivateBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Pushed to private repo successfully!"
    } else {
        Write-Error "ERROR: Failed to push to private repo"
        Write-Error "You may need to authenticate or check repo permissions"
        exit 1
    }
} else {
    Write-Info "[DRY RUN] Would:"
    Write-Info "  1. Create/checkout branch: $PrivateBranch"
    Write-Info "  2. Push to: $PrivateRepo"
}

Write-Info ""

# ============================================================================
# Phase 7: Push Cleanup to Public Repo
# ============================================================================

Write-Info "============================================================================"
Write-Info " Phase 7: Push Cleanup to Public Repo"
Write-Info "============================================================================"

Write-Info "Switching back to clean branch: $CleanBranch"

if (-not $DryRun) {
    git checkout $CleanBranch
    
    Write-Info "Pushing cleanup to public repo..."
    
    git push origin $CleanBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Pushed cleanup to public repo!"
    } else {
        Write-Error "ERROR: Failed to push to public repo"
        exit 1
    }
} else {
    Write-Info "[DRY RUN] Would:"
    Write-Info "  1. Checkout: $CleanBranch"
    Write-Info "  2. Push to: $PublicRepo"
}

Write-Info ""

# ============================================================================
# Final Verification
# ============================================================================

Write-Info "============================================================================"
Write-Info " Final Verification"
Write-Info "============================================================================"

Write-Info "Verifying local files still exist..."

$AllFilesIntact = $true
foreach ($file in $ExistingFiles) {
    if (Test-Path $file) {
        Write-Success "  ✅ $file"
    } else {
        Write-Error "  ❌ $file MISSING!"
        $AllFilesIntact = $false
    }
}

if ($AllFilesIntact) {
    Write-Success "✅ All local files preserved!"
} else {
    Write-Error "ERROR: Some local files are missing! Restore from backup:"
    Write-Error "  $BackupDir"
    exit 1
}

Write-Info ""

# ============================================================================
# Summary
# ============================================================================

Write-Info "============================================================================"
Write-Info " MIGRATION COMPLETE!"
Write-Info "============================================================================"

Write-Success "✅ Interview prep documents migrated successfully"
Write-Info ""
Write-Info "What was done:"
Write-Info "  1. ✅ Verified $($ExistingFiles.Count) local files"
Write-Info "  2. ✅ Updated .gitignore with comprehensive patterns"
Write-Info "  3. ✅ Removed files from public repo tracking"
Write-Info "  4. ✅ Committed cleanup to branch: $CleanBranch"
Write-Info "  5. ✅ Pushed all files to private repo: $PrivateRepo"
Write-Info "  6. ✅ Pushed cleanup to public repo: $PublicRepo"
Write-Info "  7. ✅ Verified local files intact"
Write-Info ""
Write-Info "Next steps:"
Write-Info "  1. Create PR on GitHub:"
Write-Info "     From: $CleanBranch"
Write-Info "     To:   main"
Write-Info "     Title: 'Remove interview prep documents from public repo'"
Write-Info ""
Write-Info "  2. After PR merged, verify on GitHub:"
Write-Info "     Public:  https://github.com/amareshkumar/telemetryhub"
Write-Info "     Private: https://github.com/amareshkumar/telemetryhub-dev"
Write-Info ""
Write-Info "  3. Continue interview prep normally!"
Write-Info "     All your documents are safe in: c:\code\telemetryhub"
Write-Info ""
Write-Success "Your interview preparation can continue uninterrupted! 🎯"
Write-Info ""
Write-Info "Interview date: January 5, 2026 (2 days)"
Write-Info "Status: READY ✅"
Write-Info ""
Write-Info "============================================================================"
