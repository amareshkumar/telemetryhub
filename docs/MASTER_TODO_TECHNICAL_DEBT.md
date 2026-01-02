# 🎯 Master TODO & Technical Debt Tracker
**Date Created:** January 2, 2026  
**Owner:** Amaresh Kumar  
**Purpose:** Comprehensive tracking for senior engineer & software architect interview preparation

---

## 📊 Executive Summary

### Current State
- **TelemetryHub:** v6.1.0 - Professional, CI passing, 20 repos (clean profile) ✅
- **Telemetry-Platform:** v5.1.0 - Organized structure, comprehensive docs ✅
- **Interview Readiness:** 85% - Strong foundation, tactical improvements needed
- **Portfolio Appeal:** High - Production-grade code, professional presentation

### Strategic Goals
1. **Demonstrate Senior-Level Expertise** - Production operations, performance engineering
2. **Show Architect Thinking** - System design, scalability patterns, trade-off analysis
3. **Maximize Hireability** - Complete documentation, impressive demos, quantified results
4. **Appeal to Clients** - Clear value proposition, professional presentation, active maintenance

---

## 🔴 PRIORITY 1: High-Impact Interview Enhancements

### 1.1 TelemetryHub - Missing CI Jobs (BLOCKER)
**Status:** 🔴 **CRITICAL** - Mentioned in RELEASE notes but disabled  
**Impact:** Reduces interview credibility ("why is coverage disabled?")

