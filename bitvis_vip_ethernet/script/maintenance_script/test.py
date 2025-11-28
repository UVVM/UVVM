import sys
import os
import shutil
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print("Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.")
    sys.exit(1)


# Clean the sim directory
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

# Set simulator name and options
lib_options = None
sim_options = None
simulator_name = hr.settings.get_simulator_name()
if simulator_name == "MODELSIM":
    sim_options = "-t ps"
elif simulator_name == "GHDL":
    # Altera library requires Synopsys std_logic_unsigned library
    com_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "-Wall", "--warn-no-shared", "--warn-no-hide", "--warn-no-delayed-checks", "-fsynopsys"]
    lib_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "--warn-no-shared", "--warn-no-hide", "-fsynopsys"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)

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
# Add TB/TH
hr.add_files("../../tb/*.vhd", "bitvis_vip_ethernet")
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_ethernet")
# The testbench below fails with NVC 1.16.0 due to wrong data coming out ethernet_with_fifos.tx_fifo.ethernet_mac_tx_fifo_xilinx (external IP)
# Both Modelsim and GHDL work fine so this is most likely an NVC issue
if simulator_name == "NVC":
    hr.remove_file("../../tb/maintenance_tb/ethernet_gmii_mac_master_tb.vhd", "bitvis_vip_ethernet")
# Add TB dependencies
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/XilinxCoreLib/*.vhd", "xilinxcorelib", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/unisims/*.vhd", "unisim", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/unisims/primitive/*.vhd", "unisim", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/*.vhd", "mac_master", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/*.vhd", "mac_master", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/generic/*.vhd", "mac_master", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/ethernet_mac-master/xilinx/ipcore_dir/*.vhd", "mac_master", com_options=lib_options)

hr.start(sim_options=sim_options)

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup("Removing simulation output")

# Run alternative simulation scripts
if simulator_name == "MODELSIM" or simulator_name == "RIVIERA-PRO":
    print('\nVerify .do scripts...')
    (ret_txt, ret_code) = hr.run_command(["vsim", "-c", "-do", "do ../script/compile_all_and_simulate.do; exit"], False)
    if ret_code == 0:
        print("TCL script test completed")
        if hr.check_run_results(exp_fail=0) is True:
            cleanup('Removing simulation output\n')
    else:
        print(ret_txt)
        num_failing_tests += 1

# Return number of failing tests
sys.exit(num_failing_tests)
