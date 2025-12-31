# TelemetryHub + TelemetryTaskProcessor Integration Diagram

## High-Level Architecture

```mermaid
architecture-beta
    group devices(cloud)[IoT Device Layer]
    group ingestion(server)[TelemetryHub Ingestion]
    group broker(database)[Message Broker]
    group processing(server)[TelemetryTaskProcessor]
    group storage(disk)[Data Storage]

    service sensor1(disk)[Temperature Sensor] in devices
    service sensor2(disk)[Pressure Sensor] in devices
    service sensor3(disk)[Humidity Sensor] in devices
    
    service device_layer(server)[Device Driver] in ingestion
    service gateway(internet)[Gateway REST API] in ingestion
    service queue(database)[TelemetryQueue] in ingestion
    
    service redis(database)[Redis] in broker
    
    service worker1(server)[Worker 1] in processing
    service worker2(server)[Worker 2] in processing
    service worker3(server)[Worker N] in processing
    
    service postgres(database)[PostgreSQL] in storage
    service metrics(internet)[Prometheus] in storage

    sensor1:R --> L:device_layer
    sensor2:R --> L:device_layer
    sensor3:R --> L:device_layer
    
    device_layer:R --> L:queue
    queue:R --> L:gateway
    gateway:R --> L:redis
    
    redis:R --> L:worker1
    redis:R --> L:worker2
    redis:R --> L:worker3
    
    worker1:R --> L:postgres
    worker2:R --> L:postgres
    worker3:R --> L:postgres
    
    worker1:B --> T:metrics
    worker2:B --> T:metrics
    worker3:B --> T:metrics
```

## Detailed Data Flow

```mermaid
sequenceDiagram
    participant Sensor as IoT Sensor
    participant Device as TelemetryHub::Device
    participant Queue as TelemetryHub::Queue
    participant Gateway as TelemetryHub::Gateway
    participant Redis as Redis Message Broker
    participant Worker as TaskProcessor::Worker
    participant Handler as TaskProcessor::TelemetryHandler
    participant DB as PostgreSQL
    participant Metrics as Prometheus

    Sensor->>Device: Read sensor data (UART/I2C/SPI)
    activate Device
    Device->>Device: Create TelemetrySample
    Device->>Queue: push(TelemetrySample)
    deactivate Device
    
    activate Queue
    Queue->>Gateway: pop() [background thread]
    deactivate Queue
    
    activate Gateway
    Gateway->>Gateway: Convert TelemetrySample → Task (JSON)
    Gateway->>Redis: RPUSH telemetry:tasks
    Note over Gateway,Redis: {id, type:"telemetry.analyze", payload}
    deactivate Gateway
    
    activate Redis
    Redis-->>Worker: BLPOP telemetry:tasks [blocking]
    deactivate Redis
    
    activate Worker
    Worker->>Worker: Deserialize Task JSON
    Worker->>Handler: dispatch(task)
    activate Handler
    
    alt Anomaly Detection
        Handler->>Handler: Check thresholds
        Handler->>Handler: Statistical analysis
    else Aggregation
        Handler->>Handler: Time-series aggregation
    else Storage
        Handler->>DB: INSERT telemetry_data
    end
    
    Handler-->>Worker: ProcessResult{success, metrics}
    deactivate Handler
    
    Worker->>Metrics: Increment counters
    Note over Worker,Metrics: tasks_processed, latency_ms
    
    alt Success
        Worker->>Redis: DEL task:{id} (cleanup)
    else Failure
        Worker->>Redis: RPUSH telemetry:dlq (dead letter)
    end
    deactivate Worker
```

## Component Integration View

