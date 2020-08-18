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
# User edit starts here: define tests and run
#=============================================================================================

# Create testbench configuration with TB generics
def create_config(channel_widths, data_widths, error_widths):
  config = []

  for channel_width, data_width, error_width in product(channel_widths, data_widths, error_widths):
    config.append(str(channel_width) + ' ' + str(data_width) + ' ' + str(error_width))

  return config


def main(argv):
  global num_failing_tests
  configs = []
  tests = []

  tb = Testbench()
  tb.set_library("bitvis_vip_avalon_st")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()

  # Define tests
  tests = [ "test_packet_data",
            "test_stream_data",
            "test_setup_and_hold_times"
          ]

  # Set testbench, config and run
  tb.set_tb_name("avalon_st_bfm_tb")
  configs = create_config(channel_widths=[7], data_widths=[8], error_widths=[1])
  tb.set_configs(configs)
  tb.add_tests(tests)
  tb.run_simulation()

  tb.set_tb_name("avalon_st_bfm_tb")
  configs = create_config(channel_widths=[8], data_widths=[16], error_widths=[1])
  tb.set_configs(configs)
  tb.add_tests(tests)
  tb.run_simulation()

  tb.set_tb_name("avalon_st_bfm_tb")
  configs = create_config(channel_widths=[8], data_widths=[32], error_widths=[1])
  tb.set_configs(configs)
  tb.add_tests(tests)
  tb.run_simulation()

  tb.set_tb_name("avalon_st_vvc_tb")
  configs = create_config(channel_widths=[7], data_widths=[8], error_widths=[1])
  tb.set_configs(configs)
  tb.add_tests(tests)
  tb.run_simulation()

  tb.set_tb_name("avalon_st_vvc_tb")
  configs = create_config(channel_widths=[8], data_widths=[16], error_widths=[1])
  tb.set_configs(configs)
  tb.add_tests(tests)
  tb.run_simulation()

  tb.set_tb_name("avalon_st_vvc_tb")
  configs = create_config(channel_widths=[8], data_widths=[32], error_widths=[1])
  tb.set_configs(configs)
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
