#include "RestCloudClient.h"
#include "telemetryhub/gateway/Log.h"

#include <string>

using telemetryhub::device::TelemetrySample;
using telemetryhub::device::DeviceState;

namespace telemetryhub::gateway {
void RestCloudClient::push_sample(const TelemetrySample &sample)
{
    TELEMETRYHUB_LOGI("cloud", 
    std::string{"{\"type\":\"sample\",\"seq\":"} + std::to_string(sample.sequence) +
    ",\"value\":" + std::to_string(sample.value) + "}" );
}

void RestCloudClient::push_status(DeviceState state)
{
    TELEMETRYHUB_LOGI("cloud",
    std::string{"{\"type\":\"status\",\"state\":\""} + to_string(state) + "\"}" );
}

} // namespace telemetryhub::gateway