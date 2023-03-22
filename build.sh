#!/bin/bash

ROOT=$(pwd)
CACHE=$(pwd)/.cache
SCRIPTS_DIR=build_scripts

if [ -z "$1" ] || [ "$1" == "--help" ] || [ ! -f "$SCRIPTS_DIR/$1.sh" ]; then
    echo "Usage:"
    echo " build.sh linux"
    echo " build.sh cross-linux-mingw64"
    echo " Pass build settings as environment variables if necessary"
    exit 0
fi

function build {
    for ST in ${STEPS[@]}; do
        cd $ROOT
        echo "step: $ST"
        if [ "$(type -t check_$ST)" == "function" ]; then
            if check_$ST; then
                echo " skip"
                continue
            fi
        fi
        do_$ST
    done
}

source ./build_scripts/$1.sh

build
