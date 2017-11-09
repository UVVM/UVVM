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

# Locations of ROOT, tcl_util, and this script
set UVVM_ALL_ROOT ../..
set TCL_UTIL_DIR tcl_util
set CURR_SCRIPT_DIR [ file dirname [file normalize $argv0]]
set TCL_UTIL_DIR $CURR_SCRIPT_DIR/$UVVM_ALL_ROOT/$TCL_UTIL_DIR

# Use tcl_util/util_base.tcl
source "$TCL_UTIL_DIR/util_base.tcl"


if {[batch_mode]} {
  onbreak {abort all; exit -f}
}

quit -sim

quietly set tb_part_path ../../bitvis_irqc
do $tb_part_path/script/compile_src.do $tb_part_path
do $tb_part_path/script/compile_tb_dep.do $tb_part_path
do $tb_part_path/script/compile_tb.do  $tb_part_path
do $tb_part_path/script/simulate_tb.do $tb_part_path


