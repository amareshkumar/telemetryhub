cmake_minimum_required(VERSION 3.20)

project(TelemetryHub 
    VERSION 0.8.0
    LANGUAGES CXX
)

include(CTest)

# Ensure RUN_TESTS builds test executables first (use multiline blocks to avoid parse errors)
if(TARGET RUN_TESTS AND TARGET unit_tests)
  add_dependencies(RUN_TESTS unit_tests)
endif()
if(TARGET RUN_TESTS AND TARGET test_gateway_e2e)
  add_dependencies(RUN_TESTS test_gateway_e2e)
endif()

# Include custom CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(GetGit)   # loads thub_get_git_info()

# Compute git info for generated header if needed
thub_get_git_info(GIT_TAG GIT_SHA)

# If a hand-written Version.h exists in the repo, use it.
# Otherwise, generate one into the build tree from Version.h.in
set(THUB_VERSION_HEADER_SRC "${CMAKE_SOURCE_DIR}/telemetryhub/Version.h")
if(EXISTS "${THUB_VERSION_HEADER_SRC}")
  message(STATUS "Using existing telemetryhub/Version.h from source tree.")
  set(THUB_VERSION_INCLUDE_DIR "${CMAKE_SOURCE_DIR}")  # it lives in the src tree
else()
  message(STATUS "Generating telemetryhub/Version.h from template.")
  set(THUB_VERSION_HEADER_GEN "${CMAKE_BINARY_DIR}/generated/telemetryhub/Version.h")
  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/generated/telemetryhub")
  configure_file(
    "${CMAKE_SOURCE_DIR}/telemetryhub/Version.h.in"
    "${THUB_VERSION_HEADER_GEN}"
    @ONLY
  )
  set(THUB_VERSION_INCLUDE_DIR "${CMAKE_BINARY_DIR}/generated")
endif()



# Make the chosen include dir available to everyone who needs Version.h
include_directories("${THUB_VERSION_INCLUDE_DIR}")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Optionally: warnings, sanitizers, etc. in cmake/ConfigWarnings.cmake
# include(cmake/ConfigWarnings.cmake)

# option(BUILD_GUI "Build Qt GUI" ON)
option(BUILD_TESTING "Build tests" ON)

add_subdirectory(device)
add_subdirectory(tools)
add_subdirectory(gateway)

target_include_directories(gateway_app PRIVATE "${THUB_VERSION_INCLUDE_DIR}")

# cpp-httplib integration via FetchContent
include(FetchContent)
FetchContent_Declare(
  httplib
  GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
  GIT_TAG v0.28.0
)
FetchContent_GetProperties(httplib)
# Include the fetched httplib.h in gateway_app
if(NOT httplib_POPULATED)
  FetchContent_MakeAvailable(httplib)
endif()
# Use existing httplib target if provided by FetchContent; otherwise define one
if(NOT TARGET httplib)
  add_library(httplib INTERFACE)
  # Mark as SYSTEM to avoid interfering with MSVC standard headers include order
  target_include_directories(httplib SYSTEM INTERFACE ${httplib_SOURCE_DIR})
endif()
target_link_libraries(gateway_app PRIVATE httplib)

if (BUILD_GUI)
    # add_subdirectory(gui)
endif()

if (BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
