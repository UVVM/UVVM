import os
import subprocess
import sys
import platform
import shutil


def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')

def find_test_files(root_dir):
    test_files = []
    for foldername, subfolders, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename == "test.py":
                file_with_path = os_adjust_path(os.path.relpath(os.path.join(foldername, filename), root_dir))
                test_files.append(file_with_path)
    return test_files

def delete_hdlregression_folder():
    script_directory = os.path.dirname(__file__)
    hdlregression_dir = os.path.join(script_directory, "hdlregression")

    if os.path.exists(hdlregression_dir):
        print(f"Deleting 'hdlregression' folder...")
        try:
            shutil.rmtree(hdlregression_dir)
            print(f"Deleted 'hdlregression' folder.")
        except Exception as e:
            print(f"Failed to delete 'hdlregression' folder: {str(e)}")

def run_tests(test_files, command_line_args):
    script_directory = os.path.dirname(__file__)
    for test_file in test_files:
        test_file_path = os.path.abspath(os.path.join(script_directory, "..", test_file))  # Prepend "../"
        test_dir = os.path.dirname(test_file_path)

        env = os.environ.copy()
        env["TERM"] = "xterm-256color"
        
        command = ["python", "-u", test_file_path] + command_line_args

        delete_hdlregression_folder()

        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=test_dir, text=True, env=env)
            stdout, stderr = process.communicate()
            if process.returncode == 0:
                print(f"Successfully ran {test_file}")
                print("=== Output ===")
                print(stdout)
            else:
                print(f"Error running {test_file}. Return code: {process.returncode}")
                print("=== Standard Output ===")
                print(stdout)
                print("=== Standard Error ===")
                print(stderr)
        except Exception as e:
            print(f"Error running {test_file}: {str(e)}")

if __name__ == "__main__":
    script_directory = os.path.dirname(__file__)
    root_directory = os.path.abspath(os.path.join(script_directory, ".."))

    command_line_args = sys.argv[1:]

    test_files = find_test_files(root_directory)
    
    if not test_files:
        print(f"No 'test.py' files found in '{root_directory}' or its subfolders.")
    else:
        run_tests(test_files, command_line_args)