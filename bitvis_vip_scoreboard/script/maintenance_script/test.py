import sys
import os
import shutil
from itertools import product


try:
    from hdlunit import HDLUnit
except:
    print('Unable to import HDLUnit module. See HDLUnit documentation for installation instructions.')
    sys.exit(1)


def cleanup(msg='Cleaning up...'):
    print(msg)

    sim_path = os.getcwd()

    for files in os.listdir(sim_path):
        path = os.path.join(sim_path, files)
        try:
            shutil.rmtree(path)
        except:
            os.remove(path)

print('Verify Bitvis VIP Scoreboard')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hdlunit.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add TB dependencies
hdlunit.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hdlunit.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
hdlunit.add_files("../../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
hdlunit.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
hdlunit.add_files("../../../bitvis_uart/src/*.vhd", "bitvis_uart")

# Add TB/TH
hdlunit.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_scoreboard_tb")
hdlunit.add_files("../../tb/*.vhd", "bitvis_vip_scoreboard_tb")

hdlunit.start(regression_mode=True, gui_mode=False)

num_failing_tests = hdlunit.get_num_fail_tests()
num_passing_tests = hdlunit.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hdlunit.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')
# Return number of failing tests
sys.exit(num_failing_tests)