```mermaid
flowchart TB
    subgraph TelemetryHub["TelemetryHub (Data Ingestion)"]
        direction TB
        A[Device Layer<br/>UART/I2C/SPI] --> B[TelemetrySample Generator<br/>9.1M ops/sec]
        B --> C[Thread-Safe Queue<br/>Bounded/Unbounded]
        C --> D[Gateway Core<br/>REST API]
        D --> E[Redis Publisher<br/>NEW COMPONENT]
    end
    
    subgraph Redis["Redis (Message Broker)"]
        direction TB
        F[Task Queue<br/>LIST: telemetry:tasks]
        G[Dead Letter Queue<br/>LIST: telemetry:dlq]
        H[Task State<br/>HASH: task:{id}]
    end
    
    subgraph TelemetryTaskProcessor["TelemetryTaskProcessor (Async Processing)"]
        direction TB
        I[Redis Client<br/>BLPOP consumer]
        I --> J[Task Dispatcher<br/>Priority routing]
        J --> K[Worker Pool<br/>8 workers]
        K --> L1[TelemetryHandler<br/>Analyze]
        K --> L2[TelemetryHandler<br/>Anomaly Detect]
        K --> L3[TelemetryHandler<br/>Aggregate]
    end
    
    subgraph Downstream["Downstream Systems"]
        direction TB
        M[PostgreSQL<br/>Time-series data]
        N[Prometheus<br/>Metrics]
        O[Alert Service<br/>Notifications]
    end
    
    E -->|RPUSH| F
    F -->|BLPOP| I
    K -->|Failed tasks| G
    
    L1 --> M
    L2 --> O
    L3 --> M
    
    K --> N
    D --> N
    
    style E fill:#ff6b6b
    style I fill:#ff6b6b
    style TelemetryHub fill:#e3f2fd
    style TelemetryTaskProcessor fill:#f3e5f5
    style Redis fill:#fff9c4
    style Downstream fill:#e8f5e9
```

## Deployment Architecture

```mermaid
flowchart LR
    subgraph Edge["Edge Network (Factory Floor)"]
        direction TB
        S1[Sensor 1]
        S2[Sensor 2]
        S3[Sensor N]
    end
    
    subgraph K8s["Kubernetes Cluster"]
        direction TB
        
        subgraph NS1["Namespace: telemetry-ingestion"]
            TH1[TelemetryHub Pod 1<br/>:8080]
            TH2[TelemetryHub Pod 2<br/>:8080]
            TH3[TelemetryHub Pod N<br/>:8080]
        end
        
        subgraph NS2["Namespace: message-broker"]
            R1[Redis Master<br/>:6379]
            R2[Redis Replica 1]
            R3[Redis Replica 2]
        end
        
        subgraph NS3["Namespace: task-processing"]
            TP1[TaskProcessor Pod 1<br/>8 workers]
            TP2[TaskProcessor Pod 2<br/>8 workers]
            TP3[TaskProcessor Pod N<br/>8 workers]
        end
    end
    
    subgraph Cloud["Cloud Services"]
        PG[(PostgreSQL<br/>RDS)]
        PROM[Prometheus<br/>:9090]
        GRAF[Grafana<br/>:3000]
    end
    
    S1 -->|UART| TH1
    S2 -->|I2C| TH2
    S3 -->|SPI| TH3
    
    TH1 -->|RPUSH| R1
    TH2 -->|RPUSH| R1
    TH3 -->|RPUSH| R1
    
    R1 -.->|Replicate| R2
    R1 -.->|Replicate| R3
    
    R1 -->|BLPOP| TP1
    R1 -->|BLPOP| TP2
    R1 -->|BLPOP| TP3
    
    TP1 --> PG
    TP2 --> PG
    TP3 --> PG
    
    TH1 -.->|/metrics| PROM
    TH2 -.->|/metrics| PROM
    TH3 -.->|/metrics| PROM
    TP1 -.->|/metrics| PROM
    TP2 -.->|/metrics| PROM
    TP3 -.->|/metrics| PROM
    
    PROM --> GRAF
    
    style NS1 fill:#e3f2fd
    style NS2 fill:#fff9c4
    style NS3 fill:#f3e5f5
    style Cloud fill:#e8f5e9
    style Edge fill:#fce4ec
```

## Performance Profile

```mermaid
flowchart TB
    Start[Sensor Reading] -->|"<1ms"| A[TelemetryHub Device]
    A -->|"<0.1ms<br/>Lock-free queue"| B[TelemetryHub Gateway]
    B -->|"<2ms<br/>Network + RPUSH"| C[Redis Queue]
    C -->|"<5ms<br/>BLPOP blocking"| D[TaskProcessor Worker]
    D -->|"10-50ms<br/>Processing logic"| E[Handler Execution]
    E -->|"5-20ms<br/>DB write"| F[PostgreSQL]
    
    style Start fill:#4caf50
    style A fill:#8bc34a
    style B fill:#cddc39
    style C fill:#ffeb3b
    style D fill:#ffc107
    style E fill:#ff9800
    style F fill:#ff5722
    
    Note1[Total Latency:<br/>p50: ~20ms<br/>p99: <50ms]
    
    E -.-> Note1
```

