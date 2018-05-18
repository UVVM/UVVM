# UVVM 
UVVM (Universal VHDL Verification Methodology) is a free and Open Source Methodology and Library for making very structured VHDL-based testbenches.

Overview, Readability, Maintainability, Extensibility and Reuse are all vital for FPGA development efficiency and quality. 
UVVM VVC (VHDL Verification Component) Framework was released in 2016 to handle exactly these aspects.

UVVM consists currently of the following elements 
- [Utility Library](https://github.com/UVVM/UVVM/blob/master/README_UVVM_Utility_Library.md)
- [VVC (VHDL Verification Component) Framework](https://github.com/UVVM/UVVM/blob/master/README_UVVM_VVC_System.md)  - Including Utility Library
- BFMs (Bus Functional Models) to be used with any part of UVVM (See below for currently supported interfaces from Bitvis)
- VVCs to be used with UVVM VVC Framework and may be combined with BFMs (see overview below)
more to come...

## For starters
Please note that UVVM has two different complexity levels. The VVC Framework and VVCs for medium to advanced testbenches, and the Utility library and BFMs for simple usage - and as a basis for more advanced testbenches.
Novice users are strongly recommended to first use UVVM Utility library and BFMs. This has a *very* low user threshold and you will be up and running in an hour. Please see [Utility Library](https://github.com/UVVM/UVVM/blob/master/README_UVVM_Utility_Library.md) for an introduction.
The VVC system is slightly more complex, but has been simplified as far as possible to allow efficient development of good quality testbenhces.

Please also see Getting Started with UVVM: https://github.com/UVVM/UVVM/blob/master/GETTING_STARTED.md

## For what do I need this VVC Framework?
UVVM is a verification component system that allows the implementation of a very structured testbench architecture to handle any verification complexity - from really simple to really complex. A key benefit of this system is the very simple software-like VHDL test sequencer that may control your complete testbench architecture with any number of verification components. This takes overview, readability and maintainability to a new level. 
As an example a simple command like uart_expect(UART_VVCT, my_data), or axilite_write(AXILITE_VVCT, my_addr, my_data, my_message) will automatically tell the respective VVC (for UART or AXI-Lite) to execute the uart_receive() or axilite_write() BFM respectively. 

## What are the main benefits of using this system?
The really great benefit here is the unique overview, readability, maintainability, extensibility and reuse you get from having the best testbench architecture possible - much in the same way as a good architecure is also critical for any complex design.
Another major benefit here is that any number of commands may be issued at the same time from the test sequencer - thus allowing full control of when an access is to be performed, and the commands are understandable "even" for a software developer ;-)   The commands may be queued, skewed, delayed, synchronised, etc - and a super-set for applying constrained random or other sequences of data may of of course also be applied.
This yields an excellent control over your testbench and VVCs.

For debugging you can select logging of a command when it is issued from the sequencer, when it is received by the VVC, when it is initiated by the VVC and/or when it has been executed towards the DUT. This allows full overview of all actions in your complete testbench.

UVVM is free and open source and has standardised the way to build good testbench architectures and VVCs so that reuse is dead simple, and allows the FPGA community to share VVCs that will work together in a well structured test harness.

You may of course combine UVVM with any other legacy or 3rd party testbenches or verification models.
[This post on LinkedIn](https://www.linkedin.com/pulse/what-uvvm-espen-tallaksen) will give you some more info on why you should use this library.

## Main Features
*	Very usefull support for checking values, ranges, time aspects, and for waiting for events inside a given window
*	An extremely low user threshold for the basic functionality - like logging, alert handling and checkers
*	A very structured testbench architecture that allows LEGO-like testbench/harness implementation
*	A very structured VHDL Verification Component (VVC) architecture that allows simultaneous activitity (stimuli and checking) on multiple interfaces in a very easily understandable manner
*	An easily understandable command syntax to control a complete testbench with multiple VVCs
*	The structure and overview is easily kept even for a testbench with a large number of VVCs
*	A VVC architecture that is almost exactly the same from one VVC to another - sometimes with only the BFM calls as the differentiator, thus allowing an extremely efficient reuse from one VVC to another
*	A VVC architecture that easily allows multiple threads for e.g. simultaneous Avalon Command and Response
*	A VVC architecture that allows simple encapsulation for ALL verification functionality for any given interface or protocol
*	Allows VVCs to be included anywhere in the test harness - or even inside the design it self
*	A logging and alert system that supports full verbosity control of functionality and hierarchy
*	A logging system that lets you easily see how your commands propagate from your central test sequencer to your VVCs - through the execution queue - until it is executed and completed towards the DUT
*	Allows 3rd party randomisation and functional coverage to be included in the central test sequencer - or even better - inside the VVCs in the local sequencers for better control and encapsulation
*	Simple integration with regression test tools like Jenkins
*	Quick references are available for UVVM Utility Library, VVC System and all the BFMs/VVCs

## Available VVCs and BFMs
These VVCs and BFMs could be used inside a typical UVVM testbench, but they could also be used stand-alone - e.g. as a BFM or VVC to handle just the AXI4-Lite interface with everything else being your proprietary testbench and methodology.
*	AXI4-Lite
*	AXI-Stream
*	Avalon MM
*	SBI (Simple Bus Interface - A single cycle simple parallel bus interface)
*	UART
*	SPI
*	I2C
* GPIO
*	More are coming


## Prerequisites
UVVM is tool and library independent, but must be compiled with VHDL 2008.
UVVM has been tested with the following simulators:
- Modelsim version 10.4d
- Riviera-PRO version: 2017.02.99.6498

Python is required **if** you want to execute the VVC generation scripts

## Introduction to VVC Framework - including manuals
All documents including powerpoint presentations are available in the doc-directory of VVC_Framework on GitHub.
These are just fast access links to some interesting info:
- *['The critically missing VHDL testbench feature - Finally a structured approach'* - A brief introduction](https://github.com/UVVM/UVVM_All/blob/master/uvvm_vvc_framework/doc/The_critically_missing_VHDL_TB_feature.ppsx)
- *['VVC Framework Manual'*  - The user manual](https://github.com/UVVM/UVVM_All/blob/master/uvvm_vvc_framework/doc/VVC_Framework_Manual.pdf)


## License

The MIT License (MIT) 

Copyright (c) 2016 by Bitvis AS 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

## UVVM Maintainers
[Bitvis](http://bitvis.no) (Norway) has released UVVM as open source and we are committed to develop this system further.
We do however appreciate contributions and suggestions from users.

Please use the pull_requests branch for contributions and we will evaluate them for inclusion in our release on the master branch and handle any required verification and documentation.

Please note the new repository for external UVVM compatible community VIP (Verification IP): ****** TBD
