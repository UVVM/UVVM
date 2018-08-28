onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /avalon_mm_tb/clock_ena
add wave -noupdate -radix hexadecimal /avalon_mm_tb/C_CLK_PERIOD
add wave -noupdate /avalon_mm_tb/avalon_mm_if
add wave -noupdate /avalon_mm_tb/clk
add wave -noupdate /avalon_mm_tb/clock_ena
add wave -noupdate /avalon_mm_tb/empty
add wave -noupdate /avalon_mm_tb/full
add wave -noupdate /avalon_mm_tb/usedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {596937 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 431
configure wave -valuecolwidth 94
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
WaveRestoreZoom {0 ps} {4452 ns}
