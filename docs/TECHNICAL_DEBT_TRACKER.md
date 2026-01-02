# Technical Debt & Future Enhancements

**Last Updated:** January 2, 2026  
**Status:** Active tracking for TelemetryHub and Telemetry-Platform

---

## 🔴 High Priority (Before Interview - Jan 5)

### 1. Branch Protection Setup (30 minutes) ⭐⭐⭐⭐⭐
**Status:** 🟡 In Progress  
**Owner:** User  
**Due:** January 3, 2026

**Description:** Configure GitHub branch protection rules for main branch to enforce trunk-based development workflow.

**Required Status Checks:**
- `cpp-ci / linux-asan-ubsan` - Linux with ASAN+UBSAN sanitizers
- `cpp-ci / windows-msvc` - Windows MSVC build
- `cpp-ci / windows-gui` - Windows GUI build with Qt6
- `cpp-ci / linux-tsan` - Linux with Thread Sanitizer (TSan)

**Implementation Steps:**
1. Go to GitHub repo Settings → Branches → Add branch protection rule
2. Branch name pattern: `main`
3. Enable: "Require a pull request before merging"
   - Required approvals: 1 (can be yourself for portfolio)
4. Enable: "Require status checks to pass before merging"
   - Search and add: `linux-asan-ubsan`, `windows-msvc`, `windows-gui`, `linux-tsan`
   - Enable: "Require branches to be up-to-date before merging"
5. Enable: "Do not allow bypassing the above settings"
6. Disable: "Allow force pushes" and "Allow deletions"
7. Enable: "Automatically delete head branches"

**Documentation:** See [GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md](GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md) section 6

**Interview Value:** ⭐⭐⭐⭐⭐ Shows production-grade workflow understanding

---

### 2. Qt6_DIR CI Fix (15 minutes) ⭐⭐⭐⭐⭐
**Status:** ✅ FIXED  
**Commit:** [To be committed]

**Problem:** `install-qt-action@v4` not setting Qt6_DIR environment variable, causing Windows GUI build to fail.

**Root Cause:** Missing `set-env: 'true'` parameter in install-qt-action configuration.

**Solution Implemented:**
```yaml
- name: Install Qt
  uses: jurplel/install-qt-action@v4
  with:
    version: '6.8.3'
    set-env: 'true'  # ← ADDED: Ensures Qt6_DIR is exported
```

**Verification Updated:**
```yaml
- name: Guardrail - Verify Qt was installed
  run: |
    if (-not $env:Qt6_DIR -and -not $env:CMAKE_PREFIX_PATH) { 
      throw 'Qt6_DIR not set by install-qt-action' 
    }
```

**Next Step:** Commit and push to trigger CI, verify all checks pass.

---

### 3. E2E Testing Validation (15 minutes) ⭐⭐⭐⭐
**Status:** 🟡 Pending  
**Owner:** User  
**Due:** January 2, 2026 (Today)

**Description:** Execute complete E2E testing workflow once to validate guide accuracy and confirm system works end-to-end.

**Steps:** Follow [HUB_E2E_TESTING_TODAY.md](HUB_E2E_TESTING_TODAY.md)
1. Build (5 min): `cmake --preset vs2022-release && cmake --build --preset vs2022-release`
2. Gateway (2 min): Start on port 8080
3. Qt6 GUI (3 min): Test 4 scenarios
4. REST API (2 min): Test /api/metrics and /api/devices
5. Performance (3 min): k6 with 100 VUs
6. Unit Tests (1 min): CTest execution
7. E2E Validation: Send 100 samples, verify

**Success Criteria:**
- ✅ Gateway starts and responds to /status
- ✅ GUI displays real-time telemetry
- ✅ k6 achieves >3,000 req/s with p95 <200ms
- ✅ All unit tests pass (5/5)

**Interview Value:** ⭐⭐⭐⭐ Confirms you can demo live system

---

### 4. Interview Preparation - Key Numbers Memorization (30 minutes) ⭐⭐⭐⭐⭐
**Status:** 🟡 In Progress  
**Due:** January 2-3, 2026

**Key Numbers to Memorize:**

**Performance:**
- 3,720 req/s (validated with k6)
- <200ms p95 latency
- <420ms p99 latency
- <1% error rate
- 5,000 VUs max tested

**Architecture:**
- 14 threads total
- 1,000 queue capacity
- 4 worker threads
- 60 FPS GUI refresh rate

