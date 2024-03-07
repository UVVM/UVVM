import sys
import os
import shutil
import mock
from itertools import product


try:
    from hdlregression import HDLRegression
except:
    print('Unable to import HDLRegression module. See HDLRegression documentation for installation instructions.')
    sys.exit(1)

sys.path.append('../script/vvc_generator')
import vvc_generator


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


def test_vvc_framework(): 
    print('Verify UVVM VVC Framework')

    hr = HDLRegression(simulator='modelsim')

    # Add util, fw and VIP Scoreboard
    hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
    hr.add_files("../../src/*.vhd", "uvvm_vvc_framework")
    hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

    # Add TB/TH and dependencies
    hr.add_files("../../../bitvis_vip_uart/src/*.vhd", "bitvis_vip_uart")
    hr.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_uart")

    hr.add_files("../../../bitvis_vip_sbi/src/*.vhd", "bitvis_vip_sbi")
    hr.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_sbi")

    hr.add_files("../../../bitvis_uart/src/*.vhd", "bitvis_uart")

    hr.add_files("../../../bitvis_vip_avalon_mm/src/*.vhd", "bitvis_vip_avalon_mm")
    hr.add_files("../../src_target_dependent/*.vhd", "bitvis_vip_avalon_mm")

    hr.add_files("../../tb/maintenance_tb/reference_vvcs/src/*sbi*.vhd", "bitvis_vip_sbi")
    hr.add_files("../../tb/maintenance_tb/reference_vvcs/src/*uart*.vhd", "bitvis_vip_uart")
    hr.add_files("../../tb/maintenance_tb/*.vhd", "testbench_lib")


    sim_options = None
    default_options = []
    simulator_name = hr.settings.get_simulator_name()
    if simulator_name in ['MODELSIM', 'RIVIERA']:
        sim_options = '-t ns'
        # Set compile options
        default_options = ["-suppress", "1346,1246,1236", "-2008"]
        hr.set_simulator(simulator=simulator_name, com_options=default_options)

    hr.start(sim_options=sim_options)

    num_failing_tests = hr.get_num_fail_tests()
    num_passing_tests = hr.get_num_pass_tests()
    if num_passing_tests == 0:
        return 1
    else:
        return num_failing_tests


#######################
# VVC Generator tests
#######################
# Test 1: name, extended_features, concurrent_channels, vvc_multiple_executors
@mock.patch('vvc_generator.input', side_effect=['test', 'n', 1, 'n'])
def test_1(mock_choice):
    vvc_generator.main()

# Test 2: name, extended_features, concurrent_channels, vvc_multiple_executors, num_executors, exec_1_name, exec_2_name, ch_NA_mult_exec
@mock.patch('vvc_generator.input', side_effect=['test', 'n', 1, 'y', 3, 'response', 'request', 'n'])
def test_2(mock_choice):
    vvc_generator.main()

# Test 3: name, extended_features, concurrent_channels, vvc_multiple_executors, num_executors, exec_1_name, exec_2_name, ch_NA_mult_exec, num_exec, exec_name
@mock.patch('vvc_generator.input', side_effect=['test', 'n', 1, 'y', 3, 'response', 'request', 'y', 2, 'response2'])
def test_3(mock_choice):
    vvc_generator.main()

# Test 4: name, extended_features, concurrent_channels, ch_0_name, ch_1_name, ch_num_executors
@mock.patch('vvc_generator.input', side_effect=['test', 'n', 2, 'RX', 'TX', 0])
def test_4(mock_choice):
    vvc_generator.main()

# Test 5: name, extended_features, concurrent_channels, ch_0_name, ch_1_name, ch_num_executors, ch_0_exec, ch_0_num_exec, ch_0_exec_name
@mock.patch('vvc_generator.input', side_effect=['test', 'n', 2, 'RX', 'TX', 1, 'y', 3, 'response', 'request'])
def test_5(mock_choice):
    vvc_generator.main()

# Test 6: name, extended_features, scoreboard, transaction_info, concurrent_channels, vvc_multiple_executors
@mock.patch('vvc_generator.input', side_effect=['test', 'y', 'n', 'n', 1, 'n'])
def test_6(mock_choice):
    vvc_generator.main()

# Test 7: name, extended_features, scoreboard, transaction_info, concurrent_channels, vvc_multiple_executors
@mock.patch('vvc_generator.input', side_effect=['test', 'y', 'n', 'y', 1, 'n'])
def test_7(mock_choice):
    vvc_generator.main()

