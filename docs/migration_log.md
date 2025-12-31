# Telemetry Platform Monorepo Migration Log

**Date:** December 26, 2025
**Goal:** Migrate TelemetryHub + TelemetryTaskProcessor into unified monorepo with independent projects
**Structure:** Two independent projects (ingestion, processing) + shared common library

---

## Migration Checklist

- [ ] Step 1: Create backups
- [ ] Step 2: Create new monorepo directory structure
- [ ] Step 3: Migrate TelemetryHub → ingestion/ (preserve git history)
- [ ] Step 4: Migrate TelemetryTaskProcessor → processing/ (preserve git history)
- [ ] Step 5: Create common/ shared library
- [ ] Step 6: Update top-level CMakeLists.txt
- [ ] Step 7: Update project CMakeLists.txt files
- [ ] Step 8: Create unified README.md
- [ ] Step 9: Update Docker Compose
- [ ] Step 10: Test builds
- [ ] Step 11: Run tests
- [ ] Step 12: Update documentation
- [ ] Step 13: Commit everything

---

## Step 1: Create Backups ✅

**Command:**
```powershell
# Backup existing repos
Copy-Item -Path "c:\code\telemetryhub" -Destination "c:\code\telemetryhub_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Recurse
Copy-Item -Path "c:\code\TelemetryTaskProcessor" -Destination "c:\code\TelemetryTaskProcessor_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Recurse
```

**Status:** 
**Result:** 

---

## Step 2: Create Monorepo Structure

**Command:**
```powershell
# Create new monorepo directory
New-Item -Path "c:\code\telemetry-platform" -ItemType Directory -Force
cd c:\code\telemetry-platform

# Initialize git repo
git init

# Create directory structure
New-Item -Path "common" -ItemType Directory
New-Item -Path "ingestion" -ItemType Directory
New-Item -Path "processing" -ItemType Directory
New-Item -Path "deployment" -ItemType Directory
New-Item -Path "docs" -ItemType Directory
New-Item -Path "tests\integration" -ItemType Directory
```

**Status:** 
**Result:** 

---

## Step 3: Migrate TelemetryHub → ingestion/

**Strategy:** Preserve git history using git subtree

**Commands:**
```powershell
cd c:\code\telemetry-platform

# Add TelemetryHub as remote
git remote add telemetryhub c:\code\telemetryhub
git fetch telemetryhub --no-tags

# Merge with history
git merge --allow-unrelated-histories telemetryhub/main -m "Merge TelemetryHub history"

# Move files to ingestion/ subdirectory
# (Will be done after fetch completes)
```

**Status:** 
**Result:** 

---

## Step 4: Migrate TelemetryTaskProcessor → processing/

**Strategy:** Preserve git history using git subtree

**Commands:**
```powershell
cd c:\code\telemetry-platform

# Add TelemetryTaskProcessor as remote
git remote add taskprocessor c:\code\TelemetryTaskProcessor
git fetch taskprocessor --no-tags

# Merge with history
git merge --allow-unrelated-histories taskprocessor/main -m "Merge TelemetryTaskProcessor history"

# Move files to processing/ subdirectory
# (Will be done after fetch completes)
```

**Status:** 
**Result:** 

---

## Step 5: Create common/ Shared Library

**Files to create:**
- common/CMakeLists.txt
- common/include/telemetry_common/redis_client.h
- common/include/telemetry_common/json_utils.h
- common/include/telemetry_common/config.h
- common/src/redis_client.cpp
- common/src/json_utils.cpp
- common/src/config.cpp

**Status:** 
**Result:** 

---

## Step 6: Create Top-Level CMakeLists.txt

**Status:** 
**Result:** 

---

## Step 7: Update Project CMakeLists.txt

**Files to update:**
- ingestion/CMakeLists.txt
- processing/CMakeLists.txt

**Status:** 
**Result:** 

---

## Step 8: Create Unified README.md

**Status:** 
**Result:** 

---

## Step 9: Update Docker Compose

**Status:** 
**Result:** 

---

## Step 10: Test Builds

**Commands:**
```powershell
cd c:\code\telemetry-platform
cmake -B build -S .
cmake --build build --config Release
```

**Status:** 
**Result:** 

---

## Step 11: Run Tests

**Commands:**
```powershell
ctest --test-dir build --output-on-failure
```

**Status:** 
**Result:** 

---

## Step 12: Update Documentation

**Files to update:**
- docs/architecture.md
- docs/integration_strategy.md
- ingestion/README.md
- processing/README.md

**Status:** 
**Result:** 

---

## Step 13: Final Commit

**Command:**
```powershell
git add .
git commit -m "Complete monorepo migration: ingestion + processing + common"
```

**Status:** 
**Result:** 

---

## Migration Complete! 🎉

**Final Structure:**
```
c:\code\telemetry-platform\
├── common\          (Shared library)
├── ingestion\       (TelemetryHub - independent)
├── processing\      (TelemetryTaskProcessor - independent)
├── deployment\      (Docker Compose, K8s)
├── docs\           (Unified docs)
├── tests\          (Integration tests)
└── .git\           (Single repo with both histories)
```

**Verification:**
- [ ] Ingestion builds independently
- [ ] Processing builds independently
- [ ] All tests pass
- [ ] Git history preserved for both projects
- [ ] Documentation updated

---

## Notes and Issues

(Will be filled as we encounter issues during migration)

