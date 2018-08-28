if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

quit -sim

quietly set vhdl_version "2008"

quietly set tb_part_path ../../uvvm_util

do $tb_part_path/script/compile_src.do $tb_part_path $vhdl_version
do $tb_part_path/internal_script/NA_compile_tb.do $tb_part_path $vhdl_version
do $tb_part_path/internal_script/NA_simulate_tb.do $tb_part_path $vhdl_version

exit


