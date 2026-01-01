# Project Strategy: TelemetryHub & Telemetry-Platform

**Date:** January 1, 2026  
**Decision:** Keep both projects public with clear differentiation

---

## Why Two Telemetry Projects?

After careful analysis and discussion, we decided to maintain **both projects** as complementary portfolio pieces targeting different aspects of software engineering expertise.

### The Key Insight

These are NOT competing or duplicate projects. They demonstrate **different skill levels**:

| Project | **TelemetryHub** | **Telemetry-Platform** |
|---------|------------------|------------------------|
| **Focus** | Implementation Mastery | Architecture Vision |
| **Demonstrates** | How to BUILD | How to DESIGN |
| **Target Role** | Senior Developer | System Architect |
| **Architecture** | Optimized monolithic gateway | Microservices with service separation |

---

## Career Context: Two Job Profiles

Amaresh is targeting **two different career paths**:
- **Senior Developer positions**: Require deep technical implementation skills
- **System Architect positions**: Require distributed systems design expertise

**Having both projects proves:** "I can CODE at senior level AND DESIGN at architect level"

---

## Project Differentiation

### TelemetryHub: "Performance & User Experience"

**Tagline:** "High-performance IoT gateway with modern C++20 and real-time Qt6 visualization"

**What it demonstrates:**
- ✅ Modern C++20 features (concepts, ranges, modules)
- ✅ Qt6 GUI development (charts, metrics dashboard, async HTTP)
- ✅ Build system expertise (FASTBuild integration: 12× speedup, 180s → 15s)
- ✅ Performance optimization (3,720 req/s, p95 < 50ms)
- ✅ Real-time visualization (60-sample rolling charts)

**Technical highlights:**
- 377 commits of iterative refinement
- FASTBuild distributed compilation
- Qt6 with QCharts and QTableWidget
- Comprehensive build documentation (2,400+ lines)

**Interview talking point:**  
*"Shows I can implement high-performance, user-facing applications with modern C++ and optimize build pipelines for team productivity."*

---

### Telemetry-Platform: "Architecture & Scale"

**Tagline:** "Production-ready microservices platform: Ingestion + Processing with Redis coordination"

**What it demonstrates:**
- ✅ Microservices architecture (separate ingestion/processing services)
- ✅ Distributed systems design (Redis task queue, async coordination)
- ✅ Service separation (independent scaling, fault isolation)
- ✅ Comprehensive testing (Catch2 BDD, GTest, pytest, k6 load tests)
- ✅ Architecture documentation (12 MB of design decisions)

**Technical highlights:**
- 63 MB codebase (7.5× larger than TelemetryHub)
- True monorepo structure (ingestion/, processing/, common/)
- Redis-coordinated async processing
- Multiple testing frameworks integrated

**Interview talking point:**  
*"Shows I can architect distributed systems with proper service boundaries, choose appropriate coordination mechanisms, and validate scalability with comprehensive testing."*

---

## The Portfolio Narrative

### Interview Question: "Why two telemetry projects?"

**WEAK Answer:** ❌ *"Oh, I was experimenting..."*

**STRONG Answer:** ✅  
*"They demonstrate different aspects of my expertise:*

- *TelemetryHub shows my **implementation skills** - C++20, Qt6 GUI, FASTBuild integration for 12× build speedup, real-time data visualization. 377 commits of iterative refinement.*

- *Telemetry-Platform shows my **architecture skills** - microservices design, Redis-coordinated async processing, separation of ingestion/processing concerns for independent scaling. 12 MB of architecture documentation.*

*Together they show I can both **architect distributed systems** AND **implement high-performance components**."*

---

## Data-Driven Comparison

