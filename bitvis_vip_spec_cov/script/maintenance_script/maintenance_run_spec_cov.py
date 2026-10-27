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

# Each entry is (argv, expected_rc). run_spec_cov.py returns a status code:
# 0 = all listed requirements compliant, 1 = technical failure,
# 2 = non-compliant requirement(s), 3 = incomplete coverage or warnings.
test_list = [
    ([python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_general_strict_0.txt"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_general_strict_1.txt"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_general_strict_2.txt"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_error_before_tc.csv", "-s", "../sim/sc_error_before_tc.csv"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_error_during_tc.csv", "-s", "../sim/sc_error_during_tc.csv"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_list_single_tickoff.csv", "-s", "../sim/sc_list_single_tickoff.csv"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/tb_tests_req_file.csv", "-p", "../sim/pc_cond_tickoff.csv", "-s", "../sim/sc_cond_tickoff.csv"], 3),
    ([python_exe, "../script/run_spec_cov.py", "--config", "../tb/maintenance_tb/cfg_mix_strict_1.txt"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-p", "../sim/pc_no_req_file.csv", "-s", "../sim/sc_no_req_file.csv"], 0),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-r", "../tb/maintenance_tb/req_file_no_req_file_tc.csv", "-p", "../sim/pc_no_req_file.csv", "-s", "../sim/sc_listed_no_req_file.csv"], 0),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-p", "../sim/pc_tc_fail.csv", "-s", "../sim/sc_unlisted_tc_fail.csv"], 2),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "0", "-p", "../sim/pc_does_not_exist.csv", "-s", "../sim/sc_does_not_exist.csv"], 1),
    ([python_exe, "../script/run_spec_cov.py", "--strictness", "5", "-p", "../sim/pc_no_req_file.csv", "-s", "../sim/sc_invalid_strictness.csv"], 1),
    ([python_exe, "../script/run_spec_cov.py", "--help"], 0)
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
    rc_mismatches = 0
    for idx, (test, expected_rc) in enumerate(test_list):
        print("Test %d : %s" % (idx, test))

        result = subprocess.run(
            test,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        output = result.stdout
        actual_rc = result.returncode

        # Save output for golden check (output is bytes in both branches)
        with open("output_" + str(idx + 1) + ".txt", "w", newline='\n') as file:
            file.write(str(output, "utf-8"))

        # Assert the return code matches the expected status code
        if actual_rc != expected_rc:
            print("ERROR: Test %d returned code %d, expected %d" % (idx, actual_rc, expected_rc))
            if result.stderr:
                print(str(result.stderr, "utf-8"))
            rc_mismatches += 1

    return rc_mismatches


def verify_test_results(python_exe, rc_mismatches=0):
    print("Verify test results...")
    num_errors = 0
    try:
        subprocess.check_call([python_exe, "../script/maintenance_script/verify_with_golden.py"], stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        num_errors = int(e.returncode)
    if num_errors != 0:
        print("Golden failed with %d errors!" % (num_errors))
    # Fold return-code mismatches into the failure count so an unexpected exit
    # code fails the harness rather than passing silently.
    if rc_mismatches != 0:
        print("Return-code assertion failed for %d test(s)!" % (rc_mismatches))
    sys.exit(num_errors + rc_mismatches)


remove_specification_coverage_files()
move_partial_coverage_files()
rc_mismatches = run_tests()
verify_test_results(python_exe, rc_mismatches)
