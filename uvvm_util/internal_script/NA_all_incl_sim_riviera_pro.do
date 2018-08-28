# Run this script to simulate Util in Riviera Pro
# Must be run from the sim directory.

vlib uvvm_util
vcom -2008 -work uvvm_util ../src/types_pkg.vhd
vcom -2008 -work uvvm_util ../src/adaptations_pkg.vhd
vcom -2008 -work uvvm_util ../src/string_methods_pkg.vhd
vcom -2008 -work uvvm_util ../src/protected_types_pkg.vhd
vcom -2008 -work uvvm_util ../src/vhdl_version_layer_pkg.vhd
vcom -2008 -work uvvm_util ../src/license_pkg.vhd
vcom -2008 -work uvvm_util ../src/hierarchy_linked_list_pkg.vhd
vcom -2008 -work uvvm_util ../src/alert_hierarchy_pkg.vhd
vcom -2008 -work uvvm_util ../src/methods_pkg.vhd
vcom -2008 -work uvvm_util ../src/bfm_common_pkg.vhd
vcom -2008 -work uvvm_util ../tb/methods_tb.vhd
vsim uvvm_util.methods_tb
run -all