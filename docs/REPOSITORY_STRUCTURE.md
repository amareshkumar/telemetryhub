# Repository Structure Guidelines - TelemetryHub

**Last Updated:** January 1, 2026  
**Status:** ✅ ACTIVE - Follow these rules for all new files

---

## 📁 Directory Organization

### Root Directory (Keep Minimal)
**Files that MUST stay in root:**
- `ReadMe.md` - Primary GitHub README (visible on repo homepage)
- `LICENSE` - License file
- `.gitignore` - Git ignore rules
- `CMakeLists.txt` - Top-level CMake configuration
- `CMakePresets.json` - CMake presets configuration
- `Dockerfile` - Docker container definition
- `docker-compose.yml` - Docker Compose orchestration

**What NOT to keep in root:**
- ❌ Other `.md` files (→ move to `docs/`)
- ❌ `.ps1` scripts (→ move to `scripts/`)
- ❌ Temporary files (→ delete or `.gitignore`)

---

## 📂 `scripts/` Directory

**Purpose:** All PowerShell automation and utility scripts

**Current Contents:**
- `cleanup_branches.ps1` - Branch cleanup automation
- `commit_changes.ps1` - Commit helper
- `configure_fbuild.ps1` - FASTBuild configuration
- `final_branch_cleanup.ps1` - Final branch cleanup
- `run_copilot_fix.ps1` - Copilot attribution fix

**Going Forward - Add Here:**
- ✅ Build scripts (`.ps1`)
- ✅ Test automation scripts
- ✅ Deployment scripts
- ✅ CI/CD helper scripts
- ✅ Repository maintenance scripts
- ✅ Any PowerShell automation

**Examples:**
```powershell
# New build script
scripts/build_release.ps1

# New test script
scripts/run_integration_tests.ps1

# New deployment script
scripts/deploy_to_staging.ps1
```

---

## 📚 `docs/` Directory

**Purpose:** All documentation, guides, notes, and markdown files (except ReadMe.md)

**Current Contents (66 files):**
- `ACTION_ITEMS_JAN2026.md` - Task tracking
- `PROJECT_STRATEGY.md` - Dual-project strategy
- `PROJECT_BOUNDARIES.md` - Feature boundaries
- `CHANGELOG.md` - Version history
- `CONTRIBUTING.md` - Contribution guidelines
- `architecture.md` - System architecture
- `api.md` - API documentation
- ... and 59 more

**Going Forward - Add Here:**
- ✅ Architecture documentation
- ✅ Design decisions (ADRs)
- ✅ Interview preparation notes
- ✅ Performance analysis
- ✅ Sprint boards / planning docs
- ✅ Tutorial guides
- ✅ Troubleshooting guides
- ✅ Meeting notes
- ✅ Career development notes
- ✅ Release notes
- ✅ Any `.md` file (except ReadMe.md)

**Examples:**
```markdown
# New architecture doc
docs/database_design.md

# New interview prep
docs/system_design_interview_2026.md

# New performance analysis
docs/performance_benchmark_q1_2026.md

# New feature RFC
docs/rfcs/feature_xyz_proposal.md
```

---

## 🗂️ Other Key Directories

### `tools/` - Compiled Tools & Utilities
**Contents:** C++ utility programs
- `clean_reconfigure.ps1` - CMake reconfiguration
- `render_mermaid.ps1` - Mermaid diagram renderer
- `run_gui.ps1` - GUI launcher
- Compiled binaries (device_simulator_cli, perf_tool, etc.)

**Distinction from `scripts/`:**
- `scripts/` = PowerShell automation scripts (repository management)
- `tools/` = C++ programs + their helper scripts (project-specific utilities)

### `tests/scripts/` - Test-Specific Scripts
**Contents:** Scripts used by test infrastructure
- `http_integration.ps1` - HTTP integration tests
- Test data generation scripts
- Test fixtures

**Distinction from `scripts/`:**
- `scripts/` = Repository-level automation
- `tests/scripts/` = Test execution and validation

### Source Directories (Keep Clean)
- `device/` - Device implementation code
- `gateway/` - Gateway implementation code
- `gui/` - Qt GUI application code
- `lib/` - Shared libraries
- `tests/` - Test code

**No scripts or docs in source directories!**

---

## 🎯 Quick Decision Matrix

| File Type | Location | Example |
|-----------|----------|---------|
| PowerShell script | `scripts/` | `build_release.ps1` |
| Markdown doc | `docs/` | `architecture.md` |
| CMake file | Source dir | `device/CMakeLists.txt` |
| C++ source | Source dir | `device/src/Device.cpp` |
| Test script | `tests/scripts/` | `http_integration.ps1` |
| Tool script | `tools/` | `run_gui.ps1` |
| Main README | Root | `ReadMe.md` |
| License | Root | `LICENSE` |

---

## 🚫 Common Mistakes to Avoid

### ❌ DON'T:
```
C:\code\telemetryhub\my_new_feature.md          ❌ (should be docs/my_new_feature.md)
C:\code\telemetryhub\deploy.ps1                 ❌ (should be scripts/deploy.ps1)
C:\code\telemetryhub\NOTES.md                   ❌ (should be docs/NOTES.md)
C:\code\telemetryhub\quick_fix.ps1              ❌ (should be scripts/quick_fix.ps1)
```

### ✅ DO:
```
C:\code\telemetryhub\ReadMe.md                  ✅ (main README stays in root)
C:\code\telemetryhub\scripts\deploy.ps1         ✅ (scripts go to scripts/)
C:\code\telemetryhub\docs\NOTES.md              ✅ (docs go to docs/)
C:\code\telemetryhub\docs\my_new_feature.md     ✅ (all .md except ReadMe)
```

---

## 📋 Maintenance Checklist

**Before committing new files, verify:**
- [ ] All `.ps1` files are in `scripts/` (except tool-specific ones in `tools/`)
- [ ] All `.md` files are in `docs/` (except `ReadMe.md` in root)
- [ ] Root directory only has essential configuration files
- [ ] No temporary files committed (`.log`, `.tmp`, etc.)
- [ ] Source directories only contain code and CMake files

---

## 🔄 Reorganization Script

If files get messy again, run:
```powershell
cd C:\code\telemetryhub
.\scripts\organize_repo.ps1
```

This will automatically:
1. Move all `.ps1` files from root → `scripts/`
2. Move all `.md` files from root → `docs/` (except ReadMe.md)
3. Show summary of organized files

---

## 💡 Rationale

**Why this structure?**

1. **Professional Appearance:** Clean root directory signals well-maintained project
2. **Discoverability:** Related files grouped together (all docs in docs/, all scripts in scripts/)
3. **GitHub Convention:** ReadMe.md in root is GitHub standard for repo homepage
4. **Scalability:** Easy to find files as project grows (66 docs organized vs scattered)
5. **Interview Impact:** Shows organizational discipline and best practices

**Before:** 20+ files in root directory (messy, unprofessional)  
**After:** ~10 files in root (clean, essential files only)

---

## 🎓 Remember This!

**Golden Rules:**
1. **`.ps1` → `scripts/`** (always, unless tool-specific)
2. **`.md` → `docs/`** (always, except `ReadMe.md`)
3. **Root stays minimal** (only essential configuration)
4. **ReadMe.md stays in root** (GitHub convention)

**Exception Handling:**
- Tool-specific scripts can stay in `tools/` if tied to C++ programs
- Test scripts can stay in `tests/scripts/` if part of test infrastructure
- When in doubt, prefer `scripts/` for `.ps1` and `docs/` for `.md`

---

**This structure is now enforced. Refresh and save in your memory!** 🧠
