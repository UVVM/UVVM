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
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--gui", help="opens simulation in GUI mode", action="store_true")
args = parser.parse_args()

# Compile
output = subprocess.run(['vsim', '-c', '-do', 'do compile_demo.do' + ';exit'], stderr=subprocess.PIPE)

# Run simulation if successful compile
if output.returncode == 0:
    if args.gui:
      subprocess.call(['vsim', '-gui', '-do', 'do run_simulation.do'], stderr=subprocess.PIPE)
    else:
      subprocess.call(['vsim', '-c', '-do', 'do run_simulation.do' + ';exit'], stderr=subprocess.PIPE)
