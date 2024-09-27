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

set lib_name "bitvis_vip_spec_cov"

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

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
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
}

#-----------------------------------------------------------------------
# Call compile scripts from dependent libraries
#-----------------------------------------------------------------------
quietly set root_path "../.."
do $root_path/script/compile_src.do $root_path/uvvm_util $root_path/uvvm_util/sim
do $root_path/script/compile_src.do $root_path/uvvm_vvc_framework $root_path/uvvm_vvc_framework/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_scoreboard $root_path/bitvis_vip_scoreboard/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_uart $root_path/bitvis_vip_uart/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_sbi $root_path/bitvis_vip_sbi/sim
do $root_path/script/compile_src.do $root_path/bitvis_uart $root_path/bitvis_uart/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_spec_cov $root_path/bitvis_vip_spec_cov/sim

#------------------------------------------------------
# Compile demo files
#------------------------------------------------------
quietly set demo_version basic
if { [info exists 1] } {
  quietly set demo_version "$1"
}

if { [string equal -nocase $demo_version "basic"] } {
  echo "\n\n=== Compiling Basic Demo TB\n"
  quietly set demo_path "$root_path/bitvis_vip_spec_cov/demo/basic_usage"
} else {
  echo "\n\n=== Compiling Advanced Demo TB\n"
  quietly set demo_path "$root_path/bitvis_vip_spec_cov/demo/advanced_usage"
}

echo "eval vcom  $compdirectives  $demo_path/uart_vvc_th.vhd"
eval vcom  $compdirectives  $demo_path/uart_vvc_th.vhd

echo "eval vcom  $compdirectives  $demo_path/uart_vvc_tb.vhd"
eval vcom  $compdirectives  $demo_path/uart_vvc_tb.vhd