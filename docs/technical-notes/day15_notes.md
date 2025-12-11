# Day 15 – Configuration System & Logging Improvements

## What We Built

### Configuration System
- Simple INI-style config file loader supporting:
  - `sampling_interval_ms`: Controls how fast the gateway polls the device
  - `queue_size`: Sets bounded capacity for the telemetry queue (0 = unbounded)
  - `log_level`: Runtime log verbosity (error, warn, info, debug, trace)
- Added `--config <file>` CLI argument to `gateway_app`

### Bounded Queue Implementation
- Enhanced `TelemetryQueue` with optional capacity limit
- Drop-oldest strategy when queue is full (maintains most recent data)
- Thread-safe with proper mutex protection
- Runtime adjustable via `set_capacity()`

### Logging Improvements
- Already had timestamps and severity levels
- Now respects config-driven log level in addition to CLI `--log-level`
- Consistent format: `YYYY-MM-DD HH:MM:SS [LEVEL] (category) message`

---

## Interview Focus Points for Senior Engineers

### 1. Configuration Management & Externalized Settings

**Key Concepts:**
- **Separation of Configuration from Code**: The 12-Factor App principle. Config should be external to allow deployment-time changes without recompilation.
- **Runtime vs Compile-Time Configuration**: Discuss trade-offs. Runtime config (files, env vars) provides flexibility; compile-time config (templates, constexpr) provides performance.

**Discussion Points:**
- Why did we choose a simple INI-style format vs JSON/YAML/TOML?
  - **Simplicity**: No external dependencies, easy to parse
  - **Human-readable**: Operators can edit config files without special tools
  - **Trade-off**: Limited nesting and data types
  
- **Config validation and defaults**: 
  - Our loader preserves existing values if keys are missing (partial override pattern)
  - Consider: Should we validate ranges? (e.g., `sampling_interval_ms > 0`)
  - Production systems need schema validation and error reporting

- **Config reload without restart**: 
  - Current implementation: config loaded at startup only
  - Enhancement: watch config file for changes, reload on SIGHUP
  - Challenge: thread-safe config updates, consistency guarantees

**Code to Discuss:**
```cpp
// Config.cpp: trim(), parse_level(), case-insensitive key matching
// Design choice: fail-safe (returns true even if file is empty)
bool load_config(const std::string& path, AppConfig& out);
```

**Senior-Level Questions to Expect:**
- "How would you handle configuration in a distributed system with multiple gateway instances?"
  - Answer: Centralized config service (etcd, Consul), version control, rollout strategies
- "How do you test configuration changes in production safely?"
  - Answer: Blue-green deployments, canary releases, feature flags
- "What's your strategy for secrets management (API keys, passwords)?"
  - Answer: Never in plain config files. Use secret managers (Vault, AWS Secrets Manager), encrypted at rest

---

### 2. Bounded Queue Design & Backpressure Handling

**Key Concepts:**
- **Backpressure**: What happens when consumers can't keep up with producers?
  - Block (may halt production)
  - Drop data (oldest or newest)
  - Apply feedback to slow producers
  
- **Queue Capacity Trade-offs**:
  - **Unbounded**: Simple but risky (memory exhaustion)
  - **Bounded**: Requires policy decision on overflow

**Discussion Points:**
- Why "drop oldest" vs "drop newest" or "block"?
  - **Drop oldest**: Best for real-time telemetry where latest data is most valuable
  - **Drop newest**: Useful for logs where historical context matters
  - **Block**: Provides back-pressure but can stall producers (deadlock risk)

- **Memory vs Latency**:
  - Larger queue absorbs bursts but increases memory footprint and latency
  - Smaller queue reduces latency but may drop more data under load

- **Observability**:
  - Current implementation: silent drops
  - Production needs: metrics on drop rate, queue depth, consumer lag

**Code to Discuss:**
```cpp
// TelemetryQueue.cpp
if (max_size_ > 0 && queue_.size() >= max_size_) {
    queue_.pop(); // Drop oldest
}
queue_.push(sample);
```

