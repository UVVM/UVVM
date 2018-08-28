
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_avalon_mm.avalon_mm_spi_tb
add log -r /*

do ../internal_script/internal_spi_wave.do

run -all
