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
#
# Define tests and run - user to edit this
#
#=============================================================================================

# Create testbench configuration with TB generics
def create_config(spi_modes, data_widths, data_array_widths):
  config = []
  for spi_mode, data_width, data_array_width in product(spi_modes, data_widths, data_array_widths):
    config.append(str(spi_mode) + ' ' + str(data_width) + ' ' + str(data_array_width))
    #config.append("-gGC_SPI_MODE=" + str(spi_mode) + ' ' + 
    #              "-GC_DATA_WIDTH=" + str(data_width) + ' ' + 
    #              "gGC_DATA_ARRAY_WIDTH=" + str(data_array_width))

  return config


def main(argv):
  global num_failing_tests
  tests = []
  configs = []


  tb = Testbench()
  tb.set_library("bitvis_vip_spi")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()

  # Create test configuration (generics)
  configs = create_config(spi_modes=range(0,4), data_widths=[8, 14, 23, 32], data_array_widths=[2, 4, 6, 8])

  # Define tests
  tests = ["VVC-to-VVC",
           "spi_master_dut_to_slave_VVC",
           "spi_slave_vvc_to_master_dut",
           "spi_master_vvc_to_slave_dut",
           "spi_slave_dut_to_master_vvc"]

  # Setup testbench and run
  tb.set_tb_name("spi_vvc_tb")
  tb.add_tests(tests)
  tb.set_configs(configs)
  tb.run_simulation()


  # Print simulation results
  tb.print_statistics()

  # Read number of failing tests for return value
  num_failing_tests = tb.get_num_failing_tests()



if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
