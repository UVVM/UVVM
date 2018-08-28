# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015, Lars Asplund lars.anders.asplund@gmail.com

# Adapted for Bitvis use by Daniel Blomkvist, 2015

from os.path import join, dirname
import os
import subprocess

# Include PDF_editor and update PDF meta data
import sys
try:
  sys.path.insert(0, '../internal_script/pdf_editor')
  from PdfMetaDataEditor import MetaDataEditor
  editor = MetaDataEditor('sbi_vvc_QuickRef.pdf')
  editor.set_meta_data(title='SBI VVC QuickRef', producer='Bitvis AS', author='Bitvis AS')
  editor = MetaDataEditor('sbi_bfm_QuickRef.pdf')
  editor.set_meta_data(title='SBI BFM QuickRef', producer='Bitvis AS', author='Bitvis AS')
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

root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(project_root, 'uvvm_util', 'src', '*.vhd'))

uvvm_vvc_framework_lib = ui.add_library('uvvm_vvc_framework')
uvvm_vvc_framework_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src', '*.vhd'))

bitvis_vip_sbi_lib = ui.add_library('bitvis_vip_sbi')
bitvis_vip_sbi_lib.add_source_files(join(root, '..', 'src', '*.vhd'))
bitvis_vip_sbi_lib.add_source_files(join(project_root, 'uvvm_vvc_framework', 'src_target_dependent', '*.vhd'))

# Add all testbenches to lib
bitvis_vip_sbi_lib.add_source_files(join(root, '..', 'internal_tb', '*.vhd'))

ui.set_compile_option('modelsim.vcom_flags', ["-suppress", "1346,1236"])

# Compile and run all test cases
ui.main()
