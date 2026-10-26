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

#-----------------------------------------------------------------------
# List dependencies
#-----------------------------------------------------------------------
echo "********************* DEPENDENCIES ***************************"
echo "1. UVVM Utility library"
echo "2. UVVM VVC Framework library"
echo "3. Bitvis VIP Scoreboard"
echo "**************************************************************"

#-----------------------------------------------------------------------
# This file may be called with 0 to 2 arguments:
#
#   0 args: regular UVVM directory structure expected
#   1 args: source directory specified, target will be current directory
#   2 args: source directory and target directory specified
#-----------------------------------------------------------------------

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

#-----------------------------------------------------------------------
# Set up source_path and target_path
#-----------------------------------------------------------------------
if { [info exists 1] } {
  quietly set source_path "$1"

  if {$argc == 1} {
    echo "\nUser specified source directory"
    quietly set target_path "$source_path/sim"
  } elseif {$argc >= 2} {
    echo "\nUser specified source and target directory"
    quietly set target_path "$2"
  }
  unset 1
} else {
  echo "\nDefault output directory"
  quietly set source_path ".."
  quietly set target_path "$source_path/sim"
}

#-----------------------------------------------------------------------
# Call top-level compile script with local library arguments
#-----------------------------------------------------------------------
do $source_path/../script/compile_src.do $source_path $target_path