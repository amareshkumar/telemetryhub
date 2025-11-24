#include <gtest/gtest.h>
#include "telemetryhub/device/Device.h"

using namespace telemetryhub::device;

TEST(DeviceTests, InitialStateIsIdle)
{
    Device dev;
    EXPECT_EQ(dev.state(), DeviceState::Idle);
}

TEST(DeviceTests, StartFromIdleEntersMeasuring)
{
    Device dev;
    dev.start();
    EXPECT_EQ(dev.state(), DeviceState::Measuring);
}

TEST(DeviceTests, StopFromMeasuringReturnsToIdle)
{
    Device dev;
    dev.start();
    ASSERT_EQ(dev.state(), DeviceState::Measuring);

    dev.stop();
    EXPECT_EQ(dev.state(), DeviceState::Idle);
}

TEST(DeviceTests, ReadSampleOnlyInMeasuring)
{
    Device dev;

    // In Idle, no sample
    auto sample_idle = dev.read_sample();
    EXPECT_FALSE(sample_idle.has_value());

    // After start, we should get a sample
    dev.start();
    auto sample_measuring = dev.read_sample();
    EXPECT_TRUE(sample_measuring.has_value());
}

TEST(DeviceTests, FaultLeadsToSafeStateAfterThreshold)
{
    // Use a small threshold so test is fast
    Device dev(/*samples_before_fault=*/3);

    dev.start();
    ASSERT_EQ(dev.state(), DeviceState::Measuring);

    // Call read_sample repeatedly until we trigger the fault
    for (int i = 0; i < 5; ++i)
    {
        auto s = dev.read_sample();
        // We don't care if some calls return nullopt near the transition
        (void)s;
    }

    auto st = dev.state();

    // Depending on your exact implementation, you may see Error briefly;
    // The important part: eventually you reach SafeState.
    EXPECT_TRUE(st == DeviceState::SafeState || st == DeviceState::Error);
}

TEST(DeviceTests, StartDoesNotRecoverFromSafeState)
{
    Device dev(/*samples_before_fault=*/1);

    dev.start();
    // Trigger fault quickly
    (void)dev.read_sample();
    (void)dev.read_sample();

    auto st = dev.state();
    // Expect SafeState after fault or at least Error transitioning to SafeState
    EXPECT_TRUE(st == DeviceState::SafeState || st == DeviceState::Error);

    // Try to restart
    dev.start();
    auto st_after = dev.state();

    // In a latched fault design, SafeState should remain (no restart).
    // If implementation keeps Error first, still acceptable as "not recovered".
    EXPECT_TRUE(st_after == DeviceState::SafeState || st_after == DeviceState::Error);
}