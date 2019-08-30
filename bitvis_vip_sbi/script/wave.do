onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label {SBI DTT} -expand -subitemconfig {/dtt_demo_tb/i_test_harness/i1_sbi_vvc/dtt_transaction_info.bt -expand} /dtt_demo_tb/i_test_harness/i1_sbi_vvc/dtt_transaction_info
add wave -noupdate -label {UART_RX DTT} -expand /dtt_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_rx/dtt_transaction_info
add wave -noupdate -label {UART_TX DTT} -expand -subitemconfig {/dtt_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/dtt_transaction_info.bt -expand /dtt_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/dtt_transaction_info.ct -expand} /dtt_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/dtt_transaction_info
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {368294993 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 158
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {7232729 ps}
