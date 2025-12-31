# TelemetryHub + TelemetryTaskProcessor Integration Strategy

## Overview

Both projects complement each other perfectly:

- **TelemetryHub**: Collects telemetry data from devices (sensors, hardware) via UART/I2C/SPI
- **TelemetryTaskProcessor**: Processes tasks asynchronously at high throughput using Redis

## Integration Architecture

### Current State

**TelemetryHub:**
- Device generates telemetry samples (9.1M ops/sec)
- TelemetryQueue (in-memory, thread-safe)
- GatewayCore exposes REST API (start/stop/status)
- Configuration via INI files

**TelemetryTaskProcessor:**
- Task-based processing system
- Redis client for distributed coordination
- Priority queues, worker pools
- JSON serialization for tasks

### Proposed Integration

**Use Case**: TelemetryHub collects sensor data → TelemetryTaskProcessor performs heavy analysis/processing

```
IoT Devices (sensors)
    ↓ UART/I2C/SPI
TelemetryHub Device Layer
    ↓ generates TelemetrySample
TelemetryHub Gateway (REST API)
    ↓ publishes to Redis
Redis (Message Broker)
    ↓ task queue
TelemetryTaskProcessor Workers
    ↓ process & analyze
Results Storage / Downstream Systems
```

## Integration Points

### 1. Redis as Message Broker

**Change in TelemetryHub:**
- Gateway publishes telemetry samples to Redis lists
- Convert `TelemetrySample` → `Task` (JSON)
- Use Redis RPUSH to enqueue tasks

**TelemetryTaskProcessor:**
- Already has Redis client ready
- Workers consume tasks via BLPOP
- Process telemetry data asynchronously

### 2. Task Types

Define telemetry-specific task types:

```cpp
// Task types in TelemetryTaskProcessor
"telemetry.analyze"       // Statistical analysis
"telemetry.anomaly_detect" // Anomaly detection
"telemetry.aggregate"     // Time-based aggregation
"telemetry.store"         // Persist to database
"telemetry.alert"         // Threshold-based alerting
```

### 3. Payload Format

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "telemetry.analyze",
  "payload": {
    "device_id": "sensor_001",
    "timestamp": "2025-12-26T10:30:00Z",
    "temperature": 23.5,
    "humidity": 65.2,
    "pressure": 1013.25,
    "raw_data": "base64_encoded_sensor_data"
  },
  "priority": "NORMAL",
  "max_retries": 3
}
```

## Implementation Steps

### Phase 1: Basic Integration (Week 1)

**TelemetryHub changes:**

1. Add Redis client dependency to Gateway
```cmake
# gateway/CMakeLists.txt
find_package(redis++ REQUIRED)
target_link_libraries(gateway_core redis++::redis++)
```

2. Create `RedisPublisher` class in Gateway
```cpp
// gateway/include/telemetryhub/gateway/RedisPublisher.h
class RedisPublisher {
public:
    RedisPublisher(const std::string& host, int port);
    bool publish_telemetry_task(const TelemetrySample& sample);
private:
    std::unique_ptr<sw::redis::Redis> redis_;
};
```

3. Integrate into GatewayCore
```cpp
// In GatewayCore::process_samples()
void GatewayCore::process_samples() {
    while (running_) {
        auto sample = queue_.pop();
        
        // Option A: Store locally (existing)
        store_sample(sample);
        
        // Option B: Publish to Redis for async processing
        redis_publisher_->publish_telemetry_task(sample);
    }
}
```

**TelemetryTaskProcessor changes:**

1. Add telemetry-specific task handlers
```cpp
// src/handlers/TelemetryHandler.cpp
class TelemetryHandler {
public:
    void handle_analyze(const Task& task);
    void handle_anomaly_detect(const Task& task);
    void handle_aggregate(const Task& task);
};
```

2. Register handlers in worker pool
```cpp
worker_pool.register_handler("telemetry.analyze", 
    std::make_shared<TelemetryHandler>());
```

### Phase 2: Advanced Features (Week 2)

1. **Circuit Breaker**: TelemetryHub backs off if Redis is down
2. **Backpressure**: TelemetryTaskProcessor signals when overloaded
3. **Metrics**: Prometheus metrics for end-to-end latency
4. **Dead Letter Queue**: Failed telemetry processing goes to DLQ

### Phase 3: Production Hardening (Week 3)

1. **Configuration**: Unified config format (YAML/INI)
2. **Observability**: Structured logging with correlation IDs
3. **Testing**: Integration tests with Redis container
4. **Docker Compose**: Single-command deployment

## Benefits of Integration

### 1. Decoupling
- TelemetryHub focuses on data collection (low latency)
- TelemetryTaskProcessor handles heavy computation (high throughput)
- Redis buffers between systems (elasticity)

### 2. Scalability
- Scale TelemetryHub horizontally (more gateways for more devices)
- Scale TelemetryTaskProcessor horizontally (more workers)
- Redis handles load balancing automatically

### 3. Reliability
- TelemetryHub keeps collecting even if processing is slow
- TelemetryTaskProcessor can catch up during low traffic
- Tasks persist in Redis (survive restarts)

### 4. Portfolio Value
Shows end-to-end systems thinking:
- Data ingestion (TelemetryHub)
- Message queuing (Redis)
- Async processing (TelemetryTaskProcessor)
- Performance optimization (9.1M ingestion + 10k processing)

## Example Workflow

```
1. Sensor generates temperature reading
   → Device.measure() in TelemetryHub