**Tasks:**
- [ ] **Add linux-ninja-coverage preset** to CMakePresets.json
  - Configuration: Coverage flags (`-fprofile-arcs -ftest-coverage`)
  - Build type: Debug with coverage instrumentation
  - Output: `.gcda/.gcno` files for gcov/lcov
  - **File:** `CMakePresets.json` (lines 80-95)
  - **Effort:** 30 minutes
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Re-enable coverage job** in `.github/workflows/cpp-ci.yml`
  - Uncomment lines 208-236
  - Add codecov upload step
  - Badge: ![codecov](https://codecov.io/gh/...)
  - **Effort:** 20 minutes
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Implement stress_test tool** in `tools/`
  - Command: `stress_test --duration 60s --producers 10 --rate 1000`
  - Validates: Sustained load, memory stability, no crashes
  - Output: Performance report (throughput, latency percentiles)
  - **File:** `tools/stress_test.cpp` (~300 lines)
  - **Effort:** 4 hours
  - **Interview Value:** ⭐⭐⭐⭐⭐

**Interview Talk Track:**
> "I maintain 90%+ test coverage with automated CI. Here's my codecov badge showing coverage trends. I also have stress testing validating 60-second sustained load at 10k samples/sec."

**Deadline:** ⚠️ **Before next interview** (Week 1)

---

### 1.2 TelemetryHub - Performance Validation Documentation
**Status:** 🟡 **PARTIAL** - k6 tests exist but results not documented  
**Impact:** Can't quantify performance claims in interviews

**Tasks:**
- [ ] **Run comprehensive k6 load test**
  - Scenarios: 100/1000/5000 concurrent devices
  - Metrics: throughput (samples/sec), latency (p50/p95/p99), error rate
  - Duration: 5 minutes per scenario
  - **Command:** `k6 run --vus 5000 --duration 5m tests/load_test.js`
  - **Effort:** 1 hour
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Create PERFORMANCE_BENCHMARKS.md**
  - Results tables with graphs
  - Bottleneck analysis
  - Scalability limits documentation
  - Optimization opportunities identified
  - **File:** `docs/PERFORMANCE_BENCHMARKS.md` (~400 lines)
  - **Effort:** 2 hours
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Add performance badge to README**
  - Badge: ![Throughput](https://img.shields.io/badge/throughput-50k%20samples%2Fsec-brightgreen)
  - Badge: ![Latency](https://img.shields.io/badge/p95%20latency-200ms-blue)
  - **Effort:** 10 minutes
  - **Interview Value:** ⭐⭐⭐⭐

**Interview Talk Track:**
> "I validated performance with k6 load testing: 5,000 concurrent devices, sustained 45k samples/sec throughput, p95 latency under 200ms. Here are the detailed benchmark results..."

**Deadline:** Week 1

---

### 1.3 TelemetryHub - Observability & Production Ops
**Status:** 🔴 **MISSING** - No metrics export, limited production readiness  
**Impact:** Can't demonstrate production operations experience

**Tasks:**
- [ ] **Add Prometheus metrics exporter**
  - Library: `prometheus-cpp` (header-only, CMake integration)
  - Metrics: 
    - Counter: `telemetry_samples_total{device_id}`
    - Gauge: `telemetry_queue_size`
    - Histogram: `telemetry_latency_seconds{percentile}`
    - Counter: `http_requests_total{endpoint,status}`
  - Endpoint: `/metrics` (Prometheus scrape format)
  - **Files:** `gateway/src/PrometheusExporter.cpp` (~200 lines)
  - **Effort:** 6 hours
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Create Grafana dashboard JSON**
  - Panels: Throughput, latency heatmap, queue depth, error rate
  - Time range: Last 15 minutes (real-time monitoring)
  - Alerts: Queue >80% full, error rate >1%
  - **File:** `deployment/grafana/telemetryhub-dashboard.json`
  - **Effort:** 2 hours
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Add health check endpoints**
  - `/health/live` - Liveness probe (200 if running)
  - `/health/ready` - Readiness probe (200 if ready to serve)
  - `/health/detailed` - Component status breakdown
  - **File:** `gateway/src/http_server.cpp` (add 3 handlers, ~100 lines)
  - **Effort:** 1 hour
  - **Interview Value:** ⭐⭐⭐⭐

**Interview Talk Track:**
> "For production deployment, I added Prometheus metrics and Grafana dashboards. Here's my monitoring setup showing real-time throughput, latency percentiles, and queue depth. I also implemented proper Kubernetes health checks."

**Deadline:** Week 2

---

### 1.4 Telemetry-Platform - Day-by-Day Docs (ARCHIVE CANDIDATE)
**Status:** 🟡 **OUTDATED** - 15+ DAY_X_*.md files clutter docs/  
**Impact:** Unprofessional appearance, hard to navigate

**Tasks:**
- [ ] **Create docs/archives/development-journey/** folder
- [ ] **Move 15 day-by-day files:**
  - DAY3_COMPLETE.md, DAY3_EXTENDED_CHECKLIST.md, DAY3_EXTENDED_COMPLETE.md
  - DAY3_FINAL_SUMMARY.md, DAY3_PROGRESS.md
  - DAY4_INTERVIEW_NOTES.md, DAY4_STATUS.md, DAY4_VISUAL_SUMMARY.md
  - DAY5_COMPLETE_SUMMARY.md, DAY5_PERFORMANCE_TEST_RESULTS.md
  - DAY_2_COMPLETION_STATUS.md, DAY_2_GOOGLE_TEST_MIGRATION.md
  - DAY_2_PROTOBUF_VS2026_SUMMARY.md, DAY_2_REFACTORING.md, DAY_2_SUMMARY.md
  - DAY_3_BUILD_ISSUES.md, DAY_3_BUILD_SUCCESS.md
- [ ] **Update CHANGELOG.md** to reference archives
- [ ] **Keep in root docs/:**
  - ARCHITECTURE_DIAGRAMS.md (active reference)
  - BUILD_GUIDE.md (still relevant)
  - BUILD_TROUBLESHOOTING.md (still relevant)
  - TESTING_SETUP_GUIDE.md (still relevant)

**Effort:** 30 minutes  
**Interview Value:** ⭐⭐⭐ (professional appearance)

**Deadline:** Today

---

### 1.5 TelemetryHub - Career/Interview Docs (ARCHIVE CANDIDATE)
**Status:** 🟡 **PERSONAL** - 20+ career docs should not be in project repo  
**Impact:** Unprofessional mixing of project docs with personal career materials

**Tasks:**
- [ ] **Create docs/archives/career-preparation/** folder
- [ ] **Move 20+ career-related files:**
  - amaresh_career_context.md
  - career_decision_journal.md
  - cover_letters/ (entire folder)
  - cover_letter_booking_backend_engineer.md
  - cover_letter_kubota_sensor_engineer.md
  - cv_improvement_guide_amaresh.md
  - day19_career_strategy.md
  - day19_cv_recommendations.md
  - day19_interaction_log.md
  - day19_interview_guidance.md
  - job_analysis_alpha_credit.md
  - linkedin_about_natural.md
  - linkedin_about_section.md
  - linkedin_job_search_strategy.md
  - resume_content_updated_telemetrytaskprocessor.md
  - telemetrytaskprocessor_reframe_plan.md
  - reframing_complete_summary.md
  - SESSION_SUMMARY_2025_12_31.md
  - TASKS_COMPLETED_JAN1_PART2.md
  - TASKS_SUMMARY_REPO_ORG.md
- [ ] **Keep in root docs/:**
  - SENIOR_TO_ARCHITECT_JOURNEY_2025.md (technical learning summary - OK)
  - EMBEDDED_SKILLS_IN_BACKEND.md (technical skills mapping - OK)
  - MULTITHREADING_ARCHITECTURE_DIAGRAM.md (technical deep dive - OK)

**Effort:** 30 minutes  
**Interview Value:** ⭐⭐⭐⭐ (professional separation)

**Deadline:** Today

---

## 🟡 PRIORITY 2: Strategic Enhancements

### 2.1 TelemetryHub - Demo Screenshots & Video
**Status:** 🔴 **MISSING** - No visual proof of GUI  
**Impact:** Can't showcase Qt6 work in portfolio

**Tasks:**
- [ ] **Record 2-minute demo video**
  - Scene 1: Launch GUI, connect to gateway (10s)
  - Scene 2: Real-time telemetry visualization with charts (30s)
  - Scene 3: REST API calls with curl (30s)
  - Scene 4: k6 load test showing sustained throughput (30s)
  - Scene 5: Grafana dashboard (if implemented) (20s)
  - **Tool:** OBS Studio (free, professional quality)
  - **Upload:** YouTube (unlisted), embed in README
  - **Effort:** 2 hours (recording + editing)
  - **Interview Value:** ⭐⭐⭐⭐⭐

- [ ] **Take professional screenshots**
  - Qt6 GUI main window (telemetry display)
  - Qt6 GUI with real-time charts (if enhanced)
  - Grafana dashboard (if implemented)
  - Terminal: k6 load test results
  - Terminal: curl REST API examples
  - **Tool:** Windows Snipping Tool, annotations with Greenshot
  - **Storage:** `docs/images/` folder
  - **Effort:** 1 hour
  - **Interview Value:** ⭐⭐⭐⭐

- [ ] **Update README.md with visuals**
  - Add screenshots section
  - Embed demo video
  - Add GIF of GUI in action (use ScreenToGif)
  - **Effort:** 30 minutes
  - **Interview Value:** ⭐⭐⭐⭐⭐

**Interview Talk Track:**
> "Here's a 2-minute demo showing the Qt6 GUI, REST API, and load testing. You can see real-time telemetry visualization and sustained 45k samples/sec throughput."

**Deadline:** Week 2

---

### 2.2 TelemetryHub - Qt6 GUI Enhancements
**Status:** 🟡 **BASIC** - Only 2 labels, no charts  
**Impact:** Misses opportunity to showcase full-stack skills

**Reference:** `docs/QT_GUI_ENHANCEMENT_PLAN.md` (already created, 700 lines)

**Tier 1 - Weekend Project (2-3 hours):**
- [ ] Add QtCharts line graph (real-time telemetry plot)
- [ ] Add metrics dashboard (queue size, samples/sec, uptime)
- [ ] Improve layout with QGridLayout

**Tier 2 - Week Project (5-8 hours):**
- [ ] Data export to CSV/JSON
- [ ] Alarm system (threshold alerts with QMessageBox)
- [ ] Configuration panel (change polling rate, queue size)

**Interview Value:** ⭐⭐⭐⭐⭐ (demonstrates full-stack capability)

**Deadline:** Week 3-4

---

### 2.3 Telemetry-Platform - Consolidate Documentation
**Status:** 🟡 **FRAGMENTED** - 46+ markdown files, hard to navigate  
**Impact:** Potential clients/interviewers get lost

**Tasks:**
- [ ] **Create docs/README.md** as navigation hub
  - Categories: Architecture, Build Guides, Testing, Profiling, Interview Prep
  - Quick links to most important docs
  - Brief descriptions of each category
  - **Effort:** 1 hour
  - **Interview Value:** ⭐⭐⭐

- [ ] **Consolidate overlapping docs:**
  - Merge: BUILD_GUIDE.md + BUILD_TROUBLESHOOTING.md → BUILD_COMPLETE_GUIDE.md
  - Merge: TESTING_SETUP_GUIDE.md + TESTING_FRAMEWORKS_COMPARISON.md → TESTING_COMPLETE_GUIDE.md
  - Archive: Duplicates, outdated content
  - **Effort:** 2 hours
  - **Interview Value:** ⭐⭐⭐

**Deadline:** Week 2

---

## 🟢 PRIORITY 3: Polish & Maintenance

### 3.1 TelemetryHub - Branch Cleanup Completion
**Status:** 🟢 **ALMOST DONE** - 67/68 deleted, 6 remaining  
**Impact:** Minor, but completes cleanup task

**Tasks:**
- [ ] Delete remaining feature branches:
  - `origin/headers_vs`
  - `origin/show_headers_option_C`
  - `origin/v6.0.0` (resolve tag conflict first)
- [ ] Run `scripts/cleanup_local_branches.ps1` (already created)
- [ ] Verify final count: 3 branches (main, release-v4.1.1, dev-main)

**Effort:** 15 minutes  
**Deadline:** Today

---

### 3.2 TelemetryHub - Copilot Attribution Verification
**Status:** 🟡 **WAITING** - GitHub cache update in progress  
**Impact:** Minor, but good to verify

**Tasks:**
- [ ] Check https://github.com/amareshkumar/telemetryhub/graphs/contributors
- [ ] Verify only "Amaresh Kumar" appears
- [ ] If still shows Copilot: Wait another 24-48 hours (GitHub cache)

**Expected:** Should be fixed by January 3, 2026  
**Deadline:** January 3

---

### 3.3 GitHub Releases Creation
**Status:** 🔴 **MISSING** - Tags exist but no releases  
**Impact:** Misses opportunity for professional presentation

**Tasks:**
- [ ] **Create TelemetryHub v6.1.0 release**
  - Visit: https://github.com/amareshkumar/telemetryhub/releases/new?tag=v6.1.0
  - Copy content from: `RELEASE_v6.1.0.md`
  - Mark as "Latest release"
  - **Effort:** 5 minutes
  - **Interview Value:** ⭐⭐⭐⭐

- [ ] **Create Telemetry-Platform v5.1.0 release**
  - Visit: https://github.com/amareshkumar/telemetry-platform/releases/new?tag=v5.1.0
  - Copy content from: `RELEASE_v5.1.0.md`
  - Mark as "Latest release"
  - **Effort:** 5 minutes
  - **Interview Value:** ⭐⭐⭐⭐

**Deadline:** Today

---

## 🔵 PRIORITY 4: Future Enhancements (Post-Offer)

### 4.1 Advanced Performance Engineering
- [ ] Tracy profiler integration (visualization of thread activity)
- [ ] Cache locality optimization (align queue to cache lines)
- [ ] SIMD optimization for telemetry processing
- [ ] Lock-free queue implementation comparison

**Interview Value:** ⭐⭐⭐⭐⭐ (Principal/Staff level)  
**Effort:** 2-3 days per item  
**Deadline:** After securing interviews

---

### 4.2 Cloud-Native Features
- [ ] Kubernetes deployment manifests (Helm chart)
- [ ] OpenTelemetry distributed tracing
- [ ] gRPC API (in addition to REST)
- [ ] Multi-region deployment guide

**Interview Value:** ⭐⭐⭐⭐⭐ (Staff/Principal level)  
**Effort:** 1 week total  
**Deadline:** After securing interviews

---

### 4.3 Compliance & Standards Documentation
- [ ] MISRA C++ compliance report (automated with cppcheck)
- [ ] IEC 62443 security controls mapping
- [ ] ISO 21434 threat analysis (TARA)
- [ ] Software Bill of Materials (SBOM)

**Interview Value:** ⭐⭐⭐⭐⭐ (Automotive/Industrial roles)  
**Effort:** 2-3 days  
**Deadline:** When targeting automotive/industrial roles

---

## 📅 Recommended Timeline

### Week 1 (January 2-8, 2026) - CRITICAL PATH
**Goal:** Fix blockers, prepare for interviews

**Monday-Tuesday (Jan 2-3):**
- ✅ Create this tracking document
- [ ] Archive outdated docs (both repos)
- [ ] Create GitHub releases (v6.1.0, v5.1.0)
- [ ] Add linux-ninja-coverage preset
- [ ] Re-enable coverage CI job
- [ ] Run k6 load tests, document results

**Wednesday-Thursday (Jan 4-5):**
- [ ] Implement stress_test tool
- [ ] Create PERFORMANCE_BENCHMARKS.md
- [ ] Add performance badges to README

**Friday-Sunday (Jan 6-8):**
- [ ] Implement Prometheus metrics exporter
- [ ] Add health check endpoints
- [ ] Take screenshots, record demo video

**Deliverables:**
- ✅ All CI jobs green (including coverage)
- ✅ Performance validated and documented
- ✅ Visual proof of GUI (video + screenshots)
- ✅ Professional documentation structure

---

### Week 2 (January 9-15, 2026) - ENHANCEMENTS
**Goal:** Strategic improvements, maximize hireability

**Tasks:**
- [ ] Create Grafana dashboard
- [ ] Consolidate Telemetry-Platform docs
- [ ] Qt6 GUI Tier 1 enhancements (if time permits)

**Deliverables:**
- ✅ Production-ready observability
- ✅ Clean, navigable documentation
- ✅ Enhanced GUI (optional)

---

### Week 3+ (January 16+, 2026) - POLISH
**Goal:** Continuous improvement based on interview feedback

**Tasks:**
- [ ] Qt6 GUI Tier 2 enhancements
- [ ] Additional performance optimizations
- [ ] Advanced features (Tracy profiling, etc.)

**Deliverables:**
- ✅ Interview-ready in all dimensions
- ✅ Continuous updates based on feedback

---

## 🎯 Success Metrics

### Technical Excellence
- [ ] **Code Coverage:** >90% (with badge)
- [ ] **CI Status:** All jobs green ✅
- [ ] **Performance:** Validated and documented (>40k samples/sec)
- [ ] **Documentation:** <15 docs in root (rest archived)
- [ ] **Visual Proof:** 2-minute demo video + 5 screenshots

### Professional Presentation
- [ ] **GitHub Profile:** Clean (20 repos, only 3 forks)
- [ ] **Repository Structure:** Professional (no career docs in project)
- [ ] **Releases:** Both repos have v6.1.0/v5.1.0 releases
- [ ] **README Quality:** Badges, visuals, clear value proposition

### Interview Readiness
- [ ] **30-Second Pitch:** Memorized for both repos
- [ ] **Performance Numbers:** Memorized (408k ops/sec, <200ms p95, etc.)
- [ ] **Architecture Talk Track:** Can draw diagrams on whiteboard
- [ ] **Production Ops:** Can discuss metrics, monitoring, health checks

---

## 📝 Notes & Context

### Why This Matters
1. **Senior Engineer Role:** Requires proof of production operations, performance validation, comprehensive testing
2. **Software Architect Role:** Requires system design thinking, trade-off analysis, scalability patterns
3. **Client Appeal:** Professional presentation, active maintenance, clear value proposition
4. **€68.4k+ Salary:** Requires demonstration of Staff/Principal-level capabilities

### Key Differentiators
- ✅ **Two complementary portfolios** (focused vs. comprehensive)
- ✅ **Production-grade code** (not toy projects)
- ✅ **Professional DevOps** (CI/CD, semantic versioning, releases)
- ✅ **Modern C++ expertise** (C++17/20/23, templates, multithreading)
- ✅ **Full-stack capability** (backend + Qt6 GUI + DevOps)

### Quick Wins for Today
1. Archive outdated docs (1 hour)
2. Create GitHub releases (10 minutes)
3. Add coverage preset (30 minutes)
4. Re-enable coverage CI (20 minutes)

**Total:** ~2 hours for massive professional appearance improvement!

---

## 🔗 Related Documents

- **TelemetryHub:**
  - [FUTURE_WORK.md](c:\code\telemetryhub\docs\FUTURE_WORK.md) - Detailed enhancement roadmap
  - [ACTION_ITEMS_JAN2026.md](c:\code\telemetryhub\docs\ACTION_ITEMS_JAN2026.md) - Completed Jan 1 tasks
  - [QT_GUI_ENHANCEMENT_PLAN.md](c:\code\telemetryhub\docs\QT_GUI_ENHANCEMENT_PLAN.md) - GUI improvement guide

- **Telemetry-Platform:**
  - [CHANGELOG.md](c:\code\telemetry-platform\ingestion\CHANGELOG.md) - Version history
  - [LYRIA_SOFT_EXPERIENCE.md](c:\code\telemetry-platform\LYRIA_SOFT_EXPERIENCE.md) - Professional positioning

- **Career:**
  - [SENIOR_TO_ARCHITECT_JOURNEY_2025.md](c:\code\telemetryhub\docs\SENIOR_TO_ARCHITECT_JOURNEY_2025.md) - Technical learning summary

---

**Last Updated:** January 2, 2026  
**Next Review:** End of Week 1 (January 8, 2026)  
**Status:** 🟢 **ACTIVE** - Critical path items prioritized
