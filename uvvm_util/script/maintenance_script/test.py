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

print('Verify UVVM Util')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit(simulator='modelsim')

# Add Util src
hdlunit.add_files("../src/*.vhd", "uvvm_util")

# Add Util TB
hdlunit.add_files("../tb/maintenance_tb/*.vhd", "uvvm_util")

# Define testcase names with generics for GC_TESTCASE
hdlunit.add_generics("generic_queue_array_tb", ["GC_TESTCASE", "generic_queue_array_tb"])
hdlunit.add_generics("generic_queue_record_tb", ["GC_TESTCASE", "generic_queue_record_tb"])
hdlunit.add_generics("generic_queue_tb", ["GC_TESTCASE", "generic_queue_tb"])
hdlunit.add_generics("simplified_data_queue_tb", ["GC_TESTCASE", "simplified_data_queue_tb"])

hdlunit.start(regression_mode=True, gui_mode=False)

num_failing_tests = hdlunit.get_num_fail_tests()
num_passing_tests = hdlunit.get_num_pass_tests()

# Check with golden reference
(ret_txt, ret_code) = hdlunit.run_command("py ../script/maintenance_script/verify_with_golden.py -modelsim")

print(ret_txt)

if ret_code > 0:
    num_failing_tests += 1
    #sys.exit(1)

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)

# Remove output only if OK
if hdlunit.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')
# Return number of failing tests
sys.exit(num_failing_tests)