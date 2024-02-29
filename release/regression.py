import os
import subprocess
import glob
import sys
import json


def find_and_run_tests(base_dir="..", script_args=[]):
    pattern = os.path.join(base_dir, "*/script/maintenance_script/test.py")

    test_scripts = glob.glob(pattern, recursive=True)
    original_cwd = os.getcwd()  # Save the original cwd to restore later

    non_zero_exit_codes = 0  # Counter for non-zero exit codes
    results_dict = {}

    for test_script in test_scripts:
        sim_dir_relative_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(test_script))), "sim"
        )

        sim_dir = os.path.relpath(sim_dir_relative_path, start=original_cwd)

        module_name = test_script.split(os.sep)[3].upper()

        if not os.path.exists(sim_dir):
            print("Creating missing sim directory: {}".format(sim_dir))
            os.makedirs(sim_dir)

        print(
            "\n\n{}\nUVVMegression script running: {}".format(("=" * 80), module_name)
        )
        print(
            "\n==> Execute {} in {} with arguments {}\n\n".format(
                test_script, sim_dir, script_args
            )
        )

        script_path = os.path.relpath(test_script, start=sim_dir).replace("\\", "/")

        return_code = 1

        try:
            return_code = subprocess.run(
                ["python", os.path.relpath(test_script, start=sim_dir)] + script_args,
                cwd=sim_dir,
            ).returncode

            results_dict[module_name] = return_code

            if return_code != 0:
                non_zero_exit_codes += 1
                print(
                    "\n\n===>> WARNING!! Script {} exited with error code {}".format(
                        test_script, return_code
                    ),
                    file=sys.stderr,
                )

        except subprocess.CalledProcessError as e:
            results_dict[module_name] = "Error"
            non_zero_exit_codes += 1  # Increment for timeout as well
            print(
                "\n\n===>> WARNING!! Error executing {} (Module: {}): {e}".format(
                    test_script, module_name, e
                ),
                file=sys.stderr,
            )
        except Exception as e:
            results_dict[module_name] = "Exception"
            non_zero_exit_codes += 1  # Increment for any other exceptions
            print("\n\n===>> WARNING!! Error executing {}: {}".format(test_script, e))

    if non_zero_exit_codes == 0:
        print("All test.py scripts executed successfully. SUMMARY: SUCCESS")
    else:
        print(
            f"Some test.py scripts failed ({non_zero_exit_codes} errors). SUMMARY: FAIL"
        )

    os.chdir(original_cwd)  # Restore the original cwd

    print("\nSummary of test execution results:")
    print(json.dumps(results_dict, indent=4))


if __name__ == "__main__":
    base_dir = os.path.join(os.path.dirname(__file__), "..")
    base_dir = os.path.abspath(base_dir)
    base_dir = os.path.normpath(base_dir)

    script_args = sys.argv[1:]
    find_and_run_tests(base_dir, script_args)
