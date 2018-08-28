onerror {abort all}

do ./internal_compile_uvvm.do 
# do ./internal_compile_dep_vip_sbi.do
do ./internal_compile_src.do
do ./internal_compile_tb_dep.do
do ./internal_compile_tb.do
do ./internal_simulate_tb.do
