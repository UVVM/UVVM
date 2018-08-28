# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up vip_axilite_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_axilite"
quietly set part_name "bitvis_vip_axilite"
# path from mpf-file in sim
quietly set vip_axilite_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_axilite_part_path "$1/..//$part_name"
  unset 1
}


# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------

set compdirectives "-2008 -work $lib_name"


# Compile the example DUTs:
eval vcom  $compdirectives  $vip_axilite_part_path/internal_tb/axilite_slave.vhd
eval vcom  $compdirectives  $vip_axilite_part_path/internal_tb/axilite_slave_model_pkg.vhd
eval vcom  $compdirectives  $vip_axilite_part_path/internal_tb/axilite_slave_model.vhd

# Compile Test Harness and Testbench
eval vcom  $compdirectives  $vip_axilite_part_path/internal_tb/axilite_vvc_th.vhd
eval vcom  $compdirectives  $vip_axilite_part_path/internal_tb/axilite_vvc_simple_tb.vhd


