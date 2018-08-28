# This file may be called with an argument
# arg 1: Part directory of this library/module

# Compile the external dependencies used by the BFM
# and VVC
#------------------------------------------------------
do ../internal_script/internal_compile_uvvm.do

# Compile the BFM and VVC
#------------------------------------------------------
do ../internal_script/internal_compile_src.do

onerror {abort all}
quit -sim   #Just in case...

# Compile Bitvis VIP sbi
#----------------------------------

# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up bitvis_vip_sbi_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_sbi"
quietly set part_name "bitvis_vip_sbi"
# path from mpf-file in sim
quietly set bitvis_vip_sbi_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_vip_sbi_part_path "$1/..//$part_name"
  unset 1
}

do $bitvis_vip_sbi_part_path/script/compile_src.do $bitvis_vip_sbi_part_path


# UART : DUT
#------------------------------------------------------
quietly set lib_name "bitvis_uart"
quietly set part_name "bitvis_uart"
# path from mpf-file in sim
quietly set bitvis_uart_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_uart_part_path "$1/..//$part_name"
  unset 1
}

do $bitvis_uart_part_path/script/1_compile_src.do $bitvis_uart_part_path

# Compile the Testbench
do ./compile_tb.do


