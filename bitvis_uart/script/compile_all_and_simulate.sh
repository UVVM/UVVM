#!/bin/bash

# compile_all_and_simulate.sh
# Compile all required sources and run simulation for bitvis_uart demo.
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

# Compiling UVVM VVC Framework
echo "Compiling UVVM VVC Framework..."
compile_component $UVVM_DIR/uvvm_vvc_framework

# Compiling Bitvis VIP Scoreboard
echo "Compiling Bitvis VIP Scoreboard..."
compile_component $UVVM_DIR/bitvis_vip_scoreboard

# Compiling Bitvis VIP SBI
echo "Compiling Bitvis VIP SBI..."
compile_component $UVVM_DIR/bitvis_vip_sbi

# Compiling Bitvis VIP UART
echo "Compiling Bitvis VIP UART..."
compile_component $UVVM_DIR/bitvis_vip_uart

# Compiling Bitvis VIP Clock Generator
echo "Compiling Bitvis VIP Clock Generator..."
compile_component $UVVM_DIR/bitvis_vip_clock_generator

# Compiling Bitvis UART
echo "Compiling Bitvis UART..."
compile_component $UVVM_DIR/bitvis_uart

# Compiling UART VVC demo TB
echo "Compiling UART VVC demo TB..."
compile bitvis_uart $UVVM_DIR/bitvis_uart/tb/uart_vvc_demo_th.vhd
compile bitvis_uart $UVVM_DIR/bitvis_uart/tb/uart_vvc_demo_tb.vhd

# Running simulations
echo "Starting simulations..."
simulate bitvis_uart uart_vvc_demo_tb
