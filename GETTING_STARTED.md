( [Click here to go to the UVVM overall overview](https://github.com/UVVM/UVVM/blob/master/README.md) )

# Getting started using UVVM

UVVM is Free and Open source, under the very flexible [MIT licence](https://github.com/UVVM/UVVM/blob/master/LICENSE)
UVVM basically has two levels of usage: Basic/Introductory and Advanced
With the Basic/Introductory level you are given a library and methodology that provides common functionality for all testbenches from simple to expert with things like logging, alert handling, checking signals, waiting for signals, checking timing properties, simple randomisation, etc. This is explained directly below this chapter.
A number of BFMs (Bus Functional Models) compatible with the Utility Library are provided as free and open source code as a kick-start for testbenches using interfaces like AXI lite/stream, Avalon, I2C, SPI, UART, SBI, GPIO, etc.
For more advanced testbenches with either multiple interfaces, or the need to reach interface related corner cases, the VVC system is really great. This is explained below the Utility Library.
A number of VHDL verification components (VVCs) are provided for free with this system.

## Github directory naming notation
- The directories starting with 'uvvm_' are the core libraries for UVVM Utility Library and UVVM VVC System
- All directories starting with 'bitvis_vip_' are verification IP/modules from Bitvis
- All other directories starting with 'bitvis_' are design IP/modules from Bitvis
- Directories starting with 'x' are external (third party) libraries that work seamlessly with UVVM

## For developers with no previous UVVM experience: 1
You should start by first understanding and trying out the Utility Library. The basics here could be covered in less than one hour. The UVVM Utility Library has a *very* low user threshold - according to all users so far.
* Read the [README-file for UVVM Utility Library](https://github.com/UVVM/UVVM/blob/master/README_UVVM_Utility_Library.md) to get a first introduction to why, what and how.
* Go through the powerpoint 'Making a simple, structured and efficient VHDL testbench – Step-by-step' linked to from the README-file

## For developers with no previous UVVM experience: 2
If you want to run a demo testbench using the Utility library, including the SBI BFM, you can run bitvis_irqc/tb/irqc_tb.vhd
To compile Utility Library related VHDL files you can do the following:
- To compile Utility Library only: 
  - Using Modelsim/Questasim project files: 
    - Double click on uvvm_util/sim/uvvm_util.mpf (may have to relate file extension to simulator)
    




