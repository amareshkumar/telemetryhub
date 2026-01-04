<#
.SYNOPSIS
    Migrate personal and interview materials from telemetry-platform to platform-dev

.DESCRIPTION
    This script safely migrates personal, career, and interview-related documents
    from the public telemetry-platform repository to the private platform-dev repository.
    
    Similar to telemetryhub-dev split, this keeps personal materials private while
    maintaining technical content in the public repository.

.PARAMETER SourcePath
    Path to telemetry-platform repository (default: C:\code\telemetry-platform)

.PARAMETER DestPath
    Path to platform-dev repository (default: C:\code\platform-dev)

.PARAMETER DryRun
    If specified, shows what would be migrated without actually moving files

.PARAMETER SkipBackup
    If specified, skips creating backup directory (NOT RECOMMENDED)

.EXAMPLE
    .\migrate_platform_to_dev.ps1 -DryRun
    Shows migration plan without executing

.EXAMPLE
    .\migrate_platform_to_dev.ps1
    Executes full migration with backup

.NOTES
    Author: Generated for Amaresh Kumar
    Date: January 4, 2026
    Reason: Increasing traffic on public repos - keep personal work process private
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "C:\code\telemetry-platform",
    
    [Parameter(Mandatory=$false)]
    [string]$DestPath = "C:\code\platform-dev",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBackup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Color output functions
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }

# Banner
Write-Host @"
╔══════════════════════════════════════════════════════════════════╗
║      Platform-Dev Migration Script                               ║
║      Migrate Personal Materials to Private Repository            ║
╚══════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Info "Source: $SourcePath"
Write-Info "Destination: $DestPath"
Write-Info "Mode: $(if($DryRun){'DRY RUN (no changes)'}else{'LIVE MIGRATION'})"
Write-Host ""

# Validation
if (-not (Test-Path $SourcePath)) {
    Write-Error "Source path not found: $SourcePath"
    exit 1
}

if (-not (Test-Path $DestPath)) {
    Write-Error "Destination path not found: $DestPath"
    Write-Warning "Please ensure platform-dev is cloned to: $DestPath"
    exit 1
}

# Check if repos are git repositories
if (-not (Test-Path "$SourcePath\.git")) {
    Write-Error "Source is not a git repository: $SourcePath"
    exit 1
}

if (-not (Test-Path "$DestPath\.git")) {
    Write-Error "Destination is not a git repository: $DestPath"
    exit 1
}

# Migration mapping: source file/folder => destination subdirectory
$migrationMap = @(
    # Root level files
    @{
        Source = "LYRIA_SOFT_EXPERIENCE.md"
        Dest = "experience"
        Description = "Work experience documentation"
    },
    @{
        Source = "DAY5_RELEASE_NOTES.md"
        Dest = "daily-logs"
        Description = "Daily release notes"
    },
    
    # docs/ files
    @{
        Source = "docs\INTERVIEW_QUICK_REFERENCE.md"
        Dest = "interview"
        Description = "Interview quick reference"
    },
    @{
        Source = "docs\SYSTEM_ARCHITECTURE_INTERVIEW_GUIDE.md"
        Dest = "interview"
        Description = "System architecture interview guide"
    },
    @{
        Source = "docs\PROFILING_EXERCISE_DAY5.md"
        Dest = "exercises"
        Description = "Profiling exercise"
    },
    @{
        Source = "docs\TTP_COMPLETION_SPRINT.md"
        Dest = "planning"
        Description = "Sprint tracking"
    },
    @{
        Source = "docs\monorepo_migration_summary.md"
        Dest = "planning"
        Description = "Migration summary"
    },
    
    # ingestion/docs/ career files
    @{
        Source = "ingestion\docs\amaresh_career_context.md"
        Dest = "career"
        Description = "Career context"
    },
    @{
        Source = "ingestion\docs\career_decision_journal.md"
        Dest = "career"
        Description = "Career decision journal"
    },
    @{
        Source = "ingestion\docs\day19_career_strategy.md"
        Dest = "career"
        Description = "Career strategy"
    },
    @{
        Source = "ingestion\docs\day19_cv_recommendations.md"
        Dest = "career\cv"
        Description = "CV recommendations"
    },
    @{
        Source = "ingestion\docs\day19_interaction_log.md"
        Dest = "daily-logs"
        Description = "Interaction log"
    },
    @{
        Source = "ingestion\docs\day19_interview_guidance.md"
        Dest = "interview"
        Description = "Interview guidance"
    },
    @{
        Source = "ingestion\docs\cv_improvement_guide_amaresh.md"
        Dest = "career\cv"
        Description = "CV improvement guide"
    },
    @{
        Source = "ingestion\docs\cover_letter_booking_backend_engineer.md"
        Dest = "interview\cover-letters"
        Description = "Cover letter - Booking"
    },
    @{
        Source = "ingestion\docs\cover_letter_kubota_sensor_engineer.md"
        Dest = "interview\cover-letters"
        Description = "Cover letter - Kubota"
    },
    @{
        Source = "ingestion\docs\cover_letters"
        Dest = "interview"
        Description = "Cover letters directory"
    },
    @{
        Source = "ingestion\docs\job_analysis_alpha_credit.md"
        Dest = "job-applications"
        Description = "Job analysis - Alpha Credit"
    },
    @{
        Source = "ingestion\docs\linkedin_about_natural.md"
        Dest = "career\linkedin"
        Description = "LinkedIn about section (natural)"
    },
    @{
        Source = "ingestion\docs\linkedin_about_section.md"
        Dest = "career\linkedin"
        Description = "LinkedIn about section"
    },
    @{
        Source = "ingestion\docs\linkedin_job_search_strategy.md"
        Dest = "career\linkedin"
        Description = "LinkedIn job search strategy"
    },
    @{
        Source = "ingestion\docs\medium_post_telemetryhub.md"
        Dest = "content"
        Description = "Medium post draft"
    },
    @{
        Source = "ingestion\docs\next_project_strategy.md"
        Dest = "planning"
        Description = "Next project strategy"
    },
    @{
        Source = "ingestion\docs\reframing_complete_summary.md"
        Dest = "planning"
        Description = "Reframing summary"
    },
    @{
        Source = "ingestion\docs\resume_content_updated_telemetrytaskprocessor.md"
        Dest = "career\resume"
        Description = "Resume content"
    },
    @{
        Source = "ingestion\docs\telemetrytaskprocessor_reframe_plan.md"
        Dest = "planning"
        Description = "Reframe plan"
    },
    @{
        Source = "ingestion\docs\distqueue_day1_status.md"
        Dest = "daily-logs"
        Description = "Day 1 status"
    },
    @{
        Source = "ingestion\docs\migration_log.md"
        Dest = "planning"
        Description = "Migration log"
    },
    @{
        Source = "ingestion\docs\repository_structure_analysis.md"
        Dest = "planning"
        Description = "Repository structure analysis"
    }
)

