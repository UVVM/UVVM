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
set generic1 0

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
  set generic1 "$4"
  unset 4
}


vsim -gGC_TEST=$run_test -gGC_DELTA_DELAYED_VVC_CLK=$generic1 $library.$testbench

run -all