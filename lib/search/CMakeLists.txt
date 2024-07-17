set(PROJECT glacierhomesearch)

set(SRC
    searchpluginmanager.h
    searchpluginmanager.cpp)

set(PUBLIC_HEADERS
    glaciersearchplugin.h)

include_directories(${CMAKE_SOURCE_DIR}/src)

add_library(${PROJECT} SHARED ${SRC} ${HEADERS} ${PUBLIC_HEADERS})
add_library(GlacierHome::Search ALIAS ${PROJECT})

target_link_libraries(${PROJECT}
    Qt6::Core)

set_target_properties(${PROJECT} PROPERTIES VERSION 0.1 SOVERSION 0)
add_definitions( -DINSTALL_LIBDIR="${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
add_subdirectory(plugins)

install(TARGETS ${PROJECT}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/)

install(FILES ${PUBLIC_HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/glacier-home)
