#pragma once

#include <atomic>
#include <condition_variable>
#include <functional>
#include <future>
#include <memory>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

namespace telemetryhub::gateway {

/**
 * @brief Simple thread pool for processing telemetry samples
 * 
 * Features:
 * - Fixed number of worker threads
 * - Job queue with FIFO processing
 * - Metrics: jobs processed, average processing time
 * - Graceful shutdown with job completion
 * 
 * Interview note: Trade-offs of thread pools
 * + Pros: Reduces thread creation overhead, limits concurrency, better CPU utilization
 * + Cons: Queue memory overhead, potential latency if workers busy, complexity
 * + When to use: High-frequency tasks, expensive thread creation, need concurrency control
 * + When NOT to use: Low task frequency, tasks block on I/O, need guaranteed low latency
 */
class ThreadPool {
public:
    /**
     * @brief Construct thread pool with N worker threads
     * @param num_threads Number of worker threads (0 = hardware concurrency)
     */
    explicit ThreadPool(size_t num_threads = 0);
    
    /**
     * @brief Destructor - waits for all jobs to complete
     */
    ~ThreadPool();

    // Non-copyable, non-movable
    ThreadPool(const ThreadPool&) = delete;
    ThreadPool& operator=(const ThreadPool&) = delete;
    ThreadPool(ThreadPool&&) = delete;
    ThreadPool& operator=(ThreadPool&&) = delete;

    /**
     * @brief Submit a job to the thread pool
     * @param job Function to execute
     * @return Future to get result
     * 
     * Example:
     *   auto future = pool.submit([](){ return 42; });
     *   int result = future.get();
     */
    template<typename F, typename... Args>
    auto submit(F&& func, Args&&... args) -> std::future<std::invoke_result_t<F, Args...>>;

    /**
     * @brief Get metrics for monitoring
     */
    struct Metrics {
        uint64_t jobs_processed{0};     ///< Total jobs completed
        uint64_t jobs_queued{0};        ///< Jobs currently in queue
        double avg_processing_ms{0.0};  ///< Average job processing time
        size_t num_threads{0};          ///< Number of worker threads
    };
    
    Metrics get_metrics() const;

    /**
     * @brief Get number of worker threads
     */
    size_t thread_count() const { return workers_.size(); }

private:
    void worker_loop();

    // Worker threads
    std::vector<std::thread> workers_;
    
    // Job queue
    std::queue<std::function<void()>> jobs_;
    mutable std::mutex queue_mutex_;
    std::condition_variable cv_;
    
    // Shutdown flag
    std::atomic<bool> stop_{false};
    
    // Metrics
    std::atomic<uint64_t> jobs_processed_{0};
    std::atomic<uint64_t> total_processing_time_us_{0};  // microseconds
};

// Template implementation must be in header
template<typename F, typename... Args>
auto ThreadPool::submit(F&& func, Args&&... args) -> std::future<std::invoke_result_t<F, Args...>>
{
    using return_type = std::invoke_result_t<F, Args...>;
    
    // Wrap in packaged_task to get future
    auto task = std::make_shared<std::packaged_task<return_type()>>(
        std::bind(std::forward<F>(func), std::forward<Args>(args)...)
    );
    
    std::future<return_type> result = task->get_future();
    
    {
        std::lock_guard lock(queue_mutex_);
        
        if (stop_) {
            throw std::runtime_error("ThreadPool is stopped, cannot submit new jobs");
        }
        
        jobs_.emplace([task]() { (*task)(); });
    }
    
    cv_.notify_one();
    return result;
}

} // namespace telemetryhub::gateway
