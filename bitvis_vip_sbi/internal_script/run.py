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
def run_simulation(library, testbench, tests, verbose=False):
  global num_tests_run
  global num_failing_tests

  if len(tests) == 0: tests = ["undefined"]

  for test in tests:
    num_tests_run += 1
    print(testbench + ":: " + test + ": ", end='')

    script_call = 'do ../internal_script/run_simulation.do ' + library + ' ' + testbench + ' ' + test
    if verbose == False:
      subprocess.call(['vsim', '-c', '-do', script_call + ';exit'], stdout=FNULL, stderr=subprocess.PIPE)
    else:
      subprocess.call(['vsim', '-c', '-do', script_call + ';exit'], stderr=subprocess.PIPE)

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


def main(argv):
  tests = []
  # Check verbosity
  verbose = check_arguments(argv)
  # Compile testbench, dependencies and DUT
  compile(verbose)

  # Configuration
  script_folder = "../internal_script"
  # Set library for TB compilations
  library = "bitvis_vip_sbi"

  # Define tests
  tests = [ "simple_write_and_check",
            "simple_write_and_read",
            "test_of_poll_until",
            "extended_write_and_read",
            "read_of_previous_value",
            "read_of_executor_status_and_inter_bfm_delay",
            "distribution_of_vvc_commands",
            "vvc_broadcast_test",
            "vvc_setup_and_hold_time_test"]
  # Set testbench
  testbench = "sbi_tb"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, verbose)


  # Define tests
  tests = [ "fixed_wait_read_test"]
  # Set testbench
  testbench = "sbi_tb_multi_cycle_read"
  # Run testbench with defined tests
  run_simulation(library, testbench, tests, verbose)

  # Print simulation results
  print("Results: " + str(num_failing_tests) + " out of " + str(num_tests_run) + " failed.\n")



if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
