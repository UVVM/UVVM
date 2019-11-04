#!/usr/bin/python
############################################################################
# This script will run all simulations for this component
#
# By Arild Reiersen, Bitvis AS
############################################################################

import os
import datetime
import subprocess
import shutil
import sys
sys.path.append('../../release')
from commons_library import *



def simulate(log_to_transcript):

  component = "uvvm_util"

  separation_line = "--------------------------------------------------"

  sim_log = Logger(log_to_transcript)

  sim_log.log("\n" + component)
  sim_log.log("\n" + separation_line)

  os.chdir("internal_script")

  # Delete old compiled libraries and simulations if any
  if os.path.exists("vunit_out"):
    shutil.rmtree("vunit_out")

  # Simulate in modelsim
  sim = subprocess.run(["py", "internal_run.py", "-p8"], stdout=subprocess.PIPE, stderr= subprocess.PIPE, text=True)
  if sim.returncode == 0:
    sim_log.log("\nModelsim : PASS")
  else:
    sim_log.log("\nModelsim : FAILED")
    sim_log.log("\n" + sim.stderr)

  # Compare logs with Golden reference
  sim = subprocess.run(["py", "internal_compare_sim_output.py", "-p8"], stdout=subprocess.PIPE, stderr= subprocess.PIPE, text=True)
  if sim.returncode == 0:
    sim_log.log("\nGolden reference: PASS")
  else:
    sim_log.log("\nGolden reference: FAILED")
    sim_log.log("\n" + sim.stderr)

  # Delete compiled libraries and simulations
  if os.path.exists("vunit_out"):
    shutil.rmtree("vunit_out")

  # Simulate in Riviera Pro
  sim = subprocess.run(["py", "internal_run_riviera_pro.py"], stdout=subprocess.PIPE, stderr= subprocess.PIPE, text=True)
  if sim.returncode == 0:
    sim_log.log("\nRiviera Pro : PASS")
  else:
    sim_log.log("\nRiviera Pro : FAILED")
    sim_log.log("\n" + sim.stderr)

  # Compare logs with Golden reference
  sim = subprocess.run(["py", "internal_compare_sim_output.py", "-p8"], stdout=subprocess.PIPE, stderr= subprocess.PIPE, text=True)
  if sim.returncode == 0:
    sim_log.log("\nGolden reference: PASS")
  else:
    sim_log.log("\nGolden reference: FAILED")
    sim_log.log("\n" + sim.stderr)

  # Delete compiled libraries and simulations
  if os.path.exists("vunit_out"):
    shutil.rmtree("vunit_out")

  # Return to main component directory
  os.chdir("..")

  return sim_log.get_log()



def main():
  os.chdir("..")
  # Delete the status.txt file
  if os.path.exists("status.txt"):
    os.remove("status.txt")
  status = open("status.txt", "w+")
  status.write(simulate(True))
  status.close()



if __name__ == '__main__':
  main()