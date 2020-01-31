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
import os, sys, subprocess

sys.path.append("../../release/regression_test")
from testbench import Testbench


# Counters
num_tests_run = 0
num_failing_tests = 0


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
  global num_failing_tests
  tests = []

  tb = Testbench()
  tb.set_library("bitvis_vip_spec_cov")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()

  tests = [ "initialize_req_cov",
            "initialize_req_cov_with_tc",
            "reset_of_req_cov_matrix",
            "requirement_exists",
            "requirement_and_tc_exists",
            "log_req_cov_normal",
            "log_req_cov_with_error"
          ]

  # Setup testbench and run
  tb.set_tb_name("spec_cov_tb")
  tb.add_tests(tests)
  tb.run_simulation()


  # Print simulation results
  tb.print_statistics()

  # Read number of failing tests for return value
  num_failing_tests = tb.get_num_failing_tests()






#=============================================================================================
# User edit ends here
#=============================================================================================
if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
