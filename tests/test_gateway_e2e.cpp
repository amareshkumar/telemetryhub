#include <gtest/gtest.h>
#include <chrono>
#include <thread>
#include "GatewayCore.h"

TEST(GatewayE2E, StartRunStop) {
  GatewayCore core;
  core.start();
  std::this_thread::sleep_for(std::chrono::milliseconds(300));
  core.stop();
  SUCCEED();
}
