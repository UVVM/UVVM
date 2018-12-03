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

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}
quit -sim   #Just in case...

# VIP GPIO : TB
#------------------------------------------------------
quietly set lib_name "bitvis_vip_gpio"
quietly set part_name "bitvis_vip_gpio"
# path from mpf-file in sim
quietly set vip_gpio_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set vip_gpio_part_path "$1/..//$part_name"
  unset 1
}

set compdirectives "-2008 -work $lib_name"

# Testbenches reside in the design library. Hence no regeneration of lib.
#------------------------------------------------------------------------
eval vcom  $compdirectives  $vip_gpio_part_path/internal_tb/gpio_vip_tb.vhd



