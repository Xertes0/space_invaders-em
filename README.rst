Space Invaders Emulator
=======================

Implements the hardware on top of my `Intel 8080 emulator library`_.

Keybinds
--------

+----------------+-------------------------------+
| Key            | Action                        |
+================+===============================+
| Return (Enter) | Insert coin                   |
+----------------+-------------------------------+
| 1              | Start the game for 1 player   |
+----------------+-------------------------------+
| 2              | Start the game for 2 players  |
+----------------+-------------------------------+
| 3              | Set ship count to 3 (default) |
+----------------+-------------------------------+
| 4              | Set ship count to 4           |
+----------------+-------------------------------+
| 5              | Set ship count to 5           |
+----------------+-------------------------------+
| 6              | Set ship count to 6           |
+----------------+-------------------------------+
| A              | 1P Move Left                  |
+----------------+-------------------------------+
| D              | 1P Move Right                 |
+----------------+-------------------------------+
| W              | 1P Shoot                      |
+----------------+-------------------------------+
| Left arrow     | 2P Move Left                  |
+----------------+-------------------------------+
| Right arrow    | 2P Move Right                 |
+----------------+-------------------------------+
| Up arrow       | 2P Shoot                      |
+----------------+-------------------------------+

ROM file
========

Place the rom file in the same directory as the executable or pass it's
path as command line argument.

This repository does not contain the rom file necessary to run this
emulator (not sure if including them would be legal). You need to find
one yourself.

ROM file format
---------------

The rom file will propably be split into 4 files ``invaders.e``,
``invaders.f``, ``invaders.g``, ``invaders.h``. You need to merge them into
one to use with this emulator.

Example command:

.. code-block:: bash

    # Mind the order
    cat ./invaders.h >  ./invaders.rom
    cat ./invaders.g >> ./invaders.rom
    cat ./invaders.f >> ./invaders.rom
    cat ./invaders.e >> ./invaders.rom

Build instructions
==================

Build prerequisites
-------------------

Build prerequisites for linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- `Conan`_ package manager
- ``SDL2``
- ``CMake``
- ``c++`` compiler
- ``ninja`` or ``make``

Build prerequisites for cross compiling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- `Conan`_ package manager
- ``MinGW gcc``
- ``CMake``
- ``ninja`` or ``make``
- ``wget``
- ``zip`` *only when packaging to a zip archive*

Compiling for linux
-------------------

.. code-block:: bash

    bash ./build.sh linux

Compiling for windows using docker
----------------------------------

.. code-block:: bash

    docker build \
        --target build-cross-linux-mingw64 \
        --tag space_inv-emu:latest .

    docker run \
        --rm \
        -v $(pwd):/work \
        space_inv-emu:latest \
        bash -c "cd /work && bash ./build.sh cross-linux-mingw64"

By default the script will pack the exe file with needed dlls to a zip
file in ``build/cross-linux-mingw64-out``. This can be disabled by
setting the ``DO_PACKAGE=false`` environment variable.

If you want the rom file to be included in the zip file use:

.. code-block:: bash

    docker run \
        --rm \
        -v $(pwd):/work \
        -v <PATH_TO_ROM>:/invaders.rom \
        space_inv-emu:latest \
        bash -c "cd /work && INVADERS_ROM_PATH=/invaders.rom bash ./build.sh cross-linux-mingw64"

Cross-compiling for windows without using docker
------------------------------------------------

If you are using debian 11, which this script was tested on you can
propably skip the following preparations

1. Make sure ``toolchains/cross-linux-mingw64.cmake`` sets the right root
   path and compilers

2. Make sure ``conan/profiles/cross-linux-mingw64`` has the right
   toolchain path and compiler version


To build and package into a zip file:

.. code-block:: bash

    bash ./build.sh cross-linux-mingw64

Optionaly set the ``INVADERS_ROM_PATH`` environment variable to include
it in the resulting zip file, which will be put in
``build/cross-linux-mingw64-out``.

.. _Intel 8080 emulator library: https://github.com/Xertes0/atat
.. _Conan: https://conan.io/
