set lib_name "bitvis_vip_ethernet"

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
set tb_path "$root_path/bitvis_vip_ethernet/tb/maintenance_tb"
echo "\n\n\n=== Compiling TB\n"


echo "eval vcom  $compdirectives  $tb_path/sbi_fifo.vhd"
eval vcom  $compdirectives  $tb_path/sbi_fifo.vhd

# TB packages
set vhd_files [glob -directory "$tb_path/" -- "*_pkg.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}

# Test harness
set vhd_files [glob -directory "$tb_path/" -- "*_th.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}

# Testbench
set vhd_files [glob -directory "$tb_path/" -- "*_tb.vhd"]
foreach vhd_file $vhd_files {
  echo "eval vcom  $compdirectives $vhd_file"
  eval vcom  $compdirectives $vhd_file
}