**Build:**
- 4.3× FASTBuild speedup
- 40% CI improvement (45min → 27min)
- 60-75% ccache speedup

**Quality:**
- 90%+ code coverage
- 0 ASAN violations
- 0 TSAN violations
- 5/5 test suites passing

**Experience:**
- 13 years C++ experience
- 2 repositories (Hub + Platform)
- 4 CI jobs per repo
- 6+ architecture diagrams per project

**Practice Method:**
- Write on flashcards
- Recite 5 times out loud
- Have someone quiz you
- Review morning of interview

---

## 🟡 Medium Priority (Post-Interview, Optional)

### 5. CI/CD ccache Optimization (30 minutes)
**Status:** 🔵 Not Started  
**Impact:** 60-75% faster Linux incremental builds

**Implementation:**
```yaml
- name: Setup ccache
  uses: hendrikmuhs/ccache-action@v1.2
  with:
    key: ${{ runner.os }}-ccache-${{ github.sha }}
    restore-keys: ${{ runner.os }}-ccache-

- name: Configure with ccache
  run: |
    export CC="ccache gcc"
    export CXX="ccache g++"
    cmake --preset linux-ninja-release
```

**Documentation:** See [CI_CD_OPTIMIZATIONS.md](CI_CD_OPTIMIZATIONS.md) Section 4.1

---

### 6. CMake Dependencies Caching (30 minutes)
**Status:** 🔵 Not Started  
**Impact:** Faster CI by caching external/

**Implementation:**
```yaml
- name: Cache CMake dependencies
  uses: actions/cache@v4
  with:
    path: |
      ${{ github.workspace }}/build/external
      ${{ github.workspace }}/build/_deps
    key: ${{ runner.os }}-cmake-deps-${{ hashFiles('**/CMakeLists.txt') }}
```

**Documentation:** See [CI_CD_OPTIMIZATIONS.md](CI_CD_OPTIMIZATIONS.md) Section 4.2

---

### 7. Matrix Strategy for Parallel Jobs (1 hour)
**Status:** 🔵 Not Started  
**Impact:** Parallel job execution (45min → 15min with 3 concurrent jobs)

**Implementation:** See [CI_CD_OPTIMIZATIONS.md](CI_CD_OPTIMIZATIONS.md) Section 4.3

---

### 8. Trunk-Based Development Workflow Implementation (30 minutes)
**Status:** 🟡 Documentation Complete, Awaiting Adoption  

**Next Steps:**
1. Create CONTRIBUTING.md with branch naming conventions
2. Practice feature branch workflow
3. Update PR templates (optional)

**Documentation:** See [GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md](GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md)

---

## 🔵 Low Priority (Long-term)

### 9. Platform Repository CI Optimizations
**Status:** 🔵 Not Started  
**Impact:** Apply same optimizations to Telemetry-Platform

Apply lessons learned from Hub:
- ccache for Linux builds
- CMake dependencies caching
- Matrix strategy
- Branch protection rules

---

### 10. FASTBuild Coordinator Setup (Optional)
**Status:** 🔵 Not Started  
**Impact:** Maximum speedup (requires network setup)

**Requirements:**
- Dedicated build machine or cloud instance
- Network configuration for worker coordination
- Initial setup: 2-4 hours

**Benefit:** Full 4.3× speedup (currently works locally, not in CI)

---

### 11. Additional Architecture Diagrams
**Status:** 🔵 Not Started  
**Impact:** Enhanced visual communication

**Candidates:**
- Sequence diagram: Request flow from device → GUI
- Deployment diagram: Container architecture
- Component diagram: Module dependencies
- Activity diagram: State machine transitions

---

### 12. Performance Regression Detection in CI
**Status:** 🔵 Not Started  
**Impact:** Catch performance regressions early

**Implementation:** See [CI_CD_OPTIMIZATIONS.md](CI_CD_OPTIMIZATIONS.md) Section 4.5

**Benchmark Job:**
```yaml
- name: Run performance benchmark
  run: |
    cmake --build --preset linux-ninja-release --target perf_tool
    ./build/tools/Release/perf_tool --benchmark
    
- name: Compare with baseline
  run: |
    python scripts/compare_perf.py \
      --current results.json \
      --baseline baseline.json \
      --threshold 10  # 10% regression threshold
```

---

## 📊 Priority Matrix

