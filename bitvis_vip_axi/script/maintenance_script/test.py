import sys
from itertools import product


try:
    from hdlunit import HDLUnit
except:
    print('Unable to import HDLUnit module. See HDLUnit documentation for installation instructions.')
    sys.exit(1)


print('Verify Bitvis VIP AXI')

hdlunit = HDLUnit(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hdlunit.add_files("../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add Avalon AXI VIP
hdlunit.add_files("../src/*.vhd", "bitvis_vip_axi")
hdlunit.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_axi")

# Add TB/TH
hdlunit.add_files("../tb/maintenance_tb/*.vhd", "bitvis_vip_axi")

hdlunit.start(regression_mode=True, gui_mode=False)

num_failing_tests = hdlunit.get_num_fail_tests()

hdlunit.check_run_results(exp_fail=0)

sys.exit(num_failing_tests)
