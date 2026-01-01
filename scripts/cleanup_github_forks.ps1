# Bulk Delete Forked Repositories from GitHub
# Requires: GitHub CLI (gh) installed and authenticated

Write-Host "=== GitHub Forked Repository Cleanup ===" -ForegroundColor Cyan
Write-Host ""

# Check if gh CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI (gh) is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install with:" -ForegroundColor Yellow
    Write-Host "  winget install --id GitHub.cli" -ForegroundColor White
    Write-Host ""
    Write-Host "Then authenticate with:" -ForegroundColor Yellow
    Write-Host "  gh auth login" -ForegroundColor White
    exit 1
}

# Check if authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated with GitHub!" -ForegroundColor Red
    Write-Host "Run: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ GitHub CLI authenticated" -ForegroundColor Green
Write-Host ""

# Repositories to KEEP (your original projects)
$keepRepos = @(
    "telemetryhub",
    "telemetry-platform",
    "OpendTect"
)

Write-Host "Repositories to KEEP:" -ForegroundColor Green
$keepRepos | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }
Write-Host ""

# Get all repositories (including visibility info)
Write-Host "Fetching your repositories..." -ForegroundColor Yellow
$allReposJson = gh repo list --json name,isFork,owner,visibility --limit 1000

if (-not $allReposJson) {
    Write-Host "ERROR: Failed to fetch repositories!" -ForegroundColor Red
    exit 1
}

$allRepos = $allReposJson | ConvertFrom-Json

# Filter: only YOUR repos (not org repos), only FORKS, and only PUBLIC
$yourForks = $allRepos | Where-Object { 
    $_.isFork -eq $true -and 
    $_.owner.login -eq "amareshkumar" -and
    $_.visibility -eq "PUBLIC" -and
    $_.name -notin $keepRepos
}

Write-Host "Found $($yourForks.Count) PUBLIC forked repositories to delete:" -ForegroundColor Yellow
Write-Host ""

if ($yourForks.Count -eq 0) {
    Write-Host "No PUBLIC forked repositories to delete!" -ForegroundColor Green
    exit 0
}

# Display list
$yourForks | ForEach-Object {
    Write-Host "  • $($_.name)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "WARNING: This will permanently delete these repositories!" -ForegroundColor Red
Write-Host "This action CANNOT be undone!" -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Type 'DELETE FORKS' to proceed (anything else to cancel)"

if ($confirmation -ne "DELETE FORKS") {
    Write-Host "Cancelled. No repositories deleted." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Deleting forked repositories..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0
$errors = @()

foreach ($repo in $yourForks) {
    $repoFullName = "amareshkumar/$($repo.name)"
    Write-Host "Deleting: $repoFullName" -ForegroundColor Gray
    
    # Delete repository
    gh repo delete $repoFullName --yes 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        $successCount++
        Write-Host "  ✓ Deleted: $repoFullName" -ForegroundColor Green
    } else {
        $failCount++
        $errors += "  ✗ Failed: $repoFullName"
        Write-Host "  ✗ Failed: $repoFullName" -ForegroundColor Red
    }
    
    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "=== Cleanup Summary ===" -ForegroundColor Cyan
Write-Host "✓ Successfully deleted: $successCount repositories" -ForegroundColor Green
Write-Host "✗ Failed to delete: $failCount repositories" -ForegroundColor Red
Write-Host ""

if ($errors.Count -gt 0) {
    Write-Host "Errors encountered:" -ForegroundColor Yellow
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    Write-Host ""
}

Write-Host "Remaining repositories:" -ForegroundColor Cyan
gh repo list --json name,isFork --limit 20 | ConvertFrom-Json | ForEach-Object {
    $icon = if ($_.isFork) { "🔱" } else { "📦" }
    Write-Host "  $icon $($_.name)" -ForegroundColor White
}

Write-Host ""
Write-Host "✓ Cleanup complete! Check: https://github.com/amareshkumar?tab=repositories" -ForegroundColor Green
Write-Host ""
Write-Host "Kept your original projects:" -ForegroundColor Green
$keepRepos | ForEach-Object { Write-Host "  ✓ https://github.com/amareshkumar/$_" -ForegroundColor Green }
