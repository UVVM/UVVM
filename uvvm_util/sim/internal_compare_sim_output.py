# Script for comparing the UVVM-Util testbench output files for log and alert tests

import sys




#
# Map hashed folder names with test output name
#
def map_folders(filename = "vunit_out/test_output/test_name_to_path_mapping.txt"):
  try:
    with open(filename) as f:
      file_content = f.readlines()
  except IOError:
    print ("Error: unable to read from file " + str(filename))
    return None

  new_vunit_version = False
  folder_mapping = []
  for line in file_content:
    if ' ' in line: # new VUnit version - dirty fix for version detection
      new_vunit_version = True
      line_content = line.split()
      if line_content[1] in line_content[0]:
        line = line.split()
        folder = line[1]
        line[1] = line[0]
        line[0] = folder  
        folder_mapping.append(line)
    else: # old VUnit version
      folder = line[1]
      line[1] = line[0]
      line[0] = folder  
      folder_mapping.append(line)

  if new_vunit_version:
    print("Test results mapped from new VUnit version.")
  else:
    print("Test results mapped from old VUnit version.")
  return (len(folder_mapping), folder_mapping)

  
#
# Compare files and ignore CRLF
#   Standard python filecmp.cmp() don't ignore CRLF and this 
#   might cause the file comparing to fail.
#
def cmp_files(folder, filename):
  file1 = "golden/" + folder[0] + "/" + filename
  file2 = "vunit_out/test_output/" + folder[1] + "/" + filename
  l1 = l2 = ' '
  with open(file1, 'r') as f1, open(file2, 'r') as f2:
    while l1 != '' and l2 != '':
      l1 = f1.readline().rstrip()
      l2 = f2.readline().rstrip()
      if l1 != l2:
        print("ERROR: File "+ filename + " was not as expected!")
        print("Golden: " + str(file1) + "\nVunit_out: " + str(file2))
        exit(1)

  print("Content of file "+ folder[0] + "." + filename + " was as expected.")




# Get foldernames
(numb_folders, mapped_folders) = map_folders("vunit_out/test_output/test_name_to_path_mapping.txt")

# Compare test output result with expected output
for folder in mapped_folders:
  if folder[0] == "uvvm_util.methods_tb.basic_log_alert":
    filename = "alertlog.txt"
    cmp_files(folder, filename)
    filename = "testlog.txt"
    cmp_files(folder, filename)
  elif folder[0] == "uvvm_util.methods_tb.enable_disable_log_msg":
    filename = "testlog.txt"
    cmp_files(folder, filename)
  elif folder[0] == "uvvm_util.methods_tb.log_header_formatting":
    filename = "testlog.txt"
    cmp_files(folder, filename)
  elif folder[0] == "uvvm_util.methods_tb.log_text_block":
    filename = "testlog.txt"
    cmp_files(folder, filename)
  elif folder[0] == "uvvm_util.methods_tb.log_to_file":
    filename = "testlog.txt"
    cmp_files(folder, filename)
    filename = "alertlog.txt"
    cmp_files(folder, filename)
    filename = "file1.txt"
    cmp_files(folder, filename)
    filename = "file2.txt"
    cmp_files(folder, filename)
  elif folder[0] == "uvvm_util.methods_tb.setting_output_file_name":
    filename = "alertlog.txt"
    cmp_files(folder, filename)
    filename = "alertlog2.txt"
    cmp_files(folder, filename)
    filename = "alertlog3.txt"
    cmp_files(folder, filename)
    filename = "testlog.txt"
    cmp_files(folder, filename)
    filename = "testlog2.txt"
    cmp_files(folder, filename)
    filename = "testlog3.txt"
    cmp_files(folder, filename)
  elif folder[0] == "uvvm_util.methods_tb.string_methods":
    filename = "testlog.txt"
    cmp_files(folder, filename)


# All OK, report and exit
print("\nAll checked log and alert files were as expected in %i folders" %(numb_folders))
exit(0)
