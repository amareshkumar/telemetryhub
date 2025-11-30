# CMake generated Testfile for 
# Source directory: /home/runner/work/telemetryhub/telemetryhub/tests
# Build directory: /home/runner/work/telemetryhub/telemetryhub/_codeql_build_dir/tests
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test([=[test_gateway_e2e]=] "/home/runner/work/telemetryhub/telemetryhub/_codeql_build_dir/tests/test_gateway_e2e")
set_tests_properties([=[test_gateway_e2e]=] PROPERTIES  _BACKTRACE_TRIPLES "/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;39;add_test;/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;0;")
add_test([=[unit_tests]=] "/home/runner/work/telemetryhub/telemetryhub/_codeql_build_dir/tests/unit_tests")
set_tests_properties([=[unit_tests]=] PROPERTIES  _BACKTRACE_TRIPLES "/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;56;add_test;/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;0;")
add_test([=[log_file_sink]=] "/usr/local/bin/cmake" "-DBIN_DIR=/home/runner/work/telemetryhub/telemetryhub/_codeql_build_dir" "-DCONFIG=Release" "-P" "/home/runner/work/telemetryhub/telemetryhub/tests/log_check.cmake")
set_tests_properties([=[log_file_sink]=] PROPERTIES  TIMEOUT "10" _BACKTRACE_TRIPLES "/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;61;add_test;/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;0;")
add_test([=[cloud_client_tests]=] "/home/runner/work/telemetryhub/telemetryhub/_codeql_build_dir/tests/cloud_client_tests")
set_tests_properties([=[cloud_client_tests]=] PROPERTIES  _BACKTRACE_TRIPLES "/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;70;add_test;/home/runner/work/telemetryhub/telemetryhub/tests/CMakeLists.txt;0;")
subdirs("../_deps/googletest-build")
