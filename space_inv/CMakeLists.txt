add_executable(space_inv)

set_property(TARGET space_inv PROPERTY CXX_STANDARD 20)
set_property(TARGET space_inv PROPERTY CXX_STANDARD_REQUIRED 20)

file(GLOB_RECURSE SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc)

target_sources(space_inv PRIVATE ${SOURCES})
target_include_directories(space_inv PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

target_link_libraries(space_inv PRIVATE atat SDL2::SDL2 CONAN_PKG::fmt)