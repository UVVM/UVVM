
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_avalon_mm.avalon_mm_vvc_tb
add log -r /*

do ../internal_script/internal_vvc_wave.do

run -all
