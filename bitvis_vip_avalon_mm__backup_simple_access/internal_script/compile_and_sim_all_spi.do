onerror {abort all}

do ../script/compile_uvvm.do
do ../script/compile_bfm.do
do ./compile_tb.do
do ./simulate_tb_spi.do
