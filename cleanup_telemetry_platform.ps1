<#
.SYNOPSIS
    Remove personal/interview files from telemetry-platform after migration to platform-dev

.DESCRIPTION
    Phase 2 of migration: Safely remove personal materials from public telemetry-platform
    repository after they have been copied to private platform-dev.
    
    IMPORTANT: Only run this AFTER verifying files are in platform-dev and committed!

.PARAMETER SourcePath
    Path to telemetry-platform repository (default: C:\code\telemetry-platform)

.PARAMETER DryRun
    If specified, shows what would be deleted without actually removing files

.PARAMETER Force
    If specified, skips confirmation prompts (use with caution!)

.EXAMPLE
    .\cleanup_telemetry_platform.ps1 -DryRun
    Shows what would be deleted

.EXAMPLE
    .\cleanup_telemetry_platform.ps1
    Removes files with confirmation prompts

.NOTES
    Author: Generated for Amaresh Kumar
    Date: January 4, 2026
    WARNING: This script DELETES files. Ensure backup exists and platform-dev is updated!
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "C:\code\telemetry-platform",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
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
║      Telemetry-Platform Cleanup Script                          ║
║      Remove Personal Materials After Migration                  ║
╚══════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Red

Write-Warning "This script will DELETE files from telemetry-platform!"
Write-Info "Source: $SourcePath"
Write-Info "Mode: $(if($DryRun){'DRY RUN (no deletion)'}else{'LIVE DELETION'})"
Write-Host ""

# Safety check: Has migration been verified?
if (-not $DryRun -and -not $Force) {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  SAFETY CHECKLIST - Please confirm:" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ☐ Files have been copied to platform-dev" -ForegroundColor White
    Write-Host "  ☐ platform-dev changes have been committed and pushed" -ForegroundColor White
    Write-Host "  ☐ Backup directory exists and verified" -ForegroundColor White
    Write-Host "  ☐ You are ready to remove files from telemetry-platform" -ForegroundColor White
    Write-Host ""
    
    $confirmation = Read-Host "Have you completed all checklist items? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Warning "Aborting cleanup. Please complete migration verification first."
        exit 0
    }
}

# Validation
if (-not (Test-Path $SourcePath)) {
    Write-Error "Source path not found: $SourcePath"
    exit 1
}

if (-not (Test-Path "$SourcePath\.git")) {
    Write-Error "Source is not a git repository: $SourcePath"
    exit 1
}

# Files to delete (same list as migration script)
$filesToDelete = @(
    # Root level
    "LYRIA_SOFT_EXPERIENCE.md",
    "DAY5_RELEASE_NOTES.md",
    
    # docs/
    "docs\INTERVIEW_QUICK_REFERENCE.md",
    "docs\SYSTEM_ARCHITECTURE_INTERVIEW_GUIDE.md",
    "docs\PROFILING_EXERCISE_DAY5.md",
    "docs\TTP_COMPLETION_SPRINT.md",
    "docs\monorepo_migration_summary.md",
    
    # ingestion/docs/
    "ingestion\docs\amaresh_career_context.md",
    "ingestion\docs\career_decision_journal.md",
    "ingestion\docs\day19_career_strategy.md",
    "ingestion\docs\day19_cv_recommendations.md",
    "ingestion\docs\day19_interaction_log.md",
    "ingestion\docs\day19_interview_guidance.md",
    "ingestion\docs\cv_improvement_guide_amaresh.md",
    "ingestion\docs\cover_letter_booking_backend_engineer.md",
    "ingestion\docs\cover_letter_kubota_sensor_engineer.md",
    "ingestion\docs\cover_letters",
    "ingestion\docs\job_analysis_alpha_credit.md",
    "ingestion\docs\linkedin_about_natural.md",
    "ingestion\docs\linkedin_about_section.md",
    "ingestion\docs\linkedin_job_search_strategy.md",
    "ingestion\docs\medium_post_telemetryhub.md",
    "ingestion\docs\next_project_strategy.md",
    "ingestion\docs\reframing_complete_summary.md",
    "ingestion\docs\resume_content_updated_telemetrytaskprocessor.md",
    "ingestion\docs\telemetrytaskprocessor_reframe_plan.md",
    "ingestion\docs\distqueue_day1_status.md",
    "ingestion\docs\migration_log.md",
    "ingestion\docs\repository_structure_analysis.md"
)

# Statistics
$stats = @{
    FilesFound = 0
    FilesMissing = 0
    FilesDeleted = 0
}

Write-Host "`n📋 CLEANUP PLAN:" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

# Process each file
foreach ($file in $filesToDelete) {
    $fullPath = Join-Path $SourcePath $file
    
    if (-not (Test-Path $fullPath)) {
        Write-Host "  ⊗ Already gone: $file" -ForegroundColor DarkGray
        $stats.FilesMissing++
        continue
    }
    
    $stats.FilesFound++
    
    $icon = if(Test-Path $fullPath -PathType Container) {"📁"} else {"📄"}
    Write-Host "  $icon DELETE: $file" -ForegroundColor Yellow
    
    if ($DryRun) {
        continue
    }
    
    # Delete the file or directory
    Remove-Item -Path $fullPath -Recurse -Force
    $stats.FilesDeleted++
}

Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor DarkGray

# Statistics
Write-Host "📊 CLEANUP STATISTICS:" -ForegroundColor Cyan
Write-Host "  Files found:     $($stats.FilesFound)"
Write-Host "  Files deleted:   $($stats.FilesDeleted)"
Write-Host "  Already missing: $($stats.FilesMissing)"

if ($DryRun) {
    Write-Host "`n⚠️  DRY RUN COMPLETE - No files were actually deleted" -ForegroundColor Yellow
    Write-Host "   Run without -DryRun to execute cleanup" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Success "Cleanup completed!"

# Show next steps
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
Write-Host "1. Verify cleanup:" -ForegroundColor White
Write-Host "   git status" -ForegroundColor DarkGray
Write-Host "   # Should show deleted files" -ForegroundColor DarkGray
Write-Host ""
Write-Host "2. Search for remaining personal content:" -ForegroundColor White
Write-Host "   git grep -i 'amaresh' -- '*.md'" -ForegroundColor DarkGray
Write-Host "   git grep -i 'interview' -- '*.md'" -ForegroundColor DarkGray
Write-Host "   git grep -i 'career' -- '*.md'" -ForegroundColor DarkGray
Write-Host ""
Write-Host "3. Update .gitignore (see PLATFORM_DEV_MIGRATION_PLAN.md)" -ForegroundColor White
Write-Host ""
Write-Host "4. Commit changes:" -ForegroundColor White
Write-Host "   git add -A" -ForegroundColor DarkGray
Write-Host "   git commit -m 'chore: Remove personal materials (migrated to platform-dev)'" -ForegroundColor DarkGray
Write-Host "   git push origin master" -ForegroundColor DarkGray
Write-Host ""

Write-Success "Cleanup script completed!"
