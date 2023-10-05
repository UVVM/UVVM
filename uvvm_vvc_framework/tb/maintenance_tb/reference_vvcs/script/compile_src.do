#================================================================================================================================
# Copyright 2020 Bitvis
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------
# This script is used to compile certain copies of old VVCs into existing
# VVC libraries so that they can be used in backwards compatibility testing.
# This file may be called with 0 to 1 arguments:
#
#   0 args: calling script from its location
#   1 args: source directory specified
#---------------------------------------------------------------------------

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

# End the simulations if there's an error or when run from terminal.
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

# Set compile directives
if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg"
}

# Set up source_path
if { [info exists 1] } {
  quietly set source_path "$1"
  unset 1
} else {
  echo "\nDefault output directory"
  quietly set source_path ".."
}

#------------------------------------------------------
# Compile src files
#------------------------------------------------------
quietly set lib_name bitvis_vip_sbi
echo "\nCompiling $lib_name source\n"
echo "eval vcom  $compdirectives -work $lib_name  $source_path/src/sbi_vvc_old.vhd"
eval vcom  $compdirectives -work $lib_name  $source_path/src/sbi_vvc_old.vhd

quietly set lib_name bitvis_vip_uart
echo "\nCompiling $lib_name source\n"
echo "eval vcom  $compdirectives -work $lib_name  $source_path/src/uart_rx_vvc_old.vhd"
eval vcom  $compdirectives -work $lib_name  $source_path/src/uart_rx_vvc_old.vhd
echo "eval vcom  $compdirectives -work $lib_name  $source_path/src/uart_tx_vvc_old.vhd"
eval vcom  $compdirectives -work $lib_name  $source_path/src/uart_tx_vvc_old.vhd
echo "eval vcom  $compdirectives -work $lib_name  $source_path/src/uart_vvc_old.vhd"
eval vcom  $compdirectives -work $lib_name  $source_path/src/uart_vvc_old.vhd