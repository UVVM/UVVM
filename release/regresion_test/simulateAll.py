#!/usr/bin/python
############################################################################
# This script will run through all DIPs, VIPs and UVVM repositories and
# run the internal_run.py simulation scripts. The outcome of the simulations
# will be written to status.txt
#
# By Andre Firing, Bitvis AS
# Modified and converted to Python by Arild Reiersen, Bitvis
############################################################################

import os
import datetime
import subprocess
import shutil

def main():

  separation_line = "\n\n=================================================="

  # Delete the status.txt file
  if os.path.exists("status.txt"):
    os.remove("status.txt")

  status = open("status.txt", "w+")

  def log(message):
    print(message, flush=True)
    status.write(message)

  def simulate(component):
    os.chdir("../../" + component + "/sim/")
    log(separation_line)
    log("\n" + component)

    # Delete old compiled libraries and simulations if any
    if os.path.exists("vunit_out"):
      shutil.rmtree("vunit_out")

    # Simulate in modelsim
    if os.path.exists("internal_run.py"):
      sim = subprocess.run(["py", "internal_run.py", "-p8"], stdout=subprocess.PIPE, stderr= subprocess.PIPE)
      #sim.wait()
      if sim.returncode == 0:
        log("\nModelsim : PASS")
      else:
        log("\nModelsim : FAILED")
        log(sim.stderr)

    # Delete compiled libraries and simulations
    if os.path.exists("vunit_out"):
      shutil.rmtree("vunit_out")

    # Simulate in Riviera Pro
    if os.path.exists("internal_run_riviera_pro.py"):
      sim = subprocess.run(["py", "internal_run_riviera_pro.py"], stdout=subprocess.PIPE, stderr= subprocess.PIPE)
      #sim.wait()
      if sim.returncode == 0:
        log("\nRiviera Pro : PASS")
      else:
        log("\nRiviera Pro : FAILED")
        log(sim.stderr)

    # Delete compiled libraries and simulations
    if os.path.exists("vunit_out"):
      shutil.rmtree("vunit_out")

    os.chdir("../../release/regresion_test")

  log("Starting tests at " + datetime.datetime.now().strftime("%H:%M:%S"))

  with open("../component_list.txt", "r") as components:
    line = components.readline()
    while line:
      simulate(line.strip())
      line = components.readline()

  log(separation_line)
  log("\nEnding test at " + datetime.datetime.now().strftime("%H:%M:%S"))
  status.close()



if __name__ == '__main__':
  main()