#========================================================================================================================
# Copyright (c) 2018 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

from os.path import join, dirname
from itertools import product
import os, sys, subprocess, pprint

# Verbosity
verbose = False

# Disable terminal output
FNULL = open(os.devnull, 'w')

# Counters
num_tests_run = 0
num_failing_tests = 0


#=============================================================================================
#
# Methods
#
#=============================================================================================


# Script arguments
def check_arguments(args):
  for arg in args:
    if arg.upper() == '-V':
      return True
  return False

# Compile DUT, testbench and dependencies
def compile(verbose=False):
  print("\nCompiling and running tests:")
  if verbose == False:
    subprocess.call(['vsim', '-c', '-do', 'do ../internal_script/compile_all.do' + ';exit'], stdout=FNULL, stderr=subprocess.PIPE)
  else:
    subprocess.call(['vsim', '-c', '-do', 'do ../internal_script/compile_all.do' + ';exit'], stderr=subprocess.PIPE)

# Run testbench simulation
def simulate(script_call, verbose=False):
  if verbose == False:
    subprocess.call(['vsim', '-c', '-do', script_call + ';exit'], stdout=FNULL, stderr=subprocess.PIPE)
  else:
    subprocess.call(['vsim', '-c', '-do', script_call + ';exit'], stderr=subprocess.PIPE)

# Clean-up
def clean_up(test):
  os.remove(test + "_Alert.txt")
  os.remove(test + "_Log.txt")
  os.remove('transcript')

# Check simulation results
def check_sim_result(filename):
  for line in open(filename, 'r'):
    if ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" in line:
      return True
  return False

# Run simulations and check result
def run_simulation(library, testbench, tests, configs , verbose=False):
  global num_tests_run
  global num_failing_tests

  if len(tests) == 0: tests = ["undefined"]
  if len(configs) == 0: configs = [""]

  for test in tests:

    for config in configs:
      num_tests_run += 1
      print("%s:: %s.config=%s : " % (testbench, test, config), end='')

      script_call = 'do ../internal_script/run_simulation.do ' + library + ' ' + testbench + ' ' + test + ' ' + str(config)
      simulate(script_call, verbose)

      if check_sim_result("transcript") == True:
        print("PASS")
        clean_up(test)

      else:
        print("FAILED")
        num_failing_tests += 1





#=============================================================================================
# User edit starts here: define tests and run
#=============================================================================================

# Create testbench configuration with TB generics
def create_config(data_widths, user_widths, id_widths, dest_widths, include_tuser=False):
  config = []

  if include_tuser:
    include_tuser = 1
  else:
    include_tuser = 0

  for data_width, user_width, id_width, dest_width in product(data_widths, user_widths, id_widths, dest_widths):
    config.append(str(data_width) + ' ' + str(user_width) + ' ' + str(id_width) + ' ' + str(dest_width) + ' ' + str(include_tuser))

  return config


def main(argv):
  tests = []
  configs = []
  # Check verbosity
  verbose = check_arguments(argv)
  # Compile testbench, dependencies and DUT
  compile(verbose)

  # Set library for TB compilations
  library = "bitvis_vip_axistream"



  # Setup testbench
  testbench = "axistream_bfm_slv_array_tb"
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)

  # Setup testbench
  testbench = "axistream_multiple_vvc_tb"
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)

  # Setup testbench
  testbench = "axistream_simple_tb"
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)

  # Setup testbench
  testbench = "axistream_vvc_slv_array_tb"
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)

  # Setup testbench
  testbench = "axistream_vvc_simple_tb"
  configs = create_config(data_widths=[8, 16, 24, 64, 128], user_widths=[8], id_widths=[8], dest_widths=[4], include_tuser=[True])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)

  # Setup testbench
  testbench = "axistream_vvc_simple_tb"
  configs = create_config(data_widths=[32], user_widths=[1, 5], id_widths=[3], dest_widths=[1], include_tuser=[True])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)

  # Setup testbench
  testbench = "axistream_vvc_simple_tb"
  configs = create_config(data_widths=[32], user_widths=[1], id_widths=[1], dest_widths=[1], include_tuser=[False])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)


  # Setup testbench
  testbench = "axistream_multiple_vvc_tb"
  configs = create_config(data_widths=[32], user_widths=[1], id_widths=[1], dest_widths=[1], include_tuser=[True])
  # Run testbench
  run_simulation(library, testbench, tests, configs, verbose)




  # Print simulation results
  print("Results: " + str(num_failing_tests) + " out of " + str(num_tests_run) + " failed.\n")





#=============================================================================================
# User edit ends here
#=============================================================================================
if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
