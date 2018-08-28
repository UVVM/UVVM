# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015, Lars Asplund lars.anders.asplund@gmail.com

# Adapted for Bitvis use by Daniel Blomkvist, 2015

from os.path import join, dirname
import os
import subprocess

# Make vunit python module importable. Can be removed if vunit is on you pythonpath
# environment variable
import sys
path_to_vunit = join(dirname(__file__), '..', '..', 'vunit')
sys.path.append(path_to_vunit)
#  -------

# --------------
# Set VUNIT_SIMULATOR environment variable
os.environ["VUNIT_SIMULATOR"] = "rivierapro"
#------------------------------------------

from vunit import VUnit, VUnitCLI

def execute_riviera_pro_command(path):
  try:
    output = subprocess.call(['vsimsa', '-do', 'do ' + path + ';exit'], stderr=subprocess.PIPE)
  except subprocess.CalledProcessError as exc:
    LOGGER.error("Failed to run %s by running 'vsimsa -do' in %s exit code was %i",
                 path, cwd, exc.returncode)
    print("== Output of 'vsimsa -do' " + ("=" * 60))
    print(exc.output)
    print("=======================" + ("=" * 60))
    raise

root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

execute_riviera_pro_command('../script/compile_src.do')

uvvm_util_lib = ui.add_external_library('uvvm_util', join(project_root, 'uvvm_util', 'sim', 'uvvm_util'))

# Add all testbenches to lib
# lib = ui.add_library('lib')
uvvm_util_lib.add_source_files(join(root, '../tb', '*.vhd'))

# Compile and run all test cases
ui.main()
