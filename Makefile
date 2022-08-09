BUILD_ROOT := $(shell pwd)/build
CONAN_PROFILE := default
BUILD_TYPE := Debug
BUILD_TARGET := all
PROJECT_ROOT = $(shell pwd)
CMAKE_GENERATOR = Ninja
CMAKE_ADDITIONAL_FLAGS =
MINGW64_BUILD_DIR = $(BUILD_ROOT)/cross-mingw64
# Not including SDL2.dll
WINDOWS_DLL_LIST = libgcc_s_seh-1.dll libstdc++-6.dll

WINDOWS_SDL2_VERSION := 2.0.22

all: build-linux

build-linux: BUILD_DIR="$(BUILD_ROOT)/linux"
build-linux: build_dir conan_install cmake_generate cmake_build

build-cross-mingw64: BUILD_DIR=$(MINGW64_BUILD_DIR)
build-cross-mingw64: CONAN_PROFILE=$(PROJECT_ROOT)/conan/profiles/cross-linux-mingw64
build-cross-mingw64: CMAKE_TOOLCHAIN="$(PROJECT_ROOT)/toolchains/cross-linux-mingw64.cmake"
build-cross-mingw64: CMAKE_GENERATOR="Unix Makefiles"
build-cross-mingw64: CMAKE_ADDITIONAL_FLAGS+="-DSDL2_DIR=$(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2"
build-cross-mingw64: build_dir conan_install prepare_windows_sdl cmake_generate cmake_build

pack-windows: build-cross-mingw64
	mkdir -p $(BUILD_ROOT)/out
	cp $(MINGW64_BUILD_DIR)/space_inv/space_inv.exe $(BUILD_ROOT)/out/
	cp $(MINGW64_BUILD_DIR)/SDL2/x86_64-w64-mingw32/bin/SDL2.dll $(BUILD_ROOT)/out/
	for NAME in $(WINDOWS_DLL_LIST) ;do\
		cp /usr/lib/gcc/x86_64-w64-mingw32/10-win32/$$NAME $(BUILD_ROOT)/out/$$NAME;\
	done
	if [ -n "$(INVADERS_ROM_PATH)" ]; then\
		cp $(INVADERS_ROM_PATH) $(BUILD_ROOT)/out/invaders.rom;\
	else\
		echo "!!! INVADERS_ROM_PATH not set rom won't be included in the resulting zip file !!!";\
	fi
	if [ -f $(BUILD_ROOT)/out/space_invaders-em.zip ]; then\
		rm $(BUILD_ROOT)/out/space_invaders-em.zip;\
	fi
	cd $(BUILD_ROOT)/out && zip space_invaders-em.zip ./*

prepare_windows_sdl:
	if [ ! -d "$(BUILD_DIR)/SDL2" ];then\
		mkdir -p $(BUILD_ROOT)/cache &&\
		cd $(BUILD_ROOT)/cache;\
		if [ ! -d "SDL2-$(WINDOWS_SDL2_VERSION)" ];then\
			wget --show-progress https://www.libsdl.org/release/SDL2-devel-$(WINDOWS_SDL2_VERSION)-mingw.tar.gz -O SDL2-devel-mingw.tar.gz &&\
			tar -xf SDL2-devel-mingw.tar.gz;\
		fi;\
		cp -r SDL2-$(WINDOWS_SDL2_VERSION) $(BUILD_DIR)/SDL2 &&\
		sed -i 's|set(prefix "/opt/local/x86_64-w64-mingw32")|set(prefix "/usr/x86_64-w64-mingw32")|'             $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake &&\
		sed -i 's|set(SDL2_PREFIX "$${prefix}")|set(SDL2_PREFIX "$(BUILD_DIR)/SDL2/x86_64-w64-mingw32")|'         $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake &&\
		sed -i 's|set(SDL2_EXEC_PREFIX "$${exec_prefix}")|set(SDL2_EXEC_PREFIX "$${SDL2_PREFIX}")|'               $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake &&\
		sed -i 's|set(SDL2_LIBDIR "$${libdir}")|set(SDL2_LIBDIR "$${SDL2_EXEC_PREFIX}/lib")|'                     $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake &&\
		sed -i 's|set(SDL2_INCLUDE_DIRS "$${includedir}/SDL2")|set(SDL2_INCLUDE_DIRS "$${SDL2_PREFIX}/include")|' $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake;\
	fi

cmake_build:
	cmake --build $(BUILD_DIR) --target $(BUILD_TARGET)

cmake_generate:
	cd $(BUILD_DIR) && cmake -G $(CMAKE_GENERATOR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_TOOLCHAIN_FILE=$(CMAKE_TOOLCHAIN) $(CMAKE_ADDITIONAL_FLAGS) $(PROJECT_ROOT)

conan_install:
	cd $(BUILD_DIR) && conan install $(PROJECT_ROOT)/conan/conanfile.txt --build=missing --profile=$(CONAN_PROFILE)

build_dir:
	mkdir -p $(BUILD_DIR)

clean:
	rm -R $(BUILD_ROOT)

.NOTPARALLEL: build-linux
.NOTPARALLEL: build-cross-mingw64