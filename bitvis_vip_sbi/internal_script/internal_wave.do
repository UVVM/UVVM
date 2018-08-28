onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {SBI Slave 1}
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/clk
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/rst
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/sbi_cs
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/sbi_rd
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/sbi_wr
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/sbi_addr
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/sbi_wdata
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/sbi_rdata
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_sbi_slave/data_in
add wave -noupdate -divider {SBI Slave 2}
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/clk
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/rst
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/sbi_cs
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/sbi_rd
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/sbi_wr
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/sbi_addr
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/sbi_wdata
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/sbi_rdata
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_sbi_slave/data_in
add wave -noupdate -divider {GPIO VVC 1}
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_gpio_vvc/gpio_vvc_din
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i1_gpio_vvc/gpio_vvc_dout
add wave -noupdate -divider {GPIO VVC 2}
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_gpio_vvc/gpio_vvc_din
add wave -noupdate -radix hexadecimal /sbi_tb/i_test_harness/i2_gpio_vvc/gpio_vvc_dout
add wave -noupdate -divider {SBI VVC 1}
add wave -noupdate -childformat {{/sbi_tb/i_test_harness/i1_sbi_vvc/transaction_info.operation} {/sbi_tb/i_test_harness/i1_sbi_vvc/transaction_info.addr -radix unsigned} {/sbi_tb/i_test_harness/i1_sbi_vvc/transaction_info.data -radix unsigned} {/sbi_tb/i_test_harness/i1_sbi_vvc/transaction_info.msg}} /sbi_tb/i_test_harness/i1_sbi_vvc/transaction_info
add wave -noupdate /sbi_tb/i_test_harness/i1_sbi_vvc/clk
add wave -noupdate /sbi_tb/i_test_harness/i1_sbi_vvc/rst
add wave -noupdate -childformat {{/sbi_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if.addr -radix unsigned} {/sbi_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if.rdata -radix unsigned}} -subitemconfig {/sbi_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if.addr {-radix unsigned} /sbi_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if.rdata {-radix unsigned}} /sbi_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if
add wave -noupdate /sbi_tb/i_test_harness/i1_sbi_vvc/executor_is_busy
add wave -noupdate /sbi_tb/i_test_harness/i1_sbi_vvc/queue_is_increasing
add wave -noupdate /sbi_tb/i_test_harness/i1_sbi_vvc/terminate_current_cmd
add wave -noupdate -radix unsigned /sbi_tb/i_test_harness/i1_sbi_vvc/last_cmd_idx_executed
add wave -noupdate /sbi_tb/i_test_harness/i1_sbi_vvc/vvc_config
add wave -noupdate -divider {SBI VVC 2}
add wave -noupdate -childformat {{/sbi_tb/i_test_harness/i2_sbi_vvc/transaction_info.operation} {/sbi_tb/i_test_harness/i2_sbi_vvc/transaction_info.addr -radix unsigned} {/sbi_tb/i_test_harness/i2_sbi_vvc/transaction_info.data -radix unsigned} {/sbi_tb/i_test_harness/i2_sbi_vvc/transaction_info.msg}} /sbi_tb/i_test_harness/i2_sbi_vvc/transaction_info
add wave -noupdate /sbi_tb/i_test_harness/i2_sbi_vvc/clk
add wave -noupdate /sbi_tb/i_test_harness/i2_sbi_vvc/rst
add wave -noupdate -childformat {{/sbi_tb/i_test_harness/i2_sbi_vvc/sbi_vvc_master_if.addr -radix unsigned} {/sbi_tb/i_test_harness/i2_sbi_vvc/sbi_vvc_master_if.rdata -radix unsigned}} -subitemconfig {/sbi_tb/i_test_harness/i2_sbi_vvc/sbi_vvc_master_if.addr {-radix unsigned} /sbi_tb/i_test_harness/i2_sbi_vvc/sbi_vvc_master_if.rdata {-radix unsigned}} /sbi_tb/i_test_harness/i2_sbi_vvc/sbi_vvc_master_if
add wave -noupdate /sbi_tb/i_test_harness/i2_sbi_vvc/executor_is_busy
add wave -noupdate /sbi_tb/i_test_harness/i2_sbi_vvc/queue_is_increasing
add wave -noupdate /sbi_tb/i_test_harness/i2_sbi_vvc/terminate_current_cmd
add wave -noupdate -radix unsigned /sbi_tb/i_test_harness/i2_sbi_vvc/last_cmd_idx_executed
add wave -noupdate /sbi_tb/i_test_harness/i2_sbi_vvc/vvc_config
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18083 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 333
configure wave -valuecolwidth 152
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
WaveRestoreZoom {0 ps} {199054 ps}
