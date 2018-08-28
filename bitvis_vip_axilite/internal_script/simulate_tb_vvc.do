
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_axilite.axilite_tb
add log -r /*

do ../internal_script/internal_wave.do

run -all
