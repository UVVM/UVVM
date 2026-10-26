#================================================================================================================================
# Copyright 2024 UVVM
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {questasim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $simulator_version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting to use Modelsim commands."
    quietly set simulator "modelsim"
  }
} else {
    puts "vsim -version failed with the following message:\n $message"
    abort all
}

onerror {resume}
if {$simulator == "modelsim"} {
  quietly WaveActivateNextPane {} 0
}
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/clk 
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/arst
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/cs
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/addr 
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/wr
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/rd
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/wdata
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/rdata
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/rx_a
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i_uart/tx
add wave -noupdate -expand -group {SBI VVC} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i1_sbi_vvc/transaction_info
add wave -noupdate -expand -group {SBI VVC} -radix hexadecimal -expand /uart_vvc_demo_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if 
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_rx/transaction_info 
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_rx/uart_vvc_rx
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/transaction_info
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_demo_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/uart_vvc_tx 
if {$simulator == "modelsim"} {
  TreeUpdate [SetDefaultTree]
  WaveRestoreCursors {{Cursor 1} {1411622 ps} 0}
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
  WaveRestoreZoom {0 ps} {27512625 ps}
}
quietly wave cursor active 1
update
