import sys
import os
import shutil
import subprocess
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print("Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.")
    sys.exit(1)


def find_python3_executable():
    python_executables = ["python3", "python"]

    for executable in python_executables:
        try:
            output = (subprocess.check_output([executable, "--version"], stderr=subprocess.STDOUT).decode().strip())
            if "Python 3" in output:
                return executable
        except (subprocess.CalledProcessError, FileNotFoundError):
            continue
    return None


def cleanup(msg="Cleaning up..."):
    print(msg)

    sim_path = os.getcwd()

    # Check if the current directory is 'sim'
    if os.path.basename(sim_path) == "sim":
        for files in os.listdir(sim_path):
            path = os.path.join(sim_path, files)
            try:
                shutil.rmtree(path)
            except:
                os.remove(path)
    else:
        print('Current directory is not "sim". Skipping cleanup.')


def test_clean_parameter():
    # Function for testing that running run_spec_cov.py with the --clean parameter
    # works as intended, both for deleting files in the current directory, and
    # when specifying a directory to be cleaned.

    print("Testing '--clean (DIR)' parameter of run_spec_cov.py")

    # Create subdirectory within test directory to test cleaning of specified directory.
    os.makedirs("test_subdir", exist_ok=True)

    # Create dummy CSV files in the two test directories
    csv_file_testdir = open(os.path.join("pc_delete_me.csv"), "w")
    csv_file_subdir = open(os.path.join("test_subdir", "pc_delete_me.csv"), "w")
    csv_file_testdir.close()
    csv_file_subdir.close()

    try:
        subprocess.run([find_python3_executable(), "../script/run_spec_cov.py", "--clean"], check=True)
    except subprocess.CalledProcessError as e:
        print("ERROR: Test of --clean parameter failed. %s" % (e))
        return 1

    try:
        subprocess.run([find_python3_executable(), "../script/run_spec_cov.py", "--clean", "./test_subdir"], check=True)
    except subprocess.CalledProcessError as e:
        print("ERROR: Cleaning test (specified dir) failed. %s" % (e))
        return 1

    # Check that files have been deleted
    if os.path.exists("pc_delete_me.csv") == True:
        print("Testing of clean parameter: Error: File not deleted")
        return 1

    if os.path.exists(os.path.join("test_subdir", "pc_delete_me.csv")) == True:
        print("Testing of clean parameter: Error: File in subdir not deleted")
        return 1

    shutil.rmtree("test_subdir")
    return 0


# Test running run_spec_cov.py with --clean parameter
errors = test_clean_parameter()

print("Verify Bitvis VIP Spec Cov")

cleanup("Removing any previous runs.")

hr = HDLRegression()

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
hr.add_files("../../src/*.vhd", "bitvis_vip_spec_cov")

# Add TB/TH
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_spec_cov")

hr.add_generics(
    entity="spec_cov_tb",
    generics=[
        "GC_TB_REQ_FILE", ("../../tb/maintenance_tb/tb_tests_req_file.csv", "PATH"),
        "GC_REQ_FILE_EMPTY", ("../../tb/maintenance_tb/req_file_empty.csv", "PATH"),
        "GC_MIX_REQ_FILE", ("../../tb/maintenance_tb/mix_req_file.csv", "PATH"),
        "GC_MIX_MAP_FILE", ("../../tb/maintenance_tb/mix_map_file.csv", "PATH"),
        "GC_GENERAL_REQ_FILE", ("../../tb/maintenance_tb/general_req_file.csv", "PATH"),
        "GC_GENERAL_MAP_FILE", ("../../tb/maintenance_tb/general_map_file.csv", "PATH"),
    ],
)

sim_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ns"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)

hr.start(sim_options=sim_options)

num_expected_failing_tests = 1
num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

if num_failing_tests >= num_expected_failing_tests:
    num_failing_tests -= num_expected_failing_tests

num_failing_tests += errors

################################
# Check with golden reference
################################
(ret_txt, ret_code) = hr.run_command(find_python3_executable() + " ../script/maintenance_script/maintenance_run_spec_cov.py", True)

if ret_code != 0:
    print(ret_txt)
    num_failing_tests += 1

################################
# Run demos
################################
print("Running demos...")

hr = HDLRegression()

# Add Util, VVC Framework and Scoreboard VIP
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
# Add UART VIP
hr.add_files("../../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
# Add UART DUT
hr.add_files("../../../bitvis_uart/src/*.vhd", "bitvis_uart")
# Add SBI VIP
hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
# Add Spec Cov VIP
hr.add_files("../../src/*.vhd", "bitvis_vip_spec_cov")

sim_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ns"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)

script_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../")
script_path = script_path.replace("\\", "/")
# Basic demo
hr.add_files("../../demo/basic_usage/*.vhd", "bitvis_vip_spec_cov")
hr.add_generics(entity="uart_vvc_tb", architecture="func", generics=["GC_SCRIPT_PATH", (script_path, "PATH")])

hr.start(sim_options=sim_options)

num_failing_tests += hr.get_num_fail_tests()
num_passing_tests += hr.get_num_pass_tests()

# Advanced demo
hr.remove_file("../../demo/basic_usage/*.vhd", "bitvis_vip_spec_cov")
hr.add_files("../../demo/advanced_usage/*.vhd", "bitvis_vip_spec_cov")
C_NUM_TESTCASES = 4
for i in range(C_NUM_TESTCASES):
    hr.add_generics(entity="uart_vvc_tb", architecture="func", generics=["GC_SCRIPT_PATH", (script_path, "PATH"), "GC_TESTCASE", i])

hr.start(sim_options=sim_options)

num_failing_tests += hr.get_num_fail_tests()
num_passing_tests += hr.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if num_failing_tests == 0:
    cleanup("Removing simulation output")
# Return number of failing tests
sys.exit(num_failing_tests)
