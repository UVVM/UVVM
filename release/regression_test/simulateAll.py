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
import sys
import importlib
sys.path.append('..')
from commons_library import *

def main():

  separation_line = "=================================================="

  # Delete the status.txt file
  if os.path.exists("status.txt"):
    os.remove("status.txt")

  status = open("status.txt", "w+")

  def log(message):
    print(message, flush=True)
    status.write(message)

  def simulate(component):
    log("\n" + separation_line)
    os.chdir("../../" + component)
    sys.path.append('internal_script')
    import simulate_component
    importlib.reload(simulate_component)
    log(simulate_component.simulate(False))

    sys.path.remove('internal_script')

    os.chdir("../release/regresion_test")
  log("\n" + separation_line)
  log("\n***               REGRESION TEST               ***")
  log("\n" + separation_line + "\n")

  start_time = datetime.datetime.now()
  log("\nStarting tests at " + start_time.strftime("%H:%M:%S"))

  with open("../component_list.txt", "r") as components:
    line = components.readline()
    while line:
      simulate(line.strip())
      line = components.readline()

  log("\n" + separation_line)
  end_time = datetime.datetime.now()
  sim_time = end_time - start_time
  days = sim_time.days
  hours, remainder = divmod(sim_time.seconds, 3600)
  hours += days*24
  minutes, seconds = divmod(remainder, 60)
  log("\nEnding test at " + end_time.strftime("%H:%M:%S"))
  log("\nSimulation time: " + str(hours) + ":" + "{:02}".format(minutes) + ":" + "{:02}".format(seconds))
  log("\n" + separation_line)
  status.close()



if __name__ == '__main__':
  main()