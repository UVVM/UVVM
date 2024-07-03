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

proc set_compdirectives {library version} {
  set lib_name $library
  set vhdl_ver $version
  global compdirectives

  vlib $library
  vmap work $library

  if { [info exists ::env(SIMULATOR)] } {
    set simulator $::env(SIMULATOR)
    puts "Simulator: $simulator"
  } else {
    puts "No simulator! Trying with modelsim"
    set simulator "MODELSIM"
  }

  if [string equal $simulator "MODELSIM"] {
    set compdirectives "-quiet -suppress 1346,1236 -$vhdl_ver -work $lib_name"
  } elseif [string equal $simulator "RIVIERAPRO"] {
    set compdirectives "-$vhdl_ver -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
  } else {
    puts "No simulator! Trying with modelsim"
    quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
  }
  puts "Setting compdirectives: $compdirectives"

}

#-----------------------------------------------------------------------
# Call compile scripts from dependent libraries
#-----------------------------------------------------------------------
set root_path "../.."
do $root_path/script/compile_src.do $root_path/uvvm_util $root_path/uvvm_util/sim
do $root_path/script/compile_src.do $root_path/uvvm_vvc_framework $root_path/uvvm_vvc_framework/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_scoreboard $root_path/bitvis_vip_scoreboard/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_gmii $root_path/bitvis_vip_gmii/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_sbi $root_path/bitvis_vip_sbi/sim
do $root_path/script/compile_src.do $root_path/bitvis_vip_hvvc_to_vvc_bridge $root_path/bitvis_vip_hvvc_to_vvc_bridge/sim


set tb_path "$root_path/bitvis_vip_ethernet/tb/maintenance_tb"
#==========================================================================================================
# Xilinx "XilinixCoreLib" library
#==========================================================================================================
echo "\n\n\n=== Compiling XilinxCoreLib library files"
set_compdirectives "xilinxcorelib" 2008

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_comp.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_comp.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_xst_comp.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_xst_comp.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3.vhd
echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_xst.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_xst.vhd

#==========================================================================================================
# Xilinx "unisim" library
#==========================================================================================================
echo "\n\n\n=== Compiling Unisim library files"

set_compdirectives "unisim" 2008

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VCOMP.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VCOMP.vhd
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VPKG.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VPKG.vhd

set_compdirectives "unisim" 93

set vhd_files [glob -directory "$tb_path/ethernet_mac-master/xilinx/unisims/primitive" -- "*.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}

#==========================================================================================================
# Xilinx "mac_master" library
#==========================================================================================================
echo "\n\n\n=== Compiling Mac_Master library files"

set_compdirectives "mac_master" 2008

# type files / ----------------------------------------------------------------------------------------
set vhd_files [glob -directory "$tb_path/ethernet_mac-master" -- "*_types.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom $compdirectives $vhd_file"
  eval vcom $compdirectives $vhd_file
}

# /xilinx/ip_core --------------------------------------------------------------------------------------------
echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/ipcore_dir/ethernet_mac_tx_fifo_xilinx.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/ipcore_dir/ethernet_mac_tx_fifo_xilinx.vhd

# / ---------------------------------------------------------------------------------------------------
echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/single_signal_synchronizer.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/single_signal_synchronizer.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/reset_generator.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/reset_generator.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/utility.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/utility.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/crc.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/crc.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/crc32.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/crc32.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/framing_common.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/framing_common.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/framing.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/framing.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/mii_gmii.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/mii_gmii.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/mii_gmii_io.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/mii_gmii_io.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/miim.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/miim.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/miim_registers.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/miim_registers.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/miim_control.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/miim_control.vhd

# /xilinx ----------------------------------------------------------------------------------------------------
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/fixed_input_delay.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/fixed_input_delay.vhd

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/input_buffer.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/input_buffer.vhd

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/output_buffer.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/output_buffer.vhd

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/mii_gmii_io_spartan6.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/mii_gmii_io_spartan6.vhd

#echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/single_signal_synchronizer_spartan6.vhd"
#eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/single_signal_synchronizer_spartan6.vhd

# / ---------------------------------------------------------------------------------------------------
echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/ethernet.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/ethernet.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/rx_fifo.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/rx_fifo.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/tx_fifo_adapter.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/tx_fifo_adapter.vhd

# /xilinx ----------------------------------------------------------------------------------------------------
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/tx_fifo.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/tx_fifo.vhd

echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/ethernet_with_fifos.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/ethernet_with_fifos.vhd

# /generic ---------------------------------------------------------------------------------------------------
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/generic/single_signal_synchronizer_simple.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/generic/single_signal_synchronizer_simple.vhd