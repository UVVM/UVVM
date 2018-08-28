onerror {abort all}

do ./internal_compile_uvvm.do
do ./internal_compile_bfm.do
do ./compile_tb.do
do ./simulate_tb.do
