# Execute Copilot Attribution Fix
# Run these commands in PowerShell

# Step 1: Navigate to repository
cd C:\code\telemetryhub

# Step 2: Create backup branch
$backupName = "backup-before-copilot-fix-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git checkout -b $backupName
Write-Host "Created backup branch: $backupName" -ForegroundColor Green
git push origin $backupName
git checkout main

# Step 3: Rewrite history (THE FIX)
Write-Host "`nRewriting git history to remove Copilot attribution..." -ForegroundColor Cyan
git filter-branch --env-filter '
if [ "$GIT_AUTHOR_EMAIL" = "198982749+Copilot@users.noreply.github.com" ]; then
    export GIT_AUTHOR_NAME="Amaresh Kumar"
    export GIT_AUTHOR_EMAIL="amaresh.kumar@live.in"
    export GIT_COMMITTER_NAME="Amaresh Kumar"
    export GIT_COMMITTER_EMAIL="amaresh.kumar@live.in"
fi
' --tag-name-filter cat -- --all

# Step 4: Verify locally
Write-Host "`nVerifying changes locally..." -ForegroundColor Cyan
$authors = git log --all --format="%aN <%aE>" | Sort-Object -Unique
Write-Host "Unique authors:" -ForegroundColor Yellow
$authors

# Check if Copilot still exists
if ($authors -match "Copilot") {
    Write-Host "ERROR: Copilot still found in history!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "SUCCESS: Copilot removed from local history!" -ForegroundColor Green
}

# Step 5: Force push to GitHub
Write-Host "`nAttempting force push to GitHub..." -ForegroundColor Cyan
Write-Host "WARNING: This will rewrite history on GitHub!" -ForegroundColor Yellow
Write-Host "If this fails with 'protected branch' error, you need to:" -ForegroundColor Yellow
Write-Host "  1. Go to: https://github.com/amareshkumar/telemetryhub/settings/branches" -ForegroundColor Yellow
Write-Host "  2. Temporarily disable branch protection" -ForegroundColor Yellow
Write-Host "  3. Re-run this script" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Continue with force push? (yes/no)"
if ($confirmation -eq "yes") {
    git push origin --force --all
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: All branches pushed!" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Force push failed. See message above." -ForegroundColor Red
        Write-Host "Check branch protection: https://github.com/amareshkumar/telemetryhub/settings/branches" -ForegroundColor Yellow
        exit 1
    }
    
    git push origin --force --tags
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: All tags pushed!" -ForegroundColor Green
    }
} else {
    Write-Host "Force push cancelled. History rewritten locally only." -ForegroundColor Yellow
    exit 0
}

# Step 6: Clean up
Write-Host "`nCleaning up local refs..." -ForegroundColor Cyan
git for-each-ref --format="%(refname)" refs/original/ | ForEach-Object { git update-ref -d $_ }
git gc --prune=now --aggressive

Write-Host "`n=== FIX COMPLETE ===" -ForegroundColor Green
Write-Host "Copilot attribution removed locally and pushed to GitHub" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: GitHub's contributor cache updates in 24-48 hours" -ForegroundColor Yellow
Write-Host "Check: https://github.com/amareshkumar/telemetryhub/graphs/contributors" -ForegroundColor Cyan
Write-Host ""
Write-Host "If Copilot still shows after 48 hours, contact GitHub Support" -ForegroundColor Yellow
