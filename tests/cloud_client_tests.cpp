
#include "tests/mock_cloud_client.h"
#include <gtest/gtest.h>

namespace telemetryhub::gateway {

TEST(MockCloudClientTest, PushSampleAndStatus)
{
    MockCloudClient mockClient;

    telemetryhub::device::TelemetrySample sample;
    sample.sequence_id = 1;
    sample.value = 42.0;
    sample.unit = "unitless";

    // Test push_sample
    EXPECT_NO_THROW(mockClient.push_sample(sample));

    // Test push_status
    EXPECT_NO_THROW(mockClient.push_status(telemetryhub::device::DeviceState::Measuring));
}

TEST(MockCloudClientTest, MultipleSamples)
{
    MockCloudClient mockClient;

    for (uint32_t i = 0; i < 10; ++i)
    {
        telemetryhub::device::TelemetrySample sample;
        sample.sequence_id = i;
        sample.value = static_cast<double>(i) * 1.1;
        sample.unit = "unitless";

        EXPECT_NO_THROW(mockClient.push_sample(sample));
    }
}

//use EXPECT_GE and small bounds rather than exact counts.


} // namespace telemetryhub::gateway