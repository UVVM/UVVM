##################################################################################################################################
FuseSoC support
##################################################################################################################################

UVVM includes `FuseSoC <https://fusesoc.readthedocs.io>`_ core files for all
sub-libraries. To use UVVM as a dependency in a FuseSoC project, add it as a
library and depend on ``uvvm:uvvm:uvvm`` (the aggregate of all
sub-libraries).

To run UVVM's own demo testbenches with GHDL::

    fusesoc run --target=sim uvvm:uvvm:bitvis_irqc

The ``.core`` files are generated from ``compile_order.txt`` and
``VERSION.TXT`` metadata by ``script/generate_fusesoc_cores.py``.
Regenerate after changing either::

    uv run script/generate_fusesoc_cores.py

Tests for the generator::

    python3 script/test_generate_fusesoc_cores.py
