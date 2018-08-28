onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/clk
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/arst
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/cs
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/addr
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/wr
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/rd
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/wdata
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/rdata
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/rx_a
add wave -noupdate -expand -group {UART 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_3/tx
add wave -noupdate -expand -group {SBI VVC 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_sbi_vvc_3/transaction_info
add wave -noupdate -expand -group {SBI VVC 3} -radix hexadecimal -expand /internal_uart_vvc_tb_d/i_test_harness/i_sbi_vvc_3/sbi_vvc_master_if
add wave -noupdate -expand -group {UART VVC 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_vvc_3/i1_uart_rx/transaction_info
add wave -noupdate -expand -group {UART VVC 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_vvc_3/i1_uart_rx/uart_vvc_rx
add wave -noupdate -expand -group {UART VVC 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_vvc_3/i1_uart_tx/transaction_info
add wave -noupdate -expand -group {UART VVC 3} -radix hexadecimal /internal_uart_vvc_tb_d/i_test_harness/i_uart_vvc_3/i1_uart_tx/uart_vvc_tx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1411622 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
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
WaveRestoreZoom {0 ps} {27512625 ps}
