set(SRC
	main.cpp
	fileutils.cpp
	fileutils.h
	glacierwindowmodel.cpp
	glacierwindowmodel.h
	bluetooth/bluetoothagent.cpp
	bluetooth/bluetoothagent.h)

#qt5_add_resources(RESOURCES resources-qml.qrc)

add_executable(lipstick ${SRC})

target_link_libraries(lipstick PUBLIC
	Qt5::Gui
	Qt5::Qml
	Qt5::Quick
	Qt5::DBus
	KF5::BluezQt
	PkgConfig::LIPSTICK
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

file(GLOB SETTINGS_WALLPAPERPLUGIN settings-plugins/wallpaper/*)
list(REMOVE_ITEM SETTINGS_WALLPAPERPLUGIN wallpaper.json)
install(FILES ${SETTINGS_WALLPAPERPLUGIN}
	DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/qml/plugins/wallpaper)

file(GLOB SETTINGS_NOTIFICATIONSPLUGIN settings-plugins/notifications/*)
list(REMOVE_ITEM SETTINGS_NOTIFICATIONSPLUGIN notifications.json)
install(FILES ${SETTINGS_WALLPAPERPLUGIN}
	DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/qml/plugins/notifications)

file(GLOB SETTINGS_DESKTOPPLUGIN settings-plugins/desktop/*)
list(REMOVE_ITEM SETTINGS_DESKTOPPLUGIN desktop.json)
install(FILES ${SETTINGS_WALLPAPERPLUGIN}
	DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/qml/plugins/desktop)

set(SETTINGS_PLUGINCONFIG
	settings-plugins/wallpaper/wallpaper.json
	settings-plugins/notifications/notifications.json
	settings-plugins/desktop/desktop.json)
install(FILES ${SETTINGS_PLUGINCONFIG}
	DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/plugins)
