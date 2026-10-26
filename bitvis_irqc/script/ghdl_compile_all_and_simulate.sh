#!/bin/bash

#==================================================================
# This script has been tested with GHDL version 0.37 and 2.0.0-dev
#==================================================================
echo "\nThis script has been tested with GHDL version 0.37 and 2.0.0-dev\n"

# Compiling UVVM Util
echo "Compiling UVVM Utility Library..."
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/types_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/adaptations_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/string_methods_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/protected_types_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/global_signals_and_shared_variables_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/hierarchy_linked_list_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/alert_hierarchy_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/license_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/methods_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/bfm_common_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/generic_queue_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/data_queue_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/data_fifo_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/data_stack_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/dummy_rand_extension_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/rand_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/dummy_func_cov_extension_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/association_list_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/func_cov_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=uvvm_util ../../uvvm_util/src/uvvm_util_context.vhd

# Compiling Bitvis VIP SBI BFM
echo "Compiling Bitvis VIP SBI BFM..."
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=bitvis_vip_sbi ../../bitvis_vip_sbi/src/sbi_bfm_pkg.vhd

# Compiling Bitvis IRQC
echo "Compiling Bitvis IRQC..."
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=bitvis_irqc ../src/irqc_pif_pkg.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=bitvis_irqc ../src/irqc_pif.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=bitvis_irqc ../src/irqc_core.vhd
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=bitvis_irqc ../src/irqc.vhd

# Compiling demo TB
echo "Compiling IRQC demo TB..."
ghdl -a --std=08 -frelaxed-rules -Wno-hide -Wno-shared --work=bitvis_irqc ../tb/irqc_demo_tb.vhd

# Running simulations
echo "Starting simulations..."
ghdl -e --std=08 -frelaxed-rules --work=bitvis_irqc irqc_demo_tb
ghdl -r --std=08 -frelaxed-rules --work=bitvis_irqc irqc_demo_tb


