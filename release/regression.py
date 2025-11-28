import os
import subprocess
import glob
import sys
import json


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


# Execute alternative simulation scripts
def run_do_scripts(script_args=[]):
    simulator_name = "MODELSIM" # Default simulator in HDLRegression
    script_args = sys.argv[1:]
    for idx, arg in enumerate(script_args):
        if arg == "-s":
            simulator_name = script_args[idx+1].upper()

    if simulator_name == "MODELSIM" or simulator_name == "RIVIERA" or simulator_name == "RIVIERA-PRO":
        print('\nVerify .do scripts...')
        return_code = subprocess.run(["vsim", "-c", "-do", "do ../script/compile_all.do ../script; exit"], stdout = subprocess.DEVNULL).returncode
        if return_code == 0:
            print("\n\n===>> compile_all.do script completed successfully")
        else:
            print("\n\n===>> WARNING!! compile_all.do script exited with error code {}. SUMMARY: FAIL".format(return_code), file=sys.stderr)


# Execute every test.py scripts from each VIP
def find_and_run_tests(base_dir="..", script_args=[], python_exec="Python3"):

    pattern = os.path.join(base_dir, "*/script/maintenance_script/test.py")

    test_scripts = glob.glob(pattern, recursive=True)
    original_cwd = os.getcwd()  # Save the original cwd to restore later

    non_zero_exit_codes = 0  # Counter for non-zero exit codes
    results_dict = {}
    print("\n\nUVVM regression running with arguments {}\n\n".format(script_args))

    for test_script in test_scripts:
        sim_dir_relative_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(test_script))), "sim")

        sim_dir = os.path.relpath(sim_dir_relative_path, start=original_cwd)

        # Get module name relative to base_dir
        module_name = os.path.relpath(test_script, base_dir).split(os.sep)[0]

        # Determine the part name
        if module_name.startswith('bitvis_vip'):
            part_name = 'bitvis_vip'
        elif module_name in ['uvvm_util', 'uvvm_vvc_framework']:
            part_name = module_name
        else:
            part_name = 'others'

        if not os.path.exists(sim_dir):
            print("Creating missing sim directory: {}".format(sim_dir))
            os.makedirs(sim_dir)

        try:
            return_code = subprocess.run([python_exec, os.path.relpath(test_script, start=sim_dir)] + script_args, cwd=sim_dir).returncode

            # Store results per module and per part
            if part_name not in results_dict:
                results_dict[part_name] = {}
            results_dict[part_name][module_name] = return_code

            if return_code != 0:
                non_zero_exit_codes += 1
                print("\n\n===>> WARNING!! Script {} exited with error code {}".format(test_script, return_code), file=sys.stderr)

        except subprocess.CalledProcessError as e:
            if part_name not in results_dict:
                results_dict[part_name] = {}
            results_dict[part_name][module_name] = "Error"
            non_zero_exit_codes += 1  # Increment for timeout as well
            print("\n\n===>> WARNING!! Error executing {} (Module: {}): {}".format(test_script, module_name, e), file=sys.stderr)
        except Exception as e:
            if part_name not in results_dict:
                results_dict[part_name] = {}
            results_dict[part_name][module_name] = "Exception"
            non_zero_exit_codes += 1  # Increment for any other exceptions
            print("\n\n===>> WARNING!! Error executing {}: {}".format(test_script, e))

    if non_zero_exit_codes == 0:
        print("All test.py scripts executed successfully. SUMMARY: SUCCESS")
    else:
        print(f"Some test.py scripts failed ({non_zero_exit_codes} errors). SUMMARY: FAIL")

    os.chdir(original_cwd)  # Restore the original cwd

    print("\nSummary of test execution results:")
    print(json.dumps(results_dict, indent=4))

    print("\nModules with errors:")
    for part, modules in results_dict.items():
        for module, return_code in modules.items():
            if return_code != 0:
                print(f"Part: {part}, Module: {module}, Error Code: {return_code}")


if __name__ == "__main__":
    base_dir = os.path.join(os.path.dirname(__file__), "..")
    base_dir = os.path.abspath(base_dir)
    base_dir = os.path.normpath(base_dir)

    python_exe = find_python3_executable()

    script_args = sys.argv[1:]
    print("\n\n{}\n{}\n =====>>>>>  UVVM regression script running  <<<<<===== \n{}".format(("=" * 80), (" " * 8), ("=" * 80)))
    run_do_scripts(script_args)
    find_and_run_tests(base_dir, script_args, python_exe)
