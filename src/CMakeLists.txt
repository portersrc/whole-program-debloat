project("whole-program-debloat")
cmake_minimum_required(VERSION 3.4)
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

find_package(LLVM REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})

include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

add_subdirectory(debloat_prof)
add_subdirectory(debloat_rt)
add_subdirectory(passes)
