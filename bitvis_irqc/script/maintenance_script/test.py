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


print('Verify Bitvis IRQC DUT')

cleanup('Removing any previous runs.')

hr = HDLRegression()

# Set testcase detection string
hr.set_testcase_identifier_name("GC_TESTCASE")

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
# Add other VIPs in the TB
#  - SBI VIP
hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
# Add DUT
hr.add_files("../../../bitvis_irqc/src/*.vhd", "bitvis_irqc")
# Add TB/TH
hr.add_files("../../../bitvis_irqc/tb/*.vhd", "bitvis_irqc")
hr.add_files("../../../bitvis_irqc/tb/maintenance_tb/*.vhd", "bitvis_irqc")

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

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)

# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')

# Return number of failing tests
sys.exit(num_failing_tests)
