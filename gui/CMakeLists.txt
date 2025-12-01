find_package(Qt6 REQUIRED COMPONENTS Widgets Network)

add_executable(gui_app
    src/main_gui.cpp
    src/MainWindow.cpp
    src/MainWindow.h
    src/RestClient.cpp
    src/RestClient.h
)

target_link_libraries(gui_app
    PRIVATE Qt6::Widgets Qt6::Network
)
