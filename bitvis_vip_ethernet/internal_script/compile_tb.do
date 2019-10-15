quietly set tb_path "$root_path/bitvis_vip_ethernet/internal_tb"


proc set_compdirectives {library simulator version} {
  quietly set lib_name $library
  quietly set vhdl_ver $version
  global compdirectives

  vlib $library
  vmap work $library


  if { [string equal -nocase $simulator "modelsim"] } {
    quietly set compdirectives "-quiet -suppress 1346,1236,1090 -novopt -$vhdl_ver -work $lib_name"
  } elseif { [string equal -nocase $simulator "rivierapro"] } {
    set compdirectives "-$vhdl_ver -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
  }
}



#==========================================================================================================
# Xilinx "XilinixCoreLib" library
#==========================================================================================================
echo "\n\n\n=== Compiling XilinxCoreLib library files"
set_compdirectives "xilinxcorelib" $simulator 2008

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

set_compdirectives "unisim" $simulator 2008

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VCOMP.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VCOMP.vhd
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VPKG.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VPKG.vhd


set_compdirectives "unisim" $simulator 93

quietly set vhd_files [glob -directory "$tb_path/ethernet_mac-master/xilinx/unisims/primitive" -- "*.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}



#==========================================================================================================
# Xilinx "mac_master" library
#==========================================================================================================
echo "\n\n\n=== Compiling Mac_Master library files"

set_compdirectives "mac_master" $simulator 2008

# type files / ----------------------------------------------------------------------------------------
quietly set vhd_files [glob -directory "$tb_path/ethernet_mac-master" -- "*_types.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom $compdirectives $vhd_file"
  eval vcom $compdirectives $vhd_file
}

# /xilinx/ip_core --------------------------------------------------------------------------------------------
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/ipcore_dir/ethernet_mac_tx_fifo_xilinx.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/ipcore_dir/ethernet_mac_tx_fifo_xilinx.vhd



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

#echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/mii_gmii_io_spartan6.vhd"
#eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/mii_gmii_io_spartan6.vhd

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/output_buffer.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/output_buffer.vhd

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




#==========================================================================================================
# Compile tb files
#==========================================================================================================
echo "\n\n\n=== Compiling TB\n"
set_compdirectives "bitvis_vip_ethernet" $simulator 2008

echo "eval vcom  $compdirectives  $tb_path/sbi_fifo.vhd"
eval vcom  $compdirectives  $tb_path/sbi_fifo.vhd


# TB packages
quietly set vhd_files [glob -directory "$tb_path/" -- "*_pkg.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}

# Test harness
quietly set vhd_files [glob -directory "$tb_path/" -- "*_th.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}

# Testbench
quietly set vhd_files [glob -directory "$tb_path/" -- "*_tb.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}
