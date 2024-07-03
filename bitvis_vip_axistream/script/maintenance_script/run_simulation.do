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

set library 0
set testbench 0
set run_test 0
set data_width 0
set user_width 0
set id_width 0
set dest_width 0
set include_tuser 0
set use_setup_and_hold 0

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
  if {$8 == 1} {
    set include_tuser "true"
  } else {
    set include_tuser "false"
  }
  unset 8
}

if { [info exists 9] } {
  if {$9 == 1} {
    set use_setup_and_hold "true"
  } else {
    set use_setup_and_hold "false"
  }
  unset 9
}


vsim -gGC_TESTCASE=$run_test -gGC_DATA_WIDTH=$data_width -gGC_USER_WIDTH=$user_width -gGC_ID_WIDTH=$id_width -gGC_DEST_WIDTH=$dest_width -gGC_INCLUDE_TUSER=$include_tuser -gGC_USE_SETUP_AND_HOLD=$use_setup_and_hold $library.$testbench

run -all