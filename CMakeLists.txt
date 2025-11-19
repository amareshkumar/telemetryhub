cmake_minimum_required(VERSION 3.20)
project(TelemetryHub LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Optionally: warnings, sanitizers, etc. in cmake/ConfigWarnings.cmake
# include(cmake/ConfigWarnings.cmake)

option(BUILD_GUI "Build Qt GUI" ON)
option(BUILD_TESTING "Build tests" ON)

# add_subdirectory(device)
# add_subdirectory(gateway)

if (BUILD_GUI)
    # add_subdirectory(gui)
endif()

if (BUILD_TESTING)
    # enable_testing()
    # add_subdirectory(tests)
endif()
