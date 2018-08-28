
if {[batch_mode]} {
  onerror {abort all; exit -f -code 1}
} else {
  onerror {abort all}
}

# Set up dir_path and lib_name
set uvvm_util_path "../../uvvm_util"
set dir_path $uvvm_util_path
set lib_name "uvvm_util"

set compdirectives "-2008 -work $lib_name"

echo "\n\nCompiling $lib_name TB\n"
eval vcom  $compdirectives   ../../uvvm_util/tb/methods_tb.vhd

