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

set lib_name "bitvis_uart"

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

# Set simulator compile directives
if { [info exists ::env(SIMULATOR)] } {
  set simulator $::env(SIMULATOR)
  puts "Simulator: $simulator"

  if [string equal $simulator "MODELSIM"] {
    set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
  } elseif [string equal $simulator "RIVIERAPRO"] {
    set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
  } else {
    puts "No simulator! Trying with modelsim"
    quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
  }
} else {
  puts "No simulator! Trying with modelsim"
  quietly set simulator "MODELSIM"
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
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
# Call compile scripts from dependent libraries
#-----------------------------------------------------------------------
do ../script/compile_src.do ../../uvvm_util ../../uvvm_util/sim
do ../script/compile_src.do ../../uvvm_vvc_framework ../../uvvm_vvc_framework/sim
do ../script/compile_src.do ../../bitvis_vip_scoreboard ../../bitvis_vip_scoreboard/sim
do ../script/compile_src.do ../../bitvis_vip_sbi ../../bitvis_vip_sbi/sim
do ../script/compile_src.do ../../bitvis_vip_uart ../../bitvis_vip_uart/sim
do ../script/compile_src.do ../../bitvis_uart ../../bitvis_uart/sim

#-----------------------------------------------------------------------
# Compile demo files
#-----------------------------------------------------------------------
echo "\nCompiling TB\n"
echo "eval vcom  $compdirectives  ../tb/cr_fc_demo_tb.vhd"
eval vcom  $compdirectives  ../tb/cr_fc_demo_tb.vhd

#-----------------------------------------------------------------------
# Simulate demo
#-----------------------------------------------------------------------
vsim bitvis_uart.cr_fc_demo_tb
run -all