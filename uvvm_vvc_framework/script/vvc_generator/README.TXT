Bitvis VVC Generator

Quick summary
---------------------------------------------------------
1. Run the script from command line with "python vvc_generator.py" (or "py vvc_generator.py") 
   and follow the instructions.
2. Modify the generated code as instructed anywhere the key --<USER_INPUT> is found.
3. If necessary, update t_channel type in UVVM-Util adaptations_pkg if new channels (other than 
   TX and RX) are used.


Introduction
---------------------------------------------------------
The Bitvis VVC Generator is a Python 3 script that generates VVCs and accompanying support files, 
including the command package, VVC methods package, a BFM skeleton and if necessary, a VVC wrapper
for multi-channel VVCs.


Prerequisites
---------------------------------------------------------
In order to run the script, it is necessary to have Python installed. To run the script from command
line, the python interpreter path needs to be added to the Path environmental variable.
Only Python 3 is supported, and the script has been tested with version 3.4.


Running the script
---------------------------------------------------------
The script can be run from command line by running:
"py vvc_generator.py"
or 
"python vvc_generator.py"

The script will query the user for information about the VVC during the script:

1. 
First, it will ask for the VVC name. Please enter the VVC name without spaces. This name needs to be
usable in the VHDL code, i.e. don't use any other characters than "a-z", "A-Z", "0-9" or "_". Any
name must start with a letter.

2. 
Second, the script will ask if the VVC will use multiple channels. Channels are a way of implementing 
more than one concurrent processes which will use the BFM procedures. For example, when implementing a
VVC for a bus which can only read OR write at the same time you would not need multiple channels. The 
SBI example VVC is an example of this.
When implementing a full duplex VVC, e.g. UART, it would make sense to use multiple channels since TX and RX
will operate concurrently. If you are implementing a VVC with concurrent channels, please type 'y' and 
press Enter. If not, type 'n' and press Enter. If you chose 'n', the script will not need any further information.

3. 
If you chose 'y' to implement multiple channels for your VVC you will be asked for how many VVC channels you need.
Enter a number between 1 and 99 and press enter.

4. 
The next step is to name your VVC channels. The script will ask for one name at the time, and generate new 
leaf VVCs for each channel name you enter. The channel names follow the same naming restrictions as the VVC 
name, stated in step 1. The script will also generate a wrapper VVC that you can include in your
test harness instead of including each leaf VVC individually. After the names have been entered for each VVC
channel, the script will not need any further details.

When the script has gathered all the information it needs, it will generate the VHDL files in the 'output' directory.
The naming of the files will be (<name> is the VVC name, and <channel> is a channel name):
- <name>_vvc.vhd
  - If this is a single channel VVC, this will be the main VVC file which includes all VVC logic (e.g. executor 
    and interpreter)
  - If this is a multi-channel VVC, this file will be the wrapper for all the leaf VVCs.
- <name>_<channel>_vvc.vhd
  - These files will consist of the VVC implementation for each VVC channel (leaf VVC). 
  - These files will only be generated if there are multiple channels for this VVC.
- <name>_bfm_pkg.vhd
  - This file is a suggested setup for the user BFM. It contains the necessary config records and types needed
    for UVVM to function properly. It does not contain any actual BFM procedures.
- vvc_cmd_pkg.vhd
  - This file contains the VVC operations and command records in which the VVC data is placed. 
- vvc_methods_pkg.vhd
  - This file contains VVC configuration and status records, and examples of how to implement the VVC methods.
For further information about the UVVM file structure, see the UVVM Manual under 'uvvm_vvc_framework/doc/'

Modifying the created VHDL files
---------------------------------------------------------
After the script has completed the files needs some user interaction before they are ready to use. In all places
marked with "--<USER_INPUT>" there will be instructions on how to properly modify the VVC for your BFM.
Additionally, if you created a VVC with multiple channels, please make sure to add these channels to the 
t_channel type located in the UVVM-Util "adaptations_pkg.vhd" file. By default, this type only contain 'TX'
and 'RX' channels but more can be added to fit any project.


Support
---------------------------------------------------------
For support, please contact Bitvis Support at support@bitvis.no
