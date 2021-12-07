set(SRC
    main.cpp
    fileutils.cpp
    fileutils.h
    widgets/swipewavewidget.cpp
    widgets/swipewavewidget.h)

#add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/geoagent.h ${CMAKE_CURRENT_SOURCE_DIR}/geoagent.cpp
#    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.GeoClue2.Agent.xml
#    COMMENT "Generate adaptors files for Dbus service"
#    COMMAND qdbusxml2cpp -l GeoclueAgent -i geoclueagent.h -a geoagent.h: ${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.GeoClue2.Agent.xml
#    COMMAND qdbusxml2cpp -i geoagent.h -l GeoclueAgent -i geoclueagent.h -a :geoagent.cpp ${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.GeoClue2.Agent.xml
#    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

#set_property(SOURCE geoagent.h PROPERTY SKIP_AUTOGEN ON)
#set_property(SOURCE geoagent.cpp PROPERTY SKIP_AUTOGEN ON)

add_executable(lipstick
    ${SRC})

target_link_libraries(lipstick PUBLIC
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
    PkgConfig::LIPSTICK
    PkgConfig::MLITE5
    PkgConfig::NEMODEVICELOCK)

add_subdirectory(plugin)

if(QT_VERSION EQUAL "5.6.0")
    target_link_libraries(lipstick PUBLIC
        Qt5::Compositor)
else()
    target_link_libraries(lipstick PUBLIC
        Qt5::WaylandCompositor)
endif()

install(TARGETS lipstick RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY qml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/lipstick-glacier-home-qt5)

file(GLOB SETTINGS_WALLPAPERPLUGIN settings-plugins/wallpaper/*)
list(REMOVE_ITEM SETTINGS_WALLPAPERPLUGIN wallpaper.json)
install(FILES ${SETTINGS_WALLPAPERPLUGIN}
    DESTINATION
    ${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/qml/plugins/wallpaper)

file(GLOB SETTINGS_DESKTOPPLUGIN settings-plugins/desktop/*)
list(REMOVE_ITEM SETTINGS_DESKTOPPLUGIN desktop.json)
install(FILES ${SETTINGS_DESKTOPPLUGIN}
    DESTINATION
    ${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/qml/plugins/desktop)

set(SETTINGS_PLUGINCONFIG
    settings-plugins/wallpaper/wallpaper.json
    settings-plugins/desktop/desktop.json)
install(FILES ${SETTINGS_PLUGINCONFIG}
    DESTINATION
    ${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/plugins)
