# tests/log_check.cmake
# Inputs:
#   -DBIN_DIR=...   (CMake binary dir, passed from add_test)
#   -DCONFIG=...    (empty on single-config; Debug/Release on MSVC)

if(NOT DEFINED BIN_DIR)
  message(FATAL_ERROR "BIN_DIR not set")
endif()

# Build candidate paths for the gateway_app executable
set(EXE_CANDIDATES
  "${BIN_DIR}/gateway/gateway_app"                          # Linux/MinGW single-config
  "${BIN_DIR}/gateway/${CONFIG}/gateway_app.exe"            # MSVC multi-config
  "${BIN_DIR}/gateway/Debug/gateway_app.exe"                # fallback
  "${BIN_DIR}/gateway/Release/gateway_app.exe"              # fallback
)

set(GATEWAY_APP "")
foreach(p IN LISTS EXE_CANDIDATES)
  if(EXISTS "${p}")
    set(GATEWAY_APP "${p}")
    break()
  endif()
endforeach()

if(GATEWAY_APP STREQUAL "")
  message(FATAL_ERROR "gateway_app not found. Checked:\n  ${EXE_CANDIDATES}")
endif()

# Log file path (in build dir)
set(LOG_FILE "${BIN_DIR}/thub.ci.log")
file(REMOVE "${LOG_FILE}")

# Run the app at TRACE and write to file
execute_process(
  COMMAND "${GATEWAY_APP}" --log-level trace --log-file "${LOG_FILE}" --version
  WORKING_DIRECTORY "${BIN_DIR}"
  TIMEOUT 5
  RESULT_VARIABLE run_rc
)

if(NOT run_rc EQUAL 0)
  message(FATAL_ERROR "gateway_app exited with code ${run_rc}")
endif()

# Verify the file was created and has expected content
if(NOT EXISTS "${LOG_FILE}")
  message(FATAL_ERROR "log file not created: ${LOG_FILE}")
endif()

file(READ "${LOG_FILE}" LOGTXT)

string(FIND "${LOGTXT}" "logger online (console)" POS_INFO)
string(FIND "${LOGTXT}" "debug visible only at --log-level debug+" POS_DBG)
string(FIND "${LOGTXT}" "trace visible only at --log-level trace" POS_TR)

if(POS_INFO EQUAL -1 OR POS_DBG EQUAL -1 OR POS_TR EQUAL -1)
  message(FATAL_ERROR "expected logger lines not found in ${LOG_FILE}")
endif()
