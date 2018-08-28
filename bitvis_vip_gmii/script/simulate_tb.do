
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_gmii.gmii_simple_tb
add log -r /*

do ../script/wave.do
#do ../script/list.do
run -all
