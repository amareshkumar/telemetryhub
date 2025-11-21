#include <iostream>
#include "telemetryhub/device/Device.h"

using telemetryhub::device::Device;
using telemetryhub::device::DeviceState;

int main()
{
    Device d;
    if (d.state() != DeviceState::Idle)
    {
        std::cerr << "FAIL: Expected initial state Idle, got different.\n";
        return 1;
    }

    d.start();
    if (d.state() != DeviceState::Measuring)
    {
        std::cerr << "FAIL: Expected state Measuring after start(), got different.\n";
        return 2;
    }

    std::cout << "device_state_test passed.\n";
    return 0;
}
