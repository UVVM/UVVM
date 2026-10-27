-----------------------------------------------------------
-- Description
-----------------------------------------------------------

Modelsim compile scripts are part of this release, see
the script folder. For other simulators, the compile order
is provided in scripts/compile_order.txt. See also the
following shell script:
  compile_all_and_simulate.sh  (usage: sh compile_all_and_simulate.sh <ghdl|nvc|vsim|xsim> <target_dir>)

-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- bitvis_irqc     : An example Design Under Test (DUT) delivered with UVVM Utility Library in order to illustrate usage and debugging support provided by the library.
  - doc           : Documentation
  - script        : IRQC compile scripts
  - src           : IRQC source code
  - tb            : IRQC testbenches and demo
