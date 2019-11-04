#========================================================================================================================
# Copyright (c) 2018 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

set library 0
set testbench 0
set run_test 0
set data_width 0
set user_width 0
set id_width 0
set dest_width 0
set include_tuser 0

if { [info exists 1] } {
  set library "$1"
  unset 1
}

if { [info exists 2] } {
  set testbench "$2"
  unset 2
}

if { [info exists 3] } {
  set run_test "$3"
  unset 3
}

if { [info exists 4] } {
  set data_width "$4"
  unset 4
}

if { [info exists 5] } {
  set user_width "$5"
  unset 5
}

if { [info exists 6] } {
  set id_width "$6"
  unset 6
}

if { [info exists 7] } {
  set dest_width "$7"
  unset 7
}

if { [info exists 8] } {
  set include_tuser "$8"
  unset 8
}



vsim -gGC_TEST=$run_test -gGC_DATA_WIDTH=$data_width -gGC_USER_WIDTH=$user_width -gGC_ID_WIDTH=$id_width -gGC_DEST_WIDTH=$dest_width -gGC_INCLUDE_TUSER=$include_tuser $library.$testbench

run -all