#========================================================================================================================
# Copyright (c) 2016 by Bitvis AS.  All rights reserved.
#
# UVVM UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM UTILITY LIBRARY.
#========================================================================================================================

# This file may be called with an argument
# arg 1: Part directory of this library/module

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}
quit -sim   #Just in case...

###########
# Fix possible vmap bug
do fix_vmap.tcl 
##########

# Set up irqc_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_irqc"
quietly set part_name "bitvis_irqc"
# path from mpf-file in sim
quietly set irqc_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set irqc_part_path "$1/..//$part_name"
  unset 1
}


# (Re-)Generate library and Compile source files
#--------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source\n"
if {[file exists $irqc_part_path/sim/$lib_name]} {
  file delete -force $irqc_part_path/sim/$lib_name
}
if {![file exists $irqc_part_path/sim]} {
  file mkdir $irqc_part_path/sim
}

vlib $irqc_part_path/sim/$lib_name
vmap $lib_name $irqc_part_path/sim/$lib_name

set compdirectives "-2008 -work $lib_name"

eval vcom  $compdirectives  $irqc_part_path/src/irqc_pif_pkg.vhd
eval vcom  $compdirectives  $irqc_part_path/src/irqc_pif.vhd
eval vcom  $compdirectives  $irqc_part_path/src/irqc_core.vhd
eval vcom  $compdirectives  $irqc_part_path/src/irqc.vhd
