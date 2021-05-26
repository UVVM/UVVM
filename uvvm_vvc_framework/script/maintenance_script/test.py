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

print('Verify UVVM VVC Framework')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hdlunit.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add TB/TH and dependencies
hdlunit.add_files("../../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
hdlunit.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_uart")

hdlunit.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hdlunit.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_sbi")

hdlunit.add_files("../../../bitvis_uart/src/*.vhd", "bitvis_uart")

hdlunit.add_files("../../../bitvis_vip_avalon_mm/src/*.vhd", "bitvis_vip_avalon_mm")
hdlunit.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_avalon_mm")

hdlunit.add_files("../../tb/maintenance_tb/reference_vvcs/src/*sbi*.vhd", "bitvis_vip_sbi")
hdlunit.add_files("../../tb/maintenance_tb/reference_vvcs/src/*uart*.vhd", "bitvis_vip_uart")
hdlunit.add_files("../../tb/maintenance_tb/*.vhd", "testbench_lib")

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