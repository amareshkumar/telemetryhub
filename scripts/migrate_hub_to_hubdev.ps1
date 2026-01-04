# ═══════════════════════════════════════════════════════════════════
# Hub to Hub-dev Migration Script
# Pattern B: Personal-Only Private Repos (Matching Platform Pattern)
# ═══════════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 1: Discovering personal files in telemetryhub" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetryhub

# Find all personal/interview/sensitive files
$personalFiles = Get-ChildItem -Recurse -Filter "*.md" -File | Where-Object {
    $_.Name -match "(interview|Interview|INTERVIEW)" -or
    $_.Name -match "(senior|Senior|SENIOR)" -or
    $_.Name -match "(career|Career)" -or
    $_.Name -match "(day\d+|Day\d+|DAY\d+)" -or
    $_.FullName -match "archives\\career"
}

Write-Host ""
Write-Host "Found $($personalFiles.Count) personal files:" -ForegroundColor Yellow
$personalFiles | ForEach-Object {
    $relativePath = $_.FullName.Replace("$PWD\", "")
    Write-Host "  - $relativePath" -ForegroundColor Gray
}

# Create backup
Write-Host ""
Write-Host "Creating backup..." -ForegroundColor Yellow
$backupDir = "C:\code\telemetryhub_personal_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$personalFiles | ForEach-Object {
    $destPath = Join-Path $backupDir $_.Name
    Copy-Item $_.FullName $destPath -Force
}
Write-Host "✅ Backup created: $backupDir" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 2: Creating directory structure in telemetryhub-dev" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetryhub-dev

# Create organized directory structure (matching platform-dev pattern)
$directories = @(
    "interview",
    "interview/guides",
    "interview/tactical",
    "daily-logs",
    "planning",
    "career",
    "career/archives",
    "fixes"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "  Created: $dir" -ForegroundColor Gray
}

Write-Host "✅ Directory structure created" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 3: Migrating files to telemetryhub-dev" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Define file mapping (source -> destination in telemetryhub-dev)
$fileMappings = @{
    # Interview guides
    "docs\CODE_FLOW_INTERVIEW_GUIDE.md" = "interview\guides\CODE_FLOW_INTERVIEW_GUIDE.md"
    "docs\CPP_CODE_INTERVIEW_REFERENCE.md" = "interview\guides\CPP_CODE_INTERVIEW_REFERENCE.md"
    "docs\INTERVIEW_TACTICAL_GUIDE_TAMIS_JAN5.md" = "interview\tactical\INTERVIEW_TACTICAL_GUIDE_TAMIS_JAN5.md"
    "docs\telemetry_platform_interview_guide.md" = "interview\guides\telemetry_platform_interview_guide.md"
    "Pre_Interview_Feedback.md" = "interview\Pre_Interview_Feedback.md"
    "INTERVIEW_DOCS_MIGRATION_GUIDE.md" = "planning\INTERVIEW_DOCS_MIGRATION_GUIDE.md"
    
    # Career/Senior planning
    "docs\GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md" = "career\GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md"
    "docs\SENIOR_TO_ARCHITECT_JOURNEY.md" = "career\SENIOR_TO_ARCHITECT_JOURNEY.md"
    "SENIOR_LEVEL_TODO.md" = "planning\SENIOR_LEVEL_TODO.md"
    
    # Daily logs and fixes
    "docs\distqueue_day1_status.md" = "daily-logs\distqueue_day1_status.md"
    "docs\FIX_DAY19_ISSUE.md" = "fixes\FIX_DAY19_ISSUE.md"
    
    # Career archives directory (all files)
    "docs\archives\career-preparation\*" = "career\archives\"
}

$migratedCount = 0
$skippedCount = 0

foreach ($mapping in $fileMappings.GetEnumerator()) {
    $sourcePath = Join-Path "C:\code\telemetryhub" $mapping.Key
    $destPath = Join-Path "C:\code\telemetryhub-dev" $mapping.Value
    
    if ($mapping.Key -like "*\*") {
        # Handle wildcard (directory copy)
        $sourceDir = Split-Path $sourcePath -Parent
        $destDir = Split-Path $destPath -Parent
        
        if (Test-Path $sourceDir) {
            Get-ChildItem -Path $sourceDir -Filter "*.md" -File | ForEach-Object {
                $dest = Join-Path $destDir $_.Name
                Copy-Item $_.FullName $dest -Force
                Write-Host "  ✓ $($_.Name) → career/archives/" -ForegroundColor Green
                $script:migratedCount++
            }
        }
    } else {
        # Single file copy
        if (Test-Path $sourcePath) {
            $destDir = Split-Path $destPath -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item $sourcePath $destPath -Force
            $fileName = Split-Path $sourcePath -Leaf
            $destRel = $mapping.Value
            Write-Host "  ✓ $fileName → $destRel" -ForegroundColor Green
            $migratedCount++
        } else {
            Write-Host "  ⚠ Skipped (not found): $($mapping.Key)" -ForegroundColor DarkGray
            $skippedCount++
        }
    }
}

Write-Host ""
Write-Host "📊 Migration complete: $migratedCount files migrated, $skippedCount skipped" -ForegroundColor Cyan

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 4: Adding README to telemetryhub-dev" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

$readmeContent = @"
# TelemetryHub Private Materials

