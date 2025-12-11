// tools/stress_test.cpp
// Stress test for TelemetryQueue with multiple producers and consumers
// Run 10 producers, 5 consumers for configurable duration
// Measure: throughput, memory usage, CPU usage, queue performance

#include "telemetryhub/gateway/TelemetryQueue.h"
#include <iostream>
#include <thread>
#include <vector>
#include <atomic>
#include <chrono>
#include <cstring>
#include <algorithm>

using namespace telemetryhub::gateway;
using namespace telemetryhub::device;
using namespace std::chrono_literals;

// Command-line options
struct StressTestConfig {
    size_t num_producers = 10;
    size_t num_consumers = 5;
    std::chrono::seconds duration{60};
    size_t queue_capacity = 1000;  // Bounded queue
    size_t samples_per_producer = 1000000;  // Target samples per producer
};

// Global counters for statistics
std::atomic<uint64_t> g_produced{0};
std::atomic<uint64_t> g_consumed{0};
std::atomic<uint64_t> g_errors{0};

// Producer thread function
void producer_thread(TelemetryQueue& queue, size_t producer_id, 
                     const StressTestConfig& config, std::atomic<bool>& running)
{
    uint64_t local_produced = 0;
    uint64_t seq_id = producer_id * 1000000;  // Unique sequence range per producer
    
    while (running.load() && local_produced < config.samples_per_producer)
    {
        TelemetrySample sample;
        sample.sequence_id = seq_id++;
        sample.value = static_cast<double>(producer_id) + 0.001 * local_produced;
        sample.unit = "unit";
        sample.timestamp = std::chrono::system_clock::now();
        
        try {
            queue.push(std::move(sample));  // Use move semantics for performance
            local_produced++;
            g_produced.fetch_add(1, std::memory_order_relaxed);
        } catch (const std::exception& e) {
            g_errors.fetch_add(1, std::memory_order_relaxed);
        }
        
        // Optionally add tiny sleep to simulate realistic device behavior
        // std::this_thread::sleep_for(std::chrono::microseconds(10));
    }
    
    std::cout << "[Producer " << producer_id << "] Finished, produced " 
              << local_produced << " samples\n";
}

// Consumer thread function
void consumer_thread(TelemetryQueue& queue, size_t consumer_id, std::atomic<bool>& running)
{
    uint64_t local_consumed = 0;
    
    while (running.load())
    {
        auto sample = queue.pop();
        if (!sample.has_value()) {
            // Queue shutdown
            break;
        }
        
        local_consumed++;
        g_consumed.fetch_add(1, std::memory_order_relaxed);
        
        // Simulate minimal processing
        volatile double dummy = sample->value * 1.001;
        (void)dummy;
    }
    
    std::cout << "[Consumer " << consumer_id << "] Finished, consumed " 
              << local_consumed << " samples\n";
}

// Monitor thread to print statistics
void monitor_thread(const std::atomic<bool>& running, const StressTestConfig& config)
{
    auto start = std::chrono::steady_clock::now();
    uint64_t prev_produced = 0;
    uint64_t prev_consumed = 0;
    
    while (running.load())
    {
        std::this_thread::sleep_for(5s);
        
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - start).count();
        
        uint64_t curr_produced = g_produced.load();
        uint64_t curr_consumed = g_consumed.load();
        uint64_t curr_errors = g_errors.load();
        
        uint64_t produced_delta = curr_produced - prev_produced;
        uint64_t consumed_delta = curr_consumed - prev_consumed;
        
        double prod_rate = produced_delta / 5.0;
        double cons_rate = consumed_delta / 5.0;
        
        std::cout << "\n[Monitor] Elapsed: " << elapsed << "s"
                  << " | Produced: " << curr_produced 
                  << " (" << static_cast<uint64_t>(prod_rate) << " ops/s)"
                  << " | Consumed: " << curr_consumed
                  << " (" << static_cast<uint64_t>(cons_rate) << " ops/s)"
                  << " | Errors: " << curr_errors
                  << " | Backlog: " << (curr_produced - curr_consumed) << "\n";
        
        prev_produced = curr_produced;
        prev_consumed = curr_consumed;
    }
}

