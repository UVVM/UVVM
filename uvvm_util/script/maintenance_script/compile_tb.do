set lib_name "uvvm_util"

if { [info exists ::env(SIMULATOR)] } {
  set simulator $::env(SIMULATOR)
  puts "Simulator: $simulator"

  if [string equal $simulator "MODELSIM"] {
    set compdirectives "-quiet -suppress 1346,1246,1236,1090 -2008 -work $lib_name"
  } elseif [string equal $simulator "RIVIERAPRO"] {
    set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
  } else {
    puts "No simulator! Trying with modelsim"
    quietly set compdirectives "-quiet -suppress 1346,1246,1236 -2008 -work $lib_name"
  }
} else {
  puts "No simulator! Trying with modelsim"
  quietly set compdirectives "-quiet -suppress 1346,1246,1236 -2008 -work $lib_name"
}

#------------------------------------------------------
# Compile tb files
#------------------------------------------------------
set root_path "../.."
set tb_path "$root_path/uvvm_util/tb/maintenance_tb"
echo "\n\n\n=== Compiling TB\n"

echo "eval vcom  $compdirectives  $tb_path/methods_tb.vhd"
eval vcom  $compdirectives  $tb_path/methods_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/generic_queue_tb.vhd"
eval vcom  $compdirectives  $tb_path/generic_queue_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/generic_queue_record_tb.vhd"
eval vcom  $compdirectives  $tb_path/generic_queue_record_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/generic_queue_array_tb.vhd"
eval vcom  $compdirectives  $tb_path/generic_queue_array_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/simplified_data_queue_tb.vhd"
eval vcom  $compdirectives  $tb_path/simplified_data_queue_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/rand_tb_pkg.vhd"
eval vcom  $compdirectives  $tb_path/rand_tb_pkg.vhd

echo "eval vcom  $compdirectives  $tb_path/rand_tb.vhd"
eval vcom  $compdirectives  $tb_path/rand_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/func_cov_tb.vhd"
eval vcom  $compdirectives  $tb_path/func_cov_tb.vhd