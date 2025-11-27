# tests/CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
include(CTest)
if(NOT BUILD_TESTING)
  return()
endif()

include(FetchContent)

set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

FetchContent_MakeAvailable(googletest)

# Bring in the gtest helpers (defines gtest_discover_tests)
include(GoogleTest)

# Example: gateway E2E test
add_executable(test_gateway_e2e
  ${CMAKE_CURRENT_SOURCE_DIR}/test_gateway_e2e.cpp
)

target_link_libraries(test_gateway_e2e
  PRIVATE
    gateway_core               # your library/target under test
)
target_compile_features(test_gateway_e2e PRIVATE cxx_std_20)
add_test(NAME test_gateway_e2e COMMAND test_gateway_e2e)

add_executable(unit_tests
    test_device.cpp
    test_queue.cpp
)

# add_executable(raii_demo
#     raii_demo.cpp
# )

# target_link_libraries(raii_demo
#     PRIVATE device
# )

# add_executable(device_smoke
#     device_smoke.cpp
# )

# target_link_libraries(device_smoke
#     PRIVATE device
# )

target_link_libraries(unit_tests
    PRIVATE
        device
        gateway_core
  GTest::gtest
  GTest::gtest_main
)

target_compile_features(unit_tests PRIVATE cxx_std_20)

add_test(
    NAME unit_tests
    COMMAND unit_tests
)
# add_test(NAME telemetryhub_tests COMMAND telemetryhub_tests)
add_test(
  NAME log_file_sink
  COMMAND ${CMAKE_COMMAND}
          -DBIN_DIR=${CMAKE_BINARY_DIR}
          -DCONFIG=$<CONFIG>
          -P ${CMAKE_CURRENT_SOURCE_DIR}/log_check.cmake
)
set_tests_properties(log_file_sink PROPERTIES TIMEOUT 10)