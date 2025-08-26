( [Click here to go to the UVVM overall overview](./../README.md) )

# UVVM VVC System (or Framework)
This methodology and library is a free and Open Source Methodology and Library for making very structured VHDL-based testbenches.

Overview, Readability, Maintainability, Extensibility and Reuse are all vital for FPGA development efficiency and quality. 
UVVM VVC (VHDL Verification Component) Framework was released in 2016 as a tool to handle exactly these aspects.
This library is a part of the overall [UVVM](./../README.md)

## For what do I need this VVC Framework?
UVVM is a verification component system that allows the implementation of a very structured testbench architecture to handle medium complexity verification challenges and upwards. A key benefit of this system is the very simple software-like VHDL test sequencer that may control your complete testbench architecture with any number of verification components. This takes overview, readability and maintainability to a new level. 
As an example a simple command like uart_expect(UART_VVCT, my_data), or axilite_write(AXILITE_VVCT, my_addr, my_data, my_message) will automatically tell the respective VVC (for UART or AXI-Lite) to execute the uart_receive() or axilite_write() BFM respectively. 

## What are the main benefits of using this system?
The really great benefit here is the unique overview, readability, maintainability, extensibility and reuse you get from having the best testbench architecture possible - much in the same way as a good architecture is also critical for any complex design.
Another major benefit here is that any number of commands may be issued at the same time from the test sequencer - thus allowing full control of when an access is to be performed, and the commands are understandable "even" for a software developer ;-)   The commands may be queued, skewed, delayed, synchronised, etc. - and a super-set for applying constrained random or other sequences of data may of course also be applied.
This yields an excellent control over your testbench and VVCs.

For debugging you can select logging of a command when it is issued from the sequencer, when it is received by the VVC, when it is initiated by the VVC and/or when it has been executed towards the DUT. This allows full overview of all actions in your complete testbench.

UVVM is free and open source and has standardised the way to build good testbench architectures and VVCs so that reuse is dead simple, and allows the FPGA community to share VVCs that will work together in a well-structured test harness. All kind of contributions are appreciated. Please provide via pull requests.

You may of course combine UVVM with any other legacy or 3rd party testbenches or verification models.
[This post on LinkedIn](https://www.linkedin.com/pulse/what-uvvm-espen-tallaksen) will give you some more info on why you should use this library.

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
*	Allows VVCs to be included anywhere in the test harness - or even inside the Design itself
*	A logging and alert system that supports full verbosity control of functionality and hierarchy
*	A logging system that lets you easily see how your commands propagate from your central test sequencer to your VVCs - through the execution queue - until it is executed and completed towards the DUT
*	Allows randomization and functional coverage to be included in the central test sequencer - or even better - inside the VVCs in the local sequencers for better control and encapsulation
*	Simple integration with regression test tools like Jenkins
*	Quick references are available for UVVM Utility Library, VVC System and all the BFMs/VVCs

## Available VVCs and BFMs 
See [UVVM](./../README.md)

## Prerequisites
UVVM is tool and library independent, but it must be compiled with VHDL-2008 or newer.
See the overall [UVVM](./../README.md) documentation for prerequisites, license, maintainers, etc.
Python is required **if** you want to execute the VVC generation scripts

## Introduction to VVC Framework - including manuals
All documents including powerpoint presentations are available in the *uvvm_vvc_framework/doc* directory on GitHub.
These are just fast access links to some interesting info:
- *['The critically missing VHDL testbench feature - Finally a structured approach'* - A brief introduction](./../uvvm_vvc_framework/doc/The_critically_missing_VHDL_TB_feature.ppsx)
- *['VVC Framework Manual'*  - The user manual](./../uvvm_vvc_framework/doc/VVC_Framework_Manual.pdf)

A demo of how to make a structured VVC based testbench is given in the [UART example](./../bitvis_uart).  
You can compile everything needed via the provided [scripts](./../bitvis_uart/script)

Please use the pull_requests branch for contributions and we will evaluate them for inclusion in our release on the master branch and handle any required verification and documentation.
