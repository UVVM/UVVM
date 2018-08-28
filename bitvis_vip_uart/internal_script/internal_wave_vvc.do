onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /methods_pkg/shared_log_hdr_for_waveview
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/addr
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/arst
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/c2p
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/clk
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/cs
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/wdata
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/rdata
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/rdata_i
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/p2c
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/p2c_i
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/rd
add wave -noupdate -expand -group PIF -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_pif/wr
add wave -noupdate -group Generics -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/GC_CLOCKS_PER_BIT
add wave -noupdate -group Generics -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/GC_START_BIT
add wave -noupdate -group Generics -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/GC_STOP_BIT
add wave -noupdate -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/arst
add wave -noupdate -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/c2p
add wave -noupdate -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/p2c
add wave -noupdate -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/c2p_i
add wave -noupdate -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/clk
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_a
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_active
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_bit_counter
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_bit_samples
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_buffer
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_clk_counter
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_data
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_data_valid
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/uart_rx/vr_rx_data_idx
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_just_active
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/rx_s
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/parity_err
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/stop_err
add wave -noupdate -expand -group {Core RX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/transient_err
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_active
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_bit_counter
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_buffer
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_clk_counter
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_data
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_data_valid
add wave -noupdate -expand -group {Core TX} -radix hexadecimal /uart_vvc_new_tb/i_test_harness/i_uart/i_uart_core/tx_ready
add wave -noupdate -expand -group {VVC Transactions} /uart_vvc_new_tb/i_test_harness/i1_sbi_vvc/transaction_info
add wave -noupdate -expand -group {VVC Transactions} /uart_vvc_new_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/transaction_info
add wave -noupdate -expand -group {VVC Transactions} /uart_vvc_new_tb/i_test_harness/i1_uart_vvc/i1_uart_rx/transaction_info
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {191085000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 291
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
WaveRestoreZoom {0 ps} {201691875 ps}
