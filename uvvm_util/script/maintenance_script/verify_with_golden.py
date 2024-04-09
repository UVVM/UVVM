# Script for comparing the UVVM-Util testbench output files for log and alert tests
import os
import sys
import ntpath

# Lines to be filtered out due to expected mismatches
filter_list =  ["load_coverage_db",
                "write_coverage_db",
                "in the bins will be overwritten"]


def get_golden_file_list(simulator='modelsim', path=None):
  filelist = []

  if path is None:
      path = os.getcwd()
      
  golden_dir = 'golden_modelsim' if simulator == 'modelsim' else 'golden_riviera_pro'

  if 'release' in path:
    path = os.path.join(path, '../uvvm_util/script/maintenance_script/' + golden_dir)
  else:
    path = os.path.join(path, '../../uvvm_util/script/maintenance_script/' + golden_dir)

  golden_folder = os.path.abspath(path)
  
  print('Path for golden files: %s' % (golden_folder))

  for subdir, dirs, files in os.walk(golden_folder):
    for file in files:
      filepath = subdir + os.sep + file
      if '.txt' in filepath:
        filelist.append(filepath)
  return filelist


def get_test_file_list(path=None):
  filelist = []

  if path is None:
      path = os.path.join(os.getcwd(), '.')

  output_folder = os.path.abspath(path)  # Look in sim/
  
  print('Path for output files: %s' % (output_folder))

  for dirpath, dirs, files in os.walk(output_folder):
    for file in files:
      if 'hdlregression' in dirpath and 'test' in dirpath and '.txt' in file:
        filepath = dirpath + os.sep + file
        if not 'report.txt' in file:
          filelist.append(filepath)
      elif 'func_cov' in file and '.txt' in file:
        filepath = dirpath + os.sep + file
        filelist.append(filepath)
  return filelist


def compare_lines(golden_lines, verify_lines):
  error_lines = []
  if len(golden_lines) != len(verify_lines):
    return False
  else:
    for idx, line in enumerate(golden_lines):
      if line.rstrip() != verify_lines[idx].rstrip():
        skip = False
        for filter_line in filter_list:
          if filter_line in line.rstrip():
            skip = True
        if not skip:
          error_lines.append('(%d) Golden >>> %s\n(%d) Output >>> %s' % (idx, line.strip(), idx, verify_lines[idx].rstrip()))
  return error_lines


def compare(modelsim=False, riviera=False, path=None):
  # Get file lists
  test_run_file_list = get_test_file_list(path)
  num_test_run_files = len(test_run_file_list)

  if modelsim:
    golden_file_list = get_golden_file_list(simulator='modelsim', path=path)
  if riviera:
    golden_file_list = get_golden_file_list(simulator='riviera', path=path)

  failing_verify_file = []
  missing_test_run_file = []

  for golden_file in golden_file_list:
    golden_file_name = ntpath.basename(golden_file)

    match = False
    # Locate matching test run file
    for test_run_file in test_run_file_list:
      test_run_file_name = ntpath.basename(test_run_file)

      # If filenames match (ignore paths), we have the correct files
      if test_run_file_name.lower() == golden_file_name.lower():
        test_file = test_run_file
        file_idx = test_run_file_list.index(test_run_file)
        test_run_file_list.pop(file_idx)
        match = True
        break

    if match is True:
      # Read golden file
      with open(golden_file, 'r') as file:
          golden_lines = file.readlines()
      # Read verify file
      with open(test_file, 'r') as file:
          verify_lines = file.readlines()

      test_file = test_file.replace('\\', '/')

      # Compare files
      error_lines = compare_lines(golden_lines, verify_lines)
      if error_lines:
        failing_verify_file.append([test_file, error_lines])

      # Check for line number mismatch
      if not test_file in failing_verify_file:
        golden_file_lines = len(open(golden_file).readlines())
        check_file_lines = len(open(test_file).readlines())
        if (golden_file_lines != check_file_lines):
          failing_verify_file.append([test_file, None])

    elif match is False:
      missing_test_run_file.append(golden_file_name.replace('\\', '/'))

  simulator = '[MODELSIM]' if modelsim else '[RIVIERA]'
  # Present statistics
  print("%s Number of golden files found : %d" % (simulator, len(golden_file_list)))
  print("%s Number of verify files found : %d" % (simulator, num_test_run_files))
  print("%s Number of verified files with errors : %d" % (simulator, len(failing_verify_file)))
  print('%s Number of missing test run files: %d' % (simulator, len(missing_test_run_file)))

  # Check that all files have been verified
  num_missing_files = abs(num_test_run_files - len(golden_file_list))
  if num_missing_files > 0:
    print("WARNING! Number of files do not match : %d != %d" % (num_test_run_files, len(golden_file_list)))

  # List files with errors
  if failing_verify_file:
    print("Mismatch found in the following file(s) : ")
    for file, error_lines in failing_verify_file:
      print('\n%s\nFile: %s' % (50*'-', file))
      if error_lines:
        for line in error_lines:
          print(line)

  # List files that are found in golden folder but not in test run folder
  if missing_test_run_file:
    print('Missing test run files:')
    for file in missing_test_run_file:
      print(file)

  # List files that were generated by tests but not found in golden list
  if len(test_run_file_list) > 0:
    print('The following files were not found in golden list:')
    for file in test_run_file_list:
      print(file)

  # Return the number of errors to caller
  num_errors = len(failing_verify_file) + num_missing_files
  if num_errors != 0:
      print("Golden failed with %d error(s)." % (num_errors))
      
  if len(golden_file_list) == 0 or num_test_run_files == 0:
      print('Missig files for comparing with golden! Returning fail!')
      sys.exit(1 + num_errors)

  sys.exit(num_errors)


def main(argv):
  args = [arg.lower() for arg in argv]

  path = None
  if len(args) > 2:
      path = args[2]

  for arg in args:
    if ("modelsim" in arg) or ("vsim" in arg):
      print("Verify golden modelsim files : ")
      print("--------------------------------------")
      compare(modelsim=True, path=path)

    elif ("vcom" in arg) or ("riviera" in arg) or ("rivierapro" in arg) or ("aldec" in arg):
      print("Verify golden riviera pro files : ")
      print("--------------------------------------")
      compare(riviera=True, path=path)

  # No simulator match
  print("Please specify simulator as argument: modelsim or riviera")
  sys.exit(1)


if __name__ == "__main__":
  main(sys.argv)