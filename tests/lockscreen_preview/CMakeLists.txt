set(PROJECT lockscreen_preview)
add_executable(${PROJECT}
    main.cpp
    ../stubs/lipsticksettings_stub.cpp
    ../stubs/lipsticksettings_stub.h
    ../stubs/wallclock_stub.cpp
    ../stubs/wallclock_stub.h)

add_compile_definitions("SOURCE_ROOT=\"${CMAKE_SOURCE_DIR}\"")

target_link_libraries(${PROJECT} PUBLIC
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Glacier::App)
