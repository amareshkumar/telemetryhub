# Career Strategy: Build vs Interview Prep - Decision Journal

**Purpose**: Document critical career decisions, skill gap analysis, and strategic reasoning for future reflection.

**Created**: December 25, 2025  
**Context**: 200+ job applications (Nov-Dec 2025), low conversion rate, identified distributed systems skill gap

---

## Decision #1: CMake vs Bazel for DistQueue (Dec 25, 2025)

### Question
"Should I use Bazel instead of CMake for DistQueue? One interview asked about Bazel experience."

### Analysis

#### Bazel's Strengths (Why Companies Ask)
- **Hermetic builds**: Perfect reproducibility across machines
- **Fast incremental builds**: Shines in large monorepos (100K+ LOC)
- **Polyglot support**: Excellent for mixed C++/Python/Go/Java projects
- **Scale**: Used by Google, Uber, trading firms, large tech companies
- **Modern tooling**: Shows exposure to cutting-edge build systems

#### Bazel vs CMake Trade-offs

| Aspect | CMake | Bazel |
|--------|-------|-------|
| **Learning Curve** | 1-2 hours (familiar) | 1-2 days (new concepts) |
| **Ecosystem Support** | 90% of C++ libraries | ~30% native, manual BUILD files needed |
| **Sweet Spot** | 1K-100K LOC projects | 100K+ LOC monorepos |
| **Industry Adoption** | ~90% C++ projects | ~5% (but growing at top firms) |
| **DistQueue Size** | Perfect fit (5K LOC) | Overkill |
| **Time Investment** | Already done (Day 1) | 10-15% of 2-week timeline |

#### Decision: **Stick with CMake for DistQueue**

**Reasoning:**
1. **Time constraint**: 2 weeks total, already invested Day 1 in CMake
2. **Appropriate tool**: CMake is correct choice for 5K LOC project
3. **Feature focus**: Want distributed systems experience, not build system experience
4. **ROI**: 1-2 days learning Bazel = 10% less distributed systems hands-on time

**Better Strategy:**
1. **Primary**: Keep CMake for DistQueue (maximize feature development)
2. **Parallel**: Add Bazel to interview prep learning list (4 hours total):
   - Read Bazel concepts (BUILD files, workspaces, hermetic builds)
   - Understand when Bazel beats CMake (monorepos, reproducibility)
   - Prepare interview answer (see below)
3. **Optional (Day 13+)**: Add parallel Bazel BUILD files to DistQueue as bonus

#### Interview Answer Template (Bazel)

**If Asked: "Do you have Bazel experience?"**

> "I haven't used Bazel in production yet, but I understand why it's valuable - hermetic builds and excellent performance for large monorepos. I chose CMake for my DistQueue project because it's the C++ ecosystem standard and appropriate for the project size (~5K LOC). Bazel would be overkill there, but I'd be excited to learn it here, especially for [your company's monorepo]. I've read about its advantages for reproducible builds at scale, and I understand the concepts of BUILD files, workspaces, and hermetic dependencies."

**Key Points:**
- ✅ Honest (no Bazel experience)
- ✅ Knowledgeable (understand when to use it)
- ✅ Pragmatic (chose right tool for project size)
- ✅ Eager (want to learn in right context)

---

## Decision #2: Distributed Systems Value for C++ System Programmer (Dec 25, 2025)

### Question
"Does distributed systems add value to my C++ system coding background? Will it increase job chances?"

### Answer: **ABSOLUTELY YES - This is EXACTLY the Missing Gap**

### Evidence: Current Market Reality

**Your Situation:**
- 📊 200+ applications submitted (Nov-Dec 2025)
  - 100+ LinkedIn Jobs
  - 50+ Indeed.com
  - 50+ company career pages
- 📉 Low conversion rate (few interviews, fewer offers)
- 🎯 Target roles: C++ Backend, Low-latency systems, Cloud infrastructure
- ❌ **ROOT CAUSE**: Failing interviews at distributed systems questions

### What Interviews Likely Look Like

#### Scenario 1: Task Queue Design (Booking.com, Amazon)

**Interviewer**: "Design a distributed task queue that handles 1 million tasks per second."

