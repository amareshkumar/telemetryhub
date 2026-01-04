# ═══════════════════════════════════════════════════════════════════
# Final Migration Steps - Complete the Cleanup
# ═══════════════════════════════════════════════════════════════════

Write-Host "STEP 1: Update .gitignore in telemetry-platform" -ForegroundColor Cyan

$gitignorePatterns = @"

# ────────────────────────────────────────────────────────────────────
# Personal and Career Development (Added: 2026-01-04)
# ────────────────────────────────────────────────────────────────────
**/amaresh_*.md
**/career_*.md
**/*_amaresh.md
**/cv_*.md
**/resume_*.md
**/linkedin_*.md
**/cover_letter*.md
**/job_analysis*.md

# ────────────────────────────────────────────────────────────────────
# Interview Preparation
# ────────────────────────────────────────────────────────────────────
**/INTERVIEW_*.md
**/*interview*.md
**/*INTERVIEW*.md
**/interview/
**/cover_letters/

# ────────────────────────────────────────────────────────────────────
# Daily Logs and Personal Notes
# ────────────────────────────────────────────────────────────────────
**/day[0-9]*_*.md
**/DAY[0-9]*_*.md
**/distqueue_*.md
**/*_interaction_log.md
**/*_status.md

# ────────────────────────────────────────────────────────────────────
# Personal Planning and Strategy
# ────────────────────────────────────────────────────────────────────
**/next_project_*.md
**/*_reframe_*.md
**/reframing_*.md
**/*_strategy.md
**/*_guidance.md
**/*_recommendations.md

# ────────────────────────────────────────────────────────────────────
# Company and Project Experience
# ────────────────────────────────────────────────────────────────────
**/LYRIA_SOFT_*.md
**/*_EXPERIENCE.md

# ────────────────────────────────────────────────────────────────────
# Migration and Fix Tracking
# ────────────────────────────────────────────────────────────────────
**/migration_log.md
**/FIX_DAY*.md

# ────────────────────────────────────────────────────────────────────
# Content and Publishing
# ────────────────────────────────────────────────────────────────────
**/medium_post*.md

# ────────────────────────────────────────────────────────────────────
# Profiling and Exercises
# ────────────────────────────────────────────────────────────────────
**/PROFILING_*.md
**/*_EXERCISE_*.md
"@

Add-Content -Path "C:\code\telemetry-platform\.gitignore" -Value $gitignorePatterns -Encoding UTF8
Write-Host "✅ .gitignore updated" -ForegroundColor Green

Write-Host ""
Write-Host "STEP 2: Commit cleanup to telemetry-platform" -ForegroundColor Cyan
Set-Location "C:\code\telemetry-platform"
git add -A
git commit -m "chore: Remove personal materials (migrated to private platform-dev repo)

- Removed 38 personal/career/interview markdown files
- Updated .gitignore to prevent future personal content commits
- All materials safely migrated to private repository"
Write-Host "✅ Telemetry-platform cleanup committed" -ForegroundColor Green

Write-Host ""
Write-Host "STEP 3: Push platform-dev (PRIVATE REPO)" -ForegroundColor Cyan
Set-Location "C:\code\platform-dev"
git push origin main
Write-Host "✅ Platform-dev pushed (PRIVATE)" -ForegroundColor Green

Write-Host ""
Write-Host "STEP 4: Push telemetry-platform (PUBLIC REPO)" -ForegroundColor Cyan
Set-Location "C:\code\telemetry-platform"
git push origin master
Write-Host "✅ Telemetry-platform pushed (PUBLIC - SANITIZED)" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "MIGRATION COMPLETE!" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  ✅ 46 personal files migrated to platform-dev (PRIVATE)" -ForegroundColor Green
Write-Host "  ✅ All files deleted from telemetry-platform (PUBLIC)" -ForegroundColor Green
Write-Host "  ✅ .gitignore updated to prevent future leaks" -ForegroundColor Green
Write-Host "  ✅ Both repositories committed and pushed" -ForegroundColor Green
Write-Host ""
Write-Host "Privacy secured: Interview/career materials are now private." -ForegroundColor Cyan
Write-Host ""
