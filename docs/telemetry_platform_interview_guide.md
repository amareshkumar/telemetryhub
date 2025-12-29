# Interview Preparation Guide - Telemetry Platform

**Project:** Telemetry Platform (Monorepo)  
**Author:** Amaresh Kumar (amaresh.kumar@live.in)  
**Location:** Eindhoven, Netherlands  
**Portfolio Project:** Production-ready C++ telemetry system

---

## 🎯 Core Interview Talking Points

### 1. **End-to-End Systems Design**
**What to say:** "I built an integrated telemetry platform that demonstrates complete systems thinking - from sensor data collection at 9.1M ops/sec, through Redis coordination, to async processing at 10K tasks/sec, with Prometheus monitoring and Grafana visualization."

**Follow-up points:**
- Designed for loose coupling - services can scale independently
- Redis as message broker enables decoupling (producer-consumer pattern)
- Each service has its own deployment unit (Docker container)

### 2. **Microservices Architecture**
**What to say:** "The platform consists of two independent microservices - an ingestion service handling sensor data and a processing service with async workers - both sharing a common library to eliminate code duplication."

**Follow-up points:**
- Monorepo with independent projects (can build separately)
- Shared library approach vs microservices code duplication debate
- Benefits: Atomic commits across services, shared utilities, single CI/CD pipeline

### 3. **Performance Engineering**
**What to say:** "I achieved 9.1M ops/sec on the ingestion queue through careful lock-free design, and maintained <50ms p99 latency on task processing through connection pooling and Redis pipelining."

**Follow-up points:**
- Profiled with perf/VTune to find bottlenecks
- Lock-free bounded queue for ingestion (thread-safe without mutexes)
- Redis connection pooling (5 connections default) reduces latency
- Benchmarked with 100K task load tests

### 4. **Code Organization (Monorepo)**
**What to say:** "I migrated two separate projects into a monorepo structure while maintaining independent build capabilities - you can build just ingestion, just processing, or both together."

**Follow-up points:**
- CMake options: BUILD_INGESTION, BUILD_PROCESSING, BUILD_COMMON
- Shared library in common/ eliminates duplication (JSON, config, UUID)
- Migration required fixing CMAKE_SOURCE_DIR → CMAKE_CURRENT_SOURCE_DIR
- Documented entire migration process for portfolio demonstration

### 5. **Modern C++ Mastery**
**What to say:** "The codebase demonstrates C++17/20 features - RAII for resource management, move semantics for zero-copy, std::optional for nullable returns, and structured bindings for clean code."

**Follow-up points:**
- RAII: Redis client with PIMPL pattern (automatic cleanup)
- Move semantics: Task objects moved, not copied (zero overhead)
- std::optional: Nullable returns without exceptions
- Concurrency: std::thread pool, std::mutex, std::condition_variable

### 6. **Production Readiness**
**What to say:** "The platform is production-ready with Docker Compose deployment, Prometheus metrics collection, comprehensive unit and integration tests, and full CI/CD pipeline."

**Follow-up points:**
- Docker Compose for local development + production deployment
- Prometheus metrics: task throughput, latency, success rate
- Testing pyramid: Unit tests (80% coverage), integration tests, load tests
- CMake + CTest for automated testing

### 7. **Observability & Monitoring**
**What to say:** "I implemented structured logging, Prometheus metrics, and Grafana dashboards to provide full observability - you can track throughput, latency, and error rates in real-time."

**Follow-up points:**
- Structured logging (JSON format) for easy parsing
- Metrics: counters (tasks processed), histograms (latency), gauges (queue size)
- Grafana dashboards showing real-time system health
- Alerting on anomalies (queue backup, high latency)

---

## 🎤 Demo Script (30 seconds)

**If asked "Can you show me the project?"**

1. **Start services:** `docker-compose up` (show Redis + services starting)
2. **Producer:** Run task producer to enqueue 10,000 tasks
3. **Metrics:** Show real-time metrics (tasks/sec, success rate)
4. **Graceful shutdown:** Ctrl+C, show no task loss (Redis persistence)
5. **Restart:** Show tasks still in queue after restart (durability)

**Key message:** "This demonstrates production-ready practices - graceful shutdown, task durability, and observability."

---

## 💡 Technical Deep-Dive Questions & Answers

### Q1: "How does your task queue handle failures?"

**Answer:**
"Three-layer approach:
1. **Redis persistence**: AOF (Append-Only File) ensures tasks survive Redis restart
2. **Worker retries**: Exponential backoff (1s, 2s, 4s, 8s) for transient failures
3. **Dead letter queue**: After 5 retries, task moves to DLQ for manual inspection

