#include "telemetryhub/gateway/GatewayCore.h"
#include "telemetryhub/device/DeviceUtils.h"
#include "telemetryhub/gateway/Log.h"

#include <iostream>
#include <mutex>
#include <thread>
#include <chrono>
using namespace std::chrono_literals; // enable 100ms duration literal

namespace telemetryhub::gateway {

GatewayCore::GatewayCore()
    : device_{} // default Device (e.g. fault after 8 samples)
{
}

GatewayCore::~GatewayCore()
{
    stop();
}

void GatewayCore::start()
{
    bool expected = false;
    if (!running_.compare_exchange_strong(expected, true))
    {
        // already running
        return;
    }

    TELEMETRYHUB_LOGI("GatewayCore","starting device...");
    TELEMETRYHUB_LOG(::telemetryhub::LogLevel::Info, "GatewayCore", "starting device...");

    device_.start();

    producer_thread_ = std::thread(&GatewayCore::producer_loop, this);
    consumer_thread_ = std::thread(&GatewayCore::consumer_loop, this);
}

void GatewayCore::stop()
{
    bool expected = true;
    if (!running_.compare_exchange_strong(expected, false))
    {
        // already stopped
        return;
    }

    // std::cout << "[GatewayCore] stopping...\n";
    TELEMETRYHUB_LOGI("GatewayCore","stopping device...");

    // Tell queue no more pushes are coming
    
    queue_.shutdown();
    
    // Stop device if still measuring
    device_.stop();

    if (producer_thread_.joinable())
    {
        producer_thread_.join();
    }
    if (consumer_thread_.joinable())
    {
        consumer_thread_.join();
    }

    // Emit shutdown summary with gateway + queue metrics snapshot
    const auto g = metrics();
    const auto &qm = queue_.metrics();
    const auto q_pushes = qm.pushes.load(std::memory_order_relaxed);
    const auto q_pops = qm.pops.load(std::memory_order_relaxed);
    const auto q_drops = qm.drops.load(std::memory_order_relaxed);
    const auto q_hwm = qm.highWatermark.load(std::memory_order_relaxed);
    const auto q_size = queue_.size();
    const auto q_capacity = queue_.capacity();
    TELEMETRYHUB_LOGI(
        "GatewayCore",
        (std::string("[shutdown] produced=") + std::to_string(g.produced) +
         " accepted=" + std::to_string(g.accepted) +
         " consumed=" + std::to_string(g.consumed) +
         " | queue pushes=" + std::to_string(q_pushes) +
         " pops=" + std::to_string(q_pops) +
         " drops=" + std::to_string(q_drops) +
         " hwm=" + std::to_string(q_hwm) +
         " size=" + std::to_string(q_size) +
         " cap=" + std::to_string(q_capacity)).c_str());

    TELEMETRYHUB_LOGI("GatewayCore","stopped.");
}

device::DeviceState GatewayCore::device_state() const
{
    return device_.state();
}

std::optional<device::TelemetrySample> GatewayCore::latest_sample() const
{
    std::lock_guard lock(latest_mutex_);
    return latest_;
}

TelemetryQueue &GatewayCore::queue()
{
    // TODO: insert return statement here
    return queue_;
}
void GatewayCore::producer_loop()
{
    // std::cout << "[GatewayCore::producer] thread started\n";
    TELEMETRYHUB_LOGI("GatewayCore","[producer] thread started");

    while (running_)
    {
        auto state = device_.state();

        if (state != device::DeviceState::Measuring)
        {
            if (state == device::DeviceState::SafeState || state == device::DeviceState::Error)
            {
                TELEMETRYHUB_LOGI("GatewayCore", (std::string("[producer] device state=") + device::to_string(state) + ", exiting producer loop").c_str());
                break;
            }
            std::this_thread::sleep_for(100ms);
            continue;
        }

        if (auto sample_opt = device_.read_sample())
        {
            metrics_.produced.fetch_add(1, std::memory_order_relaxed);
            if (queue_.try_push(*sample_opt))
            {
                metrics_.accepted.fetch_add(1, std::memory_order_relaxed);
            }
        }
        else
        {
            std::this_thread::sleep_for(100ms);
        }
    }

    // std::cout << "[GatewayCore::producer] exiting\n";
    TELEMETRYHUB_LOGI("GatewayCore","[producer] exiting");
}

void GatewayCore::consumer_loop()
{
    // std::cout << "[GatewayCore::consumer] thread started\n";
    TELEMETRYHUB_LOGI("GatewayCore","[consumer] thread started");

    while (true)
    {
        device::TelemetrySample s{};
        if (queue_.try_pop(s, /*timeout_ms*/100))
        {
            metrics_.consumed.fetch_add(1, std::memory_order_relaxed);
            {
                std::lock_guard lock(latest_mutex_);
                latest_ = s;
            }
            TELEMETRYHUB_LOGI(
                "GatewayCore",
                (std::string("[consumer] got sample #") + std::to_string(s.sequence_id) +
                 " value=" + std::to_string(s.value) + " " + s.unit).c_str());
            continue;
        }

        // timeout: if we're stopping and the queue is empty, exit
        if (!running_ && queue_.size() == 0)
        {
            TELEMETRYHUB_LOGI("GatewayCore","[consumer] queue drained after shutdown, exiting consumer loop");
            break;
        }
    }

    // std::cout << "[GatewayCore::consumer] exiting\n";
    TELEMETRYHUB_LOGI("GatewayCore","[consumer] exiting");
}

GatewayMetrics GatewayCore::metrics() const
{
    GatewayMetrics snap;
    snap.produced = metrics_.produced.load(std::memory_order_relaxed);
    snap.accepted = metrics_.accepted.load(std::memory_order_relaxed);
    snap.consumed = metrics_.consumed.load(std::memory_order_relaxed);
    return snap;
}

}   // namespace telemetryhub::gateway 