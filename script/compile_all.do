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
# This file must be called with 3 arguments:
#
# This file can be called with three arguments:
# arg 1: Part directory of this library/module
# arg 2: Target directory
# arg 3: Path to custom component list file
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
variable source_path
variable component_path
variable target_path
variable component_list_path

# Default values
# assume we stand in script folder if no source argument is given
quietly set source_path [pwd]
quietly set component_list_path "$source_path/component_list.txt"
quietly set default_target 0

if { [info exists 1] } {
  quietly set source_path "$1"
  quietly set component_list_path "$source_path/component_list.txt"

  if {$argc >= 2} {
    quietly set target_path "$2"
    quietly set default_target 1

    if {$argc >= 3} {
      quietly set component_list_path "$3"
    }
  }
}

#------------------------------------------------------
# Read component_list.txt
#------------------------------------------------------
quietly set fp [open "$component_list_path" r]
quietly set file_data [read $fp]
close $fp

#------------------------------------------------------
# Compile components
#------------------------------------------------------
foreach item $file_data {
  if {$default_target == 0} {
    quietly set target_path "$source_path/../$item/sim"
  }
  quietly set component_path "$source_path/../$item"

  namespace eval compile_src {
    variable local_source_path $source_path
    variable source_path $component_path
    variable target_path $target_path

    variable argc -1

    source $local_source_path/compile_src.do
  }
  namespace delete compile_src
}