Monitored via Prometheus metrics: failure rate, retry count, DLQ size."

**Follow-up if asked about at-least-once delivery:**
"I use RPOPLPUSH pattern - atomically move task from pending queue to in-flight queue. On success, remove from in-flight. On failure/timeout, re-queue from in-flight. Task handlers are idempotent to handle duplicates."

---

### Q2: "Why Redis over Kafka or RabbitMQ?"

**Answer:**
"For this use case, Redis offers:
- **Simplicity**: In-memory, single-node, easy to operate
- **Latency**: Sub-millisecond operations vs Kafka's multi-ms
- **Sufficient throughput**: 100K ops/sec meets my 10K tasks/sec requirement
- **Feature set**: Lists for FIFO, sorted sets for priority, sets for deduplication

Kafka adds complexity (ZooKeeper, partitions, consumer groups) needed only for multi-TB scale or multi-datacenter deployments. If requirements grow to 100K+ tasks/sec across multiple regions, I'd re-evaluate."

**Trade-offs acknowledged:**
- Redis: Single point of failure (mitigated with Redis Sentinel)
- Kafka: Better for massive scale, complex consumer patterns
- RabbitMQ: Better for advanced routing, but more operational overhead

---

### Q3: "How would you scale this to 100K tasks/sec?"

**Answer:**
"Three approaches in order:

1. **Vertical scaling (easiest):**
   - Redis pipelining: Batch 100 LPUSH operations into one round-trip
   - Connection pooling: Increase pool size to 20-50 connections
   - Worker threads: Scale from 4 to 16+ workers per instance
   - Expected: 3-5x throughput improvement

2. **Horizontal scaling (moderate):**
   - Multiple Redis instances with consistent hashing (hash on task ID)
   - Multiple worker instances (Kubernetes replicas)
   - Load balancer for Redis connections
   - Expected: 10x throughput improvement

3. **Architectural change (complex):**
   - Event-driven async I/O (libuv or ASIO) instead of thread pool
   - Non-blocking Redis client (avoid thread-per-connection)
   - Redis Cluster for partitioning (16,384 hash slots)
   - Expected: 20-50x throughput improvement

**Decision process:** Profile first to find bottleneck. If Redis is saturated, go with #2. If workers are CPU-bound, go with #3."

---

### Q4: "Walk me through your testing strategy."

**Answer:**
"Testing pyramid approach:

**Unit Tests (80% coverage):**
- TaskQueue: push, pop, priority ordering
- Worker: task execution, error handling, shutdown
- Redis client: all CRUD operations (mocked Redis)
- Ran with GoogleTest framework

**Integration Tests (real Redis):**
- Full flow: Producer → Redis → Worker → Result
- Error scenarios: Redis disconnect, malformed tasks, timeouts
- Ran with Redis test container (Docker)

**Load Tests (performance):**
- 100K tasks, measure throughput and latency (p50, p99)
- Chaos testing: Kill Redis mid-test, verify recovery
- Ran with custom benchmarking tool

**Memory Tests:**
- Valgrind for leak detection
- Address Sanitizer for buffer overflows
- All tests clean

**CI/CD:** Automated in GitHub Actions (unit + integration tests on every commit)."

---

### Q5: "How do you ensure at-least-once delivery?"

**Answer:**
"RPOPLPUSH pattern:

1. **Atomic move:** Worker does `RPOPLPUSH pending_queue in_flight_queue`
   - Atomically pops from pending, pushes to in-flight
   - Task now visible in in-flight queue (for monitoring)

2. **Process task:** Worker executes task handler

3. **On success:** Worker does `LREM in_flight_queue task_id`
   - Task removed, delivery confirmed

4. **On failure:** Worker re-queues: `LPUSH pending_queue task_id`
   - Task goes back to pending for retry

5. **On crash:** Separate monitor process checks in-flight queue
   - Tasks older than timeout (e.g., 5 minutes) re-queued to pending
   - Handles worker crashes gracefully

**Idempotency:** Task handlers designed to be idempotent (safe to execute multiple times). Example: `INSERT ... ON CONFLICT DO NOTHING` in SQL."

---

### Q6: "Why monorepo instead of separate repos?"

**Answer:**
"Monorepo benefits for this project:

