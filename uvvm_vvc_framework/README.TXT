-----------------------------------------------------------
-- Directory structure                                   -- 
-----------------------------------------------------------

- uvvm_vvc_framework        : UVVM VVC Framework
  - doc                     : UVVM Documentation
  - script                  : Compile scripts for UVVM VVC Framework. Also contains a
                              VVC Generator script and a VVC Name Modifier script.
  - sim                     : Simulation directory with a Modelsim project file. Simulation log 
                              files will be generated in this directory during simulation.  
  - demo                    : Demo directory with a list of test benches that can be run to 
                              demonstrate UVVM VVC Framework.
  - src                     : Source code for the target independent part of UVVM VVC Framework
  - src_target_dependent    : Source code for the target dependent part of UVVM VVC Framework.
                              These are files to be compiled into each VVC library
