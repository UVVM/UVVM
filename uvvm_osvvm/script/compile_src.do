# This file may be called with an argument
# arg 1: Part directory of this library/module

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

# Set up part_path and lib_name
#------------------------------------------------------
quietly set lib_name "uvvm_osvvm"
quietly set part_name "uvvm_osvvm"
# path from mpf-file in sim
quietly set part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set part_path "$1/..//$part_name"
  unset 1
}

if {[file exists $part_path/sim/$lib_name]} {
  vdel -all -lib $part_path/sim/$lib_name
}
if {![file exists $part_path/sim]} {
  file mkdir $part_path/sim
}

vlib $part_path/sim/$lib_name
vmap $lib_name $part_path/sim/$lib_name


echo "\n\n\n=== Compiling $lib_name source\n"
# Only 2008 version supported
vcom -2008 -work $lib_name $part_path/src/TextUtilPkg.vhd
vcom -2008 -work $lib_name $part_path/src/NamePkg.vhd
vcom -2008 -work $lib_name $part_path/src/TranscriptPkg.vhd
vcom -2008 -work $lib_name $part_path/src/OsvvmGlobalPkg.vhd
vcom -2008 -work $lib_name $part_path/src/AlertLogPkg.vhd
vcom -2008 -work $lib_name $part_path/src/MessagePkg.vhd
vcom -2008 -work $lib_name $part_path/src/SortListPkg_int.vhd
vcom -2008 -work $lib_name $part_path/src/RandomBasePkg.vhd
vcom -2008 -work $lib_name $part_path/src/RandomPkg.vhd
vcom -2008 -work $lib_name $part_path/src/CoveragePkg.vhd
vcom -2008 -work $lib_name $part_path/src/MemoryPkg.vhd
vcom -2008 -work $lib_name $part_path/src/OsvvmContext.vhd

