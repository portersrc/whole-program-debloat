set(CMAKE_BUILD_TYPE Debug)


add_library(debloat_rt SHARED
    debloat_rt.cpp
)

# FIXME: May need to enable this. it's getting ignored i think.
#target_link_libraries(debloat_rt PRIVATE -static-libgcc -static-libstdc++)

# Not using either of these. didn't work how i expected. using declspec everywhere now.
#target_link_options(debloat_rt PRIVATE "-Wl,--export-all-symbols")
#set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOL ON)

# FIXME: commenting this out to get past compiler error; need to review the purpose/need for this
# and possibly find windows equivalent.
#set(CMAKE_CXX_FLAGS "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/libdebloatrt.version")