**Senior-Level Questions to Expect:**
- "How would you detect and alert on queue drops in production?"
  - Answer: Instrument drop count, expose via metrics (Prometheus), alert on threshold
- "What if different data types have different importance? Should critical telemetry never drop?"
  - Answer: Priority queue, separate queues per criticality level
- "How do you size the queue capacity for a production system?"
  - Answer: Load testing, measure producer/consumer rates, add headroom for bursts (2-3x peak rate)

---

### 3. Thread Safety & Concurrency Patterns

**Key Concepts:**
- **Producer-Consumer Pattern**: Core concurrency idiom in our system
  - Producers: Device polling thread
  - Queue: Synchronized buffer
  - Consumers: REST API handler threads

- **Mutex vs Lock-Free Structures**:
  - We use `std::mutex`: simple, correct, but potential contention under high load
  - Lock-free alternatives: `std::atomic`, lock-free queues (boost::lockfree)
  - Trade-off: complexity vs performance

**Discussion Points:**
- Thread safety in `TelemetryQueue`:
  - `std::lock_guard` for short critical sections (push)
  - `std::unique_lock` + `std::condition_variable` for blocking wait (pop)
  - Why `shutdown_` flag prevents new pushes after shutdown

- **Deadlock avoidance**:
  - Lock ordering discipline
  - Avoid nested locks where possible
  - Our queue uses single lock per operation

- **Testing concurrency**:
  - See `test_bounded_queue.cpp`: concurrent producer/consumer tests
  - Challenge: non-determinism, rare race conditions
  - Tools: Thread Sanitizer (TSan), stress testing, formal verification

**Code to Discuss:**
```cpp
// Pop with condition variable
cv_.wait(lock, [this] { return shutdown_ || !queue_.empty(); });
```

**Senior-Level Questions to Expect:**
- "What's the performance impact of the mutex under high contention?"
  - Answer: Measure with profiling; consider lock-free queue if bottleneck confirmed
- "How would you scale this to millions of events per second?"
  - Answer: Partitioned queues (sharding), lock-free structures, batching, SPSC queues
- "How do you test for race conditions?"
  - Answer: TSan, stress tests, code review for lock discipline, formal methods

---

### 4. Logging Best Practices

**Key Concepts:**
- **Log Levels**: Semantic meaning and operational use
  - ERROR: Service impact, requires immediate attention
  - WARN: Degraded state, investigate soon
  - INFO: Normal operations, audit trail
  - DEBUG: Developer diagnostics
  - TRACE: Verbose, function-level tracing

- **Structured Logging**: Key-value pairs vs free-form text
  - Our current format: timestamp + level + category + message
  - Enhancement: JSON logs for machine parsing

**Discussion Points:**
- **Performance considerations**:
  - Logging is I/O-bound (file writes)
  - Async logging buffers writes, reduces latency
  - Log rotation to prevent disk fill

- **Centralized logging** (production systems):
  - ELK stack (Elasticsearch, Logstash, Kibana)
  - Splunk, Datadog, CloudWatch
  - Challenge: volume, retention, cost

- **Log sampling**:
  - High-frequency events can overwhelm logs
  - Sample (log 1 in N), rate limit, or aggregate

**Code to Discuss:**
```cpp
// Logger::log with file sink
std::fprintf(stdout, "%s [%s] (%s) %s\n", ts, L, cat, msg.c_str());
if (file_) std::fprintf(file_, "%s [%s] (%s) %s\n", ts, L, cat, msg.c_str());
```

**Senior-Level Questions to Expect:**
- "How do you handle log volume in high-traffic systems?"
  - Answer: Sampling, aggregation, separate debug logs from operational logs
- "What's your strategy for debugging production issues with logs?"
  - Answer: Correlation IDs, structured logs, distributed tracing (OpenTelemetry)
