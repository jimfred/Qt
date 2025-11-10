cmake_minimum_required(VERSION 3.21.1)

project(esp32counter VERSION 0.1.0 LANGUAGES C CXX ASM)

if(NOT TARGET Qul::Core)
    find_package(Qul)
endif()

# The metadata file specifies the sources for ESP32-S3-BOX-3
# For other platforms, use generic FreeRTOS main
qul_add_target(esp32counter
    src/freertos/main.cpp
    src/freertos/countercontrol.cpp
    src/freertos/counter_threads.cpp
    QML_PROJECT
    mcu_counter.qmlproject
)

target_include_directories(esp32counter PRIVATE src src/freertos)
