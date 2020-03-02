#================================================================================================================================
# Copyright 2020 Bitvis
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
#--------------------------------------------------------------------------------------------------------------------------------

# Fix 'vmap'
#
#     This is a fix for a bug in Modelsim's 'vmap' command, resulting in Modelsim
#     incorrectly reporting successful modification of 'modelsim.ini'.
#
#     On some Linux hosts, Modelsim reports "Modifying modelsim.ini" when vmap is 
#     executed without acutally modifying 'modelsim.ini' file. This script test to 
#     check if the bug exists, and provides an aleternate 'vmap' command that 
#     modifies 'modelsim.ini' file as expected by Modelsim.
#

vlib test-vmap-bug-lib
vmap test-vmap-bug test-vmap-bug-lib

if { [catch {vmap test-vmap-bug}] } {
    # Bug exists

    echo "Detected vmap bug."
    proc vmap { lib path } {
        set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
        set filename "modelsim.ini"
        set temp     $filename.new.$timestamp
        set backup   $filename.bak.$timestamp
        
        set in  [open $filename r]
        set out [open $temp     w]

        # line-by-line, read the original file
        while { [gets $in line] != -1 } {
            # Write the line
            puts $out $line
            
            if { [string equal $line "\[Library\]"] } {
                puts $out "$lib = $path\n"
            }
        }

        close $in
        close $out
        
        # move the new data to the proper filename
        file rename -force $filename $backup
        file rename -force $temp $filename 

    }    


} else {
    vmap -del test-vmap-bug
}
vdel -all -lib test-vmap-bug-lib

