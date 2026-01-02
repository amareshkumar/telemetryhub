# CI/CD Optimization Guide - TelemetryHub (Hub)

**Date:** January 2, 2026  
**Purpose:** Optimize GitHub Actions workflows with FASTBuild and improved caching

---

## 🎯 Current State vs. Optimized State

### Performance Comparison

| Job | Current Time | With Optimizations | Improvement |
|-----|-------------|-------------------|-------------|
| Linux ASAN | ~8 minutes | ~5 minutes | 37% faster |
| Windows MSVC | ~12 minutes | ~7 minutes | 42% faster |
| Windows GUI | ~15 minutes | ~9 minutes | 40% faster |
| Coverage | ~10 minutes | ~6 minutes | 40% faster |
| **Total CI Time** | **~45 minutes** | **~27 minutes** | **40% faster** |

### Optimization Strategies

1. **✅ Already Implemented:**
   - CMake presets (avoid redundant configuration)
   - Ninja generator for Linux (faster than Make)
   - Artifact caching for GUI bundle
   - Parallel builds (`-j` flag implicit in presets)

2. **🚀 Recommended Additions:**
   - ccache for Linux builds (75% faster rebuilds)
   - GitHub Actions cache for CMake dependencies
   - FASTBuild for Windows (4.3× speedup potential)
   - Matrix builds for parallel job execution

---

## 📦 Optimization 1: Add ccache (Linux)

**Benefit:** 60-75% faster incremental builds on Linux

### Update `.github/workflows/cpp-ci.yml`

Add after "Install toolchain" step in `linux` and `linux-tsan` jobs:

```yaml
      - name: Setup ccache
        uses: hendrikmuhs/ccache-action@v1.2
        with:
          key: ${{ github.job }}-${{ matrix.os }}
          max-size: 500M

      - name: Configure ccache
        run: |
          ccache --set-config=max_size=500M
          ccache --set-config=compression=true
          ccache --zero-stats
```

Add before "Tests" step:

```yaml
      - name: Show ccache stats
        run: ccache --show-stats
```

---

## 🔧 Optimization 2: CMake Dependencies Cache (All Platforms)

**Benefit:** Avoid re-downloading cpp-httplib, Catch2, etc.

### Add to all jobs:

```yaml
      - name: Cache CMake dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ github.workspace }}/build_*/external
            ${{ github.workspace }}/build_*/_deps
            ~/.cache/ccache
          key: ${{ runner.os }}-cmake-deps-${{ hashFiles('**/CMakeLists.txt', 'cmake/**') }}
          restore-keys: |
            ${{ runner.os }}-cmake-deps-
```

---

## ⚡ Optimization 3: Matrix Strategy (Parallel Jobs)

**Benefit:** Run multiple configurations simultaneously

### Replace individual jobs with matrix:

```yaml
jobs:
  build-and-test:
    name: ${{ matrix.name }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        include:
          - name: "Linux ASAN+UBSAN"
            os: ubuntu-latest
            preset: linux-ninja-asan-ubsan
            
          - name: "Linux TSAN"
            os: ubuntu-latest
            preset: linux-ninja-tsan
            
          - name: "Linux Coverage"
            os: ubuntu-latest
            preset: linux-ninja-coverage
            upload-coverage: true
            
          - name: "Windows MSVC"
            os: windows-latest
            preset: vs2022-release-ci
            
          - name: "Windows GUI"
            os: windows-latest
            preset: vs2022-gui
            needs-qt: true
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Qt (conditional)
        if: matrix.needs-qt
        uses: jurplel/install-qt-action@v4
        with:
          version: '6.8.3'
          cache: 'true'

      - name: Setup ccache (Linux only)
        if: runner.os == 'Linux'
        uses: hendrikmuhs/ccache-action@v1.2

      - name: Configure
        run: cmake --preset ${{ matrix.preset }}

      - name: Build
        run: cmake --build --preset ${{ matrix.preset }} -v

      - name: Test
        run: ctest --preset ${{ matrix.preset }} --output-on-failure

      - name: Upload coverage (conditional)
        if: matrix.upload-coverage
        uses: codecov/codecov-action@v3
```

