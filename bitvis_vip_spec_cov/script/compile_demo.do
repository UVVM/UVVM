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
do $uart_path/script/compile_src.do $uart_path

# Compile UVVM (including bitvis_vip_spec_vs_verif)
quietly set spec_vs_verif_path "$root_path/bitvis_vip_spec_vs_verif"
do $spec_vs_verif_path/script/compile_lib.do uvvm_util
do $spec_vs_verif_path/script/compile_lib.do uvvm_vvc_framework
do $spec_vs_verif_path/script/compile_lib.do bitvis_vip_scoreboard
do $spec_vs_verif_path/script/compile_lib.do xConstrRandFuncCov
do $spec_vs_verif_path/script/compile_lib.do bitvis_vip_spec_vs_verif
do $spec_vs_verif_path/script/compile_lib.do bitvis_vip_uart
do $spec_vs_verif_path/script/compile_lib.do bitvis_vip_sbi

quietly set lib_name "bitvis_vip_spec_vs_verif"

# Compile DUT
#do $root_path/bitvis_uart/script/1_compile_src.do $root_path/bitvis_vip_sbi
set uart_part_path $root_path/bitvis_uart
set compdirectives "-2008 -work $lib_name"
eval vcom  $compdirectives  $uart_part_path/src/uart_pkg.vhd
eval vcom  $compdirectives  $uart_part_path/src/uart_pif_pkg.vhd
eval vcom  $compdirectives  $uart_part_path/src/uart_pif.vhd
eval vcom  $compdirectives  $uart_part_path/src/uart_core.vhd
eval vcom  $compdirectives  $uart_part_path/src/uart.vhd


if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}


# Select testbench version based on the demo type (basic or advanced)

quietly set demo_version basic
if { [info exists 2] } {
  quietly set demo_version "$2"
  unset 2
}

if { [string equal -nocase $demo_version "basic"] } {
  echo "\n\n\n=== Compiling Basic Demo TB\n"
  echo "eval vcom  $compdirectives  $spec_vs_verif_path/demo/basic_usage/"
  eval vcom  $compdirectives  $spec_vs_verif_path/demo/basic_usage/uart_vvc_th.vhd
  eval vcom  $compdirectives  $spec_vs_verif_path/demo/basic_usage/uart_vvc_tb.vhd
} else {
  echo "\n\n\n=== Compiling Advanced Demo TB\n"
  echo "eval vcom  $compdirectives  $spec_vs_verif_path/demo/basic_usage/"
  eval vcom  $compdirectives  $spec_vs_verif_path/demo/advanced_usage/uart_vvc_th.vhd
  eval vcom  $compdirectives  $spec_vs_verif_path/demo/advanced_usage/uart_vvc_tb.vhd
}
