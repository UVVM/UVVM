import sys
# sys.path.append('../../hdlunit')

from hdlunit import HDLUnit

# Define a HDLUnit item to access the HDLUnit functionality:
hdlunit = HDLUnit()

# ------------ USER CONFIG START ---------------
hdlunit.set_simulator("MODELSIM")

# Add UVVM files:
hdlunit.add_files("../../uvvm_util/src/*.vhd", "uvvm_util")
hdlunit.add_files("../../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
hdlunit.add_files("../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")
#  - UART VIP
hdlunit.add_files("../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
hdlunit.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
#  - SBI VIP
hdlunit.add_files("../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
hdlunit.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
#  - Clock Generator VVC
hdlunit.add_files("../../bitvis_vip_clock_generator/src/*.vhd", "bitvis_vip_clock_generator")
hdlunit.add_files("../../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_clock_generator")

# Add DUT files
hdlunit.add_files("../../bitvis_uart/src/*.vhd", "bitvis_uart")

# Add demo testbench files
hdlunit.add_files("../*.vhd", "uvvm_demo")

# Add generics
hdlunit.add_generics("uvvm_demo_tb", ["GC_TEST", "test_randomise"])
hdlunit.add_generics("uvvm_demo_tb", ["GC_TEST", "test_functional_coverage"])

# ------------ USER CONFIG END ---------------
hdlunit.start()
