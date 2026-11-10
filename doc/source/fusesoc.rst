##################################################################################################################################
FuseSoC support
##################################################################################################################################

UVVM includes `FuseSoC <https://fusesoc.readthedocs.io>`_ core files for all
sub-libraries. To use UVVM as a dependency in a FuseSoC project, add it as a
library and depend on ``uvvm:uvvm:uvvm`` (the aggregate of all
sub-libraries).

To run UVVM's own demo testbenches with GHDL::

    fusesoc run --target=sim uvvm:uvvm:bitvis_irqc

A ``sim`` target is available for the demo testbenches of ``bitvis_irqc``, ``bitvis_uart``,
``bitvis_vip_error_injection``, ``bitvis_vip_ethernet``, ``bitvis_vip_uart`` and ``uvvm_assertions``. The demo
testbenches of ``bitvis_vip_scoreboard`` and ``uvvm_util`` have no FuseSoC target, since they depend on VIPs that in
turn depend on these libraries, and FuseSoC does not allow circular dependencies between cores. The
``bitvis_vip_spec_cov`` demos have no target either, since they also need the run_spec_cov.py post-processing step.

On Windows:

* The GHDL backend in Edalize needs ``make`` on the ``PATH``, e.g. from MSYS2.
* FuseSoC copies the shared ``td_*`` files to long build paths. If a path exceeds the 260 character limit of Windows,
  FuseSoC fails with ``Could not find EDA API file "None"``. Use a short checkout path or a short build directory, e.g.
  ``fusesoc run --build-root C:/build --target=sim uvvm:uvvm:bitvis_irqc``.

The ``.core`` files are generated from ``compile_order.txt`` and
``VERSION.TXT`` metadata by ``script/generate_fusesoc_cores.py``.
Regenerate after changing either::

    uv run script/generate_fusesoc_cores.py

Tests for the generator::

    python3 script/test_generate_fusesoc_cores.py
