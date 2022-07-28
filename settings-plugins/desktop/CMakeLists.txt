SET(SRC desktopsettingsplugin.cpp)
SET(HEADERS desktopsettingsplugin.h)

SET(PLUGINS_FILES
    desktop.qml
    desktop.svg)

set(CMAKE_AUTOMOC ON)

add_definitions(-DQT_PLUGIN)

add_library(desktop MODULE ${SRC} ${HEADERS})
target_include_directories(desktop PUBLIC "/usr/include/glacier-settings/")

target_link_libraries(desktop
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    -lglaciersettings)

install(TARGETS desktop
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/glacier-settings/)

INSTALL(FILES ${PLUGINS_FILES}
    DESTINATION /usr/share/glacier-settings/plugins/desktop/)
