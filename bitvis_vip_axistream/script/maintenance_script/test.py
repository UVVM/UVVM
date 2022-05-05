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

def create_config(data_widths, user_widths, id_widths, dest_widths, include_tuser=False, use_setup_and_hold=False):
    config = []

    # Need to convert boolean to int - and handle lists
    if isinstance(include_tuser, list):
        for idx, item in enumerate(include_tuser):
            include_tuser[idx] = 1 if item is True else 0
    else:
        include_tuser = 1 if include_tuser is True else 0
    # Need to convert boolean to int - and handle lists
    if isinstance(use_setup_and_hold, list):
        for idx, item in enumerate(use_setup_and_hold):
            use_setup_and_hold[idx] = 1 if item is True else 0
    else:
        use_setup_and_hold = 1 if use_setup_and_hold is True else 0
    
    for data_width, user_width, id_width, dest_width, tuser, setup_and_hold in product(data_widths, user_widths, id_widths, dest_widths, include_tuser, use_setup_and_hold):
      config.append([str(data_width), str(user_width), str(id_width), str(dest_width), str(tuser), str(setup_and_hold)])
    return config


print('Verify Bitvis VIP AXI Stream')

cleanup('Removing any previous runs.')

hr = HDLRegression(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add testcase configurations
configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[True, False])
for config in configs:
    hr.add_generics(entity="axistream_simple_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])  


configs = create_config(data_widths=[8, 16, 24, 64, 128], user_widths=[8], id_widths=[8], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[True])
for config in configs:
    hr.add_generics(entity="axistream_vvc_simple_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

configs = create_config(data_widths=[32], user_widths=[1, 5], id_widths=[3], dest_widths=[1], include_tuser=[True], use_setup_and_hold=[False])
for config in configs:
    hr.add_generics(entity="axistream_vvc_simple_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

hr.add_generics(entity="axistream_vvc_simple_tb",
                     generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 1, "GC_ID_WIDTH", 1, "GC_DEST_WIDTH", 1, "GC_INCLUDE_TUSER", False, "GC_USE_SETUP_AND_HOLD", True])


configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[False, True])
for config in configs:
    hr.add_generics(entity="axistream_bfm_slv_array_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[False, True])
for config in configs:
    hr.add_generics(entity="axistream_vvc_slv_array_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

hr.add_generics(entity="axistream_multiple_vvc_tb",
                     generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 1, "GC_ID_WIDTH", 1, "GC_DEST_WIDTH", 1, "GC_INCLUDE_TUSER", True, "GC_USE_SETUP_AND_HOLD", True])

hr.add_generics(entity="axistream_multiple_vvc_tb",
                     generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 8, "GC_ID_WIDTH", 7, "GC_DEST_WIDTH", 4, "GC_INCLUDE_TUSER", True, "GC_USE_SETUP_AND_HOLD", False])

# Add src files
hr.add_files("../../src/*.vhd", "bitvis_vip_axistream")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_axistream")

# Add TB/TH
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_axistream")


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
