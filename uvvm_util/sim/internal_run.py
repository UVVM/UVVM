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

root = dirname(__file__)

# Get command line arguments
ui = VUnit.from_argv()

# Create VHDL libraries and add the related project files to these
project_root = join(dirname(__file__), '..', '..')

call_bitvis_sim_script('../script/compile_src.do')

# Since we use encrypted source code we must use add_external_library
# All of these libraries must already be compiled before calling this script
uvvm_util_lib = ui.add_external_library('uvvm_util', join(project_root, 'uvvm_util', 'sim', 'uvvm_util'))

# Add all testbenches to lib
# lib = ui.add_library('lib')
uvvm_util_lib.add_source_files(join(root, '../tb', '*.vhd'))

# Compile and run all test cases
ui.main()
