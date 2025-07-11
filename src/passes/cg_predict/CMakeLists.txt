add_library(CGPredictProfile MODULE
    CGPredict.cpp
    CGPredictProfile.cpp
)
add_library(CGPredictInstrument MODULE
    CGPredict.cpp
    CGPredictInstrument.cpp
)

# Use C++11 to compile your pass (i.e., supply -std=c++11).
target_compile_features(CGPredictProfile PRIVATE cxx_range_for cxx_auto_type)
target_compile_features(CGPredictInstrument PRIVATE cxx_range_for cxx_auto_type)

# LLVM is (typically) built with no C++ RTTI. We need to match that;
# otherwise, we'll get linker errors about missing RTTI data.
set_target_properties(CGPredictProfile PROPERTIES
    COMPILE_FLAGS "-fno-rtti"
)
set_target_properties(CGPredictInstrument PROPERTIES
    COMPILE_FLAGS "-fno-rtti"
)

# Get proper shared-library behavior (where symbols are not necessarily
# resolved when the shared library is linked) on OS X.
if(APPLE)
    set_target_properties(CGPredictProfile PROPERTIES
        LINK_FLAGS "-undefined dynamic_lookup"
    )
    set_target_properties(CGPredictInstrument PROPERTIES
        LINK_FLAGS "-undefined dynamic_lookup"
    )
endif(APPLE)

add_definitions(-DDEBUG_TYPE="CGPredict")
