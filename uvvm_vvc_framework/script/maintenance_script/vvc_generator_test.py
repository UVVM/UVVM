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


print('Verify VVC Generator code')

hr = HDLRegression(simulator='modelsim')

# Add util, fw and VIP Scoreboard
hr.add_files('../../sim/output/*.vhd', 'vvc_generator_lib')
hr.add_files("../../src_target_dependent/*.vhd", "vvc_generator_lib")

hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

success = hr.start(sim_options="-t ns")

# Return number of failing tests
sys.exit(success)
