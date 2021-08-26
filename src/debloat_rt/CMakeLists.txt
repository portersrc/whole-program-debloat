set(CMAKE_BUILD_TYPE Debug)


add_library(debloat_rt MODULE
    debloat_rt.cpp
)

#target_link_options(debloat_rt PRIVATE -static-libgcc -static-libstdc++)
#target_link_options(debloat_rt PRIVATE -static-libgcc -static-libstdc++ -fvisibility=hidden)
target_link_libraries(debloat_rt PRIVATE -static-libgcc -static-libstdc++)

#set_target_properties(debloat_rt PROPERTIES CXX_VISIBILITY_PRESET hidden)

#set_target_properties(debloat_rt PROPERTIES LINK_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version)

#target_link_libraries(debloat_rt PRIVATE "-T${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version")
#target_link_options(debloat_rt PRIVATE "-T${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version")

#set(CMAKE_SHARED_LINKER_FLAGS ${CMAKE_SHARED_LINKER_FLAGS} "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version")
set(CMAKE_CXX_FLAGS "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version")
