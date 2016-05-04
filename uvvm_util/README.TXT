-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

- uvvm_util     : UVVM Utility Library
  - doc           : Quick Reference
  - script        : Compile scripts for UVVM Utility Library
  - sim           : Simulation directory with a Modelsim project file. Simulation log files will be generated in this directory during simulation.
  - src           : Source code for the UVVM Utility Library
  - demo          : Demo directory with a list of test benches that can be run to demonstrate UVVM Utility Library.

-----------------------------------------------------------
-- Transition from BVUL to UVVM-Util                     -- 
-----------------------------------------------------------

The Bitvis Utility Library (BVUL) was discontinued as of version 2.6.0 (except for bug fixes).
For users of BVUL who wish to start using UVVM-Util, the transition should be quite simple.
The key difference between the two is that UVVM-Util only supports VHDL 2008. Therefore, the
library needs to be compiled with VHDL 2008. In addition, the VHDL 2008 feature context is now
supported in UVVM-Util, so the user can simply include the context instead of each of the library
by replacing all the library includes with:
library uvvm_util;
context uvvm_util.uvvm_util_context;

All procedures and functions in the current UVVM-Util version 1.3.0 is backwards compatible with 
BVUL VHDL 2008 source version 2.6.0.

