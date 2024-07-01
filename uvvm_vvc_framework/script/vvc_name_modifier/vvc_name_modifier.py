#================================================================================================================================
# Copyright 2024 UVVM
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------cd 

__author__ = 'UVVM'
__copyright__ = "Copyright 2024, UVVM"
__version__ = "1.0.0"
__email__ = "info@uvvm.org"

import os
import glob
import fileinput


def print_help():
    print("\rPlease place the VVC which is to be modified into the \"vvc_to_be_modified\" directory")
    print("- Place the source files into the \"src\" directory")
    print("- Place compile scripts (if applicable) into the \"scripts\" directory\n")


def is_input_vhdl_legal(requested_vvc_name):
    # Check if name contains illegal VHDL characters
    illegal_chars = set("<->!¤%&/()=?`\´}][{€$£@ ^¨~'*;:.,|§\" ")
    if any((c in illegal_chars) for c in requested_vvc_name):
        print("Input contains illegal VHDL characters. Please try again.")
        return False
    if requested_vvc_name.__len__() < 1:
        print("Input too short. Please try again.")
        return False
    if requested_vvc_name.__len__() > 14:
        print("WARNING: Name exceeds default maximum name length, defined in UVVM Utility Library constant C_LOG_SCOPE_WIDTH")
        print("         - Please increase C_LOG_SCOPE_WIDTH in the adaptations_pkg.vhd")
    if (requested_vvc_name[0] == '_') or (requested_vvc_name[0].isdigit()):
        print("Input must start with a letter")
        return False
    return True


# Get vvc name and check if it is valid. Repeat until valid name is received.    
def get_vvc_name():
    requested_vvc_name = input("\rPlease enter the original VVC name: ")
    if is_input_vhdl_legal(requested_vvc_name.lower()) is False:
        return get_vvc_name()
    return requested_vvc_name


# Get vvc name extension and check if it is valid. Repeat until valid extension is received.        
def get_name_extension():
    requested_vvc_ext = input("\rPlease enter the new VVC name extension: ")
    if is_input_vhdl_legal(requested_vvc_ext.lower()) is False:
        return get_name_extension()
    return requested_vvc_ext


# Check if the expected base files in the VVC exists in the vvc_to_be_modified/src/ folder    
def expected_base_vvc_files_exists(vvc_name):
    if not os.path.isfile("vvc_to_be_modified/src/"+vvc_name.lower()+"_vvc.vhd"):
        print("File "+vvc_name.lower()+"_vvc.vhd was not found in the src directory")
        return False
    if not os.path.isfile("vvc_to_be_modified/src/vvc_methods_pkg.vhd"):
        print("File vvc_methods_pkg.vhd was not found in the src directory")
        return False
    return True


# Check if this is a multi-channel VVC by looking for expected leaf-vvc file names    
def is_multi_channel_vvc(vvc_name):
    vvcs_in_src = glob.glob("vvc_to_be_modified/src/"+vvc_name.lower()+"*_vvc.vhd")
    if vvcs_in_src.__len__() > 1:
        return True
    return False


# Get a list of all leaf VVCs    
def get_multi_channel_vvcs_as_list(vvc_name):
    vvcs_in_src = glob.glob("vvc_to_be_modified/src/"+vvc_name.lower()+"*_vvc.vhd")
    # Remove file prefix
    vvcs_in_src = [w.replace('vvc_to_be_modified/src\\', '') for w in vvcs_in_src]
    # Remove the wrapper VVC
    vvcs_in_src.remove(vvc_name.lower()+"_vvc.vhd")

    return vvcs_in_src


# Replace the necessary names in the vvc_methods_pkg    
def replace_vvc_methods_pkg(vvc_name, new_name_extension):
    # Replace targets
    with fileinput.FileInput("vvc_to_be_modified/src/vvc_methods_pkg.vhd", inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace(vvc_name.upper()+"_VVC", vvc_name.upper()+"_"+new_name_extension.upper()+"_VVC"),
                  end='')
    # Replace shared variables
    with fileinput.FileInput("vvc_to_be_modified/src/vvc_methods_pkg.vhd", inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("shared_"+vvc_name.lower(), "shared_"+vvc_name.lower()+"_"+new_name_extension.lower()),
                  end='')


# Replace all names in the VVC                  
def replace_vvc(file_name, vvc_name, new_name_extension):
    # Replace entity name
    with fileinput.FileInput("vvc_to_be_modified/src/"+file_name.lower()+"_vvc.vhd", inplace=True, backup='.bak')\
            as file:
        for line in file:
            print(line.replace("entity "+vvc_name.lower(), "entity "+vvc_name.lower()+"_"+new_name_extension.lower()),
                  end='')

    # Replace architecture name
    with fileinput.FileInput("vvc_to_be_modified/src/"+file_name.lower()+"_vvc.vhd", inplace=True, backup='.bak')\
            as file:
        for line in file:
            print(line.replace("architecture behave of "+vvc_name.lower(),
                               "architecture behave of "+vvc_name.lower()+"_"+new_name_extension.lower()), end='')
    # Replace shared variables
    with fileinput.FileInput("vvc_to_be_modified/src/"+file_name.lower()+"_vvc.vhd", inplace=True, backup='.bak')\
            as file:
        for line in file:
            print(line.replace("shared_"+vvc_name.lower(), "shared_"+vvc_name.lower()+"_"+new_name_extension.lower()),
                  end='')


