# Day 08 — Version flag, Changelog, CI, and Version header flow

CLI ownership: Added --version/--help paths that execute before full init.

Build traceability: Embed semantic version + git describe tag/SHA at configure time.

Header strategy: Single source of truth—prefer repo header; generate only when missing (prevents drift).

CI hygiene: Cross-platform GitHub Actions, full history checkout for reproducible version metadata.

Windows quirk fix: Caught and corrected a function-pointer stream bug on MSVC.

**Date:** 2025-11-26  
**Scope:** `gateway_app` CLI polish (`--version`/`--help`), `CHANGELOG.md`, GitHub Actions CI, and conditional `Version.h` generation.

---

## 1) Goals
- Add `--version` and `--help` to `gateway_app` using existing `telemetryhub::print_version()` / `print_help()`.
- Introduce a standards-based `CHANGELOG.md`.
- Enable GitHub Actions (Linux + Windows) with full-history checkout and CTest.
- Keep **one** version header:
  - Use checked-in `telemetryhub/Version.h` if present.
  - Otherwise generate from `telemetryhub/Version.h.in` at configure time.

---

## 2) What changed (high level)
- **CLI:** Early flag handling in `gateway/src/main_gateway.cpp` (no heavy init before flags).
- **Docs:** `CHANGELOG.md` with `[Unreleased]`, release `0.1.1`, and release `0.1.2` entries.
- **Build:** Added `cmake/GetGit.cmake` (`thub_get_git_info()` for `git describe` + short SHA).
- **CMake:** Conditional `configure_file()` to create `build*/generated/telemetryhub/Version.h` only if repo header missing; exposed `THUB_VERSION_INCLUDE_DIR`.
- **CI:** `.github/workflows/cpp-ci.yml` builds and tests on Linux + Windows; prints `gateway_app --version`.

---

## 3) Key snippets (for quick reference)

### 3.1 Flag handling in `main_gateway.cpp`
```cpp
#include <string_view>
#include "telemetryhub/Version.h"

int main(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    std::string_view a = argv[i];
    if (a == "--version" || a == "-v") { telemetryhub::print_version(); return 0; }
    if (a == "--help"    || a == "-h") { telemetryhub::print_help(argv[0]); return 0; }
  }
  // ... normal startup
  return 0;
}


Here you go — fresh, clean, copy-paste notes for `docs/day08_notes.md`.

````md
# Day 08 — Version flag, Changelog, CI, and Version header flow

**Date:** 2025-11-26  
**Scope:** Add `--version`/`--help` to `gateway_app`, introduce `CHANGELOG.md`, wire GitHub Actions CI, and set up conditional `Version.h` generation.

---

## 1) Goals
- Add `--version` and `--help` to `gateway_app` **without** duplicating headers.
- Adopt a standards-based changelog (Keep a Changelog + SemVer).
- Configure cross-platform CI (Linux + Windows) that builds, tests, and prints version.
- Keep a **single** version header:
  - Use checked-in `telemetryhub/Version.h` if present.
  - Otherwise generate `Version.h` from `Version.h.in` at configure time.

---

## 2) What changed
- **CLI:** Early flag handling in `gateway/src/main_gateway.cpp`:
  - `-v/--version` → `telemetryhub::print_version()`
  - `-h/--help`    → `telemetryhub::print_help(argv[0])`
- **Docs:** Added `CHANGELOG.md` and released **0.1.2** with today’s work.
- **Build:** New `cmake/GetGit.cmake` (`thub_get_git_info()` = `git describe` + short SHA).
- **CMake:** Conditional header flow:
  - Prefer repo `telemetryhub/Version.h`
  - Else `configure_file(Version.h.in → build/generated/telemetryhub/Version.h @ONLY)`
  - Expose `THUB_VERSION_INCLUDE_DIR` to targets (e.g., `gateway_app`)
- **CI:** `.github/workflows/cpp-ci.yml` (Linux + Windows) → configure, build, CTest, smoke `--version`.

---

## 3) Key snippets (for reference)

### 3.1 Flag handling (gateway main)
```cpp
#include <string_view>
#include "telemetryhub/Version.h"

