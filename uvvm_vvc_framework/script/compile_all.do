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

# This file compiles uvvm_util and uvvm_framework, and by default all VIPs listed in file vip_list.txt

# This file may be called with arguments
# arg 1: directory of UVVM folder
# arg 2: directory of VIP list file

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

quietly set uvvm_path "../../"

if { [info exists 1] } {
  # path source
  quietly set uvvm_path "$1"
  unset 1
}


quietly set vip_list_path "$uvvm_path/uvvm_vvc_framework/script/vip_list.txt"

if { [info exists 2] } {
  # vip list source
  quietly set vip_list_path "$2"
  unset 2
}

#------------------------------------------------------
# Compile UVVM Util
#------------------------------------------------------
echo "\n\n\n=== Compiling UVVM Util\n"

# Set up util_part_path
quietly set part_name "uvvm_util"
quietly set util_part_path "$uvvm_path/$part_name"

do $util_part_path/script/compile_src.do $util_part_path


#------------------------------------------------------
# Compile UVVM VVC Framework
#----------------------------------
echo "\n\n\n=== Compiling UVVM VVC Framework\n"

# Set up part_path for uvvm_vvc_framework
#------------------------------------------------------
quietly set part_name "uvvm_vvc_framework"
quietly set uvvm_part_path "$uvvm_path/$part_name"

do $uvvm_part_path/script/compile_src.do $uvvm_part_path


#------------------------------------------------------
# Read vip_list.txt
#------------------------------------------------------
quietly set fp [open $vip_list_path r]
quietly set file_data [read $fp]
close $fp


#------------------------------------------------------
# Compile VIPs
#------------------------------------------------------
foreach item $file_data {
  quietly set vip_path "$uvvm_path/$item"
  do $vip_path/script/compile_src.do $vip_path
}


#------------------------------------------------------
# Compile demos
#------------------------------------------------------

# Set up part_path for uvvm_vvc_framework
#------------------------------------------------------
quietly set part_name "uvvm_vvc_framework"
quietly set uvvm_part_path "$uvvm_path/$part_name"

do $uvvm_part_path/script/compile_demo_tb.do $uvvm_part_path