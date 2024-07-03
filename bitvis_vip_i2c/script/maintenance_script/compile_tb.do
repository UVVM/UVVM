set lib_name "bitvis_vip_i2c"

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

#------------------------------------------------------
# Compile tb files
#------------------------------------------------------
set root_path "../.."
set tb_path "$root_path/bitvis_vip_i2c/tb/maintenance_tb"
echo "\n\n\n=== Compiling TB\n"


# i2c slave dut
echo "eval vcom  $compdirectives  $tb_path/fpga_i2c_slave_github/txt_util.vhd"
eval vcom  $compdirectives  $tb_path/fpga_i2c_slave_github/txt_util.vhd
echo "eval vcom  $compdirectives  $tb_path/fpga_i2c_slave_github/i2c_slave.vhd"
eval vcom  $compdirectives  $tb_path/fpga_i2c_slave_github/i2c_slave.vhd


# i2c master dut
echo "eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c.vhd"
eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/tst_ds1621.vhd"
eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/tst_ds1621.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c_maste_bit_ctrl.vhd"
eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c_master_bit_ctrl.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c_master_byte_ctrl.vhd"
eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c_master_byte_ctrl.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c_master_top.vhd"
eval vcom  $compdirectives  $tb_path/i2c_opencores/trunk/rtl/vhdl/i2c_master_top.vhd



# TB
echo "eval vcom  $compdirectives  $tb_path/i2c_master_dut.vhd"
eval vcom  $compdirectives  $tb_path/i2c_master_dut.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_slave_dut.vhd"
eval vcom  $compdirectives  $tb_path/i2c_slave_dut.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_th.vhd"
eval vcom  $compdirectives  $tb_path/i2c_th.vhd

echo "eval vcom  $compdirectives  $tb_path/i2c_vvc_tb.vhd"
eval vcom  $compdirectives  $tb_path/i2c_vvc_tb.vhd