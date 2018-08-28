
quit -sim

# Run the testbench
vsim  -pedanticerrors  -nocollapse bitvis_vip_uart.uart_vvc_new_tb
add log -r /*

do ../internal_script/internal_wave_vvc.do
run -all
