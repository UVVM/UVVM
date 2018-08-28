onerror {abort all}

# do ./internal_compile_uvvm.do
# do ./internal_compile_bfm.do
do ../script/compile_src.do

do ./compile_tb.do
do ./simulate_tb.do
