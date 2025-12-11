#include "telemetryhub/gateway/TelemetryQueue.h"
#include <gtest/gtest.h>
#include <thread>
#include <vector>
#include <chrono>

using namespace telemetryhub::gateway;
using namespace telemetryhub::device;

class BoundedQueueTest : public ::testing::Test {
protected:
    TelemetrySample make_sample(uint32_t seq) {
        TelemetrySample s;
        s.sequence_id = seq;
        s.value = static_cast<double>(seq);
        s.unit = "test";
        s.timestamp = std::chrono::system_clock::now();
        return s;
    }
};

TEST_F(BoundedQueueTest, UnboundedQueueAcceptsAll) {
    TelemetryQueue q(0); // unbounded
    
    for (uint32_t i = 0; i < 100; ++i) {
        q.push(make_sample(i));
    }
    
    for (uint32_t i = 0; i < 100; ++i) {
        auto sample = q.pop();
        ASSERT_TRUE(sample.has_value());
        EXPECT_EQ(sample->sequence_id, i);
    }
}

TEST_F(BoundedQueueTest, BoundedQueueDropsOldest) {
    TelemetryQueue q(3); // capacity of 3
    
    q.push(make_sample(1));
    q.push(make_sample(2));
    q.push(make_sample(3));
    q.push(make_sample(4)); // should drop seq=1
    q.push(make_sample(5)); // should drop seq=2
    
    auto s1 = q.pop();
    ASSERT_TRUE(s1.has_value());
    EXPECT_EQ(s1->sequence_id, 3u);
    
    auto s2 = q.pop();
    ASSERT_TRUE(s2.has_value());
    EXPECT_EQ(s2->sequence_id, 4u);
    
    auto s3 = q.pop();
    ASSERT_TRUE(s3.has_value());
    EXPECT_EQ(s3->sequence_id, 5u);
}

TEST_F(BoundedQueueTest, BoundedQueueCapacityOne) {
    TelemetryQueue q(1); // capacity of 1
    
    q.push(make_sample(10));
    q.push(make_sample(20)); // should drop seq=10
    q.push(make_sample(30)); // should drop seq=20
    
    auto sample = q.pop();
    ASSERT_TRUE(sample.has_value());
    EXPECT_EQ(sample->sequence_id, 30u);
}

TEST_F(BoundedQueueTest, SetCapacityAtRuntime) {
    TelemetryQueue q(0); // unbounded initially
    
    q.push(make_sample(1));
    q.push(make_sample(2));
    q.push(make_sample(3));
    
    q.set_capacity(2); // now bounded to 2
    
    q.push(make_sample(4)); // should drop seq=1
    q.push(make_sample(5)); // should drop seq=2
    
    auto s1 = q.pop();
    ASSERT_TRUE(s1.has_value());
    EXPECT_EQ(s1->sequence_id, 3u);
    
    auto s2 = q.pop();
    ASSERT_TRUE(s2.has_value());
    EXPECT_EQ(s2->sequence_id, 4u);
    
    auto s3 = q.pop();
    ASSERT_TRUE(s3.has_value());
    EXPECT_EQ(s3->sequence_id, 5u);
}

TEST_F(BoundedQueueTest, ShutdownStopsAcceptingPushes) {
    TelemetryQueue q(5);
    
    q.push(make_sample(1));
    q.push(make_sample(2));
    q.shutdown();
    
    q.push(make_sample(3)); // should be rejected
    
    auto s1 = q.pop();
    ASSERT_TRUE(s1.has_value());
    EXPECT_EQ(s1->sequence_id, 1u);
    
    auto s2 = q.pop();
    ASSERT_TRUE(s2.has_value());
    EXPECT_EQ(s2->sequence_id, 2u);
    
    auto s3 = q.pop();
    EXPECT_FALSE(s3.has_value()); // shutdown and empty
}

TEST_F(BoundedQueueTest, MoveSemantics) {
    TelemetryQueue q(10);
    
    auto sample = make_sample(42);
    q.push(std::move(sample));
    
    auto retrieved = q.pop();
    ASSERT_TRUE(retrieved.has_value());
    EXPECT_EQ(retrieved->sequence_id, 42u);
}

TEST_F(BoundedQueueTest, ConcurrentProducerConsumer) {
    TelemetryQueue q(100);
    const int num_items = 1000;
    std::atomic<int> consumed{0};
    
    // Producer thread
    std::thread producer([&]() {
        for (int i = 0; i < num_items; ++i) {
            q.push(make_sample(i));
        }
        q.shutdown();
    });
    
    // Consumer thread
    std::thread consumer([&]() {
        while (true) {
            auto sample = q.pop();
            if (!sample.has_value()) break;
            consumed++;
        }
    });
    
    producer.join();
    consumer.join();
    
    // With bounded queue of 100 and 1000 pushes, some will be dropped
    // We should have consumed at most 100 items (the capacity)
    EXPECT_GT(consumed.load(), 0);
    EXPECT_EQ(consumed.load(), std::min(num_items, 100));
}

TEST_F(BoundedQueueTest, MultipleProducersOneBoundedQueue) {
    TelemetryQueue q(50);
    const int items_per_producer = 100;
    const int num_producers = 5;
    std::atomic<int> total_consumed{0};
    
    std::vector<std::thread> producers;
    for (int p = 0; p < num_producers; ++p) {
        producers.emplace_back([&, p]() {
            for (int i = 0; i < items_per_producer; ++i) {
                q.push(make_sample(p * 1000 + i));
            }
        });
    }
    
    // Consumer
    std::thread consumer([&]() {
        for (int i = 0; i < items_per_producer * num_producers; ++i) {
            auto sample = q.pop();
            if (sample.has_value()) {
                total_consumed++;
            }
        }
    });
    
    for (auto& t : producers) t.join();
    q.shutdown();
    consumer.join();
    
    // We pushed 500 items into a queue of capacity 50, so many were dropped
    EXPECT_GT(total_consumed.load(), 0);
    EXPECT_LE(total_consumed.load(), items_per_producer * num_producers);
}

TEST_F(BoundedQueueTest, EmptyQueueReturnsNulloptOnShutdown) {
    TelemetryQueue q(10);
    q.shutdown();
    
    auto sample = q.pop();
    EXPECT_FALSE(sample.has_value());
}
