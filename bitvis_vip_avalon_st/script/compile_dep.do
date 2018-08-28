# Compile Bitvis Util
#----------------------------------

# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up ieee proposed part_path and lib_name
#------------------------------------------------------
quietly set lib_name "ieee_proposed"
quietly set part_name "x_ieee_proposed"
# path from mpf-file in sim
quietly set ieee_proposed_part_path "../../$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set ieee_proposed_part_path "$1/../$part_name"
  #unset 1
}

do $ieee_proposed_part_path/script/compile_src.do $ieee_proposed_part_path

# Set up util_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "bitvis_util"
quietly set part_name "bitvis_util"
# path from mpf-file in sim
quietly set util_part_path "../../$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set util_part_path "$1/../$part_name"
  unset 1
}

do $util_part_path/script/compile_src.do $util_part_path
