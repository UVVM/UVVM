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