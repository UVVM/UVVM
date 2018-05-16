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

# This file may be called with arguments:
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

#------------------------------------------------------
# Set up source_path and default_target
#
#   0 args: regular UVVM directory structure expected
#   1 args: source directory specified, target will be current directory
#
#------------------------------------------------------
quietly set part_name "uvvm_vvc_framework"

if { [info exists 1] } {
  echo "\nUser specified source directory"
  quietly set source_path "$1"
  quietly set target_path [pwd]
  quietly set default_target 0
  unset 1
} else {
  echo "\nDefault output directory"
  # path from mpf-file in /sim folder
  quietly set source_path "../..//$part_name"
  quietly set target_path $source_path
  quietly set default_target 1
}
echo "Source path: $source_path"
echo "Taget path: $target_path"

#------------------------------------------------------
# Compile demos
#------------------------------------------------------

# IRQC
do $source_path/../bitvis_irqc/script/compile_src.do $source_path/../bitvis_irqc
do $source_path/../bitvis_irqc/script/compile_tb.do $source_path/../bitvis_irqc

# UART
do $source_path/../bitvis_uart/script/1_compile_src.do $source_path/../bitvis_uart
do $source_path/../bitvis_uart/script/4_compile_uart_vvc_tb.do $source_path/../bitvis_uart