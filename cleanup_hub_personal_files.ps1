# ═══════════════════════════════════════════════════════════════════
# Cleanup Personal Files from TelemetryHub Public Repo
# Pattern B: Remove personal materials (now in telemetryhub-dev)
# ═══════════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Cleaning personal files from telemetryhub PUBLIC repo" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

cd C:\code\telemetryhub

# List of files to delete (migrated to telemetryhub-dev)
$filesToDelete = @(
    "docs\CODE_FLOW_INTERVIEW_GUIDE.md",
    "docs\CPP_CODE_INTERVIEW_REFERENCE.md",
    "docs\INTERVIEW_TACTICAL_GUIDE_TAMIS_JAN5.md",
    "docs\telemetry_platform_interview_guide.md",
    "Pre_Interview_Feedback.md",
    "docs\GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md",
    "docs\SENIOR_TO_ARCHITECT_JOURNEY.md",
    "SENIOR_LEVEL_TODO.md",
    "docs\distqueue_day1_status.md",
    "docs\FIX_DAY19_ISSUE.md",
    "INTERVIEW_DOCS_MIGRATION_GUIDE.md",
    "PLATFORM_MIGRATION_EXECUTION_GUIDE.md",
    "PLATFORM_DEV_MIGRATION_PLAN.md",
    "PLATFORM_DEV_README.md",
    "PLATFORM_MIGRATION_DELIVERABLES.md",
    "TELEMETRY_PLATFORM_GITIGNORE_ADDITIONS.txt",
    "REPOSITORY_STRATEGY_ANALYSIS.md"
)

$deleted = 0
$notFound = 0

Write-Host "Files to delete:" -ForegroundColor Yellow
foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  ✓ Deleted: $file" -ForegroundColor Green
        $deleted++
    } else {
        Write-Host "  ⚠ Not found: $file" -ForegroundColor DarkGray
        $notFound++
    }
}

# Delete career archives directory
if (Test-Path "docs\archives\career-preparation") {
    Remove-Item "docs\archives\career-preparation" -Recurse -Force
    Write-Host "  ✓ Deleted: docs\archives\career-preparation\" -ForegroundColor Green
    $deleted++
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Git status and commit" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

git status --short | Select-Object -First 40

Write-Host ""
Write-Host "Ready to commit cleanup? (Press Enter or Ctrl+C to abort)" -ForegroundColor Yellow
Read-Host

git add -A
git commit -m "chore: Remove personal materials (migrated to telemetryhub-dev)

Pattern B standardization: Separate technical (public) from personal (private)

Removed:
- Interview preparation guides (4 files + feedback)
- Career planning documents (GIT branching, senior-to-architect)
- Career archives directory (21 files)
- Daily development logs
- Fix tracking notes
- Migration planning documents

All materials safely migrated to telemetryhub-dev (private repo).
Updated .gitignore to prevent future personal file commits.

Repos now follow consistent Pattern B:
- telemetryhub (public) = technical only
- telemetryhub-dev (private) = personal only
- telemetry-platform (public) = technical only  
- platform-dev (private) = personal only"

Write-Host ""
Write-Host "✅ Cleanup committed to telemetryhub" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Deleted: $deleted files/directories" -ForegroundColor Green
Write-Host "  Not found: $notFound files" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Next: git push origin main (or your branch)" -ForegroundColor Cyan
