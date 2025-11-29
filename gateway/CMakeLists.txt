add_library(gateway_core
    src/GatewayCore.cpp
    src/TelemetryQueue.cpp
    src/RestCloudClient.cpp
)

target_include_directories(gateway_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(gateway_core
    PUBLIC device
)

add_executable(gateway_app
    src/main_gateway.cpp
    src/http_server.cpp
)

target_link_libraries(gateway_app
    PRIVATE gateway_core
)
target_include_directories(gateway_app 
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}/include)