**You (Before DistQueue - Internal Monologue)**:
```
"Ok, task queue... I know queues, I've used std::queue...
But 1 million/sec? That's distributed... multiple servers?
How do they coordinate? Redis? Kafka? I've heard of those...
Sharding? Partitioning? Load balancing? Uh...
I'm blanking. I can talk about thread pools? No, that's single process..."
```

**Result**: ❌ Can't design distributed system, lacks hands-on experience

**Interviewer's Mental Note**: "Good C++ skills, but no distributed systems experience. Next candidate."

---

**You (After DistQueue - With Confidence)**:
```
"I actually built a distributed task queue recently. Let me walk through the design:

1. Task Submission Layer
   - Multiple producers (C++/Python clients)
   - Priority-based routing (HIGH/NORMAL/LOW queues)
   - Target: 1M tasks/sec → need horizontal scaling

2. Queue Backend
   - Redis Cluster for persistence (why not single Redis: bottleneck at ~200K ops/sec)
   - Sharding by task ID hash (consistent hashing)
   - Each shard handles ~250K tasks/sec (4 shards total)

3. Worker Pool
   - Stateless workers (scale horizontally)
   - BLPOP from priority queues (blocking, no polling overhead)
   - Exactly-once delivery using Redis transactions (Lua scripts)

4. Coordination Challenges I Hit:
   - Initially used WATCH/MULTI/EXEC → starvation under high contention
   - Switched to Lua scripts for atomic operations
   - Throughput improved from 800 to 1200 tasks/sec per shard

5. Observability
   - Prometheus metrics: queue_depth, task_latency_p99, throughput
   - Alerting on queue depth > threshold (backpressure detection)

Trade-offs:
- Redis Cluster adds complexity vs single Redis (operational overhead)
- But necessary for throughput target
- Alternative: Kafka (higher throughput, more complex, overkill for task queue)"
```

**Result**: ✅ Detailed design with real experience, trade-off discussions, debugging stories

**Interviewer's Mental Note**: "Solid distributed systems thinking. Good candidate. Continue."

---

#### Scenario 2: Coordination & Consistency (Trading Firm)

**Interviewer**: "How do you ensure exactly-once delivery in a distributed system?"

**You (Before)**:
```
"Exactly-once... I know transactions in databases...
In distributed? Um... two-phase commit? I read about that...
But I've never implemented it. How does it work again?
Is that Paxos? Raft? I'm mixing concepts..."
```

**Result**: ❌ Theoretical knowledge, no hands-on experience

---

**You (After DistQueue)**:
```
"In my DistQueue project, I implemented exactly-once delivery. Here's what I learned:

1. Problem: Workers crash mid-task
   - Task popped from queue (BLPOP)
   - Worker crashes before completing
   - Task lost (not in queue, not completed)

2. Initial Solution: Two-phase processing
   - Phase 1: Move from pending → processing queue
   - Phase 2: On completion, remove from processing queue
   - But: Race condition if two workers pop same task

3. Final Solution: Redis Lua scripts (atomic operations)
   ```lua
   -- Atomic: pop from pending, add to processing with timestamp
   local task = redis.call('LPOP', 'pending')
   if task then
       redis.call('ZADD', 'processing', CURRENT_TIME, task)
   end
   return task
   ```
   
4. Worker Heartbeat:
   - Workers update heartbeat every 5 seconds
   - Separate reaper process checks for stale tasks (processing with old timestamp)
   - Returns stale tasks to pending queue

5. Idempotency:
   - Task execution may happen more than once (network failures)
   - Task handler must be idempotent (check completion status before executing)

This is 'at-least-once with idempotency' - simpler than true exactly-once (which requires distributed transactions). Trade-off: simpler implementation, task handlers need idempotency."
```

**Result**: ✅ Real implementation details, failure modes, trade-offs

---

#### Scenario 3: Low-Latency Systems (IMC, Optiver)

**Interviewer**: "You have embedded experience. How would you optimize a distributed cache for low latency?"

**You (Before)**:
```
"I optimized embedded for 38% performance gain using cache-friendly data structures...
But distributed cache? That's... Redis? Memcached?
Network latency dominates, right? ~100μs minimum?
I don't know optimization techniques for distributed systems..."
```

**Result**: ❌ Can't bridge embedded optimization → distributed optimization

---

