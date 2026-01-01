# Project Conceptual Differences: TelemetryHub vs Telemetry-Platform

**Purpose:** Quick reference to prevent redundant features across projects

---

## Core Purpose

### TelemetryHub
**"How to BUILD high-performance systems"**
- Focus: Implementation excellence
- Audience: Senior Developers
- Skills: C++20, Qt6, build systems, optimization

### Telemetry-Platform
**"How to DESIGN scalable systems"**
- Focus: Architecture patterns
- Audience: System Architects
- Skills: Microservices, distributed coordination, service boundaries

---

## Feature Matrix

| Feature Category | TelemetryHub | Telemetry-Platform |
|-----------------|--------------|-------------------|
| **Language Features** | ✅ C++20 showcase | ✅ C++17 (stable) |
| **GUI** | ✅ Qt6 (charts, metrics) | ❌ Server-only |
| **Build System** | ✅ FASTBuild optimization | ✅ FASTBuild support (added Jan 2026) |
| **Architecture** | Monolithic gateway | ✅ Microservices |
| **Service Separation** | Single process | ✅ Multiple services |
| **Coordination** | In-process queues | ✅ Redis-based |
| **Testing Focus** | Performance, GUI tests | ✅ BDD (Catch2), integration, load |
| **Documentation Focus** | Build systems, Qt dev | ✅ Architecture decisions |

---

## What Belongs Where

### ✅ Add to TelemetryHub (Implementation Focus)

**UI/UX Enhancements:**
- ✅ More Qt widgets (status indicators, configuration panels)
- ✅ Chart enhancements (histograms, scatter plots, heatmaps)
- ✅ Dark mode, themes, customizable layouts
- ✅ Export data to CSV, JSON

**C++20 Features:**
- ✅ Concepts for generic telemetry processors
- ✅ Ranges for data transformation pipelines
- ✅ Coroutines for async operations
- ✅ Modules (when compiler support stable)

**Build System:**
- ✅ FASTBuild distributed build guides
- ✅ Build time optimization techniques
- ✅ Cache strategies documentation
- ✅ CI/CD pipeline optimization

**Performance:**
- ✅ SIMD optimizations
- ✅ Memory pooling
- ✅ Lock-free data structures
- ✅ Profiling tools integration (VTune, perf)

**Single-Process Optimizations:**
- ✅ Thread pool tuning
- ✅ Zero-copy techniques
- ✅ Custom allocators

---

### ✅ Add to Telemetry-Platform (Architecture Focus)

**Service Expansion:**
- ✅ Analytics service (separate microservice)
- ✅ Alerting service (rule engine)
- ✅ Storage service (time-series DB abstraction)
- ✅ API gateway (routing, rate limiting)

**Distributed Patterns:**
- ✅ Service mesh (Istio, Linkerd)
- ✅ Circuit breakers between services
- ✅ Saga pattern for distributed transactions
- ✅ Event sourcing
- ✅ CQRS (Command Query Responsibility Segregation)

**Observability:**
- ✅ Distributed tracing (OpenTelemetry, Jaeger)
- ✅ Centralized logging (ELK stack)
- ✅ Service-level metrics (RED method)
- ✅ Dependency graphs

**Deployment:**
- ✅ Kubernetes manifests
- ✅ Helm charts
- ✅ Docker Compose for local development
- ✅ Infrastructure as Code (Terraform)

**Scaling:**
- ✅ Horizontal pod autoscaling
- ✅ Message queue patterns (Kafka, RabbitMQ)
- ✅ Sharding strategies
- ✅ Load balancing algorithms

**Architecture Documentation:**
- ✅ ADR (Architecture Decision Records)
- ✅ Service dependency diagrams
- ✅ Data flow diagrams
- ✅ Failure mode analysis

---

## ❌ What NOT to Duplicate

### DON'T Add to TelemetryHub:
- ❌ Separate microservices (belongs to Platform)
- ❌ Redis coordination (belongs to Platform)
- ❌ Service mesh (belongs to Platform)
- ❌ Kubernetes deployment (belongs to Platform)
- ❌ Inter-service communication patterns (belongs to Platform)

**Why?** TelemetryHub focuses on **how to build ONE service well**, not multiple services.

### DON'T Add to Telemetry-Platform:
- ❌ Qt GUI (belongs to TelemetryHub)
- ❌ FASTBuild optimization guides (belongs to TelemetryHub)
- ❌ C++20 showcase features (belongs to TelemetryHub)
- ❌ GUI-specific optimizations (belongs to TelemetryHub)
- ❌ Desktop application patterns (belongs to TelemetryHub)

