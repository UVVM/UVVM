#================================================================================================================================
# Copyright 2024 UVVM
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
import os
import subprocess
import sys

num_errors = 0

try:
    from hdlregression import HDLRegression

    hr = HDLRegression()

    # Add Util, VVC Framework and Scoreboard VIP
    hr.add_files("../../uvvm_util/src/*.vhd", "uvvm_util")
    hr.add_files("../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
    hr.add_files("../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
    # Add UART VIP
    hr.add_files("../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
    hr.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
    # Add UART DUT
    hr.add_files("../../bitvis_uart/src/*.vhd", "bitvis_uart")
    # Add SBI VIP
    hr.add_files("../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    # Add Spec Cov VIP
    hr.add_files("../src/*.vhd", "bitvis_vip_spec_cov")
    # Add Demo files
    hr.add_files("../demo/advanced_usage/*.vhd", "bitvis_vip_spec_cov")

    sim_options = None
    simulator_name = hr.settings.get_simulator_name()
    # Set simulator name and options
    if simulator_name == "MODELSIM":
        sim_options = "-t ns"

    script_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "./")
    C_NUM_TESTCASES = 4
    for i in range(C_NUM_TESTCASES):
      hr.add_generics(entity="uart_vvc_tb", architecture="func", generics=["GC_SCRIPT_PATH", (script_path, "PATH"), "GC_TESTCASE", i])

    num_errors += hr.start(sim_options=sim_options)

except:
    # Compile
    num_errors += subprocess.call(['vsim', '-c', '-do', 'do ../script/compile_demo.do advanced' + ';exit'], stderr=subprocess.PIPE)
    # Run simulation
    C_NUM_TESTCASES = 4
    for i in range(C_NUM_TESTCASES):
      script_call = 'do ../script/simulate_demo.do ' + str(i)
      num_errors += subprocess.call(['vsim', '-c', '-do', script_call + ';exit'], stderr=subprocess.PIPE)

# Run the specification coverage python script
num_errors += subprocess.call(['python', '../script/run_spec_cov.py', '--config', '../demo/advanced_usage/config_advanced_demo.txt'], stderr=subprocess.PIPE)

if num_errors != 0:
    sys.exit(num_errors)