#!/bin/bash
############################################################################
# This script will run through all DIPs, VIPs and UVVM repositories and
# run the internal_run.py simulation scripts. The outcome of the simulations
# will be written to status.txt
#
# By Andre Firing, Bitvis AS
############################################################################

function simulate {
  echo Running $1
  cd ../$1/sim/
  echo $'\r'  >> ../../regresion_test/status.txt
  echo $1 $'\r'  >> ../../regresion_test/status.txt
  rm -rf vunit_out
  py internal_run.py -p8
  status=$?
  if [ $status -eq 0 ]; then
    echo "modelsim : PASS"$'\r'  >> ../../regresion_test/status.txt
  else
    echo "modelsim : FAILED"$'\r'  >> ../../regresion_test/status.txt
  fi
  rm -rf vunit_out
  py internal_run_riviera_pro.py
  status=$?
  if [ $status -eq 0 ]; then
    echo "riviera pro : PASS"$'\r'  >> ../../regresion_test/status.txt
  else
    echo "riviera pro : FAILED"$'\r'  >> ../../regresion_test/status.txt
  fi
  rm -rf vunit_out
  cd ../../regresion_test
}

# Delete the status.txt file
rm -rf status.txt
echo "Starting testing at " $(date +%T) $'\r' >> status.txt

simulate bitvis_uart
simulate bitvis_irqc
simulate bitvis_vip_sbi
simulate bitvis_vip_uart
simulate bitvis_vip_axilite
simulate bitvis_vip_axistream
simulate bitvis_vip_avalon_mm
simulate bitvis_vip_i2c
simulate bitvis_vip_spi
simulate bitvis_vip_gpio
simulate bitvis_vip_clock_generator
simulate bitvis_vip_scoreboard
simulate uvvm_util
simulate uvvm_vvc_framework

echo "Ending test at " $(date +%T) >> status.txt