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
option(USE_HTTPLIB_STUB "Use local httplib stub instead of real cpp-httplib" ON)
target_include_directories(gateway_app PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/external/httplib
)
if(USE_HTTPLIB_STUB)
    target_compile_definitions(gateway_app PRIVATE USE_HTTPLIB_STUB=1)
endif()
