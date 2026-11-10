-----------------------------------------------------------
-- Description
-----------------------------------------------------------

This is NOT an example of how to implement a UART.
This is just a simple test vehicle that can be used to
demonstrate the functionality of the UVVM VVC Framework.

Modelsim compile scripts are part of this release, see
the script folder. For other simulators, the compile order
is provided in scripts/compile_order.txt. See also the
following shell script:
  compile_all_and_simulate.sh  (usage: sh compile_all_and_simulate.sh <ghdl|nvc|vsim|xsim> <target_dir>)

-----------------------------------------------------------
-- Directory structure                                   --
-----------------------------------------------------------

- bitvis_uart     : An example Design Under Test (DUT) delivered with UVVM in order to illustrate usage and debugging support provided by the library.
  - doc           : Documentation
  - script        : UART compile scripts
  - src           : UART source code
  - tb            : UART testbenches and demo
