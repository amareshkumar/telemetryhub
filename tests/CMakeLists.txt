include(FetchContent)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
)
FetchContent_MakeAvailable(googletest)

add_executable(unit_tests
    test_device.cpp
    test_queue.cpp
)

add_executable(raii_demo
    raii_demo.cpp
)

target_link_libraries(raii_demo
    PRIVATE device
)

add_executable(device_smoke
    device_smoke.cpp
)

target_link_libraries(device_smoke
    PRIVATE device
)

target_link_libraries(unit_tests
    PRIVATE
        device
        gateway_core
        gtest_main
)

add_test(NAME unit_tests COMMAND unit_tests)
