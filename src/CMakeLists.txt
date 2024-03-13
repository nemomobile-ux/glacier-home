file(GLOB_RECURSE QML_JS_FILES *.qml *.js)

set(SRC
    main.cpp
    audiocontrol/audioroutemanager.h
    audiocontrol/audioroutemanager.cpp
    audiocontrol/audiorouteservice.h
    audiocontrol/audiorouteservice.cpp
    audiocontrol/org.nemomobile.Route.Manager.xml
    resourcecontrol/org.maemo.resource.manager.xml
    resourcecontrol/resourcecontrolservice.cpp
    resourcecontrol/resourcecontrolservice.h
    controlcenterbuttonsmodel.cpp
    controlcenterbuttonsmodel.h
    fileutils.cpp
    fileutils.h
    glacierwindowmodel.cpp
    glacierwindowmodel.h
    mceconnect.cpp
    mceconnect.h
    logging.h
    logging.cpp
    ${QML_JS_FILES}
    )

qt_add_dbus_adaptor(SRC "${CMAKE_SOURCE_DIR}/src/audiocontrol/org.nemomobile.Route.Manager.xml"
    "audiocontrol/audiorouteservice.h"
    "AudioRouteService"
    "routemanageradaptor"
    "RouteManagerAdaptor")

qt_add_dbus_adaptor(SRC "${CMAKE_SOURCE_DIR}/src/resourcecontrol/org.maemo.resource.manager.xml"
    "resourcecontrol/resourcecontrolservice.h"
    "ResourceControlService"
    "resourcecontroladaptor"
    "ResourCecontrolAdaptor")

if(USE_GEOCLUE2)
    add_compile_options(-DUSE_GEOCLUE2)

    set(GEOCLUE_SRC
        geoclueagent.cpp
        geoclueagent.h
        geoagent.cpp
        geoagent.h)
endif()

add_executable(lipstick ${SRC} ${GEOCLUE_SRC}
    resourcecontrol/resourcecontrolmanager.h resourcecontrol/resourcecontrolmanager.cpp)

target_link_libraries(lipstick PUBLIC
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::DBus
    PkgConfig::LIPSTICK
    PkgConfig::MLITE6
    PkgConfig::NEMODEVICELOCK
    PkgConfig::NEMOCONNECTIVITY
    PkgConfig::LIBRESOURCE)

target_link_libraries(lipstick PUBLIC
        Qt6::WaylandCompositor)

install(TARGETS lipstick RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY qml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/lipstick-glacier-home-qt6)
