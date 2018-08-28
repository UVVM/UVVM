onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_vvc_tb/arst
add wave -noupdate /spi_vvc_tb/clk
add wave -noupdate /spi_vvc_tb/clk_ena
add wave -noupdate -divider VVC-to-VVC
add wave -noupdate /spi_vvc_tb/spi_vvc_if_1
add wave -noupdate -divider spi_master_dut_to_slave_VVC
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/sbi_if
add wave -noupdate /spi_vvc_tb/spi_vvc_if_2
add wave -noupdate -divider spi_slave_vvc_to_master_dut
add wave -noupdate -childformat {{/spi_vvc_tb/sbi_vvc_if.wdata -radix hexadecimal}} -subitemconfig {/spi_vvc_tb/sbi_vvc_if.wdata {-height 15 -radix hexadecimal}} /spi_vvc_tb/sbi_vvc_if
add wave -noupdate /spi_vvc_tb/spi_vvc_if_2
add wave -noupdate -childformat {{/spi_vvc_tb/i_spi_master_pif/sbi_if.wdata -radix hexadecimal}} -subitemconfig {/spi_vvc_tb/i_spi_master_pif/sbi_if.wdata {-height 15 -radix hexadecimal}} /spi_vvc_tb/i_spi_master_pif/sbi_if
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/spi_ss_n
add wave -noupdate -radix hexadecimal /spi_vvc_tb/i_spi_master_pif/di_o
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/wren_o
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/wr_ack_i
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/do_valid_i
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/do_i
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/sbi_wr_rdy
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/sbi_rd_rdy
add wave -noupdate -radix hexadecimal /spi_vvc_tb/i_spi_master_pif/spi_to_sbi_data
add wave -noupdate /spi_vvc_tb/i_spi_master_pif/sbi_write_state
add wave -noupdate -divider spi_master_vvc_to_slave_dut
add wave -noupdate /spi_vvc_tb/sbi_vvc_if
add wave -noupdate /spi_vvc_tb/spi_vvc_if_3
add wave -noupdate -divider spi_slave_dut_to_master_vvc
add wave -noupdate /spi_vvc_tb/sbi_vvc_if
add wave -noupdate /spi_vvc_tb/spi_vvc_if_3
add wave -noupdate -childformat {{/spi_vvc_tb/i_spi_slave_pif/sbi_if.wdata -radix hexadecimal}} -subitemconfig {/spi_vvc_tb/i_spi_slave_pif/sbi_if.wdata {-radix hexadecimal}} /spi_vvc_tb/i_spi_slave_pif/sbi_if
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/spi_ss_n
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/di_o
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/wren_o
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/wr_ack_i
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/do_valid_i
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/do_i
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/sbi_wr_rdy
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/sbi_rd_rdy
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/spi_to_sbi_data
add wave -noupdate /spi_vvc_tb/i_spi_slave_pif/sbi_write_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {1635150966 ps} 0} {{Cursor 3} {2986421555 ps} 0} {{Cursor 4} {5677607519 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 349
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {16158471 ns}