**Pros:**
- ✅ **Atomic commits:** Change API in common library + update both services in one commit
- ✅ **Shared code:** Eliminate duplication (JSON utils, config parsing, UUID generation)
- ✅ **Single CI/CD:** One pipeline builds everything, runs all tests
- ✅ **Easy refactoring:** Rename function in common/, update all call sites atomically
- ✅ **Portfolio presentation:** One repo showing integrated system (vs two 5K LOC repos)

**Cons:**
- ❌ Larger clone size (mitigated with shallow clone)
- ❌ All developers see all code (not an issue for small team)

**Independent builds preserved:**
- Can build just ingestion: `cmake -DBUILD_PROCESSING=OFF`
- Can build just processing: `cmake -DBUILD_INGESTION=OFF`
- Services deploy independently (separate Docker containers)

**Polyrepo alternative:** Would need subtree/submodule for shared library, more complex CI/CD, harder to keep services in sync."

---

### Q7: "Describe your Redis client design decisions."

**Answer:**
"Key design choices in `common/redis_client`:

1. **Library selection:** redis-plus-plus over hiredis
   - Modern C++ API with RAII (automatic connection cleanup)
   - Exception-safe (RAII handles errors gracefully)
   - Connection pooling built-in
   - std::optional for nullable returns (vs error codes)

2. **PIMPL pattern:** Hide redis-plus-plus in .cpp file
   - Header only includes forward declarations
   - Reduces compile-time dependencies
   - Easy to swap implementation later

3. **Connection pooling:** Configurable pool size (default 5)
   - Reduces connection overhead
   - Thread-safe access from worker pool
   - Automatic connection recycling

4. **Error handling:** Non-throwing public API
   - All operations return bool or std::optional
   - Exceptions caught internally
   - Simplifies caller code (no try-catch everywhere)

5. **Interface design:** Operations match Redis semantics
   - `lpush()`, `rpop()` for FIFO queue (intuitive naming)
   - `zadd()`, `zpopmax()` for priority queue
   - `sadd()`, `sismember()` for deduplication

**Trade-offs:**
- Non-throwing API hides errors (mitigated with logging)
- Connection pool has memory overhead (5 connections × socket buffer)
- PIMPL adds indirection cost (negligible for network I/O)"

---

## 📊 Performance Numbers to Memorize

| Metric | Value | Context |
|--------|-------|---------|
| **Ingestion throughput** | 9.1M ops/sec | Bounded queue, Release build |
| **Processing throughput** | 10K tasks/sec | 4 worker threads, Redis backend |
| **p99 latency** | <50ms | Task execution time |
| **Redis throughput** | 100K ops/sec | Single instance, pipelined |
| **Build time** | ~70s | Full platform (CMake + compile) |
| **Test time** | ~3s | Core tests (unit + integration) |
| **LOC** | 10,000+ | Unified platform |
| **Test coverage** | 80%+ | Unit tests |

---

## 🏗️ Architecture Decisions to Defend

### Decision 1: Redis for Message Broker
**Why Redis?**
- In-memory speed (<1ms latency)
- Simple data structures (lists, sets, sorted sets)
- Built-in persistence (AOF, RDB)
- Proven reliability (used by Twitter, GitHub)

**Why not Kafka?**
- Overkill for 10K tasks/sec (Kafka designed for millions)
- Operational complexity (ZooKeeper, partitions)
- Higher latency (disk-based, batching)

**Why not RabbitMQ?**
- More complex routing than needed
- Higher operational overhead (Erlang VM)
- Redis lists provide similar semantics

---

