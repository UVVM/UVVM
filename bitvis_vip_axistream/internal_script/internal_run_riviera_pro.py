# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015, Lars Asplund lars.anders.asplund@gmail.com

# Adapted for Bitvis use by Daniel Blomkvist, 2015

from os.path import join, dirname
from itertools import product
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

def generate_tests(obj, data_widths, user_widths, id_widths, dest_widths):
    """
    Generate test by varying the user/id/dest width generics
    """

    for data_width, user_width, id_width, dest_width in product(data_widths, user_widths, id_widths, dest_widths):
        # This configuration name is added as a suffix to the test bench name
        config_name = "data_width=%i,user_width=%i,id_width=%i,dest_width=%i" % (data_width, user_width, id_width, dest_width)

        # Add the configuration with a post check function to verify the output
        obj.add_config(name=config_name,
                       generics=dict(
                         gc_data_width=data_width,
                         gc_user_width=user_width,
                         gc_id_width=id_width,
                         gc_dest_width=dest_width))

# Same as above, but set gc_include_tuser = false
def generate_tests_no_tuser(obj, data_widths, user_widths):
    """
    Generate test with gc_include_tuser=false
    """

    for data_width, user_width in product(data_widths, user_widths):
        # This configuration name is added as a suffix to the test bench name
        config_name = "data_width=%i,user_width=%i,include_tuser=false" % (data_width, user_width)

        # Add the configuration with a post check function to verify the output
        obj.add_config(name=config_name,
                       generics=dict(
                         gc_data_width=data_width,
                         gc_user_width=user_width,
                         gc_include_tuser="false"
                         ))

# Test case  multiple_vvc
def generate_tests_multiple_vvc(obj, data_widths, user_widths):
    """
    Generate test with multiple VVCs for testing await_any_completion()
    """

    for data_width, user_width in product(data_widths, user_widths):
        # This configuration name is added as a suffix to the test bench name
        config_name = "data_width=%i,user_width=%i,include_tuser=false" % (data_width, user_width)

        # Add the configuration with a post check function to verify the output
        obj.add_config(name=config_name,
                       generics=dict(
                         gc_data_width=data_width,
                         gc_user_width=user_width,
                         gc_include_tuser="false"
                         ))
root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(project_root, 'uvvm_util', 'src', '*.vhd'))

uvvm_vvc_framework_lib = ui.add_library('uvvm_vvc_framework')
uvvm_vvc_framework_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src', '*.vhd'))

bitvis_vip_axistream_lib = ui.add_library('bitvis_vip_axistream')
bitvis_vip_axistream_lib.add_source_files(join(root, '..', 'src', '*.vhd'))
bitvis_vip_axistream_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

# Add all testbenches to lib
bitvis_vip_axistream_lib.add_source_files(join(root, '..', 'internal_tb', '*.vhd'))

ui.set_compile_option('rivierapro.vcom_flags', ["-nowarn", "COMP96_0564", "-nowarn", "COMP96_0048", "-dbg"])

# Run axistream t_slv_array BFM test - set generics : Generate tests for various data widths / tuser widths
axistream_bfm_slv_array_tb = bitvis_vip_axistream_lib.entity("axistream_bfm_slv_array_tb")
generate_tests(axistream_bfm_slv_array_tb, [32], [8], [7], [4]);

# Run axistream t_slv_array VVC test - set generics : Generate tests for various data widths / tuser widths
axistream_vvc_slv_array_tb = bitvis_vip_axistream_lib.entity("axistream_vvc_slv_array_tb")
generate_tests(axistream_vvc_slv_array_tb, [32], [8], [7], [4]);

# Run axistream t_byte_array BFM test - set generics : Generate tests for various data widths / tuser widths
axistream_simple_tb = bitvis_vip_axistream_lib.entity("axistream_simple_tb")
generate_tests(axistream_simple_tb, [32], [8], [7], [4]);

# Run axistream t_byte_array VVC test - set generics : Generate tests for various data widths / tuser widths
axistream_vvc_simple_tb = bitvis_vip_axistream_lib.entity("axistream_vvc_simple_tb")
generate_tests(axistream_vvc_simple_tb, [8, 16, 24, 64, 128], [8], [8], [4]);
generate_tests(axistream_vvc_simple_tb, [32], [1, 5], [3], [1]);

# Run axistream t_byte_array VVC test - when tuser is not provided by DUT
generate_tests_no_tuser(axistream_vvc_simple_tb, [32], [1]);

# Run axistream t_byte_array VVC test - testing await_any_completion
axistream_multiple_vvc_tb = bitvis_vip_axistream_lib.entity("axistream_multiple_vvc_tb")
generate_tests_multiple_vvc(axistream_multiple_vvc_tb, [32], [1]);

# Compile and run all test cases
ui.main()
