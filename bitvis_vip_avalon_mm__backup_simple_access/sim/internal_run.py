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
os.environ["VUNIT_SIMULATOR"] = "modelsim"
#------------------------------------------

from vunit import VUnit, VUnitCLI
    
root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(project_root, 'uvvm_util', 'src', '*.vhd'))

uvvm_vvc_framework_lib = ui.add_library('uvvm_vvc_framework')
uvvm_vvc_framework_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src', '*.vhd'))

bitvis_vip_avalon_mm_lib = ui.add_library('bitvis_vip_avalon_mm')
bitvis_vip_avalon_mm_lib.add_source_files(join(project_root, 'bitvis_vip_avalon_mm__backup_simple_access', 'src', '*.vhd'))
bitvis_vip_avalon_mm_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

# Add all testbenches to lib
bitvis_vip_avalon_mm_lib.add_source_files(join(root, '../internal_tb', '*.vhd'))

# GHDL options
ui.set_sim_option("ghdl_flags", ["-frelaxed-rules"])
ui.set_compile_option("ghdl_flags", ["-frelaxed-rules", "-v", "--no-vital-checks","--std=08"])


# Compile and run all test cases
ui.main()
