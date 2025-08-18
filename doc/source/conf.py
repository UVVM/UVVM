# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'UVVM'
author = 'UVVM'
copyright = '2025 by UVVM steering group. All rights reserved'

# The full version, including alpha/beta/rc tags
def read_uvvm_version(fname):
    with open(os.path.join(os.path.dirname(__file__), fname)) as rf:
        lines = rf.readlines()

    for idx, line in enumerate(lines):
        if line.startswith('v'):
            if '----' in lines[idx+1]:
                return line.strip()

def read_module_version(fname):
    versions = ''
    with open(os.path.join(os.path.dirname(__file__), fname)) as rf:
        lines = rf.readlines()

    for idx, line in enumerate(lines):
        if idx > 0:
            versions += line.strip() + '\n'
    return versions

            
uvvm_version = read_uvvm_version('../../CHANGES.TXT')
module_versions = read_module_version('../../versions.txt')


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

highlight_language = 'VHDL'


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

html_theme_options = {
    'navigation_depth': '5',
    'style_nav_header_background': '#F5F5F5',
    'logo_only': 'True'
}

html_logo = 'images/uvvm.png'


# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['_static']