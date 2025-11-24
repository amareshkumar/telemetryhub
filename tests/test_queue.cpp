#include "telemetryhub/gateway/TelemetryQueue.h"
#include "telemetryhub/device/TelemetrySample.h"
#include "gtest/gtest.h"

using telemetryhub::gateway::TelemetryQueue;
using telemetryhub::device::TelemetrySample;

TEST(TelemetryQueueTests, PushPopSingleThread)
{
    TelemetryQueue q;

    TelemetrySample s1;
    s1.sequence_id = 1;
    s1.value = 10.0;
    s1.unit = "u1";

    TelemetrySample s2;
    s2.sequence_id = 2;
    s2.value = 20.0;
    s2.unit = "u2";

    q.push(s1);
    q.push(s2);

    auto r1 = q.pop();
    ASSERT_TRUE(r1.has_value());
    EXPECT_EQ(r1->sequence_id, 1u);
    EXPECT_EQ(r1->value, 10.0);
    EXPECT_EQ(r1->unit, "u1");

    auto r2 = q.pop();
    ASSERT_TRUE(r2.has_value());
    EXPECT_EQ(r2->sequence_id, 2u);
    EXPECT_EQ(r2->value, 20.0);
    EXPECT_EQ(r2->unit, "u2");
}

TEST(TelemetryQueueTests, ShutdownCausesPopToReturnNulloptWhenEmpty)
{
    TelemetryQueue q;

    TelemetrySample s;
    s.sequence_id = 42;
    s.value = 123.0;
    s.unit = "demo";

    q.push(s);

    auto r1 = q.pop();
    ASSERT_TRUE(r1.has_value());
    EXPECT_EQ(r1->sequence_id, 42u);

    // Now the queue is empty; after shutdown, pop should return nullopt
    q.shutdown();

    auto r2 = q.pop();
    EXPECT_FALSE(r2.has_value());
}
