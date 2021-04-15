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
    
print('Verify Bitvis IRQC DUT')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit()

# Set testcase detection string
hdlunit.set_testcase_id("GC_TESTCASE")

# Add util, fw and VIP Scoreboard
hdlunit.add_files("../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
# Add other VIPs in the TB
#  - SBI VIP
hdlunit.add_files("../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hdlunit.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
# Add DUT
hdlunit.add_files("../../bitvis_irqc/src/*.vhd", "bitvis_irqc")
# Add TB/TH
hdlunit.add_files("../../bitvis_irqc/tb/*.vhd", "bitvis_irqc")
hdlunit.add_files("../../bitvis_irqc/tb/maintenance_tb/*.vhd", "bitvis_irqc")
hdlunit.start()


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