---

## 🚀 Optimization 4: FASTBuild Integration (Optional - Advanced)

**Benefit:** 4.3× faster Windows builds (180s → 42s with 4 workers)

**Note:** Requires FASTBuild workers to be set up. Skip if not available.

### Add FASTBuild job:

```yaml
  windows-fastbuild:
    name: Windows (FASTBuild)
    runs-on: windows-latest
    if: false  # Enable when FASTBuild coordinator is available
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install FASTBuild
        run: |
          choco install fastbuild -y
          fbuild --version

      - name: Configure (FASTBuild preset)
        run: cmake --preset vs2022-fastbuild

      - name: Generate .bff files
        run: cmake --build build_fastbuild --target fbuild_config

      - name: Build with FASTBuild
        run: |
          cd build_fastbuild
          fbuild all -summary -cache -dist
          
      - name: Test
        run: ctest --preset vs2022-fastbuild --output-on-failure
```

---

## 📊 Optimization 5: Benchmark Job (Performance Regression Detection)

**Benefit:** Catch performance regressions before merge

### Add benchmark job:

```yaml
  benchmark:
    name: Performance Benchmark
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Checkout (base)
        uses: actions/checkout@v4
        with:
          ref: ${{ github.base_ref }}
          path: base

      - name: Checkout (PR)
        uses: actions/checkout@v4
        with:
          path: pr

      - name: Build base
        run: |
          cd base
          cmake --preset linux-ninja-release
          cmake --build --preset linux-ninja-release

      - name: Build PR
        run: |
          cd pr
          cmake --preset linux-ninja-release
          cmake --build --preset linux-ninja-release

      - name: Run benchmarks
        run: |
          echo "Base throughput:"
          cd base/build/tools
          ./benchmark_tool --duration 30s | tee ${{ github.workspace }}/base_results.txt
          
          echo "PR throughput:"
          cd ${{ github.workspace }}/pr/build/tools
          ./benchmark_tool --duration 30s | tee ${{ github.workspace }}/pr_results.txt

      - name: Compare results
        run: |
          BASE_THROUGHPUT=$(grep "ops/sec" base_results.txt | awk '{print $1}')
          PR_THROUGHPUT=$(grep "ops/sec" pr_results.txt | awk '{print $1}')
          
          DIFF=$(echo "scale=2; (($PR_THROUGHPUT - $BASE_THROUGHPUT) / $BASE_THROUGHPUT) * 100" | bc)
          
          echo "Performance change: ${DIFF}%"
          
          if (( $(echo "$DIFF < -10" | bc -l) )); then
            echo "::error::Performance regression detected: ${DIFF}%"
            exit 1
          fi
```

---

## 🎛️ Optimization 6: Conditional Job Execution

**Benefit:** Skip unnecessary jobs for documentation-only changes

### Add path filters:

```yaml
on:
  push:
    branches: [ main, master ]
    paths-ignore:
      - 'docs/**'
      - '**.md'
      - '.gitignore'
      - 'LICENSE'
  pull_request:
    branches: [ main, master ]
    paths-ignore:
      - 'docs/**'
      - '**.md'
```

### Add job dependencies:

```yaml
jobs:
  quick-check:
    name: Quick Syntax Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cmake --preset linux-ninja-debug
      - run: cmake --build --preset linux-ninja-debug --target gateway_app
  
  full-build:
    name: Full Build & Test
    needs: quick-check  # Only run if quick check passes
    # ... rest of job
```

---

## 📝 Complete Optimized Workflow Example

Here's how the complete workflow looks with all optimizations:

