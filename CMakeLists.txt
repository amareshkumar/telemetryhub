cmake_minimum_required(VERSION 3.20)

project(TelemetryHub 
    VERSION 0.8.0
    LANGUAGES CXX
)

include(CTest)

# Sanitize environment to avoid MSYS headers/libs leaking into MSVC builds
foreach(_var IN ITEMS INCLUDE LIB LIBPATH CPATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH C_INCLUDE_PATH)
  if(DEFINED ENV{${_var}})
    string(FIND "$ENV{${_var}}" "msys64" _msys_pos)
    if(_msys_pos GREATER -1)
      message(WARNING "Detected MSYS in $ENV{${_var}}; clearing for this configure to protect MSVC build.")
      unset(ENV{${_var}})
    endif()
  endif()
endforeach()

# In addition, prevent CMake find_* from consulting system environment paths
set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH OFF)
# And ignore common MSYS roots so generated projects don't pick them up
list(APPEND CMAKE_SYSTEM_IGNORE_PATH "C:/msys64" "C:/msys64/ucrt64" "C:/msys64/mingw64" 
                                  "C:/msys64/usr" 
                                  "/msys64" "/usr" "/usr/local")

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
## Prevent MSVC from emitting /external:I entries for system includes, which
## can accidentally pick up MSYS include paths from the environment.
set(CMAKE_MSVC_INCLUDE_EXTERNAL_HEADERS OFF)

# Optionally: warnings, sanitizers, etc. in cmake/ConfigWarnings.cmake
# include(cmake/ConfigWarnings.cmake)

# option(BUILD_GUI "Build Qt GUI" ON)
option(BUILD_TESTING "Build tests" ON)

add_subdirectory(device)
add_subdirectory(tools)
add_subdirectory(gateway)

target_include_directories(gateway_app PRIVATE "${THUB_VERSION_INCLUDE_DIR}")

# cpp-httplib integration via FetchContent, but avoid its CMake logic
include(FetchContent)

FetchContent_Declare(
  httplib_src
  GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
  GIT_TAG v0.28.0
)
FetchContent_GetProperties(httplib_src)
if(NOT httplib_src_POPULATED)
  FetchContent_Populate(httplib_src)
endif()

# Define a simple INTERFACE target that points to the header path
add_library(httplib INTERFACE)
target_include_directories(httplib INTERFACE ${httplib_src_SOURCE_DIR})
target_link_libraries(gateway_app PRIVATE httplib)
## Hard-disable optional cpp-httplib features that may inject unwanted libs/defs
target_compile_definitions(gateway_app PRIVATE 
  CPPHTTPLIB_ZSTD_SUPPORT=0 
  CPPHTTPLIB_USE_NON_BLOCKING_GETADDRINFO=0
  CPPHTTPLIB_NO_ZSTD=1
  CPPHTTPLIB_NO_BROTLI=1
  CPPHTTPLIB_NO_ZLIB=1
  CPPHTTPLIB_NO_OPENSSL=1
)

if (BUILD_GUI)
    # add_subdirectory(gui)
endif()

if (BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
