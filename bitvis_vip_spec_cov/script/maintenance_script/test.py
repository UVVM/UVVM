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

print('Verify Bitvis VIP Spec Cov')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit(simulator='modelsim')

# Remove output files prior to sim
hdlunit.run_command("rm *.txt")
hdlunit.run_command("py ../script/maintenance_script/sim.py")

# Add util, fw and VIP Scoreboard
hdlunit.add_files("../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
hdlunit.add_files("../../uvvm/bitvis_vip_spec_cov/src/*.vhd", "bitvis_vip_spec_cov")

# Add TB/TH
hdlunit.add_files("../tb/maintenance_tb/*.vhd", "bitvis_vip_spec_cov")
hdlunit.add_files("../tb/*.vhd", "bitvis_vip_spec_cov")

hdlunit.add_generics("spec_cov_tb", ["GC_REQ_FILE", ("../tb/maintenance_tb/req_file.csv", "PATH"),
                                     "GC_SUB_REQ_FILE", ("../tb/maintenance_tb/sub_req_file.csv", "PATH")])

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