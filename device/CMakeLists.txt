# device/CMakeLists.txt

set(DEVICE_SOURCES
    src/FileHandle.cpp    
    src/Device.cpp
    # src/DeviceConfig.cpp
)

set(DEVICE_HEADERS
  include/telemetryhub/device/Device.h
  include/telemetryhub/device/TelemetrySample.h
  include/telemetryhub/device/FileHandle.h
)

add_library (device ${DEVICE_SOURCES})

target_include_directories(device
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_sources(device
  PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include
    FILES ${DEVICE_HEADERS}
)

# Nice folders in Visual Studio Solution Explorer
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}
  FILES ${DEVICE_SOURCES} ${DEVICE_HEADERS}
)

target_compile_features(device PUBLIC cxx_std_20)