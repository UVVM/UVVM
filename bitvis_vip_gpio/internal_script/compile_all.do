#========================================================================================================================
# Copyright (c) 2017 by Bitvis AS.  All rights reserved.
#
# BITVIS UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH BITVIS UTILITY LIBRARY.
#========================================================================================================================

# This file may be called with an argument
# arg 1: Part directory of this library/module


# Compile the external dependencies used by the BFM
# and VVC
#------------------------------------------------------
do ../script/compile_dep.do

# Compile the BFM and VVC
#------------------------------------------------------
do ../script/compile_src.do


# Compile Bitvis VIP sbi
#----------------------------------

# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up vip_sbi_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_vip_sbi"
quietly set part_name "bitvis_vip_sbi"
# path from mpf-file in sim
quietly set vip_sbi_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_sbi_part_path "$1/..//$part_name"
  unset 1
}

#do $vip_sbi_part_path/script/compile_src_bfm.do $vip_sbi_part_path
do $vip_sbi_part_path/script/compile_src.do $vip_sbi_part_path

# VIP uart : BFM
#------------------------------------------------------
quietly set lib_name "bitvis_vip_uart"
quietly set part_name "bitvis_vip_uart"
# path from mpf-file in sim
quietly set vip_uart_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_uart_part_path "$1/..//$part_name"
  unset 1
}

#do $vip_uart_part_path/script/compile_src_bfm.do $vip_uart_part_path
do $vip_uart_part_path/script/compile_src.do $vip_uart_part_path


# VIP GPIO : TB
#------------------------------------------------------------------------
do ./compile_tb.do




