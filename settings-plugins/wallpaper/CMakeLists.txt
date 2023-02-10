SET(SRC wallpapersettingsplugin.cpp)
SET(HEADERS wallpapersettingsplugin.h)

SET(PLUGINS_FILES
    wallpaper.qml
    selectImage.qml
    wallpaper.svg)

set(CMAKE_AUTOMOC ON)

add_definitions(-DQT_PLUGIN)

add_library(wallpaper MODULE ${SRC} ${HEADERS})
target_include_directories(wallpaper PUBLIC "/usr/include/glacier-settings/")

target_link_libraries(wallpaper
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    -lglaciersettings)

install(TARGETS wallpaper
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/glacier-settings/)

INSTALL(FILES ${PLUGINS_FILES}
    DESTINATION /usr/share/glacier-settings/plugins/wallpaper/)

# Translations
file(GLOB TS_FILES translations/*.ts)
#set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION ${CMAKE_INSTALL_LOCALEDIR})
qt5_add_translation(QM_FILES ${TS_FILES})
add_custom_target(wallpaper_translations DEPENDS ${QM_FILES})
add_dependencies(wallpaper wallpaper_translations)

install(FILES ${QM_FILES}
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/glacier-settings/translations)