# Test 8: name, extended_features, scoreboard, transaction_info, concurrent_channels, vvc_multiple_executors
@mock.patch('vvc_generator.input', side_effect=['test', 'y', 'y', 'n', 1, 'n'])
def test_8(mock_choice):
    vvc_generator.main()

# Test 9: name, extended_features, scoreboard, transaction_info, concurrent_channels, vvc_multiple_executors
@mock.patch('vvc_generator.input', side_effect=['test', 'y', 'y', 'y', 1, 'n'])
def test_9(mock_choice):
    vvc_generator.main()

# Test 10: name, extended_features, scoreboard, transaction_info, concurrent_channels, ch_0_name, ch_1_name, ch_num_executors, ch_0_exec, ch_0_num_exec, ch_0_exec_name
@mock.patch('vvc_generator.input', side_effect=['test', 'y', 'y', 'y', 2, 'RX', 'TX', 1, 'y', 3, 'response', 'request'])
def test_10(mock_choice):
    vvc_generator.main()


def test_vvc_generator():
    print('Verify UVVM VVC Generator')

    # Generate the files with different inputs
    test_1()
    os.rename("output", "generated_vip_1")
    test_2()
    os.rename("output", "generated_vip_2")
    test_3()
    os.rename("output", "generated_vip_3")
    test_4()
    os.rename("output", "generated_vip_4")
    test_5()
    os.rename("output", "generated_vip_5")
    test_6()
    os.rename("output", "generated_vip_6")
    test_7()
    os.rename("output", "generated_vip_7")
    test_8()
    os.rename("output", "generated_vip_8")
    test_9()
    os.rename("output", "generated_vip_9")
    test_10()
    os.rename("output", "generated_vip_10")

    hr = HDLRegression(simulator='modelsim')

    # Add util, fw and VIP Scoreboard
    hr.add_files("../../../uvvm_util/src/*.vhd", "uvvm_util")
    hr.add_files("../../src/*.vhd", "uvvm_vvc_framework")
    hr.add_files("../../../bitvis_vip_scoreboard/src/*.vhd", "bitvis_vip_scoreboard")

    # Add generated files
    hr.add_files('../../sim/generated_vip_1/*.vhd', 'generated_vip_1')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_1")

    hr.add_files('../../sim/generated_vip_2/*.vhd', 'generated_vip_2')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_2")

    hr.add_files('../../sim/generated_vip_3/*.vhd', 'generated_vip_3')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_3")

    hr.add_files('../../sim/generated_vip_4/*.vhd', 'generated_vip_4')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_4")

    hr.add_files('../../sim/generated_vip_5/*.vhd', 'generated_vip_5')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_5")

    hr.add_files('../../sim/generated_vip_6/*.vhd', 'generated_vip_6')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_6")

    hr.add_files('../../sim/generated_vip_7/*.vhd', 'generated_vip_7')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_7")

    hr.add_files('../../sim/generated_vip_8/*.vhd', 'generated_vip_8')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_8")

    hr.add_files('../../sim/generated_vip_9/*.vhd', 'generated_vip_9')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_9")

    hr.add_files('../../sim/generated_vip_10/*.vhd', 'generated_vip_10')
    hr.add_files("../../src_target_dependent/*.vhd", "generated_vip_10")

    # Add a testbench to detect whether compilation passed or failed using get_num_pass_tests()
    hr.add_files("../../tb/maintenance_tb/generic_queue_tb.vhd", "testbench_lib")

    sim_options = None
    default_options = []
    simulator_name = hr.settings.get_simulator_name()
    if simulator_name in ['MODELSIM', 'RIVIERA']:
        sim_options = '-t ns'
        # Set compile options
        default_options = ["-suppress", "1346,1246,1236", "-2008"]
        hr.set_simulator(simulator=simulator_name, com_options=default_options)

    hr.start(sim_options=sim_options)

    num_passing_tests = hr.get_num_pass_tests()
    if num_passing_tests == 0:
        return 1
    else:
        return 0


def main():
    cleanup('Removing any previous runs.')
    num_fw_errors = test_vvc_framework()
    num_gen_errors = test_vvc_generator()

    # Remove output only if OK
    if num_fw_errors == 0 and num_gen_errors == 0:
        cleanup('Removing simulation output')
    # Return number of failing tests
    sys.exit(num_fw_errors + num_gen_errors)

if __name__ == '__main__':
    main()
