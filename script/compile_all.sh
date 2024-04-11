#!/bin/zsh

# compile_all.sh
# Compiles all UVVM libraries and VIPs.
# Usage: sh compile_all.sh <simulator> <target_dir>
# simulator  : ghdl, nvc, vsim or xsim
#            : Note that current UVVM support in Xsim is limited.
# target_dir : path to target directory (optional, defaults to .)

set -o errexit
SIM=$1
TARGET_DIR=$2
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    SCRIPT_DIR=$(cygpath -m ${SCRIPT_DIR})
fi
UVVM_DIR=$SCRIPT_DIR/..

source $UVVM_DIR/script/multisim.sh

component_list=$(tr -d '\r' <$UVVM_DIR/script/component_list.txt | tr '\n' ' ')
for component in $component_list; do
    compile_component $UVVM_DIR/$component
done
