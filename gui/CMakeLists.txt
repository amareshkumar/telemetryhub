# links Qt6::Widgets and Qt6::Network
cmake_minimum_required(VERSION 3.20)

# Enable Qt's automatic processing for moc/uic/rcc
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

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
