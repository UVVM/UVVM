
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_avalon_mm.avalon_mm_tb
add log -r /*

do ../internal_script/internal_simple_tb_wave.do

run -all