| Metric | TelemetryHub | Telemetry-Platform | Analysis |
|--------|--------------|-------------------|----------|
| **Commits** | 377 | 38 | TelemetryHub: More iterative development |
| **Codebase** | 8.4 MB (278 files) | 63 MB (5,626 files) | Platform: More comprehensive |
| **Documentation** | 2 MB (recent, polished) | 12 MB (exhaustive) | Platform: More detailed |
| **Focus** | Monolithic optimization | Distributed design | Different problem spaces |
| **GUI** | ✅ Qt6 with charts | ❌ Server-only | TelemetryHub: User-facing |
| **Build System** | ✅ FASTBuild + MSBuild | MSBuild (FASTBuild added Jan 2026) | TelemetryHub: Build optimization focus |
| **Architecture** | Device → Gateway → Storage | Ingestion ⇄ Redis ⇄ Processing | Platform: Microservices |

---

## Complementary, Not Redundant

### Different Stages of System Design

```
TelemetryHub asks: "What's the BEST way to build ONE service?"
  → Deep technical skills, optimization, modern C++, user experience

Telemetry-Platform asks: "What's the BEST way to architect MANY services?"
  → Systems thinking, scaling strategy, distributed coordination, service boundaries
```

### Career Flexibility

**Applying for Senior Developer?**
- ✅ Lead with TelemetryHub
- ✅ Emphasize: Qt GUI, FASTBuild, C++20, performance optimization
- ✅ Mention Platform as: "evolved to microservices architecture"

**Applying for System Architect?**
- ✅ Lead with Telemetry-Platform
- ✅ Emphasize: Microservices, Redis coordination, service separation, comprehensive testing
- ✅ Mention TelemetryHub as: "deep implementation expertise in each component"

---

## README Cross-References

Both READMEs include cross-references to show deliberate complementary design:

**TelemetryHub README includes:**
> **Related Project:** For microservices architecture approach, see [Telemetry-Platform](https://github.com/amareshkumar/telemetry-platform)

**Telemetry-Platform README includes:**
> **Related Project:** For deep C++20 implementation with Qt6 GUI, see [TelemetryHub](https://github.com/amareshkumar/telemetryhub)

---

## The 30-Second Elevator Pitch

*"I have two telemetry projects showcasing different expertise levels.*

*TelemetryHub demonstrates my **implementation skills** - high-performance C++20 gateway with FASTBuild integration (12× faster builds) and Qt6 real-time visualization. 377 commits of refinement.*

*Telemetry-Platform demonstrates my **architecture skills** - microservices design with Redis coordination, separate ingestion/processing services for independent scaling. 12 MB of architecture docs.*

*Together they show I can both **architect distributed systems** and **implement high-performance components**."*

---

## Decision Timeline

1. **Initial thought:** Keep only Telemetry-Platform (larger, more documented)
2. **Concern:** Looks unfocused, duplicate effort
3. **Analysis:** Measured commits, code volume, documentation
4. **Insight:** They're complementary, not competing
5. **Decision:** Keep both, differentiate clearly
6. **Execution:** Add FASTBuild to Platform, update READMEs, cross-reference

---

## Going Forward: Preventing Redundancy

### What to add to TelemetryHub:
- ✅ Qt GUI enhancements (more charts, metrics)
- ✅ Build system optimizations (distributed compilation docs)
- ✅ C++20 features showcase
- ✅ Performance profiling tools
- ❌ **NOT** microservices architecture (belongs to Platform)
- ❌ **NOT** service separation (belongs to Platform)

### What to add to Telemetry-Platform:
- ✅ More microservices (add analytics service, alerting service)
- ✅ Service mesh integration (Istio, Linkerd)
- ✅ Kubernetes deployment manifests
- ✅ Distributed tracing (OpenTelemetry)
- ❌ **NOT** Qt GUI (belongs to TelemetryHub)
- ❌ **NOT** FASTBuild optimization guides (belongs to TelemetryHub)

---

## Conclusion

**This is a strength, not a weakness.**

Two focused projects demonstrate:
- **Breadth:** Multiple approaches to similar problems
- **Depth:** 377 commits in one, 12 MB docs in other
- **Evolution:** From monolithic to microservices thinking
- **Versatility:** Can target two different career levels

**Position:** Complementary portfolio pieces, not competing projects.

---

**Last Updated:** January 1, 2026  
**Next Review:** Before major feature additions to either project
