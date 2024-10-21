cmake_minimum_required(VERSION 3.6.0)

project(glacier-home
    VERSION 1.0
    DESCRIPTION "Glacier UX homescreen")

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")

include(FindPkgConfig)
include(FeatureSummary)
include(GNUInstallDirs)

option(USE_SYSTEMD "Use systemd services" ON)
option(USE_GEOCLUE2 "Use geoclue2 location service. If no use classic geoclue" OFF)

set(QT_MIN_VERSION "6.2.0")
set(CMAKE_INSTALL_PREFIX /usr)
find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS
    Gui
    Qml
    Quick
    DBus
    WaylandCompositor
    LinguistTools)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIPSTICK lipstick-qt6 REQUIRED IMPORTED_TARGET)
pkg_check_modules(NEMODEVICELOCK nemodevicelock REQUIRED IMPORTED_TARGET)
pkg_check_modules(NEMOCONNECTIVITY nemoconnectivity REQUIRED IMPORTED_TARGET)
pkg_check_modules(MLITE6 mlite6 REQUIRED IMPORTED_TARGET)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(KF6BluezQt REQUIRED)

add_definitions(-DBLUEZQT_VERSION_MAJOR=${KF6BluezQt_VERSION_MAJOR})
add_definitions(-DBLUEZQT_VERSION_MINOR=${KF6BluezQt_VERSION_MINOR})

add_subdirectory(lib)
add_subdirectory(src)
add_subdirectory(settings-plugins)

if(USE_SYSTEMD)
    install(FILES data/lipstick.service DESTINATION /usr/lib/systemd/user)
endif()

install(FILES data/nemovars.conf
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/glacier-home)
install(FILES
    data/90-glacier-powerkey.conf
    data/90-glacier-devlock.conf
    DESTINATION ${CMAKE_INSTALL_FULL_SYSCONFDIR}/mce)

# Translations
file(GLOB TS_FILES translations/*.ts)
qt6_add_translation(QM_FILES ${TS_FILES})
add_custom_target(translations DEPENDS ${QM_FILES})
add_dependencies(lipstick translations)

install(FILES ${QM_FILES}
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/glacier-home/translations)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
