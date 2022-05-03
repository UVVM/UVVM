import sys
import os
import shutil
from itertools import product
import platform


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

def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')


print('Verify UVVM Util')

cleanup('Removing any previous runs.')

hr = HDLRegression(simulator='modelsim')

# Add Util src
hr.add_files("../../src/*.vhd", "uvvm_util")

# Add Util TB
hr.add_files("../../tb/maintenance_tb/*.vhd", "uvvm_util")

# Define testcase names with generics for GC_TESTCASE
hr.add_generics(entity="generic_queue_array_tb",
                     generics=["GC_TESTCASE", "generic_queue_array_tb"])
hr.add_generics(entity="generic_queue_record_tb",
                     generics=["GC_TESTCASE", "generic_queue_record_tb"])
hr.add_generics(entity="generic_queue_tb",
                     generics=["GC_TESTCASE", "generic_queue_tb"])
hr.add_generics(entity="simplified_data_queue_tb",
                     generics=["GC_TESTCASE", "simplified_data_queue_tb"])

output_path = os_adjust_path(os.getcwd() + '//')
hr.add_generics(entity='func_cov_tb',
                     architecture='func',
                     generics=['GC_FILE_PATH', (output_path, 'PATH')])

hr.start(regression_mode=True, gui_mode=False)

# Run coverage accumulation script
hr.run_command("py ../script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_verbose.txt -r")
hr.run_command("py ../script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_non_verbose.txt -r -nv")
hr.run_command("py ../script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_holes.txt -r -hl -im")

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# Check with golden reference
(ret_txt, ret_code) = hr.run_command("py ../script/maintenance_script/verify_with_golden.py -modelsim")
print(ret_txt.replace('\\', '/'))

# Golden compare ok?
if ret_code > 0:
    sys.exit(1)

# Tests have been run?
if num_passing_tests == 0:
    sys.exit(1)

# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')

# Return number of failing tests
sys.exit(num_failing_tests)