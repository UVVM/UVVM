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

import os, sys

sys.path.append("../../script")
from testbench import Testbench


# Counters
num_tests_run = 0
num_failing_tests = 0


#=============================================================================================
# User edit starts here: define tests and run
#=============================================================================================

def main(argv):
  global num_failing_tests
  tests = []

  tb = Testbench()
  tb.set_library("bitvis_vip_spec_cov")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()

  tests = ["test_init_with_no_requirement_file",
           "test_init_with_requirement_file",
           "test_log_listed_and_not_listed_requirements",
           "test_log_testcase_pass_and_fail",
           "test_uvvm_status_error_before_log",
           "test_uvvm_status_error_after_log",
           "test_open_no_existing_req_file",
           "test_sub_requirement_pass",
           "test_sub_requirement_fail",
           "test_sub_requirement_incomplete",
           "test_sub_requirement_omitted",
           "test_sub_requirement_omitted_check_pass",
           "test_sub_requirement_omitted_check_fail",
           "test_incomplete_testcase",
           "test_testcase_with_multiple_reqs",
           "test_requirement_name_match", 
           "test_list_single_tick_off",
           "test_list_single_tick_off_pass_then_fail",
           "test_list_tick_off_disable"
          ]

  # Setup testbench and run
  tb.set_tb_name("spec_cov_tb")
  tb.add_tests(tests)
  # This test should be aborted by UVVM due to alert count vs expected mismatch
  tb.add_expected_failing_testcase("test_incomplete_testcase") 
  # Start simulations
  tb.run_simulation()


  # Print simulation results
  tb.print_statistics()

  # Read number of failing tests for return value
  num_failing_tests = tb.get_num_failing_tests()

  # Run golden verification and update any errors
  num_failing_golden = tb.run_verify_with_golden("maintenance_run_spec_cov.py")

  # Return number of failing tests to caller
  sys.exit(num_failing_tests + num_failing_golden)




#=============================================================================================
# User edit ends here
#=============================================================================================
if __name__ == "__main__":
  main(sys.argv)
