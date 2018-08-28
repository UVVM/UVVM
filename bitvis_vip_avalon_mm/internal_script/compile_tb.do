# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up vip_avalon_mm_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_avalon_mm"
quietly set part_name "bitvis_vip_avalon_mm"
# path from mpf-file in sim
quietly set vip_avalon_mm_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_avalon_mm_part_path "$1/..//$part_name"
  unset 1
}


# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------

set compdirectives "-2008 -work $lib_name"


# Compile the example DUT:
eval vcom  $compdirectives  $vip_avalon_mm_part_path/internal_tb/avalon_fifo.vhd
eval vcom  $compdirectives  $vip_avalon_mm_part_path/internal_tb/avalon_spi.vhd


# Compile Testbench
eval vcom  $compdirectives  $vip_avalon_mm_part_path/internal_tb/avalon_mm_simple_tb.vhd
eval vcom  $compdirectives  $vip_avalon_mm_part_path/internal_tb/avalon_mm_simple_spi_tb.vhd


