#pragma once

#include <string>
#include <memory>
#include <optional>
#include <nlohmann/json.hpp>

namespace telemetryhub {
namespace gateway {

/**
 * @brief Redis publisher for TelemetryHub-TelemetryTaskProcessor integration
 * 
 * Publishes TelemetrySample data as tasks to Redis for async processing
 * by TelemetryTaskProcessor workers.
 * 
 * Integration Architecture:
 * 
 *   TelemetryHub Device → TelemetryQueue → GatewayCore → RedisPublisher
 *                                                              ↓ RPUSH
 *                                                         Redis (task queue)
 *                                                              ↓ BLPOP
 *                                           TelemetryTaskProcessor Workers
 * 
 * Usage:
 *   auto publisher = std::make_unique<RedisPublisher>("127.0.0.1", 6379);
 *   if (publisher->connect()) {
 *       TelemetrySample sample = {...};
 *       publisher->publish_task(sample, "telemetry.analyze");
 *   }
 */
class RedisPublisher {
public:
    /**
     * @brief Constructor
     * @param host Redis server host
     * @param port Redis server port
     * @param queue_name Redis list key for task queue (default: "telemetry:tasks")
     */
    RedisPublisher(const std::string& host = "127.0.0.1", 
                   int port = 6379,
                   const std::string& queue_name = "telemetry:tasks");
    
    /**
     * @brief Destructor
     */
    ~RedisPublisher();
    
    /**
     * @brief Connect to Redis server
     * @return true if connection successful
     */
    bool connect();
    
    /**
     * @brief Check if connected to Redis
     */
    bool is_connected() const;
    
    /**
     * @brief Publish telemetry sample as task to Redis
     * 
     * Converts TelemetrySample to Task JSON format and pushes to Redis queue.
     * 
     * Task JSON format:
     * {
     *   "id": "uuid-v4",
     *   "type": "telemetry.analyze",
     *   "payload": {
     *     "device_id": "sensor_001",
     *     "timestamp": "2025-12-26T10:30:00Z",
     *     "temperature": 23.5,
     *     "humidity": 65.2,
     *     "pressure": 1013.25,
     *     "voltage": 3.3,
     *     "current": 0.5
     *   },
     *   "priority": "NORMAL",
     *   "max_retries": 3,
     *   "created_at": "2025-12-26T10:30:00Z"
     * }
     * 
     * @param sample TelemetrySample to publish
     * @param task_type Task type (e.g., "telemetry.analyze", "telemetry.anomaly_detect")
     * @param priority Task priority ("HIGH", "NORMAL", "LOW")
     * @param max_retries Maximum retry attempts (default: 3)
     * @return Task ID if successful, empty string if failed
     */
    std::string publish_task(const TelemetrySample& sample,
                            const std::string& task_type = "telemetry.analyze",
                            const std::string& priority = "NORMAL",
                            int max_retries = 3);
    
    /**
     * @brief Batch publish multiple telemetry samples
     * 
     * More efficient than individual publish_task calls for high throughput.
     * Uses Redis MULTI/EXEC for atomic batch insertion.
     * 
     * @param samples Vector of TelemetrySample to publish
     * @param task_type Task type for all samples
     * @return Number of successfully published tasks
     */
    size_t publish_batch(const std::vector<TelemetrySample>& samples,
                        const std::string& task_type = "telemetry.analyze");
    
    /**
     * @brief Get queue depth (number of pending tasks)
     * @return Number of tasks in queue, 0 if error
     */
    size_t get_queue_depth() const;
    
    /**
     * @brief Check if queue is healthy (not overloaded)
     * @param threshold Maximum acceptable queue depth
     * @return true if queue depth < threshold
     */
    bool is_queue_healthy(size_t threshold = 10000) const;
    
    /**
     * @brief Get publisher statistics
     */
    struct Stats {
        size_t tasks_published = 0;
        size_t tasks_failed = 0;
        size_t bytes_sent = 0;
        double avg_latency_ms = 0.0;
    };
    
    Stats get_stats() const;
    
    /**
     * @brief Reset statistics
     */
    void reset_stats();

private:
    struct Impl;
    std::unique_ptr<Impl> pimpl_;
    
    // Helper: Convert TelemetrySample to Task JSON
    nlohmann::json sample_to_task_json(const TelemetrySample& sample,
                                       const std::string& task_type,
                                       const std::string& priority,
                                       int max_retries);
    
    // Helper: Generate UUID v4
    std::string generate_uuid();
    
    // Helper: Get ISO8601 timestamp
    std::string get_iso8601_timestamp();
};

} // namespace gateway
} // namespace telemetryhub
