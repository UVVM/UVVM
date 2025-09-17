#!/bin/bash

# compile_all_and_simulate.sh
# Compile all required sources and run simulation for bitvis_irqc demo.
# Usage: sh compile_all_and_simulate.sh <simulator> <target_dir>
# simulator  : ghdl, nvc, or vsim
# target_dir : path to target directory (optional, defaults to .)

set -o errexit
SIM=$1
TARGET_DIR=$2
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    SCRIPT_DIR=$(cygpath -m ${SCRIPT_DIR})
fi
UVVM_DIR=$SCRIPT_DIR/../..

source $UVVM_DIR/script/multisim.sh

# Compiling UVVM Util
echo "Compiling UVVM Utility Library..."
compile_component $UVVM_DIR/uvvm_util

# Compiling Bitvis VIP SBI BFM
echo "Compiling Bitvis VIP SBI BFM..."
compile bitvis_vip_sbi $UVVM_DIR/bitvis_vip_sbi/src/sbi_bfm_pkg.vhd

# Compiling Bitvis IRQC
echo "Compiling Bitvis IRQC..."
compile_component $UVVM_DIR/bitvis_irqc

# Compiling demo TB
echo "Compiling IRQC demo TB..."
compile bitvis_irqc $UVVM_DIR/bitvis_irqc/tb/irqc_demo_tb.vhd

# Running simulations
echo "Starting simulations..."
simulate bitvis_irqc irqc_demo_tb
