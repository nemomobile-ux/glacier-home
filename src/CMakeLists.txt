file(GLOB_RECURSE QML_JS_FILES *.qml *.js)

set(SRC
    main.cpp
    controlcenterbuttonsmodel.cpp
    controlcenterbuttonsmodel.h
    fileutils.cpp
    fileutils.h
    glacierwindowmodel.cpp
    glacierwindowmodel.h
    mceconnect.cpp
    mceconnect.h
    ${QML_JS_FILES}
    )

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

add_executable(lipstick ${SRC} ${GEOCLUE_SRC})

target_link_libraries(lipstick PUBLIC
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::DBus
    PkgConfig::LIPSTICK
    PkgConfig::MLITE6
    PkgConfig::NEMODEVICELOCK
    PkgConfig::NEMOCONNECTIVITY)

target_link_libraries(lipstick PUBLIC
        Qt6::WaylandCompositor)

install(TARGETS lipstick RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY qml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/lipstick-glacier-home-qt6)
