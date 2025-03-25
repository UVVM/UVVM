import sys
import os
import shutil
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print("Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.")
    sys.exit(1)


def cleanup(msg="Cleaning up..."):
    print(msg)

    sim_path = os.getcwd()

    # Check if the current directory is 'sim'
    if os.path.basename(sim_path) == "sim":
        for files in os.listdir(sim_path):
            path = os.path.join(sim_path, files)
            try:
                shutil.rmtree(path)
            except:
                os.remove(path)
    else:
        print('Current directory is not "sim". Skipping cleanup.')


print("Verify Bitvis VIP Ethernet")

cleanup("Removing any previous runs.")

hr = HDLRegression()

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add Ethernet VIP
hr.add_files("../../src/*.vhd", "bitvis_vip_ethernet")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_ethernet")

# Add HVVC Bridge VIP
hr.add_files("../../../bitvis_vip_hvvc_to_vvc_bridge/src/*.vhd", "bitvis_vip_hvvc_to_vvc_bridge")

# Add GMII VIP
hr.add_files("../../../bitvis_vip_gmii/src/*.vhd", "bitvis_vip_gmii")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_gmii")

# Add SBI VIP
hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")

# Add testbench and harness
hr.add_files("../../tb/*.vhd", "bitvis_vip_ethernet")
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_ethernet")

# Add TB dependencies
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/XilinxCoreLib/*.vhd", "xilinxcorelib")
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/unisims/*.vhd", "unisim")
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/unisims/primitive/*.vhd", "unisim")
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/*.vhd", "mac_master")
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/*.vhd", "mac_master")
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/generic/*.vhd", "mac_master")
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/ipcore_dir/*.vhd", "mac_master")

sim_options = None
com_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ps"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
elif simulator_name == "GHDL":
    com_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "--warn-no-shared", "--warn-no-hide", "--warn-no-attribute"]
    com_options += ["-fsynopsys"] # Xilinx library requires Synopsys std_logic_unsigned library

hr.set_simulator(simulator=simulator_name, com_options=com_options)
hr.start(sim_options=sim_options)

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup("Removing simulation output")
# Return number of failing tests
sys.exit(num_failing_tests)
