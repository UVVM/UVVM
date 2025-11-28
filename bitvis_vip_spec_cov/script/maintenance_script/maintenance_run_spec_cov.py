import subprocess
import os
import sys


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


python_exe = find_python3_executable()

test_list = [
    [python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_general_strict_0.txt"],
    [python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_general_strict_1.txt"],
    [python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_general_strict_2.txt"],
    [python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_error_before_tc.csv", "-s", "../sim/sc_error_before_tc.csv"],
    [python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_error_during_tc.csv", "-s", "../sim/sc_error_during_tc.csv"],
    [python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_list_single_tickoff.csv", "-s", "../sim/sc_list_single_tickoff.csv"],
    [python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_cond_tickoff.csv", "-s", "../sim/sc_cond_tickoff.csv"],
    [python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_mix_strict_1.txt"],
    [python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-p", "../sim/pc_no_req_file.csv", "-s", "../sim/sc_no_req_file.csv"]
]


def remove_specification_coverage_files():
    print("Removing old run_spec_cov.py run files...")
    for filename in os.listdir("."):
        if filename[0:3] == "sc_":
            if filename.endswith(".csv"):
                print("Removing : %s" % (filename))
                os.remove(filename)
        elif filename[0:7] == "output_":
            if filename.endswith(".txt"):
                print("Removing : %s" % (filename))
                os.remove(filename)


def move_partial_coverage_files():
    print("Moving partial coverage files...")
    for root, dirs, files in os.walk("../sim/hdlregression/test/spec_cov_tb"):
        for name in files:
            if name.endswith(".csv"):
                os.rename(root + "/" + name, "../sim/" + name)


def run_tests():
    print("Running tests...")
    output = None
    for idx, test in enumerate(test_list):
        print("Test %d : %s" % (idx, test))

        try:
            output = subprocess.check_output(test, stderr=subprocess.PIPE)
            # Save output for golden check
            with open("output_" + str(idx + 1) + ".txt", "w", newline='\n') as file:
                file.write(str(output, "utf-8"))
        except subprocess.CalledProcessError as e:
            print("ERROR: %s" % (e))


def verify_test_results(python_exe):
    print("Verify test results...")
    num_errors = 0
    try:
        subprocess.check_call([python_exe, "../script/maintenance_script/verify_with_golden.py"], stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        num_errors = int(e.returncode)
    if num_errors != 0:
        print("Golden failed with %d errors!" % (num_errors))
    sys.exit(num_errors)


remove_specification_coverage_files()
move_partial_coverage_files()
run_tests()
verify_test_results(python_exe)
