#!/usr/bin/env python3
"""Unit tests for generate_fusesoc_cores.py.

Run with:
    python3 script/test_generate_fusesoc_cores.py
"""

import os
import subprocess
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


def write_temp(content, suffix):
    """Write content to a temp file, returning its Path. Auto-cleans up."""
    f = tempfile.NamedTemporaryFile(mode='w', suffix=suffix, delete=False)
    f.write(content)
    f.flush()
    f.close()
    return Path(f.name)


class TestParseVersion(unittest.TestCase):
    def setUp(self):
        self._files = []

    def _write(self, content):
        p = write_temp(content, '.txt')
        self._files.append(p)
        return p

    def tearDown(self):
        for p in self._files:
            p.unlink(missing_ok=True)

    def test_plain(self):
        self.assertEqual(parse_version(self._write('1.2.3')), '1.2.3')

    def test_v_prefix(self):
        self.assertEqual(parse_version(self._write('v2.21.4')), '2.21.4')

    def test_beta_suffix(self):
        self.assertEqual(parse_version(self._write('v0.1.1 BETA')), '0.1.1')


class TestParseCompileOrder(unittest.TestCase):
    def setUp(self):
        self._files = []

    def _write(self, content):
        p = write_temp(content, '.txt')
        self._files.append(p)
        return p

    def tearDown(self):
        for p in self._files:
            p.unlink(missing_ok=True)

    def test_basic(self):
        name, files, toplevel = parse_compile_order(self._write(
            '# library bitvis_irqc\n'
            '../src/irqc_pif_pkg.vhd\n'
            '../src/irqc.vhd\n'
        ))
        self.assertEqual(name, 'bitvis_irqc')
        self.assertEqual(files, ['../src/irqc_pif_pkg.vhd', '../src/irqc.vhd'])
        self.assertIsNone(toplevel)

    def test_with_toplevel(self):
        name, files, toplevel = parse_compile_order(self._write(
            '# library bitvis_irqc\n'
            '# toplevel: irqc_demo_tb\n'
            '../tb/irqc_demo_tb.vhd\n'
        ))
        self.assertEqual(toplevel, 'irqc_demo_tb')


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
    def setUp(self):
        self._files = []

    def _write(self, content):
        p = write_temp(content, '.vhd')
        self._files.append(p)
        return p

    def tearDown(self):
        for p in self._files:
            p.unlink(missing_ok=True)

    def test_single_library(self):
        deps = find_library_deps(self._write('library ieee;\nlibrary uvvm_util;\n'))
        self.assertEqual(deps, {'ieee', 'uvvm_util'})

    def test_comma_separated(self):
        deps = find_library_deps(self._write(
            'library std, ieee;\nlibrary uvvm_util, uvvm_vvc_framework;\n'
        ))
        self.assertEqual(deps, {'std', 'ieee', 'uvvm_util', 'uvvm_vvc_framework'})

    def test_case_insensitive(self):
        deps = find_library_deps(self._write('LIBRARY IEEE;\nLibrary Uvvm_Util;\n'))
        self.assertEqual(deps, {'ieee', 'uvvm_util'})

    def test_ignores_comments(self):
        deps = find_library_deps(self._write('-- library ieee;\nlibrary uvvm_util;\n'))
        self.assertEqual(deps, {'uvvm_util'})


class TestIdempotency(unittest.TestCase):
    """Verify that running the generator reproduces the checked-in files."""

    def test_generator_matches_checked_in_files(self):
        script_dir = Path(__file__).resolve().parent
        uvvm_root = script_dir.parent

        # Collect all .core files and fusesoc.conf (skip build/ and .git/)
        files = [
            f for f in uvvm_root.rglob('*')
            if '.git' not in f.parts and 'build' not in f.parts
            and (f.suffix == '.core' or f.name == 'fusesoc.conf')
        ]
        originals = {f: f.read_bytes() for f in files}

        try:
            result = subprocess.run(
                [sys.executable, str(script_dir / 'generate_fusesoc_cores.py')],
                capture_output=True, text=True, cwd=uvvm_root,
            )
            if result.returncode != 0:
                self.fail(f'Generator failed: {result.stderr}')

            for f, original in originals.items():
                if f.read_bytes() != original:
                    self.fail(
                        f'{f.relative_to(uvvm_root)} would change. '
                        f'Run: uv run script/generate_fusesoc_cores.py'
                    )
        finally:
            for f, content in originals.items():
                f.write_bytes(content)


if __name__ == '__main__':
    unittest.main()
