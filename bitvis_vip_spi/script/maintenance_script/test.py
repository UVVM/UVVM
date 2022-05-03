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

    for files in os.listdir(sim_path):
        path = os.path.join(sim_path, files)
        try:
            shutil.rmtree(path)
        except:
            os.remove(path)


def create_config(spi_modes, data_widths, data_array_widths):
    config = []
    for spi_mode, data_width, data_array_width in product(spi_modes, data_widths, data_array_widths):
      config.append([str(spi_mode), str(data_width), str(data_array_width)])
    return config

print('Verify Bitvis VIP SPI')

cleanup('Removing any previous runs.')

hr = HDLRegression(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add testcase configurations
configs = create_config(spi_modes=range(0,4), data_widths=[8, 14, 23, 32], data_array_widths=[2, 4, 6, 8])
for config in configs:
    hr.add_generics(entity="spi_vvc_tb",
                         generics=["GC_SPI_MODE", config[0],"GC_DATA_WIDTH", config[1], "GC_DATA_ARRAY_WIDTH", config[2]])
#    hr.add_generics("spi_vvc_tb", ["GC_SPI_MODE", config[0],"GC_DATA_WIDTH", config[1], "GC_DATA_ARRAY_WIDTH", config[2]])

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

hr.start(regression_mode=True, gui_mode=False)

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