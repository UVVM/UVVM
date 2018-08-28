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

# Include PDF_editor and update PDF meta data
import sys
try:
  sys.path.insert(0, '../internal_script/pdf_editor')
  from PdfMetaDataEditor import MetaDataEditor
  editor = MetaDataEditor('spi_vvc_QuickRef.pdf')
  editor.set_meta_data(title='SPI VVC QuickRef', producer='Bitvis AS', author='Bitvis AS')
  editor = MetaDataEditor('spi_bfm_QuickRef.pdf')
  editor.set_meta_data(title='SPI BFM QuickRef', producer='Bitvis AS', author='Bitvis AS')
  print("Updated PDF meta data")

except ImportError:
  print("Unable to import pdf_editor.")
  print("Clone from ssh://git@stash.bitvis.no/bv_tools/pdf_editor.git")
  print("pdf_editor depends on pyPDF2, see https://pypi.python.org/pypi/PyPDF2")


# Make vunit python module importable. Can be removed if vunit is on you pythonpath
# environment variable
path_to_vunit = join(dirname(__file__), '..', '..', 'vunit')
sys.path.append(path_to_vunit)
#  -------

# --------------
# Set VUNIT_SIMULATOR environment variable
os.environ["VUNIT_SIMULATOR"] = "modelsim"
#------------------------------------------

from vunit import VUnit, VUnitCLI

def call_bitvis_sim_script(path):
  try:
    output = subprocess.call(['vsim', '-c', '-do', 'do ' + path + ';exit'], stderr=subprocess.PIPE)
  except subprocess.CalledProcessError as exc:
    LOGGER.error("Failed to run %s by running 'vsim -c -do' in %s exit code was %i",
                 path, cwd, exc.returncode)
    print("== Output of 'vsim -c -do' " + ("=" * 60))
    print(exc.output)
    print("=======================" + ("=" * 60))
    raise


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

call_bitvis_sim_script('../script/compile_uvvm.do')
call_bitvis_sim_script('../script/compile_src.do')
call_bitvis_sim_script('../internal_script/compile_tb_dep_excl_uvvm.do; quit')

# Since we use encrypted source code we must use add_external_library
# All of these libraries must already be compiled before calling this script
ui.add_external_library('uvvm_util', join(project_root, 'uvvm_util', 'sim', 'uvvm_util'))
ui.add_external_library('uvvm_vvc_framework', join(project_root, 'uvvm_vvc_framework', 'sim', 'uvvm_vvc_framework'))

ui.add_external_library('bitvis_vip_sbi', join(project_root, 'bitvis_vip_sbi', 'sim', 'bitvis_vip_sbi'))
bitvis_vip_spi_lib = ui.add_external_library('bitvis_vip_spi', join(project_root, 'bitvis_vip_spi', 'sim', 'bitvis_vip_spi'))

# Add all testbenches to lib
bitvis_vip_spi_lib.add_source_files(join(root, '../internal_tb', '*.vhd'))

spi_vvc_tb = bitvis_vip_spi_lib.entity("spi_vvc_tb")
# set a generic
# spi_vvc_tb.set_generic("gc_spi_mode", "2");

# Generate tests for SPI mode 0 to 3 with many data widths (8 is min in SPI DUT, 32 is max Data width in VVC by default)
#                            mode,       data width,    data array width
generate_tests(spi_vvc_tb, range(0,4), [8, 14, 23, 32], [2, 4, 6, 8]);

# Compile and run all test cases
ui.main()
