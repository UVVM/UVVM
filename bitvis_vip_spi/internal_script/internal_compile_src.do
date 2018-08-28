#========================================================================================================================
# Copyright (c) 2017 by Bitvis AS.  All rights reserved.
#
# BITVIS UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH BITVIS UTILITY LIBRARY.
#========================================================================================================================

# This file may be called with an argument
# arg 1: Part directory of this library/module


onerror {abort all}
quit -sim   #Just in case...

###########
# Fix possible vmap bug
do fix_vmap.tcl 
##########

# Set up vip_spi_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_spi"
quietly set part_name "bitvis_vip_spi"
# path from mpf-file in sim
quietly set vip_spi_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_spi_part_path "$1/..//$part_name"
  unset 1
}


# (Re-)Generate library and Compile source files
#--------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source\n"


if {[file exists $vip_spi_part_path/sim/$lib_name]} {
  file delete -force $vip_spi_part_path/sim/$lib_name
}
if {![file exists $vip_spi_part_path/sim]} {
  file mkdir $vip_spi_part_path/sim
}

vlib $vip_spi_part_path/sim/$lib_name
vmap $lib_name $vip_spi_part_path/sim/$lib_name

set compdirectives "-2008 -work $lib_name"

eval vcom  $compdirectives  $vip_spi_part_path/src/spi_bfm_pkg.vhd
eval vcom  $compdirectives  $vip_spi_part_path/src/vvc_cmd_pkg.vhd
eval vcom  $compdirectives  $vip_spi_part_path/../uvvm_vvc_framework/src/internal_uvvm_vvc_dedicated_support_pkg.vhd
eval vcom  $compdirectives  $vip_spi_part_path/../uvvm_vvc_framework/src/internal_uvvm_methods_pkg.vhd
eval vcom  $compdirectives  $vip_spi_part_path/src/vvc_methods_pkg.vhd
eval vcom  $compdirectives  $vip_spi_part_path/../uvvm_vvc_framework/src/internal_vvc_support_pkg.vhd
eval vcom  $compdirectives  $vip_spi_part_path/src/spi_tx_vvc.vhd
eval vcom  $compdirectives  $vip_spi_part_path/src/spi_rx_vvc.vhd
eval vcom  $compdirectives  $vip_spi_part_path/src/spi_vvc.vhd

