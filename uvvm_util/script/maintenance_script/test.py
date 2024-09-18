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


def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')


path_called_from = os_adjust_path(os.getcwd())

print('Verify UVVM Util')

cleanup()

hr = HDLRegression()

# Add Util src
hr.add_files("../../src/*.vhd", "uvvm_util")

# Add Util TB and dependencies
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
hr.add_files("../../tb/maintenance_tb/*.vhd", "uvvm_util_tb")

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
                generics=['GC_FILE_PATH', (path_called_from + os.sep, 'PATH')])

sim_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ps"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)
elif simulator_name == "NVC":
    sim_options = ["-M64m", "-H2g"]

hr.start(sim_options=sim_options)

# Run coverage accumulation script
hr.run_command("python ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_verbose.txt -r")
hr.run_command("python ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_non_verbose.txt -r -nv")
hr.run_command("python ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_holes.txt -r -hl -im")

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# Check with golden reference
if simulator_name == 'MODELSIM':
    (ret_txt, ret_code) = hr.run_command("python ../../uvvm_util/script/maintenance_script/verify_with_golden.py -modelsim")
elif simulator_name == 'RIVIERA':
    (ret_txt, ret_code) = hr.run_command("python ../../uvvm_util/script/maintenance_script/verify_with_golden.py -riviera")
elif simulator_name == 'GHDL':
    (ret_txt, ret_code) = hr.run_command("python ../../uvvm_util/script/maintenance_script/verify_with_golden.py -ghdl")
elif simulator_name == 'NVC':
    (ret_txt, ret_code) = hr.run_command("python ../../uvvm_util/script/maintenance_script/verify_with_golden.py -nvc")
else:
  print("Please specify simulator as argument: MODELSIM, RIVIERA, GHDL or NVC")
  sys.exit(1)
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
