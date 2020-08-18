#================================================================================================================================
# Copyright 2020 Bitvis
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

from itertools import product
import os, sys

sys.path.append("../../script")
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
           "spi_slave_dut_to_master_vvc",
           "scoreboard_test"]

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
