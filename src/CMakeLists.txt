set(SRC
    main.cpp
    controlcenterbuttonsmodel.cpp
    controlcenterbuttonsmodel.h
    fileutils.cpp
    fileutils.h
    glacierwindowmodel.cpp
    glacierwindowmodel.h
    mceconnect.cpp
    mceconnect.h)

#add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/geoagent.h ${CMAKE_CURRENT_SOURCE_DIR}/geoagent.cpp
#    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.GeoClue2.Agent.xml
#    COMMENT "Generate adaptors files for Dbus service"
#    COMMAND qdbusxml2cpp -l GeoclueAgent -i geoclueagent.h -a geoagent.h: ${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.GeoClue2.Agent.xml
#    COMMAND qdbusxml2cpp -i geoagent.h -l GeoclueAgent -i geoclueagent.h -a :geoagent.cpp ${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.GeoClue2.Agent.xml
#    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

#set_property(SOURCE geoagent.h PROPERTY SKIP_AUTOGEN ON)
#set_property(SOURCE geoagent.cpp PROPERTY SKIP_AUTOGEN ON)

if(USE_GEOCLUE2)
    add_compile_options(-DUSE_GEOCLUE2)

    set(GEOCLUE_SRC
        geoclueagent.cpp
        geoclueagent.h
        geoagent.cpp
        geoagent.h)
endif()

qtquick_compiler_add_resources(RESOURCES qml/glacier-home.qrc)

add_executable(lipstick ${SRC} ${GEOCLUE_SRC} ${RESOURCES})

target_link_libraries(lipstick PUBLIC
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
    PkgConfig::LIPSTICK
    PkgConfig::MLITE5
    PkgConfig::NEMODEVICELOCK)

target_link_libraries(lipstick PUBLIC
    Qt5::WaylandCompositor)

install(TARGETS lipstick RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR})

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