2. TelemetrySample created
   → {device_id: "sensor_001", temp: 23.5°C, timestamp: now}

3. Gateway publishes to Redis
   → RPUSH telemetry:tasks "{...json...}"

4. TelemetryTaskProcessor worker picks up task
   → BLPOP telemetry:tasks

5. Worker processes (e.g., anomaly detection)
   → if temp > 30°C: trigger alert

6. Result stored or forwarded
   → PostgreSQL / Kafka / REST API
```

## Configuration Example

### TelemetryHub config (config.ini)
```ini
[redis]
enabled = true
host = 127.0.0.1
port = 6379
queue_name = telemetry:tasks

[gateway]
sampling_interval_ms = 100
local_storage = true
redis_publish = true  # Enable dual mode
```

### TelemetryTaskProcessor config (config.yaml)
```yaml
redis:
  host: 127.0.0.1
  port: 6379
  queue_name: telemetry:tasks
  
worker_pool:
  num_workers: 8
  max_queue_size: 10000
  
handlers:
  - type: telemetry.analyze
    priority: NORMAL
  - type: telemetry.anomaly_detect
    priority: HIGH
```

## Testing Strategy

### Unit Tests
- Mock Redis in both projects (already done in TelemetryTaskProcessor)
- Test serialization: TelemetrySample ↔ Task JSON

### Integration Tests
```cpp
TEST(IntegrationTest, TelemetryHubToProcessor) {
    // Start Redis container
    auto redis = RedisTestContainer();
    
    // Start TelemetryHub gateway
    GatewayCore gateway(config_with_redis);
    gateway.start();
    
    // Start TelemetryTaskProcessor workers
    WorkerPool workers(config);
    workers.start();
    
    // Inject telemetry sample
    gateway.inject_sample({temp: 25.5});
    
    // Verify task processed
    std::this_thread::sleep_for(100ms);
    EXPECT_TRUE(workers.task_completed("telemetry.analyze"));
}
```

### Load Tests
- TelemetryHub: Generate 1M samples/sec
- Redis: Monitor queue depth
- TelemetryTaskProcessor: Measure processing rate

## Docker Compose Deployment

```yaml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      
  telemetryhub:
    build: ./telemetryhub
    depends_on:
      - redis
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    ports:
      - "8080:8080"
      
  telemetry_processor:
    build: ./TelemetryTaskProcessor
    depends_on:
      - redis
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - NUM_WORKERS=8
    deploy:
      replicas: 2  # Scale processors
      
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

volumes:
  redis_data:
```

## Common Code Opportunities

Both projects could share:

1. **RedisClient wrapper**: DRY principle
2. **JSON utilities**: Serialization helpers
3. **Logging framework**: spdlog/structured logging
4. **Configuration parser**: Unified config library
5. **Metrics exporter**: Prometheus client library

**Suggestion**: Create shared library `telemetry-common`:
```
telemetry-common/
  include/
    redis_client.h
    json_utils.h
    config.h
    metrics.h
  src/
    redis_client.cpp
    ...
```

Then link from both projects:
```cmake
# In TelemetryHub and TelemetryTaskProcessor
target_link_libraries(gateway_core telemetry-common)
target_link_libraries(telemetry_processor telemetry-common)
```

## Migration Path

### Option 1: Gradual Migration
Keep both projects separate, connect via Redis:
- ✅ Lower risk (no code merge)
- ✅ Independent deployment
- ❌ Code duplication

### Option 2: Monorepo
Merge into single repository:
```
telemetry-platform/
  common/          # Shared libraries
  ingestion/       # TelemetryHub
  processing/      # TelemetryTaskProcessor
  deployment/      # Docker Compose, K8s
  docs/           # Unified docs
```
- ✅ Code reuse (shared library)
- ✅ Unified documentation
- ❌ Higher upfront effort

**Recommendation**: Start with Option 1 (gradual), migrate to Option 2 after integration proven.

## Timeline

**Week 1**: Basic integration (Redis connection)
**Week 2**: Task handlers, testing
**Week 3**: Production features (circuit breaker, metrics)
**Week 4**: Documentation, Docker Compose

Total: 4 weeks to production-ready integrated system

## Success Metrics

- End-to-end latency: <50ms p99 (ingestion → processing)
- Throughput: 5,000+ telemetry samples/sec processed
- Reliability: 99.9% task delivery success rate
- Zero data loss during normal operation
- Graceful degradation when Redis unavailable

---

**Next Steps:**
1. Review this strategy
2. Create detailed design for RedisPublisher (TelemetryHub)
3. Create TelemetryHandler (TelemetryTaskProcessor)
4. Set up integration test environment (Docker Compose)
5. Implement Phase 1 (basic integration)
