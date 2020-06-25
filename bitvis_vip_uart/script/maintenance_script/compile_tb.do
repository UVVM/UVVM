set lib_name "bitvis_vip_uart"

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
set tb_path "$root_path/bitvis_vip_uart/tb/maintenance_tb"

echo "\n\n\n=== Compiling TB\n"

echo "eval vcom  $compdirectives  $tb_path/uart_vip_th.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_th.vhd
echo "eval vcom  $compdirectives  $tb_path/uart_vip_tb.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_tb.vhd

# The following TB is not compliant with UART Core functionallity, thus not simulated:
echo "eval vcom  $compdirectives  $tb_path/uart_vip_monitor_th.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_monitor_th.vhd
echo "eval vcom  $compdirectives  $tb_path/uart_transaction_sb_pkg.vhd"
eval vcom  $compdirectives  $tb_path/uart_transaction_sb_pkg.vhd
echo "eval vcom  $compdirectives  $tb_path/uart_vip_monitor_tb.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_monitor_tb.vhd

