SET(PLUGINNAME application)

set(SRC ${PLUGINNAME}searchplugin.cpp)
SET(HEADERS ${PLUGINNAME}searchplugin.h)

include_directories(${CMAKE_SOURCE_DIR}/lib)
set(CMAKE_AUTOMOC ON)
add_definitions(-DQT_PLUGIN)

add_library(${PLUGINNAME} MODULE ${SRC} ${HEADERS})

target_link_libraries(${PLUGINNAME} PUBLIC
    Qt6::Core
    Qt6::DBus
    GlacierHome::Search
    PkgConfig::LIPSTICK)

install(TARGETS ${PLUGINNAME}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/glacier-home/plugins/search)
