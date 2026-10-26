import sys
import os
import shutil
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print('Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.')
    sys.exit(1)


# Clean the sim directory
def cleanup(msg='Cleaning up...'):
    print(msg)
    sim_path = os.getcwd()
    # Check if the current directory is 'sim'
    if os.path.basename(sim_path) == 'sim':
        for files in os.listdir(sim_path):
            path = os.path.join(sim_path, files)
            try:
                shutil.rmtree(path)
            except:
                os.remove(path)
    else:
        print('Current directory is not "sim". Skipping cleanup.')


# Create testbench configuration with TB generics
def create_config(spi_modes, data_widths, data_array_widths):
    config = []
    for spi_mode, data_width, data_array_width in product(spi_modes, data_widths, data_array_widths):
        config.append([str(spi_mode), str(data_width), str(data_array_width)])
    return config


print('Verify Bitvis VIP SPI')

cleanup('Removing any previous runs.')

hr = HDLRegression()

# Set simulator name and options
lib_options = None
sim_options = None
simulator_name = hr.settings.get_simulator_name()
if simulator_name == "MODELSIM":
    sim_options = "-t ps"
elif simulator_name == "GHDL":
    # Opencores library requires Synopsys std_logic_unsigned library
    com_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "-Wall", "--warn-no-shared", "--warn-no-hide", "--warn-no-delayed-checks", "-fsynopsys"]
    lib_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "--warn-no-shared", "--warn-no-hide", "-fsynopsys"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
# Add SBI VIP
hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
# Add SPI VIP
hr.add_files("../../src/*.vhd", "bitvis_vip_spi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_spi")
# Add TB/TH
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_spi")
# Add TB dependencies
hr.add_files("../../tb/maintenance_tb/spi_pif.vhd", "bitvis_vip_spi")
hr.add_files("../../tb/maintenance_tb//spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_common_pkg.vhd", "bitvis_vip_spi", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_master.vhd", "bitvis_vip_spi", com_options=lib_options)
hr.add_files("../../tb/maintenance_tb/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_slave.vhd", "bitvis_vip_spi", com_options=lib_options)

# Add testcase configurations
configs = create_config(spi_modes=range(0, 4), data_widths=[8, 23, 32], data_array_widths=[2, 8])
for config in configs:
    hr.add_generics(entity="spi_vvc_tb", generics=["GC_SPI_MODE", config[0], "GC_DATA_WIDTH", config[1], "GC_DATA_ARRAY_WIDTH", config[2]])

hr.start(sim_options=sim_options)

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')

# Run alternative simulation scripts
if simulator_name == "MODELSIM" or simulator_name == "RIVIERA-PRO":
    print('\nVerify .do scripts...')
    (ret_txt, ret_code) = hr.run_command(["vsim", "-c", "-do", "do ../script/compile_src.do ../../uvvm_util ../../uvvm_util/sim; exit"], False)
    (ret_txt, ret_code) = hr.run_command(["vsim", "-c", "-do", "do ../script/compile_bfm.do; exit"], False)
    if ret_code == 0:
        print("TCL script test completed")
        if hr.check_run_results(exp_fail=0) is True:
            cleanup('Removing simulation output\n')
    else:
        print(ret_txt)
        num_failing_tests += 1

# Return number of failing tests
sys.exit(num_failing_tests)
