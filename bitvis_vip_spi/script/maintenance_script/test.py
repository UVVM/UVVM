import sys
import os
import shutil
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print('Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.')
    sys.exit(1)


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


def create_config(spi_modes, data_widths, data_array_widths):
    config = []
    for spi_mode, data_width, data_array_width in product(spi_modes, data_widths, data_array_widths):
        config.append([str(spi_mode), str(data_width), str(data_array_width)])
    return config


print('Verify Bitvis VIP SPI')

cleanup('Removing any previous runs.')

hr = HDLRegression()

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add testcase configurations
configs = create_config(spi_modes=range(0, 4), data_widths=[8, 23, 32], data_array_widths=[2, 8])
for config in configs:
    hr.add_generics(entity="spi_vvc_tb",
                    generics=["GC_SPI_MODE", config[0], "GC_DATA_WIDTH", config[1], "GC_DATA_ARRAY_WIDTH", config[2]])

# Add SPI VIP
hr.add_files("../../src/*.vhd", "bitvis_vip_spi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_spi")

# Add TB/TH and dependencies
hr.add_files("../../tb/maintenance_tb//spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_common_pkg.vhd", "bitvis_vip_spi")
hr.add_files("../../tb/maintenance_tb/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_master.vhd", "bitvis_vip_spi")
hr.add_files("../../tb/maintenance_tb/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_slave.vhd", "bitvis_vip_spi")
hr.add_files("../../tb/maintenance_tb/spi_pif.vhd", "bitvis_vip_spi")
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_spi")

hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")

sim_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ns"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)
elif simulator_name == "GHDL":
    com_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "--warn-no-shared", "--warn-no-hide", "--warn-no-attribute"]
    com_options += ["-fsynopsys"] # Opencores library requires Synopsys std_logic_unsigned library
    hr.set_simulator(simulator=simulator_name, com_options=com_options)

hr.start(sim_options=sim_options)

num_failing_tests = hr.get_num_fail_tests()
num_passing_tests = hr.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hr.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')
# Return number of failing tests
sys.exit(num_failing_tests)
