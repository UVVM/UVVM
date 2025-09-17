#================================================================================================================================
# Copyright 2025 UVVM
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

quietly set source_path_old $source_path
quietly set target_path_old $target_path

#-----------------------------------------------------------------------
# Compile libraries and source files
#-----------------------------------------------------------------------
do $source_path/../script/compile_src.do $source_path/../uvvm_util $target_path

quietly set source_path $source_path_old
quietly set target_path $target_path_old

do $source_path/../script/compile_src.do $source_path $target_path

#-----------------------------------------------------------------------
# Compile testbench files
#-----------------------------------------------------------------------
quietly set lib_name "uvvm_assertions"

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

echo "\nCompiling Demo Entities\n"
echo "eval vcom  $compdirectives  $source_path/tb/demo_entities.vhd"
eval vcom  $compdirectives  $source_path/tb/demo_entities.vhd

echo "\nCompiling TH\n"
echo "eval vcom  $compdirectives  $source_path/tb/uvvm_assertions_demo_th.vhd"
eval vcom  $compdirectives  $source_path/tb/uvvm_assertions_demo_th.vhd

echo "\nCompiling TB\n"
echo "eval vcom  $compdirectives  $source_path/tb/uvvm_assertions_demo_tb.vhd"
eval vcom  $compdirectives  $source_path/tb/uvvm_assertions_demo_tb.vhd

#-----------------------------------------------------------------------
# Simulate testbench
#-----------------------------------------------------------------------
vsim uvvm_assertions.uvvm_assertions_demo_tb
run -all