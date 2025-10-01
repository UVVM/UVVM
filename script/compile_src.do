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
#   arg 1: Part directory of this library/module
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

#------------------------------------------------------
# Set up source_path and target_path
#------------------------------------------------------
if {$argc == 2} {
  quietly set source_path "$1"
  quietly set target_path "$2"
} elseif {$argc == -1} {
  # Called from other script
} else {
  error "Needs two arguments: source path and target path"
}

#------------------------------------------------------
# Read compile_order.txt and set lib_name
#------------------------------------------------------
quietly set fp [open "$source_path/script/compile_order.txt" r]
quietly set file_data [read $fp]
quietly set lib_name [lindex $file_data 2]
close $fp

echo "\n\n=== Re-gen lib and compile $lib_name source\n"
echo "Source path: $source_path"
echo "Target path: $target_path"

#------------------------------------------------------
# (Re-)Generate library and Compile source files
#------------------------------------------------------
if {[file exists $target_path/$lib_name]} {
  file delete -force $target_path/$lib_name
}
if {![file exists $target_path]} {
  file mkdir $target_path/$lib_name
}

quietly vlib $target_path/$lib_name
quietly vmap $lib_name $target_path/$lib_name

# These two core libraries are needed by every VIP (except the IRQC and UART demos, and specification coverage),
# therefore we should map them in case they were compiled from different directories
# which would cause the references to be in a different file.
# First check if the libraries are in the specified target path, if not, then look
# in the default UVVM structure.
if {$lib_name != "uvvm_util" && $lib_name != "uvvm_assertions" && $lib_name != "bitvis_irqc" && $lib_name != "bitvis_uart" && $lib_name != "bitvis_vip_spec_cov"} {
  echo "Mapping uvvm_util and uvvm_vvc_framework"
  if {[file exists $target_path/uvvm_util]} {
    quietly vmap uvvm_util $target_path/uvvm_util
  } else {
    quietly vmap uvvm_util $source_path/../uvvm_util/sim/uvvm_util
  }
  if {[file exists $target_path/uvvm_vvc_framework]} {
    quietly vmap uvvm_vvc_framework $target_path/uvvm_vvc_framework
  } else {
    quietly vmap uvvm_vvc_framework $source_path/../uvvm_vvc_framework/sim/uvvm_vvc_framework
  }
}
# uvvm_assertions only requires uvvm_util and therefore we dont compile uvvm_vvc_framework
if {$lib_name == "uvvm_assertions"} {
  echo "Mapping uvvm_util"
  if {[file exists $target_path/uvvm_util]} {
    quietly vmap uvvm_util $target_path/uvvm_util
  } else {
    quietly vmap uvvm_util $source_path/../uvvm_util/sim/uvvm_util
  }
}

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1246,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#------------------------------------------------------
# Compile src files
#------------------------------------------------------
echo "\nCompiling $lib_name source\n"
quietly set idx 0
foreach item $file_data {
  if {$idx > 2} {
    echo "eval vcom $compdirectives $source_path/script/$item"
    eval vcom $compdirectives [list "$source_path/script/$item"]
  }
  incr idx 1
}