**Repository:** Private development and personal materials for [TelemetryHub](https://github.com/amareshkumar/telemetryhub)  
**Purpose:** Interview preparation, career planning, and daily development logs  
**Privacy:** This repository contains personal information and is NOT public

---

## Structure

\`\`\`
telemetryhub-dev/
├── interview/           # Interview preparation materials
│   ├── guides/          # Technical interview guides
│   └── tactical/        # Interview strategy and tactics
├── daily-logs/          # Day-by-day development progress
├── career/              # Career planning and strategy
│   └── archives/        # Historical career documents
├── planning/            # Project planning and TODOs
└── fixes/               # Issue tracking and resolution notes
\`\`\`

---

## Relationship to Public Repo

This repository follows **Pattern B: Personal-Only Private Repo**

| Repository | Type | Content |
|-----------|------|---------|
| [telemetryhub](https://github.com/amareshkumar/telemetryhub) | PUBLIC | Technical code, architecture docs, API references |
| telemetryhub-dev | PRIVATE | Interview prep, career notes, personal logs |

**Key Principle:** These repos serve completely different purposes and are never merged.

---

## Usage Guidelines

✅ **Do store here:**
- Interview preparation notes
- Career planning documents
- Daily development logs
- Personal strategy documents
- Job application materials

❌ **Don't store here:**
- Source code (belongs in public repo)
- Technical documentation (belongs in public repo)
- Anything that could be public

---

## Security

This repository is **private** and should remain so. It contains:
- Personal career thoughts
- Interview strategies
- Sensitive development notes

Never accidentally push these materials to the public telemetryhub repository.

---

**Created:** $(Get-Date -Format 'MMMM d, yyyy')  
**Migration:** From telemetryhub public repo (Pattern B standardization)  
**Related:** See [platform-dev](https://github.com/amareshkumar/platform-dev) for similar structure
"@

Set-Content -Path "C:\code\telemetryhub-dev\README.md" -Value $readmeContent -Encoding UTF8
Write-Host "✅ README.md created" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 5: Updating .gitignore in telemetryhub" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetryhub

$gitignorePatterns = @"

# ────────────────────────────────────────────────────────────────────
# Personal and Interview Materials (Added: $(Get-Date -Format 'yyyy-MM-dd'))
# Migrated to telemetryhub-dev (private repo)
# ────────────────────────────────────────────────────────────────────

# Interview preparation
docs/INTERVIEW_*.md
docs/*interview*.md
docs/*Interview*.md
docs/CPP_CODE_INTERVIEW_REFERENCE.md
docs/INTERVIEW_TACTICAL_GUIDE_*.md
docs/CODE_FLOW_INTERVIEW_GUIDE.md
docs/telemetry_platform_interview_guide.md
Pre_Interview_Feedback.md
INTERVIEW_*.md

# Career and senior-level planning
docs/SENIOR_TO_ARCHITECT_*.md
docs/GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md
SENIOR_LEVEL_TODO.md
**/career-preparation/

# Daily logs and personal notes
docs/day[0-9]*_*.md
docs/Day[0-9]*_*.md
docs/DAY[0-9]*_*.md
docs/distqueue_day*.md

# Fixes and issue tracking
docs/FIX_*.md
docs/GITHUB_CLEANUP_*.md

# Temporary and working files
COMMIT_NOW.md
DAILY_SUMMARY_*.md
*_backup_*.md

# Migration and planning documents
*MIGRATION*.md
PLATFORM_*.md
REPOSITORY_STRATEGY*.md
"@

Add-Content -Path ".gitignore" -Value $gitignorePatterns -Encoding UTF8
Write-Host "✅ .gitignore updated with personal file patterns" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 6: Committing to telemetryhub-dev" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetryhub-dev
git add -A
git status --short

Write-Host ""
Write-Host "Ready to commit. Press Enter to continue or Ctrl+C to abort..." -ForegroundColor Yellow
Read-Host

git commit -m "chore: Migrate personal materials from telemetryhub (Pattern B standardization)

- Add interview preparation guides and tactical documents
- Add career planning and senior-level strategy docs
- Add daily development logs and fix tracking
- Create organized directory structure matching platform-dev
- Add README documenting private repo purpose

Migration follows Pattern B (Personal-Only Private Repos):
- telemetryhub (public) = technical content only
- telemetryhub-dev (private) = personal materials only

Files migrated: ~$migratedCount documents
Backup location: $backupDir"

Write-Host ""
Write-Host "✅ Changes committed to telemetryhub-dev" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "MIGRATION SUMMARY" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "✅ Discovered: $($personalFiles.Count) personal files in telemetryhub" -ForegroundColor Green
Write-Host "✅ Migrated: $migratedCount files to telemetryhub-dev" -ForegroundColor Green
Write-Host "✅ Backup: $backupDir" -ForegroundColor Green
Write-Host "✅ Committed: telemetryhub-dev updated" -ForegroundColor Green
Write-Host "✅ .gitignore: Updated in telemetryhub" -ForegroundColor Green
Write-Host ""
Write-Host "⏭️  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Push telemetryhub-dev: cd C:\code\telemetryhub-dev; git push origin main" -ForegroundColor White
Write-Host "  2. Clean telemetryhub: Run cleanup script (will be generated next)" -ForegroundColor White
Write-Host "  3. Verify: Final audit of all 4 repos" -ForegroundColor White
Write-Host ""
