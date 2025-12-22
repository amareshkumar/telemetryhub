# TelemetryHub-Dev Repository Setup Guide

**For:** Amaresh Kumar  
**Date:** December 22, 2025  
**Purpose:** Separate repository for interview preparation materials

---

## 🎯 Why Separate Repositories?

**telemetryhub (public):**
- Production-ready code
- Professional documentation
- Client-facing materials
- Resume/LinkedIn showcase

**telemetryhub-dev (private):**
- Interview preparation notes
- Day-by-day conversation logs
- SOLID principles guides
- GitHub strategy documents
- Personal learning notes

**Benefits:**
✅ No branch switching confusion  
✅ Easy access to all interview materials in one place  
✅ Keep public repo clean and professional  
✅ Private repo for interview tactics  
✅ Can reference both repos independently  

---

## 📋 Step-by-Step Setup

### Step 1: Create New Repository on GitHub

**Option A: Via GitHub Web Interface**
1. Go to https://github.com/new
2. Repository name: `telemetryhub-dev`
3. Description: "Interview preparation and development notes for TelemetryHub"
4. Visibility: **Private** ⚠️ (Important!)
5. ✅ Add README
6. ✅ Add .gitignore (choose "None" - we'll create custom)
7. License: None (or MIT if you prefer)
8. Click "Create repository"

**Option B: Via GitHub CLI**
```powershell
# Install GitHub CLI if not already: winget install GitHub.cli
gh auth login
gh repo create telemetryhub-dev --private --description "Interview prep and dev notes for TelemetryHub"
```

---

### Step 2: Add Second Remote to Current Repo

```powershell
# Still in your current telemetryhub directory
cd C:\code\telemetryhub

# Add the new remote (call it "dev")
git remote add dev https://github.com/amareshkumar/telemetryhub-dev.git

# Verify both remotes
git remote -v
# Should show:
# origin   https://github.com/amareshkumar/telemetryhub.git (fetch)
# origin   https://github.com/amareshkumar/telemetryhub.git (push)
# dev      https://github.com/amareshkumar/telemetryhub-dev.git (fetch)
# dev      https://github.com/amareshkumar/telemetryhub-dev.git (push)
```

---

### Step 3: Prepare Interview Materials for Dev Repo

**Create a clean branch for interview content:**

```powershell
# Create new branch from day16 (has all interview materials)
git checkout day16
git checkout -b dev-main

# This branch will track interview materials only
```

---

### Step 4: Remove Production Code (Keep Only Interview Materials)

**Files to KEEP in telemetryhub-dev:**
```
docs/
  ├─ day16_conversation_log.md               ✅
  ├─ day16_summary.md                        ✅
  ├─ day16_task_responses.md                 ✅
  ├─ solid_principles_interview_guide.md     ✅
  ├─ solid_code_reference.md                 ✅
  ├─ v4.0.0_release_preparation.md           ✅
  ├─ v4.0.0_quick_reference.md               ✅
  ├─ interview-preparation.md                ✅
  ├─ interview_snippets_week1.md             ✅
  ├─ interview-topics.md                     ✅
  ├─ SprintBoard.md                          ✅
  ├─ SENIOR_LEVEL_TODO.md                    ✅
  └─ Interview/                              ✅ (entire folder)

CHANGELOG.md                                 ✅ (for version reference)
ReadMe.md                                    ✅ (modify for dev repo)
.gitignore                                   ✅
```

**Files to REMOVE (production code):**
```
device/          ❌ (source code)
gateway/         ❌ (source code)
gateway/         ❌ (source code)
tests/           ❌ (test code)
tools/           ❌ (tool code)
gui/             ❌ (GUI code)
examples/        ❌ (example code)
build*/          ❌ (build artifacts)
external/        ❌ (dependencies)
CMakeLists.txt   ❌ (build files)
CMakePresets.json ❌
docker-compose.yml ❌
Dockerfile       ❌
```

**Automated cleanup script:**

```powershell
# Create cleanup script
$cleanupScript = @'
# Remove all production code directories
Remove-Item -Recurse -Force device, gateway, gui, tests, tools, examples, external, cmake -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build*, .vs, .vscode -ErrorAction SilentlyContinue

# Remove build files
Remove-Item CMakeLists.txt, CMakePresets.json, Dockerfile, docker-compose.yml -ErrorAction SilentlyContinue

# Keep only documentation
Write-Host "Cleaned up production code. Only docs remain."
'@

# Save script
Set-Content -Path "cleanup_for_dev_repo.ps1" -Value $cleanupScript

# Run it
.\cleanup_for_dev_repo.ps1

# Verify what's left
Get-ChildItem -Recurse -Directory | Select-Object Name
```

---

### Step 5: Create Dev Repo README

**Create new README for telemetryhub-dev:**

```powershell
# Backup current README
Copy-Item ReadMe.md ReadMe_production.md

# Create new dev-focused README
@'
# TelemetryHub-Dev

**Private repository for interview preparation and development notes**

> This repo contains my interview preparation materials, daily learning logs, 
> and technical discussion notes for the TelemetryHub project.

## 📚 Purpose

This is a companion repository to [telemetryhub](https://github.com/amareshkumar/telemetryhub) 
(public production code). Here I keep:

- Daily conversation logs and Q&A
- SOLID principles guides with interview talking points
- GitHub strategy and release preparation notes
- Senior-level engineering topics and study materials
- Interview-specific documentation

## 🗂️ Structure

### Day-by-Day Logs
- `docs/day16_conversation_log.md` - Complete Q&A from Day 16 session
- `docs/day16_summary.md` - Technical achievements and interview value
- `docs/day16_task_responses.md` - Detailed task responses

### SOLID Principles & Design Patterns
- `docs/solid_principles_interview_guide.md` - Comprehensive SOLID reference
- `docs/solid_code_reference.md` - Quick lookup for code examples

### Release & GitHub Strategy
- `docs/v4.0.0_release_preparation.md` - Release workflow and professionalism tips
- `docs/v4.0.0_quick_reference.md` - Quick checklist for releases

### General Interview Prep
- `docs/interview-preparation.md` - Overall interview strategy
- `docs/interview-topics.md` - Topics to master
- `docs/SENIOR_LEVEL_TODO.md` - Senior engineer skill development

## 🔗 Related Repositories

- **Public Production Code:** https://github.com/amareshkumar/telemetryhub
- **This Repo (Private):** Interview preparation notes

## 📖 How to Use

### Before Technical Interviews:
1. Review `solid_principles_interview_guide.md` for talking points
2. Read relevant `day#_conversation_log.md` for Q&A context
3. Check `solid_code_reference.md` for code locations

### When Working on New Features:
1. Update `SprintBoard.md` with tasks
2. Document Q&A in `day#_conversation_log.md`
3. Add lessons learned to appropriate guides

### Before GitHub Updates:
1. Review `v4.0.0_release_preparation.md` for best practices
2. Follow release checklist in `v4.0.0_quick_reference.md`

## 🔒 Privacy

**This repository is PRIVATE** - contains interview preparation strategies.  
**Public repo:** https://github.com/amareshkumar/telemetryhub (production code only)

---

**Author:** Amaresh Kumar  
**Started:** December 22, 2025  
**Purpose:** Centralized interview prep for TelemetryHub project
'@ | Out-File -FilePath ReadMe.md -Encoding UTF8
```

---

### Step 6: Push to Dev Repo

```powershell
# Stage all interview materials
git add -A
git commit -m "Initial commit: Day 16 interview preparation materials

- Day 16 conversation log with 16 Q&A sessions
- SOLID principles guide with code examples
- v4.0.0 release preparation and GitHub strategies
- Interview topics and senior-level roadmap
- Sprint board and development notes"

# Push to dev remote (NOT origin!)
git push dev dev-main:main

# Set up tracking
git branch --set-upstream-to=dev/main dev-main
```

---

### Step 7: Create .gitignore for Dev Repo

```powershell
# Create .gitignore for dev repo (minimal, since no code)
@'
# Build artifacts (in case you accidentally copy)
build*/
*.exe
*.dll
*.so
*.dylib

# IDE files
.vs/
.vscode/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
desktop.ini

# Temporary files
*.tmp
*.log
*.bak
'@ | Out-File -FilePath .gitignore -Encoding UTF8

git add .gitignore
git commit -m "Add .gitignore for dev repo"
git push dev dev-main:main
```

---

## 🔄 Daily Workflow Going Forward

### When Working on Day 17+ Features:

**1. Work in your main telemetryhub repo:**
```powershell
cd C:\code\telemetryhub
git checkout main  # or day17 branch

# Do your development work...
# Implement features, write tests, etc.
```

**2. When you have interview notes to save:**

```powershell
# Create/update interview docs in docs/ folder
# Example: docs/day17_conversation_log.md

# Commit interview docs separately
git add docs/day17_conversation_log.md
git commit -m "docs(day17): Add conversation log"

# Push to BOTH repos:

# Push production code to public repo
git push origin main  # or day17-clean:main

# Push interview docs to private repo
git push dev main  # or current-branch:main
```

**Alternative: Create day17 folder in dev repo**

```powershell
# In telemetryhub-dev repo
cd C:\code\telemetryhub-dev  # Clone it once
mkdir docs/day17
# Copy interview materials here
git add docs/day17/
git commit -m "Add Day 17 interview notes"
git push origin main
```

---

## 📂 Recommended Structure for telemetryhub-dev

```
telemetryhub-dev/
├─ ReadMe.md                          # Dev repo overview
├─ .gitignore                         # Minimal gitignore
├─ CHANGELOG_learning.md              # Your learning progress
├─ docs/
│  ├─ day16/
│  │  ├─ conversation_log.md
│  │  ├─ summary.md
│  │  ├─ task_responses.md
│  │  └─ release_preparation.md
│  ├─ day17/
│  │  ├─ conversation_log.md
│  │  └─ notes.md
│  ├─ solid_principles/
│  │  ├─ interview_guide.md
│  │  ├─ code_reference.md
│  │  └─ examples.md
│  ├─ interview_prep/
│  │  ├─ preparation.md
│  │  ├─ topics.md
│  │  └─ senior_level_todo.md
│  └─ github_strategy/
│     ├─ release_workflow.md
│     └─ professionalism_tips.md
└─ scripts/
   └─ sync_from_main.ps1              # Script to copy docs from main repo
```

---

## 🔧 Useful Commands

### Check which remote you're pushing to:
```powershell
git remote -v
```

### Push to specific remote:
```powershell
git push origin main      # Public repo
git push dev main         # Private dev repo
```

### Clone dev repo to separate directory:
```powershell
cd C:\code
git clone https://github.com/amareshkumar/telemetryhub-dev.git
cd telemetryhub-dev
```

### Sync specific files from main repo to dev repo:
```powershell
# Copy interview docs from main repo to dev repo
$sourceDocs = "C:\code\telemetryhub\docs"
$destDocs = "C:\code\telemetryhub-dev\docs"

# Copy specific files
Copy-Item "$sourceDocs\day16_*.md" -Destination "$destDocs\" -Force
Copy-Item "$sourceDocs\solid_*.md" -Destination "$destDocs\" -Force
Copy-Item "$sourceDocs\v4.0.0_*.md" -Destination "$destDocs\" -Force

cd C:\code\telemetryhub-dev
git add docs/
git commit -m "Sync Day 16 interview materials"
git push origin main
```

---

## ⚠️ Important Notes

1. **Always double-check which remote you're pushing to:**
   - `origin` = public telemetryhub (production code)
   - `dev` = private telemetryhub-dev (interview notes)

2. **Never push interview docs to public repo:**
   - Use `.gitignore` in public repo to exclude interview files
   - Or use separate clones for safety

3. **Keep dev repo PRIVATE:**
   - Verify at https://github.com/amareshkumar/telemetryhub-dev/settings

4. **Consider separate clones (safest approach):**
   ```
   C:\code\telemetryhub\          → Push to origin (public)
   C:\code\telemetryhub-dev\      → Push to dev remote (private)
   ```

---

## 🎯 Quick Start (TL;DR)

```powershell
# 1. Create repo on GitHub (private!)
gh repo create telemetryhub-dev --private

# 2. Add remote to current repo
cd C:\code\telemetryhub
git remote add dev https://github.com/amareshkumar/telemetryhub-dev.git

# 3. Create clean branch with only docs
git checkout day16
git checkout -b dev-main

# 4. Remove production code (keep only docs/)
# (Use cleanup script above)

# 5. Push to dev repo
git add -A
git commit -m "Initial commit: Interview prep materials"
git push dev dev-main:main

# 6. Clone to separate directory for easier access
cd C:\code
git clone https://github.com/amareshkumar/telemetryhub-dev.git
```

---

## 📞 Support

If you encounter issues:
- Check `git remote -v` to verify remotes
- Use `git remote remove dev` and re-add if needed
- Verify GitHub repo is private in settings

---

**Result:** Clean separation between public production code and private interview preparation materials! 🎉