## Docker Compose Setup

```mermaid
flowchart TB
    subgraph Docker["docker-compose.yml"]
        direction TB
        
        DC_Redis[redis:7-alpine<br/>Port: 6379]
        DC_TH[telemetryhub:latest<br/>Port: 8080<br/>ENV: REDIS_HOST=redis]
        DC_TP1[telemetry_processor:latest<br/>Replica 1<br/>8 workers]
        DC_TP2[telemetry_processor:latest<br/>Replica 2<br/>8 workers]
        DC_PG[(postgres:15<br/>Port: 5432)]
        DC_PROM[prometheus:latest<br/>Port: 9090]
        DC_GRAF[grafana:latest<br/>Port: 3000]
        
        DC_TH -->|depends_on| DC_Redis
        DC_TP1 -->|depends_on| DC_Redis
        DC_TP2 -->|depends_on| DC_Redis
        DC_TP1 -->|depends_on| DC_PG
        DC_TP2 -->|depends_on| DC_PG
        DC_PROM -->|scrapes| DC_TH
        DC_PROM -->|scrapes| DC_TP1
        DC_PROM -->|scrapes| DC_TP2
        DC_GRAF -->|reads| DC_PROM
    end
    
    User[Developer] -->|docker compose up| Docker
    
    style DC_Redis fill:#fff9c4
    style DC_TH fill:#e3f2fd
    style DC_TP1 fill:#f3e5f5
    style DC_TP2 fill:#f3e5f5
    style DC_PG fill:#c8e6c9
    style DC_PROM fill:#ffccbc
    style DC_GRAF fill:#d1c4e9
```

## Task State Machine

```mermaid
stateDiagram-v2
    [*] --> Created: TelemetryHub creates task
    Created --> Queued: Gateway RPUSH to Redis
    Queued --> Assigned: Worker BLPOP
    Assigned --> Running: Worker starts processing
    
    Running --> Completed: Success
    Running --> Failed: Error (retries < max)
    Running --> DeadLetter: Error (retries >= max)
    
    Failed --> Queued: Exponential backoff retry
    
    Completed --> [*]
    DeadLetter --> [*]
    
    note right of Queued
        Redis LIST:
        telemetry:tasks
    end note
    
    note right of Running
        Task processing:
        - Anomaly detection
        - Aggregation
        - Storage
    end note
    
    note right of DeadLetter
        Redis LIST:
        telemetry:dlq
        Manual intervention
    end note
```

## Key Integration Points

| Component | Technology | Purpose | Performance |
|-----------|-----------|---------|-------------|
| **TelemetryHub Device** | C++20, UART/I2C/SPI | Sensor data collection | 9.1M ops/sec |
| **TelemetryHub Gateway** | C++20, cpp-httplib | REST API, Redis publisher | 50k req/sec |
| **Redis** | Redis 7.x | Message broker, task queue | 100k ops/sec |
| **TelemetryTaskProcessor** | C++17, redis++ | Async task processing | 10k tasks/sec |
| **Worker Pool** | C++17, std::thread | Concurrent processing | 8-16 workers |
| **PostgreSQL** | PostgreSQL 15 | Time-series storage | 10k writes/sec |
| **Prometheus** | Prometheus 2.x | Metrics collection | Real-time monitoring |

---

**Integration Benefits:**
- ✅ Decoupled architecture (loosely coupled via Redis)
- ✅ Horizontal scalability (scale ingestion & processing independently)
- ✅ High throughput (9.1M ingestion + 10k processing)
- ✅ Fault tolerance (Redis persistence, task retries, DLQ)
- ✅ Observability (Prometheus metrics, structured logging)
- ✅ Production-ready (Docker Compose, K8s deployment)

**Next Steps:**
1. Implement RedisPublisher in TelemetryHub Gateway
2. Create TelemetryHandler in TelemetryTaskProcessor
3. Set up Docker Compose environment
4. Integration testing with real Redis
5. Load testing (1M telemetry samples/sec)
