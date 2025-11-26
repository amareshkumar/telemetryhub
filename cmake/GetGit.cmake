# configure step to embed git info at build time.
# Runs at configure time; fills fallback if not a git repo.
function(get_git_info GIT_TAG_OUT GIT_SHA_OUT)
  set(_tag "unknown")
  set(_sha "unknown")
  find_package(Git QUIET)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE _tag OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE _sha OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
  endif()
  set(${GIT_TAG_OUT} "${_tag}" PARENT_SCOPE)
  set(${GIT_SHA_OUT} "${_sha}" PARENT_SCOPE)
endfunction()
# End of GetGit.cmake