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

add_executable(lipstick ${SRC} ${GEOCLUE_SRC})

target_link_libraries(lipstick PUBLIC
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
    PkgConfig::LIPSTICK
    PkgConfig::MLITE5
    PkgConfig::NEMODEVICELOCK)

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
