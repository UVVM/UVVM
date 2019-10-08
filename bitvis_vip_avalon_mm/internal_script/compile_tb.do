quietly set lib_name "bitvis_vip_avalon_mm"

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236,1090 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#------------------------------------------------------
# Compile tb files
#------------------------------------------------------
quietly set tb_path "$root_path/bitvis_vip_avalon_mm/internal_tb"
echo "\n\n\n=== Compiling TB\n"


# TB - DUTs
echo "eval vcom  $compdirectives  $tb_path/avalon_fifo.vhd"
eval vcom  $compdirectives  $tb_path/avalon_fifo.vhd

echo "eval vcom  $compdirectives  $tb_path/fpga4u_sdram_controller.vhd"
eval vcom  $compdirectives  $tb_path/fpga4u_sdram_controller.vhd

echo "eval vcom  $compdirectives  $tb_path/avalon_spi.vhd"
eval vcom  $compdirectives  $tb_path/avalon_spi.vhd

# TBs

echo "eval vcom  $compdirectives  $tb_path/avalon_mm_simple_spi_tb.vhd"
eval vcom  $compdirectives  $tb_path/avalon_mm_simple_spi_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/avalon_mm_simple_tb.vhd"
eval vcom  $compdirectives  $tb_path/avalon_mm_simple_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/avalon_mm_vvc_pipeline_tb.vhd"
eval vcom  $compdirectives  $tb_path/avalon_mm_vvc_pipeline_tb.vhd

echo "eval vcom  $compdirectives  $tb_path/avalon_mm_vvc_th.vhd"
eval vcom  $compdirectives  $tb_path/avalon_mm_vvc_th.vhd

echo "eval vcom  $compdirectives  $tb_path/avalon_mm_vvc_tb.vhd"
eval vcom  $compdirectives  $tb_path/avalon_mm_vvc_tb.vhd