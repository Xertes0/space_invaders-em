STEPS=( make_dirs conan_install cmake_generate cmake_build )

: ${BUILD_DIR:="$ROOT/build/linux"}
: ${CMAKE_GENERATOR:="Ninja"}
: ${BUILD_TYPE:="Release"}

function check_make_dirs {
    [ -d "$BUILD_DIR" ]
}

function do_make_dirs {
    mkdir -p $BUILD_DIR
}

function check_conan_install {
    [ -f "$BUILD_DIR/conan.lock" ]
}

function do_conan_install {
    cd $BUILD_DIR
    conan install $ROOT/conan --build=missing
}

function check_cmake_generate {
    [ -f "$BUILD_DIR/CMakeCache.txt" ]
}

function do_cmake_generate {
    cd $BUILD_DIR
    cmake -G "$CMAKE_GENERATOR" -DCMAKE_BUILD_TYPE=Release $ROOT
}

function do_cmake_build {
    cmake --build $BUILD_DIR --target all
}
