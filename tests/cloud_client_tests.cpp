
#include "tests/mock_cloud_client.h"
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
        if (mock->samples.size() >= 2 && mock->statuses.size() >= 2) break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
    gw.stop();
    EXPECT_GE(mock->samples.size(), 1u);
    EXPECT_GE(mock->statuses.size(), 2u);
    // basic cadence check (loose upper bound)
    EXPECT_LE(mock->samples.size(), mock->statuses.size()*10);
}

} // namespace telemetryhub::gateway