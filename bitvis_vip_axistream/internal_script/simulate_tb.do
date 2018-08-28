
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_axistream.axistream_simple_tb
add log -r /*

do ../internal_script/internal_wave.do

run -all
do ../sim/wave_simple.do
