#========================================================================================================================
# Copyright (c) 2017 by Bitvis AS.  All rights reserved.
#
# BITVIS UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH BITVIS UTILITY LIBRARY.
#========================================================================================================================

# Compile Bitvis concurrency
#----------------------------------

# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...



# Set up part_path and lib_name for bitvis_concurrency
#------------------------------------------------------
quietly set lib_name "uvvm_vvc_framework"
quietly set part_name "uvvm_vvc_framework"
# path from mpf-file in sim
quietly set concurrency_part_path "../..//$part_name"

if { [info exists 1] } {
  # path from this part to target part
  quietly set concurrency_part_path "$1/..//$part_name"
  unset 1
}

do $concurrency_part_path/internal_script/internal_compile_src.do $concurrency_part_path
