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


print("Verify Bitvis VIP Avalon MM")

cleanup("Removing any previous runs.")

hr = HDLRegression()

# Add util, fw and VIP Scoreboard
hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

# Add Avalon MM VIP
hr.add_files("../../src/*.vhd", "bitvis_vip_avalon_mm")
hr.add_files("../../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_avalon_mm")

# Add TB/TH etc
hr.add_files("../../tb/maintenance_tb/*.vhd", "bitvis_vip_avalon_mm")

hr.add_files("../../tb/maintenance_tb/altera_files/altera/*.vhd", "altera")
hr.add_files("../../tb/maintenance_tb/altera_files/altera_mf/*.vhd", "altera_mf")
hr.add_files("../../tb/maintenance_tb/altera_files/220model/*.vhd", "lpm")

hr.add_generics(entity="avalon_mm_vvc_pipeline_tb",
                architecture=None,
                generics=["GC_DELTA_DELAYED_VVC_CLK", True])

hr.add_generics(entity="avalon_mm_vvc_pipeline_tb",
                architecture=None,
                generics=["GC_DELTA_DELAYED_VVC_CLK", False])

sim_options = None
simulator_name = hr.settings.get_simulator_name()
# Set simulator name and compile options
if simulator_name in ["MODELSIM", "RIVIERA"]:
    sim_options = "-t ps"
    com_options = ["-suppress", "1346,1246,1236", "-2008"]
    hr.set_simulator(simulator=simulator_name, com_options=com_options)
elif simulator_name == "GHDL":
    com_options = ["--ieee=standard", "--std=08", "-frelaxed-rules", "--warn-no-shared", "--warn-no-hide", "--warn-no-attribute"]
    com_options += ["-fsynopsys"] # Altera library requires Synopsys std_logic_unsigned library
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
