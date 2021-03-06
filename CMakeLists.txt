cmake_minimum_required(VERSION 3.6.0)

project(glacier-home
	VERSION 0.33.0
	DESCRIPTION "Glacier UX homescreen")

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

include(FindPkgConfig)
include(FeatureSummary)
include(GNUInstallDirs)

option(USE_SYSTEMD "Use systemd services" ON)

set(QT_MIN_VERSION "5.9.0")
find_package(Qt5 ${QT_MIN_VERSION} REQUIRED COMPONENTS
	Gui
	Qml
	Quick
	DBus
	LinguistTools)
if(QT_VERSION LESS "5.11.0")
	find_package(Qt5 REQUIRED COMPONENTS Compositor)
else()
	find_package(Qt5 REQUIRED COMPONENTS WaylandCompositor)
endif()
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIPSTICK lipstick-qt5 REQUIRED IMPORTED_TARGET)
pkg_check_modules(NEMODEVICELOCK nemodevicelock REQUIRED IMPORTED_TARGET)
pkg_check_modules(MLITE5 mlite5 IMPORTED_TARGET)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(KF5 REQUIRED COMPONENTS BluezQt)

add_definitions(-DBLUEZQT_VERSION_MAJOR=${KF5BluezQt_VERSION_MAJOR})
add_definitions(-DBLUEZQT_VERSION_MINOR=${KF5BluezQt_VERSION_MINOR})

include(KDEInstallDirs)
include(KDECMakeSettings)

add_subdirectory(src)

if(USE_SYSTEMD)
	install(FILES data/lipstick.service
		DESTINATION ${SYSTEMD_USER_UNIT_INSTALL_DIR})
endif()

install(FILES data/nemovars.conf
	DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/lipstick-glacier-home-qt5)
install(FILES
		data/90-glacier-powerkey.conf
		data/90-glacier-devlock.conf
	DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/mce)

# Translations
file(GLOB TS_FILES translations/*.ts)
qt5_add_translation(QM_FILES ${TS_FILES})
add_custom_target(translations DEPENDS ${QM_FILES})
add_dependencies(lipstick translations)

install(FILES ${QM_FILES}
	DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/lipstick-glacier-home-qt5/translations)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
