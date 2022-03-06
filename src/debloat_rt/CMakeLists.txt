set(CMAKE_BUILD_TYPE Debug)


add_library(debloat_rt MODULE
    debloat_rt.cpp
)

target_link_libraries(debloat_rt PRIVATE -static-libgcc -static-libstdc++)

# FIXME: commenting this out to get past compiler error; need to review the purpose/need for this
# and possibly find windows equivalent.
#set(CMAKE_CXX_FLAGS "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version")
