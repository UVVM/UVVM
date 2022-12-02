#
# Copyright (c) 2022 by HDLRegression Authors.  All rights reserved.
# Licensed under the MIT License; you may not use this file except in compliance with the License.
# You may obtain a copy of the License at https://opensource.org/licenses/MIT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#
# HDLRegression AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN HDLRegression.
#


import shutil
import os
import platform
import time
import sys

from hdlregression import HDLRegression
from itertools import product

# Counters to accumulate results from individual runs
num_pass = 0
num_fail = 0
num_minor = 0

failing_tests_list = []
num_tests_run = 0

class TestcaseError(Exception):
    def __init__(self, expected, actual):
        self.exp = expected
        self.act = actual


class TestcaseRunError(TestcaseError):
    def __str__(self):
        if self.exp != self.act:
            return f"Number of tests run: expected={self.exp}, actual={self.act}."
        return ''


class TestcasePassError(TestcaseError):
    def __str__(self):
        if self.exp != self.act:
            return f"Number of tests pass: expected={self.exp}, actual={self.act}."
        return ''


class TestcasePassMinorError(TestcaseError):
    def __str__(self):
        if self.exp != self.act:
            return f"Number of tests pass with minor: expected={self.exp}, actual={self.act}."
        return ''


class TestcaseFailError(TestcaseError):
    def __str__(self):
        if self.exp != self.act:
            return f"Number of tests fail: expected={self.exp}, actual={self.act}."
        return ''


def passing():
    ''' Using the ANSI Shadow font from 
    http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=PASS%20w%2Fminor '''
    print('''
██████╗  █████╗ ███████╗███████╗
██╔══██╗██╔══██╗██╔════╝██╔════╝
██████╔╝███████║███████╗███████╗
██╔═══╝ ██╔══██║╚════██║╚════██║
██║     ██║  ██║███████║███████║
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝''')


def passing_with_minor():
    print('''
██████╗  █████╗ ███████╗███████╗    ██╗    ██╗    ██╗███╗   ███╗██╗███╗   ██╗ ██████╗ ██████╗ 
██╔══██╗██╔══██╗██╔════╝██╔════╝    ██║    ██║   ██╔╝████╗ ████║██║████╗  ██║██╔═══██╗██╔══██╗
██████╔╝███████║███████╗███████╗    ██║ █╗ ██║  ██╔╝ ██╔████╔██║██║██╔██╗ ██║██║   ██║██████╔╝
██╔═══╝ ██╔══██║╚════██║╚════██║    ██║███╗██║ ██╔╝  ██║╚██╔╝██║██║██║╚██╗██║██║   ██║██╔══██╗
██║     ██║  ██║███████║███████║    ╚███╔███╔╝██╔╝   ██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝██║  ██║
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝     ╚══╝╚══╝ ╚═╝    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  
╚═╝''')


def failing():
    print('''
███████╗ █████╗ ██╗██╗     
██╔════╝██╔══██╗██║██║     
█████╗  ███████║██║██║     
██╔══╝  ██╔══██║██║██║     
██║     ██║  ██║██║███████╗
╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝ ''')


def os_adjust_path(path) -> str:
    if platform.system().lower() == "windows":
        return path.replace('\\', '//')
    else:
        return path.replace('\\', '\\\\')


def update_tests_run(numb):
    global num_tests_run
    num_tests_run += numb


def check_result(exp_pass, exp_fail, exp_minor, hr):
    # Counters to accumulate results from individual runs
    global num_pass
    global num_fail
    global failing_tests_list
    global num_minor

    actual_run = hr.get_num_tests_run()
    actual_pass = hr.get_num_pass_tests()
    actual_fail = hr.get_num_fail_tests()
    actual_minor = hr.get_num_pass_with_minor_alert_tests()

    try:
        raise TestcaseRunError(actual=actual_run, expected=(exp_pass + exp_fail))
    except TestcaseRunError as e:
        if e:
            print(e)
    try:
        raise TestcasePassError(actual=actual_pass, expected=exp_pass)
    except TestcasePassError as e:
        if e:
            print(e)
    try:
        raise TestcaseFailError(actual=actual_fail, expected=exp_fail)
    except TestcaseFailError as e:
        if e:
            print(e)
    try:
        raise TestcasePassMinorError(actual=actual_minor, expected=exp_minor)
    except TestcasePassMinorError as e:
        if e:
            print(e)

    passing_tests, failing_tests = hr.get_results()
    
    for test in failing_tests:
        failing_tests_list.append(test)
    num_pass += hr.get_num_pass_tests()
    num_fail += hr.get_num_fail_tests()
    num_minor += hr.get_num_pass_with_minor_alert_tests()

    update_tests_run(actual_run)

    if (actual_pass == exp_pass) and (actual_fail == exp_fail):
        if actual_minor > 0:
            passing_with_minor()
        else:
            passing()
    else:
        failing()
        
    


