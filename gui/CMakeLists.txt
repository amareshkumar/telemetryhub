find_package(Qt6 REQUIRED COMPONENTS Widgets)

add_executable(gui_app
    src/main_gui.cpp
    src/MainWindow.cpp
    src/MainWindow.h
)

target_link_libraries(gui_app
    PRIVATE Qt6::Widgets
)
