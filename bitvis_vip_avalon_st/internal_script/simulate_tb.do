
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_avalon_st.avalon_st_simple_tb
add log -r /*

do ../internal_script/wave.do

run -all
