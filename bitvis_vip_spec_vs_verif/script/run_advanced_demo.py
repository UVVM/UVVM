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
subprocess.call(['vsim', '-c', '-do', 'do compile_demo.do ../ advanced' + ';exit'], stderr=subprocess.PIPE)

# Run simulation
C_NUM_TESTCASES = 4
for i in range(C_NUM_TESTCASES):
  script_call = 'do run_advanced_simulation.do ' + str(i)
  subprocess.call(['vsim', '-c', '-do', script_call + ';exit'], stderr=subprocess.PIPE)

# Run the specification vs verification python script. Configuration of the script is read from file.
subprocess.call(['python', '../script/run_spec_vs_verif.py', '--config', '../demo/advanced_usage/script_config_file.txt'], stderr=subprocess.PIPE)
