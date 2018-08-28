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

# Compile IRQC
vlib bitvis_irqc
vcom -2008 -dbg -work bitvis_irqc ../src/irqc_pif_pkg.vhd
vcom -2008 -dbg -work bitvis_irqc ../src/irqc_pif.vhd
vcom -2008 -dbg -work bitvis_irqc ../src/irqc_core.vhd
vcom -2008 -dbg -work bitvis_irqc ../src/irqc.vhd

# Compile uvvm_util
vlib uvvm_util
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/types_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/adaptations_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/string_methods_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/protected_types_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/hierarchy_linked_list_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/alert_hierarchy_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/license_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/methods_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/bfm_common_pkg.vhd
vcom -2008 -dbg -work uvvm_util ../../uvvm_util/src/uvvm_util_context.vhd

# Compile VIP SBI (just BFM for now)
vlib bitvis_vip_sbi
vcom -2008 -dbg -work bitvis_vip_sbi ../../bitvis_vip_sbi/src/sbi_bfm_pkg.vhd

# Compile TB
vcom -2008 -dbg -relax -work bitvis_irqc ../tb/irqc_tb.vhd


# Simulate TB
vsim bitvis_irqc.irqc_tb
run -all
