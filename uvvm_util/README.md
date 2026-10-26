( [Click here to go to the UVVM overall overview](./../README.md) )

# UVVM Utility Library
The Open Source 'UVVM (Universal VHDL Verification Methodology) - Utility Library', a VHDL testbench infrastructure for making better VHDL testbenches for verification of FPGA.
This library is a part of the overall [UVVM](./../README.md)

## For what do I need this Utility Library?
UVVM Utility Library (previously (pre 2015) Bitvis Utility Library) is a basic VHDL testbench infrastructure that allows a much faster testbench development with a good logging and alert handling mechanism, topped with lots of useful checking procedures - like checking a signal value, stability and change, or waiting for such. It also has lots of support for clock generation, pulse generation, semaphores, string handling and BFM functionality. It even includes both simple and advanced approaches to Randomisation and Functional Coverage. 

## What are the benefits of using this system?
The base functionality of Utility Library is dead easy to use. The extremely low user threshold allows users to be up and running in less than an hour. UVVM is free and open source, and contributions from the community are welcomed (via for instance pull requests).
* The logging procedures can be used directly and simplify the process of reporting progress in a simulation, as well as providing valuable debug information if an error is detected. A flexible verbosity control is available - if you want this.
* The checkers are intelligent so that they give you a mismatch report, and you may select whether you want a positive acknowledge. Alerts may be controlled in many ways - like counting, potentially ignoring and potentially stopping the simulation.


## Prerequisites
UVVM Utility Library is tool and library independent, but it must be compiled with VHDL-2008 or newer.
See the overall [UVVM](./../README.md) documentation for prerequisites, license, maintainers, etc.

## Introduction to Utility Library - including manuals
All documents including powerpoint presentations are available in the *uvvm_util/doc* directory on GitHub.
This is just a fast access link to some interesting info:
- *['Making a simple, structured and efficient VHDL testbench – Step-by-step'*](./../uvvm_util/doc/Simple_TB_step_by_step.pps) - A brief introduction to making good testbenches - mainly independent of language and library, but the UVVM Utility Library as an example
- *['UVVM Utility Library Concepts and usage'*](./../uvvm_util/doc/UVVM_Utility_Library_Concepts_and_Usage.pps)  - Going into more details of the library

A demo of how to make a simple, but structured testbench is given in the [IRQC (simple interrupt controller) example](./../bitvis_irqc).
You can compile the complete DUT, Utility library, required BFMs and the testbench via the provided [scripts](./../bitvis_irqc/script)

Note that a dedicated repository (UVVM_Light)](https://github.com/UVVM/UVVM_Light) has been provided to simplify getting started using Utility Library and BFMs. Here all the code and documentation have been collected in a single directory, and only a single VHDL library is used. The documentation and code are 100% the same as for the full UVVM. This was provided on request to novice VHDL users with little experiemce with VHDL libraries.

## UVVM Maintainers
The UVVM steering group (currently Inventas and EmLogic, Norway) has released UVVM as open source and both EmLogic and Inventas are committed to develop this system further.
We do however appreciate contributions and suggestions from users.

Please use Pull requests for contributions and we will evaluate them for inclusion in our release on the master branch.
