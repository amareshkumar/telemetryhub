#include <algorithm>
#include <chrono>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <string>
#include <vector>

// Simple TelemetrySample-like struct for perf harness purposes.
struct TelemetrySample
{
    double value;
    std::uint64_t timestamp;
};

struct RollingStats
{
    double average;
    double min;
    double max;
};

// Hot path: compute rolling average and simple min/max filter
// over a pre-populated vector of TelemetrySample.
static RollingStats compute_stats(const std::vector<TelemetrySample>& samples)
{
    if (samples.empty())
    {
        return {0.0, 0.0, 0.0};
    }

    double sum = 0.0;
    double min_v = samples.front().value;
    double max_v = samples.front().value;

    for (const auto& s : samples)
    {
        const double v = s.value;
        sum += v;
        if (v < min_v)
        {
            min_v = v;
        }
        if (v > max_v)
        {
            max_v = v;
        }
    }

    const double avg = sum / static_cast<double>(samples.size());
    return {avg, min_v, max_v};
}

int main(int argc, char** argv)
{
    // Configuration: adjust these to scale the workload.
    const std::size_t sample_count = 10'000;      // number of samples per run
    const std::size_t iterations   = 1'000;       // number of times we re-run the hot path

    std::cout << "telemetryhub perf_tool: rolling average/filter hot path\n";
    std::cout << "sample_count=" << sample_count
              << ", iterations=" << iterations << "\n";

    // Prepare a buffer of samples to simulate telemetry.
    std::vector<TelemetrySample> samples;
    samples.reserve(sample_count); // optimization candidate we can toggle

    std::mt19937_64 rng{42};
    std::uniform_real_distribution<double> dist(0.0, 100.0);

    const std::uint64_t base_ts = 1'700'000'000ULL;

    for (std::size_t i = 0; i < sample_count; ++i)
    {
        TelemetrySample s{};
        s.value = dist(rng);
        s.timestamp = base_ts + static_cast<std::uint64_t>(i);
        samples.push_back(s); // potential copy/elision optimization point
    }

    // Hot path loop: repeatedly compute stats over the same buffer.
    RollingStats last_stats{};

    auto start = std::chrono::high_resolution_clock::now();
    for (std::size_t i = 0; i < iterations; ++i)
    {
        last_stats = compute_stats(samples);
    }
    auto end = std::chrono::high_resolution_clock::now();

    const auto total_ns = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
    const double total_ms = static_cast<double>(total_ns) / 1'000'000.0;
    const double per_iter_ns = static_cast<double>(total_ns) / static_cast<double>(iterations);

    std::cout << std::fixed << std::setprecision(3);
    std::cout << "total time: " << total_ms << " ms for " << iterations << " iterations\n";
    std::cout << "per-iteration: " << per_iter_ns << " ns\n";
    std::cout << "last_stats: avg=" << last_stats.average
              << ", min=" << last_stats.min
              << ", max=" << last_stats.max << "\n";

    (void)argc;
    (void)argv;

    return 0;
}
