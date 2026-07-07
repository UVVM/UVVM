#!/usr/bin/env python3
"""Unit tests for generate_fusesoc_cores.py pure functions.

Run with:
    python3 script/test_generate_fusesoc_cores.py
"""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_fusesoc_cores import (
    find_library_deps,
    parse_compile_order,
    parse_version,
    to_core_path,
)


class TestParseVersion(unittest.TestCase):
    def test_plain(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write('1.2.3')
            f.flush()
            self.assertEqual(parse_version(Path(f.name)), '1.2.3')

    def test_v_prefix(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write('v2.21.4')
            f.flush()
            self.assertEqual(parse_version(Path(f.name)), '2.21.4')

    def test_beta_suffix(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write('v0.1.1 BETA')
            f.flush()
            self.assertEqual(parse_version(Path(f.name)), '0.1.1')


class TestParseCompileOrder(unittest.TestCase):
    def test_basic(self):
        content = (
            '# library bitvis_irqc\n'
            '../src/irqc_pif_pkg.vhd\n'
            '../src/irqc.vhd\n'
        )
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(content)
            f.flush()
            name, files = parse_compile_order(Path(f.name))
        self.assertEqual(name, 'bitvis_irqc')
        self.assertEqual(files, ['../src/irqc_pif_pkg.vhd', '../src/irqc.vhd'])


class TestToCorePath(unittest.TestCase):
    def test_src_path(self):
        self.assertEqual(to_core_path('../src/foo.vhd'), './src/foo.vhd')

    def test_tb_path(self):
        self.assertEqual(to_core_path('../tb/foo.vhd'), './tb/foo.vhd')

    def test_bare_path(self):
        self.assertEqual(to_core_path('foo.vhd'), './foo.vhd')

    def test_td_path_emits_copyto(self):
        result = to_core_path(
            '../../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd'
        )
        self.assertEqual(result, {
            '../uvvm_vvc_framework/src_target_dependent/td_queue_pkg.vhd':
                {'copyto': 'src/td_queue_pkg.vhd'}
        })

    def test_escaping_path_raises(self):
        with self.assertRaises(ValueError):
            to_core_path('../../../etc/passwd')


class TestFindLibraryDeps(unittest.TestCase):
    def test_single_library(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.vhd', delete=False) as f:
            f.write('library ieee;\nlibrary uvvm_util;\n')
            f.flush()
            deps = find_library_deps(Path(f.name))
        self.assertEqual(deps, {'ieee', 'uvvm_util'})

    def test_comma_separated(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.vhd', delete=False) as f:
            f.write('library std, ieee;\nlibrary uvvm_util, uvvm_vvc_framework;\n')
            f.flush()
            deps = find_library_deps(Path(f.name))
        self.assertEqual(deps, {'std', 'ieee', 'uvvm_util', 'uvvm_vvc_framework'})

    def test_ignores_comments(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.vhd', delete=False) as f:
            f.write('-- library ieee;\nlibrary uvvm_util;\n')
            f.flush()
            deps = find_library_deps(Path(f.name))
        self.assertEqual(deps, {'uvvm_util'})


if __name__ == '__main__':
    unittest.main()
