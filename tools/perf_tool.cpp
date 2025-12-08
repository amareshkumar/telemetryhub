#include "telemetryhub/gateway/TelemetryQueue.h"
#include "telemetryhub/device/TelemetrySample.h"

#include <chrono>
#include <cstdint>
#include <iostream>
#include <thread>

using telemetryhub::gateway::TelemetryQueue;
using telemetryhub::device::TelemetrySample;

namespace chrono = std::chrono;

struct Stats {
    double seconds{};
    std::size_t ops{};
    double ops_per_sec{};
};

Stats run_test_move(std::size_t n)
{
    TelemetryQueue q;

    auto start = chrono::steady_clock::now();

    std::thread consumer([&]() {
        std::size_t consumed = 0;
        while (consumed < n) {
            auto s = q.pop();
            if (!s) break;
            ++consumed;
        }
    });

    for (std::size_t i = 0; i < n; ++i) {
        TelemetrySample s{};
        s.sequence_id = static_cast<std::uint32_t>(i);
        s.value = 123.0 + static_cast<double>(i % 100);
        s.unit = "perf";
        q.push(std::move(s));
    }
    q.shutdown();

    consumer.join();

    auto end = chrono::steady_clock::now();
    double secs = chrono::duration<double>(end - start).count();
    return Stats{secs, n, n / secs};
}

Stats run_test_copy(std::size_t n)
{
    TelemetryQueue q;

    auto start = chrono::steady_clock::now();

    std::thread consumer([&]() {
        std::size_t consumed = 0;
        while (consumed < n) {
            auto s = q.pop();
            if (!s) break;
            ++consumed;
        }
    });

    TelemetrySample s{};
    s.unit = "perf";
    for (std::size_t i = 0; i < n; ++i) {
        s.sequence_id = static_cast<std::uint32_t>(i);
        s.value = 123.0 + static_cast<double>(i % 100);
        q.push(s);
    }
    q.shutdown();

    consumer.join();

    auto end = chrono::steady_clock::now();
    double secs = chrono::duration<double>(end - start).count();
    return Stats{secs, n, n / secs};
}

int main(int argc, char** argv)
{
    std::size_t n = 1'000'000; // default ops
    if (argc > 1) {
        try {
            n = static_cast<std::size_t>(std::stoull(argv[1]));
        } catch (...) {
            std::cerr << "Invalid N; using default " << n << "\n";
        }
    }

    std::cout << "Running perf_tool with N=" << n << "\n";

    auto copy_stats = run_test_copy(n);
    std::cout << "copy:  "
              << copy_stats.ops << " ops in " << copy_stats.seconds << " s, "
              << static_cast<long long>(copy_stats.ops_per_sec) << " ops/s\n";

    auto move_stats = run_test_move(n);
    std::cout << "move:  "
              << move_stats.ops << " ops in " << move_stats.seconds << " s, "
              << static_cast<long long>(move_stats.ops_per_sec) << " ops/s\n";

    double speedup = move_stats.ops_per_sec / copy_stats.ops_per_sec;
    std::cout << "speedup (move/copy): " << speedup << "x\n";

    return 0;
}
