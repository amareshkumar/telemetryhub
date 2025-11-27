#include <chrono>
#include <thread>
#include <iostream>
#include "telemetryhub/gateway/GatewayCore.h"

int main() {
  telemetryhub::gateway::GatewayCore core;
  core.start();
  std::this_thread::sleep_for(std::chrono::milliseconds(300));
  core.stop();
  std::cout << "Gateway E2E smoke passed" << std::endl;
  return 0;
}
