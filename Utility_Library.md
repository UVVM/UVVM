# UVVM Utility Library
The Open Source 'UVVM (Universal VHDL Verification Methodology) - Utility Library', a HVDL testbench infrastructure for making better  VHDL testbenches for verification of FPGA.
UVVM consists currently of 
- Utility Library
- VVC Framework
more to come...

## For what do I need this Utility Library?
UVVM Utility Library (previously Bitvis Utility Library) is a basic VHDL testbench infrastructure that allows a much faster testbench development with a good logging and alert handling mechanism, topped with lots of useful checking procedures - like checking a signal value, stability and change. It also has lots of support for string handling and BFMs, and a simple, but efficient set of functions for random value generation. 

## What are the benefits of using this system?
The Utility Library is dead easy to use. The extremely low user threshold allows users to be up and running in less than an hour.
* The logging procedures can be used directly and simplifies the process of reporting progress in a simulation, as well as providing valuable debug information if en error is detected. A flexible verbosity control is available - if you want this.
* The checkers are intelligent so that they give you a mismatch report, and you may select whether you want a positive acknowledge. Alerts may be controlled in many ways - like counting, potentially ignoring and potentially stopping the simulation.
* BFM suport, string handling and basic randomisation is also available.
[This post on LinkedIn](https://www.linkedin.com/pulse/free-library-good-testbench-checking-functionality-espen-tallaksen?trk=mp-reader-card) will give you some more info on why you should use this library.

## Prerequisites
UVVM Utility Library is tool and library independent, but must be compiled with VHDL 2008.
UVVM has been tested with the following simulators:
- Modelsim version 10.4d
- Riviera-PRO version: 2017.02.99.6498

## Introduction to Utility Library - including manuals
All documents including powerpoint presentations are available in the doc-directory of Utility_Library on GitHub.
This is just a fast access link to some interesting info:
- *['Making a simple, structured and efficient VHDL testbench – Step-by-step'*](https://github.com/UVVM/UVVM_Utility_Library/raw/master/uvvm_util/Simple_TB_step_by_step.pps) - A brief introduction to making good testbenches - mainly independent of language and library, but using Bitvis Utility Library as an example
- *['UVVM Utility Library Concepts and usage'*](https://github.com/UVVM/UVVM_Utility_Library/raw/master/uvvm_util/UVVM_Utility_Library_Concepts_and_Usage.pps)  - Going into more details of the library

## License

The MIT License (MIT) 

Copyright (c) 2016 by Bitvis AS 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

## UVVM Maintainers
[Bitvis](http://bitvis.no) (Norway) has released UVVM as open source and we are committed to develop this system further.
We do however appreciate contributions and suggestions from users.
