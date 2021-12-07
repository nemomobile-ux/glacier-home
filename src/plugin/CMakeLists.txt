### Sets QT_INSTALL_QML to the directory where QML Plugins should be installed
function(FindQtInstallQml)
    find_program(QMAKE NAMES qmake-qt5 qmake)
    if(NOT QMAKE)
    message(FATAL_ERROR "qmake not found")
    endif()
    execute_process(
        COMMAND ${QMAKE} -query QT_INSTALL_QML
        OUTPUT_VARIABLE PROC_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(QT_INSTALL_QML ${PROC_RESULT} PARENT_SCOPE)
endfunction()

set(SRC
    plugin.cpp
    ../models/controlcenterbuttonsmodel.cpp
    ../models/controlcenterbuttonsmodel.h
    ../models/glacierwindowmodel.cpp
    ../models/glacierwindowmodel.h
    ../geoclueagent.cpp
    ../geoclueagent.h
    ../geoagent.cpp
    ../geoagent.h
    ../mceconnect.cpp
    ../mceconnect.h)

add_library(glaciernemomobile SHARED ${SRC})

target_link_libraries(glaciernemomobile
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
    Qt5::WaylandCompositor
    PkgConfig::LIPSTICK
    PkgConfig::MLITE5)

FindQtInstallQml()

install(FILES qmldir DESTINATION ${QT_INSTALL_QML}/org/nemomobile/glacier/)
install(TARGETS glaciernemomobile DESTINATION ${QT_INSTALL_QML}/org/nemomobile/glacier/)
