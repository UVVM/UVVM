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

# This file may be called with an argument
# arg 1: Part directory of this library/module

# Overload quietly (Modelsim specific command) to let it work in Riviera-Pro
proc quietly { args } {
  if {[llength $args] == 0} {
    puts "quietly"
  } else {
    # this works since tcl prompt only prints the last command given. list prints "".
    uplevel $args; list;
  }
}

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  # puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
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


#------------------------------------------------------
# Set up source_path and default_target
#
#   0 args: regular UVVM directory structure expected
#   1 args: source directory specified, target will be current directory
#   2 args: source directory and target directory specified
#
#------------------------------------------------------

if { [info exists 1] } {
  quietly set source_path "$1"
  quietly set default_target 0

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
  # path from mpf-file in /sim folder
  quietly set source_path ".."
  quietly set target_path "$source_path/sim"
  quietly set default_target 1
}

namespace eval compile_util {
  variable local_source_path $source_path
  variable source_path $local_source_path/../uvvm_util
  variable target_path $local_source_path/../uvvm_util/sim

  variable argc -1

  source $local_source_path/../script/compile_src.do
}
namespace delete compile_util

namespace eval compile_vvc_framework {
  variable local_source_path $source_path
  variable source_path $local_source_path/../uvvm_vvc_framework
  variable target_path $local_source_path/../uvvm_vvc_framework/sim

  variable argc -1

  source $local_source_path/../script/compile_src.do
}
namespace delete compile_vvc_framework

do $source_path/../script/compile_src.do $source_path $target_path