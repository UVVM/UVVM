# Compile Bitvis VIP GPIO
#----------------------------------

# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up vip_gpio_part_path and lib_name
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

do $vip_gpio_part_path/internal_script/internal_compile_src.do $vip_gpio_part_path