### Decision 2: Thread Pool for Workers
**Why thread pool?**
- Predictable resource usage (fixed # threads)
- Easy to reason about concurrency
- Blocking Redis client fits naturally
- CPU-bound tasks benefit from threads

**Why not async I/O (libuv, ASIO)?**
- Redis operations are network-bound (blocking OK)
- Task handlers may be CPU-bound (threads better)
- Async adds complexity (callback hell, state machines)
- Thread pool is simpler to debug

**Trade-offs:**
- Thread pool: Context switching overhead, memory per thread
- Async I/O: Better for I/O-bound, scales to thousands of connections

---

### Decision 3: JSON for Task Serialization
**Why JSON?**
- Human-readable (easy debugging)
- Schema flexibility (add fields without breaking)
- Widely supported (every language has JSON library)
- Tooling support (jq, browser devtools)

**Why not binary (Protocol Buffers, MessagePack)?**
- JSON: 2-3x larger, but negligible for 10K tasks/sec
- Binary: Requires schema file, harder to debug
- JSON: 100MB/sec bandwidth easily available

**Trade-offs:**
- JSON: Slower serialization, larger size
- Binary: Faster, smaller, but needs schema versioning

---

### Decision 4: C++17 vs C++20
**Why C++17?**
- Widespread compiler support (GCC 7+, Clang 5+, MSVC 2017+)
- Sufficient features: std::optional, structured bindings, fold expressions
- Most production environments support C++17

**C++20 features used where available:**
- Concepts for template constraints (if compiler supports)
- Modules for faster compilation (experimental)

**Trade-offs:**
- C++17: Mature, stable, widely deployed
- C++20: Newer features (coroutines, ranges) but less compiler support

---

### Decision 5: Static Library for Common
**Why static library?**
- No runtime dependency (.so file not needed)
- Easier deployment (single binary)
- Compiler can optimize across library boundaries (LTO)

**Why not dynamic library?**
- Static: Larger binary size (acceptable for this project)
- Dynamic: Shared across processes (not needed here)
- Static: No versioning conflicts

**Trade-offs:**
- Static: Larger binaries, rebuild if library changes
- Dynamic: Smaller binaries, runtime dependency, versioning complexity

---

## 🎯 Key Achievements (Quantified)

1. **Built integrated telemetry platform** - 10,000+ LOC, two microservices + shared library
2. **Achieved 9.1M ops/sec ingestion** - Lock-free bounded queue, Release build
3. **Achieved 10K tasks/sec processing** - Redis-backed async workers, <50ms p99 latency
4. **Designed decoupled architecture** - Services scale independently, loosely coupled via Redis
5. **Implemented shared library** - Eliminated code duplication, 300+ lines of shared utilities
6. **Created production deployment** - Docker Compose with Redis, Prometheus, Grafana
7. **Completed monorepo migration** - Two separate repos → unified platform, documented process
8. **Comprehensive testing** - 80% unit test coverage, integration tests, load tests

---

## 🚀 Portfolio Impact

**Before:**
- Two separate 5K LOC projects (TelemetryHub, TelemetryTaskProcessor)
- Duplicated code (JSON parsing, config, UUID generation)
- Hard to demonstrate integration story

**After:**
- One unified 10K+ LOC platform
- Shared library eliminates duplication
- Clear integration narrative: Sensor → Ingestion → Redis → Processing → Storage
- Demonstrates senior-level architecture thinking

**Presentation advantage:**
- "I built an integrated telemetry platform..." (sounds bigger)
- Shows systems thinking (end-to-end design)
- Demonstrates monorepo migration skill (relevant for companies using monorepos)

---

## 📝 Code Review Talking Points

**If interviewer asks to review code:**

1. **Show common/redis_client.h:**
   - "This demonstrates RAII design - PIMPL pattern hides implementation"
   - "std::optional for nullable returns - no error codes or exceptions"
   - "Connection pooling for production scalability"

2. **Show processing/src/core/TaskQueue.cpp:**
   - "Thread-safe queue using Redis lists - LPUSH/RPOP for FIFO"
   - "BRPOP for blocking pop - more efficient than polling"
   - "Task serialization with JSON - human-readable, debuggable"

3. **Show ingestion/device/:**
   - "Hardware abstraction layer - supports UART, I2C, SPI"
   - "Lock-free bounded queue for high throughput"
   - "Device simulator for testing without hardware"

4. **Show tests/:**
   - "GoogleTest for unit tests - 80% coverage"
   - "Integration tests with real Redis container"
   - "Load tests measuring throughput and latency"

---

## 🎓 Follow-up Reading

**If you need to brush up:**

1. **Redis:**
   - https://redis.io/docs/data-types/ (lists, sets, sorted sets)
   - https://redis.io/docs/manual/patterns/distributed-locks/ (RPOPLPUSH pattern)

2. **C++:**
   - https://en.cppreference.com/w/cpp/utility/optional (std::optional)
   - https://en.cppreference.com/w/cpp/thread/thread (std::thread)

3. **Prometheus:**
   - https://prometheus.io/docs/concepts/metric_types/ (counter, histogram, gauge)

4. **Docker:**
   - https://docs.docker.com/compose/ (Docker Compose)

---

## 📞 Contact

**Amaresh Kumar**  
Email: amaresh.kumar@live.in  
Phone: +31 645 302 309  
Location: Eindhoven, Netherlands  
LinkedIn: linkedin.com/in/amareshkumar  
GitHub: github.com/amareshkumar

---

**Good luck with your interviews! You've built something impressive - own it with confidence! 🚀**
