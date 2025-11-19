#include <gtest/gtest.h>
#include "telemetryhub/device/Device.h"

using namespace telemetryhub::device;

TEST(DeviceTests, InitialStateIsIdle)
{
    Device dev;
    EXPECT_EQ(dev.state(), DeviceState::Idle);
}
