#========================================================================================================================
# Copyright (c) 2019 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

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