**Why?** Telemetry-Platform focuses on **service architecture**, not user-facing implementation.

---

## Architecture Decision Boundaries

### TelemetryHub Decisions (Implementation Level)

**Questions answered:**
- What's the most efficient data structure?
- How to optimize memory layout?
- Which threading model performs best?
- How to minimize build times?
- What GUI framework provides best UX?

**Example PRs:**
- "Add QChartView for real-time visualization"
- "Optimize queue with lock-free algorithms"
- "Integrate FASTBuild for 12× speedup"
- "Add C++20 concepts for type safety"

### Telemetry-Platform Decisions (Architecture Level)

**Questions answered:**
- How to separate concerns across services?
- What coordination mechanism scales best?
- How to handle partial failures?
- What's the right service granularity?
- How to ensure data consistency?

**Example PRs:**
- "Split monolith into ingestion/processing services"
- "Add Redis for async task coordination"
- "Implement circuit breaker between services"
- "Add OpenTelemetry distributed tracing"

---

## Interview Positioning

### When to Lead with TelemetryHub:

**Job Description mentions:**
- "Senior C++ Developer"
- "Performance optimization"
- "Desktop application development"
- "Modern C++ (C++17/20)"
- "GUI development (Qt, wxWidgets)"
- "Build system optimization"

**Talking points:**
- "I optimized build times from 180s to 15s using FASTBuild"
- "I built a Qt6 GUI with real-time charting"
- "I used C++20 concepts for type-safe APIs"

### When to Lead with Telemetry-Platform:

**Job Description mentions:**
- "System Architect"
- "Microservices architecture"
- "Distributed systems"
- "Service-oriented architecture"
- "Kubernetes/Docker"
- "Scalability engineering"

**Talking points:**
- "I designed a microservices platform with separate ingestion/processing services"
- "I implemented Redis-based async coordination for distributed tasks"
- "I documented architecture decisions with 12 MB of ADRs and design docs"

---

## Quick Decision Tree

```
New feature idea?
  ↓
Is it about GUI/visualization?
  YES → TelemetryHub
  NO  → Continue
  ↓
Is it about C++20 language features?
  YES → TelemetryHub
  NO  → Continue
  ↓
Is it about build system optimization?
  YES → TelemetryHub
  NO  → Continue
  ↓
Is it about service separation?
  YES → Telemetry-Platform
  NO  → Continue
  ↓
Is it about distributed coordination?
  YES → Telemetry-Platform
  NO  → Continue
  ↓
Is it about multiple services?
  YES → Telemetry-Platform
  NO  → Continue
  ↓
Is it about deployment/orchestration?
  YES → Telemetry-Platform
  NO  → Could go in either (discuss)
```

---

## Examples of Good Decisions

### ✅ TelemetryHub: Add Dark Mode Theme
**Rationale:** GUI enhancement, improves UX, shows Qt expertise

### ✅ Telemetry-Platform: Add Analytics Service
**Rationale:** New microservice, demonstrates service separation

### ✅ TelemetryHub: Integrate VTune Profiler
**Rationale:** Performance tooling, optimization focus

### ✅ Telemetry-Platform: Add Kubernetes Manifests
**Rationale:** Deployment architecture, scaling strategy

---

## Examples of Bad Decisions (Redundant)

### ❌ Add Qt GUI to Telemetry-Platform
**Problem:** GUI already in TelemetryHub, creates duplication
**Alternative:** Keep Platform server-only, reference TelemetryHub for GUI

### ❌ Add Microservices to TelemetryHub
**Problem:** Architecture already demonstrated in Platform
**Alternative:** Keep TelemetryHub monolithic, reference Platform for microservices

### ❌ Write FASTBuild guide in Platform
**Problem:** Build optimization already documented in TelemetryHub
**Alternative:** Reference TelemetryHub's FASTBuild guide

---

## Reminder Checklist

Before adding a major feature, ask:

- [ ] Does this fit the project's core purpose?
- [ ] Is this already demonstrated in the other project?
- [ ] Will this create redundancy?
- [ ] Does this align with the target role (Senior Dev vs Architect)?
- [ ] Can I explain why this goes in THIS project during an interview?

---

**Last Updated:** January 1, 2026  
**Review:** Before any major feature addition
