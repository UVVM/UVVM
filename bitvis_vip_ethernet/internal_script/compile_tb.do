quietly set tb_path "$root_path/bitvis_vip_ethernet/internal_tb"

proc set_compdirectives {library simulator version} {
  quietly set lib_name $library
  quietly set vhdl_ver $version
  global compdirectives

  vlib $library
  vmap work $library


  if { [string equal -nocase $simulator "modelsim"] } {
    quietly set compdirectives "-quiet -suppress 1346,1236,1090 -$vhdl_ver -work $lib_name"
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

#echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3.vhd"
#eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3.vhd
#echo "eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_xst.vhd"
#eval vcom $compdirectives $tb_path/ethernet_mac-master/xilinx/XilinxCoreLib/fifo_generator_v9_3_xst.vhd


#==========================================================================================================
# Xilinx "unisim" library
#==========================================================================================================
echo "\n\n\n=== Compiling Unisim library files"
set_compdirectives "unisim" $simulator 2008

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VCOMP.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VCOMP.vhd
echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VPKG.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/unisims/unisim_VPKG.vhd


#set_compdirectives "unisim" $simulator 93
#
#quietly set vhd_files [glob -directory "$tb_path/ethernet_mac-master/xilinx/unisims/primitive" -- "*.vhd"]
#foreach vhd_file $vhd_files {
#  echo "eval vcom  $compdirectives $vhd_file"
#  eval vcom  $compdirectives $vhd_file
#}



#==========================================================================================================
# Xilinx "mac_master" library
#==========================================================================================================
echo "\n\n\n=== Compiling Mac_Master library files"
set_compdirectives "mac_master" $simulator 2008



#vcom -just p *.vhd
#vcom -just e *.vhd
#vcom -just pb *.vhd
#vcom -just a *.vhd
#vcom -just c *.vhd

quietly set vhd_files [glob -directory "$tb_path/ethernet_mac-master" -- "*_types.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom $compdirectives $vhd_file"
  eval vcom $compdirectives $vhd_file
}

echo "eval vcom -just p $compdirectives $tb_path/ethernet_mac-master/single_signal_synchronizer.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/single_signal_synchronizer.vhd

echo "eval vcom -just p $compdirectives $tb_path/ethernet_mac-master/reset_generator.vhd"
eval vcom $compdirectives $tb_path/ethernet_mac-master/single_signal_synchronizer.vhd

quietly set vhd_files [glob -directory "$tb_path/ethernet_mac-master" -- "*.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom $compdirectives $vhd_file"
  eval vcom $compdirectives $vhd_file
}


echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/generic/single_signal_synchronizer_simple.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/generic/single_signal_synchronizer_simple.vhd

echo "eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/ipcore_dir/ethernet_max_tx_fifo_xilinx.vhd"
eval vcom  $compdirectives  $tb_path/ethernet_mac-master/xilinx/ipcore_dir/ethernet_max_tx_fifo_xilinx.vhd

quietly set vhd_files [glob -directory "$tb_path/ethernet_mac-master/xilinx" -- "*.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}



#==========================================================================================================
# Compile tb files
#==========================================================================================================
echo "\n\n\n=== Compiling TB\n"
set_compdirectives "bitvis_vip_ethernet" $simulator 2008

echo "eval vcom  $compdirectives  $tb_path/sbi_fifo.vhd"
eval vcom  $compdirectives  $tb_path/sbi_fifo.vhd

