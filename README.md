# UVVM VVC Framework
The Open Source 'UVVM (Universal VHDL Verification Methodology) - VVC (VHDL Verification Component) Framework' for making structured VHDL testbenches for verification of FPGA.
UVVM consists currently of 
- Utility Library
- VVC Framework
more to come...

## For what do I need this VVC Framework?
The VVC Framework is a VHDL Verification Component system that allows multiple interfaces on a DUT to be stimulated/handled simultaneously in a very structured manner, and controlled by a very simple to understand software like a test sequencer. 
VVC Framework is unique as an open source VHDL approach to building a structured testbench architecture using Verification components and a simple protocol to access these. As an example a simple command like uart_expect(UART_VVCT, my_data), or axilite_write(AXILITE_VVCT, my_addr, my_data, my_message) will automatically tell the respective VVC (for UART or AXI-Lite) to execute the uart_receive() or axilite_write() BFM respectively. 

## What are the benefits of using this system?
The really great benefit here is that these commands may be issued at the same time from the test sequencer - thus allowing full control of when an access is to be performed, and the commands are understandable "even" for a software developer ;-)   The commands may be queued, skewed, delayed, synchronised, etc - and a super-set for applying constrained random or other sequences of data may of of course also be applied.
This yields an excellent control over your testbench and VVCs.
For debugging you can select logging of a command when it is issued from the sequencer, when it is received by the VVC, when it is initiated by the VVC and/or when it has been executed towards the DUT. This allows full overview of all actions in your complete testbench.
[This post on LinkedIn](https://www.linkedin.com/pulse/what-uvvm-espen-tallaksen) will give you some more info on why you should use this library.

## Prerequisites
UVVM is tool and library independent, but must be compiled with VHDL 2008.
UVVM has been tested with the following simulators:
- Modelsim version 10.3d
- Riviera-PRO version: 2015.10.85

Python is required **if** you want to execute the VVC generation scripts

## Introduction to VVC Framework - including manuals
All documents including powerpoint presentations are available in the doc-directory of VVC_Framework on GitHub.
This is just a [fast access link to some interesting info:](http://bitvis.no/resources/uvvm-vvc-framework-download/)
- *'The critically missing VHDL testbench feature - Finally a structured approach'* - A brief introduction
- *'VVC Framework Manual'*  - The user manual

## License

The MIT License (MIT) 

Copyright (c) 2016 by Bitvis AS 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

## UVVM Maintainers
[Bitvis](http://bitvis.no) (Norway) has released UVVM as open source and we are committed to develop this system further.
We do however appreciate contributions and suggestions from users.
