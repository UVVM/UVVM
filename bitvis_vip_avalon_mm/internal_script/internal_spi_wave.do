onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /avalon_mm_spi_tb/clock_ena
add wave -noupdate -radix hexadecimal /avalon_mm_spi_tb/C_CLK_PERIOD
add wave -noupdate -expand -group SPI /avalon_mm_spi_tb/MISO
add wave -noupdate -expand -group SPI /avalon_mm_spi_tb/MOSI
add wave -noupdate -expand -group SPI /avalon_mm_spi_tb/SCLK
add wave -noupdate -expand -group SPI /avalon_mm_spi_tb/SS_n
add wave -noupdate /avalon_mm_spi_tb/avalon_mm_if
add wave -noupdate /avalon_mm_spi_tb/clk
add wave -noupdate /avalon_mm_spi_tb/clock_ena
add wave -noupdate /avalon_mm_spi_tb/dataavailable
add wave -noupdate /avalon_mm_spi_tb/endofpacket
add wave -noupdate /avalon_mm_spi_tb/irq
add wave -noupdate /avalon_mm_spi_tb/readyfordata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1064967 ps} 0}
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
WaveRestoreZoom {0 ps} {3622500 ps}
