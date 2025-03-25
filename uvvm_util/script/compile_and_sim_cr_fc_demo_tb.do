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
# Compile libraries and source files
#-----------------------------------------------------------------------
do ../script/compile_src.do ../../uvvm_util ../../uvvm_util/sim
do ../script/compile_src.do ../../uvvm_vvc_framework ../../uvvm_vvc_framework/sim
do ../script/compile_src.do ../../bitvis_vip_scoreboard ../../bitvis_vip_scoreboard/sim
do ../script/compile_src.do ../../bitvis_vip_sbi ../../bitvis_vip_sbi/sim
do ../script/compile_src.do ../../bitvis_vip_uart ../../bitvis_vip_uart/sim
do ../script/compile_src.do ../../bitvis_uart ../../bitvis_uart/sim

#-----------------------------------------------------------------------
# Compile testbench files
#-----------------------------------------------------------------------
quietly set lib_name "bitvis_uart"

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

echo "\nCompiling TB\n"
echo "eval vcom  $compdirectives  ../tb/cr_fc_demo_tb.vhd"
eval vcom  $compdirectives  ../tb/cr_fc_demo_tb.vhd

#-----------------------------------------------------------------------
# Simulate testbench
#-----------------------------------------------------------------------
vsim bitvis_uart.cr_fc_demo_tb
run -all