**You (After DistQueue + Learning)**:
```
"My embedded background is perfect for this. I optimized for 38% perf gain using:
- Memory-aligned structures (cache line aware)
- Lock-free algorithms (atomics, CAS)
- Batch processing (reduce syscall overhead)

For distributed cache, similar principles apply but different scale:

1. Network is Bottleneck (~100μs RTT)
   - Embedded: Optimize CPU cycles (nanoseconds)
   - Distributed: Optimize network round-trips (microseconds)
   - Strategy: Batch requests, use pipelining

2. Memory Optimization (Same as Embedded)
   - Use memory pools (avoid malloc/free on critical path)
   - Zero-copy operations (scatter-gather I/O)
   - NUMA-aware memory allocation

3. Concurrency (Different Scale)
   - Embedded: Thread-level parallelism (mutexes, atomics)
   - Distributed: Process-level coordination (Redis locks, Lua scripts)
   - But same principles: minimize contention, lock-free where possible

4. Example: DistQueue Optimization
   - Initially: Individual Redis commands (1 RTT per task)
   - Optimized: Lua scripts for atomic multi-step operations (1 RTT)
   - Result: 50% latency reduction (p99: 100ms → 50ms)

The thinking is the same - identify bottleneck (CPU vs network), minimize overhead (cache misses vs RTTs), optimize hot path (profiling + iteration)."
```

**Result**: ✅ Bridges embedded → distributed, shows transferable optimization thinking

---

### Skill Bridge Analysis

#### Your Current Foundation (13 Years Embedded/System)

```
Core Strengths:
├── Memory Management
│   ├── Pointers, references, RAII
│   ├── Smart pointers (unique_ptr, shared_ptr)
│   ├── Custom allocators
│   └── Memory-constrained optimization
│
├── Concurrency (Thread-Level)
│   ├── std::thread, std::mutex
│   ├── Atomics, lock-free algorithms
│   ├── Condition variables, barriers
│   └── Data races, deadlock prevention
│
├── Performance Optimization
│   ├── 38% performance gain (TelemetryHub)
│   ├── Profiling (gprof, Valgrind)
│   ├── Cache-friendly data structures
│   └── 40% build time improvement
│
├── Fault Tolerance
│   ├── Safety standards (IEC 62304, ISO 26262)
│   ├── Fault injection testing
│   ├── Watchdogs, error recovery
│   └── Circuit breaker pattern
│
└── Testing Rigor
    ├── TDD, GTest framework
    ├── 8 test files, 117 commits
    ├── CI/CD (GitHub Actions)
    └── Code coverage tracking
```

#### Skills Gap for Target Roles (Backend C++ at Scale)

```
Missing Distributed Systems Skills:
├── Process Coordination (NEW - Not Thread Coordination)
│   ├── ❌ Redis locks, distributed locks
│   ├── ❌ Consensus algorithms (Raft, Paxos - awareness)
│   ├── ❌ Leader election
│   └── ❌ Distributed state management
│
├── Network Failures (Extension of Fault Tolerance)
│   ├── ❌ Retry strategies (exponential backoff)
│   ├── ❌ Timeout handling (cascading failures)
│   ├── ❌ Circuit breakers at network level
│   └── ✅ (You have circuit breaker, need distributed context)
│
├── Data Consistency (NEW)
│   ├── ❌ Exactly-once delivery
│   ├── ❌ Idempotency patterns
│   ├── ❌ Eventual consistency
│   └── ❌ CAP theorem (practical application)
│
├── Scalability Patterns (NEW)
│   ├── ❌ Horizontal scaling (not just multi-threading)
│   ├── ❌ Sharding, partitioning
│   ├── ❌ Load balancing strategies
│   └── ❌ Backpressure handling
│
└── Observability (Extension of Testing)
    ├── ❌ Distributed tracing
    ├── ❌ Prometheus metrics
    ├── ❌ Centralized logging
    └── ✅ (You have testing rigor, need distributed visibility)
```

#### Why Your Embedded Background is PERFECT Foundation

**Transferable Thinking:**

1. **Concurrency Concepts Transfer**
   - Embedded: Thread synchronization (mutexes) → Distributed: Process coordination (Redis locks)
   - Embedded: Atomics (CAS) → Distributed: Optimistic locking (WATCH/MULTI/EXEC)
   - Embedded: Deadlock prevention → Distributed: Distributed deadlock detection

