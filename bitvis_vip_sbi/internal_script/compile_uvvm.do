# Compile UVVM-Util
#----------------------------------

# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

# Set up util_part_path and lib_name
#------------------------------------------------------
quietly set lib_name "uvvm_util"
quietly set part_name "uvvm_util"
# path from mpf-file in sim
quietly set util_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set util_part_path "$1/..//$part_name"
  unset 1
}

do $util_part_path/script/compile_src.do $util_part_path


# Compile UVVM VVC Framework
#----------------------------------

# Set up part_path and lib_name for uvvm_vvc_framework
#------------------------------------------------------
quietly set lib_name "uvvm_vvc_framework"
quietly set part_name "uvvm_vvc_framework"
# path from mpf-file in sim
quietly set uvvm_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set uvvm_part_path "$1/..//$part_name"
  unset 1
}

do $uvvm_part_path/script/compile_src.do $uvvm_part_path

