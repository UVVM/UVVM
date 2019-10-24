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
import sys

# Make vunit python module importable. Can be removed if vunit is on you pythonpath
# environment variable
path_to_vunit = join(dirname(__file__), '..', '..', 'vunit')
sys.path.append(path_to_vunit)
#  -------

# --------------
# Set VUNIT_SIMULATOR environment variable
os.environ["VUNIT_SIMULATOR"] = "rivierapro"
#------------------------------------------

from vunit import VUnit, VUnitCLI

def generate_tests(obj, spi_modes, data_widths, data_array_widths):
    """
    Generate test by varying the mode and data width generics
    """

    for data_array_width, data_width, spi_mode in product(data_array_widths, data_widths, spi_modes):
        # This configuration name is added as a suffix to the test bench name
        config_name = "data_width=%i,data_array_width=%i,spi_mode=%i" % (data_width, data_array_width, spi_mode)

        # Add the configuration with a post check function to verify the output
        obj.add_config(name=config_name,
                       generics=dict(
                         gc_data_width=data_width,
                         gc_spi_mode=spi_mode,
                         gc_data_array_width=data_array_width))

root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(project_root, 'uvvm_util', 'src', '*.vhd'))

uvvm_vvc_framework_lib = ui.add_library('uvvm_vvc_framework')
uvvm_vvc_framework_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src', '*.vhd'))

bitvis_vip_scoreboard_lib = ui.add_library('bitvis_vip_scoreboard')
bitvis_vip_scoreboard_lib.add_source_files(join(project_root, 'bitvis_vip_scoreboard', 'src', '*.vhd'))

bitvis_vip_sbi_lib = ui.add_library("bitvis_vip_sbi")
bitvis_vip_sbi_lib.add_source_files(join(project_root, 'bitvis_vip_sbi', 'src', '*.vhd'))
bitvis_vip_sbi_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

bitvis_vip_spi_lib = ui.add_library("bitvis_vip_spi")
bitvis_vip_spi_lib.add_source_files(join(root, '..', 'src', '*.vhd'))
bitvis_vip_spi_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

# Add all testbenches to lib
bitvis_vip_spi_lib.add_source_files(join(root, '..', 'internal_tb', '*.vhd'))
bitvis_vip_spi_lib.add_source_file(join(root, '..', 'internal_tb', 'spi_master_slave_opencores','trunk','rtl','spi_master_slave','spi_common_pkg.vhd'))
bitvis_vip_spi_lib.add_source_file(join(root, '..', 'internal_tb', 'spi_master_slave_opencores','trunk','rtl','spi_master_slave','spi_master.vhd'))
bitvis_vip_spi_lib.add_source_file(join(root, '..', 'internal_tb', 'spi_master_slave_opencores','trunk','rtl','spi_master_slave','spi_slave.vhd'))

spi_vvc_tb = bitvis_vip_spi_lib.entity("spi_vvc_tb")

ui.set_compile_option('rivierapro.vcom_flags', ["-nowarn", "COMP96_0564", "-nowarn", "COMP96_0048", "-dbg"])

# set a generic
# spi_vvc_tb.set_generic("gc_spi_mode", "2");

# Generate tests for SPI mode 0 to 3 with many data widths (8 is min in SPI DUT, 32 is max Data width in VVC by default)
#                            mode,       data width,    data array width
generate_tests(spi_vvc_tb, range(0,4), [8, 14, 23, 32], [2, 4, 6, 8]);

# Compile and run all test cases
ui.main()