2. **Fault Tolerance Extends Naturally**
   - Embedded: Device crashes → Distributed: Network partitions
   - Embedded: Watchdog timers → Distributed: Worker heartbeats
   - Embedded: Error recovery → Distributed: Task retry mechanisms

3. **Performance Optimization Scales**
   - Embedded: CPU cycles (nanoseconds) → Distributed: Network RTTs (microseconds)
   - Embedded: Cache misses → Distributed: Network round-trips
   - Embedded: Profiling bottlenecks → Distributed: Distributed tracing

4. **Resource Constraints Mindset**
   - Embedded: Limited memory → Distributed: Limited bandwidth
   - Embedded: CPU budget → Distributed: Latency budget
   - Embedded: Battery life → Distributed: Cost optimization (cloud $$$)

**You don't need to RELEARN - you need to EXTEND.**

---

### Market Demand Analysis

#### Role Categories & Requirements

| Role Type | C++ Skill | Distributed Systems | Low-Latency | Your Fit (Before) | Your Fit (After DistQueue) |
|-----------|-----------|---------------------|-------------|-------------------|---------------------------|
| **Embedded (Medical/Automotive)** | ✅ Required | ❌ Not needed | ⚠️ Sometimes | ✅ Perfect (13 years) | ✅ Perfect (over-qualified) |
| **C++ Backend (Booking.com, Amazon)** | ✅ Required | ✅ **REQUIRED** | ⚠️ Nice to have | ❌ Missing distributed | ✅ Strong fit |
| **Trading Firms (IMC, Optiver, Flow Traders)** | ✅ Required | ✅ **REQUIRED** | ✅ **REQUIRED** | ❌ Missing both | ⚠️ Good fit (need low-latency deep dive) |
| **Cloud Infrastructure (Databricks, Snowflake)** | ✅ Required | ✅ **REQUIRED** | ❌ Not needed | ❌ Missing distributed | ✅ Strong fit |
| **Databases/Storage (MongoDB, Redis Labs)** | ✅ Required | ✅ **REQUIRED** | ⚠️ Nice to have | ❌ Missing distributed | ✅ Strong fit |

**Key Insight**: Your 200+ applications likely targeted rows 2-5 (backend, trading, cloud, databases) → all require distributed systems.

**Current Gap**: You're qualified for row 1 (embedded) but market demand is rows 2-5.

**DistQueue Impact**: Moves you from "❌ Missing distributed" → "✅ Strong fit" for rows 2, 4, 5.

---

### Differentiation: Why Rare = Valuable

#### Market Segmentation

**Most C++ Candidates Fall Into:**

```
Bucket A: Embedded-Only
├── Skills: C++, embedded systems, device drivers
├── Domains: Medical, automotive, IoT, robotics
├── Strengths: Hardware interaction, real-time, safety
└── Weakness: No distributed systems, no cloud

Bucket B: Backend-Only
├── Skills: C++, web services, databases
├── Domains: Tech companies, SaaS, cloud
├── Strengths: Distributed systems, scalability
└── Weakness: No embedded, no hardware constraints
```

**You (After DistQueue): Bucket A + B = Rare Hybrid**

```
Your Profile:
├── Embedded C++ (13 years)
│   ├── Safety standards (IEC 62304, ISO 26262)
│   ├── Real-time constraints
│   ├── Hardware optimization
│   └── Resource-constrained thinking
│
├── PLUS Distributed Systems (DistQueue)
│   ├── Redis coordination
│   ├── Exactly-once delivery
│   ├── Horizontal scaling
│   └── Prometheus metrics
│
└── = RARE COMBINATION (Top 5% of C++ Engineers)
```

#### Why This Combination is Valuable

**Use Case 1: Low-Latency Trading Systems**
- **Need**: Embedded-level optimization (nanoseconds matter) + Distributed coordination (multiple trading nodes)
- **Why You**: Understand cache-friendly data structures (embedded) AND distributed state management
- **Competition**: Bucket A can't do distributed; Bucket B doesn't think about cache lines

**Use Case 2: Cloud Infrastructure for IoT**
- **Need**: Distributed system at scale (millions of devices) + Embedded device understanding
- **Why You**: Know device constraints (embedded) AND backend scalability patterns
- **Competition**: Bucket A can't scale; Bucket B doesn't understand device limitations

