# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}

# Set up vip_axistream_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_axistream"
quietly set part_name "bitvis_vip_axistream"
# path from mpf-file in sim
quietly set vip_axistream_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_axistream_part_path "$1/..//$part_name"
  unset 1
}


# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------

set compdirectives "-2008 -quiet -work $lib_name"


# Compile the example DUTs:
eval vcom  $compdirectives  $vip_axistream_part_path/internal_tb/axis_fifo.vhd 
# eval vlog -work bitvis_vip_axistream $vip_axistream_part_path/internal_tb/axistream_fifo.v

# Compile Test Harness and Testbench
eval vcom  $compdirectives  $vip_axistream_part_path/internal_tb/axistream_th.vhd 
eval vcom  $compdirectives  $vip_axistream_part_path/internal_tb/axistream_simple_tb.vhd 


