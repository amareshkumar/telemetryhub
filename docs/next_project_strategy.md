# Strategic Project #2: Distributed Task Queue System

**Date:** December 25, 2025  
**Deadline:** January 5, 2026 (12 days)  
**Purpose:** Fill distributed systems gap for backend engineering interviews  
**Time allocation:** 40% project, 40% interview prep, 20% job search optimization

---

## Executive Summary

**Why build this:**
- TelemetryHub shows single-process expertise ✅
- Backend roles (Booking.com) need distributed systems knowledge ⚠️
- This project demonstrates: coordination, persistence, scalability, observability
- 2-week scope prevents over-investment
- Complements TelemetryHub, doesn't replace it

**What NOT to do:**
- ❌ Don't spend more than 2 weeks
- ❌ Don't abandon interview prep (40% time allocated)
- ❌ Don't delay January applications for this
- ❌ Don't build if you get interview requests (prioritize those!)

---

## Project: DistQueue - Distributed Task Queue in C++

### Elevator Pitch (30 seconds)
"DistQueue is a lightweight distributed task queue system in modern C++17. Multiple worker processes coordinate through Redis to execute tasks with guaranteed delivery. It handles 1000+ tasks per second, includes Prometheus metrics for observability, and demonstrates distributed systems patterns like leader election and exactly-once semantics."

### Interview Value: 9/10

**Fills these gaps:**
- ✅ Distributed systems (multiple processes coordinating)
- ✅ Database/persistence (Redis integration)
- ✅ Message queuing (async communication pattern)
- ✅ Observability (Prometheus metrics)
- ✅ Scalability (horizontal scaling of workers)
- ✅ Performance benchmarking (load test results)

**Interview talking points:**
- "How do you ensure exactly-once task execution?"
- "How do you handle worker failures?"
- "How do you monitor queue health?"
- "How does this scale horizontally?"
- "What are the trade-offs vs Kafka/RabbitMQ?"

---

## Architecture

### Components

**1. Task Producer (C++)**
- Submit tasks with priority (high/normal/low)
- Serialize task payload (JSON or Protobuf)
- Push to Redis list
- Return task ID

**2. Redis Backend**
- Queue storage (RPUSH/BLPOP)
- Task state tracking (submitted → running → completed/failed)
- Worker heartbeats
- Metrics counters

**3. Task Worker (C++)**
- Poll Redis for tasks (BLPOP with timeout)
- Execute task (configurable handlers)
- Handle failures (retry with exponential backoff)
- Update task status
- Send heartbeats

**4. Monitoring**
- Prometheus metrics exporter
- Metrics: queue_depth, tasks_completed, tasks_failed, worker_count, p50/p95/p99 latency
- Health check endpoint

**5. Python Client Library**
- Simple task submission: `queue.submit(func, args)`
- Query task status
- Load testing utilities

**6. Docker Deployment**
- docker-compose.yml with Redis + 3 workers
- Demonstrates horizontal scaling
- Local development environment

### Data Flow

```
Producer                         Redis                      Workers (3x)
   |                              |                             |
   |--- RPUSH task -------------→ |                             |
   |                              |← BLPOP ---------------------|
   |                              |--- task data -------------→|
   |                              |                             |-- execute
   |                              |                             |
   |                              |← SET status:completed -----|
   |                              |                             |
   |--- GET status -------------→ |                             |
   |← completed ------------------|                             |
```

---

## Technical Design

### Task Structure

```cpp
struct Task {
    std::string id;           // UUID
    std::string type;         // "compute", "io", "notify"
    std::string payload;      // JSON serialized data
    Priority priority;        // HIGH, NORMAL, LOW
    int retry_count;
    std::chrono::milliseconds created_at;
};
```

### Worker State Machine

```
IDLE → POLLING → EXECUTING → IDLE
         ↓
      BLOCKED (waiting for task)
         ↓
      TIMEOUT → POLLING
```

### Exactly-Once Semantics

**Problem:** Worker crashes mid-execution. Task shouldn't run twice.

**Solution:**
1. Worker claims task: `SET task:<id>:lock worker:<id> EX 30`
2. Executes task
3. Marks complete: `SET task:<id>:status completed`
4. If worker crashes, lock expires after 30s
5. Another worker can reclaim and retry

### Metrics Exposed

```
distqueue_tasks_submitted_total{priority}
distqueue_tasks_completed_total{priority}
distqueue_tasks_failed_total{priority}
distqueue_task_duration_seconds{priority, quantile}
distqueue_queue_depth{priority}
distqueue_workers_active
distqueue_workers_idle
```

