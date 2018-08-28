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

# Set up bitvis_uvvm_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "uvvm_vvc_framework"
quietly set part_name "uvvm_vvc_framework"
# path from mpf-file in sim
quietly set bitvis_uvvm_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_uvvm_part_path "$1/..//$part_name"
  unset 1
}


# (Re-)Generate library and Compile source files
#--------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source\n"
if {[file exists $bitvis_uvvm_part_path/sim/$lib_name]} {
  file delete -force  $bitvis_uvvm_part_path/sim/$lib_name
}
if {![file exists $bitvis_uvvm_part_path/sim]} {
  file mkdir $bitvis_uvvm_part_path/sim
}

vlib $bitvis_uvvm_part_path/sim/$lib_name
vmap $lib_name $bitvis_uvvm_part_path/sim/$lib_name

set compdirectives "-2008 -work $lib_name"

echo "\n\n\n=== Compiling $lib_name source\n"
eval vcom  $compdirectives   $bitvis_uvvm_part_path/src/ti_generic_queue_pkg.vhd
eval vcom  $compdirectives   $bitvis_uvvm_part_path/internal_tb/internal_generic_queue_tb.vhd

vsim  uvvm_vvc_framework.generic_queue_tb
run -all


