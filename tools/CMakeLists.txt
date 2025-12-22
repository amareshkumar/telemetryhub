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

add_executable(device_state_test
    device_state_test.cpp
)

target_link_libraries(device_state_test
    PRIVATE device
)

add_executable(perf_tool
    perf_tool.cpp
)

target_link_libraries(perf_tool
    PRIVATE gateway_core
)

add_executable(device_simulator_cli
    device_simulator_cli.cpp
)

target_link_libraries(device_simulator_cli
    PRIVATE device
)

add_executable(stress_test
    stress_test.cpp
)

target_link_libraries(stress_test
    PRIVATE gateway_core
)