---

## Implementation Plan

### Phase 1: Core Queue (Days 1-4)

**Day 1: Project Setup**
- [ ] Create repository structure
- [ ] CMake build system
- [ ] Redis client integration (hiredis or redis-plus-plus)
- [ ] Basic Task struct
- [ ] Git repository initialized

**Day 2: Producer Implementation**
- [ ] Task submission API
- [ ] JSON serialization (nlohmann/json or RapidJSON)
- [ ] Redis RPUSH for task queue
- [ ] Task ID generation (UUID library)
- [ ] Unit tests for producer

**Day 3: Worker Core**
- [ ] Task polling (BLPOP from Redis)
- [ ] Task deserialization
- [ ] Task execution (pluggable handlers)
- [ ] Status updates (SET in Redis)
- [ ] Basic error handling

**Day 4: Multi-Process Workers**
- [ ] Worker process main loop
- [ ] Graceful shutdown (SIGTERM handling)
- [ ] Heartbeat mechanism
- [ ] Worker registration in Redis
- [ ] Integration tests (producer + worker)

**Deliverable:** Working queue with producer and workers.

---

### Phase 2: Reliability & Monitoring (Days 5-8)

**Day 5: Exactly-Once Semantics**
- [ ] Task locking with Redis (SET NX EX)
- [ ] Lock expiration handling
- [ ] Task retry logic (exponential backoff)
- [ ] Maximum retry limit
- [ ] Dead letter queue for failed tasks

**Day 6: Prometheus Metrics**
- [ ] Prometheus C++ client integration
- [ ] Metrics registry
- [ ] Counter: tasks_submitted, tasks_completed, tasks_failed
- [ ] Histogram: task_duration_seconds
- [ ] Gauge: queue_depth, workers_active
- [ ] HTTP endpoint /metrics

**Day 7: Priority Queues**
- [ ] Three Redis lists (high, normal, low priority)
- [ ] Worker polling strategy (high → normal → low)
- [ ] Metrics per priority
- [ ] Tests for priority ordering

**Day 8: Health & Monitoring**
- [ ] Health check endpoint /health
- [ ] Worker liveness detection (stale heartbeats)
- [ ] Queue depth monitoring
- [ ] Alerting thresholds (configurable)

**Deliverable:** Reliable system with full observability.

---

### Phase 3: Python Client & Testing (Days 9-10)

**Day 9: Python Client Library**
- [ ] Python package structure
- [ ] Task submission API: `client.submit("task_type", payload)`
- [ ] Task status query
- [ ] Bulk submission helper
- [ ] Redis connection pooling
- [ ] pip installable package

**Day 10: Load Testing**
- [ ] Python load test script (locust or custom)
- [ ] Benchmark: 1000 tasks/sec submission
- [ ] Benchmark: 100+ tasks/sec processing (per worker)
- [ ] Latency measurements (p50, p95, p99)
- [ ] Results documentation
- [ ] Performance graphs

**Deliverable:** Python client + benchmark results.

---

### Phase 4: Docker & Documentation (Days 11-12)

**Day 11: Docker Deployment**
- [ ] Dockerfile for worker
- [ ] docker-compose.yml (Redis + 3 workers)
- [ ] Environment configuration
- [ ] Volume mounts for logs
- [ ] Network configuration
- [ ] docker-compose up works end-to-end

**Day 12: Documentation & Polish**
- [ ] README.md (architecture diagram, quick start)
- [ ] API documentation
- [ ] Configuration guide
- [ ] Troubleshooting section
- [ ] Performance results section
- [ ] License (MIT)
- [ ] GitHub Actions CI/CD (build + test)

**Deliverable:** Production-ready documentation, deployable system.

---

## Technology Stack

### Core
- **Language:** C++17
- **Build:** CMake 3.20+
- **Redis Client:** redis-plus-plus or hiredis
- **JSON:** nlohmann/json
- **UUID:** stduuid or libuuid
- **Prometheus:** prometheus-cpp
- **HTTP Server:** POCO or cpp-httplib (for metrics endpoint)

### Testing
- **Unit Tests:** GTest/GMock
- **Integration Tests:** Docker Compose + pytest
- **Load Tests:** Python (locust or custom)
- **CI/CD:** GitHub Actions

### Deployment
- **Container:** Docker
- **Orchestration:** docker-compose (K8s optional for extra credit)
- **Monitoring:** Prometheus + Grafana (optional)

