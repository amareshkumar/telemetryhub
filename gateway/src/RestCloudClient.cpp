#include "telemetryhub/gateway/RestCloudClient.h"
#include "telemetryhub/gateway/Log.h"
#include "telemetryhub/device/DeviceUtils.h"

#include <string>

using telemetryhub::device::TelemetrySample;
using telemetryhub::device::DeviceState;

namespace telemetryhub::gateway {
void RestCloudClient::push_sample(const TelemetrySample &sample)
{
    std::string msg = std::string{"{\"type\":\"sample\",\"seq\":"} +
        std::to_string(sample.sequence_id) +
        ",\"value\":" + std::to_string(sample.value) +
        ",\"unit\":\"" + sample.unit + "\"}";
    TELEMETRYHUB_LOGI("cloud", msg);
}

void RestCloudClient::push_status(DeviceState state)
{
    std::string msg = std::string{"{\"type\":\"status\",\"state\":\""} + device::to_string(state) + "\"}";
    TELEMETRYHUB_LOGI("cloud", msg);
}

} // namespace telemetryhub::gateway