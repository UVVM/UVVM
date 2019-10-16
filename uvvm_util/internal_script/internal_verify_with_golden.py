# Script for comparing the UVVM-Util testbench output files for log and alert tests

import os
import sys
import glob
from pathlib import Path


def cmp_files(sim_file, golden_file):
  l1 = l2 = ' '
  with open(sim_file, 'r') as f1, open(golden_file, 'r') as f2:
    l1 = f1.readline().rstrip()
    l2 = f2.readline().rstrip()

    while l1 != '' and l2 != '':
      if l1 != l2:
        print("ERROR: File "+ sim_file + " was not as expected!")
        return 1
      else:
        l1 = f1.readline().rstrip()
        l2 = f2.readline().rstrip()

  os.remove(sim_file)
  return 0


def compare(modelsim=False, riviera=False):
  sim_path = os.getcwd()
  num_errors = 0

  if modelsim:
    golden_path = sim_path + '/../internal_script/golden_modelsim/test_outputs'
  elif riviera:
    golden_path = sim_path + '/../internal_script/golden_riviera_pro/test_output/'


  sim_files = [f for f in glob.glob(sim_path + "**/*.txt", recursive=False)]
  golden_files = [f for f in glob.glob(golden_path + "**/*.txt", recursive=False)]

  if len(sim_files) != len(golden_files):
    print("ERROR! number of output files and golden files do not match! " + str(len(sim_files)) + " / " + str(len(golden_files)))
  else:
    for idx in range(len(golden_files)):
      print(sim_files[idx] + " <-----> " + golden_files[idx])
      num_errors += cmp_files(sim_files[idx], golden_files[idx])

  print("Number of files with error(s): " + str(num_errors))


def main(args):
  for arg in args:
    if ("vsim" or "modelsim") in arg.lower():
      print("Verify golden modelsim files")
      compare(modelsim = True)

    elif ("vcom" or "riviera" or "rivierapro") in arg.lower():
      print("Verify golden riviera pro files")
      compare(riviera = True)

    else:
      print("Please specify simulator as argument: modelsim or riviera")


if __name__ == "__main__":
  main(sys.argv)
