import sys
import os
import shutil
from itertools import product
import platform
from pathlib import Path

try:
    from hdlregression import HDLRegression
except:
    print('Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.')
    sys.exit(1)


def cleanup():
  if os.path.isdir('./hdlregression'):
    shutil.rmtree('./hdlregression')

#  for filename in Path(".").glob("*.txt"):
#      filename.unlink()


def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')


path_called_from = os_adjust_path(os.getcwd())

print('Verify UVVM Util')

cleanup()

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

hr.add_generics(entity='func_cov_tb',
                architecture='func',
                generics=['GC_FILE_PATH', (path_called_from + '/', 'PATH')])

hr.start(regression_mode=False, gui_mode=False)

# Run coverage accumulation script
hr.run_command(
    "python ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_verbose.txt -r")
hr.run_command(
    "python ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_non_verbose.txt -r -nv")
hr.run_command(
    "python ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_holes.txt -r -hl -im")

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# Check with golden reference, args: 1=modelsim simulator, 2=path to uvvm_util

(ret_txt, ret_code) = hr.run_command(
    "python ../../uvvm_util/script/maintenance_script/verify_with_golden.py -modelsim")
print(ret_txt.replace('\\', '/'))

# Golden compare ok?
if ret_code > 0:
    sys.exit(1)

# Tests have been run?
if num_passing_tests == 0:
    sys.exit(1)

if num_failing_tests == 0:
  cleanup()

# Return number of failing tests
sys.exit(num_failing_tests)