**Use Case 3: Database/Storage Systems**
- **Need**: Low-level optimization (storage engines) + Distributed consistency (replication)
- **Why You**: Performance tuning mindset (embedded) AND distributed coordination patterns
- **Competition**: Bucket A no distributed; Bucket B less optimization depth

**Market Reality**: Companies hiring for these roles see 100 Bucket A resumes, 100 Bucket B resumes, and maybe 5 hybrid profiles like yours.

**Your 200+ applications with low conversion = wrong positioning.** After DistQueue: rare profile that commands attention.

---

### ROI Analysis: Build vs Interview Prep

#### Option A: Continue Applying (Current State)

```
Timeline:
├── Week 1-4: Apply to 50 more positions
├── Interviews: Few (distributed systems questions → fail)
├── Result: Same pattern as Nov-Dec (low conversion)
└── Time to offer: Infinite (can't pass what you don't know)

Problems:
├── Type 2 Interview Failure (lack of skills, not technique)
├── Can't "interview prep" out of experience gap
├── Reading about Redis ≠ Debugging Redis locks at 11pm
└── Desperate loop: Apply → Fail → Apply → Fail → ...
```

**Outcome**: ❌ Frustration, desperation, same results

---

#### Option B: 2 Weeks DistQueue, Then Apply Stronger

```
Timeline:
├── Week 1-2 (Dec 25 - Jan 5): Build DistQueue
│   ├── 40% time: DistQueue implementation (4 hours/day)
│   ├── 40% time: Interview prep (system design) (4 hours/day)
│   └── 20% time: Job applications (2 hours/day)
│
├── Week 3-6 (Jan 6 - Feb 2): Interview with Real Experience
│   ├── Update CV with DistQueue
│   ├── Update LinkedIn with distributed systems keywords
│   ├── Apply to 30 positions (better targeting)
│   ├── Interviews: "I built DistQueue, here's how I handled..."
│   └── Pass distributed systems questions (authenticity)
│
└── Week 7: Offers (Target: Jan 30 - Feb 15)

Investment: 80 hours DistQueue (40% of 2 weeks)
Result: Real distributed systems experience
ROI: 6 weeks to offer < Infinite weeks failing
```

**Outcome**: ✅ Break desperate loop, interview stronger, land offers

---

#### The Math

**Scenario 1: Skip DistQueue**
- Applications: 200 (done) + 100 more (Jan-Feb) = 300 total
- Conversion: 1-2% (same as current, lacking distributed experience)
- Interviews: 3-6 (fail at distributed systems questions)
- Offers: 0-1 (maybe get lucky with embedded-only role)
- Time: 8+ weeks (likely more)

**Scenario 2: Build DistQueue First**
- Applications: 200 (done) + 30 targeted (post-DistQueue)
- Conversion: 5-10% (stronger profile, answer distributed questions)
- Interviews: 10-15 (pass technical rounds)
- Offers: 2-4 (backend, cloud, or trading firms)
- Time: 6-8 weeks total (2 weeks building + 4-6 weeks interviewing)

**Key Insight**: 2 weeks building + 4 weeks interviewing (6 total) < 8+ weeks failing repeatedly

**Hidden Cost of Option A**: Emotional toll of repeated failures, desperation, loss of confidence

**Hidden Benefit of Option B**: Confidence from real experience, authentic interview stories, rare profile differentiation

---

### Decision: BUILD DISTQUEUE (DistQueue = Strategic Investment, Not Procrastination)

**Validation Points:**

1. ✅ **Root Cause Identified**: 200+ apps with low conversion = distributed systems gap (not volume issue)
2. ✅ **Type 2 Failure**: Can't interview-prep out of experience gap (need to BUILD skills)
3. ✅ **Market Demand**: Target roles REQUIRE distributed systems (Booking.com, Amazon, trading)
4. ✅ **Foundation Exists**: Embedded background is perfect base (concurrency, fault tolerance, performance)
5. ✅ **Differentiation**: Embedded + Distributed = rare combination (top 5%)
6. ✅ **ROI Positive**: 6 weeks to offer < infinite weeks failing

**Risk Mitigation:**

- **Exit Strategy**: Stop immediately if interviews come (project is means, not end)
- **Parallel Tracks**: 40% DistQueue, 40% interview prep, 20% job search (not abandoning applications)
- **Time-Boxed**: 2 weeks MAX (Jan 5 hard deadline, stop regardless of completion)
- **Success Metric**: NOT "project finished" but "can confidently discuss distributed systems in interviews"

