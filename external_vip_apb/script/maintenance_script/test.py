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

import sys

# Import the HDLRegression module to the Python script:
from hdlregression import HDLRegression

num_errors = 0

# Define a HDLRegression item to access the HDLRegression functionality:
hr = HDLRegression()

# Add UVVM Util, VVC Framework and Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add APB VIP source files
hr.add_files("../../src/*.vhd", "external_vip_apb")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "external_vip_apb")

# Add testbench files
hr.add_files("../../tb/maintenance_tb/*.vhd", "external_vip_apb")

sim_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and options
if simulator_name == "MODELSIM":
    sim_options = "-t ns"

num_errors += hr.start(sim_options=sim_options)

if num_errors != 0:
    sys.exit(num_errors)
