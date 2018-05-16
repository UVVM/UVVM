#========================================================================================================================
# Copyright (c) 2017 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

onerror {resume}
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/clk
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/arst
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/cs
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/addr
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/wr
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/rd
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/wdata
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/rdata
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/rx_a
add wave -noupdate -expand -group {UART DUT} -radix hexadecimal /uart_vvc_tb/i_test_harness/i_uart/tx
add wave -noupdate -expand -group {SBI VVC} -radix hexadecimal /uart_vvc_tb/i_test_harness/i1_sbi_vvc/transaction_info
add wave -noupdate -expand -group {SBI VVC} -radix hexadecimal -expand /uart_vvc_tb/i_test_harness/i1_sbi_vvc/sbi_vvc_master_if
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_tb/i_test_harness/i1_uart_vvc/i1_uart_rx/transaction_info
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_tb/i_test_harness/i1_uart_vvc/i1_uart_rx/uart_vvc_rx
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/transaction_info
add wave -noupdate -expand -group {UART VVC} -radix hexadecimal /uart_vvc_tb/i_test_harness/i1_uart_vvc/i1_uart_tx/uart_vvc_tx
quietly wave cursor active 1
update
