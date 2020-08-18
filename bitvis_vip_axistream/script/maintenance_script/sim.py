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
def create_config(data_widths, user_widths, id_widths, dest_widths, include_tuser=False, use_setup_and_hold=False):
  config = []

  if any(include_tuser):
    include_tuser = 1
  else:
    include_tuser = 0

  if any(use_setup_and_hold):
    use_setup_and_hold = 1
  else:
    use_setup_and_hold = 0

  for data_width, user_width, id_width, dest_width in product(data_widths, user_widths, id_widths, dest_widths):
    config.append(str(data_width) + ' ' + str(user_width) + ' ' + str(id_width) + ' ' + str(dest_width) + ' ' + str(include_tuser) + ' ' + str(use_setup_and_hold))

  return config


def main(argv):
  global num_failing_tests
  configs = []

  tb = Testbench()
  tb.set_library("bitvis_vip_axistream")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()


  # Set testbench, config and run
  tb.set_tb_name("axistream_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  tb.set_tb_name("axistream_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_simple_tb")
  configs = create_config(data_widths=[8, 16, 24, 64, 128], user_widths=[8], id_widths=[8], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[1, 5], id_widths=[3], dest_widths=[1], include_tuser=[True], use_setup_and_hold=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[1], id_widths=[1], dest_widths=[1], include_tuser=[False], use_setup_and_hold=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_bfm_slv_array_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  tb.set_tb_name("axistream_bfm_slv_array_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_slv_array_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  tb.set_tb_name("axistream_vvc_slv_array_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_multiple_vvc_tb")
  configs = create_config(data_widths=[32], user_widths=[1], id_widths=[1], dest_widths=[1], include_tuser=[True], use_setup_and_hold=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_multiple_vvc_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[False])
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
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
