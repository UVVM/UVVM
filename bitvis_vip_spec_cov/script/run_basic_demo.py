#========================================================================================================================
# Copyright (c) 2019 by Bitvis AS.  All rights reserved.
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
subprocess.call(['vsim', '-c', '-do', 'do ../script/compile_demo.do basic' + ';exit'], stderr=subprocess.PIPE)

# Run simulation
subprocess.call(['vsim', '-c', '-do', 'do ../script/run_basic_simulation.do' + ';exit'], stderr=subprocess.PIPE)

# Run the specification coverage python script
subprocess.call(['python', '../script/run_spec_cov.py', '-r', '../demo/basic_usage/req_list_basic_demo.csv', '-i', '../sim/partial_cov_basic_demo.csv', '-s', '../sim/spec_cov_basic_demo.csv'], stderr=subprocess.PIPE)