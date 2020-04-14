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

def main(argv):
  global num_failing_tests

  tb = Testbench()
  tb.set_library("bitvis_vip_wishbone")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()


  # Setup testbench and run
  tb.set_tb_name("wishbone_vip_tb")
  tb.run_simulation()


  # Print simulation results
  tb.print_statistics()

  # Read number of failing tests for return value
  num_failing_tests = tb.get_num_failing_tests()





if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
