#========================================================================================================================
# Copyright (c) 2017 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

# This file may be called with an argument
# arg 1: Part directory of this library/module

# Locations of ROOT, tcl_util, and this script
set UVVM_ALL_ROOT ../..
set TCL_UTIL_DIR tcl_util
set CURR_SCRIPT_DIR [ file dirname [file normalize $argv0]]
set TCL_UTIL_DIR $CURR_SCRIPT_DIR/$UVVM_ALL_ROOT/$TCL_UTIL_DIR

# Use tcl_util/util_base.tcl
source "$TCL_UTIL_DIR/util_base.tcl"


# Just in case...
quietly quit -sim

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


# (Re-)Generate library and Compile source files
#--------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source\n"
if {[file exists $vip_avalon_mm_part_path/sim/$lib_name]} {
  file delete -force $vip_avalon_mm_part_path/sim/$lib_name
}
if {![file exists $vip_avalon_mm_part_path/sim]} {
  file mkdir $vip_avalon_mm_part_path/sim
}

vlib $vip_avalon_mm_part_path/sim/$lib_name
vmap $lib_name $vip_avalon_mm_part_path/sim/$lib_name

if { [string equal -nocase $simulator "modelsim"] } {
  set compdirectives "-2008 -suppress 1346,1236 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -dbg -work $lib_name"
}

eval vcom  $compdirectives  $vip_avalon_mm_part_path/src/avalon_mm_bfm_pkg.vhd