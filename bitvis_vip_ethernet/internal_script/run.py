#========================================================================================================================
# Copyright (c) 2020 by Bitvis AS.  All rights reserved.
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
def create_config(data_widths):
  config = []

  for data_width in product(data_widths):
    config.append(str(data_width))

  return config


def main(argv):
  global num_failing_tests
  configs = []

  tb = Testbench()
  tb.set_library("bitvis_vip_ethernet")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()

  # Set testbench and run
  tb.set_tb_name("ethernet_gmii_tb")
  tb.run_simulation()

  # Set testbench and run
  tb.set_tb_name("ethernet_gmii_mac_master_tb")
  tb.run_simulation()

  # Set testbench and run
  tb.set_tb_name("ethernet_gmii_mac_master_sb_tb")
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("ethernet_sbi_tb")
  configs = create_config([4, 8, 9, 12, 16])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("ethernet_sbi_sb_tb")
  configs = create_config([4, 8, 9, 12, 16])
  tb.set_configs(configs)
  tb.run_simulation()

  # Print simulation results
  tb.print_statistics()

  # Read number of failing tests for return value
  num_failing_tests = tb.get_num_failing_tests()


#=============================================================================================
# User edit ends here
#=============================================================================================
if __name__ == "__main__":
  # Run testbench
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