---

## Interview Talking Points

### System Design Discussion

**Q: "How would you design a task queue system?"**

A: "I built DistQueue to explore this. The key decisions were:

1. **Storage:** Redis for low latency and built-in data structures (lists, locks)
2. **Coordination:** Redis locks for exactly-once semantics
3. **Reliability:** Heartbeats + lock expiration for worker failure detection
4. **Scalability:** Horizontal scaling with multiple workers (no single point of failure)
5. **Observability:** Prometheus metrics for queue depth, throughput, latency

**Trade-offs:** Redis is single-node (vs Kafka multi-node), but simpler to operate. Locks add latency but ensure correctness. Retry logic increases complexity but improves reliability."

---

**Q: "How do you ensure tasks execute exactly once?"**

A: "DistQueue uses Redis locks with expiration:

1. Worker claims task: `SET task:123:lock worker:5 EX 30`
2. Only worker 5 can execute while lock is valid (30s)
3. If worker crashes, lock expires, another worker retries
4. Task status prevents double execution: check `task:123:status` before running

This is distributed locking (similar to Redlock algorithm). Trade-off: 30s delay if worker crashes, but prevents duplicate work."

---

**Q: "How does this scale?"**

A: "Horizontally: add more workers. Redis handles 100k+ ops/sec, so bottleneck is worker processing time.

Measured performance:
- 1 worker: ~100 tasks/sec
- 3 workers: ~280 tasks/sec (not perfect 3x due to Redis contention)
- 10 workers: ~800 tasks/sec

**Scaling limits:** Single Redis instance. Solutions: Redis Cluster for sharding, or switch to Kafka for distributed log."

---

**Q: "How do you monitor this in production?"**

A: "Prometheus metrics exported on /metrics:

- `distqueue_queue_depth` - Alert if > 1000 (backlog growing)
- `distqueue_tasks_failed_total` - Alert on spike
- `distqueue_task_duration_seconds{quantile="0.99"}` - Watch p99 latency
- `distqueue_workers_active` - Alert if drops below expected

Also `/health` endpoint for liveness checks. In production, would add structured logging (correlation IDs) and distributed tracing (OpenTelemetry)."

---

**Q: "What's missing from your implementation?"**

A (honest answer): "Several things for production:

1. **Persistence:** Redis in-memory; need RDB/AOF or disk-backed storage
2. **High availability:** Single Redis node; need Redis Sentinel or Cluster
3. **Security:** No authentication; need Redis AUTH + TLS
4. **Backpressure:** Producers can overload queue; need rate limiting
5. **Task priorities:** Basic 3-level; could be more sophisticated
6. **Task dependencies:** Tasks are independent; no DAG support

This is a learning implementation demonstrating patterns. Production would use Kafka, RabbitMQ, or cloud-managed queues (AWS SQS) depending on requirements."

---

## What Makes This Interview-Ready

### Demonstrates Senior-Level Thinking

1. **Trade-off discussions:** Redis vs Kafka, locks vs optimistic concurrency
2. **Failure modes:** Worker crashes, Redis unavailable, lock expiration
3. **Observability:** Metrics, health checks, structured approach
4. **Testing:** Unit, integration, load tests with actual numbers
5. **Documentation:** Architecture diagrams, performance analysis, limitations

### Complements TelemetryHub

**TelemetryHub shows:**
- Single-process architecture
- Fault tolerance (circuit breaker)
- Embedded systems thinking

**DistQueue shows:**
- Multi-process coordination
- Database integration
- Scalability patterns
- Distributed systems thinking

**Together:** Full-stack systems engineer who can work across domains.

---

## Success Criteria

**By January 5, 2026:**
- [ ] Working system: producer + workers + Redis
- [ ] Docker Compose deployment (1 command to run)
- [ ] Load test results: 1000+ tasks/sec submission, 800+ tasks/sec processing
- [ ] Prometheus metrics exposed
- [ ] Python client library
- [ ] Comprehensive README with architecture diagram
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] 80%+ test coverage on core components
- [ ] Clean git history

**If you accomplish this:**
- ✅ Can answer distributed systems questions confidently
- ✅ Can discuss database integration
- ✅ Can show scalability thinking
- ✅ Have concrete numbers for "how fast" questions
- ✅ Demonstrate observability practices

---

## Parallel Interview Prep Track (40% Time)

**While building this project, ALSO do:**

