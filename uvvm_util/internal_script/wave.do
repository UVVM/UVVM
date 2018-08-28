onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /methods_tb/bol
add wave -noupdate -label shared_initialised_util /methods_pkg/shared_initialised_util
add wave -noupdate -label shared_msg_id_panel /methods_pkg/shared_msg_id_panel
add wave -noupdate -label shared_log_file_name_is_set /methods_pkg/shared_log_file_name_is_set
add wave -noupdate -label shared_alert_file_name_is_set /methods_pkg/shared_alert_file_name_is_set
add wave -noupdate -label shared_warned_time_stamp_trunc /methods_pkg/shared_warned_time_stamp_trunc
add wave -noupdate -label shared_alert_attention /methods_pkg/shared_alert_attention
add wave -noupdate -label shared_stop_limit /methods_pkg/shared_stop_limit
add wave -noupdate -label shared_log_hdr_for_waveview /methods_pkg/shared_log_hdr_for_waveview
add wave -noupdate -label shared_current_log_hdr.normal /methods_pkg/shared_current_log_hdr.normal
add wave -noupdate -label shared_current_log_hdr.large /methods_pkg/shared_current_log_hdr.large
add wave -noupdate -label shared_current_log_hdr.xl /methods_pkg/shared_current_log_hdr.xl
add wave -noupdate -label shared_seed1 /methods_pkg/shared_seed1
add wave -noupdate -label shared_seed2 /methods_pkg/shared_seed2
add wave -noupdate -label C_BURIED_SCOPE /methods_pkg/C_BURIED_SCOPE
add wave -noupdate /methods_tb/slv8
add wave -noupdate /methods_tb/slv128
add wave -noupdate /methods_tb/u8
add wave -noupdate /methods_tb/s8
add wave -noupdate /methods_tb/i
add wave -noupdate /methods_tb/r
add wave -noupdate /methods_tb/sl
add wave -noupdate /methods_tb/ctr
add wave -noupdate /methods_tb/C_RANDOM_MIN_VALUE
add wave -noupdate /methods_tb/C_RANDOM_MAX_VALUE
add wave -noupdate /methods_tb/ctr
add wave -noupdate /methods_tb/clk100M
add wave -noupdate /methods_tb/clk100M_ena
add wave -noupdate /methods_tb/clk200M
add wave -noupdate /methods_tb/clk200M_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {465408 ps} 0} {{Cursor 2} {1760000 ps} 0} {{Cursor 3} {1810000 ps} 0}
configure wave -namecolwidth 419
configure wave -valuecolwidth 176
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
configure wave -timelineunits ps
update
WaveRestoreZoom {1751823 ps} {1862236 ps}
