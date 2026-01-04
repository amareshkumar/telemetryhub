# Welcome to TelemetryHub

![Build Status](https://github.com/amareshkumar/telemetryhub/actions/workflows/build.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![C++20](https://img.shields.io/badge/C++-20-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey.svg)

**TelemetryHub** is a high-performance, multi-threaded telemetry ingestion and forwarding system built in modern C++20. It demonstrates production-grade software engineering practices including thread safety, performance optimization, and comprehensive testing.

---

## 🎯 Project Overview

TelemetryHub showcases advanced C++ development techniques while solving a real-world problem: efficient telemetry data collection and forwarding. The system achieves **3,720+ requests/second** with sub-500ms p99 latency using a producer-consumer architecture with bounded queues.

### Key Highlights

- **Performance:** 3,720+ req/s, 14-thread architecture, p99 < 500ms
- **Quality:** 90%+ test coverage, 0 ASAN/TSAN/UBSAN violations
- **Modern C++20:** Lock-free patterns, thread safety, RAII, smart pointers
- **Cross-Platform:** Windows (MSVC 2022/2026), Linux (GCC/Clang), Qt6 GUI
- **Production Ready:** REST API, health checks, graceful shutdown, signal handling

---

## 📚 Documentation

### Getting Started
- **[Quick Start Guide](https://github.com/amareshkumar/telemetryhub/blob/main/README.md)** - Build and run in 5 minutes
- **[Configuration Guide](https://github.com/amareshkumar/telemetryhub/blob/main/docs/configuration.md)** - Configure devices, gateway, cloud endpoints
- **[Development Setup](https://github.com/amareshkumar/telemetryhub/blob/main/docs/development.md)** - IDE setup, debugging, Git workflow

### Architecture & Design
- **[System Architecture](https://github.com/amareshkumar/telemetryhub/blob/main/docs/architecture.md)** - High-level design, component interactions
- **[Multithreading Design](https://github.com/amareshkumar/telemetryhub/blob/main/docs/MULTITHREADING_ARCHITECTURE_DIAGRAM.md)** - Thread pools, bounded queues, synchronization
- **[Design Patterns](https://github.com/amareshkumar/telemetryhub/blob/main/docs/INDUSTRY_DESIGN_PATTERNS.md)** - Producer-Consumer, RAII, Thread Pool
- **[Architecture Decisions](https://github.com/amareshkumar/telemetryhub/blob/main/docs/architecture-decisions.md)** - Technical choices explained

### Performance & Scalability
- **[Performance Analysis](https://github.com/amareshkumar/telemetryhub/blob/main/PERFORMANCE.md)** - Benchmarks, optimization techniques
- **[Scalability Guide](https://github.com/amareshkumar/telemetryhub/blob/main/docs/scalability.md)** - Horizontal/vertical scaling strategies

### API & Integration
- **[REST API Reference](https://github.com/amareshkumar/telemetryhub/blob/main/docs/api.md)** - Endpoints, request/response formats
- **[Example Usage](https://github.com/amareshkumar/telemetryhub/tree/main/examples)** - C++ and Python client examples

### Testing & Quality
- **[Testing Strategy](https://github.com/amareshkumar/telemetryhub/blob/main/docs/development.md#testing)** - Unit, integration, E2E tests
- **[CI/CD Pipeline](https://github.com/amareshkumar/telemetryhub/actions)** - GitHub Actions workflows

### Troubleshooting
- **[Troubleshooting Guide](https://github.com/amareshkumar/telemetryhub/blob/main/docs/troubleshooting.md)** - Common issues and solutions
- **[Windows Build Issues](https://github.com/amareshkumar/telemetryhub/blob/main/docs/windows_build_troubleshooting.md)** - Windows-specific build problems

---

## 🚀 Quick Start

### Prerequisites

**Windows:**
```powershell
# Install Visual Studio 2022 with C++ workload
# Install CMake 3.26+
# Install Qt6 (optional, for GUI)
```

**Linux:**
```bash
sudo apt-get install build-essential cmake libcurl4-openssl-dev
```

### Build & Run

```bash
# Clone the repository
git clone https://github.com/amareshkumar/telemetryhub.git
cd telemetryhub

# Configure (Windows)
cmake --preset vs2022-debug

# Configure (Linux)
cmake --preset ninja-debug

# Build
cmake --build build --config Debug

# Run tests
ctest --test-dir build -C Debug

# Run the gateway
./build/gateway/telemetryhub_gateway
```

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up --build

# Gateway available at: http://localhost:8080
```

---

## 🏗️ Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                     TelemetryHub System                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌───────────┐ │
│  │   Devices    │─────▶│   Gateway    │─────▶│   Cloud   │ │
│  │  (Sensors)   │      │ (Hub/Forwd)  │      │ (Backend) │ │
│  └──────────────┘      └──────────────┘      └───────────┘ │
│                                                               │
│  REST API (8080)        Thread Pools          HTTP Client    │
│  Bounded Queues         Worker Threads        Retry Logic    │
│  Health Checks          Flow Control          TLS/SSL        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Threading Model

- **REST Server Thread:** Accepts incoming telemetry (1 thread)
- **Worker Pool:** Processes and forwards data (12 threads)
- **Cloud Client:** Batches and sends to backend (1 thread)
- **Bounded Queue:** 10,000-item capacity with backpressure

### Data Flow

1. **Ingestion:** REST API receives telemetry from devices
2. **Queuing:** Bounded queue buffers data (prevents overload)
3. **Processing:** Worker threads validate and enrich data
4. **Forwarding:** Cloud client batches and sends to backend
5. **Monitoring:** Health checks, metrics, graceful shutdown

---

## 🎓 Learning Resources

### For Interview Preparation

This project demonstrates:

- **Multithreading:** Thread pools, producer-consumer, synchronization
- **Performance:** Lock-free patterns, cache optimization, profiling
- **Modern C++:** RAII, smart pointers, move semantics, constexpr
- **Design Patterns:** Factory, Singleton, Command (implicit), Observer
- **Testing:** Unit tests (GTest), mocks, sanitizers (ASAN/TSAN)
- **DevOps:** CMake, Docker, CI/CD, cross-platform builds

### Code Walkthrough

**Key Files to Study:**

1. **[ThreadPool.h](https://github.com/amareshkumar/telemetryhub/blob/main/gateway/include/telemetryhub/ThreadPool.h)** - Modern thread pool implementation
2. **[BoundedQueue.h](https://github.com/amareshkumar/telemetryhub/blob/main/gateway/include/telemetryhub/BoundedQueue.h)** - Thread-safe bounded queue with backpressure
3. **[CloudClient.h](https://github.com/amareshkumar/telemetryhub/blob/main/gateway/include/telemetryhub/CloudClient.h)** - HTTP client with retry logic
4. **[Gateway.cpp](https://github.com/amareshkumar/telemetryhub/blob/main/gateway/src/Gateway.cpp)** - Main orchestration and signal handling

### Technical Deep Dives

- **[Thread Safety Analysis](https://github.com/amareshkumar/telemetryhub/blob/main/docs/MULTITHREADING_ARCHITECTURE_DIAGRAM.md)** - How we avoid data races
- **[Performance Optimization](https://github.com/amareshkumar/telemetryhub/blob/main/PERFORMANCE.md)** - Achieving 3,720+ req/s
- **[Testing Strategy](https://github.com/amareshkumar/telemetryhub/blob/main/docs/development.md#testing)** - 90%+ coverage approach

---

## 🔧 Configuration

### Example Configuration

**`config.ini`:**
```ini
[gateway]
device_port=8080
cloud_url=https://api.example.com/telemetry
worker_threads=12
queue_size=10000
batch_size=100
batch_timeout_ms=1000

[logging]
level=info
file=telemetryhub.log

[health]
endpoint=/health
interval_ms=5000
```

### Environment Variables

```bash
TELEMETRYHUB_CONFIG_PATH=/path/to/config.ini
TELEMETRYHUB_LOG_LEVEL=debug
TELEMETRYHUB_CLOUD_URL=https://api.example.com/telemetry
```

---

## 📊 Performance Metrics

### Benchmark Results

| Metric                | Value          | Test Environment      |
|-----------------------|----------------|-----------------------|
| **Throughput**        | 3,720 req/s    | Windows, 14 threads   |
| **Latency (p50)**     | 12 ms          | Local network         |
| **Latency (p99)**     | < 500 ms       | Under load            |
| **Memory Usage**      | ~50 MB         | Steady state          |
| **Queue Capacity**    | 10,000 items   | Backpressure enabled  |
| **Test Coverage**     | 90%+           | Unit + Integration    |

### Sanitizer Validation

- ✅ **AddressSanitizer (ASAN):** 0 violations
- ✅ **ThreadSanitizer (TSAN):** 0 data races
- ✅ **UndefinedBehaviorSanitizer (UBSAN):** 0 violations

---

## 🛠️ Development

### Build Variants

**Windows (Visual Studio):**
- `vs2022-debug` - Debug build with MSVC 2022
- `vs2022-release` - Release build with optimizations
- `vs2026-debug` - Debug build with MSVC 2026 (preview)
- `vs2026-gui` - GUI build with Qt6

**Linux:**
- `ninja-debug` - Debug build with Ninja
- `ninja-release` - Release build
- `gcc-debug` - GCC-specific build
- `clang-debug` - Clang-specific build

### Running Tests

```bash
# All tests
ctest --test-dir build -C Debug -V

# Specific test
./build/tests/telemetryhub_tests --gtest_filter=BoundedQueueTest.*

# With sanitizers (Linux)
cmake -DCMAKE_BUILD_TYPE=Debug -DUSE_SANITIZERS=ON ..
cmake --build .
./tests/telemetryhub_tests
```

### Code Style

- **C++ Standard:** C++20
- **Naming:** PascalCase (classes), camelCase (functions), snake_case (variables)
- **Formatting:** ClangFormat (LLVM style)
- **Documentation:** Doxygen-style comments

---

## 🤝 Contributing

### Contribution Guidelines

1. **Fork the repository**
2. **Create feature branch:** `git checkout -b feature/amazing-feature`
3. **Write tests:** Maintain 90%+ coverage
4. **Run sanitizers:** Ensure 0 violations
5. **Update documentation:** Keep docs in sync with code
6. **Submit PR:** Follow [CONTRIBUTING.md](https://github.com/amareshkumar/telemetryhub/blob/main/CONTRIBUTING.md)

### Issue Templates

We use structured issue templates:
- **Bug Report:** Reproducible bug with system details
- **Feature Request:** New functionality proposal
- **Performance Issue:** Performance degradation report
- **Documentation:** Documentation improvements
- **Question:** General questions about the project

[Report an Issue](https://github.com/amareshkumar/telemetryhub/issues/new/choose)

---

## 📈 Project Roadmap

### ✅ Completed (v6.2.0)
- Multi-threaded gateway with thread pool
- REST API with cpp-httplib
- Bounded queue with backpressure
- Cloud client with retry logic
- Comprehensive test suite (90%+ coverage)
- Docker deployment
- GitHub Actions CI/CD
- Cross-platform support (Windows/Linux)
- Qt6 GUI application

### 🚧 In Progress
- Security enhancements (TLS/SSL, authentication)
- Observability (Prometheus metrics, OpenTelemetry)
- Advanced retry strategies (exponential backoff)
- Performance profiling integration

### 🔮 Future (Post v6.2.0)
- Kubernetes deployment manifests
- gRPC support for high-performance clients
- Time-series database integration (InfluxDB)
- Load balancing and sharding
- WebSocket support for real-time monitoring

---

## 🔒 Security

### Reporting Vulnerabilities

If you discover a security vulnerability, please:

1. **DO NOT** open a public issue
2. Email: amaresh.kumar@live.in
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

We'll respond within 48 hours and provide a fix within 7 days for critical issues.

### Security Best Practices

- ✅ Private vulnerability reporting (enabled)
- ✅ Dependabot alerts (enabled)
- ✅ Regular dependency updates
- ✅ ASAN/TSAN/UBSAN validation
- ✅ Code review for all PRs
- 🔄 TLS/SSL support (in progress)
- 🔄 Authentication/Authorization (in progress)

---

## 📜 License

This project is licensed under the **MIT License** - see [LICENSE](https://github.com/amareshkumar/telemetryhub/blob/main/LICENSE) file for details.

```
Copyright (c) 2025 Amaresh Kumar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 📞 Contact & Support

### Project Maintainer

**Amaresh Kumar**
- GitHub: [@amareshkumar](https://github.com/amareshkumar)
- Email: amaresh.kumar@live.in
- LinkedIn: [amareshkumar](https://www.linkedin.com/in/amareshkumar)

### Community

- **Issues:** [GitHub Issues](https://github.com/amareshkumar/telemetryhub/issues)
- **Discussions:** [GitHub Discussions](https://github.com/amareshkumar/telemetryhub/discussions)
- **Pull Requests:** [Contributing Guide](https://github.com/amareshkumar/telemetryhub/blob/main/CONTRIBUTING.md)

---

## 🌟 Acknowledgments

### Technologies Used

- **[cpp-httplib](https://github.com/yhirose/cpp-httplib)** - Modern C++ HTTP library
- **[nlohmann/json](https://github.com/nlohmann/json)** - JSON for Modern C++
- **[Google Test](https://github.com/google/googletest)** - C++ testing framework
- **[Qt6](https://www.qt.io/)** - Cross-platform GUI framework
- **[CMake](https://cmake.org/)** - Build system generator
- **[Docker](https://www.docker.com/)** - Containerization platform

### Inspiration

This project was inspired by real-world telemetry systems used in:
- IoT sensor networks
- Distributed monitoring systems
- Edge computing gateways
- Industrial automation

---

## 📖 Additional Resources

### External References

- **[Modern C++ Best Practices](https://github.com/cpp-best-practices/cppbestpractices)** - C++ guidelines
- **[C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)** - ISO C++ standards
- **[CMake Documentation](https://cmake.org/documentation/)** - Build system reference
- **[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)** - Code style

### Similar Projects

- **[Prometheus](https://github.com/prometheus/prometheus)** - Monitoring and alerting
- **[InfluxDB](https://github.com/influxdata/influxdb)** - Time-series database
- **[Telegraf](https://github.com/influxdata/telegraf)** - Agent for collecting metrics
- **[Vector](https://github.com/vectordotdev/vector)** - High-performance observability pipelines

---

## ⭐ Star History

If you find TelemetryHub useful, please consider:
- ⭐ **Starring the repository** on GitHub
- 🍴 **Forking** to experiment with your own ideas
- 📢 **Sharing** with colleagues and friends
- 🐛 **Reporting issues** to help improve the project
- 💬 **Contributing** features and bug fixes

---

## 📚 Wiki Navigation

### Core Documentation
- **[Home](https://github.com/amareshkumar/telemetryhub/wiki)** (You are here)
- [Architecture Overview](https://github.com/amareshkumar/telemetryhub/wiki/Architecture)
- [Getting Started](https://github.com/amareshkumar/telemetryhub/wiki/Getting-Started)
- [API Reference](https://github.com/amareshkumar/telemetryhub/wiki/API-Reference)

### Advanced Topics
- [Performance Tuning](https://github.com/amareshkumar/telemetryhub/wiki/Performance-Tuning)
- [Threading Deep Dive](https://github.com/amareshkumar/telemetryhub/wiki/Threading)
- [Testing Strategy](https://github.com/amareshkumar/telemetryhub/wiki/Testing)
- [Deployment Guide](https://github.com/amareshkumar/telemetryhub/wiki/Deployment)

### Development
- [Building from Source](https://github.com/amareshkumar/telemetryhub/wiki/Building)
- [Contributing Guide](https://github.com/amareshkumar/telemetryhub/wiki/Contributing)
- [Troubleshooting](https://github.com/amareshkumar/telemetryhub/wiki/Troubleshooting)
- [FAQ](https://github.com/amareshkumar/telemetryhub/wiki/FAQ)

---

<div align="center">

**Built with ❤️ by [Amaresh Kumar](https://github.com/amareshkumar)**

[⬆ Back to Top](#welcome-to-telemetryhub)

</div>
