BUILD_ROOT := $(shell pwd)/build
CONAN_PROFILE := default
BUILD_TYPE := Debug
BUILD_TARGET := all
PROJECT_ROOT = $(shell pwd)
CMAKE_GENERATOR = Ninja
CMAKE_ADDITIONAL_FLAGS = ""

WINDOWS_SDL2_VERSION := "2.0.22"

all: build-linux

build-linux: BUILD_DIR="$(BUILD_ROOT)/linux"
build-linux: build_dir conan_install cmake_generate cmake_build

build-cross-mingw64: BUILD_DIR=$(BUILD_ROOT)/cross-mingw64
build-cross-mingw64: CONAN_PROFILE=$(PROJECT_ROOT)/conan/profiles/cross-linux-mingw64
build-cross-mingw64: CMAKE_TOOLCHAIN="$(PROJECT_ROOT)/toolchains/cross-linux-mingw64.cmake"
build-cross-mingw64: CMAKE_GENERATOR="Unix Makefiles"
build-cross-mingw64: CMAKE_ADDITIONAL_FLAGS+="-DSDL2_DIR=$(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2"
build-cross-mingw64: build_dir conan_install prepare_windows_sdl prepare_windows_project cmake_generate cmake_build

prepare_windows_project:
	sed -i 's|target_include_directories|target_include_directories(space_inv PRIVATE $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/include)\ntarget_include_directories|' $(PROJECT_ROOT)/space_inv/CMakeLists.txt
	sed -i 's|::stderr|stderr|' $(PROJECT_ROOT)/space_inv/include/error.hh
	sed -i 's|::stderr|stderr|' $(PROJECT_ROOT)/space_inv/src/main.cc

prepare_windows_sdl:
	cd $(shell mktemp --dir) &&\
	wget --show-progress https://www.libsdl.org/release/SDL2-devel-$(WINDOWS_SDL2_VERSION)-mingw.tar.gz -O SDL2-devel-mingw.tar.gz &&\
	tar -xf *.tar.gz &&\
	mv SDL2-$(WINDOWS_SDL2_VERSION) $(BUILD_DIR)/SDL2

	sed -i 's|set(prefix "/opt/local/x86_64-w64-mingw32")|set(prefix "/usr/x86_64-w64-mingw32")|'                  $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
	sed -i 's|set(SDL2_PREFIX "$${prefix}")|set(SDL2_PREFIX "$(BUILD_DIR)/SDL2/x86_64-w64-mingw32")|'              $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
	sed -i 's|set(SDL2_EXEC_PREFIX "$${exec_prefix}")|set(SDL2_EXEC_PREFIX "$${SDL2_PREFIX}")|'                    $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
	sed -i 's|set(SDL2_LIBDIR "$${libdir}")|set(SDL2_LIBDIR "$${SDL2_EXEC_PREFIX}/lib")|'                          $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake
	sed -i 's|set(SDL2_INCLUDE_DIRS "$${includedir}/SDL2")|set(SDL2_INCLUDE_DIRS "$${SDL2_PREFIX}/include/SDL2")|' $(BUILD_DIR)/SDL2/x86_64-w64-mingw32/lib/cmake/SDL2/sdl2-config.cmake

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