# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}

###########
# Fix possible vmap bug
do ../script/fix_vmap.tcl 
##########

# Set up bitvis_vip_axistream_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_axistream"
quietly set part_name "bitvis_vip_axistream"
# path from mpf-file in sim
quietly set bitvis_vip_axistream_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set bitvis_vip_axistream_part_path "$1/..//$part_name"
  unset 1
}


#    # (Re-)Generate library and Compile source files
#    #--------------------------------------------------
#    echo "\n\nRe-gen lib and compile $lib_name source\n"
#    if {[file exists $bitvis_vip_axistream_part_path/sim/$lib_name]} {
#      vdel -all -lib $bitvis_vip_axistream_part_path/sim/$lib_name
#    }
#    if {![file exists $bitvis_vip_axistream_part_path/sim]} {
#      file mkdir $bitvis_vip_axistream_part_path/sim
#    }
#    
#    vlib $bitvis_vip_axistream_part_path/sim/$lib_name
#    vmap $lib_name $bitvis_vip_axistream_part_path/sim/$lib_name

set compdirectives "-2008 -work $lib_name"

eval vcom  $compdirectives  $bitvis_vip_axistream_part_path/src/axistream_bfm_pkg.vhd
