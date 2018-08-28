# This file may be called with an argument
# arg 1: Part directory of this library/module

onerror {abort all}
quit -sim   #Just in case...

source ../internal_script/compile_dep_concurrency.do
source ../internal_script/compile_dep_vip_gpio.do
source ../internal_script/internal_compile_src.do
source ../internal_script/compile_tb.do
source ../internal_script/simulate_tb.do

