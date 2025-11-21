add_library(device STATIC
    src/FileHandle.cpp    
    src/Device.cpp
    # src/DeviceConfig.cpp
)

target_include_directories(device
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(device PUBLIC cxx_std_20)
