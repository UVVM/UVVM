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


# Create testbench configuration with TB generics
def create_config(channel_widths, data_widths, error_widths):
    config = []
    for channel_width, data_width, error_width in product(channel_widths, data_widths, error_widths):
        config.append([str(channel_width),
                       str(data_width),
                       str(error_width)])
    return config


print('Verify Bitvis VIP Avalon ST')

cleanup('Removing any previous runs.')

hr = HDLRegression()

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Setup BFM TB test generics
for config in create_config(channel_widths=[7], data_widths=[8], error_widths=[1]):
    hr.add_generics(entity="avalon_st_bfm_tb",
                    generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
for config in create_config(channel_widths=[8], data_widths=[16], error_widths=[1]):
    hr.add_generics(entity="avalon_st_bfm_tb",
                    generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
for config in create_config(channel_widths=[8], data_widths=[32], error_widths=[1]):
    hr.add_generics(entity="avalon_st_bfm_tb",
                    generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])

# Setup VVC TB test generics
for config in create_config(channel_widths=[7], data_widths=[8], error_widths=[1]):
    hr.add_generics(entity="avalon_st_vvc_tb",
                    generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
for config in create_config(channel_widths=[8], data_widths=[16], error_widths=[1]):
    hr.add_generics(entity="avalon_st_vvc_tb",
                    generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
for config in create_config(channel_widths=[8], data_widths=[32], error_widths=[1]):
    hr.add_generics(entity="avalon_st_vvc_tb",
                    generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])

# Add Avalon ST VIP
hr.add_files("../../src/*.vhd", "bitvis_vip_avalon_st")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_avalon_st")

# Add TB/TH
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_avalon_st")

sim_options    = None
global_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ns"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)
elif simulator_name == "NVC":
    global_options = ["--stderr=error", "--messages=compact", "-M64m", "-H512m"]

hr.start(sim_options=sim_options, global_options=global_options)

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
