onerror {abort all}

do ../script/compile_uvvm.do
do ../script/compile_bfm.do
do ../script/compile_src.do
do ./compile_tb_vvc.do
do ./simulate_tb_vvc.do
