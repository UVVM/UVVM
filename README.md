# UVVM
UVVM (Universal VHDL Verification Methodology) is a free and Open Source Methodology and Library for making very structured VHDL-based testbenches.

Overview, Readability, Maintainability, Extensibility and Reuse are all vital for FPGA development efficiency and quality.
UVVM VVC (VHDL Verification Component) Framework was released in 2016 to handle exactly these aspects.

Full documentation can be found on https://uvvm.github.io.

UVVM consists currently of the following elements:
- [Utility Library](./uvvm_util/README.md)
- [VVC (VHDL Verification Component) Framework](./uvvm_vvc_framework/README.md)  - Including Utility Library
- BFMs (Bus Functional Models) to be used with any part of UVVM (See below for currently supported interfaces for UVVM)
- VVCs to be used with UVVM VVC Framework and may be combined with BFMs (see overview below)
- Scoreboards to ber used as supplementary functionality at any level
- Enhanced randomisation - Included under the Utility library, automatically available when compiling Utility Library
- Functional Coverage - Included under the Utility library, automatically available when compiling Utility Library
- Specification Coverage - Aka Requirement Coverage og Requirement tracking - Includes a Requirements Traceability Matrix
- Error Injector
- more to come...

## For starters
Please note that UVVM has two different complexity levels. The VVC Framework and VVCs for medium to advanced testbenches, and the Utility library and BFMs for simple usage - and as a basis for more advanced testbenches.
Novice users are strongly recommended to first use UVVM Utility library and BFMs. This has a *very* low user threshold and you will be up and running in an hour. Please see [Utility Library](./uvvm_util/README.md) for an introduction. 
The VVC framework is slightly more complex, but it has been simplified as far as possible to allow efficient development of good quality testbenches.
As a starter you may also want to include Enhanced Randomisation, Functional Coverage or Specification coverage

Note that a dedicated repository (UVVM_Light)](https://github.com/UVVM/UVVM_Light) has been provided to simplify getting started using Utility Library and BFMs. Here all the code and documentation have been collected in a single directory, and only a single VHDL library is used. The documentation and code are 100% the same as for the full UVVM. 

Please also see [Getting Started](./GETTING_STARTED.md) with UVVM.

## For what do I need this VVC Framework?
UVVM is a verification component system that allows the implementation of a very structured testbench architecture to handle any verification complexity - from really simple to really complex. A key benefit of this system is the very simple software-like VHDL test sequencer that may control your complete testbench architecture with any number of verification components. This takes overview, readability and maintainability to a new level.
As an example a simple command like uart_expect(UART_VVCT, my_data), or axilite_write(AXILITE_VVCT, my_addr, my_data, my_message) will automatically tell the respective VVC (for UART or AXI-Lite) to execute the uart_receive() or axilite_write() BFM respectively.

## What are the main benefits of using this system?
The really great benefit here is the unique overview, readability, maintainability, extensibility and reuse you get from having the best testbench architecture possible - much in the same way as a good architecture is also critical for any complex FPGA design.
Another major benefit here is that any number of commands may be issued at the same time from the test sequencer - thus allowing full control of when an access is to be performed, and the commands are understandable "even" for a software developer ;-)   The commands may be queued, skewed, delayed, synchronised, etc. - and a super-set for applying constrained random or other sequences of data may of course also be applied.
This yields an excellent control over your testbench and VVCs.

For debugging you can select logging of a command when it is issued from the sequencer, when it is received by the VVC, when it is initiated by the VVC and/or when it has been executed towards the DUT. This allows full overview of all actions in your complete testbench.

UVVM is free and open source and has standardised the way to build good testbench architectures and VVCs so that reuse is dead simple, and allows the FPGA community to share VVCs that will work together in a well-structured test harness.
You may of course combine UVVM with any other legacy or 3rd party testbenches or verification models.


