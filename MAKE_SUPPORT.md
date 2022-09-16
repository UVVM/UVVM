# GNU Make Support
Experimental support for using GNU Make to drive simulation of the `bitvis_uart` and `bitvis_irqc` examples is now included. The `script` subdirectory of these examples now includes a Makefile which can be used to compile, simulate and view the resulting waveform in **GTKWave**. The supported simulators are **GHDL**, **NVC**, **ModelSim** and **Questa**.

To try it out, open a terminal, navigate to the `script` subdirectory of the relevant example, then run `make`, specifying the simulator as the target. For example, on Windows/MSYS2, in a Windows Command Prompt:

    cd C:\work\UVVM\bitvis_uart\script
    make ghdl

Replace `C:\work\UVVM` with the correct path to your clone of the UVVM repository.

The heavy lifting is done by a couple of Makefile includes (`multisim.mk` and `example.mk`) and a shell script (`vcd2gtkw.sh`) which are located in the main `script` directory, along with `Makefile_template` which can be used as a starting point for using Makefiles in your own projects.

### Notes:
1. On Windows, MSYS2 is recommended. Use `pacman` to install `make` (required) and `git` (recommended).
2. At present, precompiled UVVM libraries are required. See the simulator specific notes below for details.

## Simulator Specific Notes

### GHDL
To precompile the UVVM libraries and VIPs, run the `compile-uvvm.sh` script which is located in the `vendors` subdirectory of the GHDL libraries directory. On Linux, the default location of this directory is `/usr/local/lib/ghdl`; on Windows/MSYS2, the default location is `C:\msys64\mingw64\lib\ghdl`.

### NVC
UVVM support in NVC is partially complete, but sufficient for the examples.

To precompile the UVVM libraries and VIPs, run the following command:

    nvc --install uvvm

### ModelSim/Questa
The `compile_all.do` script located in the main script directory can be used to precompile the UVVM libraries and VIPs. Choose (or create) an appropriate directory for user precompiled libraries, and create a `uvvm` subdirectory under it. This subdirectory is the 2nd argument to the script. For example, on Windows/MSYS2, enter the following command in a Windows Command Prompt:

    vsim -c -do "do C:/work/UVVM/script/compile_all.do C:/work/UVVM/script C:/work/.simlib/uvvm; exit"

* Replace `C:/work/UVVM` with the correct path to your clone of the UVVM repository.
* Replace `C:/work/.simlib` with the correct path to your precompiled libraries directory.
* Note the forward slashes!

The `multisim.mk` Makefile include assumes that precompiled libraries are located in the `.simlib` subdirectory of the **home** directory. You can change this by setting the `SIM_LIB_PATH` variable in your Makefile.