# Run the testbench
vsim  -pedanticerrors -gGC_DATA_WIDTH=8 -gGC_USER_WIDTH=2 -gGC_ID_WIDTH=2 -gGC_DEST_WIDTH=2 -nocollapse bitvis_vip_axistream.axistream_vvc_simple_tb 
add log -r /*

# do ../sim/wave.do   
# do ../sim/wave_vvc.do

run -all
