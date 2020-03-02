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
import os
import subprocess

# Compile
subprocess.call(['vsim', '-c', '-do', 'do ../script/compile_demo.do basic' + ';exit'], stderr=subprocess.PIPE)

# Run simulation
subprocess.call(['vsim', '-c', '-do', 'do ../script/simulate_demo.do' + ';exit'], stderr=subprocess.PIPE)

# Run the specification coverage python script
subprocess.call(['python', '../script/run_spec_cov.py', '-r', '../demo/basic_usage/req_list_basic_demo.csv', '-p', '../sim/partial_cov_basic_demo.csv', '-s', '../sim/spec_cov_basic_demo.csv'], stderr=subprocess.PIPE)