def clear_sim_folder():
    if os.path.isdir('./hdlregression'):
        shutil.rmtree('./hdlregression')


def get_sim_options(hr):
  if hr.settings.get_simulator_name() == 'MODELSIM':
    return '-t ps'
  else:
    return None


def add_uvvm_basic_files(hr):
    hr.add_files("../uvvm_util/src/*.vhd", "uvvm_util")
    hr.add_files("../uvvm_vvc_framework/src/*.vhd", "uvvm_vvc_framework")
    hr.add_files("../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")


def print_test_name(name):
    print("\n%s" % ("#"*80))
    print(">")
    print('> %s' %(name))
    print(">")
    print("%s" % ("#"*80))


def test_bitvis_uart():
    clear_sim_folder()
    print_test_name("UART DUT")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add other VIPs in the TB
    #  - SBI VIP
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    #  - UART VIP
    hr.add_files("../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
    #  - Clock Generator VVC
    hr.add_files("../bitvis_vip_clock_generator/src/*.vhd", "bitvis_vip_clock_generator")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_clock_generator")
    # Add DUT
    hr.add_files("../bitvis_uart/src/*.vhd", "bitvis_uart")
    # Add TB/TH
    hr.add_files("../bitvis_uart/tb/maintenance_tb/*.vhd", "bitvis_uart")
    hr.add_files("../bitvis_uart/tb/*.vhd", "bitvis_uart")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=9, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_irqc():
    clear_sim_folder()
    print_test_name("IRQC DUT")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add other VIPs in the TB
    #  - SBI VIP
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    # Add DUT
    hr.add_files("../bitvis_irqc/src/*.vhd", "bitvis_irqc")
    # Add TB/TH
    hr.add_files("../bitvis_irqc/tb/*.vhd", "bitvis_irqc")
    hr.add_files("../bitvis_irqc/tb/maintenance_tb/*.vhd", "bitvis_irqc")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=2, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_avalon_mm():
    clear_sim_folder()
    print_test_name("Avalon MM VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add Avalon MM VIP
    hr.add_files("../bitvis_vip_avalon_mm/src/*.vhd", "bitvis_vip_avalon_mm")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_avalon_mm")
    # Add TB/TH etc
    hr.add_files("../bitvis_vip_avalon_mm/tb/maintenance_tb/*.vhd", "bitvis_vip_avalon_mm")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=4, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_avalon_st():

    # Create testbench configuration with TB generics
    def create_config(channel_widths, data_widths, error_widths):
        config = []
        for channel_width, data_width, error_width in product(channel_widths, data_widths, error_widths):
            config.append([str(channel_width),
                           str(data_width),
                           str(error_width)])
        return config

    clear_sim_folder()
    print_test_name("Avalon ST VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Setup BFM TB test generics
    created_tests = 0
    for config in create_config(channel_widths=[7], data_widths=[8], error_widths=[1]):
        hr.add_generics(entity="avalon_st_bfm_tb",
                             generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
        created_tests += 1

    for config in create_config(channel_widths=[8], data_widths=[16], error_widths=[1]):
        hr.add_generics(entity="avalon_st_bfm_tb",
                             generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
        created_tests += 1

    for config in create_config(channel_widths=[8], data_widths=[32], error_widths=[1]):
        hr.add_generics(entity="avalon_st_bfm_tb",
                             generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
        created_tests += 1

    # Setup VVC TB test generics
    for config in create_config(channel_widths=[7], data_widths=[8], error_widths=[1]):
        hr.add_generics(entity="avalon_st_vvc_tb",
                             generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
        created_tests += 1

    for config in create_config(channel_widths=[8], data_widths=[16], error_widths=[1]):
        hr.add_generics(entity="avalon_st_vvc_tb",
                             generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
        created_tests += 1


    for config in create_config(channel_widths=[8], data_widths=[32], error_widths=[1]):
        hr.add_generics(entity="avalon_st_vvc_tb",
                             generics=["GC_CHANNEL_WIDTH", config[0], "GC_DATA_WIDTH", config[1], "GC_ERROR_WIDTH", config[2]])
        created_tests += 1

    created_tests = created_tests * 3 # 3 sequencer testcases in each testbench.

    # Add Avalon ST VIP
    hr.add_files("../bitvis_vip_avalon_st/src/*.vhd", "bitvis_vip_avalon_st")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_avalon_st")
    # Add TB/TH
    hr.add_files("../bitvis_vip_avalon_st/tb/maintenance_tb/*.vhd", "bitvis_vip_avalon_st")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=created_tests, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_axi():
    clear_sim_folder()
    print_test_name("AXI VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add Avalon AXI VIP
    hr.add_files("../bitvis_vip_axi/src/*.vhd", "bitvis_vip_axi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_axi")
    # Add TB/TH
    hr.add_files("../bitvis_vip_axi/tb/maintenance_tb/*.vhd", "bitvis_vip_axi")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=2, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_axilite():
    clear_sim_folder()
    print_test_name("AXI-Lite VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add Avalon AXI VIP
    hr.add_files("../bitvis_vip_axilite/src/*.vhd", "bitvis_vip_axilite")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_axilite")
    # Add TB/TH
    hr.add_files("../bitvis_vip_axilite/tb/maintenance_tb/*.vhd", "bitvis_vip_axilite")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=2, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_axistream():

    # Create testbench configuration with TB generics
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

        for data_width, user_width, id_width, dest_width, tuser, setup_and_hold in product(data_widths, user_widths, id_widths, dest_widths, include_tuser, 
use_setup_and_hold):
          config.append([str(data_width), str(user_width), str(id_width), str(dest_width), str(tuser), str(setup_and_hold)])
        return config

    clear_sim_folder()
    print_test_name("AXI Stream VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)

    # Add testcase configurations
    created_testcases = 0
    configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[True, False])
    for config in configs:
        hr.add_generics(entity="axistream_simple_tb",
                             generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], 
"GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])
        created_testcases += 1

    configs = create_config(data_widths=[8, 16, 24, 64, 128], user_widths=[8], id_widths=[8], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[True])
    for config in configs:
        hr.add_generics(entity="axistream_vvc_simple_tb",
                             generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], 
"GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])
        created_testcases += 1

    configs = create_config(data_widths=[32], user_widths=[1, 5], id_widths=[3], dest_widths=[1], include_tuser=[True], use_setup_and_hold=[False])
    for config in configs:
        hr.add_generics(entity="axistream_vvc_simple_tb",
                             generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], 
"GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])
        created_testcases += 1

    hr.add_generics(entity="axistream_vvc_simple_tb",
                         generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 1, "GC_ID_WIDTH", 1, "GC_DEST_WIDTH", 1, "GC_INCLUDE_TUSER", False, 
"GC_USE_SETUP_AND_HOLD", True])
    created_testcases += 1

    configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[False], use_setup_and_hold=[False, True])
    for config in configs:
        hr.add_generics(entity="axistream_bfm_slv_array_tb",
                             generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], 
"GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])
        created_testcases += 1

    configs = create_config(data_widths=[32], user_widths=[8], id_widths=[7], dest_widths=[4], include_tuser=[True], use_setup_and_hold=[False, True])
    for config in configs:
        hr.add_generics(entity="axistream_vvc_slv_array_tb",
                             generics=["GC_DATA_WIDTH", config[0],"GC_USER_WIDTH", config[1], "GC_ID_WIDTH", config[2], "GC_DEST_WIDTH", config[3], 
"GC_INCLUDE_TUSER", config[4], "GC_USE_SETUP_AND_HOLD", config[5]])
        created_testcases += 1

    hr.add_generics(entity="axistream_multiple_vvc_tb",
                         generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 1, "GC_ID_WIDTH", 1, "GC_DEST_WIDTH", 1, "GC_INCLUDE_TUSER", True, 
"GC_USE_SETUP_AND_HOLD", True])
    created_testcases += 1

    hr.add_generics(entity="axistream_multiple_vvc_tb",
                         generics=["GC_DATA_WIDTH", 32, "GC_USER_WIDTH", 8, "GC_ID_WIDTH", 7, "GC_DEST_WIDTH", 4, "GC_INCLUDE_TUSER", True, 
"GC_USE_SETUP_AND_HOLD", False])
    created_testcases += 1

    # Add Avalon AXI VIP
    hr.add_files("../bitvis_vip_axistream/src/*.vhd", "bitvis_vip_axistream")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_axistream")
    # Add TB/TH
    hr.add_files("../bitvis_vip_axistream/tb/maintenance_tb/*.vhd", "bitvis_vip_axistream")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=created_testcases, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_clock_generator():
    clear_sim_folder()
    print_test_name("Clock Generator VIP")

    hr = HDLRegression(simulator='modelsim')

    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add Avalon AXI VIP
    hr.add_files("../bitvis_vip_clock_generator/src/*.vhd", "bitvis_vip_clock_generator")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_clock_generator")
    # Add TB/TH
    hr.add_files("../bitvis_vip_clock_generator/tb/maintenance_tb/*.vhd", "bitvis_vip_clock_generator")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=1, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_error_injection():
    clear_sim_folder()
    print_test_name("Error Injection VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add EI VIP
    hr.add_files("../bitvis_vip_error_injection/src/*.vhd", "bitvis_vip_error_injection")
    # Add TB/TH
    hr.add_files("../bitvis_vip_error_injection/tb/maintenance_tb/*.vhd", "bitvis_vip_error_injection")
    hr.add_files("../bitvis_vip_error_injection/tb/*.vhd", "bitvis_vip_error_injection")
    sim_options = "-t ns"
    hr.start(sim_options='-t ns')

    check_result(exp_pass=2, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_gmii():
    clear_sim_folder()
    print_test_name("GMII VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add GMII VIP
    hr.add_files("../bitvis_vip_gmii/src/*.vhd", "bitvis_vip_gmii")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_gmii")
    # Add TB/TH
    hr.add_files("../bitvis_vip_gmii/tb/maintenance_tb/*.vhd", "bitvis_vip_gmii")
    hr.add_files("../bitvis_vip_gmii/tb/*.vhd", "bitvis_vip_gmii")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=2, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_gpio():
    clear_sim_folder()
    print_test_name("GPIO VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add GPIO VIP
    hr.add_files("../bitvis_vip_gpio/src/*.vhd", "bitvis_vip_gpio")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_gpio")
    # Add TB/TH
    hr.add_files("../bitvis_vip_gpio/tb/maintenance_tb/*.vhd", "bitvis_vip_gpio")
    hr.add_files("../bitvis_vip_gpio/tb/*.vhd", "bitvis_vip_gpio")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=1, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_i2c():
    clear_sim_folder()
    print_test_name("I2C VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add I2C VIP
    hr.add_files("../bitvis_vip_i2c/src/*.vhd", "bitvis_vip_i2c")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_i2c")
    # Add TB/TH
    hr.add_files("../bitvis_vip_i2c/tb/maintenance_tb/*.vhd", "bitvis_vip_i2c")
    # Add TB dependencies
    hr.add_files("../bitvis_vip_i2c/tb/maintenance_tb/fpga_i2c_slave_github/*.vhd", "bitvis_vip_i2c")
    hr.add_files("../bitvis_vip_i2c/tb/maintenance_tb/i2c_opencores/trunk/rtl/vhdl/*.vhd", "bitvis_vip_i2c")
    # Add SBI VIP
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    # Add Wishbone VIP
    hr.add_files("../bitvis_vip_wishbone/src/*.vhd", "bitvis_vip_wishbone")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_wishbone")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=21, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_rgmii():
    clear_sim_folder()
    print_test_name("RGMII VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add RGMII VIP
    hr.add_files("../bitvis_vip_rgmii/src/*.vhd", "bitvis_vip_rgmii")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_rgmii")
    # Add TB/TH
    hr.add_files("../bitvis_vip_rgmii/tb/maintenance_tb/*.vhd", "bitvis_vip_rgmii")
    hr.add_files("../bitvis_vip_rgmii/tb/*.vhd", "bitvis_vip_rgmii")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=2, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_sbi():
    clear_sim_folder()
    print_test_name("SBI VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add SBI VIP
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    # Add TB/TH
    hr.add_files("../bitvis_vip_sbi/tb/maintenance_tb/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../bitvis_vip_sbi/tb/*.vhd", "bitvis_vip_sbi")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=11, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_scoreboard():
    clear_sim_folder()
    print_test_name("Scoreboard VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add TB dependencies
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
    hr.add_files("../bitvis_uart/src/*.vhd", "bitvis_uart")
    # Add TB/TH
    hr.add_files("../bitvis_vip_scoreboard/tb/maintenance_tb/*.vhd", "bitvis_vip_scoreboard_tb")
    hr.add_files("../bitvis_vip_scoreboard/tb/*.vhd", "bitvis_vip_scoreboard_tb")
    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=3, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_spec_cov():
    clear_sim_folder()
    print_test_name("Specification Coverage VIP")

    hr = HDLRegression(simulator='modelsim')

    # Remove output files prior to sim
    hr.run_command("rm *.txt")
    # hr.run_command("py ../bitvis_vip_spec_cov/script/maintenance_script/sim.py")

    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    hr.add_files("../bitvis_vip_spec_cov/src/*.vhd", "bitvis_vip_spec_cov")
    # Add TB/TH
    hr.add_files("../bitvis_vip_spec_cov/tb/maintenance_tb/*.vhd", "bitvis_vip_spec_cov")
    hr.add_files("../bitvis_vip_spec_cov/tb/*.vhd", "bitvis_vip_spec_cov")

    hr.add_generics(entity="spec_cov_tb",
                         generics=["GC_REQ_FILE",       ("../bitvis_vip_spec_cov/tb/maintenance_tb/req_file.csv", "PATH"),
                                   "GC_REQ_FILE_EMPTY", ("../bitvis_vip_spec_cov/tb/maintenance_tb/req_file_empty.csv", "PATH"),
                                   "GC_SUB_REQ_FILE",   ("../bitvis_vip_spec_cov/tb/maintenance_tb/sub_req_file.csv", "PATH"),
                                   "GC_REQ_OMIT_MAP",   ("../bitvis_vip_spec_cov/tb/maintenance_tb/sub_req_omit_map_file.csv", "PATH")])

    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=20, exp_fail=1, exp_minor=0, hr=hr)


def test_bitvis_vip_spi():

    def create_config(spi_modes, data_widths, data_array_widths):
        config = []
        for spi_mode, data_width, data_array_width in product(spi_modes, data_widths, data_array_widths):
          config.append([str(spi_mode), str(data_width), str(data_array_width)])
        return config

    clear_sim_folder()
    print_test_name("SPI VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)

    # Add testcase configurations
    created_testcases = 0
    configs = create_config(spi_modes=range(0,4), data_widths=[8, 14, 23, 32], data_array_widths=[2, 4, 6, 8])
    for config in configs:
        hr.add_generics(entity="spi_vvc_tb",
                             generics=["GC_SPI_MODE", config[0],"GC_DATA_WIDTH", config[1], "GC_DATA_ARRAY_WIDTH", config[2]])
        created_testcases += 1

    total_testcases = created_testcases * 6

    # Add SPI VIP
    hr.add_files("../bitvis_vip_spi/src/*.vhd", "bitvis_vip_spi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_spi")
    # Add TB/TH and dependencies
    hr.add_files("../bitvis_vip_spi/tb/maintenance_tb//spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_common_pkg.vhd", "bitvis_vip_spi")
    hr.add_files("../bitvis_vip_spi/tb/maintenance_tb/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_master.vhd", "bitvis_vip_spi")
    hr.add_files("../bitvis_vip_spi/tb/maintenance_tb/spi_master_slave_opencores/trunk/rtl/spi_master_slave/spi_slave.vhd", "bitvis_vip_spi")
    hr.add_files("../bitvis_vip_spi/tb/maintenance_tb/spi_pif.vhd", "bitvis_vip_spi")
    hr.add_files("../bitvis_vip_spi/tb/maintenance_tb/*.vhd", "bitvis_vip_spi")
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")

    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=total_testcases, exp_fail=0, exp_minor=0, hr=hr)



def test_bitvis_vip_uart():
    clear_sim_folder()
    print_test_name("UART VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add UART VIP
    hr.add_files("../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")
    # Add TB/TH
    hr.add_files("../bitvis_vip_uart/tb/maintenance_tb/*.vhd", "bitvis_vip_uart")
    hr.add_files("../bitvis_vip_uart/tb/*.vhd", "bitvis_vip_uart")
    # Add Clock Generator VIP
    hr.add_files("../bitvis_vip_clock_generator/src/*.vhd", "bitvis_vip_clock_generator")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_clock_generator")
    # Add UART DUT
    hr.add_files("../bitvis_uart/src/*.vhd", "bitvis_uart")
    # Add SBI VIP
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")

    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=3, exp_fail=0, exp_minor=0, hr=hr)


def test_bitvis_vip_ethernet():
    clear_sim_folder()
    print_test_name("Ethernet VIP")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add Ethernet VIP
    hr.add_files("../bitvis_vip_ethernet/src/*.vhd", "bitvis_vip_ethernet")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_ethernet")
    # Add HVVC Bridge VIP
    hr.add_files("../bitvis_vip_hvvc_to_vvc_bridge/src/*.vhd", "bitvis_vip_hvvc_to_vvc_bridge")
    # Add GMII VIP
    hr.add_files("../bitvis_vip_gmii/src/*.vhd", "bitvis_vip_gmii")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_gmii")
    # Add SBI VIP
    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")
    # Add testbench and harness
    hr.add_files("../bitvis_vip_ethernet/tb/*.vhd", "bitvis_vip_ethernet")
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/*.vhd", "bitvis_vip_ethernet")
    # Add TB dependencies
    compile_directives_93 = ["-suppress", "1346,1236,1090", "-93"]
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/xilinx/XilinxCoreLib/*.vhd", "xilinxcorelib")
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/xilinx/unisims/*.vhd", "unisim") # 08
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/xilinx/unisims/primitive/*.vhd", "unisim", com_options=compile_directives_93)
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/*.vhd", "mac_master")
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/xilinx/*.vhd", "mac_master")
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/generic/*.vhd", "mac_master")
    hr.add_files("../bitvis_vip_ethernet/tb/maintenance_tb/ethernet_mac-master/xilinx/ipcore_dir/*.vhd", "mac_master")

    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=4, exp_fail=0, exp_minor=0, hr=hr)


def test_uvvm_util():
    clear_sim_folder()
    print_test_name("Utility Library")

    # Counters to accumulate results from individual runs
    global num_fail

    hr = HDLRegression(simulator='modelsim')
    # Remove output files prior to sim
    hr.run_command("rm *.txt")
    # Add Util src
    hr.add_files("../uvvm_util/src/*.vhd", "uvvm_util")
    # Add Util TB
    hr.add_files("../uvvm_util/tb/maintenance_tb/*.vhd", "uvvm_util")

    # Define testcase names with generics for GC_TESTCASE
    hr.add_generics(entity="generic_queue_array_tb",
                         generics=["GC_TESTCASE", "generic_queue_array_tb"])
    hr.add_generics(entity="generic_queue_record_tb",
                         generics=["GC_TESTCASE", "generic_queue_record_tb"])
    hr.add_generics(entity="generic_queue_tb",
                         generics=["GC_TESTCASE", "generic_queue_tb"])
    hr.add_generics(entity="simplified_data_queue_tb",
                         generics=["GC_TESTCASE", "simplified_data_queue_tb"])

    output_path = os_adjust_path(os.getcwd())
    hr.add_generics(entity='func_cov_tb',
                         architecture='func',
                         generics=['GC_FILE_PATH', (output_path, 'PATH')])

    hr.start(sim_options=get_sim_options(hr))

    check_result(exp_pass=51, exp_fail=0, exp_minor=0, hr=hr)

    # Run coverage accumulation script
    hr.run_command("python ../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_verbose.txt -r")
    hr.run_command("python ../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_non_verbose.txt -r -nv")
    hr.run_command("python ../uvvm_util/script/func_cov_merge.py -f db_*_parallel_*.txt -o func_cov_accumulated_holes.txt -r -hl -im")

    # Check with golden reference
    (ret_txt, ret_code) = hr.run_command("pwd")
    (ret_txt, ret_code) = hr.run_command("python ../uvvm_util/script/maintenance_script/verify_with_golden.py -modelsim")

    if ret_code != 0:
        print(ret_txt)
        num_fail += 1


def test_uvvm_vvc_framework():
    clear_sim_folder()
    print_test_name("VVC Framework")

    hr = HDLRegression(simulator='modelsim')
    # Add util, fw and VIP Scoreboard
    add_uvvm_basic_files(hr)
    # Add TB/TH and dependencies
    hr.add_files("../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_uart")

    hr.add_files("../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_sbi")

    hr.add_files("../bitvis_uart/src/*.vhd", "bitvis_uart")

    hr.add_files("../bitvis_vip_avalon_mm/src/*.vhd", "bitvis_vip_avalon_mm")
    hr.add_files("../uvvm_vvc_framework/src_target_dependent/*.vhd", "bitvis_vip_avalon_mm")

    hr.add_files("../uvvm_vvc_framework/tb/maintenance_tb/reference_vvcs/src/*sbi*.vhd", "bitvis_vip_sbi")
    hr.add_files("../uvvm_vvc_framework/tb/maintenance_tb/reference_vvcs/src/*uart*.vhd", "bitvis_vip_uart")
    hr.add_files("../uvvm_vvc_framework/tb/maintenance_tb/*.vhd", "testbench_lib")
    sim_options = "-t ns"
    hr.start(sim_options='-t ns')

    check_result(exp_pass=11, exp_fail=0, exp_minor=0, hr=hr)



def present_result():
    # Counters to accumulate results from individual runs
    global num_pass
    global num_fail
    global failing_tests_list
    global num_tests_run

    print("Results:")
    print("Number of tests run: %d" %(num_tests_run))
    print("Passing tests: %d" %(num_pass))
    print("Failing tests: %d" %(num_fail))
    print("Passing tests with minor alerts: %s\n" %(num_minor))
    for test in failing_tests_list:
        print(" - FAIL: %s" %(test))


def main():

    if not os.path.isdir("../"):
        print('UVVM not found in : ../uvvm ')
        print('aborting')
        sys.exit(1)

    start_time = time.time()

    print('''
   __  ___    ___    ____  ___
  / / / / |  / / |  / /  |/  /
 / / / /| | / /| | / / /|_/ /
/ /_/ / | |/ / | |/ / /  / /
\____/  |___/  |___/_/  /_/   Regression Runner
    ''')

    test_uvvm_util()
    test_bitvis_vip_spec_cov()
    test_bitvis_uart()
    test_bitvis_irqc()
    test_bitvis_vip_sbi()
    test_bitvis_vip_scoreboard()
    test_bitvis_vip_avalon_st()
    test_bitvis_vip_avalon_mm()
    test_bitvis_vip_axi()
    test_bitvis_vip_axilite()
    test_bitvis_vip_axistream()
    test_bitvis_vip_clock_generator()
    test_bitvis_vip_error_injection()
    test_bitvis_vip_gmii()
    test_bitvis_vip_gpio()
    test_bitvis_vip_i2c()
    test_bitvis_vip_rgmii()
    test_bitvis_vip_spi()
    test_bitvis_vip_uart()
    test_bitvis_vip_ethernet()
    test_uvvm_vvc_framework()

    # Num tests = X
    present_result()

    end_time = time.time()

    print('Total simulation time: %d sec' % (end_time - start_time))


if __name__ == "__main__":
    main()
