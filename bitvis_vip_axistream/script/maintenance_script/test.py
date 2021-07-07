import sys
import os
import shutil
from itertools import product


try:
    from hdlunit import HDLUnit
except:
    print('Unable to import HDLUnit module. See HDLUnit documentation for installation instructions.')
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
    if any(include_tuser): include_tuser = 1
    else: include_tuser = 0
    if any(use_setup_and_hold): use_setup_and_hold = 1
    else: use_setup_and_hold = 0

    for data_width, user_width, id_width, dest_width in product(data_widths, user_widths, id_widths, dest_widths):
      config.append([str(data_width), str(user_width), str(id_width), str(dest_width), str(include_tuser), str(use_setup_and_hold)])
    return config


print('Verify Bitvis VIP AXI Stream')

cleanup('Removing any previous runs.')

hdlunit = HDLUnit(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hdlunit.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add testcase configurations
configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[True, False])
for config in configs:
    hdlunit.add_generics(entity="axistream_simple_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])  


configs = create_config(data_widths=[8, 16, 24, 64, 128], user_widths=[8], id_widths=[8], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[True])
for config in configs:
    hdlunit.add_generics(entity="axistream_vvc_simple_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

configs = create_config(data_widths=[32], user_widths=[1, 5], id_widths=[3], dest_widths=[1], include_tuser=[True], use_setup_and_hold=[False])
for config in configs:
    hdlunit.add_generics(entity="axistream_vvc_simple_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

hdlunit.add_generics(entity="axistream_vvc_simple_tb",
                     generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 1, "GC_ID_WIDTH", 1, "GC_DEST_WIDTH", 1, "GC_INCLUDE_TUSER", False, "GC_USE_SETUP_AND_HOLD", True])


configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[False, True])
for config in configs:
    hdlunit.add_generics(entity="axistream_bfm_slv_array_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[False, True])
for config in configs:
    hdlunit.add_generics(entity="axistream_vvc_slv_array_tb",
                         generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], "GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])

hdlunit.add_generics(entity="axistream_multiple_vvc_tb",
                     generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 1, "GC_ID_WIDTH", 1, "GC_DEST_WIDTH", 1, "GC_INCLUDE_TUSER", True, "GC_USE_SETUP_AND_HOLD", True])

hdlunit.add_generics(entity="axistream_multiple_vvc_tb",
                     generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 8, "GC_ID_WIDTH", 7, "GC_DEST_WIDTH", 4, "GC_INCLUDE_TUSER", True, "GC_USE_SETUP_AND_HOLD", False])

# Add src files
hdlunit.add_files("../../src/*.vhd", "bitvis_vip_axistream")
hdlunit.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_axistream")

# Add TB/TH
hdlunit.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_axistream")

hdlunit.start(regression_mode=True, gui_mode=False)

num_failing_tests = hdlunit.get_num_fail_tests()
num_passing_tests = hdlunit.get_num_pass_tests()

# No tests run error
if num_passing_tests == 0:
    sys.exit(1)
# Remove output only if OK
if hdlunit.check_run_results(exp_fail=0) is True:
    cleanup('Removing simulation output')
# Return number of failing tests
sys.exit(num_failing_tests)
