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

def generate_tests(obj, data_widths):
    """
    Generate test by varying the mode and data width generics
    """

    for data_width in product(data_widths):
        # This configuration name is added as a suffix to the test bench name
        config_name = "data_width=%i" % (data_width)

        # Add the configuration with a post check function to verify the output
        obj.add_config(name=config_name,
                       generics=dict(
                       gc_data_width=data_width))

root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(project_root, 'uvvm_util', 'src', '*.vhd'))

uvvm_vvc_framework_lib = ui.add_library('uvvm_vvc_framework')
uvvm_vvc_framework_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src', '*.vhd'))

bitvis_vip_gmii_lib = ui.add_library('bitvis_vip_gmii')
bitvis_vip_gmii_lib.add_source_files(join(project_root, 'bitvis_vip_gmii', 'src', '*.vhd'))
bitvis_vip_gmii_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

bitvis_vip_sbi_lib = ui.add_library('bitvis_vip_sbi')
bitvis_vip_sbi_lib.add_source_files(join(project_root, 'bitvis_vip_sbi', 'src', '*.vhd'))
bitvis_vip_sbi_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

bitvis_vip_scoreboard_lib = ui.add_library('bitvis_vip_scoreboard')
bitvis_vip_scoreboard_lib.add_source_files(join(project_root, 'bitvis_vip_scoreboard', 'src', '*.vhd'))

bitvis_vip_hvvc_to_vvc_bridge = ui.add_library('bitvis_vip_hvvc_to_vvc_bridge')
bitvis_vip_hvvc_to_vvc_bridge.add_source_files(join(project_root, 'bitvis_vip_hvvc_to_vvc_bridge', 'src', '*.vhd'))

bitvis_vip_ethernet_lib = ui.add_library('bitvis_vip_ethernet')
bitvis_vip_ethernet_lib.add_source_files(join(root, '..', 'src', '*.vhd'))
bitvis_vip_ethernet_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))
ethernet_sb_pkg = bitvis_vip_ethernet_lib.get_source_file(join(root, '..', 'src', 'ethernet_sb_pkg.vhd'))
hvvc_methods_pkg = bitvis_vip_ethernet_lib.get_source_file(join(root, '..', 'src', 'hvvc_methods_pkg.vhd'))
hvvc_methods_pkg.add_dependency_on(ethernet_sb_pkg)

XilinxCoreLib_lib = ui.add_library('xilinxcorelib')
XilinxCoreLib_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', 'xilinx', 'XilinxCoreLib', '*.vhd'))

unisim_lib = ui.add_library('unisim')
unisim_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', 'xilinx', 'unisims', '*.vhd'), vhdl_standard='93')
unisim_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', 'xilinx', 'unisims', 'primitive', '*.vhd'), vhdl_standard='93')

mac_master_lib = ui.add_library('mac_master')
mac_master_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', '*.vhd'))
mac_master_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', 'generic', '*.vhd'))
mac_master_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', 'xilinx', 'ipcore_dir', '*.vhd'))
mac_master_lib.add_source_files(join(root, '..', 'internal_tb', 'ethernet_mac-master', 'xilinx', '*.vhd'))

# Add all testbenches to lib
bitvis_vip_ethernet_lib.add_source_files(join(root, '..', 'internal_tb', '*.vhd'))

ethernet_sbi_tb = bitvis_vip_ethernet_lib.entity("ethernet_sbi_tb")
ethernet_sbi_sb_tb = bitvis_vip_ethernet_lib.entity("ethernet_sbi_sb_tb")

# Generate tests for ethernet over sbi with different lengths
#                               data widths
generate_tests(ethernet_sbi_tb, [4, 8, 9, 12, 16]);
generate_tests(ethernet_sbi_sb_tb, [4, 8, 9, 12, 16]);

ui.set_compile_option('rivierapro.vcom_flags', ["-nowarn", "COMP96_0564", "-nowarn", "COMP96_0048", "-dbg"])
ui.set_sim_option("rivierapro.vsim_flags", ["-i", "10000", "-access_leak_report"])

# Compile and run all test cases
ui.main()