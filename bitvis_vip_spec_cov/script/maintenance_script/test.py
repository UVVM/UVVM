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

    # Check if the current directory is 'sim'
    if os.path.basename(sim_path) == 'sim':
        for files in os.listdir(sim_path):
            path = os.path.join(sim_path, files)
            try:
                shutil.rmtree(path)
            except:
                os.remove(path)
    else:
        print('Current directory is not "sim". Skipping cleanup.')


print('Verify Bitvis VIP Spec Cov')

cleanup('Removing any previous runs.')

hr = HDLRegression(simulator='modelsim')

# Remove output files prior to sim
hr.run_command("rm *.txt")

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd",
             "bitvis_vip_scoreboard")
hr.add_files("../../src/*.vhd", "bitvis_vip_spec_cov")

# Add TB/TH
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_spec_cov")

hr.add_generics(entity="spec_cov_tb",
                generics=["GC_REQ_FILE",       ("../../tb/maintenance_tb/req_file.csv", "PATH"),
                          "GC_REQ_FILE_EMPTY", (
                    "../../tb/maintenance_tb/req_file_empty.csv", "PATH"),
                    "GC_SUB_REQ_FILE",   (
                    "../../tb/maintenance_tb/sub_req_file.csv", "PATH"),
                    "GC_REQ_OMIT_MAP",   ("../../tb/maintenance_tb/sub_req_omit_map_file.csv", "PATH")])

sim_options = None
default_options = []
simulator_name = hr.settings.get_simulator_name()
if simulator_name in ['MODELSIM', 'RIVIERA']:
    sim_options = '-t ns'
    # Set compile options
    default_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=default_options)

hr.start(sim_options=sim_options)

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# Check with golden reference
(ret_txt, ret_code) = hr.run_command(
    "python ../script/maintenance_script/maintenance_run_spec_cov.py")

if ret_code != 0:
    print(ret_txt)
    num_failing_tests += 1

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=1) is True:
    cleanup('Removing simulation output')
# Return number of failing tests
sys.exit(num_failing_tests)
