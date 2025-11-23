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

add_executable(queue_smoke
    queue_smoke.cpp
)

target_link_libraries(queue_smoke
    PRIVATE gateway_core
)