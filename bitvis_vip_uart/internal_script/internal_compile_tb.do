# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up bitvis_vip_uart_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_uart"
quietly set part_name "bitvis_vip_uart"
# path from mpf-file in sim
quietly set bitvis_vip_uart_part_path "../../$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_vip_uart_part_path "$1/../$part_name"
  unset 1
}

# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------

set compdirectives "-2008 -work $lib_name"

# Compile Testbench
eval vcom  $compdirectives  $bitvis_vip_uart_part_path/internal_tb/uart_vip_th.vhd
eval vcom  $compdirectives  $bitvis_vip_uart_part_path/internal_tb/uart_vip_tb.vhd


