import sys
import os
import shutil
from itertools import product
import platform
from pathlib import Path
import subprocess

try:
    from hdlregression import HDLRegression
except:
    print('Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.')
    sys.exit(1)


# Clean the sim directory
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


# Fix the path separators
def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')


# Find the correct python executable
def find_python3_executable():
    python_executables = ["python3", "python", "Python3", "Python"]

    for executable in python_executables:
        try:
            output = (subprocess.check_output([executable, "--version"], stderr=subprocess.STDOUT).decode().strip())
            if "Python 3" in output:
                return executable
        except (subprocess.CalledProcessError, FileNotFoundError):
            continue
    return "python"


path_called_from = os_adjust_path(os.getcwd())

print('Verify UVVM Util')

cleanup()

hr = HDLRegression()

# Add util and VIP Scoreboard
hr.add_files("../../src/*.vhd", "uvvm_util")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
# Add TB
hr.add_files("../../tb/maintenance_tb/*.vhd", "uvvm_util_tb")

# Define testcase names with generics for GC_TESTCASE
hr.add_generics(entity="generic_queue_array_tb", generics=["GC_TESTCASE", "generic_queue_array_tb"])
hr.add_generics(entity="generic_queue_record_tb", generics=["GC_TESTCASE", "generic_queue_record_tb"])
hr.add_generics(entity="generic_queue_tb", generics=["GC_TESTCASE", "generic_queue_tb"])
hr.add_generics(entity="simplified_data_queue_tb", generics=["GC_TESTCASE", "simplified_data_queue_tb"])
hr.add_generics(entity="association_list_tb", generics=["GC_TESTCASE", "association_list_tb"])
hr.add_generics(entity='func_cov_tb', generics=['GC_FILE_PATH', (path_called_from + os.sep, 'PATH')])

# Set simulator name and options
sim_options    = None
global_options = None
simulator_name = hr.settings.get_simulator_name()
if simulator_name == "MODELSIM":
    sim_options = "-t ps"
elif simulator_name in ["GHDL"]:
    com_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "-Wall", "--warn-no-shared", "--warn-no-hide", "--warn-no-delayed-checks"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)
elif simulator_name == "NVC":
    global_options = ["--stderr=error", "--messages=compact", "-M64m", "-H2g"]

hr.start(sim_options=sim_options, global_options=global_options)

python_exec = find_python3_executable()

# Run coverage accumulation script
hr.run_command("{} ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_verbose.txt -r".format(python_exec))
hr.run_command("{} ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_non_verbose.txt -r -nv".format(python_exec))
hr.run_command("{} ../../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_holes.txt -r -hl -im".format(python_exec))

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# Check with golden reference
if simulator_name == 'MODELSIM':
    (ret_txt, ret_code) = hr.run_command("{} ../../uvvm_util/script/maintenance_script/verify_with_golden.py -modelsim".format(python_exec))
elif simulator_name == 'RIVIERA-PRO':
    (ret_txt, ret_code) = hr.run_command("{} ../../uvvm_util/script/maintenance_script/verify_with_golden.py -riviera".format(python_exec))
elif simulator_name == 'GHDL':
    (ret_txt, ret_code) = hr.run_command("{} ../../uvvm_util/script/maintenance_script/verify_with_golden.py -ghdl".format(python_exec))
elif simulator_name == 'NVC':
    (ret_txt, ret_code) = hr.run_command("{} ../../uvvm_util/script/maintenance_script/verify_with_golden.py -nvc".format(python_exec))
else:
  print("Please specify simulator as argument: MODELSIM, RIVIERA, GHDL or NVC")
  sys.exit(1)
print(ret_txt.replace('\\', '/'))

# Golden compare error
if ret_code > 0:
    sys.exit(1)
# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')

# Run alternative simulation scripts
if simulator_name == "MODELSIM" or simulator_name == "RIVIERA-PRO":
    print('\nVerify .do scripts...')
    (ret_txt, ret_code) = hr.run_command(["vsim", "-c", "-do", "do ../script/compile_and_sim_cr_fc_demo_tb.do; exit"], False)
    if ret_code == 0:
        print("TCL script test completed")
        if hr.check_run_results(exp_fail=0) is True:
            cleanup('Removing simulation output\n')
    else:
        print(ret_txt)
        num_failing_tests += 1

# Return number of failing tests
sys.exit(num_failing_tests)
