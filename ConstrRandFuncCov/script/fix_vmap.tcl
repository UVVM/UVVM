#========================================================================================================================
# Copyright (c) 2017 by Bitvis AS.  All rights reserved.
# You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
# contact Bitvis AS <support@bitvis.no>.
#
# UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR
# OTHER DEALINGS IN UVVM.
#========================================================================================================================

#
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

