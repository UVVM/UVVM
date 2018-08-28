vsim uvvm_util.methods_tb

if {! [batch_mode]} {
  do ../internal_script/wave.do
}

run -all