## Main Features
*	Very useful support for checking values, ranges, time aspects, and for waiting for events inside a given window
*	An extremely low user threshold for the basic functionality - like logging, alert handling and checkers
*	A very structured testbench architecture that allows LEGO-like testbench/harness implementation
*	A very structured VHDL Verification Component (VVC) architecture that allows simultaneous activity (stimuli and checking) on multiple interfaces in a very easily understandable manner
*	An easily understandable command syntax to control a complete testbench with multiple VVCs
*	The structure and overview are easily kept even for a testbench with a large number of VVCs
*	A VVC architecture that is almost exactly the same from one VVC to another - sometimes with only the BFM calls as the differentiator, thus allowing an extremely efficient reuse from one VVC to another
*	A VVC architecture that easily allows multiple threads for e.g. simultaneous Avalon Command and Response
*	A VVC architecture that allows simple encapsulation for ALL verification functionality for any given interface or protocol
*	Allows VVCs to be included anywhere in the test harness - or even inside the design itself
*	A logging and alert system that supports full verbosity control of functionality and hierarchy
*	A logging system that lets you easily see how your commands propagate from your central test sequencer to your VVCs - through the execution queue - until it is executed and completed towards the DUT
*	Includes randomisation and functional coverage to be included in the central test sequencer - or even better - inside the VVCs in the local sequencers for better control and encapsulation
*	Simple integration with regression test tools like Jenkins and [HDLRegression](https://github.com/HDLUtils/hdlregression)
*	Quick references are available for UVVM Utility Library, VVC Framework and all the BFMs/VVCs/VIP
*   May insert delay between commands – from sequencer, - and thus the only system to target cycle related corner cases
*   Simple handling of split transactions and out of order protocols
*   Common commands to control VVC behaviour
*   Simple synchronization of interface actions – from sequencer
*   May use Broadcast and Multicast



## Available VVCs and BFMs
These VVCs and BFMs could be used inside a typical UVVM testbench, but they could also be used stand-alone - e.g. as a BFM or VVC to handle just the AXI4-Lite interface with everything else being your proprietary testbench and methodology.
*	AXI4
*	AXI4-Lite
*	AXI-Stream - master and slave
*	Avalon MM
*   Avalon ST - master and slave
*   Ethernet
*	SBI (Simple Bus Interface - A single cycle simple parallel bus interface)
*	UART
*	SPI - master and slave
*	I2C - master and slave
*   GPIO
*   GMII - Transmit and receive
*   RGMII - Transmit and receive
*   Wishbone
*   Clock Generator
*   Error Injector
*	More are coming

**IMPORTANT**
The VIPs complies with respective protocols and thus allows a
normal access towards the interface. The VIPs are not protocol checkers.

## Prerequisites
UVVM is tool and library independent, but it must be compiled with VHDL-2008 or newer.
UVVM has been tested with the following simulators:
- Modelsim
- Riviera-PRO
- Questa Sim
- GHDL

**Note** Questa Sim version 19.2 and Modelsim version 19.2 have known bugs that might prevent UVVM from working properly.

Python is required **if** you want to execute the VVC generation scripts


## Introduction to VVC Framework - including manuals
All documents including powerpoint presentations are available in the *doc* (and *uvvm_vvc_framework/doc*) directory on GitHub.
These are just fast access links to some interesting info:
- *['The critically missing VHDL testbench feature - Finally a structured approach'* - A brief introduction](./uvvm_vvc_framework/doc/The_critically_missing_VHDL_TB_feature.ppsx)
- *['VVC Framework Manual'*  - The user manual](./uvvm_vvc_framework/doc/VVC_Framework_Manual.pdf)


## License

Copyright 2024 UVVM  
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


## UVVM Maintainers
The UVVM steering group (currently Inventas and EmLogic, Norway) has released UVVM as open source and both EmLogic and Inventas are committed to develop this system further.
We do however appreciate contributions and suggestions from users.

Please use Pull requests for contributions and we will evaluate them for inclusion in our release on the master branch.
