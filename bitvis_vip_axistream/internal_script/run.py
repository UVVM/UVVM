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
  configs = []

  tb = Testbench()
  tb.set_library("bitvis_vip_axistream")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()


  # Set testbench, config and run
  tb.set_tb_name("axistream_bfm_slv_array_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_slv_array_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_simple_tb")
  configs = create_config(data_widths=[8, 16, 24, 64, 128], user_widths=[8], id_widths=[8], dest_widths=[4], include_tuser=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[1, 5], id_widths=[3], dest_widths=[1], include_tuser=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_vvc_simple_tb")
  configs = create_config(data_widths=[32], user_widths=[1], id_widths=[1], dest_widths=[1], include_tuser=[False])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_multiple_vvc_tb")
  configs = create_config(data_widths=[32], user_widths=[1], id_widths=[1], dest_widths=[1], include_tuser=[True])
  tb.set_configs(configs)
  tb.run_simulation()

  # Set testbench, config and run
  tb.set_tb_name("axistream_multiple_vvc_tb")
  configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True])
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
