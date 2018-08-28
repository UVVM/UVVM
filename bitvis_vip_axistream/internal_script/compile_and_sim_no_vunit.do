onerror {abort all}

# do ./internal_compile_uvvm.do
# do ./internal_compile_src.do
do ../script/compile_src.do
do ./compile_tb_vvc_no_vunit.do
do ./simulate_tb_vvc.do
