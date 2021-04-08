( [Click here to go to the UVVM overall overview](./README.md) )

# Getting started using UVVM

UVVM is Free and Open source, under the very flexible [Apache license](./LICENSE).
UVVM basically has two levels of usage: Basic/Introductory and Advanced.
With the Basic/Introductory level you are given a library and methodology that provide common functionality for all testbenches from simple to expert with things like logging, alert handling, checking signals, waiting for signals, checking timing properties, simple randomisation, etc. This is explained directly below this chapter.
A number of BFMs (Bus Functional Models) compatible with the Utility Library are provided as free and open source code as a kick-start for testbenches using interfaces like AXI lite/stream, Avalon, I2C, SPI, UART, SBI, GPIO, etc.
For more advanced testbenches with either multiple interfaces, or the need to reach interface related corner cases, the VVC system is really great. This is explained below the Utility Library.
A number of VHDL verification components (VVCs) are provided for free with this system.
NOTE: All Libraries, BFMs, VVCs, etc. have their own dedicated Quick Reference (QR) showing you all you need to use the respective part.

## Github directory naming notation
- The directories starting with 'uvvm_' are the core libraries for UVVM Utility Library and UVVM VVC System
- All directories starting with 'bitvis_vip_' are verification IP/modules from Bitvis
- All other directories starting with 'bitvis_' are design IP/modules from Bitvis
- Directories starting with 'x' are external (third party) libraries that work seamlessly with UVVM

## List of demo testbenches
 - /bitvis_irqc/tb
    - Navigate to /bitvis_irqc/sim
    - Open "bitvis_irqc.mpf" or run "vsim -c -do ../script/compile_all_and_simulate.do"

 - /bitvis_uart/tb
    - Navigate to /bitvis_uart/sim
    - Open "bitvis_uart.mpf" or run "vsim -c -do ../script/compile_all_and_simulate.do"

## For developers with no previous UVVM experience:
### Step 1
You should start by first understanding and trying out the Utility Library. The basics here could be covered in less than one hour. The UVVM Utility Library has a *very* low user threshold - according to all users so far.
* Read the [README-file for UVVM Utility Library](./uvvm_util/README.md) to get a first introduction to why, what and how.
* Go through the powerpoint 'Making a simple, structured and efficient VHDL testbench – Step-by-step' linked to from the README-file

### Step 2
To compile Utility Library related VHDL files you can do the following:
* To compile Utility Library only you can use the following approaches:
   * Running commands inside Modelsim/Questasim/RivieraPro/ActiveHDL:
      1. Go to the uvvm_util/script directory using the simulator's console.
      2. Run the command: do compile_src.do 
         The following arguments are suported compile_src.do arg1 arg2 :
         - arg1: sets source directory, target will be current directory if no arg2
         - arg2: sets target directory
   * Using GHDL:
      Use GHDL provided script with uvvm_util/script/compile_order.txt as input
   * Any other approach - or with script problems:
      Follow compile order given in uvvm_util/script/compile_order.txt
      Note that VHDL 2008 must be used. Lines starting with '# ' are required library definitions
* To compile the complete IRQC demo testbench including Utility Library, SBI BFM and the IRQC DUT:
   1. Use any of the approaches above and exchange the path 'uvvm_util' with 'bitvis_irqc'
   2. Use the file compile_all_and_simulate.do instead.
* To compile all above plus all provided BFMs, the scripts for compiling the complete UVVM should be used. (See below) (This compiles far more than you need, but then at least everything is pre-compiled)

## For developers who understand the basics of UVVM Utility library and need more than just basic testbenches:
### Step 1
* A very brief introduction to making a structured testbench architecture can be found under [Advanced Verification - Made simple](./_supplementary_doc).
* Our presentation at the ESA (European Space Agency) conference on SEFUW 2018 gives a good introduction to UVVM, Testbench architecture, VVCs and how UVVM is standardising the VHDL testbench architecture: https://indico.esa.int/indico/event/232/session/6/contribution/8/material/slides/0.pdf
* For a slightly deeper introduction - also explaining the challenges - please check out our PPT-file [The_critically_missing_VHDL_TB_feature.ppsx](./uvvm_vvc_framework/doc/The_critically_missing_VHDL_TB_feature.ppsx)

### Step 2
* The easiest way to compile the complete UVVM with everything (Utility Library, VVC Framework, BFMS, VVCs, etc.) is to go to the top-level script directory and run 'compile_all.do' inside Modelsim/Questasim/RivieraPro/ActiveHDL.

* For the UART VVC demo, go to bitvis_uart/script and run 'compile_all_and_simulate.do'

* For GHDL use the provided 'compile_order.txt' files.

### Step 3
If you like to use UVVM in a more advanced way you should read the relevant documentation under [UVVM VVC Framework doc](./uvvm_vvc_framework/doc)
