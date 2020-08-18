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
  tb.set_library("bitvis_vip_i2c")
  tb.check_arguments(argv)

  # Compile VIP, dependencies, DUTs, TBs etc
  tb.compile()


  # Define tests
  tests = [ "master_to_slave_VVC-to-VVC_7_bit_addressing",
            "slave_to_master_VVC-to-VVC_7_bit_addressing",
            "master_to_slave_VVC-to-VVC_10_bit_addressing",
            "slave_to_master_VVC-to-VVC_10_bit_addressing",
            "single-byte_communication_with_master_dut",
            "single-byte_communication_with_single_slave_dut",
            "single-byte_communication_with_multiple_slave_duts",
            "multi-byte_transmit_to_i2c_master_dut",
            "multi-byte_receive_from_i2c_master_dut",
            "multi-byte_transmit_to_i2c_slave_dut",
            "multi-byte_receive_from_i2c_slave_dut",
            "multi-byte_receive_from_i2c_slave_VVC-to-VVC",
            "multi-byte_transaction_with_i2c_master_dut_with_repeated_start_conditions",
            "single-byte_communication_with_multiple_slave_duts_without_stop_condition_in_between",
            "multi-byte_transmit_to_i2c_master_dut_10_bit_addressing",
            "multi-byte_receive_from_i2c_master_dut_10_bit_addressing",
            "receive_and_fetch_result",
            "multi-byte-send-and-receive-with-restart",
            "master-slave-vvc-quick-command",
            "master_quick_cmd_I2C_7bit_dut_test",
            "scoreboard_test"]
  tb.add_tests(tests)

  # Setup testbench and run
  tb.set_tb_name("i2c_vvc_tb")
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
