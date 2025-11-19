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

target_link_libraries(unit_tests
    PRIVATE
        device
        gateway_core
        gtest_main
)

add_test(NAME unit_tests COMMAND unit_tests)
