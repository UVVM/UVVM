# Script for comparing the UVVM-Util testbench output files for log and alert tests

import sys
import os, os.path
  
#
# Compare files and ignore CRLF
#   Standard python filecmp.cmp() don't ignore CRLF and this 
#   might cause the file comparing to fail.
#
def cmp_files(filename):
  file1 = "golden/" + filename
  file2 = filename
  l1 = l2 = ' '
  with open(file1, 'r') as f1, open(file2, 'r') as f2:
    while l1 != '' and l2 != '':
      l1 = f1.readline().rstrip()
      l2 = f2.readline().rstrip()
      if l1 != l2:
        print("ERROR: File "+ filename + " was not as expected!")
        print("Golden: " + str(file1) + "\nTest output: " + str(file2))
        exit(1)

  print("Content of file "+ filename + " was as expected.")

  


# Compare test output result with expected output
golden_directory = 'golden/'
iterator = 0
for file in os.listdir(golden_directory):
  cmp_files(file)
  iterator+=1

# All OK, report and exit
print("\nAll %i checked result file(s) were as expected" %(iterator))
exit(0)
