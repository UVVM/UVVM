import sys
# User specify HDLRegression install path:
sys.path.append('../../../hdlregression/')

# Import the HDLRegression module to the Python script:
from hdlregression import HDLRegression

# Define a HDLRegression item to access the HDLRegression functionality:
hr = HDLRegression()

# ------------ USER CONFIG START ---------------

# Add all .vhd files in the /src directory to library my_dut_lib:
hr.add_files("../../uvvm_util/src/*.vhd", "uvvm_util")
hr.add_files("../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hr.add_files("../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

hr.add_files("../src/*.vhd", "external_vip_apb")
hr.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "external_vip_apb")

# Add testbech file to library my_tb_lib:
hr.add_files("../tb/*.vhd", "my_tb_lib")

# ------------ USER CONFIG END ---------------
hr.start()