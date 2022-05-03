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

print('Verify Bitvis VIP Spec Cov')

cleanup('Removing any previous runs.')

hr = HDLRegression(simulator='modelsim')

# Remove output files prior to sim
hr.run_command("rm *.txt")
# hr.run_command("py ../script/maintenance_script/sim.py")

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
hr.add_files("../../src/*.vhd", "bitvis_vip_spec_cov")

# Add TB/TH
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_spec_cov")
hr.add_files("../../tb/*.vhd", "bitvis_vip_spec_cov")

hr.add_generics(entity="spec_cov_tb",
                     generics=["GC_REQ_FILE", ("../../tb/maintenance_tb/req_file.csv", "PATH"),
                               "GC_SUB_REQ_FILE", ("../../tb/maintenance_tb/sub_req_file.csv", "PATH"),
                               "GC_SUB_REQ_FILE", ("../../tb/maintenance_tb/sub_req_file.csv", "PATH"),
                               "GC_REQ_OMIT_MAP", ("../../tb/maintenance_tb/sub_req_omit_map_file.csv", "PATH")])

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