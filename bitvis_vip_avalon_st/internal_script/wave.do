onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_st_simple_tb/clock_ena
add wave -noupdate /avalon_st_simple_tb/C_CLK_PERIOD
add wave -noupdate /avalon_st_simple_tb/clk_slave
add wave -noupdate -childformat {{/avalon_st_simple_tb/avalon_st_from_dut.data -radix hexadecimal}} -expand -subitemconfig {/avalon_st_simple_tb/avalon_st_from_dut.data {-height 15 -radix hexadecimal}} /avalon_st_simple_tb/avalon_st_from_dut
add wave -noupdate /avalon_st_simple_tb/clk_master
add wave -noupdate -childformat {{/avalon_st_simple_tb/avalon_st_to_dut.data -radix hexadecimal}} -expand -subitemconfig {/avalon_st_simple_tb/avalon_st_to_dut.data {-height 15 -radix hexadecimal}} /avalon_st_simple_tb/avalon_st_to_dut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1537284 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 387
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {1319132 ps} {2004257 ps}
