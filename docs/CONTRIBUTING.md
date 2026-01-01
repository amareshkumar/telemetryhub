# Contributing to TelemetryHub

Thank you for your interest in contributing! This guide will help you get started.

---

## Development Setup

### Prerequisites

- **C++20 Compiler**: GCC 10+, Clang 12+, or MSVC 2022+
- **CMake**: Version 3.20 or newer
- **Build Tool**: Ninja (recommended) or Make/MSBuild
- **Qt 6.10+**: Optional, only required for GUI development
- **Python 3.7+**: Optional, for running example scripts

### Quick Start

#### Linux

```bash
# Install dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y build-essential cmake ninja-build

# Clone repository
git clone https://github.com/amareshkumar/telemetryhub.git
cd telemetryhub

# Configure and build (with sanitizers)
cmake --preset linux-ninja-asan-ubsan
cmake --build --preset linux-ninja-asan-ubsan

# Run tests
ctest --preset linux-ninja-asan-ubsan --output-on-failure

# Run gateway
./build_asan/gateway/gateway_app --version
./build_asan/gateway/gateway_app --config docs/config.example.ini
```

#### Windows

```powershell
# Install dependencies (if needed)
choco install cmake ninja visualstudio2022-workload-vctools

# Clone repository
git clone https://github.com/amareshkumar/telemetryhub.git
cd telemetryhub

# Configure and build
cmake --preset vs2022-release-ci
cmake --build --preset vs2022-release-ci

# Run tests
ctest --preset vs2022-release-ci --output-on-failure

# Run gateway
.\\build_vs_ci\\gateway\\Release\\gateway_app.exe --version
```

---

## Code Style

### General Principles

- **Modern C++20**: Prefer standard library features over custom implementations
- **RAII**: All resources managed via RAII (no manual `new`/`delete`, no raw pointers)
- **const-correctness**: Mark everything `const` unless it needs to mutate
- **Explicit**: Avoid implicit conversions and magic numbers

### Naming Conventions

- **Classes/Structs**: `PascalCase` (e.g., `TelemetryQueue`, `GatewayCore`)
- **Functions/Methods**: `snake_case` (e.g., `device_state()`, `push_sample()`)
- **Member Variables**: `snake_case_` with trailing underscore (e.g., `queue_`, `running_`)
- **Constants**: `UPPER_SNAKE_CASE` or `kCamelCase` (e.g., `MAX_QUEUE_SIZE`)
- **Namespaces**: `lowercase` (e.g., `telemetryhub::gateway`)

### Example

```cpp
class TelemetryQueue {
public:
    explicit TelemetryQueue(size_t max_size = 0);
    
    void push(const TelemetrySample& sample);
    void push(TelemetrySample&& sample);  // Move overload
    
    std::optional<TelemetrySample> pop();
    void shutdown();
    
private:
    std::queue<TelemetrySample> queue_;
    std::mutex mutex_;
    std::condition_variable cv_;
    size_t max_size_;
    bool shutdown_{false};
};
```

---

## Testing Requirements

All new features **must** include tests. We use Google Test for unit and integration testing.

### Test Categories

1. **Unit Tests**: Test individual functions/classes in isolation
2. **Integration Tests**: Test component interactions
3. **Concurrency Tests**: Validate thread safety with multiple producers/consumers
4. **End-to-End Tests**: Full system validation

### Writing Tests

```cpp
#include <gtest/gtest.h>
#include "telemetryhub/gateway/TelemetryQueue.h"

TEST(TelemetryQueueTest, PushAndPop) {
    TelemetryQueue q;
    
    TelemetrySample sample;
    sample.sequence_id = 42;
    sample.value = 3.14;
    sample.unit = "test";
    
    q.push(sample);
    
    auto retrieved = q.pop();
    ASSERT_TRUE(retrieved.has_value());
    EXPECT_EQ(retrieved->sequence_id, 42u);
}
```

### Running Tests

```bash
# All tests
ctest --preset linux-ninja-asan-ubsan --output-on-failure

# Specific test
ctest -R TelemetryQueueTest --output-on-failure

# With sanitizers (recommended)
cmake --preset linux-ninja-tsan
cmake --build --preset linux-ninja-tsan
ctest --preset linux-ninja-tsan
```

---

## Pull Request Process

1. **Fork and Branch**
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

2. **Write Tests First** (TDD encouraged)
   - Create test file in `tests/`
   - Write failing tests
   - Implement feature
   - Verify tests pass

3. **Update Documentation**
   - Update `CHANGELOG.md` under `[Unreleased]` section
   - Update relevant markdown files in `docs/`
   - Add code comments for complex logic

4. **Run Full Test Suite**
   ```bash
   # Linux (with sanitizers)
   cmake --preset linux-ninja-asan-ubsan
   cmake --build --preset linux-ninja-asan-ubsan
   ctest --preset linux-ninja-asan-ubsan --output-on-failure
   
   # Windows
   cmake --preset vs2022-release-ci
   cmake --build --preset vs2022-release-ci
   ctest --preset vs2022-release-ci --output-on-failure
   ```

5. **Verify CI Passes**
   - Check GitHub Actions status
   - Fix any CI failures before requesting review

6. **Create Pull Request**
   - Clear title describing the change
   - Reference any related issues
   - Provide context and motivation

---

## Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring (no functional change)
- `perf`: Performance improvements
- `chore`: Build system, dependencies, etc.
- `ci`: CI/CD configuration changes

### Examples

```
feat(gateway): add runtime configuration support

Implement INI-style config parser with support for sampling_interval,
queue_size, and log_level. Config can be loaded via --config flag.

Closes #42
```

```
fix(queue): correct bounded queue drop-oldest logic

Previous implementation dropped newest instead of oldest when queue
was full. This fix ensures oldest samples are dropped first.
```

---

## Code Review Guidelines

### For Authors

- Keep PRs focused (one feature/fix per PR)
- Respond to feedback promptly
- Be open to suggestions

### For Reviewers

- Be constructive and respectful
- Focus on code quality, not personal preferences
- Suggest alternatives when requesting changes

---

## Project Structure

```
telemetryhub/
├── device/           # Device simulation and state machine
├── gateway/          # Gateway core, queue, HTTP server
├── gui/              # Qt6 GUI application
├── tests/            # Unit and integration tests
├── tools/            # Utility tools (perf_tool, smoke tests)
├── docs/             # Documentation
├── examples/         # Usage examples
└── cmake/            # CMake modules
```

---

## Questions?

- **Open an Issue**: For bugs or feature requests
- **Discussions**: For questions or ideas

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE) file).