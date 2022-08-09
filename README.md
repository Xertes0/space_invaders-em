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
- [conan](https://conan.io/) package manager
- SDL2 already installed if building for linux

## Compile for linux
``
make build-linux
``

## Cross compile for windows using docker
```bash
docker build --target build-cross-linux-mingw64 --tag space_inv-emu:latest .
docker run --rm -v $(pwd):/work space_inv-emu:latest bash -c "cd /work && make package-windows"
# Optionaly append -v PATH_TO_INVADERS_ROM:/invaders.rom to include it in the zip file
```
This will output the zip file to `build/out` directory.

## Cross compile for windows without using docker (not recommended)
To just build
```bash
make build-cross-mingw64
```

To build and package into zip file
```bash
make packge-windows
# or
make package-windows INVADERS_ROM_PATH=path_to_invaders_rom
# to include the rom file in the zip file
```
The zip file will be put in build/out/space_inv.zip