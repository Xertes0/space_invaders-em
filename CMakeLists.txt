cmake_minimum_required(VERSION 3.20)

project(space_invaders)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(TARGETS NO_OUTPUT_DIRS)

find_package(SDL2 REQUIRED)

add_subdirectory(libatat)
add_subdirectory(space_inv)