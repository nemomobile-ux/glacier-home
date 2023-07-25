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
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    -lglaciersettings)

install(TARGETS desktop
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/glacier-settings/)

INSTALL(FILES ${PLUGINS_FILES}
    DESTINATION /usr/share/glacier-settings/plugins/desktop/)

# Translations
file(GLOB TS_FILES translations/*.ts)
#set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION ${CMAKE_INSTALL_LOCALEDIR})
qt6_add_translation(QM_FILES ${TS_FILES})
add_custom_target(desktop_translations DEPENDS ${QM_FILES})
add_dependencies(desktop desktop_translations)

install(FILES ${QM_FILES}
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/translations)