```yaml
name: C++ CI (Optimized)

on:
  push:
    branches: [ main, master ]
    paths-ignore:
      - 'docs/**'
      - '**.md'
  pull_request:
    branches: [ main, master ]

permissions:
  contents: read

jobs:
  build-and-test:
    name: ${{ matrix.name }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        include:
          - name: "Linux ASAN"
            os: ubuntu-latest
            preset: linux-ninja-asan-ubsan
            needs-ccache: true
            
          - name: "Linux Coverage"
            os: ubuntu-latest
            preset: linux-ninja-coverage
            needs-ccache: true
            upload-coverage: true
            
          - name: "Windows MSVC"
            os: windows-latest
            preset: vs2022-release-ci
            
          - name: "Windows GUI"
            os: windows-latest
            preset: vs2022-gui
            needs-qt: true

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Cache CMake dependencies
        uses: actions/cache@v4
        with:
          path: |
            ${{ github.workspace }}/build_*/external
            ${{ github.workspace }}/build_*/_deps
          key: ${{ runner.os }}-cmake-${{ hashFiles('**/CMakeLists.txt') }}

      - name: Setup ccache
        if: matrix.needs-ccache
        uses: hendrikmuhs/ccache-action@v1.2
        with:
          key: ${{ matrix.name }}

      - name: Install Qt
        if: matrix.needs-qt
        uses: jurplel/install-qt-action@v4
        with:
          version: '6.8.3'
          cache: 'true'

      - name: Configure
        run: cmake --preset ${{ matrix.preset }}

      - name: Build
        run: cmake --build --preset ${{ matrix.preset }} -v

      - name: Test
        run: ctest --preset ${{ matrix.preset }} --output-on-failure

      - name: ccache stats
        if: matrix.needs-ccache
        run: ccache --show-stats

      - name: Upload coverage
        if: matrix.upload-coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./build_coverage/coverage.info
```

---

## 📊 Expected Results

### Before Optimizations

```
Total CI time: ~45 minutes
- Linux ASAN: 8 min
- Windows MSVC: 12 min
- Windows GUI: 15 min
- Coverage: 10 min
```

### After Optimizations

```
Total CI time: ~27 minutes (40% faster)
- Linux ASAN: 5 min (ccache + parallel)
- Windows MSVC: 7 min (CMake cache + parallel)
- Windows GUI: 9 min (Qt cache + parallel)
- Coverage: 6 min (ccache + parallel)
```

### Cost Savings

- **Developer time saved:** 18 minutes per CI run
- **GitHub Actions minutes saved:** 18 minutes × 10 PRs/day = 180 minutes/day
- **Monthly savings:** 5,400 minutes (~90 hours) of CI time

---

## 🚀 Implementation Plan

### Phase 1: Quick Wins (30 minutes)

1. ✅ Add ccache for Linux (5 min)
2. ✅ Add CMake dependencies cache (5 min)
3. ✅ Add path filters (5 min)
4. ✅ Test on PR (15 min)

### Phase 2: Matrix Strategy (1 hour)

1. Convert jobs to matrix (30 min)
2. Test all configurations (30 min)

### Phase 3: Advanced (Optional)

1. Set up FASTBuild coordinator (2-3 hours)
2. Add benchmark job (1 hour)
3. Fine-tune caching strategies (1 hour)

---

## 🔍 Monitoring & Validation

### Track CI Performance

Add to workflow:

```yaml
      - name: CI Timing Summary
        if: always()
        run: |
          echo "::notice::Job completed in ${{ job.status }} after $SECONDS seconds"
```

### Create Dashboard

Use GitHub Insights → Actions to track:
- Average job duration
- Success rate
- Cache hit rate

---

## 📚 References

- **ccache docs:** https://ccache.dev/
- **GitHub Actions cache:** https://docs.github.com/en/actions/using-workflows/caching-dependencies
- **FASTBuild:** [fastbuild_guide.md](fastbuild_guide.md)
- **CMake presets:** [CMakePresets.json](../CMakePresets.json)

---

**Status:** ✅ Optimizations documented, ready to implement  
**Last Updated:** January 2, 2026  
**Author:** Amaresh Kumar
