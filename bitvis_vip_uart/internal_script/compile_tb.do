quietly set lib_name "bitvis_vip_uart"

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236,1090 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#------------------------------------------------------
# Compile tb files
#------------------------------------------------------
quietly set tb_path "$root_path/bitvis_vip_uart/internal_tb"

echo "\n\n\n=== Compiling TB\n"

echo "eval vcom  $compdirectives  $tb_path/uart_vip_th.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_th.vhd

echo "eval vcom  $compdirectives  $tb_path/uart_vip_tb.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/uart_vip_monitor_th.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_monitor_th.vhd

echo "eval vcom  $compdirectives  $tb_path/uart_vip_monitor_tb.vhd"
eval vcom  $compdirectives  $tb_path/uart_vip_monitor_tb.vhd

