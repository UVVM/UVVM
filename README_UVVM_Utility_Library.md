( [Click here to go to the UVVM overall overview](https://github.com/UVVM/UVVM/blob/master/README.md) )

# UVVM Utility Library
The Open Source 'UVVM (Universal VHDL Verification Methodology) - Utility Library', a VHDL testbench infrastructure for making better  VHDL testbenches for verification of FPGA.
This library is a part of the overall [UVVM](https://github.com/UVVM/UVVM/raw/master/README.md)

## For what do I need this Utility Library?
UVVM Utility Library (previously Bitvis Utility Library) is a basic VHDL testbench infrastructure that allows a much faster testbench development with a good logging and alert handling mechanism, topped with lots of useful checking procedures - like checking a signal value, stability and change. It also has lots of support for string handling and BFMs, and a simple, but efficient set of functions for random value generation. 

## What are the benefits of using this system?
The Utility Library is dead easy to use. The extremely low user threshold allows users to be up and running in less than an hour. UVVM is free and open source, and contributions from the community is welcomed (via for instance pull requests).
* The logging procedures can be used directly and simplifies the process of reporting progress in a simulation, as well as providing valuable debug information if en error is detected. A flexible verbosity control is available - if you want this.
* The checkers are intelligent so that they give you a mismatch report, and you may select whether you want a positive acknowledge. Alerts may be controlled in many ways - like counting, potentially ignoring and potentially stopping the simulation.
* BFM suport, string handling and basic randomisation is also available.
[This post on LinkedIn](https://www.linkedin.com/pulse/free-library-good-testbench-checking-functionality-espen-tallaksen?trk=mp-reader-card) will give you some more info on why you should use this library.

## Prerequisites
UVVM Utility Library is tool and library independent, but must be compiled with VHDL 2008.
See the overall [UVVM](https://github.com/UVVM/UVVM/raw/master/README.md) documentation for prerequisites, license, maintainers, etc.

## Introduction to Utility Library - including manuals
All documents including powerpoint presentations are available in the doc-directory of Utility_Library on GitHub.
This is just a fast access link to some interesting info:
- *['Making a simple, structured and efficient VHDL testbench – Step-by-step'*](https://github.com/UVVM/UVVM/raw/master/uvvm_util/Simple_TB_step_by_step.pps) - A brief introduction to making good testbenches - mainly independent of language and library, but using Bitvis Utility Library as an example
- *['UVVM Utility Library Concepts and usage'*](https://github.com/UVVM/UVVM/raw/master/uvvm_util/UVVM_Utility_Library_Concepts_and_Usage.pps)  - Going into more details of the library
A demo of how to make a simple, but structured testbench is given in the [IRQC (simple interrupt controller) example](https://github.com/UVVM/UVVM/tree/master/bitvis_irqc).  
You can compile the complete DUT, Utility library, required BFMs and the testbench via the provided [scripts](https://github.com/UVVM/UVVM/tree/master/bitvis_irqc/script)


Please use the pull_requests branch for contributions and we will evaluate them for inclusion in our release on the master branch and handle any required verification and documentation.
