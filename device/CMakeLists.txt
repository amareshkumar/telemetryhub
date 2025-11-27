# device/CMakeLists.txt  (CMake >= 3.23 for FILE_SET)
include(${CMAKE_CURRENT_LIST_DIR}/device_files.cmake)

add_library(device ${DEVICE_SOURCES})

# Public headers visible to dependents
target_include_directories(device
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Publish public headers (good for IDE + install/export later)
target_sources(device
  PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include
    FILES ${DEVICE_PUBLIC_HEADERS}
)

# Pretty Solution Explorer folders in Visual Studio
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}
  FILES ${DEVICE_SOURCES} ${DEVICE_PUBLIC_HEADERS}
)

set_target_properties(device PROPERTIES FOLDER "telemetryhub")
target_compile_features(device PUBLIC cxx_std_20)
