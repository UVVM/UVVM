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
  editor = MetaDataEditor('util_quick_ref.pdf')
  editor.set_meta_data(title='UVVM Util QuickRef', producer='Bitvis AS', author='Bitvis AS')
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
uvvm_dir = join(root, '..')

# Get command line arguments
ui = VUnit.from_argv()

# UVVM UTIL
uvvm_util_lib = ui.add_library('uvvm_util')
uvvm_util_lib.add_source_files(join(uvvm_dir, 'src', '*.vhd'))

# Add all testbenches to lib
uvvm_util_lib.add_source_files(join(uvvm_dir, 'internal_tb', '*.vhd'))

ui.set_compile_option('modelsim.vcom_flags', ["-suppress", "1346,1236"])

# Compile and run all test cases
ui.main()