# Create backup directory if not skipped
$backupPath = $null
if (-not $SkipBackup -and -not $DryRun) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = Join-Path $SourcePath "backup_migration_$timestamp"
    Write-Info "Creating backup directory: $backupPath"
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
}

# Statistics
$stats = @{
    FilesFound = 0
    FilesMissing = 0
    FilesSkipped = 0
    FilesCopied = 0
    DirsCreated = 0
}

Write-Host "`n📋 MIGRATION PLAN:" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

# Process each item in migration map
foreach ($item in $migrationMap) {
    $sourcePath = Join-Path $SourcePath $item.Source
    $destDir = Join-Path $DestPath $item.Dest
    
    # Check if source exists
    if (-not (Test-Path $sourcePath)) {
        Write-Warning "Not found: $($item.Source)"
        $stats.FilesMissing++
        continue
    }
    
    $stats.FilesFound++
    
    # Display migration plan
    $arrow = if($DryRun) {"→ (DRY RUN)"} else {"→"}
    Write-Host "  $($item.Description):" -ForegroundColor White
    Write-Host "    FROM: $($item.Source)" -ForegroundColor DarkGray
    Write-Host "    TO:   $($item.Dest)\" -ForegroundColor DarkGray
    
    if ($DryRun) {
        continue
    }
    
    # Create destination directory
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        $stats.DirsCreated++
    }
    
    # Copy to backup first
    if ($backupPath) {
        $backupDest = Join-Path $backupPath $item.Source
        $backupParent = Split-Path $backupDest -Parent
        if (-not (Test-Path $backupParent)) {
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
        }
        Copy-Item -Path $sourcePath -Destination $backupDest -Recurse -Force
    }
    
    # Copy to platform-dev
    $fileName = Split-Path $sourcePath -Leaf
    $destPath = Join-Path $destDir $fileName
    
    if (Test-Path $sourcePath -PathType Container) {
        # Directory - copy recursively
        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
    } else {
        # File - copy single file
        Copy-Item -Path $sourcePath -Destination $destPath -Force
    }
    
    $stats.FilesCopied++
}

Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor DarkGray

# Statistics
Write-Host "📊 MIGRATION STATISTICS:" -ForegroundColor Cyan
Write-Host "  Files found:     $($stats.FilesFound)"
Write-Host "  Files missing:   $($stats.FilesMissing)"
Write-Host "  Files copied:    $($stats.FilesCopied)"
Write-Host "  Directories created: $($stats.DirsCreated)"

if ($backupPath) {
    Write-Host "  Backup location: $backupPath" -ForegroundColor DarkGray
}

if ($DryRun) {
    Write-Host "`n⚠️  DRY RUN COMPLETE - No files were actually moved" -ForegroundColor Yellow
    Write-Host "   Run without -DryRun to execute migration" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Success "Migration to platform-dev completed!"

# Prompt for cleanup
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
Write-Host "1. Verify files in platform-dev:" -ForegroundColor White
Write-Host "   cd $DestPath" -ForegroundColor DarkGray
Write-Host "   git status" -ForegroundColor DarkGray
Write-Host "   git add -A" -ForegroundColor DarkGray
Write-Host "   git commit -m 'chore: Initial migration from telemetry-platform'" -ForegroundColor DarkGray
Write-Host "   git push origin main" -ForegroundColor DarkGray
Write-Host ""
Write-Host "2. Remove files from telemetry-platform:" -ForegroundColor White
Write-Host "   cd $SourcePath" -ForegroundColor DarkGray
Write-Host "   # Review backup in: $backupPath" -ForegroundColor DarkGray
Write-Host "   # Then delete migrated files (see PLATFORM_DEV_MIGRATION_PLAN.md)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "3. Update .gitignore in telemetry-platform" -ForegroundColor White
Write-Host "   # Add patterns from PLATFORM_DEV_MIGRATION_PLAN.md" -ForegroundColor DarkGray
Write-Host ""
Write-Host "4. Verify no personal content remains:" -ForegroundColor White
Write-Host "   git grep -i 'amaresh' -- '*.md'" -ForegroundColor DarkGray
Write-Host "   git grep -i 'interview' -- '*.md'" -ForegroundColor DarkGray
Write-Host ""

Write-Success "Migration script completed successfully!"
Write-Info "Backup preserved at: $backupPath"
