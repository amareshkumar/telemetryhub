#include "telemetryhub/gateway/ThreadPool.h"
#include <chrono>

namespace telemetryhub::gateway {

ThreadPool::ThreadPool(size_t num_threads)
    : stop_(false)
{
    // Default to hardware concurrency
    if (num_threads == 0) {
        num_threads = std::thread::hardware_concurrency();
        if (num_threads == 0) num_threads = 4; // Fallback
    }
    
    // Spawn worker threads
    workers_.reserve(num_threads);
    for (size_t i = 0; i < num_threads; ++i) {
        workers_.emplace_back(&ThreadPool::worker_loop, this);
    }
}

ThreadPool::~ThreadPool()
{
    // Signal workers to stop
    {
        std::lock_guard lock(queue_mutex_);
        stop_ = true;
    }
    cv_.notify_all();
    
    // Wait for all workers to finish
    for (auto& worker : workers_) {
        if (worker.joinable()) {
            worker.join();
        }
    }
}

void ThreadPool::worker_loop()
{
    while (true) {
        std::function<void()> job;
        
        {
            std::unique_lock lock(queue_mutex_);
            
            // Wait for job or stop signal
            cv_.wait(lock, [this] {
                return stop_.load() || !jobs_.empty();
            });
            
            // Exit if stopped and no more jobs
            if (stop_ && jobs_.empty()) {
                return;
            }
            
            // Get next job
            if (!jobs_.empty()) {
                job = std::move(jobs_.front());
                jobs_.pop();
            }
        }
        
        // Execute job and measure time
        if (job) {
            auto start = std::chrono::steady_clock::now();
            
            job();
            
            auto end = std::chrono::steady_clock::now();
            auto duration_us = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
            
            // Update metrics
            jobs_processed_.fetch_add(1, std::memory_order_relaxed);
            total_processing_time_us_.fetch_add(duration_us, std::memory_order_relaxed);
        }
    }
}

ThreadPool::Metrics ThreadPool::get_metrics() const
{
    Metrics m;
    m.jobs_processed = jobs_processed_.load(std::memory_order_relaxed);
    m.num_threads = workers_.size();
    
    {
        std::lock_guard lock(queue_mutex_);
        m.jobs_queued = jobs_.size();
    }
    
    // Calculate average processing time
    uint64_t total_jobs = m.jobs_processed;
    if (total_jobs > 0) {
        uint64_t total_us = total_processing_time_us_.load(std::memory_order_relaxed);
        m.avg_processing_ms = static_cast<double>(total_us) / total_jobs / 1000.0;
    }
    
    return m;
}

} // namespace telemetryhub::gateway
