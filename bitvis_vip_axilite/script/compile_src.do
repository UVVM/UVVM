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

# This file may be called with arguments:
# arg 1: Part directory of this library/module
# arg 2: Target directory

# Locations of ROOT, tcl_util, and this script
set UVVM_ALL_ROOT ../..
set TCL_UTIL_DIR tcl_util
set CURR_SCRIPT_DIR [ file dirname [file normalize $argv0]]
set TCL_UTIL_DIR $CURR_SCRIPT_DIR/$UVVM_ALL_ROOT/$TCL_UTIL_DIR

# Use tcl_util/util_base.tcl
source "$TCL_UTIL_DIR/util_base.tcl"


#------------------------------------------------------
# Set up source_path and default_target
#
#   0 args: regular UVVM directory structure expected
#   1 args: source directory specified, target will be current directory
#   2 args: source directory and target directory specified
#
#------------------------------------------------------
quietly set part_name "bitvis_vip_axilite"

if { [info exists 1] } {
  if {$argc == 1} {
    echo "\nUser specified source directory"
    quietly set source_path "$1"
    quietly set target_path [pwd]
    quietly set default_target 0
  } elseif {$argc >= 2} {
    echo "\nUser specified source and target directory"
    quietly set target_path "$2"
    quietly set default_target 0
  }
  unset 1
} else {
  echo "\nDefault output directory"
  # path from mpf-file in /sim folder
  quietly set source_path "../..//$part_name"
  quietly set target_path $source_path
  quietly set default_target 1
}
echo "Source path: $source_path"
echo "Taget path: $target_path"


#------------------------------------------------------
# Read compile_order.txt and set lib_name
#------------------------------------------------------
quietly set fp [open "$source_path/script/compile_order.txt" r]
quietly set file_data [read $fp]
quietly set lib_name [lindex $file_data 2]
close $fp

#------------------------------------------------------
# (Re-)Generate library and Compile source files
#------------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source"
if {$default_target} {
  if {[file exists $source_path/sim/$lib_name]} {
    file delete -force $source_path/sim/$lib_name
  }
  if {![file exists $source_path/sim]} {
    file mkdir $source_path/sim
  }
} else {
  if {![file exists $target_path/$lib_name]} {
    file mkdir $target_path/$lib_name
  }
}

if {$default_target} {
  vlib $source_path/sim/$lib_name
  vmap $lib_name $source_path/sim/$lib_name
} else {
  vlib $target_path/$lib_name
  vmap $lib_name $target_path/$lib_name
}

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#------------------------------------------------------
# Compile src files
#------------------------------------------------------
echo "\n\n\n=== Compiling $lib_name source\n"
quietly set idx 0
foreach item $file_data {
  if {$idx > 2} {
    echo "eval vcom  $compdirectives  $source_path/script/$item"
    eval vcom  $compdirectives  $source_path/script/$item
  }
  incr idx 1
}