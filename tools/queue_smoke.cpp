#include "telemetryhub/gateway/TelemetryQueue.h"
#include "telemetryhub/device/TelemetrySample.h"

#include <iostream>
#include <thread>
#include <chrono>

using telemetryhub::gateway::TelemetryQueue;
using telemetryhub::device::TelemetrySample;

int main()
{
    using namespace std::chrono_literals;

    TelemetryQueue queue;

    std::thread producer([&queue] {
        for (int i = 0; i < 10; ++i)
        {
            TelemetrySample s;
            s.sequence_id = static_cast<std::uint32_t>(i);
            s.value = 100.0 + i;
            s.unit = "demo";

            std::cout << "[producer] pushing sample #" << s.sequence_id
                      << " value=" << s.value << " " << s.unit << "\n";

            queue.push(s);
            std::this_thread::sleep_for(100ms);
        }

        std::cout << "[producer] done, calling shutdown()\n";
        queue.shutdown();
    });

    std::thread consumer([&queue] {
        while (true)
        {
            auto sample_opt = queue.pop();
            if (!sample_opt)
            {
                std::cout << "[consumer] queue shutdown, exiting\n";
                break;
            }

            const auto& s = *sample_opt;
            std::cout << "[consumer] got sample #" << s.sequence_id
                      << " value=" << s.value << " " << s.unit << "\n";
        }
    });

    producer.join();
    consumer.join();

    std::cout << "queue_smoke finished.\n";
    return 0;
}
