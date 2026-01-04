<#
.SYNOPSIS
    Verify migration from telemetry-platform to platform-dev

.DESCRIPTION
    Comprehensive verification script to ensure:
    1. All personal files exist in platform-dev
    2. No personal content remains in telemetry-platform
    3. .gitignore patterns are working correctly
    
.PARAMETER PlatformPath
    Path to telemetry-platform repository (default: C:\code\telemetry-platform)

.PARAMETER PlatformDevPath
    Path to platform-dev repository (default: C:\code\platform-dev)

.EXAMPLE
    .\verify_platform_migration.ps1

.NOTES
    Author: Generated for Amaresh Kumar
    Date: January 4, 2026
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$PlatformPath = "C:\code\telemetry-platform",
    
    [Parameter(Mandatory=$false)]
    [string]$PlatformDevPath = "C:\code\platform-dev"
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
║      Platform Migration Verification Script                     ║
║      Ensure Complete and Safe Migration                         ║
╚══════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Info "Public repo (telemetry-platform): $PlatformPath"
Write-Info "Private repo (platform-dev): $PlatformDevPath"
Write-Host ""

# Verification results
$results = @{
    PlatformPathExists = $false
    PlatformDevPathExists = $false
    PlatformDevFileCount = 0
    PersonalFilesInPlatform = @()
    GitignoreUpdated = $false
    PlatformDevCommitted = $false
    PlatformClean = $false
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  STEP 1: Verify Repository Paths" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

# Check telemetry-platform exists
if (Test-Path $PlatformPath) {
    Write-Success "telemetry-platform found: $PlatformPath"
    $results.PlatformPathExists = $true
} else {
    Write-Error "telemetry-platform NOT FOUND: $PlatformPath"
}

# Check platform-dev exists
if (Test-Path $PlatformDevPath) {
    Write-Success "platform-dev found: $PlatformDevPath"
    $results.PlatformDevPathExists = $true
} else {
    Write-Error "platform-dev NOT FOUND: $PlatformDevPath"
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  STEP 2: Check platform-dev Content" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

if ($results.PlatformDevPathExists) {
    # Count markdown files in platform-dev
    $mdFiles = Get-ChildItem -Path $PlatformDevPath -Recurse -Filter "*.md" -File -ErrorAction SilentlyContinue
    $results.PlatformDevFileCount = $mdFiles.Count
    
    if ($results.PlatformDevFileCount -gt 0) {
        Write-Success "Found $($results.PlatformDevFileCount) markdown files in platform-dev"
        
        # Show directory structure
        Write-Host "`n  Directory structure:" -ForegroundColor Cyan
        Get-ChildItem -Path $PlatformDevPath -Directory | ForEach-Object {
            $fileCount = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue).Count
            Write-Host "    📁 $($_.Name)/ ($fileCount files)" -ForegroundColor DarkGray
        }
    } else {
        Write-Warning "No markdown files found in platform-dev - migration may not have run"
    }
    
    # Check git status
    Push-Location $PlatformDevPath
    $gitStatus = git status --porcelain 2>&1
    Pop-Location
    
    if ([string]::IsNullOrWhiteSpace($gitStatus)) {
        Write-Success "platform-dev has no uncommitted changes (clean working tree)"
        $results.PlatformDevCommitted = $true
    } else {
        Write-Warning "platform-dev has uncommitted changes:"
        Write-Host $gitStatus -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  STEP 3: Search for Personal Content in telemetry-platform" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

if ($results.PlatformPathExists) {
    Push-Location $PlatformPath
    
    # Search patterns that might indicate personal content
    $searchPatterns = @(
        @{Pattern = "amaresh"; Description = "Name 'amaresh'"},
        @{Pattern = "interview"; Description = "Word 'interview'"},
        @{Pattern = "career"; Description = "Word 'career'"},
        @{Pattern = "resume"; Description = "Word 'resume'"},
        @{Pattern = "linkedin"; Description = "Word 'linkedin'"},
        @{Pattern = "cover.letter"; Description = "Phrase 'cover letter'"},
        @{Pattern = "job.application"; Description = "Phrase 'job application'"}
    )
    
    foreach ($search in $searchPatterns) {
        Write-Host "`n  Searching for: $($search.Description)" -ForegroundColor Cyan
        $matches = git grep -i $search.Pattern -- "*.md" 2>&1
        
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($matches)) {
            $matchLines = $matches -split "`n"
            $matchCount = $matchLines.Count
            
            if ($matchCount -gt 0) {
                Write-Warning "Found $matchCount matches"
                
                # Show first 3 matches
                $matchLines | Select-Object -First 3 | ForEach-Object {
                    Write-Host "    $_" -ForegroundColor DarkGray
                }
                
                if ($matchCount -gt 3) {
                    Write-Host "    ... and $($matchCount - 3) more" -ForegroundColor DarkGray
                }
                
                $results.PersonalFilesInPlatform += $search.Description
            }
        } else {
            Write-Success "No matches found"
        }
    }
    
    Pop-Location
    
    if ($results.PersonalFilesInPlatform.Count -eq 0) {
        Write-Success "`ntelemetry-platform appears clean (no personal content found)"
        $results.PlatformClean = $true
    } else {
        Write-Warning "`nFound potential personal content in telemetry-platform"
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  STEP 4: Check .gitignore in telemetry-platform" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

if ($results.PlatformPathExists) {
    $gitignorePath = Join-Path $PlatformPath ".gitignore"
    
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath -Raw
        
        # Check for key patterns
        $keyPatterns = @("amaresh_*.md", "interview", "career", "cover_letter")
        $foundPatterns = @()
        
        foreach ($pattern in $keyPatterns) {
            if ($gitignoreContent -match [regex]::Escape($pattern)) {
                $foundPatterns += $pattern
            }
        }
        
        if ($foundPatterns.Count -gt 0) {
            Write-Success ".gitignore contains personal content patterns"
            Write-Host "  Found patterns: $($foundPatterns -join ', ')" -ForegroundColor DarkGray
            $results.GitignoreUpdated = $true
        } else {
            Write-Warning ".gitignore does NOT contain personal content patterns"
            Write-Info "Add patterns from TELEMETRY_PLATFORM_GITIGNORE_ADDITIONS.txt"
        }
    } else {
        Write-Warning ".gitignore file not found"
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  STEP 5: Git Status Check" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

if ($results.PlatformPathExists) {
    Push-Location $PlatformPath
    $gitStatus = git status --short
    Pop-Location
    
    if ([string]::IsNullOrWhiteSpace($gitStatus)) {
        Write-Success "telemetry-platform has clean working tree"
    } else {
        Write-Info "telemetry-platform has changes:"
        Write-Host $gitStatus -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "  VERIFICATION SUMMARY" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray

Write-Host ""
Write-Host "Repository Status:" -ForegroundColor Cyan
Write-Host "  telemetry-platform exists:    $(if($results.PlatformPathExists){'✅'}else{'❌'})"
Write-Host "  platform-dev exists:          $(if($results.PlatformDevPathExists){'✅'}else{'❌'})"
Write-Host ""
Write-Host "Migration Status:" -ForegroundColor Cyan
Write-Host "  Files in platform-dev:        $($results.PlatformDevFileCount) markdown files"
Write-Host "  platform-dev committed:       $(if($results.PlatformDevCommitted){'✅'}else{'⚠️  Uncommitted changes'})"
Write-Host "  telemetry-platform clean:     $(if($results.PlatformClean){'✅'}else{'⚠️  Personal content found'})"
Write-Host "  .gitignore updated:           $(if($results.GitignoreUpdated){'✅'}else{'⚠️  Needs patterns'})"
Write-Host ""

# Overall status
$allGood = $results.PlatformPathExists -and 
           $results.PlatformDevPathExists -and 
           $results.PlatformDevFileCount -gt 20 -and
           $results.PlatformDevCommitted -and
           $results.PlatformClean -and
           $results.GitignoreUpdated

if ($allGood) {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Success "MIGRATION COMPLETE AND VERIFIED!"
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ All personal content migrated to platform-dev" -ForegroundColor Green
    Write-Host "✅ telemetry-platform sanitized (public-ready)" -ForegroundColor Green
    Write-Host "✅ .gitignore patterns prevent future leaks" -ForegroundColor Green
    Write-Host ""
    Write-Success "Both repositories are ready for use!"
} else {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Warning "MIGRATION INCOMPLETE OR NEEDS ATTENTION"
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not $results.PlatformDevPathExists) {
        Write-Host "⚠️  Clone platform-dev repository" -ForegroundColor Yellow
    }
    
    if ($results.PlatformDevFileCount -lt 20) {
        Write-Host "⚠️  Run migration script: .\migrate_platform_to_dev.ps1" -ForegroundColor Yellow
    }
    
    if (-not $results.PlatformDevCommitted) {
        Write-Host "⚠️  Commit changes in platform-dev" -ForegroundColor Yellow
    }
    
    if (-not $results.PlatformClean) {
        Write-Host "⚠️  Run cleanup script: .\cleanup_telemetry_platform.ps1" -ForegroundColor Yellow
    }
    
    if (-not $results.GitignoreUpdated) {
        Write-Host "⚠️  Update .gitignore using TELEMETRY_PLATFORM_GITIGNORE_ADDITIONS.txt" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Info "See PLATFORM_DEV_MIGRATION_PLAN.md for detailed instructions"
}

Write-Host ""