- "How do you balance log verbosity and performance?"
  - Answer: Dynamic log levels (change at runtime), guard expensive log construction

---

### 5. Testability & Google Test Strategy

**Key Concepts:**
- **Unit vs Integration vs E2E Tests**:
  - Unit: `test_config.cpp` (config parser), `test_bounded_queue.cpp` (queue logic)
  - Integration: `http_integration.ps1` (gateway + REST)
  - E2E: Full system with real device

- **Test Doubles**: Mocks, stubs, fakes
  - Our tests use real `TelemetryQueue`, no mocks needed (state-based testing)
  - When to use mocks: external dependencies (network, disk), non-deterministic behavior

**Discussion Points:**
- **Testing concurrency**: 
  - `test_bounded_queue.cpp`: spawns multiple producer/consumer threads
  - Non-deterministic: rely on statistical behavior, TSan for race detection
  
- **Test isolation**:
  - Config tests use temp directory (`std::filesystem::temp_directory_path`)
  - Cleanup in `TearDown()` ensures no cross-test pollution

- **Coverage vs brittleness**:
  - High coverage is good, but over-mocking leads to brittle tests
  - Focus on behavior, not implementation details

**Code to Discuss:**
```cpp
// Concurrency test
TEST_F(BoundedQueueTest, ConcurrentProducerConsumer) {
    // Producer thread pushes 1000 items
    // Consumer thread pops until shutdown
    // Assert: consumed count <= capacity (some drops expected)
}
```

**Senior-Level Questions to Expect:**
- "How do you test for performance regressions?"
  - Answer: Benchmark tests (our `perf_tool.cpp`), CI integration, track metrics over time
- "What's your approach to testing distributed systems?"
  - Answer: Chaos engineering, network partition simulations, contract testing
- "How do you balance test execution time and coverage?"
  - Answer: Fast unit tests in CI, slower integration tests nightly, E2E on deploy

---

### 6. System Design Trade-offs

**Discuss these architectural decisions:**

1. **In-memory queue vs persistent queue (Kafka, RabbitMQ)**:
   - Current: Fast, simple, but ephemeral
   - Trade-off: Durability vs performance

2. **Polling vs event-driven**:
   - Current: Gateway polls device at fixed interval
   - Alternative: Device pushes events on change
   - Trade-off: Simplicity vs reactivity

3. **Monolithic vs microservices**:
   - Current: Single gateway binary
   - Scale-out: Separate device service, gateway service, API service
   - Trade-off: Simplicity vs scalability

4. **Configuration file vs database**:
   - Current: File-based config
   - Alternative: Config service (etcd, database)
   - Trade-off: Simplicity vs dynamic updates, multi-instance coordination

---

## Preparing for the Interview

### What to Demonstrate:
1. **Code walkthrough**: Show `Config.cpp`, explain parsing logic, discuss error handling
2. **Design rationale**: Why drop-oldest? Why INI format? Why these specific config keys?
3. **Production readiness**: What's missing? (Metrics, validation, reload, etc.)

### Questions to Ask Them:
- "What's your configuration management strategy at scale?"
- "How do you handle backpressure in your data pipelines?"
- "What's your testing pyramid? (Unit vs integration ratio)"

### Red Flags to Avoid:
- Don't say "It's just a simple config parser" – discuss production considerations
- Don't ignore thread safety – always mention mutex, race conditions, testing strategy
- Don't dismiss testing – explain the value of each test case

---

## Summary: Key Takeaways

1. **Configuration is a first-class concern** – externalize, validate, version control
2. **Bounded queues require policy decisions** – understand your data's semantics (real-time vs historical)
3. **Concurrency is hard** – simple designs (mutex) are often right; optimize only when proven bottleneck
4. **Logging is operational visibility** – design for production (levels, rotation, centralization)
5. **Tests give confidence** – unit tests for logic, integration for behavior, concurrency tests for safety

**Final Tip**: Frame every answer in terms of trade-offs. Senior engineers evaluate judgment, not just knowledge.
