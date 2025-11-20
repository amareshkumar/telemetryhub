add_executable(raii_demo
    raii_demo.cpp
)

target_link_libraries(raii_demo
    PRIVATE device
)
