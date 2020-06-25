set lib_name "bitvis_vip_spi"

if { [info exists ::env(SIMULATOR)] } {
  set simulator $::env(SIMULATOR)
  puts "Simulator: $simulator"

  if [string equal $simulator "MODELSIM"] {
    set compdirectives "-quiet -suppress 1346,1236,1090 -2008 -work $lib_name"
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
set tb_path "$root_path/bitvis_vip_spi/tb/maintenance_tb"
echo "\n\n\n=== Compiling TB\n"


# DUT
echo "eval vcom  $compdirectives  $tb_path/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_common_pkg.vhd"
eval vcom  $compdirectives  $tb_path/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_common_pkg.vhd

echo "eval vcom  $compdirectives  $tb_path/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_master.vhd"
eval vcom  $compdirectives  $tb_path/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_master.vhd

echo "eval vcom  $compdirectives  $tb_path/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_slave.vhd"
eval vcom  $compdirectives  $tb_path/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_slave.vhd

echo "eval vcom  $compdirectives  $tb_path/spi_pif.vhd"
eval vcom  $compdirectives  $tb_path/spi_pif.vhd

# Testbench
echo "eval vcom  $compdirectives  $tb_path/spi_vvc_tb.vhd"
eval vcom  $compdirectives  $tb_path/spi_vvc_tb.vhd