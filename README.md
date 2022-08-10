# Space Invaders Emulator
Implements the hardware on top of [Intel 8080 emulator library](https://github.com/Xertes0/atat)

# Keybinds
|Key|Action|
|-|-|
|Return (Enter)|Insert coin|
|1|Start the game for 1 player|
|2|Start the game for 2 players|
|3|Set ship count to 3 (default)|
|4|Set ship count to 4|
|5|Set ship count to 5|
|6|Set ship count to 6|
|A|1P Move Left|
|D|1P Move Right|
|W|1P Shoot|
|Left arrow|2P Move Left|
|Right arrow|2P Move Right|
|Up arrow|2P Shoot|

# Building from source
## Build prerequisites
### If building for linux:
- [Conan](https://conan.io/) package manager
- SDL2 devel
- cmake
- gcc compiler
- ninja or make

### If cross compiling for windows without docker:
- [Conan](https://conan.io/) package manager
- MinGW gcc and g++ compilers
- cmake
- ninja or make
- wget
- zip (if packaging to a zip file)

## Compile for linux
```bash
bash ./build.sh linux
```

## Compile for windows using docker
```bash
docker build --target build-cross-linux-mingw64 --tag space_inv-emu:latest .
docker run --rm -v $(pwd):/work space_inv-emu:latest bash -c "cd /work && bash ./build.sh cross-linux-mingw64"
```
This by default will pack the exe file with needed dlls to a zip file in `build/cross-linux-mingw64-out`  
This can be disabled by setting `DO_PACKAGE=false` environment variable  
If you want the rom file to be included in the zip file use:  
```bash
docker run --rm -v $(pwd):/work -v PATH_TO_ROM:/invaders.rom space_inv-emu:latest bash -c "cd /work && INVADERS_ROM_PATH=/invaders.rom bash ./build.sh cross-linux-mingw64"
```

## Cross compile for windows without using docker
If you are using debian 11 which this script was tested on you can propably skip the following preparations
1. Make sure `toolchains/cross-linux-mingw64.cmake` sets the right root path and compilers
2. Make sure `conan/profiles/cross-linux-mingw64` has the right toolchain path and compiler version


To build and package into a zip file
```bash
bash ./build.sh cross-linux-mingw64
```
Optionaly set `INVADERS_ROM_PATH` environment variable to include it in the resulting zip file  
The zip file will be put in `build/cross-linux-mingw64-out`