| Task | Priority | Effort | Impact | Status | Due Date |
|------|----------|--------|--------|--------|----------|
| Branch Protection Setup | 🔴 High | 30 min | ⭐⭐⭐⭐⭐ | 🟡 Pending | Jan 3 |
| Qt6_DIR CI Fix | 🔴 High | 15 min | ⭐⭐⭐⭐⭐ | ✅ Fixed | Jan 2 |
| E2E Testing Validation | 🔴 High | 15 min | ⭐⭐⭐⭐ | 🟡 Pending | Jan 2 |
| Key Numbers Memorization | 🔴 High | 30 min | ⭐⭐⭐⭐⭐ | 🟡 In Progress | Jan 2-3 |
| ccache Optimization | 🟡 Medium | 30 min | ⭐⭐⭐⭐ | 🔵 Not Started | Post-interview |
| CMake Deps Caching | 🟡 Medium | 30 min | ⭐⭐⭐ | 🔵 Not Started | Post-interview |
| Matrix Strategy | 🟡 Medium | 1 hour | ⭐⭐⭐⭐⭐ | 🔵 Not Started | Post-interview |
| Trunk-Based Adoption | 🟡 Medium | 30 min | ⭐⭐⭐⭐ | 🟡 Docs Done | Jan 3 |
| Platform CI Optimizations | 🔵 Low | 2 hours | ⭐⭐⭐ | 🔵 Not Started | Future |
| FASTBuild Coordinator | 🔵 Low | 4 hours | ⭐⭐⭐⭐ | 🔵 Not Started | Future |
| Architecture Diagrams | 🔵 Low | 3 hours | ⭐⭐⭐ | 🔵 Not Started | Future |
| Perf Regression CI | 🔵 Low | 2 hours | ⭐⭐⭐⭐ | 🔵 Not Started | Future |

---

## 🎯 Interview Preparation Checklist (Jan 5, 2026)

### Day 1 (Jan 2 - Today)
- [x] Read INTERVIEW_TACTICAL_GUIDE_TAMIS_JAN5.md
- [x] Read CPP_CODE_INTERVIEW_REFERENCE.md
- [x] Read GIT_BRANCHING_STRATEGY_SENIOR_LEVEL.md
- [ ] Memorize key numbers (30 min)
- [ ] Practice elevator pitch 5 times (20 min)
- [ ] Run E2E test workflow (15 min)

### Day 2 (Jan 3 - Tomorrow)
- [ ] Review MULTITHREADING_ARCHITECTURE_DIAGRAM.md
- [ ] Review LAYERED_ARCHITECTURE_C4_MODEL.md
- [ ] Re-run k6 tests (validate 3,720 req/s)
- [ ] Review CI/CD workflows
- [ ] Practice STAR method examples
- [ ] Navigate code in VSCode (practice live demo)
- [ ] Setup branch protection rules (30 min) ⭐

### Day 3 (Jan 4 - Day Before)
- [ ] Mock interview with colleague (1 hour)
- [ ] Test live demo: gateway + GUI + k6 (5 min)
- [ ] Print tactical guide + code reference
- [ ] Prepare laptop backups
- [ ] REST WELL (go to bed early!)

### Interview Day (Jan 5)
- [ ] Review key numbers (5 min)
- [ ] Have both repos open in VSCode
- [ ] Have architecture diagrams ready
- [ ] Confident, professional, enthusiastic mindset

---

## 📝 Notes & Lessons Learned

### Build Quality
1. **Always test after refactoring** - MainWindow.cpp duplicates caught by incremental build
2. **CI environment variables matter** - Qt6_DIR must be explicitly set with `set-env: 'true'`
3. **Verification steps prevent failures** - Guardrail checks catch setup issues early

### Git Workflow
1. **Trunk-based scales** - Same workflow works for 1 developer or 1,000
2. **Branch protection is essential** - Prevents accidental force pushes, requires reviews
3. **Status checks matter** - All CI must pass before merge (prevents broken main)

### Interview Preparation
1. **Code > Theory for 3-7 year roles** - Show actual implementations, not just concepts
2. **Quantify everything** - 3,720 req/s beats "high performance"
3. **Map systematically** - Every requirement → portfolio evidence → talk track

---

**Status Legend:**
- 🔴 High Priority
- 🟡 Medium Priority
- 🔵 Low Priority
- ✅ Complete
- 🟡 In Progress
- 🔵 Not Started

**Last Review:** January 2, 2026  
**Next Review:** January 6, 2026 (Post-interview)
