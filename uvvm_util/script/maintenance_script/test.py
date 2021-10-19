import sys
import os
import shutil
from itertools import product
import platform


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

def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')


print('Verify UVVM Util')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit(simulator='modelsim')

# Add Util src
hdlunit.add_files("../../src/*.vhd", "uvvm_util")

# Add Util TB
hdlunit.add_files("../../tb/maintenance_tb/*.vhd", "uvvm_util")

# Define testcase names with generics for GC_TESTCASE
hdlunit.add_generics(entity="generic_queue_array_tb",
                     generics=["GC_TESTCASE", "generic_queue_array_tb"])
hdlunit.add_generics(entity="generic_queue_record_tb",
                     generics=["GC_TESTCASE", "generic_queue_record_tb"])
hdlunit.add_generics(entity="generic_queue_tb",
                     generics=["GC_TESTCASE", "generic_queue_tb"])
hdlunit.add_generics(entity="simplified_data_queue_tb",
                     generics=["GC_TESTCASE", "simplified_data_queue_tb"])

output_path = os_adjust_path(os.getcwd())
hdlunit.add_generics(entity='func_cov_tb',
                     architecture='func',
                     generics=['GC_FILE_PATH', (output_path, 'PATH')])

hdlunit.start(regression_mode=True, gui_mode=False)

num_failing_tests = hdlunit.get_num_fail_tests()
num_passing_tests = hdlunit.get_num_pass_tests()

# Check with golden reference
(ret_txt, ret_code) = hdlunit.run_command("py ../script/maintenance_script/verify_with_golden.py -modelsim")
print(ret_txt)

# Golden compare ok?
if ret_code > 0:
    sys.exit(1)

# Tests have been run?
if num_passing_tests == 0:
    sys.exit(1)

# Remove output only if OK
if hdlunit.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')

# Return number of failing tests
sys.exit(num_failing_tests)