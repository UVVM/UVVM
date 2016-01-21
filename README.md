# UVVM VVC Framework
The Open Source 'UVVM (Universal VHDL Verification Methodology) - VVC (VHDL Verification Component) Framework' for making structured VHDL testbenches for verification of FPGA.

# For what do I need this VVC Framework?
The VVC Framework is a VHDL Verification Component system that allows multiple interfaces on a DUT to be stimulated/handled simultaneously in a very structured manner, and controlled by a very simple to understand software like test sequencer. 
VVC Framework is unique as an open source VHDL approach to building a structured testbench architecture using Verification components and a simple protocol to access these. As an example a simple command like uart_expect(UART_VVCT, my_data), or axilite_write(AXILITE_VVCT, my_addr, my_data, my_message) will automatically tell the respective VVC (for UART or AXI-Lite) to execute the uart_receive() or axilite_write() BFM respectively. 

# What are the benefits of using this system?
The really great benefit here is that these commands may be issued at the same time from the test sequencer - thus allowing full control of when an access is to be performed, and the commands are understandable "even" for a software developer ;-)   The commands may be queued, skewed, delayed, synchronised, etc - and a super-set for applying constrained random or other sequences of data may of of course also be applied.
This yields an excellent control over your testbench and VVCs.
For debugging you can select logging of a command when it is issued from the sequencer, when it is received by the VVC, when it is initiated by the VVC and/or when it has been executed towards the DUT. This allows full overview of all actions in your complete testbench.
This previous post on LinkedIn will give you some more info on why you should use this library.

# License

