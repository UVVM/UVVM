#!/usr/bin/env python3
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "pyyaml",
# ]
# ///
"""Generate FuseSoC CAPI2 .core files for UVVM from existing metadata.

Sources of truth:
  - script/component_list.txt       : ordered list of UVVM sub-libraries
  - <lib>/VERSION.TXT               : version string
  - <lib>/script/compile_order.txt  : file list (ordered) + library name

For each sub-library, VHDL source files are scanned for `library X;`
statements to discover dependencies on other UVVM libraries.

Target-dependent (td_) files from uvvm_vvc_framework/src_target_dependent/
are referenced via FuseSoC's `copyto` file property, which copies them
into each VIP's work directory at build time. This avoids committing
duplicate copies while keeping per-VIP .core files self-contained.

Output:
  - <lib>/<lib>.core   : one core file per sub-library
  - uvvm.core          : aggregate core depending on all sub-libraries
  - fusesoc.conf       : project file declaring UVVM as a local library

Usage:
    uv run script/generate_fusesoc_cores.py
    uv run script/generate_fusesoc_cores.py --uvvm-root /path/to/uvvm

    # Or with plain python if pyyaml is installed:
    python3 script/generate_fusesoc_cores.py
"""

import argparse
import re
import sys
from pathlib import Path

import yaml


def parse_version(path):
    """Read VERSION.TXT and return a clean version string."""
    text = path.read_text().strip()
    text = re.sub(r'^v', '', text)
    text = re.sub(r'\s+BETA$', '', text)
    return text


def parse_compile_order(path):
    """Parse compile_order.txt -> (logical_name, [file_paths]).

    File paths are relative to the script/ directory of the component.
    """
    logical_name = None
    files = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith('#'):
            m = re.match(r'#\s*library\s+(\S+)', line)
            if m:
                logical_name = m.group(1)
            continue
        files.append(line)
    return logical_name, files


def to_core_path(script_relative):
    """Convert a path relative to script/ to a .core file path entry.

    compile_order.txt paths are relative to <lib>/script/.
    .core file paths are relative to <lib>/.

    Paths into uvvm_vvc_framework/src_target_dependent/ are emitted as
    copyto entries so FuseSoC copies them into the work directory at
    build time, avoiding committed duplicates.

    Returns a string for regular files, or a dict for copyto entries.

    Examples:
      ../src/foo.vhd                                    -> ./src/foo.vhd
      ../../uvvm_vvc_framework/src_target_dependent/x   -> {../uvvm_vvc_framework/src_target_dependent/x: {copyto: src/x}}
    """
    if 'src_target_dependent/' in script_relative:
        source = script_relative[3:]  # strip one ../ -> core-relative
        filename = Path(script_relative).name
        return {source: {'copyto': f'src/{filename}'}}
    if not script_relative.startswith('../'):
        return './' + script_relative
    stripped = script_relative[3:]
    if stripped.startswith('..'):
        raise ValueError(f'Path escapes core directory: {script_relative}')
    return './' + stripped


def find_library_deps(vhd_path):
    """Return set of lowercase library names referenced in a .vhd file.

    Handles both single-library statements (`library ieee;`) and
    comma-separated ones (`library std, ieee;`).
    """
    deps = set()
    text = vhd_path.read_text(errors='replace')
    for m in re.finditer(r'^\s*library\s+([\w,\s]+);', text, re.MULTILINE):
        for name in m.group(1).split(','):
            name = name.strip()
            if name:
                deps.add(name.lower())
    return deps


def dump_core(core_dict):
    """Serialize a core dict to .core file content with CAPI=2 header."""
    yaml_body = yaml.dump(core_dict, default_flow_style=False, sort_keys=False)
    return f'CAPI=2:\n{yaml_body}'


def generate_fusesoc_conf_content():
    """Build the fusesoc.conf content.

    A single library entry pointing at the UVVM root causes FuseSoC to
    recursively scan and discover all .core files. This is preferable to
    one entry per component because it needs no maintenance when
    components are added or removed.
    """
    return (
        '[library.uvvm]\n'
        'location = .\n'
        'sync-type = local\n'
    )


