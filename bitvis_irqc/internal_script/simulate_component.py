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

  component = "bitvis_irqc"

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

  # Delete compiled libraries and simulations
  if os.path.exists("vunit_out"):
    shutil.rmtree("vunit_out")

  os.chdir("../script")
  sim = subprocess.run(['vsim', '-c',  '-do', 'do compile_all_and_simulate.do' + ';exit'], stdout=subprocess.PIPE, stderr= subprocess.PIPE, text=True)

  demo_pass = False
  if sim.returncode == 0:
    # Check transcript for any errors
    with open("transcript", "r") as transcript:
      lines = transcript.read().splitlines()
      last_line = lines[-1]
      if "Errors: 0" in last_line.strip():
        demo_pass = True

  if demo_pass:
    sim_log.log("\nDemo : PASS")
  else:
    sim_log.log("\nDemo : FAILED")
    sim_log.log(sim.stderr)

  # Delete compiled libraries and transcripts
  if os.path.exists("modelsim.ini"):
    os.remove("modelsim.ini")

  if os.path.exists("_Alert.txt"):
    os.remove("_Alert.txt")

  if os.path.exists("_Log.txt"):
    os.remove("_Log.txt")

  if os.path.exists("transcript"):
    os.remove("transcript")

  if os.path.exists("../sim/bitvis_irqc"):
    shutil.rmtree("../sim/bitvis_irqc")

  if os.path.exists("../../uvvm_util/sim/uvvm_util"):
    shutil.rmtree("../../uvvm_util/sim/uvvm_util")

  if os.path.exists("../../uvvm_vvc_framework/sim/uvvm_vvc_framework"):
    shutil.rmtree("../../uvvm_vvc_framework/sim/uvvm_vvc_framework")

  if os.path.exists("../../bitvis_vip_sbi/sim/bitvis_vip_sbi"):
    shutil.rmtree("../../bitvis_vip_sbi/sim/bitvis_vip_sbi")

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