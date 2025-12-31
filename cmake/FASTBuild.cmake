# FASTBuild.cmake - Generate .bff files from CMake targets
# This module enables using FASTBuild as a distributed build executor with CMake
# 
# FASTBuild 1.18 Compatibility Notes:
# - All paths MUST be absolute (no relative paths)
# - Paths with spaces use Windows 8.3 short format (PROGRA~1) to avoid quote escaping
# - Required properties: .Librarian, .LibrarianOptions, .Linker, .LinkerOptions
# - Tokens required: /c %1 /Fo%2 (compiler), /OUT:%2 %1 (linker/librarian)
# - Library paths added via /LIBPATH: in LinkerOptions
#
# Usage:
#   include(cmake/FASTBuild.cmake)
#   thub_generate_fastbuild_config()

function(thub_generate_fastbuild_config)
    message(STATUS "Generating FASTBuild .bff configuration files...")
    
    set(FBUILD_BFF_OUTPUT "${CMAKE_BINARY_DIR}/fbuild.bff")
    set(FBUILD_COMPILER "vs2022")  # Can be overridden via cache variable
    
    # Detect Visual Studio version and path
    if(MSVC)
        if(MSVC_VERSION GREATER_EQUAL 1940)
            set(VS_VERSION "2022")
            set(VS_YEAR "2022")
        elseif(MSVC_VERSION GREATER_EQUAL 1930)
            set(VS_VERSION "2022")
            set(VS_YEAR "2022")
        else()
            set(VS_VERSION "2019")
            set(VS_YEAR "2019")
        endif()
        
        # Find Visual Studio installation
        find_program(VSWHERE_EXECUTABLE 
            NAMES vswhere.exe
            PATHS "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer"
        )
        
        if(VSWHERE_EXECUTABLE)
            execute_process(
                COMMAND "${VSWHERE_EXECUTABLE}" -latest -property installationPath
                OUTPUT_VARIABLE VS_INSTALL_PATH
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            message(STATUS "Found Visual Studio at: ${VS_INSTALL_PATH}")
        endif()
        
        # Find MSVC compiler and librarian
        get_filename_component(MSVC_COMPILER_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)
        set(MSVC_CL_PATH "${MSVC_COMPILER_DIR}/cl.exe")
        set(MSVC_LIB_PATH "${MSVC_COMPILER_DIR}/lib.exe")
        set(MSVC_LINK_PATH "${MSVC_COMPILER_DIR}/link.exe")
        
        # Get MSVC include directory
        # Path structure: <VS>/VC/Tools/MSVC/<version>/bin/<host>/<arch>/cl.exe
        # We want:        <VS>/VC/Tools/MSVC/<version>/include
        get_filename_component(MSVC_ARCH_DIR "${MSVC_COMPILER_DIR}" DIRECTORY)      # .../bin/Hostx64
        get_filename_component(MSVC_HOST_DIR "${MSVC_ARCH_DIR}" DIRECTORY)         # .../bin
        get_filename_component(MSVC_VERSION_DIR "${MSVC_HOST_DIR}" DIRECTORY)      # .../14.50.35717
        set(MSVC_INCLUDE_DIR "${MSVC_VERSION_DIR}/include")
        message(STATUS "MSVC include directory: ${MSVC_INCLUDE_DIR}")
        
        # Get Windows SDK paths
        if(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION)
            set(WIN_SDK_VERSION "${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}")
            set(WIN_SDK_BASE "$ENV{ProgramFiles\(x86\)}/Windows Kits/10")
            set(WIN_SDK_INCLUDE "${WIN_SDK_BASE}/Include/${WIN_SDK_VERSION}")
            set(WIN_SDK_LIB "${WIN_SDK_BASE}/Lib/${WIN_SDK_VERSION}")
        endif()
        
        # Build include path string for compiler options
        # Use short paths (8.3 format) to avoid issues with spaces in FASTBuild
        set(MSVC_INCLUDE_FLAGS "")
        if(EXISTS "${MSVC_INCLUDE_DIR}")
            file(TO_NATIVE_PATH "${MSVC_INCLUDE_DIR}" MSVC_INCLUDE_DIR_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${MSVC_INCLUDE_DIR_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE MSVC_INCLUDE_DIR_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${MSVC_INCLUDE_DIR_SHORT}" MSVC_INCLUDE_DIR_SHORT)
            string(APPEND MSVC_INCLUDE_FLAGS " /I${MSVC_INCLUDE_DIR_SHORT}")
            message(STATUS "Adding MSVC include path: ${MSVC_INCLUDE_DIR_SHORT}")
        else()
            message(WARNING "MSVC include directory not found: ${MSVC_INCLUDE_DIR}")
        endif()
        if(EXISTS "${WIN_SDK_INCLUDE}/ucrt")
            file(TO_NATIVE_PATH "${WIN_SDK_INCLUDE}/ucrt" WIN_SDK_UCRT_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${WIN_SDK_UCRT_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE WIN_SDK_UCRT_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${WIN_SDK_UCRT_SHORT}" WIN_SDK_UCRT_SHORT)
            string(APPEND MSVC_INCLUDE_FLAGS " /I${WIN_SDK_UCRT_SHORT}")
        endif()
        if(EXISTS "${WIN_SDK_INCLUDE}/um")
            file(TO_NATIVE_PATH "${WIN_SDK_INCLUDE}/um" WIN_SDK_UM_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${WIN_SDK_UM_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE WIN_SDK_UM_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${WIN_SDK_UM_SHORT}" WIN_SDK_UM_SHORT)
            string(APPEND MSVC_INCLUDE_FLAGS " /I${WIN_SDK_UM_SHORT}")
        endif()
        if(EXISTS "${WIN_SDK_INCLUDE}/shared")
            file(TO_NATIVE_PATH "${WIN_SDK_INCLUDE}/shared" WIN_SDK_SHARED_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${WIN_SDK_SHARED_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE WIN_SDK_SHARED_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${WIN_SDK_SHARED_SHORT}" WIN_SDK_SHARED_SHORT)
            string(APPEND MSVC_INCLUDE_FLAGS " /I${WIN_SDK_SHARED_SHORT}")
        endif()
        
        # Calculate library directories (using short paths to avoid quote issues)
        set(MSVC_LINKER_FLAGS "")
        
        # MSVC library directory
        # Path structure: <VS>/VC/Tools/MSVC/<version>/lib/<arch>
        if(EXISTS "${MSVC_VERSION_DIR}/lib/x64")
            file(TO_NATIVE_PATH "${MSVC_VERSION_DIR}/lib/x64" MSVC_LIB_DIR_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${MSVC_LIB_DIR_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE MSVC_LIB_DIR_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${MSVC_LIB_DIR_SHORT}" MSVC_LIB_DIR_SHORT)
            string(APPEND MSVC_LINKER_FLAGS " /LIBPATH:${MSVC_LIB_DIR_SHORT}")
        endif()
        
        # Windows SDK library directories
        if(EXISTS "${WIN_SDK_LIB}/ucrt/x64")
            file(TO_NATIVE_PATH "${WIN_SDK_LIB}/ucrt/x64" WIN_SDK_UCRT_LIB_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${WIN_SDK_UCRT_LIB_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE WIN_SDK_UCRT_LIB_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${WIN_SDK_UCRT_LIB_SHORT}" WIN_SDK_UCRT_LIB_SHORT)
            string(APPEND MSVC_LINKER_FLAGS " /LIBPATH:${WIN_SDK_UCRT_LIB_SHORT}")
        endif()
        
        if(EXISTS "${WIN_SDK_LIB}/um/x64")
            file(TO_NATIVE_PATH "${WIN_SDK_LIB}/um/x64" WIN_SDK_UM_LIB_NATIVE)
            execute_process(
                COMMAND cmd /c for %A in ("${WIN_SDK_UM_LIB_NATIVE}") do @echo %~sA
                OUTPUT_VARIABLE WIN_SDK_UM_LIB_SHORT
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            file(TO_CMAKE_PATH "${WIN_SDK_UM_LIB_SHORT}" WIN_SDK_UM_LIB_SHORT)
            string(APPEND MSVC_LINKER_FLAGS " /LIBPATH:${WIN_SDK_UM_LIB_SHORT}")
        endif()
        
        if(NOT EXISTS "${MSVC_LIB_PATH}")
            message(WARNING "Could not find lib.exe at ${MSVC_LIB_PATH}")
        endif()
    endif()
    
    # Generate main .bff file
    file(WRITE "${FBUILD_BFF_OUTPUT}" "// Generated by CMake - FASTBuild Configuration\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "// Generated on: ${CMAKE_CURRENT_LIST_FILE}\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "// Build directory: ${CMAKE_BINARY_DIR}\n\n")
    
    # Global settings
    file(APPEND "${FBUILD_BFF_OUTPUT}" "//==============================================================================\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "// Global Settings\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "//==============================================================================\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "Settings\n{\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "    .CachePath = '${CMAKE_BINARY_DIR}/.fbuild.cache'\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "    .Workers = { '127.0.0.1' }  // Add worker machines here\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "}\n\n")
    
    # Compiler configuration
    file(APPEND "${FBUILD_BFF_OUTPUT}" "//==============================================================================\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "// Compiler Configuration (MSVC)\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "//==============================================================================\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "Compiler('MSVC-Compiler')\n{\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "    .Executable = '${MSVC_CL_PATH}'\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "    .ExtraFiles = { '${MSVC_COMPILER_DIR}/c1.dll', '${MSVC_COMPILER_DIR}/c1xx.dll', '${MSVC_COMPILER_DIR}/c2.dll', '${MSVC_COMPILER_DIR}/mspdbcore.dll', '${MSVC_COMPILER_DIR}/mspdbsrv.exe' }\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "}\n\n")
    
    # Generate per-target configuration
    _thub_generate_library_targets("${FBUILD_BFF_OUTPUT}")
    _thub_generate_executable_targets("${FBUILD_BFF_OUTPUT}")
    
    # Generate 'all' alias
    file(APPEND "${FBUILD_BFF_OUTPUT}" "//==============================================================================\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "// Build All Alias\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "//==============================================================================\n")
    file(APPEND "${FBUILD_BFF_OUTPUT}" "Alias('all')\n{\n")
    if(TARGET gui_app)
        file(APPEND "${FBUILD_BFF_OUTPUT}" "    .Targets = { 'device', 'gateway_core', 'gateway_app', 'gui_app' }\n")
    else()
        file(APPEND "${FBUILD_BFF_OUTPUT}" "    .Targets = { 'device', 'gateway_core', 'gateway_app' }\n")
    endif()
    file(APPEND "${FBUILD_BFF_OUTPUT}" "}\n\n")
    
    message(STATUS "FASTBuild configuration written to: ${FBUILD_BFF_OUTPUT}")
    message(STATUS "To build with FASTBuild, run: fbuild -config ${FBUILD_BFF_OUTPUT}")
endfunction()

# Internal: Generate library target configurations
function(_thub_generate_library_targets BFF_FILE)
    file(APPEND "${BFF_FILE}" "//==============================================================================\n")
    file(APPEND "${BFF_FILE}" "// Library Targets\n")
    file(APPEND "${BFF_FILE}" "//==============================================================================\n")
    
    # Device library
    set(_device_compiler_opts "/std:c++20 /EHsc /W3 /O2 /DNDEBUG /I${CMAKE_SOURCE_DIR}/device/include /I${CMAKE_BINARY_DIR}/generated${MSVC_INCLUDE_FLAGS} /c %1 /Fo%2")
    file(APPEND "${BFF_FILE}" "Library('device')\n{\n")
    file(APPEND "${BFF_FILE}" "    .Compiler = 'MSVC-Compiler'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerOptions = '${_device_compiler_opts}'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerInputPath = '${CMAKE_SOURCE_DIR}/device/src'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerOutputPath = '${CMAKE_BINARY_DIR}/device'\n")
    file(APPEND "${BFF_FILE}" "    .Librarian = '${MSVC_LIB_PATH}'\n")
    file(APPEND "${BFF_FILE}" "    .LibrarianOptions = '/NOLOGO /OUT:%2 %1'\n")
    file(APPEND "${BFF_FILE}" "    .LibrarianOutput = '${CMAKE_BINARY_DIR}/device/device.lib'\n")
    file(APPEND "${BFF_FILE}" "}\n\n")
    
    # Gateway core library
    set(_gateway_core_compiler_opts "/std:c++20 /EHsc /W3 /O2 /DNDEBUG /I${CMAKE_SOURCE_DIR}/gateway/include /I${CMAKE_SOURCE_DIR}/device/include /I${CMAKE_BINARY_DIR}/generated /I${CMAKE_BINARY_DIR}/_deps/httplib_src-src${MSVC_INCLUDE_FLAGS} /c %1 /Fo%2")
    file(APPEND "${BFF_FILE}" "Library('gateway_core')\n{\n")
    file(APPEND "${BFF_FILE}" "    .Compiler = 'MSVC-Compiler'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerOptions = '${_gateway_core_compiler_opts}'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerInputFiles = { '${CMAKE_SOURCE_DIR}/gateway/src/Config.cpp', '${CMAKE_SOURCE_DIR}/gateway/src/GatewayCore.cpp', '${CMAKE_SOURCE_DIR}/gateway/src/RestCloudClient.cpp', '${CMAKE_SOURCE_DIR}/gateway/src/TelemetryQueue.cpp', '${CMAKE_SOURCE_DIR}/gateway/src/ThreadPool.cpp' }\n")
    file(APPEND "${BFF_FILE}" "    .CompilerOutputPath = '${CMAKE_BINARY_DIR}/gateway'\n")
    file(APPEND "${BFF_FILE}" "    .Librarian = '${MSVC_LIB_PATH}'\n")
    file(APPEND "${BFF_FILE}" "    .LibrarianOptions = '/NOLOGO /OUT:%2 %1'\n")
    file(APPEND "${BFF_FILE}" "    .LibrarianOutput = '${CMAKE_BINARY_DIR}/gateway/gateway_core.lib'\n")
    file(APPEND "${BFF_FILE}" "    .LibrarianAdditionalInputs = { 'device' }\n")
    file(APPEND "${BFF_FILE}" "}\n\n")
endfunction()

# Internal: Generate executable target configurations
function(_thub_generate_executable_targets BFF_FILE)
    file(APPEND "${BFF_FILE}" "//==============================================================================\n")
    file(APPEND "${BFF_FILE}" "// Executable Targets\n")
    file(APPEND "${BFF_FILE}" "//==============================================================================\n")
    
    # Gateway executable
    # First, compile the gateway app source files
    set(_gateway_app_compiler_opts "/std:c++20 /EHsc /W3 /O2 /DNDEBUG /I${CMAKE_SOURCE_DIR}/gateway/include /I${CMAKE_SOURCE_DIR}/device/include /I${CMAKE_BINARY_DIR}/generated /I${CMAKE_BINARY_DIR}/_deps/httplib_src-src${MSVC_INCLUDE_FLAGS} /c %1 /Fo%2")
    file(APPEND "${BFF_FILE}" "ObjectList('gateway_app_objs')\n{\n")
    file(APPEND "${BFF_FILE}" "    .Compiler = 'MSVC-Compiler'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerOptions = '${_gateway_app_compiler_opts}'\n")
    file(APPEND "${BFF_FILE}" "    .CompilerInputFiles = { '${CMAKE_SOURCE_DIR}/gateway/src/main_gateway.cpp', '${CMAKE_SOURCE_DIR}/gateway/src/http_server.cpp' }\n")
    file(APPEND "${BFF_FILE}" "    .CompilerOutputPath = '${CMAKE_BINARY_DIR}/gateway'\n")
    file(APPEND "${BFF_FILE}" "}\n\n")
    
    # Then link everything
    file(APPEND "${BFF_FILE}" "Executable('gateway_app')\n{\n")
    file(APPEND "${BFF_FILE}" "    .Linker = '${MSVC_LINK_PATH}'\n")
    file(APPEND "${BFF_FILE}" "    .LinkerOptions = '/NOLOGO /SUBSYSTEM:CONSOLE${MSVC_LINKER_FLAGS} /OUT:%2 %1'\n")
    file(APPEND "${BFF_FILE}" "    .LinkerOutput = '${CMAKE_BINARY_DIR}/gateway/gateway_app.exe'\n")
    file(APPEND "${BFF_FILE}" "    .Libraries = { 'gateway_app_objs', 'gateway_core', 'device' }\n")
    file(APPEND "${BFF_FILE}" "}\n\n")
    
    # GUI executable (if Qt is available)
    if(TARGET gui_app)
        file(APPEND "${BFF_FILE}" "Executable('gui_app')\n{\n")
        file(APPEND "${BFF_FILE}" "    .Compiler = 'MSVC-Compiler'\n")
        set(_gui_app_compiler_opts "/std:c++20 /EHsc /W3 /O2 /DNDEBUG /I${CMAKE_SOURCE_DIR}/gui/src${MSVC_INCLUDE_FLAGS} /c %1 /Fo%2")
        file(APPEND "${BFF_FILE}" "    .CompilerOptions = '${_gui_app_compiler_opts}'\n")
        file(APPEND "${BFF_FILE}" "    .CompilerInputPath = '${CMAKE_SOURCE_DIR}/gui/src'\n")
        file(APPEND "${BFF_FILE}" "    .CompilerOutputPath = '${CMAKE_BINARY_DIR}/gui'\n")
        file(APPEND "${BFF_FILE}" "    .Linker = '${MSVC_LINK_PATH}'\n")
        file(APPEND "${BFF_FILE}" "    .LinkerOptions = '/NOLOGO /SUBSYSTEM:WINDOWS /OUT:%2 %1'\n")
        file(APPEND "${BFF_FILE}" "    .LinkerOutput = '${CMAKE_BINARY_DIR}/gui/gui_app.exe'\n")
        file(APPEND "${BFF_FILE}" "    // Note: Qt integration requires MOC preprocessing - use CMake for full Qt builds\n")
        file(APPEND "${BFF_FILE}" "}\n\n")
    endif()
endfunction()

# Option to enable FASTBuild generation
option(THUB_ENABLE_FASTBUILD "Generate FASTBuild .bff files alongside CMake" OFF)

if(THUB_ENABLE_FASTBUILD)
    thub_generate_fastbuild_config()
endif()
