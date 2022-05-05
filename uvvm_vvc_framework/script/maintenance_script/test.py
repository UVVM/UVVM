import sys
import os
import shutil
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print('Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.')
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

hr = HDLRegression(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add TB/TH and dependencies
hr.add_files("../../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
hr.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_uart")

hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hr.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_sbi")

hr.add_files("../../../bitvis_uart/src/*.vhd", "bitvis_uart")

hr.add_files("../../../bitvis_vip_avalon_mm/src/*.vhd", "bitvis_vip_avalon_mm")
hr.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_avalon_mm")

hr.add_files("../../tb/maintenance_tb/reference_vvcs/src/*sbi*.vhd", "bitvis_vip_sbi")
hr.add_files("../../tb/maintenance_tb/reference_vvcs/src/*uart*.vhd", "bitvis_vip_uart")
hr.add_files("../../tb/maintenance_tb/*.vhd", "testbench_lib")

hr.start(regression_mode=True, gui_mode=False)

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')
# Return number of failing tests
sys.exit(num_failing_tests)