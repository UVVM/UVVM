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
#Just in case...
quietly quit -sim

# Detect simulator
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  # puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $simulator_version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting use use Modelsim commands."
    quietly set simulator "modelsim"
  }
} else {
    puts "vsim -version failed with the following message:\n $message"
    abort all
}

# path from mpf-file in sim
quietly set root_path "../.."

if { [info exists 1] } {
  # path from this part to target part
  quietly set root_path "$1/.."
  unset 1
}


# (Re-)Generate library and Compile source files
#--------------------------------------------------
quietly set uart_path "$root_path/bitvis_uart"
do $uart_path/script/1_compile_src.do $uart_path

quietly set sb_path "$root_path/bitvis_vip_scoreboard"
do $sb_path/script/compile_lib.do uvvm_util
do $sb_path/script/compile_lib.do uvvm_vvc_framework
do $sb_path/script/compile_lib.do bitvis_vip_scoreboard
do $root_path/bitvis_vip_uart/script/compile_bfm.do $root_path/bitvis_vip_uart
do $root_path/bitvis_vip_sbi/script/compile_bfm.do $root_path/bitvis_vip_sbi

quietly set lib_name "bitvis_vip_scoreboard"

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#------------------------------------------------------
# Compile src files
#------------------------------------------------------
echo "\n\n\n=== Compiling TB\n"
echo "eval vcom  $compdirectives  $source_path/script/$item"
eval vcom  $compdirectives  $sb_path/demo/sb_uart_sbi_demo_tb.vhd
