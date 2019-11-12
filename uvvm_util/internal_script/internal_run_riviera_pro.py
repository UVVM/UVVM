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

root = dirname(__file__)
uvvm_dir = join(root, '..')

# Get command line arguments
ui = VUnit.from_argv()

# UVVM UTIL
uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(uvvm_dir, 'src', '*.vhd'))

# Add all testbenches to lib
uvvm_util_lib.add_source_files(join(uvvm_dir, 'internal_tb', '*.vhd'))

ui.set_compile_option('rivierapro.vcom_flags', ["-nowarn", "COMP96_0564", "-nowarn", "COMP96_0048", "-dbg"])

# Compile and run all test cases
ui.main()
