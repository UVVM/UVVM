#================================================================================================================================
# Copyright 2024 UVVM
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------
# This file must be called with 2 arguments:
#
#   arg 1: Source directory of this library/module
#   arg 2: Target directory
#-----------------------------------------------------------------------

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  # puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {questasim} $simulator_version]} {
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

# End the simulations if there's an error or when run from terminal.
if {[batch_mode]} {
  if { [string equal -nocase $simulator "rivierapro"] } {
    # Special for Riviera-PRO
    onerror {quit -code 1 -force}
   } else {
    onerror {abort all; exit -f -code 1}
  }
} else {
  onerror {abort all}
}

#-----------------------------------------------------------------------
# Set up source_path and target_path
#-----------------------------------------------------------------------
if { [info exists 1] } {
  quietly set source_path "$1"

  if {$argc == 1} {
    echo "\nUser specified source directory"
    quietly set target_path "$source_path/sim"
  } elseif {$argc >= 2} {
    echo "\nUser specified source and target directory"
    quietly set target_path "$2"
  }
  unset 1
} else {
  echo "\nDefault output directory"
  quietly set source_path ".."
  quietly set target_path "$source_path/sim"
}

#------------------------------------------------------
# Set lib_name
#------------------------------------------------------
quietly set lib_name bitvis_vip_axilite


#------------------------------------------------------
# (Re-)Generate library and Compile source files
#------------------------------------------------------
echo "\n\n=== Re-gen lib and compile $lib_name BFM source\n"
echo "Source path: $source_path"
echo "Target path: $target_path"

if {[file exists $target_path/$lib_name]} {
  file delete -force $target_path/$lib_name
}
if {![file exists $target_path]} {
  file mkdir $target_path/$lib_name
}

quietly vlib $target_path/$lib_name
quietly vmap $lib_name $target_path/$lib_name

# Check if the UVVM Util library is in the specified target path, if not, 
# then look in the default UVVM structure.
if {$lib_name != "uvvm_util" && $lib_name != "bitvis_irqc" && $lib_name != "bitvis_uart"} {
  echo "Mapping uvvm_util"
  if {[file exists $target_path/uvvm_util]} {
    quietly vmap uvvm_util $target_path/uvvm_util
  } else {
    quietly vmap uvvm_util $source_path/../uvvm_util/sim/uvvm_util
  }
}

#------------------------------------------------------
# Setup compile directives
#------------------------------------------------------
if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#------------------------------------------------------
# Compile BFM file
#------------------------------------------------------
echo "\nCompiling $lib_name BFM source\n"
echo "eval vcom  $compdirectives  $source_path/src/axilite_bfm_pkg.vhd"
eval vcom  $compdirectives  $source_path/src/axilite_bfm_pkg.vhd
