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
if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
  onbreak {abort all; exit -f}
} else {
  onerror {abort all}
}

quietly set tb_part_path ../../bitvis_uart
do $tb_part_path/script/1_compile_src.do  $tb_part_path
do $tb_part_path/script/2_compile_util.do $tb_part_path
do $tb_part_path/script/3_compile_tb_dep_ex_util.do $tb_part_path
do $tb_part_path/script/4_compile_uart_vvc_tb.do  $tb_part_path
vsim  bitvis_uart.uart_vvc_tb
if {[catch {eval "source ../script/wave_modelsim.do"} message]} { 
  puts $message
  quit -force -code 1
}

