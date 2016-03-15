# This file may be called with an argument
# arg 1: Part directory of this library/module

if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

# Set up part_path
#------------------------------------------------------
quietly set part_name "uvvm_osvvm"
# path from mpf-file in sim
quietly set part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set part_path "$1/..//$part_name"
  unset 1
}

do $part_path/script/compile_util.do $part_path
do $part_path/script/compile_src.do $part_path

