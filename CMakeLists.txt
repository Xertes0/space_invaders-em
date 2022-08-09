cmake_minimum_required(VERSION 3.18)

option(LTO "Enable LTO if supported on release builds" ON)

project(space_invaders CXX)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    include(CheckIPOSupported)
    check_ipo_supported(RESULT LTOSupported OUTPUT LTOError)
    if(LTOSupported)
        message(STATUS "Enabling LTO")
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        message(WARNING "LTO not supported: " ${LTOError})
    endif()
endif()

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(TARGETS NO_OUTPUT_DIRS)

find_package(SDL2 REQUIRED)

add_subdirectory(libatat)
add_subdirectory(space_inv)