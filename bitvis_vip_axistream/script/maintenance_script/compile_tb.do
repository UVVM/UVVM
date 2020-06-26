set lib_name "bitvis_vip_axistream"

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
set tb_path "$root_path/bitvis_vip_axistream/tb/maintenance_tb"
echo "\n\n\n=== Compiling TB\n"


# TB - DUTs
echo "eval vcom  $compdirectives  $tb_path/axis_fifo.vhd"
eval vcom  $compdirectives  $tb_path/axis_fifo.vhd



# TBs
echo "eval vcom  $compdirectives  $tb_path/axistream_th.vhd"
eval vcom  $compdirectives  $tb_path/axistream_th.vhd

echo "eval vcom  $compdirectives  $tb_path/axistream_bfm_slv_array_tb.vhd"
eval vcom  $compdirectives  $tb_path/axistream_bfm_slv_array_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/axistream_multiple_vvc_tb.vhd"
eval vcom  $compdirectives  $tb_path/axistream_multiple_vvc_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/axistream_simple_tb.vhd"
eval vcom  $compdirectives  $tb_path/axistream_simple_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/axistream_vvc_simple_tb.vhd"
eval vcom  $compdirectives  $tb_path/axistream_vvc_simple_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/axistream_vvc_slv_array_tb.vhd"
eval vcom  $compdirectives  $tb_path/axistream_vvc_slv_array_tb.vhd