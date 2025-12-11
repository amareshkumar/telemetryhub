
#include "mock_cloud_client.h"
#include "telemetryhub/gateway/GatewayCore.h"
#include <gtest/gtest.h>

using namespace telemetryhub::gateway;

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
TEST(CloudClientIntegration, CadenceAndTransitions) {
    auto mock = std::make_shared<MockCloudClient>();
    telemetryhub::gateway::GatewayCore gw;
    gw.set_cloud_client(mock, 2);
    gw.start();
    auto start = std::chrono::steady_clock::now();
    while (std::chrono::steady_clock::now() - start < std::chrono::milliseconds(800)) {
        if (mock->sample_count() >= 2 && mock->status_count() >= 1) break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
    gw.stop();
    EXPECT_GE(mock->sample_count(), 1u);
    EXPECT_GE(mock->status_count(), 1u);
    // basic cadence check (loose upper bound)
    EXPECT_LE(mock->sample_count(), mock->status_count()*10);
    auto statuses = mock->statuses_snapshot();
    // Expect at least one status push for Measuring state
    ASSERT_FALSE(statuses.empty());
    EXPECT_EQ(statuses.front(), telemetryhub::device::DeviceState::Measuring);
    // When stopped externally, final state may be Idle, SafeState, or Error
    auto last = statuses.back();
    EXPECT_TRUE(last == telemetryhub::device::DeviceState::Idle || 
                last == telemetryhub::device::DeviceState::Measuring ||
                last == telemetryhub::device::DeviceState::SafeState || 
                last == telemetryhub::device::DeviceState::Error);
}

} // namespace telemetryhub::gateway