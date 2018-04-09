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

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  # puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $simulator_version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting to use Modelsim commands."
    quietly set simulator "modelsim"
  }
} else {
    puts "vsim -version failed with the following message:\n $message"
    abort all
}

if { [string equal -nocase $simulator "modelsim"] } {
  ###########
  # Fix possible vmap bug
  do fix_vmap.tcl
  ##########
}


#------------------------------------------------------
# Set up source_path and default_target
#
#   0 args: regular UVVM directory structure expected
#   1 args: source directory specified, target will be current directory
#   2 args: source directory and target directory specified
#
#------------------------------------------------------
quietly set part_name "uvvm_util"

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