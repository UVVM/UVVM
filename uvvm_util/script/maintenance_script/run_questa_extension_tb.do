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
#--------------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------
# Check if Questa extension libraries are present in uvvm_util/src. 
# If not, copy them in from misc directory
#-------------------------------------------------------------------
quietly set dst_dir "../src"
quietly set src_dir "../../misc/vendor_extensions/questa_one_2026.1"

quietly set filename "questa_rand_extension_pkg.vhd"
quietly set dst_file [file join $dst_dir $filename]
quietly set src_file [file join $src_dir $filename]
if {![file exists $dst_file]} {
    echo "Copying $filename into $dst_dir"
    file copy -force $src_file $dst_file
}

quietly set filename "questa_func_cov_extension_pkg.vhd"
quietly set dst_file [file join $dst_dir $filename]
quietly set src_file [file join $src_dir $filename]
if {![file exists $dst_file]} {
    echo "Copying $filename into $dst_dir"
    file copy -force $src_file $dst_file
}

#-----------------------------------------------------------
# Get list of uvvm_util source files from compile_order.txt
#-----------------------------------------------------------
quietly set fp [open "../script/compile_order.txt" r]
quietly set file_data [read $fp]
close $fp

#-------------------------
# Compile uvvm_util files
#-------------------------
quietly set idx 0
quietly set compdirectives "-quiet -suppress 1346,1246,1236 -2008 -work uvvm_util"
foreach item $file_data {
  if {$idx > 2} {
    if {$item eq "../src/dummy_rand_extension_pkg.vhd"} {
        set item "../src/questa_rand_extension_pkg.vhd"
    }
    if {$item eq "../src/dummy_func_cov_extension_pkg.vhd"} {
        set item "../src/questa_func_cov_extension_pkg.vhd"
    }
    echo "eval vcom $compdirectives $item"
    eval vcom $compdirectives [list $item]
  }
  incr idx 1
}

#-----------------------------------------------------------------------
# Compile testbench files and run simulation
#-----------------------------------------------------------------------
vcom -2008 ../tb/maintenance_tb/questa_extension_tb.vhd
qopt -o opt questa_extension_tb qoneRandLib.RandLib -GGC_EXTENSIONS_ENABLED=TRUE -designfile designfile  -noincr -access=r+/.
qsim -c opt -do "run -all"

#-----------------------------------------------------------------------
# Save coverage data to UCDB and generate coverage report
#-----------------------------------------------------------------------
coverage save -cvg test.ucdb
vcover report -cvg -details -output func_cov_test_report.txt test.ucdb

exit