**Philosophy**: When desperate for job BUT actual skill gaps exist → build skills, then interview with authenticity.

**You're not avoiding job search - you're fixing the reason interviews fail.** That's strategic, not procrastination.

---

## Future Consideration: Large-Scale Project (100K+ LOC) for Bazel Experience

### Client Feedback Analysis

**Client's Concern**: "Stressed too much about my experience in such project [large-scale, 100K+ LOC]"

**What This Signals:**
- Role likely involves large codebase maintenance (existing 100K+ LOC system)
- Build system complexity matters (Bazel, incremental builds, hermetic builds)
- Monorepo experience valued (microservices, polyglot, shared libraries)
- Team scale (10+ engineers contributing simultaneously)

**Your Gap**: Both TelemetryHub and DistQueue are small projects (~5K LOC each).

### Project Idea: Large-Scale C++ Monorepo (Future, Not Now)

**Timing**: AFTER DistQueue + Landing Job (or if need stronger portfolio in 3-6 months)

**Concept**: "MicroTrading" - Simulated trading system monorepo

```
Project Structure (Target: 100K+ LOC):

MicroTrading/
├── services/                    (~60K LOC)
│   ├── market_data_service/    (10K LOC - WebSocket feeds, tick data)
│   ├── order_management/       (15K LOC - Order lifecycle, state machine)
│   ├── risk_engine/           (12K LOC - Position tracking, limits)
│   ├── execution_engine/       (10K LOC - Smart order routing)
│   ├── strategy_engine/        (8K LOC - Trading strategies)
│   └── monitoring/            (5K LOC - Prometheus, dashboards)
│
├── libraries/                   (~25K LOC)
│   ├── core/                   (5K LOC - Common utilities)
│   ├── network/               (6K LOC - Low-latency networking)
│   ├── serialization/         (4K LOC - FIX protocol, protobuf)
│   ├── time/                  (3K LOC - High-resolution timing)
│   └── testing/               (7K LOC - Test fixtures, mocks)
│
├── third_party/                 (Managed dependencies)
│   ├── grpc/
│   ├── protobuf/
│   ├── abseil/
│   └── benchmark/
│
├── tools/                       (~5K LOC)
│   ├── code_generators/
│   ├── build_tools/
│   └── deployment/
│
└── tests/                       (~10K LOC)
    ├── unit/ (GTest, each service)
    ├── integration/ (End-to-end scenarios)
    └── performance/ (Latency benchmarks)

Total: ~100K LOC
Build System: Bazel (hermetic, incremental)
Polyglot: C++ (core), Python (tools), Go (monitoring)
```

**Why This Works for Bazel:**

1. **Monorepo Structure**: Multiple services, shared libraries
2. **Polyglot**: C++ services, Python tools, Go monitoring (Bazel excels here)
3. **Hermetic Builds**: Critical for trading (reproducibility, compliance)
4. **Incremental Builds**: 100K LOC → fast iteration needed
5. **Dependency Management**: third_party/ with Bazel's external workspaces

**Learning Outcomes:**

```
Technical Skills:
├── Bazel build system (BUILD files, workspaces, toolchains)
├── Monorepo management (dependency graphs, circular deps)
├── Microservices architecture (service boundaries, APIs)
├── Low-latency networking (TCP, UDP, multicast)
├── gRPC/Protobuf (cross-service communication)
└── Performance benchmarking (Google Benchmark)

Interview Talking Points:
├── "I built a 100K LOC trading system monorepo using Bazel..."
├── "Bazel's hermetic builds were critical for reproducibility..."
├── "Incremental build times: full build 5 min → incremental 30 sec"
├── "Managed 6 microservices with shared C++ libraries"
└── "Polyglot: C++ for latency-critical, Python for tools"
```

**Timeline Estimate**: 3-6 months (part-time, while employed)

