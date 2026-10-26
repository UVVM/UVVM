#!/bin/bash

# compile_src.sh
# Compiles UVVM component (library or VIP).
# Usage: sh compile_src.sh <simulator> <source_dir> <target_dir>
# simulator   : ghdl, nvc, or vsim
# target_dir  : path to target directory (optional, defaults to .)

set -o errexit
SIM=$1
TARGET_DIR=$2
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    SCRIPT_DIR=$(cygpath -m ${SCRIPT_DIR})
fi
UVVM_DIR=$SCRIPT_DIR/../..

source $UVVM_DIR/script/multisim.sh

compile_component $SCRIPT_DIR/..
