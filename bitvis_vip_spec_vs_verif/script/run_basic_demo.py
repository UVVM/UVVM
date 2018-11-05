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
import os
import subprocess

# Compile
subprocess.call(['vsim', '-c', '-do', 'do ../script/compile_demo.do ../ basic' + ';exit'], stderr=subprocess.PIPE)

# Run simulation
subprocess.call(['vsim', '-c', '-do', 'do ../script/run_basic_simulation.do' + ';exit'], stderr=subprocess.PIPE)

# Run the specification vs verification python script
subprocess.call(['python', '../script/run_spec_vs_verif.py', '--requirements', '../demo/basic_usage/req_to_test_map.csv', '--resultfile', '../sim/basic_demo_req_output_file.csv', '--output', '../sim/basic_usage_requirement_results.csv'], stderr=subprocess.PIPE)
