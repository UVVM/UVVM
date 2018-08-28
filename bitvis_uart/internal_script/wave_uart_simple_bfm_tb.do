onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /uart_simple_bfm_tb/C_CLK_PERIOD
add wave -noupdate -radix hexadecimal /uart_simple_bfm_tb/clock_ena
add wave -noupdate -divider Clock,Reset,SBI
add wave -noupdate /uart_simple_bfm_tb/clk
add wave -noupdate /uart_simple_bfm_tb/arst
add wave -noupdate /uart_simple_bfm_tb/cs
add wave -noupdate /uart_simple_bfm_tb/addr
add wave -noupdate /uart_simple_bfm_tb/wr
add wave -noupdate /uart_simple_bfm_tb/rd
add wave -noupdate -radix hexadecimal /uart_simple_bfm_tb/wdata
add wave -noupdate -radix hexadecimal /uart_simple_bfm_tb/rdata
add wave -noupdate /uart_simple_bfm_tb/ready
add wave -noupdate /uart_simple_bfm_tb/rx
add wave -noupdate /uart_simple_bfm_tb/tx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 244
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {48087375 ps}