def build_core_dict(comp_name, version, logical_name, files, deps):
    """Build the dict structure for a per-component .core file."""
    fileset = {
        'files': [to_core_path(f) for f in files],
        'file_type': 'vhdlSource-2008',
        'logical_name': logical_name,
    }
    if deps:
        fileset['depend'] = sorted(deps)

    return {
        'name': f'uvvm:uvvm:{comp_name}:{version}',
        'filesets': {
            'rtl': fileset,
        },
        'targets': {
            'default': {
                'filesets': ['rtl'],
            },
        },
    }


def build_aggregate_dict(version, all_vlnvs):
    """Build the dict structure for the aggregate uvvm.core file."""
    return {
        'name': f'uvvm:uvvm:uvvm:{version}',
        'filesets': {
            'deps': {
                'depend': all_vlnvs,
            },
        },
        'targets': {
            'default': {
                'filesets': ['deps'],
            },
        },
    }


def main():
    parser = argparse.ArgumentParser(
        description='Generate FuseSoC .core files for UVVM',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        '--uvvm-root',
        default=None,
        help='Path to UVVM root (default: script parent directory)',
    )
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    uvvm_root = (Path(args.uvvm_root) if args.uvvm_root else script_dir.parent).resolve()

    component_list = uvvm_root / 'script' / 'component_list.txt'
    if not component_list.exists():
        print(f'ERROR: {component_list} not found', file=sys.stderr)
        sys.exit(1)

    components = [
        line.strip() for line in component_list.read_text().splitlines() if line.strip()
    ]

    # Build library_name -> VLNV mapping
    vlnv_map = {}
    versions = {}
    for comp in components:
        v = parse_version(uvvm_root / comp / 'VERSION.TXT')
        versions[comp] = v
        vlnv_map[comp.lower()] = f'uvvm:uvvm:{comp}:{v}'

    # Generate per-component .core files
    all_vlnvs = []
    for comp in components:
        co_path = uvvm_root / comp / 'script' / 'compile_order.txt'
        if not co_path.exists():
            print(f'  SKIP {comp} (no compile_order.txt)')
            continue

        logical_name, files = parse_compile_order(co_path)
        if not logical_name:
            print(f'  WARNING: no library name in {co_path}', file=sys.stderr)
            continue

        # Scan .vhd files for library dependencies
        deps = set()
        for f in files:
            vhd_path = (uvvm_root / comp / 'script' / f).resolve()
            if vhd_path.suffix == '.vhd' and vhd_path.exists():
                deps.update(find_library_deps(vhd_path))

        # Filter to UVVM libraries, excluding self
        uvvm_deps = {
            vlnv_map[d] for d in deps if d in vlnv_map and d != logical_name.lower()
        }

        vlnv = f'uvvm:uvvm:{comp}:{versions[comp]}'
        all_vlnvs.append(vlnv)

        core_dict = build_core_dict(comp, versions[comp], logical_name, files, uvvm_deps)
        core_path = uvvm_root / comp / f'{comp}.core'
        core_path.write_text(dump_core(core_dict))
        print(f'  Wrote {core_path.relative_to(uvvm_root)}')

    # Generate aggregate uvvm.core (uses uvvm_util version as the UVVM release version)
    aggregate_version = versions['uvvm_util']
    agg_dict = build_aggregate_dict(aggregate_version, all_vlnvs)
    aggregate_path = uvvm_root / 'uvvm.core'
    aggregate_path.write_text(dump_core(agg_dict))
    print(f'  Wrote {aggregate_path.relative_to(uvvm_root)}')

    # Generate fusesoc.conf at the UVVM root
    conf_path = uvvm_root / 'fusesoc.conf'
    conf_path.write_text(generate_fusesoc_conf_content())
    print(f'  Wrote {conf_path.relative_to(uvvm_root)}')

    print(f'\nDone. Generated {len(all_vlnvs) + 1} core files + fusesoc.conf.')


if __name__ == '__main__':
    main()
