Bitvis VVC Name Modifier

Quick summary
---------------------------------------------------------
1. Copy the VIP files into their respective directory under vvc_to_be_modified
2. Run the script and follow the instructions in the terminal
3. Copy the modified files back into the VIP directory
4. If the VIP was already being used in a testbench, remember to update the names there.


Introduction
---------------------------------------------------------
The Bitvis VVC Name Modifier script is a Python 3 script that modifies the name of an existing Bitvis VIP.
The script is intended to be used if two version of a VIP, e.g. bitvis_vip_uart_x and bitvis_vip_uart_y
are to be used in the same testbench. By default, all variations of the Bitvis released VIPs share the 
same name. This means e.g. that bitvis_vip_uart_x will have entity uart_vvc, not uart_vvc_x. The
compile scripts will by default compile the VIP variation into the shared name library, e.g. bitvis_vip_sbi_full
is compiled into the bitvis_vip_sbi library. By running this script, all necessary files will be changed
in order for two variations of the VIP to work in the same test bench.


Prerequisites
---------------------------------------------------------
In order to run the script, it is necessary to have Python installed. To run the script from command
line, the python interpreter path needs to be added to the Path environmental variable.
Only Python 3 is supported, and the script has been tested with version 3.4.


What will be modified?
---------------------------------------------------------
Source code:
- In vvc_methods_pkg.vhd:
  - constant C_VVC_NAME 
  - <NAME>_VVCT target and alias
  - Shared variables that can be accessed from the sequencer
- In <name>_vvc.vhd for single channel VVCs and <name>_<channel>_vvc.vhd for multi-channel VVCs:
  - entity name
  - Shared variable aliases
- In <name>_vvc.vhd VVC wrapper for multi-channel VVCs:
  - entity name
  - entity name of instantiated leaf VVCs
  - Instance declarations of leaf VVCs
Scripts (if applicable):
- lib_name "bitvis_vip_<name>" is replaced with "bitvis_vip_<name>_<extension>"
  

Running the script
---------------------------------------------------------
1. Copy the files into the vvc_name_modifier folders:
- Copy all files under the VIP "src/" folder into the "uvvm_vvc_framework/script/vvc_name_modifier/vvc_to_be_modified/src/" folder.
- Copy all files under the VIP "script/" folder into the "uvvm_vvc_framework/script/vvc_name_modifier/vvc_to_be_modified/script/" folder.
  Note that the script can run without placing compile scripts in the "script/" folder.

2. Open a terminal and navigate to the vvc_name_modifier folder "uvvm_vvc_framework/script/vvc_name_modifier/"

3. Run the script with python vvc_name_modifier.py

4. At this point the script will query for the VVC name. Enter the VVC name exactly as it is typed in VIP name,
e.g. for bitvis_vip_uart enter "uart". If the expected <name>_vvc.vhd file is not found in the src directory, the
script will quit.

5. Let the script continue until it returns. The script will report SUCCESS when it has completed successfully. 

6. Copy the src and script files back into their respective folders in the VIP they were first copied from. The VIP has now successfully 
been renamed from <name> to <name>_<ext>.


Modifications after running the script
---------------------------------------------------------
If the VIP was already in use in a test environment before it was renamed, remember to change the following:

- Change any existing references to the old VIP name in your test bench. This includes:
  - Libraries and includes
    - Example: "library bitvis_vip_uart;" => "library bitvis_vip_uart_<ext>";
    - Example: "use bitvis_vip_uart.vvc_methods_pkg.all;" => "use bitvis_vip_uart_<ext>.vvc_methods_pkg.all;"
  - VVC target parameters (<NAME>_VVCT)
    - Example: "enable_log_msg(SBI_VVCT, 1, ID_BFM);" => "enable_log_msg(SBI_<EXT>_VVCT, 1, ID_BFM);"
  - Accesses to the VVC shared variables
    - Example: "shared_sbi_vvc_config(1).inter_bfm_delay.delay_type := TIME_START2START;" =>
               "shared_sbi_<ext>_vvc_config(1).inter_bfm_delay.delay_type := TIME_START2START;"

               
Support
---------------------------------------------------------
For support, please contact UVVM Support at info@uvvm.org