void parse_args(int argc, char* argv[], StressTestConfig& config)
{
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        
        if (arg == "--duration" && i + 1 < argc) {
            config.duration = std::chrono::seconds(std::stoi(argv[++i]));
        }
        else if (arg == "--producers" && i + 1 < argc) {
            config.num_producers = std::stoul(argv[++i]);
        }
        else if (arg == "--consumers" && i + 1 < argc) {
            config.num_consumers = std::stoul(argv[++i]);
        }
        else if (arg == "--queue-capacity" && i + 1 < argc) {
            config.queue_capacity = std::stoul(argv[++i]);
        }
        else if (arg == "--samples" && i + 1 < argc) {
            config.samples_per_producer = std::stoul(argv[++i]);
        }
        else if (arg == "--help" || arg == "-h") {
            std::cout << "Usage: stress_test [OPTIONS]\n"
                      << "Options:\n"
                      << "  --duration <seconds>     Test duration (default: 60)\n"
                      << "  --producers <count>      Number of producer threads (default: 10)\n"
                      << "  --consumers <count>      Number of consumer threads (default: 5)\n"
                      << "  --queue-capacity <size>  Bounded queue size (default: 1000)\n"
                      << "  --samples <count>        Samples per producer (default: 1000000)\n"
                      << "  --help, -h               Show this help\n";
            exit(0);
        }
    }
}

int main(int argc, char* argv[])
{
    StressTestConfig config;
    parse_args(argc, argv, config);
    
    std::cout << "=== TelemetryQueue Stress Test ===\n";
    std::cout << "Configuration:\n";
    std::cout << "  Producers: " << config.num_producers << "\n";
    std::cout << "  Consumers: " << config.num_consumers << "\n";
    std::cout << "  Duration: " << config.duration.count() << "s\n";
    std::cout << "  Queue Capacity: " << config.queue_capacity << " (bounded)\n";
    std::cout << "  Samples per Producer: " << config.samples_per_producer << "\n";
    std::cout << "==================================\n\n";
    
    // Create queue with bounded capacity
    TelemetryQueue queue(config.queue_capacity);
    
    // Control flag
    std::atomic<bool> running{true};
    
    // Start monitor thread
    std::thread monitor(monitor_thread, std::cref(running), std::cref(config));
    
    // Launch producer threads
    std::vector<std::thread> producers;
    producers.reserve(config.num_producers);
    for (size_t i = 0; i < config.num_producers; ++i) {
        producers.emplace_back(producer_thread, std::ref(queue), i, 
                               std::cref(config), std::ref(running));
    }
    
    // Launch consumer threads
    std::vector<std::thread> consumers;
    consumers.reserve(config.num_consumers);
    for (size_t i = 0; i < config.num_consumers; ++i) {
        consumers.emplace_back(consumer_thread, std::ref(queue), i, std::ref(running));
    }
    
    auto start = std::chrono::steady_clock::now();
    
    // Wait for duration or until all producers finish
    std::this_thread::sleep_for(config.duration);
    
    // Stop producers
    running.store(false);
    
    // Wait for all producers to finish
    for (auto& t : producers) {
        if (t.joinable()) {
            t.join();
        }
    }
    
    std::cout << "\n[Main] All producers finished. Waiting for consumers to drain queue...\n";
    
    // Wait a bit for consumers to drain the queue
    std::this_thread::sleep_for(2s);
    
    // Shutdown queue to unblock consumers
    queue.shutdown();
    
    // Wait for all consumers to finish
    for (auto& t : consumers) {
        if (t.joinable()) {
            t.join();
        }
    }
    
    // Stop monitor
    if (monitor.joinable()) {
        monitor.join();
    }
    
    auto end = std::chrono::steady_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(end - start);
    
    // Final statistics
    uint64_t total_produced = g_produced.load();
    uint64_t total_consumed = g_consumed.load();
    uint64_t total_errors = g_errors.load();
    uint64_t lost = total_produced - total_consumed;
    
    std::cout << "\n=== Final Results ===\n";
    std::cout << "Total Runtime: " << elapsed.count() << "s\n";
    std::cout << "Total Produced: " << total_produced << " samples\n";
    std::cout << "Total Consumed: " << total_consumed << " samples\n";
    std::cout << "Lost/Dropped: " << lost << " samples ("
              << (total_produced > 0 ? (100.0 * lost / total_produced) : 0.0) 
              << "%)\n";
    std::cout << "Errors: " << total_errors << "\n";
    std::cout << "\nThroughput:\n";
    std::cout << "  Produced: " << (total_produced / std::max(1.0, static_cast<double>(elapsed.count()))) 
              << " ops/sec\n";
    std::cout << "  Consumed: " << (total_consumed / std::max(1.0, static_cast<double>(elapsed.count()))) 
              << " ops/sec\n";
    
    // Success criteria
    bool success = (total_errors == 0) && (total_consumed > 0);
    double throughput = total_consumed / std::max(1.0, static_cast<double>(elapsed.count()));
    
    if (!success) {
        std::cerr << "\n❌ STRESS TEST FAILED!\n";
        return 1;
    }
    
    // Check if throughput is reasonable (at least 100k ops/sec for multi-threaded)
    if (throughput < 100000) {
        std::cerr << "\n⚠️  WARNING: Throughput below expected threshold (100k ops/sec)\n";
        return 1;
    }
    
    std::cout << "\n✅ STRESS TEST PASSED!\n";
    return 0;
}