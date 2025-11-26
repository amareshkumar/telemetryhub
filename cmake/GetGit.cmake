# cmake/GetGit.cmake
function(thub_get_git_info OUT_TAG OUT_SHA)
  set(_tag "unknown")
  set(_sha "unknown")
  find_package(Git QUIET)
  if(Git_FOUND)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE _tag
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    execute_process(
      COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE _sha
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()
  set(${OUT_TAG} "${_tag}" PARENT_SCOPE)
  set(${OUT_SHA} "${_sha}" PARENT_SCOPE)
endfunction()
