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

if { [string equal -nocase $simulator "modelsim"] } {
  ###########
  # Fix possible vmap bug
  do fix_vmap.tcl
  ##########
}


#
# Set up vip_uart_part_path and default_library
#------------------------------------------------------
quietly set part_name "bitvis_vip_uart"
# path from mpf-file in sim
quietly set vip_uart_part_path "../..//$part_name"

# argument number 1 - user specified input directory
if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_uart_part_path "$1/..//$part_name"
  unset 1
}
# argument number 2 - user speficied output directory
if {$argc >= 2} {
  echo "\nUser specified output directory"
  quietly set destination_path "$2"
  quietly set default_library 0
} else {
  echo "\nDefault output directory"
  quietly set destination_path vip_uart_part_path
  quietly set default_library 1
}


#
# Read compile_order.txt and set lib_name
#--------------------------------------------------
quietly set fp [open "$vip_uart_part_path/script/compile_order.txt" r]
quietly set file_data [read $fp]
quietly set lib_name [lindex $file_data 2]
close $fp

#
# (Re-)Generate library and Compile source files
#--------------------------------------------------
echo "\n\nRe-gen lib and compile $lib_name source"
if {$default_library} {
  if {[file exists $vip_uart_part_path/sim/$lib_name]} {
    file delete -force $vip_uart_part_path/sim/$lib_name
  }
  if {![file exists $vip_uart_part_path/sim]} {
    file mkdir $vip_uart_part_path/sim
  }
} else {
  if {![file exists $destination_path/$lib_name]} {
    file mkdir $destination_path/$lib_name
  }
}

if {$default_library} {
  vlib $vip_uart_part_path/sim/$lib_name
  vmap $lib_name $vip_uart_part_path/sim/$lib_name
} else {
  vlib $destination_path/$lib_name
  vmap $lib_name $destination_path/$lib_name
}

if { [string equal -nocase $simulator "modelsim"] } {
  quietly set compdirectives "-quiet -suppress 1346,1236 -2008 -work $lib_name"
} elseif { [string equal -nocase $simulator "rivierapro"] } {
  set compdirectives "-2008 -nowarn COMP96_0564 -nowarn COMP96_0048 -dbg -work $lib_name"
}

#
# Compile src files
#--------------------------------------------------
echo "\n\n\n=== Compiling $lib_name source\n"
quietly set idx 0
foreach item $file_data {
  if {$idx > 2} {
    echo "eval vcom  $compdirectives  $vip_uart_part_path/sim/$item"
    eval vcom  $compdirectives  $vip_uart_part_path/sim/$item
  }
  incr idx 1
}
