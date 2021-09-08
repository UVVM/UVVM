# Script for comparing the UVVM-Util testbench output files for log and alert tests

import os
import sys
import glob
from pathlib import Path



def get_file_list(path = "."):
    filelist = []
    for filename in os.listdir(path):
      if filename.endswith(".txt"):
        filelist.append(filename)
    return filelist


def compare(modelsim=False, riviera=False):
  sim_path = os.getcwd()
  num_errors = 0

  if modelsim:
    golden_path = sim_path + '/../script/maintenance_script/golden_modelsim'
  elif riviera:
    golden_path = sim_path + '/../script/maintenance_script/golden_riviera_pro'

  # Get file lists
  filelist = get_file_list(".")
  golden_file_list = get_file_list(golden_path)

  failing_verify_file = []

  for filename in filelist:
      golden_file = golden_path + '/' + filename

      if os.path.isfile(golden_file):
          golden_file_lines = len(open(golden_file).readlines(  ))
          check_file_lines  = len(open(filename).readlines(  ))
            
          # Read golden file
          with open(golden_file, 'r') as file:
              golden_lines = file.readlines()

          # Read verify file 
          with open(filename, 'r') as file:
              verify_lines = file.readlines()

          # Compare files
          error_found = False
          for idx, line in enumerate(golden_lines):
              if golden_lines[idx] != verify_lines[idx]:
                  failing_verify_file.append(filename)
                  error_found = True
                  break
          # Check for line number mismatch
          if not(error_found) and (golden_file_lines != check_file_lines):
              failing_verify_file.append(filename)
              error_found = True

          # Remove OK files
          if not(error_found):
              os.remove(filename)   

      else:
          print("ERROR! Golden do not have file : %s" %(filename))             
          failing_verify_file.append(filename)
        


  if modelsim:
    simulator = "[MODELSIM]"
  elif riviera:
    simulator = "[RIVIERA_PRO]"

  # Present statistics
  print("%s Number of golden files found : %d" %(simulator, len(golden_file_list)))
  print("%s Number of verify files found : %d" %(simulator, len(filelist)))
  print("%s Number of verified files with errors : %d" %(simulator, len(failing_verify_file)))

  # Check that all files have been verified
  num_missing_files = abs(len(filelist) - len(golden_file_list))
  if num_missing_files > 0:
      print("WARNING! Number of files do not match : %d != %d" %(len(filelist), len(golden_file_list)))

  # List files with errors
  if failing_verify_file:
      print("Mismatch found in the following file(s) : ")
      for file in failing_verify_file:
          print(file)

  # Return the number of errors to caller
  num_errors = len(failing_verify_file) + num_missing_files
  if num_errors != 0:
      print("Golden failed with %d error(s)." %(num_errors))
  sys.exit(num_errors)





def main(argv):
  args = [arg.lower() for arg in argv]

  for arg in args:
    if ("modelsim" in arg) or ("vsim" in arg):
      print("Verify golden modelsim files : ")
      print("--------------------------------------")
      compare(modelsim = True)

    elif ("vcom" in arg) or ("riviera" in arg) or ("rivierapro" in arg) or ("aldec" in arg):
      print("Verify golden riviera pro files : ")
      print("--------------------------------------")
      compare(riviera = True)

    else:
      print("Please specify simulator as argument: modelsim or riviera")



if __name__ == "__main__":
  main(sys.argv)
