onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal -childformat {{/gmii_simple_tb/eth_cfg.preamble -radix hexadecimal} {/gmii_simple_tb/eth_cfg.preamble_len -radix hexadecimal} {/gmii_simple_tb/eth_cfg.start_of_frame -radix hexadecimal} {/gmii_simple_tb/eth_cfg.dest_addr -radix hexadecimal} {/gmii_simple_tb/eth_cfg.source_addr -radix hexadecimal} {/gmii_simple_tb/eth_cfg.insert_vlan1 -radix hexadecimal} {/gmii_simple_tb/eth_cfg.vlan_type1 -radix hexadecimal} {/gmii_simple_tb/eth_cfg.vlan_setting1 -radix hexadecimal} {/gmii_simple_tb/eth_cfg.insert_vlan2 -radix hexadecimal} {/gmii_simple_tb/eth_cfg.vlan_type2 -radix hexadecimal} {/gmii_simple_tb/eth_cfg.vlan_setting2 -radix hexadecimal} {/gmii_simple_tb/eth_cfg.len_field_is_len -radix hexadecimal} {/gmii_simple_tb/eth_cfg.ether_type -radix hexadecimal}} -expand -subitemconfig {/gmii_simple_tb/eth_cfg.preamble {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.preamble_len {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.start_of_frame {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.dest_addr {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.source_addr {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.insert_vlan1 {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.vlan_type1 {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.vlan_setting1 {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.insert_vlan2 {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.vlan_type2 {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.vlan_setting2 {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.len_field_is_len {-height 15 -radix hexadecimal} /gmii_simple_tb/eth_cfg.ether_type {-height 15 -radix hexadecimal}} /gmii_simple_tb/eth_cfg
add wave -noupdate /gmii_simple_tb/clk
add wave -noupdate -childformat {{/gmii_simple_tb/gmii_from_dut.data -radix hexadecimal}} -expand -subitemconfig {/gmii_simple_tb/gmii_from_dut.data {-radix hexadecimal}} /gmii_simple_tb/gmii_from_dut
add wave -noupdate -childformat {{/gmii_simple_tb/gmii_to_dut.data -radix hexadecimal}} -expand -subitemconfig {/gmii_simple_tb/gmii_to_dut.data {-radix hexadecimal}} /gmii_simple_tb/gmii_to_dut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1667958 ps} 0}
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
WaveRestoreZoom {0 ps} {103815600 ps}
