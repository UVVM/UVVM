-----------------------------------------------------------
-- Description
-----------------------------------------------------------

This is NOT an example of how to implement a UART. 
This is just a simple test vehicle that can be used to 
demonstrate the functionality of the UVVM VVC Framework.

Modelsim compile scripts are part of this release, see
the script folder. For other simulators, see compile order
in sim/compile_order.txt.

-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

- bitvis_uart     : An example Design Under Test (DUT) delivered with UVVM in order to illustrate usage and debugging support provided by the library.
  - doc           : Documentation
  - script        : UART compile scripts
  - sim           : Simulation directory with a Modelsim project file. Simulation log files will be generated in this directory during simulation.  
  - src           : UART source code
  - tb            : UART Test bench

