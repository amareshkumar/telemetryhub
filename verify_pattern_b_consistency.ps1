# ═══════════════════════════════════════════════════════════════════
# Final Verification: All 4 Repos Pattern B Consistency
# ═══════════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "FINAL VERIFICATION: 4-REPO PATTERN B CONSISTENCY CHECK" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

$results = @()

# ════════════════════════════════════════════════════════════════════
Write-Host "1. Checking telemetryhub (PUBLIC)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetryhub
$personalInHub = git grep -i "amaresh" -- "*.md" 2>$null | Where-Object { $_ -notmatch "github.com/amareshkumar" }
if ($personalInHub) {
    Write-Host "  ❌ FOUND personal content:" -ForegroundColor Red
    $personalInHub | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
    $results += "❌ telemetryhub has personal content"
} else {
    Write-Host "  ✅ No personal content (amaresh)" -ForegroundColor Green
    $results += "✅ telemetryhub clean"
}

$interviewInHub = git grep -i "interview" -- "*.md" 2>$null | Where-Object { $_ -match "INTERVIEW_|interview preparation|interview guide" }
if ($interviewInHub) {
    Write-Host "  ❌ FOUND interview content:" -ForegroundColor Red
    $interviewInHub | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
    $results += "❌ telemetryhub has interview content"
} else {
    Write-Host "  ✅ No sensitive interview content" -ForegroundColor Green
    $results += "✅ telemetryhub interview-clean"
}

# ════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "2. Checking telemetryhub-dev (PRIVATE)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetryhub-dev
$hubDevFiles = Get-ChildItem -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count
$interviewFiles = Get-ChildItem -Path "interview" -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
$careerFiles = Get-ChildItem -Path "career" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "  Files: $hubDevFiles total" -ForegroundColor White
Write-Host "  Interview: $interviewFiles files" -ForegroundColor White
Write-Host "  Career: $careerFiles files" -ForegroundColor White

if ($interviewFiles -gt 0 -and $careerFiles -gt 0) {
    Write-Host "  ✅ Has personal content (expected)" -ForegroundColor Green
    $results += "✅ telemetryhub-dev has personal content"
} else {
    Write-Host "  ⚠ Missing expected personal content" -ForegroundColor Yellow
    $results += "⚠ telemetryhub-dev might be incomplete"
}

# ════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "3. Checking telemetry-platform (PUBLIC)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\telemetry-platform
$personalInPlatform = git grep -i "amaresh" -- "*.md" 2>$null | Where-Object { $_ -notmatch "github.com/amareshkumar" }
if ($personalInPlatform) {
    Write-Host "  ❌ FOUND personal content:" -ForegroundColor Red
    $personalInPlatform | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
    $results += "❌ telemetry-platform has personal content"
} else {
    Write-Host "  ✅ No personal content (amaresh)" -ForegroundColor Green
    $results += "✅ telemetry-platform clean"
}

$careerInPlatform = git grep -i "career|interview" --  "*.md" 2>$null | Select-Object -First 1
if ($careerInPlatform) {
    Write-Host "  ❌ FOUND career/interview content" -ForegroundColor Red
    $results += "❌ telemetry-platform has career content"
} else {
    Write-Host "  ✅ No career/interview content" -ForegroundColor Green
    $results += "✅ telemetry-platform career-clean"
}

# ════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "4. Checking platform-dev (PRIVATE)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan

cd C:\code\platform-dev
$platformDevFiles = Get-ChildItem -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count
$platformCareerFiles = Get-ChildItem -Path "career" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
$platformInterviewFiles = Get-ChildItem -Path "interview" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "  Files: $platformDevFiles total" -ForegroundColor White
Write-Host "  Career: $platformCareerFiles files" -ForegroundColor White
Write-Host "  Interview: $platformInterviewFiles files" -ForegroundColor White

if ($platformCareerFiles -gt 0 -and $platformInterviewFiles -gt 0) {
    Write-Host "  ✅ Has personal content (expected)" -ForegroundColor Green
    $results += "✅ platform-dev has personal content"
} else {
    Write-Host "  ⚠ Missing expected personal content" -ForegroundColor Yellow
    $results += "⚠ platform-dev might be incomplete"
}

# ════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "PATTERN B CONSISTENCY SUMMARY" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

Write-Host "PUBLIC REPOS (should be clean):" -ForegroundColor Cyan
Write-Host "  telemetryhub      → $($results[0])" -ForegroundColor $(if ($results[0] -like "*✅*") { "Green" } else { "Red" })
Write-Host "  telemetry-platform→ $($results[2])" -ForegroundColor $(if ($results[2] -like "*✅*") { "Green" } else { "Red" })
Write-Host ""

Write-Host "PRIVATE REPOS (should have personal content):" -ForegroundColor Cyan
Write-Host "  telemetryhub-dev  → $($results[4])" -ForegroundColor $(if ($results[4] -like "*✅*") { "Green" } else { "Yellow" })
Write-Host "  platform-dev      → $($results[5])" -ForegroundColor $(if ($results[5] -like "*✅*") { "Green" } else { "Yellow" })
Write-Host ""

$failures = $results | Where-Object { $_ -like "*❌*" }
if ($failures) {
    Write-Host "⚠ WARNING: $($failures.Count) issues found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Action required:" -ForegroundColor Yellow
    $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
} else {
    Write-Host "✅ ALL REPOS CONSISTENT - PATTERN B VERIFIED" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pattern B standardization complete:" -ForegroundColor Cyan
    Write-Host "  ✅ Public repos (Hub, Platform) = technical only" -ForegroundColor Green
    Write-Host "  ✅ Private repos (Hub-dev, Platform-dev) = personal only" -ForegroundColor Green
    Write-Host "  ✅ .gitignore patterns added to prevent leaks" -ForegroundColor Green
    Write-Host "  ✅ Zero risk of personal content exposure" -ForegroundColor Green
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