int main(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    std::string_view a = argv[i];
    if (a == "--version" || a == "-v") { telemetryhub::print_version(); return 0; }
    if (a == "--help"    || a == "-h") { telemetryhub::print_help(argv[0]); return 0; }
  }
  // ... normal startup
  return 0;
}
````

### 3.2 Conditional Version.h (top-level CMake)

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(GetGit)
thub_get_git_info(GIT_TAG GIT_SHA)

set(THUB_VER_SRC "${CMAKE_SOURCE_DIR}/telemetryhub/Version.h")
if(EXISTS "${THUB_VER_SRC}")
  set(THUB_VERSION_INCLUDE_DIR "${CMAKE_SOURCE_DIR}")
else()
  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/generated/telemetryhub")
  configure_file(
    "${CMAKE_SOURCE_DIR}/telemetryhub/Version.h.in"
    "${CMAKE_BINARY_DIR}/generated/telemetryhub/Version.h"
    @ONLY
  )
  set(THUB_VERSION_INCLUDE_DIR "${CMAKE_BINARY_DIR}/generated")
endif()

target_include_directories(gateway_app PRIVATE "${THUB_VERSION_INCLUDE_DIR}")
```

### 3.3 GetGit (summary)

* `git describe --tags --always --dirty` → `GIT_TAG`
* `git rev-parse --short HEAD`           → `GIT_SHA`
* Fallback to `"unknown"` when Git/metadata isn’t available.

---

## 4) Commands run

```bash
# Windows example
cmake -S . -B build_vs -G "Visual Studio 17 2022" -A x64
cmake --build build_vs --config Debug --target gateway_app
.\build_vs\gateway\Debug\gateway_app.exe --version
.\build_vs\gateway\Debug\gateway_app.exe --help

# GitHub Actions workflow
git add .github/workflows/cpp-ci.yml
git commit -m "ci: add GitHub Actions (Linux+Windows); build+CTest; smoke --version"

# Changelog + tag
git add CHANGELOG.md
git commit -m "docs(changelog): release 0.1.2"
git tag -a v0.1.2 -m "v0.1.2 — version flag, CI, conditional Version.h"
git push --follow-tags
```

---

## 5) Troubles we fixed (and how)

* **MSVC couldn’t find `print_version`/`print_help`:** generated header didn’t expose them → added same API to `Version.h.in`.
* **`operator<<` ambiguous:** accidentally streamed `telemetryhub::version` (function pointer) instead of `version()` → fixed call site.
* **Version showed `0.1.1` while git was `v0.1.2-1-g…`:** `PROJECT_VERSION` drives `project_version()` → bumped in `project(... VERSION 0.1.2)` and reconfigured.

---

## 6) Interview talking points

* **CLI polish & ownership:** early flags avoid heavy init; consistent help/version UX.
* **Traceable builds:** embed semantic version + `git describe` tag/SHA at configure time.
* **Single-source header strategy:** prefer repo header; generate only if missing (prevents drift).
* **CI hygiene:** Linux+Windows builds, tests, and version smoke check; full-history checkout for reproducible metadata.
* **Windows quirk caught & fixed:** function-pointer stream bug; reinforced careful API usage.

---

## 7) Next (Day 09 preview)

* Minimal logger (levels, timestamps, optional file).
* `--log-level` / `--log-file` flags in `gateway_app`.
* Ctrl-C graceful shutdown path via stop token.
* E2E test: start → run → stop (guards against deadlocks).
* (Optional) Linux TSan CI job.

---

```
::contentReference[oaicite:0]{index=0}
```

original plan: 
Purpose: Cloud client interface abstraction.
Benefits: decoupling, testability, swappable transports, resilience patterns (retry/backoff), CI friendliness.
Design choices: synchronous calls for now, cadence-based sample pushes, transition-based status pushes, error swallow/log in client.
Future work: batching, async queue, exponential backoff, retry budget, circuit breaker, metrics for cloud success/fail.
