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

      script_call = 'do ../internal_script/run_simulation.do ' + library + ' ' + testbench + ' ' + test + ' ' + config
      simulate(script_call, verbose)

      if check_sim_result("transcript") == True:
        print("PASS")
        clean_up(test)

      else:
        print("FAILED")
        num_failing_tests += 1





#=============================================================================================
#
# Define tests and run - user to edit this
#
#=============================================================================================

# Create testbench configuration with TB generics
def create_config(modes, data_widths, data_array_widths):
  config = []
  for mode, data_width, data_array_width in product(modes, data_widths, data_array_widths):
    config.append(str(mode) + ' ' + str(data_width) + ' ' + str(data_array_width))

  return config


def main(argv):
  tests = []
  configs = []
  # Check verbosity
  verbose = check_arguments(argv)
  # Compile testbench, dependencies and DUT
  compile(verbose)

  # Set library for TB compilations
  library = "uvvm_vvc_framework"

  # Setup testbench
  tests = [ "Testing_2_Sequencer_Parallel_using_different_types_of_VVCs",
            "Testing_2_Sequencer_Parallel_using_same_types_of_VVCs_but_different_instances",
            "Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_but_not_at_the_same_time",
            "Testing_get_last_received_cmd_idx",
            "Testing_differt_accesses_between_two_sequencer",
            "Testing_differt_single_sequencer_access",
            "Testing_shared_uvvm_status_await_any_completion_info"
            ]
  testbench = "internal_vvc_tb"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, configs, verbose)


  # Setup testbench
  tests = [ ]
  testbench = "simplified_data_queue_tb"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, configs, verbose)


  # Setup testbench
  tests = [ ]
  testbench = "generic_queue_tb"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, configs, verbose)


  # Setup testbench
  tests = [ ]
  testbench = "generic_queue_record_tb"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, configs, verbose)


  # Setup testbench
  tests = [ ]
  testbench = "generic_queue_array_tb"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, configs, verbose)



  # Print simulation results
  print("Results: " + str(num_failing_tests) + " out of " + str(num_tests_run) + " failed.\n")



if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
