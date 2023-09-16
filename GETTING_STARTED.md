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
- The directories starting with `uvvm_` are the core libraries for UVVM Utility Library and UVVM VVC System
- All directories starting with `bitvis_vip_` are verification IP/modules from Bitvis
- All other directories starting with `bitvis_` are design IP/modules from Bitvis
- Directories starting with 'x' are external (third party) libraries that work seamlessly with UVVM

## Compiling all of UVVM

The easiest way to compile the complete UVVM with everything (Utility Library, VVC Framework, BFMS, VVCs, etc.) is to go to the top-level script directory and either run `compile_all.do` inside Modelsim / Questasim / RivieraPro / ActiveHDL, or run the `compile_all.sh` shell script:

    sh compile_all.sh <simulator> <target>

`<simulator>` specifies the simulator to be used and should be `ghdl`, `nvc` or `vsim`. `<target_dir>` sets target directory (defaults to current directory if not specified).

## Demo testbenches

Demo testbenches are provided in the `bitvis_irqc` and `bitvis_uart` directories.

To compile and simulate a demo, start by navigating to its `script` subdirectory. Users of ModelSim, Questa, Riviera Pro and ActiveHDl can run the `compile_all_and_simulate.do` script:

     vsim -c -do compile_all_and_simulate.do

Alternatively, run the `compile_all_and_simulate.sh` shell script:

    sh compile_all_and_simulate.sh <simulator> <target_dir>

`<simulator>` specifies the simulator to be used and should be `ghdl`, `nvc` or `vsim`. `<target_dir>` sets target directory (defaults to current directory if not specified).

## For developers with no previous UVVM experience:
### Step 1
You should start by first understanding and trying out the Utility Library. The basics here could be covered in less than one hour. The UVVM Utility Library has a *very* low user threshold - according to all users so far.
* Read the [README-file for UVVM Utility Library](./uvvm_util/README.md) to get a first introduction to why, what and how.
* Go through the powerpoint 'Making a simple, structured and efficient VHDL testbench – Step-by-step' linked to from the README-file

### Step 2
To compile Utility Library related VHDL files, navigate to `uvvm_util/script`. Users of Modelsim, Questasim, Riviera Pro or ActiveHDL may run the `compile_src.do` script in the simulator console:

    do compile_src.do <source_dir> <target_dir>

`<source_dir>` sets source directory, `<target_dir>` sets target directory (defaults to current directory if not specified).

Alternatively, run the `compile_src.sh` shell script:

    sh compile_src.sh <simulator> <target_dir>

`<simulator>` specifies the simulator to be used and should be `ghdl`, `nvc` or `vsim`. `<target_dir>` sets target directory (defaults to current directory if not specified).

To compile the demo testbenches, refer to the **Demo testbenches** section above.

To compile everything, refer to the **Compiling all of UVVM** section above.

## For developers who understand the basics of UVVM Utility library and need more than just basic testbenches:
### Step 1
* A very brief introduction to making a structured testbench architecture can be found under [Advanced Verification - Made simple](./_supplementary_doc).
* Our presentation at the ESA (European Space Agency) conference on SEFUW 2018 gives a good introduction to UVVM, Testbench architecture, VVCs and how UVVM is standardising the VHDL testbench architecture: https://github.com/UVVM/UVVM/blob/master/uvvm_util/doc/Advanced_VHDL_verification.pdf
* For a slightly deeper introduction - also explaining the challenges - please check out our PPT-file [The_critically_missing_VHDL_TB_feature.ppsx](./uvvm_vvc_framework/doc/The_critically_missing_VHDL_TB_feature.ppsx)

### Step 2
* Refer to the **Compiling all of UVVM** section above.

* Refer to the **Demo testbenches** section above.

### Step 3
If you would like to use UVVM in a more advanced way you should read the relevant documentation under [UVVM VVC Framework doc](./uvvm_vvc_framework/doc).

## Running Shell Scripts on Windows

[MSYS2](https://www.msys2.org/) is recommended for running shell scripts, GNU utilities etc on Windows. It is also recommended for the GHDL and NVC simulators. Remember to add the MSYS2 binary directories to the Windows path if you would like to use a Windows Terminal or Command Prompt instead of the MSYS2 terminal:

    C:\msys64\usr\bin
    C:\msys64\mingw64\bin
    C:\msys64\mingw32\bin