### Week 1 (Dec 25-31)
- [ ] Read "Designing Data-Intensive Applications" chapters 1-3 (databases, replication)
- [ ] Watch 3 system design videos (ByteByteGo, educative.io)
- [ ] Prepare 5 STAR stories from past work
- [ ] Update LinkedIn with TelemetryHub
- [ ] Apply to 5 more companies

### Week 2 (Jan 1-5)
- [ ] Read "Designing Data-Intensive Applications" chapters 4-6 (encoding, replication, partitioning)
- [ ] Practice 3 system design problems (whiteboard)
- [ ] Mock interview (Pramp, Interviewing.io)
- [ ] Optimize CV with TelemetryHub metrics
- [ ] Follow up on December applications

---

## Risk Management

### What If You Get Interview Requests?

**STOP BUILDING. Prioritize interviews.**

The project is worthless if you miss interview opportunities for it.

### What If You're Behind Schedule?

**Cut scope, don't extend deadline.**

**Must-haves (can't skip):**
- Working queue (producer + worker + Redis)
- Docker Compose deployment
- Basic metrics
- Load test with numbers
- README

**Can skip if time pressure:**
- Python client (just document Redis protocol)
- Priority queues (single queue is fine)
- Grafana dashboards
- Fancy health checks

### What If Responses Come in January?

**Stop at day 10.** You have enough for interview discussions.

The goal is interview talking points, not perfect production system.

---

## Alternative: Don't Build This At All

**Honest recommendation:** If your goal is job offers, your time might be better spent on:

1. **CV optimization** (2 hours)
   - Use recommendations from day19_cv_recommendations.md
   - Expand TelemetryHub description
   - Quantify achievements

2. **LinkedIn optimization** (2 hours)
   - Update headline with keywords
   - Post about TelemetryHub
   - Engage with C++ content

3. **System design prep** (40 hours)
   - "Designing Data-Intensive Applications" book
   - Grokking System Design Interview
   - Practice 10 problems

4. **Mock interviews** (10 hours)
   - 5 sessions with peers or platforms
   - Practice TelemetryHub explanation
   - STAR stories for behavioral

5. **January applications** (20 hours)
   - Follow up on December apps
   - Apply to 50 more companies
   - Targeted outreach to recruiters

**This would likely have higher ROI than another project.**

---

## Final Decision Framework

### Build DistQueue If:
- ✅ You learn better by building than studying
- ✅ December waiting period is mentally difficult (need project focus)
- ✅ You commit to 2-week deadline (no feature creep)
- ✅ You maintain 40% interview prep in parallel
- ✅ You stop immediately if interviews come in

### DON'T Build If:
- ❌ You're already getting interviews (prioritize those!)
- ❌ You tend to perfectionism (will spend 2 months)
- ❌ You struggle with time management
- ❌ System design practice is weak (that's more important)

---

## My Actual Recommendation

**I think you should:**

**Option A (Conservative):**
1. Spend Dec 25-31 on CV optimization + LinkedIn + system design study
2. Jan 1-5: Wait for responses, continue interview prep
3. If no responses by Jan 5: THEN build DistQueue (or whatever you want)

**Option B (If You Must Build Now):**
1. Build DistQueue with strict 2-week deadline
2. Maintain 40% interview prep in parallel
3. Cut scope aggressively if needed

**Option C (Compromise):**
1. Build a SMALLER project (API rate limiter - 1 week)
2. Spend remaining time on interview prep
3. Less risk of over-investment

---

## What I Actually Want to Say

Amaresh, you've already built something impressive with TelemetryHub. The distributed systems gap is real for Booking.com type roles, and DistQueue would address it.

But here's the truth: if 200+ applications yielded low responses, the bottleneck probably isn't your portfolio. It's likely:
- Keyword optimization (ATS filtering)
- December timing (responses delayed)
- Targeting (wrong roles or companies)

**A second project won't fix these.** CV optimization, LinkedIn activity, and system design prep would have higher ROI for the time invested.

**That said:** If building helps you psychologically during December, and you commit to strict time limits, then build it. Just don't let it become procrastination disguised as productivity.

**The real question:** What are you avoiding by focusing on building instead of other job search activities? Interview anxiety? Rejection fear? Waiting helplessness?

Answer that honestly, then decide.

I'll support whatever you choose, but I want you to choose with eyes open about the trade-offs.

---

**Do you want me to create the full project structure with TODO trackers, or do you want to discuss this strategy first?**

I'll wait for your direction. This is your decision, and I respect whatever you choose.