**Strategic Value**:
- Demonstrates large-scale project experience (client's concern)
- Bazel expertise (trading firms, Google, Uber)
- Low-latency systems (trading focus)
- Monorepo patterns (enterprise scale)

### Decision: NOT NOW, but Consider After Landing Job

**Reasoning:**

1. **Priority 1**: DistQueue (distributed systems gap - 2 weeks)
2. **Priority 2**: Land job (Jan-Feb 2026)
3. **Priority 3**: Large-scale Bazel project (if still needed in 3-6 months)

**Why Wait:**

- ✅ DistQueue addresses immediate gap (distributed systems)
- ✅ 2 weeks investment vs 3-6 months for large project
- ✅ Can get job with DistQueue + TelemetryHub
- ✅ Large project better done while employed (no financial pressure)
- ✅ Can tailor to actual job requirements (learn what's needed on job)

**If Client Rejects Due to Scale:**

- Document feedback: "Need large-scale project experience"
- Assess: Is this pattern (rejected for scale) or one-off?
- If pattern (3+ rejections for scale): Consider large project
- If one-off: Continue with DistQueue strategy (distributed > scale)

**Interview Answer for Scale Questions (Today):**

> "I haven't worked on 100K+ LOC monorepos yet, but I understand the challenges - build times, dependency management, team coordination. My projects (TelemetryHub, DistQueue) are smaller in scale (~5K LOC each), but demonstrate production-quality thinking: modular design, testing rigor, CI/CD. I chose smaller projects to go deep on specific skills (distributed systems, fault tolerance) rather than broad on code volume. I'm excited to work on large-scale systems here and contribute to your monorepo. I've researched Bazel and understand why it's valuable for hermetic builds at scale."

---

## Reflection Prompts (For Future Self)

### When Feeling Desperate About Job Search

**Read this section.**

**Questions to Ask:**

1. **Am I failing due to volume or skill gap?**
   - Volume issue: Need to apply more, improve CV, network
   - Skill gap: Need to BUILD skills (like DistQueue), then interview

2. **Can I interview-prep this gap?**
   - Type 1 (technique): Yes → Mock interviews, behavioral prep
   - Type 2 (experience): No → Build projects, gain hands-on experience

3. **What's the root cause of interview failures?**
   - Look for patterns: Always fail at X topic (distributed, low-latency, Bazel)
   - Be honest: Can I authentically discuss X, or am I reciting theory?

4. **What's the ROI of building vs applying?**
   - If skill gap exists: 2-4 weeks building < infinite weeks failing
   - If technique gap: 1-2 weeks mock interviews > building projects

5. **Am I procrastinating or strategizing?**
   - Procrastinating: Building random projects, avoiding applications
   - Strategizing: Building targeted projects for identified gaps, parallel job search

**Validation Checks:**

- ✅ Have I applied to 100+ positions? (Yes → not volume issue)
- ✅ Am I getting interviews but failing? (Yes → skill/technique gap)
- ✅ Is there a consistent failure pattern? (Yes → distributed systems)
- ✅ Can I authentically discuss the gap? (No → need hands-on experience)
- ✅ Is the project time-boxed? (Yes → 2 weeks MAX)
- ✅ Am I maintaining parallel job search? (Yes → 20% time on applications)

**If all checks pass → BUILDING IS THE RIGHT MOVE.**

### When Considering New Projects

**Questions to Ask:**

1. **What skill gap does this address?**
   - Must map to interview failure pattern
   - Example: DistQueue → distributed systems gap

2. **What's the time investment vs value?**
   - DistQueue: 2 weeks → distributed systems experience (HIGH VALUE)
   - Large Bazel project: 3-6 months → scale experience (MEDIUM VALUE, wrong timing)

3. **Is this appropriate for current situation?**
   - Employed: Long projects OK (3-6 months)
   - Job searching: Short projects only (2-4 weeks MAX)

4. **Will this differentiate me?**
   - Embedded + Distributed = rare (Yes)
   - Generic CRUD app = common (No)

5. **Can I authentically discuss this in interviews?**
   - Built it yourself: Yes (real debugging stories)
   - Followed tutorial: No (no depth)

**Decision Matrix:**

| Project | Skill Gap | Time | Value | Timing | Decision |
|---------|-----------|------|-------|--------|----------|
| DistQueue | Distributed systems | 2 weeks | HIGH | NOW | ✅ DO IT |
| Large Bazel monorepo | Scale, Bazel | 3-6 months | MEDIUM | LATER | ⏸️ WAIT |
| AI/ML project | ML skills | 4-8 weeks | LOW | NEVER | ❌ WRONG TRACK |
| Another embedded | Embedded | 2-4 weeks | LOW | NEVER | ❌ ALREADY HAVE |

---

## Key Insights (Memorize These)

### On Skill Gaps vs Interview Prep

> "Type 1 Failure (interview technique) → Mock interviews fix it.  
> Type 2 Failure (actual skill gaps) → Building projects fix it.  
> Know which you have. Act accordingly."

### On Authenticity in Interviews

> "Interviewers detect authenticity.  
> 'I tried X, it failed because Y, I fixed with Z' > Reciting CAP theorem.  
> Real debugging stories > Theoretical knowledge.  
> Build to gain stories, then interview with confidence."

### On Desperate Loops

> "Desperate loop: Apply → Fail → Apply → Fail → Infinite time.  
> Growth loop: Identify gap → Build skills → Interview stronger → Offers.  
> 2 weeks building + 4 weeks interviewing (6 total) < Infinite failing."

### On Distributed Systems Value

> "Your embedded background is PERFECT foundation.  
> Concurrency (threads) → Coordination (processes).  
> Fault tolerance (devices) → Network failures.  
> Optimization (CPU) → Optimization (network RTT).  
> You don't relearn. You extend."

### On Rare Combinations

> "Most candidates: Embedded-only OR Backend-only.  
> You: Embedded + Distributed = Rare (top 5%).  
> Rare = Valuable.  
> Low-latency trading: Need both.  
> Cloud IoT: Need both.  
> Database systems: Need both."

### On Project Scope

> "CMake: 1K-100K LOC projects (90% of C++ world).  
> Bazel: 100K+ LOC monorepos (5% of C++ world, but top firms).  
> Choose tool for project size, not resume padding.  
> DistQueue = 5K LOC → CMake is correct choice.  
> Learn Bazel for interviews (4 hours) OR large project later."

### On Strategic Building

> "Not all projects are equal.  
> Generic CRUD app: Low value (everyone has it).  
> Targeted gap project: High value (addresses failure pattern).  
> DistQueue: Addresses distributed systems gap = Strategic.  
> Random blockchain app: Doesn't address gap = Procrastination."

---

## Action Log (Update as Decisions Made)

### December 25, 2025

**Decision**: Use CMake for DistQueue (not Bazel)
- **Reasoning**: Appropriate tool for 5K LOC, maximize feature development time
- **Action**: Completed Day 1 with CMake (Task system, mock Redis, 16 unit tests)
- **Outcome**: Day 1 complete, 4.5 hours invested, foundation solid

**Decision**: Build DistQueue to address distributed systems gap
- **Reasoning**: 200+ apps with low conversion = distributed systems gap (Type 2 failure)
- **Action**: Starting 2-week DistQueue project (Dec 25 - Jan 5)
- **Timeline**: 40% DistQueue, 40% interview prep, 20% job search
- **Exit Strategy**: Stop if interviews come, Jan 5 hard deadline

**Future Consideration**: Large-scale Bazel project (100K+ LOC)
- **Reasoning**: Client feedback about large project experience
- **Decision**: NOT NOW (after landing job or if pattern emerges)
- **Rationale**: DistQueue higher ROI (2 weeks vs 3-6 months), addresses immediate gap

---

## References & Resources

### Distributed Systems Learning
- Book: "Designing Data-Intensive Applications" by Martin Kleppmann
- Course: educative.io "Grokking the System Design Interview"
- Videos: ByteByteGo YouTube channel
- Practice: Pramp (mock interviews)

### Bazel Learning (When Needed)
- Docs: https://bazel.build/
- Tutorial: "Bazel in 10 minutes" (official)
- Book: "Build Systems à la Carte" (academic, deep)
- Example: Study Abseil-cpp (Google's C++ library with Bazel)

### Low-Latency Systems (Future Deep Dive)
- Blog: Mechanical Sympathy (Martin Thompson)
- Course: "Low-Latency Programming" (skill-up courses)
- Book: "C++ High Performance" by Björn Andrist

---

**Remember**: This document exists because your career strategy thinking is STRONG. You identified distributed systems gap yourself. You asked rational questions about Bazel. You validated the value of distributed systems. Trust your instincts. Build DistQueue. Interview with confidence. Land offers.

**You're not procrastinating. You're fixing the root cause.**

---

*End of Decision Journal - Continue adding entries as career progresses*
