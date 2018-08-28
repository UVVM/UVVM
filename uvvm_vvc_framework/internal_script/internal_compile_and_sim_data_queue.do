# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

###########
# Fix possible vmap bug
do ../script/fix_vmap.tcl 
##########

source ../script/compile_util.do
source ../script/compile_src.do

# Set up uvvm_vvc_framework_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "uvvm_vvc_framework"
quietly set part_name "uvvm_vvc_framework"
# path from mpf-file in sim
quietly set uvvm_vvc_framework_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set uvvm_vvc_framework_part_path "$1/..//$part_name"
  unset 1
}


# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------

set compdirectives "-2008 -work $lib_name"

echo "\n\n\n=== Compiling $lib_name source\n"
eval vcom  $compdirectives   $uvvm_vvc_framework_part_path/internal_tb/internal_simplified_data_queue_tb.vhd

vsim  uvvm_vvc_framework.simplified_data_queue_tb
run -all


