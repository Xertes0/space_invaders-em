STEPS=( make_dirs conan_install cache_sdl prepare_sdl cmake_generate cmake_build package )

DLL_LIST=( libgcc_s_seh-1.dll libstdc++-6.dll )
: ${BUILD_DIR:="$ROOT/build/cross-linux-mingw64"}
: ${CMAKE_GENERATOR:="Ninja"}
: ${BUILD_TYPE:="Release"}
: ${SDL_VERSION:="2.0.22"}
: ${CMAKE_TOOLCHAIN:="$ROOT/toolchains/cross-linux-mingw64.cmake"}
: ${CONAN_PROFILE:="$ROOT/conan/profiles/cross-linux-mingw64"}
: ${DO_PACKAGE:="true"}
: ${PACK_DIR:="$BUILD_DIR-out"}
: ${INVADERS_ROM_PATH:=""}

function check_package {
    if [ $DO_PACKAGE == "false" ] || [ ! -f "$PACK_DIR/space_inv.exe" ]; then
        return 0
    fi

    if (( $(date -r $BUILD_DIR/space_inv/space_inv.exe "+%s") > $(date -r $PACK_DIR/space_inv.exe "+%s") )); then
        return 1
    else
        return 0
    fi
}

function do_package {
    cd $PACK_DIR

	cp $BUILD_DIR/space_inv/space_inv.exe .
	cp $BUILD_DIR/SDL2/x86_64-w64-mingw32/bin/SDL2.dll .
	for DLL in ${DLL_LIST[@]}; do
		cp /usr/lib/gcc/x86_64-w64-mingw32/10-win32/$DLL .
	done

	if [ -n "$INVADERS_ROM_PATH" ]; then
		cp $INVADERS_ROM_PATH ./invaders.rom
	else
		echo "!!! INVADERS_ROM_PATH not set rom won't be included in the resulting zip file !!!"
	fi

	if [ -f $PACK_DIR/space_invaders-em.zip ]; then
		rm $PACK_DIR/space_invaders-em.zip
	fi
	zip space_invaders-em.zip ./*
}

function check_cache_sdl {
    [ -f "$CACHE/SDL2-devel-mingw.tar.gz" ]
}

function do_cache_sdl {
    cd $CACHE
    wget --show-progress https://www.libsdl.org/release/SDL2-devel-$SDL_VERSION-mingw.tar.gz -O SDL2-devel-mingw.tar.gz
}

function check_prepare_sdl {
    [ -d "$BUILD_DIR/SDL2" ]
}

function do_prepare_sdl {
    cd $BUILD_DIR
    tar -xf $CACHE/SDL2-devel-mingw.tar.gz
    mv SDL2-$SDL_VERSION SDL2

    sed -i 's|set(prefix "/opt/local/x86_64-w64-mingw32")|set(prefix "/usr/x86_64-w64-mingw32")|'           $BUILD_DIR/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
    sed -i 's|set(SDL2_PREFIX "${prefix}")|set(SDL2_PREFIX "'$BUILD_DIR'/SDL2/x86_64-w64-mingw32")|'        $BUILD_DIR/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
    sed -i 's|set(SDL2_EXEC_PREFIX "${exec_prefix}")|set(SDL2_EXEC_PREFIX "${SDL2_PREFIX}")|'               $BUILD_DIR/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
    sed -i 's|set(SDL2_LIBDIR "${libdir}")|set(SDL2_LIBDIR "${SDL2_EXEC_PREFIX}/lib")|'                     $BUILD_DIR/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
    sed -i 's|set(SDL2_INCLUDE_DIRS "${includedir}/SDL2")|set(SDL2_INCLUDE_DIRS "${SDL2_PREFIX}/include")|' $BUILD_DIR/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
}

function check_make_dirs {
    [ -d "$BUILD_DIR" ] && [ -d "$PACK_DIR" ]
}

function do_make_dirs {
    mkdir -p $BUILD_DIR
    mkdir -p $PACK_DIR
}

function check_conan_install {
    [ -f "$BUILD_DIR/conan.lock" ]
}

function do_conan_install {
    cd $BUILD_DIR
    conan install $ROOT/conan --build=missing --profile=$CONAN_PROFILE -c tools.cmake.cmaketoolchain:generator="$CMAKE_GENERATOR"
}

function check_cmake_generate {
    [ -f "$BUILD_DIR/CMakeCache.txt" ]
}

function do_cmake_generate {
    cd $BUILD_DIR
    cmake -G "$CMAKE_GENERATOR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN -DSDL2_DIR=$BUILD_DIR/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2 $ROOT
}

function do_cmake_build {
    cmake --build $BUILD_DIR --target all
}
