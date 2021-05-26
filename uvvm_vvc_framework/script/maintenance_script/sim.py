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
#
# Define tests and run - user to edit this
#
#=============================================================================================

def main(argv):
  global num_failing_tests

  tb = Testbench()
  tb.set_library("uvvm_vvc_framework")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()

  tests = [ "Testing_2_Sequencer_Parallel_using_different_types_of_VVCs",
            "Testing_2_Sequencer_Parallel_using_same_types_of_VVCs_but_different_instances",
            "Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_but_not_at_the_same_time",
            "Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_at_the_same_time",
            "Testing_get_last_received_cmd_idx",
            "Testing_different_accesses_between_two_sequencer",
            "Testing_different_single_sequencer_access",
            "Testing_shared_uvvm_status_await_any_completion_info",
            "Testing_await_completion_from_different_sequencers",
            "Testing_await_any_completion_from_different_sequencers",
            "Testing_2_Sequencer_Parallel_using_same_instance_of_a_VVC_type_at_the_same_time"
            ]

  # Setup testbench and run
  tb.set_tb_name("vvc_tb")
  tb.add_tests(tests)
  tb.run_simulation()

  tb.remove_tests()

  # Setup testbench and run
  tb.set_tb_name("generic_queue_tb")
  tb.run_simulation()


  # Print simulation results
  tb.print_statistics()

  # Read number of failing tests for return value
  num_failing_tests = tb.get_num_failing_tests()





if __name__ == "__main__":
  main(sys.argv)

  # Return number of failing tests to caller
  sys.exit(num_failing_tests)