# Get VVC name and channel from the VVC file name                  
def parse_vvc_name_and_channel_from_file_name(vvc_file_name):
    return vvc_file_name.replace('_vvc.vhd', '')


# Get VVC channel from the VVC file name and base name    
def parse_channel_from_vvc_name(full_vvc_name, vvc_base_name):
    retstr = full_vvc_name.replace('_vvc.vhd', '')
    retstr = retstr.replace(vvc_base_name+"_",'')
    return retstr


# Replace all VVC names in the VVC wrapper, if this is a multi-channel VVC    
def replace_vvc_wrapper(vvc_name, new_name_extension, list_of_leaf_vvcs):
    # Replace entity name
    with fileinput.FileInput("vvc_to_be_modified/src/"+vvc_name.lower()+"_vvc.vhd", inplace=True, backup='.bak')\
            as file:
        for line in file:
            print(line.replace("entity "+vvc_name.lower(), "entity "+vvc_name.lower()+"_"+new_name_extension.lower()),
                  end='')
    # Replace architecture name
    with fileinput.FileInput("vvc_to_be_modified/src/"+vvc_name.lower()+"_vvc.vhd", inplace=True, backup='.bak')\
            as file:
        for line in file:
            print(line.replace("architecture struct of "+vvc_name.lower(),
                               "architecture struct of "+vvc_name.lower()+"_"+new_name_extension.lower()),
                  end='')
    for i in list_of_leaf_vvcs:
        channel = parse_channel_from_vvc_name(i,vvc_name)
        # Replace all instance declarations
        with fileinput.FileInput("vvc_to_be_modified/src/"+vvc_name.lower()+"_vvc.vhd", inplace=True, backup='.bak')\
                as file:
            for line in file:
                print(line.replace("i1_"+vvc_name.lower()+"_"+channel.lower()+": entity work."+vvc_name.lower()+"_"+
                                   channel.lower()+"_vvc",
                                   "i1_"+vvc_name.lower()+"_"+new_name_extension+"_"+channel.lower()+": entity work."+
                                   vvc_name.lower()+"_"+new_name_extension+"_"+channel.lower()+"_vvc"), end='')


# Remove .bak backup files                                   
def remove_backup_files(path):
    for currentFile in glob.glob(os.path.join(path, '*')):
        if currentFile.endswith(".bak"):
            os.remove(currentFile)


# Method which replaces the names in all VVC source files            
def replace_vvc_names(vvc_name, new_name_extension, multi_channel_vvc):
    replace_vvc_methods_pkg(vvc_name, new_name_extension)
    if multi_channel_vvc:
        list_of_leaf_vvcs = get_multi_channel_vvcs_as_list(vvc_name)
        for i in list_of_leaf_vvcs:
            replace_vvc(parse_vvc_name_and_channel_from_file_name(i), vvc_name, new_name_extension)
        replace_vvc_wrapper(vvc_name, new_name_extension, list_of_leaf_vvcs)
    else:
        replace_vvc(vvc_name, vvc_name, new_name_extension)

    remove_backup_files("vvc_to_be_modified/src/")
    print("Source files successfully modified")


# Replaces the compiled library name in the VVC compile scripts    
def replace_script(file_name, vvc_name, new_name_extension):
    # Replace lib name
    with fileinput.FileInput("vvc_to_be_modified/script/"+file_name, inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace("quietly set lib_name \"bitvis_vip_"+vvc_name.lower()+"\"",
                               "quietly set lib_name \"bitvis_vip_"+vvc_name.lower()+"_"+new_name_extension.lower()+
                               "\""), end='')


# Checks if the expected scripts exists                               
def script_exists(script_name):
    if not os.path.isfile("vvc_to_be_modified/script/"+script_name):
        print("Script "+script_name+" was not found in the script directory. Skipping...")
        return False
    print("Found script "+ script_name)
    return True


# Modify all scripts, if they exist. Will not fail if scripts does not exist.    
def replace_script_names(vvc_name, new_name_extension):
    if script_exists("compile_bfm.do"):
        replace_script("compile_bfm.do", vvc_name, new_name_extension)
    if script_exists("compile_src.do"):
        replace_script("compile_src.do", vvc_name, new_name_extension)
    remove_backup_files("vvc_to_be_modified/script/")


# Main entry point for the script    
if __name__ == '__main__':
    print_help()
    vvc_name = get_vvc_name()
    multi_channel_vvc = False

    # Exit if the expected files were found
    if not expected_base_vvc_files_exists(vvc_name):
        print("Did not find all necessary files in the src directory")
        exit(1)
    else:
        print("Found the necessary VVC source files")

    new_name_extension = get_name_extension()

    multi_channel_vvc = is_multi_channel_vvc(vvc_name)
    if multi_channel_vvc:
        print("Detected that this is a multi-channel VVC")
    else:
        print("Detected that this is a single channel VVC")

    replace_vvc_names(vvc_name, new_name_extension, multi_channel_vvc)
    replace_script_names(vvc_name, new_name_extension)
    print("\nSUCCESS")

    exit(0)