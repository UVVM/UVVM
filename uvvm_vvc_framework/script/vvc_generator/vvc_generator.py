# ================================================================================================================================
# Copyright 2024 UVVM
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# ================================================================================================================================
# Note : Any functionality not explicitly described in the documentation is subject to change at any time
# --------------------------------------------------------------------------------------------------------------------------------

__author__ = 'UVVM'
__copyright__ = "Copyright 2024, UVVM"
__version__ = "1.1.2"
__email__ = "info@uvvm.org"

import os

division_line = "--=========================================================================================="

extended_features = {"scoreboard": False,
                     "transaction_pkg": False,
                     "transaction_info": False,
                     "unwanted_activity": False}


class Channel:

    def __init__(self, name):
        self.name = name
        self.executor_names = ["cmd"]

    def append_executor(self, names):
        for name in range(0, len(names)):
            self.executor_names.append(names[name])

    def number_of_executors(self):
        return len(self.executor_names)

    def get_name(self):
        return str(self.name)


def print_linefeed(file_handle):
    file_handle.write("\n")


def fill_with_n_spaces(used_spaces, required_spaces):
    retstr = ""
    if required_spaces >= used_spaces:
        for i in range(required_spaces - used_spaces):
            retstr = retstr + " "
    return retstr


# Check if name contains illegal VHDL characters
def is_input_vhdl_legal(requested_vvc_name):
    illegal_chars = set("<->!¤%&/()=?`\´}][{€$£@ ^¨~'*;:.,|§\" ")
    if any((c in illegal_chars) for c in requested_vvc_name):
        print("Input contains illegal VHDL characters. Please try again.")
        return False
    if requested_vvc_name.__len__() < 1:
        print("Input too short. Please try again.")
        return False
    if (requested_vvc_name[0] == '_') or (requested_vvc_name[0].isdigit()):
        print("Input must start with a letter")
        return False
    return True


def get_user_input(txt="\rPlease select 'Y' or 'N': "):
    raw_input = ""
    while not(raw_input.lower() == "y" or raw_input.lower() == "n"):
        raw_input = input(txt)
        try:
            if not(raw_input.lower() == "y" or raw_input.lower() == "n"):
                print("Please select 'Y' or 'N'!")
        except:
            print("Please select 'Y' or 'N'!")
            continue

    return raw_input.lower()


# Get the basic or advanced VVC generation.
def get_generating_level():
    print("\n\rThe VVC is generated with basic code for running with UVVM as default, but can be")
    print("generated with extended UVVM features such as Scoreboard and transaction info.")
    selected_features = extended_features.copy()
    extended_selection = None
    while extended_selection == None:
        raw_input = input("\rGenerate VVC with extended UVVM features? [y/n]: ")
        if raw_input == "":
            extended_selection = False
        else:
            try:
                if raw_input.lower() == "y":
                    extended_selection = True
                elif raw_input.lower() == "n":
                    extended_selection = False
                else:
                    print("Please select 'Y' for basic VVC or 'N' for extended VVC!")
            except:
                print("Please select 'Y' for basic VVC or 'N' for extended VVC!")
                continue

    if extended_selection:
        if get_user_input("\rAdd scoreboard to VVC? [y/n]: ") == 'y':
            selected_features["scoreboard"] = True
        if get_user_input("\rAdd transaction info to VVC? [y/n]: ") == 'y':
            selected_features["transaction_pkg"] = True
            selected_features["transaction_info"] = True
        if get_user_input("\rAdd unwanted activity detection to VVC? [y/n]: ") == 'y':
            selected_features["unwanted_activity"] = True

    return selected_features


# Get the number of channels in the VVC, if multi-channel VVC.
def get_number_of_channels():
    print("\n\rMultiple channels can be used to emulate concurrent channels in the VIP, e.g. concurrent RX and TX channels.")
    input_accepted = False
    while not input_accepted:
        raw_input = input("\rSet the number of concurrent channels to use [1-99], press enter for default(1): ")
        if raw_input == "":
            number_selected = 1
        else:
            try:
                number_selected = int(raw_input)
            except ValueError:
                print("Input was not an integer!")
                continue

        if number_selected < 1:
            print("Selected number " + str(number_selected) + " is too small. Please use a number between 1 and 99")
        elif number_selected > 99:
            print("Selected number " + str(number_selected) + " is too large. Please use a number between 1 and 99")
        else:
            input_accepted = True

    return number_selected


# Get the channel name and check if it is valid
def get_channel_name(idx):
    raw_input = input("\rPlease enter a channel name. Update t_channel type in UVVM-Util adaptations_pkg if\nnew channels (other than RX and TX) are used.\n" +
                      "Press enter for default (channel_" + str(idx) + "): ")
    requested_vvc_channel_name = raw_input.lower()
    if raw_input == "":
        requested_vvc_channel_name = "channel_" + str(idx)
    else:
        if is_input_vhdl_legal(requested_vvc_channel_name) is False:
            return get_channel_name(idx)
    return requested_vvc_channel_name


# Sets up channels with name
def set_channels(number_of_channels):
    vvc_channels = []
    if number_of_channels > 1:
        for i in range(number_of_channels):
            # Switch order from [tx, rx] to [rx, tx] in order to avoid doing manual change in t_channels or in the
            # generated type t_sub_channel in the cases where a RX and TX channel is the desired channel names.
            # Generate channel with user input for all other cases
            channel_name = get_channel_name(i)
            if i == 0 and channel_name == "tx":
                channel = Channel("rx")
            elif i == 1 and channel_name == "rx":
                channel = Channel("tx")
            else:
                channel = Channel(channel_name)

            vvc_channels.append(channel)
    else:
        channel = Channel("NA")
        vvc_channels.append(channel)
    return vvc_channels


def print_multiple_executor_info():
    print("\nMultiple executors (and queues) are used when concurrent command operations are needed.\nE.g. Avalon-MM uses two executors because multiple read" +
          " requests might be sent before receiving the responses.\nThus the first executor is sending out the commands, whereas the second executor is receiving" +
          " the response.\nBoth are required because the first executor may be busy issuing a new command at the same time the second executor is receiving a" +
          " response on a previous command.")


def get_number_of_channels_with_multiple_executors(number_of_channels):
    input_accepted = False
    while not input_accepted:
        raw_input = input("\rHow many channels shall have multiple executors? Press enter for default(0): ")
        if raw_input == "":
            number_selected = 0
        else:
            try:
                number_selected = int(raw_input)
            except ValueError:
                print("Input was not an integer!")
                continue

        if number_selected < 0:
            print("Selected number " + str(number_selected) + " is too small. Please use a number between 0 and " + str(number_of_channels))
        elif number_selected > number_of_channels:
            print("Selected number " + str(number_selected) + " is too large. Please use a number between 0 and " + str(number_of_channels))
        else:
            input_accepted = True

    return number_selected


def yes_no_question(question):
    input_accepted = False
    choice = ''
    answer = False
    while not input_accepted:
        choice = input("\r" + str(question) + " [y/n]: ")
        choice = choice.lower()
        if choice == 'y':
            answer = True
            input_accepted = True
        elif choice == 'n':
            answer = False
            input_accepted = True
        else:
            print("Input not accepted. Please use either y or n")
    return answer


# Ask user if channel is multi-executor
def is_multi_queue_channel():
    input_accepted = False
    choice = ''
    while not input_accepted:
        print("\nMultiple executors (and queues) are used when concurrent command operations are needed.\nE.g. Avalon-MM uses two executors because multiple" +
              " read requests might be sent before receiving the responses.\nThus the first executor is sending out the commands, whereas the second executor" +
              " is receiving the response.\nBoth are required because the first executor may be busy issuing a new command at the same time the second executor" +
              " is receiving a response on a previous command.")
        choice = input("\rUse multiple executors for this channel? [y/n]: ")
        choice = choice.lower()
        if choice == 'y':
            input_accepted = True
        elif choice == 'n':
            input_accepted = True
        else:
            print("Input not accepted. Please use either y or n")
    return choice


# Get the number of queues in the channel, if multi-executor channel.
def get_number_of_executors():
    input_accepted = False
    while not input_accepted:
        raw_input = input("\rSet the number of concurrent executors to use [2-3], included cmd executor: ")
        try:
            number_selected = int(raw_input)
        except ValueError:
            print("Input was not an integer!")
            continue
        if number_selected < 2:
            print("Selected number " + str(number_selected) + " is too small. Please use a number between 2 and 3")
        elif number_selected > 3:
            print("Selected number " + str(number_selected) + " is too large. Please use a number between 2 and 3")
        else:
            input_accepted = True

    return number_selected


# Get the channel name and check if it is valid
def get_executor_name():
    requested_queue_name = input("\rPlease enter an executor name prefix (e.g. response): ")
    if is_input_vhdl_legal(requested_queue_name.lower()) is False:
        return get_executor_name()
    return requested_queue_name


def get_list_of_executors():
    number_of_executors = get_number_of_executors()
    executor_names = []
    if number_of_executors > 1:
        for i in range(1, number_of_executors):
            executor_names.append(get_executor_name())
    return executor_names


# Get the VVC name and check if it is valid
def get_vvc_name():
    requested_vvc_name = input("\rPlease enter the VVC Name (e.g. SBI, UART, axilite): ")
    if is_input_vhdl_legal(requested_vvc_name.lower()) is False:
        return get_vvc_name()
    return requested_vvc_name


# Adds header to the output file
def add_vvc_header(file_handle):
    file_handle.write(division_line + "\n")
    file_handle.write("-- This VVC was generated with UVVM VVC Generator\n")
    file_handle.write(division_line + "\n")
    print_linefeed(file_handle)
    print_linefeed(file_handle)


# Adds included libraries to a leaf VVC
def add_leaf_includes(file_handle, vvc_name, vvc_channel_idx, features):
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_util;\n")
    file_handle.write("context uvvm_util.uvvm_util_context;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_vvc_framework;\n")
    file_handle.write("use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;\n")
    print_linefeed(file_handle)

    if features["scoreboard"] and vvc_channel_idx == 0:
        file_handle.write("library bitvis_vip_scoreboard;\n")
        file_handle.write("use bitvis_vip_scoreboard.generic_sb_support_pkg.C_SB_CONFIG_DEFAULT;\n")
        print_linefeed(file_handle)

    file_handle.write("use work." + vvc_name.lower() + "_bfm_pkg.all;\n")
    file_handle.write("use work.vvc_methods_pkg.all;\n")
    file_handle.write("use work.vvc_cmd_pkg.all;\n")
    file_handle.write("use work.td_target_support_pkg.all;\n")
    file_handle.write("use work.td_vvc_entity_support_pkg.all;\n")
    file_handle.write("use work.td_cmd_queue_pkg.all;\n")
    file_handle.write("use work.td_result_queue_pkg.all;\n")
    if features["transaction_pkg"]:
        file_handle.write("use work.transaction_pkg.all;\n")
    if features["scoreboard"]:
        file_handle.write("use work.vvc_sb_support_pkg.all;\n")
    print_linefeed(file_handle)
    file_handle.write(division_line + "\n")
    file_handle.write(division_line + "\n")


# Adds included libraries to a wrapper VVC
def add_wrapper_includes(file_handle, vvc_name):
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_util;\n")
    file_handle.write("context uvvm_util.uvvm_util_context;\n")
    print_linefeed(file_handle)
    file_handle.write("use work." + vvc_name.lower() + "_bfm_pkg.all;\n")
    print_linefeed(file_handle)
    file_handle.write(division_line + "\n")


def add_vvc_entity(file_handle, vvc_name, vvc_channel):
    if vvc_channel != "NA":
        file_handle.write("entity " + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc is\n")
    else:
        file_handle.write("entity " + vvc_name.lower() + "_vvc is\n")
    file_handle.write("  generic (\n")
    file_handle.write("    --<USER_INPUT> Insert interface specific generic constants here\n")
    file_handle.write("    -- Example: \n")
    file_handle.write("    -- GC_ADDR_WIDTH                            : integer range 1 to C_VVC_CMD_ADDR_MAX_LENGTH;\n")
    file_handle.write("    -- GC_DATA_WIDTH                            : integer range 1 to C_VVC_CMD_DATA_MAX_LENGTH;\n")
    file_handle.write("    GC_INSTANCE_IDX                          : natural;\n")
    if vvc_channel != "NA":
        file_handle.write("    GC_CHANNEL                               : t_channel;\n")
    file_handle.write("    GC_" + vvc_name.upper() + "_BFM_CONFIG" + fill_with_n_spaces(vvc_name.__len__(), 26) +
                      " : t_" + vvc_name.lower() + "_bfm_config" + fill_with_n_spaces(vvc_name.__len__(), 13) +
                      ":= C_" + vvc_name.upper() + "_BFM_CONFIG_DEFAULT;\n")
    file_handle.write("    GC_CMD_QUEUE_COUNT_MAX                   : natural                   := C_CMD_QUEUE_COUNT_MAX;\n")
    file_handle.write("    GC_CMD_QUEUE_COUNT_THRESHOLD             : natural                   := C_CMD_QUEUE_COUNT_THRESHOLD;\n")
    file_handle.write("    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY    : t_alert_level             := C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY;\n")
    file_handle.write("    GC_RESULT_QUEUE_COUNT_MAX                : natural                   := C_RESULT_QUEUE_COUNT_MAX;\n")
    file_handle.write("    GC_RESULT_QUEUE_COUNT_THRESHOLD          : natural                   := C_RESULT_QUEUE_COUNT_THRESHOLD;\n")
    file_handle.write("    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY : t_alert_level             := C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY\n")
    file_handle.write("  );\n")
    file_handle.write("  port (\n")
    file_handle.write("    --<USER_INPUT> Insert BFM interface signals here\n")
    file_handle.write("    -- Example: \n")
    if(vvc_channel == "NA"):
        file_handle.write("    -- " + vvc_name.lower() + "_vvc_if" + fill_with_n_spaces(vvc_name.__len__(), 21) +
                          ": inout t_" + vvc_name.lower() + "_if := init_" + vvc_name.lower() +
                          "_if_signals(GC_ADDR_WIDTH, GC_DATA_WIDTH); \n")
    else:
        file_handle.write("    -- " + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if" +
                          fill_with_n_spaces(vvc_name.__len__() + vvc_channel.__len__(), 20) +
                          ": inout t_" + vvc_name.lower() + "_" + vvc_channel.lower() + "_if := init_" + vvc_name.lower() +
                          "_" + vvc_channel.lower() + "_if_signals(GC_ADDR_WIDTH, GC_DATA_WIDTH); \n")
    file_handle.write("    -- VVC control signals: \n")
    file_handle.write("    -- rst                         : in std_logic; -- Optional VVC Reset\n")
    file_handle.write("    clk                         : in std_logic\n")
    file_handle.write("  );\n")
    if vvc_channel != "NA":
        file_handle.write("end entity " + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc;\n")
    else:
        file_handle.write("end entity " + vvc_name.lower() + "_vvc;\n")
    print_linefeed(file_handle)
    file_handle.write(division_line + "\n")
    file_handle.write(division_line + "\n")


def add_architecture_declaration(file_handle, vvc_name, vvc_channel, features, num_of_queues):
    number_of_executors = vvc_channel.number_of_executors()

    if vvc_channel.name != "NA":
        file_handle.write("architecture behave of " + vvc_name.lower() + "_" + vvc_channel.name.lower() + "_vvc is\n")
    else:
        file_handle.write("architecture behave of " + vvc_name.lower() + "_vvc is\n")
    print_linefeed(file_handle)
    file_handle.write("  constant C_SCOPE      : string       := get_scope_for_log(C_VVC_NAME, GC_INSTANCE_IDX")
    if vvc_channel.name == "NA":
        file_handle.write(");\n")
    else:
        file_handle.write(", GC_CHANNEL);\n")
    file_handle.write("  constant C_VVC_LABELS : t_vvc_labels := assign_vvc_labels(C_SCOPE, C_VVC_NAME,")
    if vvc_channel.name == "NA":
        file_handle.write(" GC_INSTANCE_IDX, NA);\n")
    else:
        file_handle.write(" GC_INSTANCE_IDX, GC_CHANNEL);\n")
    print_linefeed(file_handle)
    file_handle.write("  signal executor_is_busy       : boolean := false;\n")
    file_handle.write("  signal queue_is_increasing    : boolean := false;\n")
    file_handle.write("  signal last_cmd_idx_executed  : natural := 0;\n")

    if number_of_executors > 1:
        for i in range(1, number_of_executors):
            file_handle.write("  signal " + vvc_channel.executor_names[i] + "_is_busy       : boolean := false;\n")
            file_handle.write("  signal " + vvc_channel.executor_names[i] + "_queue_is_increasing    : boolean := false;\n")
            file_handle.write("  signal last_" + vvc_channel.executor_names[i] + "_idx_executed  : natural := 0;\n")

    file_handle.write("  signal terminate_current_cmd  : t_flag_record;\n")
    if features["unwanted_activity"]:
        file_handle.write("  --<USER_INPUT> Uncomment if the VVC has a valid signal, e.g. tvalid in AXI-Stream\n")
        file_handle.write("  -- signal clock_period           : time;\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Instantiation of the element dedicated executor\n")
    file_handle.write("  shared variable command_queue : work.td_cmd_queue_pkg.t_generic_queue;\n")

    if number_of_executors > 1:
        for i in range(1, number_of_executors):
            file_handle.write("  shared variable " + vvc_channel.executor_names[i] + "_queue : work.td_cmd_queue_pkg.t_generic_queue;\n")

    file_handle.write("  shared variable result_queue  : work.td_result_queue_pkg.t_generic_queue;\n")
    print_linefeed(file_handle)
    if vvc_channel.name == "NA":
        file_handle.write("  alias vvc_config : t_vvc_config is shared_" + vvc_name.lower() + "_vvc_config(GC_INSTANCE_IDX);\n")
        file_handle.write("  alias vvc_status : t_vvc_status is shared_" + vvc_name.lower() + "_vvc_status(GC_INSTANCE_IDX);\n")

        if features["transaction_info"]:
            file_handle.write("  -- Transaction info\n")
            file_handle.write("  alias vvc_transaction_info_trigger        : std_logic           is global_" + vvc_name.lower() +
                              "_vvc_transaction_trigger(GC_INSTANCE_IDX);\n")
            file_handle.write("  alias vvc_transaction_info                : t_transaction_group is shared_" + vvc_name.lower() +
                              "_vvc_transaction_info(GC_INSTANCE_IDX);\n")

    else:
        file_handle.write("  alias vvc_config : t_vvc_config is shared_" + vvc_name.lower() + "_vvc_config(GC_CHANNEL, GC_INSTANCE_IDX);\n")
        file_handle.write("  alias vvc_status : t_vvc_status is shared_" + vvc_name.lower() + "_vvc_status(GC_CHANNEL, GC_INSTANCE_IDX);\n")

        if features["transaction_info"]:
            file_handle.write("  -- Transaction info\n")
            file_handle.write("  alias vvc_transaction_info_trigger        : std_logic           is global_" + vvc_name.lower() +
                              "_vvc_transaction_trigger(GC_CHANNEL, GC_INSTANCE_IDX);\n")
            file_handle.write("  alias vvc_transaction_info                : t_transaction_group is shared_" + vvc_name.lower() +
                              "_vvc_transaction_info(GC_CHANNEL, GC_INSTANCE_IDX);\n")

    file_handle.write("  -- VVC Activity\n")
    file_handle.write("  signal entry_num_in_vvc_activity_register : integer;\n")
    print_linefeed(file_handle)

    file_handle.write("begin\n")
    print_linefeed(file_handle)
    if vvc_channel.name != "NA":
        file_handle.write("  assert GC_CHANNEL = " + vvc_channel.name.upper() + " report \"GC_CHANNEL must be set accordingly to the VVC, i.e. " + vvc_channel.name.upper() +
                          "\" severity failure;\n")
    print_linefeed(file_handle)


def add_wrapper_architecture_declaration(file_handle, vvc_name):
    file_handle.write("architecture struct of " + vvc_name.lower() + "_vvc is\n")
    print_linefeed(file_handle)
    file_handle.write("begin\n")
    print_linefeed(file_handle)


def add_wrapper_architecture_end(file_handle):
    print_linefeed(file_handle)
    file_handle.write("end struct;\n")
    print_linefeed(file_handle)


def add_vvc_constructor(file_handle, vvc_name):
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Constructor\n")
    file_handle.write("  -- - Set up the defaults and show constructor if enabled\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  work.td_vvc_entity_support_pkg.vvc_constructor(C_SCOPE, GC_INSTANCE_IDX, vvc_config, command_queue, result_queue, GC_" +vvc_name.upper() +
                      "_BFM_CONFIG,\n")
    file_handle.write("                  GC_CMD_QUEUE_COUNT_MAX, GC_CMD_QUEUE_COUNT_THRESHOLD, GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,\n")
    file_handle.write("                  GC_RESULT_QUEUE_COUNT_MAX, GC_RESULT_QUEUE_COUNT_THRESHOLD, GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,\n")
    file_handle.write("                  C_VVC_MAX_INSTANCE_NUM);\n")
    file_handle.write("  " + division_line + "\n")

    print_linefeed(file_handle)
    print_linefeed(file_handle)


def add_vvc_interpreter(file_handle, vvc_channel, features, num_of_queues):
    number_of_executors = vvc_channel.number_of_executors()

    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Command interpreter\n")
    file_handle.write("  -- - Interpret, decode and acknowledge commands from the central sequencer\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  cmd_interpreter : process is\n")
    file_handle.write("    variable v_cmd_has_been_acked : boolean; -- Indicates if acknowledge_cmd() has been called for the current shared_vvc_cmd\n")
    file_handle.write("    variable v_local_vvc_cmd      : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;\n")
    file_handle.write("    variable v_msg_id_panel       : t_msg_id_panel;\n")
    file_handle.write("    variable v_temp_msg_id_panel  : t_msg_id_panel; --UVVM: temporary fix for HVVC, remove in v3.0\n")
    file_handle.write("  begin\n")
    print_linefeed(file_handle)
    file_handle.write("    -- 0. Initialize the process prior to first command\n")
    file_handle.write("    work.td_vvc_entity_support_pkg.initialize_interpreter(terminate_current_cmd, global_awaiting_completion);\n")
    file_handle.write("    -- initialise shared_vvc_last_received_cmd_idx for channel and instance\n")
    if vvc_channel.name == "NA":
        file_handle.write("    shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := 0;\n")
    else:
        file_handle.write("    shared_vvc_last_received_cmd_idx(GC_CHANNEL, GC_INSTANCE_IDX) := 0;\n")
    print_linefeed(file_handle)
    file_handle.write("    -- Register VVC in vvc activity register\n")
    file_handle.write("    entry_num_in_vvc_activity_register <= shared_vvc_activity_register.priv_register_vvc(name     => C_VVC_NAME,\n")
    if vvc_channel.name != "NA":
        file_handle.write("                                                                                         channel  => GC_CHANNEL,\n")
    if num_of_queues == 1:
        file_handle.write("                                                                                         instance => GC_INSTANCE_IDX);\n")
    else:
        file_handle.write("                                                                                         instance => GC_INSTANCE_IDX,\n")
        file_handle.write("                                                                                         num_executors => " + str(num_of_queues) + ");\n")
    file_handle.write("    -- Set initial value of v_msg_id_panel to msg_id_panel in config\n")
    file_handle.write("    v_msg_id_panel := vvc_config.msg_id_panel;\n")
    print_linefeed(file_handle)
    file_handle.write("    -- Then for every single command from the sequencer\n")
    file_handle.write("    loop  -- basically as long as new commands are received\n")
    print_linefeed(file_handle)
    file_handle.write("      -- 1. wait until command targeted at this VVC. Must match VVC name, instance and channel (if applicable)\n")
    file_handle.write("      --    releases global semaphore\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      work.td_vvc_entity_support_pkg.await_cmd_from_sequencer(C_VVC_LABELS, vvc_config, THIS_VVCT, VVC_BROADCAST, global_vvc_busy," +
                      " global_vvc_ack, v_local_vvc_cmd);\n")
    file_handle.write("      v_cmd_has_been_acked := false; -- Clear flag\n")
    file_handle.write("      -- Update shared_vvc_last_received_cmd_idx with received command index\n")
    if vvc_channel.name == "NA":
        file_handle.write("      shared_vvc_last_received_cmd_idx(NA, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;\n")
    else:
        file_handle.write("      shared_vvc_last_received_cmd_idx(GC_CHANNEL, GC_INSTANCE_IDX) := v_local_vvc_cmd.cmd_idx;\n")
    file_handle.write("      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the\n")
    file_handle.write("      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.\n")
    file_handle.write("      v_msg_id_panel := get_msg_id_panel(v_local_vvc_cmd, vvc_config);\n")
    print_linefeed(file_handle)
    file_handle.write("      -- 2a. Put command on the executor if intended for the executor\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      if v_local_vvc_cmd.command_type = QUEUED then\n")
    file_handle.write("        work.td_vvc_entity_support_pkg.put_command_on_queue(v_local_vvc_cmd, command_queue, vvc_status, queue_is_increasing);\n")
    print_linefeed(file_handle)
    file_handle.write("      -- 2b. Otherwise command is intended for immediate response\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      elsif v_local_vvc_cmd.command_type = IMMEDIATE then\n")
    print_linefeed(file_handle)
    file_handle.write("        --UVVM: temporary fix for HVVC, remove two lines below in v3.0\n")
    file_handle.write("        if v_local_vvc_cmd.operation /= DISABLE_LOG_MSG and v_local_vvc_cmd.operation /= ENABLE_LOG_MSG then\n")
    file_handle.write("          v_temp_msg_id_panel     := vvc_config.msg_id_panel;\n")
    file_handle.write("          vvc_config.msg_id_panel := v_msg_id_panel;\n")
    file_handle.write("        end if;\n")
    print_linefeed(file_handle)
    file_handle.write("        case v_local_vvc_cmd.operation is\n")
    print_linefeed(file_handle)
    file_handle.write("          when DISABLE_LOG_MSG =>\n")
    file_handle.write("            uvvm_util.methods_pkg.disable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel" +
                      ", to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);\n")
    print_linefeed(file_handle)
    file_handle.write("          when ENABLE_LOG_MSG =>\n")
    file_handle.write("            uvvm_util.methods_pkg.enable_log_msg(v_local_vvc_cmd.msg_id, vvc_config.msg_id_panel" +
                      ", to_string(v_local_vvc_cmd.msg) & format_command_idx(v_local_vvc_cmd), C_SCOPE, v_local_vvc_cmd.quietness);\n")
    print_linefeed(file_handle)
    file_handle.write("          when FLUSH_COMMAND_QUEUE =>\n")
    file_handle.write("            work.td_vvc_entity_support_pkg.interpreter_flush_command_queue(v_local_vvc_cmd, command_queue, vvc_config, vvc_status," +
                      " C_VVC_LABELS);\n")
    print_linefeed(file_handle)
    file_handle.write("          when TERMINATE_CURRENT_COMMAND =>\n")
    file_handle.write("            work.td_vvc_entity_support_pkg.interpreter_terminate_current_command(v_local_vvc_cmd, vvc_config, C_VVC_LABELS," +
                      " terminate_current_cmd, executor_is_busy);\n")
    print_linefeed(file_handle)
    file_handle.write("          when FETCH_RESULT =>\n")
    file_handle.write("            work.td_vvc_entity_support_pkg.interpreter_fetch_result(result_queue, entry_num_in_vvc_activity_register, v_local_vvc_cmd, vvc_config," +
                      " C_VVC_LABELS, shared_vvc_response);\n")
    print_linefeed(file_handle)
    file_handle.write("          when others =>\n")
    file_handle.write("            tb_error(\"Unsupported command received for IMMEDIATE execution: '\" & to_string(v_local_vvc_cmd.operation) & \"'\", C_SCOPE);\n")
    print_linefeed(file_handle)
    file_handle.write("        end case;\n")
    print_linefeed(file_handle)
    file_handle.write("        --UVVM: temporary fix for HVVC, remove line below in v3.0\n")
    file_handle.write("        if v_local_vvc_cmd.operation /= DISABLE_LOG_MSG and v_local_vvc_cmd.operation /= ENABLE_LOG_MSG then\n")
    file_handle.write("          vvc_config.msg_id_panel := v_temp_msg_id_panel;\n")
    file_handle.write("        end if;\n")
    print_linefeed(file_handle)
    file_handle.write("      else\n")
    file_handle.write("        tb_error(\"command_type is not IMMEDIATE or QUEUED\", C_SCOPE);\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    file_handle.write("      -- 3. Acknowledge command after running or queuing the command\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      if not v_cmd_has_been_acked then\n")
    file_handle.write("        work.td_target_support_pkg.acknowledge_cmd(global_vvc_ack, v_local_vvc_cmd.cmd_idx);\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    file_handle.write("    end loop;\n")
    file_handle.write("    wait;\n")
    file_handle.write("  end process cmd_interpreter;\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)
    print_linefeed(file_handle)


def add_vvc_executor(file_handle, vvc_name, vvc_channel, vvc_channel_idx, features):
    number_of_executors = vvc_channel.number_of_executors()

    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Command executor\n")
    file_handle.write("  -- - Fetch and execute the commands\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  cmd_executor : process is\n")
    file_handle.write("    constant C_EXECUTOR_ID                            : natural := 0;\n")
    file_handle.write("    variable v_cmd                                    : t_vvc_cmd_record;\n")
    file_handle.write("    -- variable v_result                              : t_vvc_result; -- See vvc_cmd_pkg\n")
    file_handle.write("    variable v_timestamp_start_of_current_bfm_access  : time    := 0 ns;\n")
    file_handle.write("    variable v_timestamp_start_of_last_bfm_access     : time    := 0 ns;\n")
    file_handle.write("    variable v_timestamp_end_of_last_bfm_access       : time    := 0 ns;\n")
    file_handle.write("    variable v_command_is_bfm_access                  : boolean := false;\n")
    file_handle.write("    variable v_prev_command_was_bfm_access            : boolean := false;\n")
    file_handle.write("    variable v_msg_id_panel                           : t_msg_id_panel;\n")
    file_handle.write("    -- variable v_normalised_addr    : unsigned(GC_ADDR_WIDTH-1 downto 0) := (others => '0');\n")
    file_handle.write("    -- variable v_normalised_data    : std_logic_vector(GC_DATA_WIDTH-1 downto 0) := (others => '0');\n")
    print_linefeed(file_handle)
    file_handle.write("  begin\n")
    print_linefeed(file_handle)
    file_handle.write("    -- 0. Initialize the process prior to first command\n")
    file_handle.write("    -------------------------------------------------------------------------\n")
    file_handle.write("    work.td_vvc_entity_support_pkg.initialize_executor(terminate_current_cmd);\n")
    print_linefeed(file_handle)

    if features["scoreboard"] and vvc_channel_idx == 0:
        file_handle.write("    -- Setup " + vvc_name.upper() + " scoreboard\n")
        file_handle.write("    " + vvc_name.upper() + "_VVC_SB.set_scope(\"" + vvc_name.upper() + "_VVC_SB\");\n")
        file_handle.write("    " + vvc_name.upper() + "_VVC_SB.enable(GC_INSTANCE_IDX, \"" + vvc_name.upper() + " VVC SB Enabled\");\n")
        file_handle.write("    " + vvc_name.upper() + "_VVC_SB.config(GC_INSTANCE_IDX, C_SB_CONFIG_DEFAULT);\n")
        file_handle.write("    " + vvc_name.upper() + "_VVC_SB.enable_log_msg(GC_INSTANCE_IDX, ID_DATA);\n")

    file_handle.write("    -- Set initial value of v_msg_id_panel to msg_id_panel in config\n")
    file_handle.write("    v_msg_id_panel := vvc_config.msg_id_panel;\n")
    print_linefeed(file_handle)
    file_handle.write("    loop\n")
    print_linefeed(file_handle)

    file_handle.write("      -- update vvc activity\n")
    file_handle.write("      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register," +
                      " C_EXECUTOR_ID, last_cmd_idx_executed, command_queue.is_empty(VOID), C_SCOPE);\n")
    print_linefeed(file_handle)

    file_handle.write("      -- 1. Set defaults, fetch command and log\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, command_queue, vvc_config, vvc_status, queue_is_increasing," +
                      " executor_is_busy, C_VVC_LABELS);\n")
    print_linefeed(file_handle)

    file_handle.write("      -- update vvc activity\n")
    file_handle.write("      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register," +
                      " C_EXECUTOR_ID, last_cmd_idx_executed, command_queue.is_empty(VOID), C_SCOPE);\n")
    print_linefeed(file_handle)

    file_handle.write("      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the\n")
    file_handle.write("      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.\n")
    file_handle.write("      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);\n")
    print_linefeed(file_handle)
    file_handle.write("      -- Check if command is a BFM access\n")
    file_handle.write("      v_prev_command_was_bfm_access := v_command_is_bfm_access; -- save for inter_bfm_delay\n")
    file_handle.write("      --<USER_INPUT> Replace this if statement with a check of the current v_cmd.operation, in order to set v_cmd_is_bfm_access to true" +
                      " if this is a BFM access command\n")
    file_handle.write("      -- Example:\n")
    file_handle.write("      -- if v_cmd.operation = WRITE or v_cmd.operation = READ or v_cmd.operation = CHECK or v_cmd.operation = POLL_UNTIL then \n")
    file_handle.write("      if true then  -- Replace this line with actual check\n")
    file_handle.write("        v_command_is_bfm_access := true;\n")
    file_handle.write("      else\n")
    file_handle.write("        v_command_is_bfm_access := false;\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    file_handle.write("      -- Insert delay if needed\n")
    file_handle.write("      work.td_vvc_entity_support_pkg.insert_inter_bfm_delay_if_requested(vvc_config                         => vvc_config,\n")
    file_handle.write("                                                                         command_is_bfm_access              => v_prev_command_was_bfm_access,\n")
    file_handle.write("                                                                         timestamp_start_of_last_bfm_access => v_timestamp_start_of_last_bfm_access,\n")
    file_handle.write("                                                                         timestamp_end_of_last_bfm_access   => v_timestamp_end_of_last_bfm_access,\n")
    file_handle.write("                                                                         scope                              => C_SCOPE,\n")
    file_handle.write("                                                                         msg_id_panel                       => v_msg_id_panel);\n")
    print_linefeed(file_handle)
    file_handle.write("      if v_command_is_bfm_access then\n")
    file_handle.write("        v_timestamp_start_of_current_bfm_access := now;\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    file_handle.write("      -- 2. Execute the fetched command\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      case v_cmd.operation is  -- Only operations in the dedicated record are relevant\n")
    print_linefeed(file_handle)
    file_handle.write("        -- VVC dedicated operations\n")
    file_handle.write("        --===================================\n")
    print_linefeed(file_handle)
    file_handle.write("        --<USER_INPUT>: Insert BFM procedure calls here\n")
    file_handle.write("        -- Example:\n")
    file_handle.write("        --   when WRITE =>\n")

    if features["transaction_info"]:
        file_handle.write("        --     -- Set vvc transaction info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);\n")
        print_linefeed(file_handle)

    file_handle.write("        --     v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, \"addr\", \"shared_vvc_cmd.addr\", \"" +
                      vvc_name.lower() + "_write() called with too wide address. \" & v_cmd.msg);\n")
    file_handle.write("        --     v_normalised_data := normalize_and_check(v_cmd.data, v_normalised_data, ALLOW_WIDER_NARROWER, \"data\", \"shared_vvc_cmd.data\", \"" +
                      vvc_name.lower() + "_write() called with too wide data. \" & v_cmd.msg);\n")
    file_handle.write("        --     -- Call the corresponding procedure in the BFM package.\n")
    file_handle.write("        --     " + vvc_name.lower() + "_write(addr_value    => v_normalised_addr,\n")
    file_handle.write("        --               data_value    => v_normalised_data,\n")
    file_handle.write("        --               msg           => format_msg(v_cmd),\n")
    file_handle.write("        --               clk           => clk,\n")
    file_handle.write("        --               " + vvc_name.lower() + "_if        => " + vvc_name.lower() + "_vvc_if,\n")
    file_handle.write("        --               scope         => C_SCOPE,\n")
    file_handle.write("        --               msg_id_panel  => v_msg_id_panel,\n")
    file_handle.write("        --               config        => vvc_config.bfm_config);\n")
    print_linefeed(file_handle)

    if features["transaction_info"]:
        file_handle.write("        --     -- Update vvc transaction info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);\n")
        print_linefeed(file_handle)

    if number_of_executors > 1:
        file_handle.write("        --  Example of pipelined read from Avalon-MM interface.\n")
    else:
        file_handle.write("        --  -- If the result from the BFM call is to be stored, e.g. in a read call, use the additional procedure illustrated in this" +
                          " read example\n")

    file_handle.write("        --   when READ =>\n")

    if features["transaction_info"]:
        file_handle.write("        --     -- Set vvc_transaction_info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);\n")
        print_linefeed(file_handle)

    file_handle.write("        --     v_normalised_addr := normalize_and_check(v_cmd.addr, v_normalised_addr, ALLOW_WIDER_NARROWER, \"addr\", \"shared_vvc_cmd.addr\", \"" +
                      vvc_name.lower() + "_write() called with too wide address. \" & v_cmd.msg);\n")
    file_handle.write("        --     -- Call the corresponding procedure in the BFM package.\n")

    if number_of_executors > 1:
        file_handle.write("        --     if vvc_config.use_read_pipeline then\n")
        file_handle.write("        --       -- Stall until response command executor is no longer full\n")
        file_handle.write("        --       check_value(vvc_config.bfm_config.clock_period > -1 ns, TB_ERROR, \"Check that clock_period is configured when using" +
                          " insert_delay().\",\n")
        file_handle.write("        --                   C_SCOPE, ID_NEVER, v_msg_id_panel);\n")
        file_handle.write("        --       while command_response_queue.get_count(VOID) > vvc_config.num_pipeline_stages loop\n")
        file_handle.write("        --         wait for vvc_config.bfm_config.clock_period;\n")
        file_handle.write("        --       end loop;\n")
        file_handle.write("        --       avalon_mm_read_request( addr_value          => v_normalised_addr,\n")
        file_handle.write("        --                               msg                 => format_msg(v_cmd),\n")
        file_handle.write("        --                               clk                 => clk,\n")
        file_handle.write("        --                               avalon_mm_if        => avalon_mm_vvc_master_if,\n")
        file_handle.write("        --                               scope               => C_SCOPE,\n")
        file_handle.write("        --                               msg_id_panel        => v_msg_id_panel,\n")
        file_handle.write("        --                               config              => vvc_config.bfm_config);\n")
        file_handle.write("        --       work.td_vvc_entity_support_pkg.put_command_on_queue(v_cmd, command_response_queue, vvc_status, response_queue_is_increasing);\n")
        print_linefeed(file_handle)
        file_handle.write("        --     else\n")
        file_handle.write("        --       avalon_mm_read( addr_value          => v_normalised_addr,\n")
        file_handle.write("        --                       data_value          => v_result(GC_DATA_WIDTH-1 downto 0),\n")
        file_handle.write("        --                       msg                 => format_msg(v_cmd),\n")
        file_handle.write("        --                       clk                 => clk,\n")
        file_handle.write("        --                       avalon_mm_if        => avalon_mm_vvc_master_if,\n")
        file_handle.write("        --                       scope               => C_SCOPE,\n")
        file_handle.write("        --                       msg_id_panel        => v_msg_id_panel,\n")
        file_handle.write("        --                       config              => vvc_config.bfm_config);\n")
        print_linefeed(file_handle)

        if features["scoreboard"]:
            file_handle.write("        --       -- Request SB check result\n")
            file_handle.write("        --       if v_cmd.data_routing = TO_SB then\n")
            file_handle.write("        --         -- call SB check_received\n")
            file_handle.write("        --         " + vvc_name.upper() + "_VVC_SB.check_received(GC_INSTANCE_IDX, pad_" + vvc_name.lower() +
                              "_sb(v_result(GC_DATA_WIDTH-1 downto 0)));\n")
            file_handle.write("        --       else\n")
            file_handle.write("        --         -- Store the result\n")
            file_handle.write("        --         work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,\n")
            file_handle.write("        --                                                     cmd_idx      => v_cmd.cmd_idx,\n")
            file_handle.write("        --                                                     result       => v_result);\n")
            file_handle.write("        --       end if;\n")
        else:
            file_handle.write("        --       -- Store the result\n")
            file_handle.write("        --       work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,\n")
            file_handle.write("        --                                                   cmd_idx      => v_cmd.cmd_idx,\n")
            file_handle.write("        --                                                   result       => v_result);\n")

        if features["transaction_info"]:
            print_linefeed(file_handle)
            file_handle.write("        --       -- Update vvc transaction info\n")
            file_handle.write("        --       set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);\n")

        file_handle.write("        --    end if;\n")

    else:
        file_handle.write("        --     " + vvc_name.lower() + "_read(addr_value    => v_normalised_addr,\n")
        file_handle.write("        --              data_value    => v_result,\n")
        file_handle.write("        --              msg           => format_msg(v_cmd),\n")
        file_handle.write("        --              clk           => clk,\n")
        file_handle.write("        --              " + vvc_name.lower() + "_if        => " + vvc_name.lower() + "_vvc_if,\n")
        file_handle.write("        --              scope         => C_SCOPE,\n")
        file_handle.write("        --              msg_id_panel  => v_msg_id_panel,\n")
        file_handle.write("        --              config        => vvc_config.bfm_config);\n")
        print_linefeed(file_handle)

        if features["scoreboard"]:
            file_handle.write("        --     -- Request SB check result\n")
            file_handle.write("        --     if v_cmd.data_routing = TO_SB then\n")
            file_handle.write("        --       -- call SB check_received\n")
            file_handle.write("        --       " + vvc_name.upper() + "_VVC_SB.check_received(GC_INSTANCE_IDX, pad_" + vvc_name.lower() +
                              "_sb(v_result(GC_DATA_WIDTH-1 downto 0)));\n")
            file_handle.write("        --     else\n")
            file_handle.write("        --       -- Store the result\n")
            file_handle.write("        --       work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,\n")
            file_handle.write("        --                                                   cmd_idx      => v_cmd.cmd_idx,\n")
            file_handle.write("        --                                                   result       => v_result);\n")
            file_handle.write("        --     end if;\n")
        else:
            file_handle.write("        --     -- Store the result\n")
            file_handle.write("        --     work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,\n")
            file_handle.write("        --                                                 cmd_idx      => v_cmd.cmd_idx,\n")
            file_handle.write("        --                                                 result       => v_result);\n")

        if features["transaction_info"]:
            file_handle.write("        --     -- Update vvc transaction info\n")
            file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);\n")
            print_linefeed(file_handle)

    print_linefeed(file_handle)
    print_linefeed(file_handle)
    file_handle.write("        -- UVVM common operations\n")
    file_handle.write("        --===================================\n")
    file_handle.write("        when INSERT_DELAY =>\n")
    file_handle.write("          log(ID_INSERTED_DELAY, \"Running: \" & to_string(v_cmd.proc_call) & \" \" & format_command_idx(v_cmd), C_SCOPE, v_msg_id_panel);\n")
    file_handle.write("          if v_cmd.gen_integer_array(0) = -1 then\n")
    file_handle.write("            -- Delay specified using time\n")
    file_handle.write("            wait until terminate_current_cmd.is_active = '1' for v_cmd.delay;\n")
    file_handle.write("          else\n")
    file_handle.write("            -- Delay specified using integer\n")
    file_handle.write("            --<USER_INPUT> Uncomment if BFM has clock_period config\n")
    file_handle.write("            -- check_value(vvc_config.bfm_config.clock_period > -1 ns, TB_ERROR, \"Check that clock_period is configured when using insert_delay().\",\n")
    file_handle.write("            --             C_SCOPE, ID_NEVER, v_msg_id_panel);\n")
    file_handle.write("            -- wait until terminate_current_cmd.is_active = '1' for v_cmd.gen_integer_array(0) * vvc_config.bfm_config.clock_period;\n")
    file_handle.write("          end if;\n")
    print_linefeed(file_handle)
    file_handle.write("        when others =>\n")
    file_handle.write("          tb_error(\"Unsupported local command received for execution: '\" & to_string(v_cmd.operation) & \"'\", C_SCOPE);\n")
    file_handle.write("      end case;\n")
    print_linefeed(file_handle)
    file_handle.write("      if v_command_is_bfm_access then\n")
    file_handle.write("        v_timestamp_end_of_last_bfm_access   := now;\n")
    file_handle.write("        v_timestamp_start_of_last_bfm_access := v_timestamp_start_of_current_bfm_access;\n")
    file_handle.write("        if ((vvc_config.inter_bfm_delay.delay_type = TIME_START2START) and\n")
    file_handle.write("           ((now - v_timestamp_start_of_current_bfm_access) > vvc_config.inter_bfm_delay.delay_in_time)) then\n")
    file_handle.write("          alert(vvc_config.inter_bfm_delay.inter_bfm_delay_violation_severity, \"BFM access exceeded specified start-to-start inter-bfm delay, \" & \n")
    file_handle.write("                to_string(vvc_config.inter_bfm_delay.delay_in_time) & \".\", C_SCOPE);\n")
    file_handle.write("        end if;\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    file_handle.write("      -- Reset terminate flag if any occurred\n")
    file_handle.write("      if (terminate_current_cmd.is_active = '1') then\n")
    file_handle.write("        log(ID_CMD_EXECUTOR, \"Termination request received\", C_SCOPE, v_msg_id_panel);\n")
    file_handle.write("        uvvm_vvc_framework.ti_vvc_framework_support_pkg.reset_flag(terminate_current_cmd);\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    if number_of_executors > 1:
        file_handle.write("      --<USER_INPUT> Fill out which operations are pipelined in other executors\n")
        file_handle.write("      -- Example of pipelined read from Avalon-MM interface.\n")
        file_handle.write("      -- Pipelined read commands are divided into read requests executed here and read responses executed in another executor.\n")
        file_handle.write("      -- Since the commands can finish in any order, to detect when this specific command has finished, we store the cmd_idx\n")
        file_handle.write("      -- in a list with pending commands which will be cleared in the corresponding executor when it has finished.\n")
        file_handle.write("      -- if (v_cmd.operation = READ or v_cmd.operation = CHECK) and vvc_config.use_read_pipeline = true then\n")
        file_handle.write("      --   shared_vvc_activity_register.priv_add_pending_cmd_idx(entry_num_in_vvc_activity_register, v_cmd.cmd_idx);\n")
        file_handle.write("      -- else\n")
        file_handle.write("      --   last_cmd_idx_executed <= v_cmd.cmd_idx; -- Only updated for commands completed in this executor\n")
        file_handle.write("      -- end if;\n")
    else:
        file_handle.write("      last_cmd_idx_executed <= v_cmd.cmd_idx;\n")
    print_linefeed(file_handle)
    if features["transaction_info"]:
        file_handle.write("      -- Set vvc_transaction_info back to default values\n")
        file_handle.write("      reset_vvc_transaction_info(vvc_transaction_info, v_cmd);\n")
        print_linefeed(file_handle)
    else:
        file_handle.write("      -- Wait a delta cycle so that last_cmd_idx_executed is updated\n")
        file_handle.write("      wait for 0 ns;\n")
        print_linefeed(file_handle)
    file_handle.write("    end loop;\n")
    file_handle.write("  end process cmd_executor;\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)


def add_vvc_pipeline_step(file_handle, vvc_name, queue_name, executor_idx, features):
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Pipelined step\n")
    file_handle.write("  -- - Fetch and execute the commands in the " + queue_name + " executor\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  " + queue_name + "_executor : process\n")
    file_handle.write("    constant C_EXECUTOR_ID        : natural := " + str(executor_idx) + ";\n")
    file_handle.write("    variable v_cmd                : t_vvc_cmd_record;\n")
    file_handle.write("    variable v_msg_id_panel       : t_msg_id_panel;\n")
    file_handle.write("    -- variable v_result             : t_vvc_result; -- See vvc_cmd_pkg\n")
    file_handle.write("    -- variable v_normalised_addr    : unsigned(GC_ADDR_WIDTH-1 downto 0) := (others => '0');\n")
    file_handle.write("    -- variable v_normalised_data    : std_logic_vector(GC_DATA_WIDTH-1 downto 0) := (others => '0');\n")
    print_linefeed(file_handle)
    file_handle.write("  begin\n")
    file_handle.write("    -- Set the " + queue_name + " executor up with the same settings as the command executor\n")
    file_handle.write("    " + queue_name + "_queue.set_scope(C_SCOPE & \":" + queue_name.upper() + "\");\n")
    file_handle.write("    " + queue_name + "_queue.set_queue_count_max(GC_CMD_QUEUE_COUNT_MAX);\n")
    file_handle.write("    " + queue_name + "_queue.set_queue_count_threshold(GC_CMD_QUEUE_COUNT_THRESHOLD);\n")
    file_handle.write("    " + queue_name + "_queue.set_queue_count_threshold_severity(GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY);\n")
    file_handle.write("    -- Wait until VVC is registered in vvc activity register in the interpreter\n")
    file_handle.write("    wait until entry_num_in_vvc_activity_register >= 0;\n")
    file_handle.write("    -- Set initial value of v_msg_id_panel to msg_id_panel in config\n")
    file_handle.write("    v_msg_id_panel := vvc_config.msg_id_panel;\n")
    print_linefeed(file_handle)
    file_handle.write("    loop\n")
    print_linefeed(file_handle)

    file_handle.write("      -- update vvc activity\n")
    file_handle.write("       update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, INACTIVE, entry_num_in_vvc_activity_register," +
                      " C_EXECUTOR_ID, last_" + queue_name + "_idx_executed, command_queue.is_empty(VOID), C_SCOPE);\n")
    print_linefeed(file_handle)

    file_handle.write("      -- Fetch commands\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      work.td_vvc_entity_support_pkg.fetch_command_and_prepare_executor(v_cmd, " + queue_name + "_queue, vvc_config" +
                      ", vvc_status, " + queue_name + "_queue_is_increasing, " + queue_name + "_is_busy, C_VVC_LABELS);\n")
    print_linefeed(file_handle)
    file_handle.write("      -- Select between a provided msg_id_panel via the vvc_cmd_record from a VVC with a higher hierarchy or the\n")
    file_handle.write("      -- msg_id_panel in this VVC's config. This is to correctly handle the logging when using Hierarchical-VVCs.\n")
    file_handle.write("      v_msg_id_panel := get_msg_id_panel(v_cmd, vvc_config);\n")
    print_linefeed(file_handle)

    file_handle.write("      -- update vvc activity\n")
    file_handle.write("      update_vvc_activity_register(global_trigger_vvc_activity_register, vvc_status, ACTIVE, entry_num_in_vvc_activity_register," +
                      " C_EXECUTOR_ID, last_" + queue_name + "_idx_executed, command_queue.is_empty(VOID), C_SCOPE);\n")
    print_linefeed(file_handle)

    print_linefeed(file_handle)
    file_handle.write("      -- Execute the fetched command\n")
    file_handle.write("      -------------------------------------------------------------------------\n")
    file_handle.write("      case v_cmd.operation is  -- Only operations in the dedicated record are relevant\n")
    file_handle.write("        --<USER_INPUT>: Insert BFM procedure calls here\n")
    file_handle.write("        -- Example of pipelined step used for read operations on the Avalon-MM interface:\n")
    file_handle.write("        --   when READ =>\n")

    if features["transaction_info"]:
        file_handle.write("        --     -- Set vvc_transaction_info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);\n")
        print_linefeed(file_handle)

    file_handle.write("        --     -- Initiate read response\n")
    file_handle.write("        --     avalon_mm_read_response(addr_value          => v_normalised_addr,\n")
    file_handle.write("        --                             data_value          => v_result(GC_DATA_WIDTH-1 downto 0),\n")
    file_handle.write("        --                             msg                 => format_msg(v_cmd),\n")
    file_handle.write("        --                             clk                 => clk,\n")
    file_handle.write("        --                             avalon_mm_if        => avalon_mm_vvc_master_if,\n")
    file_handle.write("        --                             scope               => C_SCOPE,\n")
    file_handle.write("        --                             msg_id_panel        => v_msg_id_panel,\n")
    file_handle.write("        --                             config              => vvc_config.bfm_config);\n")
    print_linefeed(file_handle)

    if features["scoreboard"]:
        file_handle.write("        --     -- Request SB check result\n")
        file_handle.write("        --     if v_cmd.data_routing = TO_SB then\n")
        file_handle.write("        --       -- call SB check_received\n")
        file_handle.write("        --       " + vvc_name.upper() + "_VVC_SB.check_received(GC_INSTANCE_IDX, pad_" + vvc_name.lower() +
                          "_sb(v_result(GC_DATA_WIDTH-1 downto 0)));\n")
        file_handle.write("        --     else\n")
        file_handle.write("        --       -- Store the result\n")
        file_handle.write("        --       work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,\n")
        file_handle.write("        --                                                   cmd_idx      => v_cmd.cmd_idx,\n")
        file_handle.write("        --                                                   result       => v_result);\n")
        file_handle.write("        --     end if;\n")
    else:
        file_handle.write("        --     -- Store the result\n")
        file_handle.write("        --     work.td_vvc_entity_support_pkg.store_result(result_queue => result_queue,\n")
        file_handle.write("        --                                                 cmd_idx      => v_cmd.cmd_idx,\n")
        file_handle.write("        --                                                 result       => v_result);\n")

    if features["transaction_info"]:
        print_linefeed(file_handle)
        file_handle.write("        --     -- Update vvc transaction info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, v_result, COMPLETED, C_SCOPE);\n")

    print_linefeed(file_handle)
    file_handle.write("        --   when CHECK =>\n")

    if features["transaction_info"]:
        file_handle.write("        --     -- Set vvc_transaction_info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, IN_PROGRESS, C_SCOPE);\n")
        print_linefeed(file_handle)

    file_handle.write("        --     -- Initiate check response\n")
    file_handle.write("        --     avalon_mm_check_response(addr_value          => v_normalised_addr,\n")
    file_handle.write("        --                              data_exp            => v_normalised_data,\n")
    file_handle.write("        --                              msg                 => format_msg(v_cmd),\n")
    file_handle.write("        --                              clk                 => clk,\n")
    file_handle.write("        --                              avalon_mm_if        => avalon_mm_vvc_master_if,\n")
    file_handle.write("        --                              alert_level         => v_cmd.alert_level,\n")
    file_handle.write("        --                              scope               => C_SCOPE,\n")
    file_handle.write("        --                              msg_id_panel        => v_msg_id_panel,\n")
    file_handle.write("        --                              config              => vvc_config.bfm_config);\n")
    print_linefeed(file_handle)

    if features["transaction_info"]:
        file_handle.write("        --     -- Update vvc transaction info\n")
        file_handle.write("        --     set_global_vvc_transaction_info(vvc_transaction_info_trigger, vvc_transaction_info, v_cmd, vvc_config, COMPLETED, C_SCOPE);\n")
        print_linefeed(file_handle)

    file_handle.write("          when others =>\n")
    file_handle.write("            tb_error(\"Unsupported local command received for execution: '\" & to_string(v_cmd.operation) & \"'\", C_SCOPE);\n")
    print_linefeed(file_handle)
    file_handle.write("      end case;\n")
    print_linefeed(file_handle)
    file_handle.write("      last_" + queue_name + "_idx_executed <= v_cmd.cmd_idx;\n")
    print_linefeed(file_handle)
    if features["transaction_info"]:
        file_handle.write("      -- Set vvc_transaction_info back to default values\n")
        file_handle.write("      reset_vvc_transaction_info(vvc_transaction_info, v_cmd);\n")
        print_linefeed(file_handle)

    file_handle.write("    end loop;\n")
    file_handle.write("    wait;\n")
    file_handle.write("  end process;\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)
    print_linefeed(file_handle)


def add_vvc_terminator(file_handle):
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Command termination handler\n")
    file_handle.write("  -- - Handles the termination request record (sets and resets terminate flag on request)\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  cmd_terminator : uvvm_vvc_framework.ti_vvc_framework_support_pkg.flag_handler(terminate_current_cmd);  -- flag: is_active, set, reset\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)
    print_linefeed(file_handle)


def add_clock_period(file_handle):
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Clock period\n")
    file_handle.write("  -- - Finds the clock period\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  --<USER_INPUT> Uncomment if the VVC has a valid signal, e.g. tvalid in AXI-Stream\n")
    file_handle.write("  -- p_clock_period : process\n")
    file_handle.write("  -- begin\n")
    file_handle.write("  --   wait until rising_edge(clk);\n")
    file_handle.write("  --   clock_period <= now;\n")
    file_handle.write("  --   wait until rising_edge(clk);\n")
    file_handle.write("  --   clock_period <= now - clock_period;\n")
    file_handle.write("  --   wait;\n")
    file_handle.write("  -- end process;\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)
    print_linefeed(file_handle)


def add_unwanted_activity_detection(file_handle, vvc_name, vvc_channel):
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Unwanted activity detection\n")
    file_handle.write("  -- - Monitors unwanted activity from the DUT\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  p_unwanted_activity : process is\n")
    file_handle.write("  begin\n")
    file_handle.write("    -- Add a delay to allow the VVC to be registered in the activity register\n")
    file_handle.write("    wait for std.env.resolution_limit;\n")
    print_linefeed(file_handle)
    file_handle.write("    loop\n")
    file_handle.write("      -- Skip if the vvc is inactive to avoid waiting for an inactive activity register\n")
    file_handle.write("      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = ACTIVE then\n")
    file_handle.write("        -- Wait until the vvc is inactive\n")
    file_handle.write("        loop\n")
    file_handle.write("          wait on global_trigger_vvc_activity_register;\n")
    file_handle.write("          if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then\n")
    file_handle.write("            exit;\n")
    file_handle.write("          end if;\n")
    file_handle.write("        end loop;\n")
    file_handle.write("      end if;\n")
    print_linefeed(file_handle)
    file_handle.write("      --<USER_INPUT> Insert all DUT outputs to be monitored in the 'wait on' statement below, except ready signal\n")
    file_handle.write("      -- Note: ready signal, e.g. tready in AXI-Stream, shall not be monitored when the VVC is a master VVC\n")
    if vvc_channel != "NA":
        file_handle.write("      -- Example: wait on " + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.valid, " + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.data, global_trigger_vvc_activity_register;\n")
    else:
        file_handle.write("      -- Example: wait on " + vvc_name.lower() + "_vvc_if.valid, " + vvc_name.lower() + "_vvc_if.data, global_trigger_vvc_activity_register;\n")
    file_handle.write("      wait on global_trigger_vvc_activity_register;\n")
    print_linefeed(file_handle)
    file_handle.write("      -- Check the changes on the DUT outputs only when the vvc is inactive\n")
    file_handle.write("      if shared_vvc_activity_register.priv_get_vvc_activity(entry_num_in_vvc_activity_register) = INACTIVE then\n")
    file_handle.write("        --<USER_INPUT> Use the check_unwanted_activity() procedure defined in the VVC framework support package to check the changes on the DUT outputs\n")
    file_handle.write("        -- Example:\n")
    if vvc_channel != "NA":
        file_handle.write("        -- check_unwanted_activity(" + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.last, vvc_config.unwanted_activity_severity, \"last\", C_SCOPE);\n")
        file_handle.write("        -- check_unwanted_activity(" + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.data, vvc_config.unwanted_activity_severity, \"data\", C_SCOPE);\n")
    else:
        file_handle.write("        -- check_unwanted_activity(" + vvc_name.lower() + "_vvc_if.last, vvc_config.unwanted_activity_severity, \"last\", C_SCOPE);\n")
        file_handle.write("        -- check_unwanted_activity(" + vvc_name.lower() + "_vvc_if.data, vvc_config.unwanted_activity_severity, \"data\", C_SCOPE);\n")
    print_linefeed(file_handle)
    file_handle.write("        -- Note: Use the following example instead if the interface has a valid signal, e.g. tvalid in AXI-Stream\n")
    file_handle.write("        -- Example:\n")
    file_handle.write("        -- Skip checking the changes if the valid signal goes low within one clock period after the VVC becomes inactive\n")
    if vvc_channel != "NA":
        file_handle.write("        -- if not (falling_edge(" + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.valid'event) and global_trigger_vvc_activity_register'last_event < clock_period) then\n")
        file_handle.write("        --   check_unwanted_activity(" + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.valid, vvc_config.unwanted_activity_severity, \"valid\", C_SCOPE);\n")
        file_handle.write("        --   check_unwanted_activity(" + vvc_name.lower() + "_" + vvc_channel.lower() + "_vvc_if.data, vvc_config.unwanted_activity_severity, \"data\", C_SCOPE);\n")
    else:
        file_handle.write("        -- if not (falling_edge(" + vvc_name.lower() + "_vvc_if.valid'event) and global_trigger_vvc_activity_register'last_event < clock_period) then\n")
        file_handle.write("        --   check_unwanted_activity(" + vvc_name.lower() + "_vvc_if.valid, vvc_config.unwanted_activity_severity, \"valid\", C_SCOPE);\n")
        file_handle.write("        --   check_unwanted_activity(" + vvc_name.lower() + "_vvc_if.data, vvc_config.unwanted_activity_severity, \"data\", C_SCOPE);\n")
    file_handle.write("        -- end if;\n")
    file_handle.write("      end if;\n")
    file_handle.write("    end loop;\n")
    file_handle.write("  end process p_unwanted_activity;\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)


def add_end_of_architecture(file_handle):
    file_handle.write("end architecture behave;\n")


def add_leaf_vvc_entity(file_handle, vvc_name, channel):
    print_linefeed(file_handle)
    file_handle.write("  -- " + vvc_name.upper() + " " + channel.upper() + " VVC\n")
    file_handle.write("  i1_" + vvc_name.lower() + "_" + channel.lower() + ": entity work." + vvc_name.lower() + "_" + channel.lower() + "_vvc\n")
    file_handle.write("  generic map (\n")
    file_handle.write("    --<USER_INPUT> Insert interface specific generic constants here\n")
    file_handle.write("    -- Example: \n")
    file_handle.write("    -- GC_DATA_WIDTH                             => GC_DATA_WIDTH,\n")
    file_handle.write("    GC_INSTANCE_IDX                           => GC_INSTANCE_IDX,\n")
    file_handle.write("    GC_CHANNEL                                => " + channel.upper() + ",\n")
    file_handle.write("    GC_" + vvc_name.upper() + "_BFM_CONFIG" + fill_with_n_spaces(vvc_name.__len__(), 28) + "=> GC_" + vvc_name.upper() + "_BFM_CONFIG,\n")
    file_handle.write("    GC_CMD_QUEUE_COUNT_MAX                    => GC_CMD_QUEUE_COUNT_MAX,\n")
    file_handle.write("    GC_CMD_QUEUE_COUNT_THRESHOLD              => GC_CMD_QUEUE_COUNT_THRESHOLD,\n")
    file_handle.write("    GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY     => GC_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,\n")
    file_handle.write("    GC_RESULT_QUEUE_COUNT_MAX                 => GC_RESULT_QUEUE_COUNT_MAX,\n")
    file_handle.write("    GC_RESULT_QUEUE_COUNT_THRESHOLD           => GC_RESULT_QUEUE_COUNT_THRESHOLD,\n")
    file_handle.write("    GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY  => GC_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY\n")
    file_handle.write("  )\n")
    file_handle.write("  port map (\n")
    file_handle.write("  --<USER_INPUT> Please insert the proper interface needed for this leaf VVC\n")
    file_handle.write("  -- Example:\n")
    file_handle.write("    -- " + vvc_name.lower() + "_vvc_" + channel.lower() + "         => " + vvc_name.lower() + "_vvc_if." + vvc_name.lower() +
                      "_vvc_" + channel.lower() + ",\n")
    file_handle.write("    -- rst                 => rst,  -- Optional VVC Reset\n")
    file_handle.write("    clk                 => clk\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)


def add_vvc_cmd_pkg_includes(file_handle, features):
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_util;\n")
    file_handle.write("context uvvm_util.uvvm_util_context;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_vvc_framework;\n")
    file_handle.write("use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;\n")
    print_linefeed(file_handle)
    if features["transaction_pkg"]:
        file_handle.write("use work.transaction_pkg.all;\n")
        print_linefeed(file_handle)
    file_handle.write(division_line + "\n")
    file_handle.write(division_line + "\n")


def add_vvc_cmd_pkg_header(file_handle, features):
    file_handle.write("package vvc_cmd_pkg is\n")
    print_linefeed(file_handle)
    if features["transaction_pkg"]:
        file_handle.write("  alias t_operation is work.transaction_pkg.t_operation;\n")
        print_linefeed(file_handle)

    if not(features["transaction_pkg"]):
        file_handle.write("  " + division_line + "\n")
        file_handle.write("  -- t_operation\n")
        file_handle.write("  -- - VVC and BFM operations\n")
        file_handle.write("  " + division_line + "\n")
        file_handle.write("  type t_operation is (\n")
        file_handle.write("    -- UVVM common\n")
        file_handle.write("    NO_OPERATION,\n")
        file_handle.write("    AWAIT_COMPLETION,\n")
        file_handle.write("    AWAIT_ANY_COMPLETION,\n")
        file_handle.write("    ENABLE_LOG_MSG,\n")
        file_handle.write("    DISABLE_LOG_MSG,\n")
        file_handle.write("    FLUSH_COMMAND_QUEUE,\n")
        file_handle.write("    FETCH_RESULT,\n")
        file_handle.write("    INSERT_DELAY,\n")
        file_handle.write("    TERMINATE_CURRENT_COMMAND\n")
        file_handle.write("    -- VVC local\n")
        file_handle.write("    --<USER_INPUT> Expand this type with enums for BFM procedures.\n")
        file_handle.write("    -- Example: \n")
        file_handle.write("    -- TRANSMIT, RECEIVE, EXPECT\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)
        file_handle.write("  --<USER_INPUT> Create constants for the maximum sizes to use in this VVC.\n")
        file_handle.write("  -- You can create VVCs with smaller sizes than these constants, but not larger.\n")
        file_handle.write("  -- For example, given a VVC with parallel data bus and address bus, constraints\n")
        file_handle.write("  -- should be added for maximum data length and address length.\n")
        file_handle.write("  -- Note: if these constants are to be flexible, create similar constants in adaptations_pkg\n")
        file_handle.write("  -- and use them to assign these constants, see other UVVM VIPs for guidance on how it's done.\n")
        file_handle.write("  -- Example:\n")
        file_handle.write("  constant C_VVC_CMD_DATA_MAX_LENGTH   : natural := 32;\n")
        file_handle.write("  --constant C_VVC_CMD_ADDR_MAX_LENGTH   : natural := 32;\n")
        file_handle.write("  constant C_VVC_CMD_STRING_MAX_LENGTH : natural := 300;\n")
        file_handle.write("  constant C_VVC_MAX_INSTANCE_NUM      : natural := C_MAX_VVC_INSTANCE_NUM;\n")
        print_linefeed(file_handle)

    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- t_vvc_cmd_record\n")
    file_handle.write("  -- - Record type used for communication with the VVC\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  type t_vvc_cmd_record is record\n")
    file_handle.write("    -- VVC dedicated fields\n")
    file_handle.write("    --<USER_INPUT> Insert all data types needed to transport data to the BFM here.\n")
    file_handle.write("    -- This includes data field, address field, constraints (e.g. timeout), etc.\n")
    file_handle.write("    -- Example: \n")
    file_handle.write("    -- data                      : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);\n")
    file_handle.write("    -- max_receptions            : integer;\n")
    file_handle.write("    -- timeout                   : time;\n")
    file_handle.write("    -- Common VVC fields\n")
    file_handle.write("    operation                 : t_operation;\n")
    file_handle.write("    proc_call                 : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);\n")
    file_handle.write("    msg                       : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);\n")
    file_handle.write("    data_routing              : t_data_routing;\n")
    file_handle.write("    cmd_idx                   : natural;\n")
    file_handle.write("    command_type              : t_immediate_or_queued;\n")
    file_handle.write("    msg_id                    : t_msg_id;\n")
    file_handle.write("    gen_integer_array         : t_integer_array(0 to 1); -- Increase array length if needed\n")
    file_handle.write("    gen_boolean               : boolean; -- Generic boolean\n")
    file_handle.write("    timeout                   : time;\n")
    file_handle.write("    alert_level               : t_alert_level;\n")
    file_handle.write("    delay                     : time;\n")
    file_handle.write("    quietness                 : t_quietness;\n")
    file_handle.write("    parent_msg_id_panel       : t_msg_id_panel;\n")
    file_handle.write("  end record t_vvc_cmd_record;\n")
    print_linefeed(file_handle)
    file_handle.write("  constant C_VVC_CMD_DEFAULT : t_vvc_cmd_record := (\n")
    file_handle.write("    --<USER_INPUT> Set the fields you added to the t_vvc_cmd_record above to their default value here\n")
    file_handle.write("    -- Example:\n")
    file_handle.write("    -- data                      => (others => '0'),\n")
    file_handle.write("    -- max_receptions            => 1,\n")
    file_handle.write("    -- timeout                   => 0 ns,\n")
    file_handle.write("    -- Common VVC fields\n")
    file_handle.write("    operation                 => NO_OPERATION,\n")
    file_handle.write("    proc_call                 => (others => NUL),\n")
    file_handle.write("    msg                       => (others => NUL),\n")
    file_handle.write("    data_routing              => NA,\n")
    file_handle.write("    cmd_idx                   => 0,\n")
    file_handle.write("    command_type              => NO_COMMAND_TYPE,\n")
    file_handle.write("    msg_id                    => NO_ID,\n")
    file_handle.write("    gen_integer_array         => (others => -1),\n")
    file_handle.write("    gen_boolean               => false,\n")
    file_handle.write("    timeout                   => 0 ns,\n")
    file_handle.write("    alert_level               => FAILURE,\n")
    file_handle.write("    delay                     => 0 ns,\n")
    file_handle.write("    quietness                 => NON_QUIET,\n")
    file_handle.write("    parent_msg_id_panel       => C_UNUSED_MSG_ID_PANEL\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- shared_vvc_cmd\n")
    file_handle.write("  -- - Shared variable used for transmitting VVC commands\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  shared variable shared_vvc_cmd : t_vvc_cmd_record := C_VVC_CMD_DEFAULT;\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- t_vvc_result, t_vvc_result_queue_element, t_vvc_response and shared_vvc_response :\n")
    file_handle.write("  --\n")
    file_handle.write("  -- - Used for storing the result of a BFM procedure called by the VVC,\n")
    file_handle.write("  --   so that the result can be transported from the VVC to for example a sequencer via\n")
    file_handle.write("  --   fetch_result() as described in uvvm_vvc_framework/Common_VVC_Methods QuickRef.\n")
    file_handle.write("  -- - t_vvc_result includes the return value of the procedure in the BFM. It can also\n")
    file_handle.write("  --   be defined as a record if multiple values shall be transported from the BFM\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  subtype  t_vvc_result is std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);\n")
    print_linefeed(file_handle)
    file_handle.write("  type t_vvc_result_queue_element is record\n")
    file_handle.write("    cmd_idx       : natural;   -- from UVVM handshake mechanism\n")
    file_handle.write("    result        : t_vvc_result;\n")
    file_handle.write("  end record t_vvc_result_queue_element;\n")
    print_linefeed(file_handle)
    file_handle.write("  type t_vvc_response is record\n")
    file_handle.write("    fetch_is_accepted    : boolean;\n")
    file_handle.write("    transaction_result   : t_transaction_result;\n")
    file_handle.write("    result               : t_vvc_result;\n")
    file_handle.write("  end record t_vvc_response;\n")
    print_linefeed(file_handle)
    file_handle.write("  shared variable shared_vvc_response : t_vvc_response;\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- t_last_received_cmd_idx :\n")
    file_handle.write("  -- - Used to store the last queued cmd in VVC interpreter.\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  type t_last_received_cmd_idx is array (t_channel range <>, natural range <>) of integer;\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- shared_vvc_last_received_cmd_idx\n")
    file_handle.write("  --  - Shared variable used to get last queued index from VVC to sequencer\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  shared variable shared_vvc_last_received_cmd_idx : t_last_received_cmd_idx(t_channel'left to t_channel'right, 0 to" +
                      " C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => -1));\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Procedures\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  --function to_string (\n")
    file_handle.write("  --  result : t_vvc_result\n")
    file_handle.write("  --) return string;\n")
    print_linefeed(file_handle)
    file_handle.write("end package vvc_cmd_pkg;\n")
    print_linefeed(file_handle)


def add_vvc_cmd_pkg_body(file_handle):
    file_handle.write("package body vvc_cmd_pkg is\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Custom to_string overload needed when result is of a record type\n")
    file_handle.write("  --function to_string (\n")
    file_handle.write("  --  result : t_vvc_result\n")
    file_handle.write("  --) return string is\n")
    file_handle.write("  --begin\n")
    file_handle.write("  --  <USER_INPUT> Set the record fields from the t_vvc_result here\n")
    file_handle.write("  --   Example:\n")
    file_handle.write("  --   return to_string(result.data_array'length) & \" Words\";\n")
    file_handle.write("  --end function to_string;\n")
    print_linefeed(file_handle)
    file_handle.write("end package body vvc_cmd_pkg;\n")


def add_methods_pkg_includes(file_handle, vvc_name, features):
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_util;\n")
    file_handle.write("context uvvm_util.uvvm_util_context;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_vvc_framework;\n")
    file_handle.write("use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;\n")
    print_linefeed(file_handle)
    file_handle.write("use work." + vvc_name.lower() + "_bfm_pkg.all;\n")
    file_handle.write("use work.vvc_cmd_pkg.all;\n")
    file_handle.write("use work.td_target_support_pkg.all;\n")
    if features["transaction_pkg"]:
        file_handle.write("use work.transaction_pkg.all;\n")
    if features["scoreboard"]:
        file_handle.write("use work.vvc_sb_pkg.all;\n")
    print_linefeed(file_handle)
    file_handle.write(division_line + "\n")
    file_handle.write(division_line + "\n")


def add_methods_pkg_header(file_handle, vvc_name, vvc_channels, features):
    file_handle.write("package vvc_methods_pkg is\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Types and constants for the " + vvc_name.upper() + " VVC\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  constant C_VVC_NAME     : string := \"" + vvc_name.upper() + "_VVC\";\n")
    print_linefeed(file_handle)
    file_handle.write("  signal " + vvc_name.upper() + "_VVCT" + fill_with_n_spaces(vvc_name.__len__(), 13) +
                      ": t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);\n")
    file_handle.write("  alias  THIS_VVCT         : t_vvc_target_record is " + vvc_name.upper() + "_VVCT;\n")
    file_handle.write("  alias  t_bfm_config is t_" + vvc_name.lower() + "_bfm_config;\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Type found in UVVM-Util types_pkg\n")
    file_handle.write("  constant C_" + vvc_name.upper() + "_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (\n")
    file_handle.write("    delay_type                         => NO_DELAY,\n")
    file_handle.write("    delay_in_time                      => 0 ns,\n")
    file_handle.write("    inter_bfm_delay_violation_severity => WARNING\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)
    file_handle.write("  type t_vvc_config is record\n")
    file_handle.write("    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM " + 
                      "accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.\n")
    file_handle.write("    cmd_queue_count_max                   : natural;           -- Maximum pending number in command " + 
                      "executor before executor is full. Adding additional commands will result in an ERROR.\n")
    file_handle.write("    cmd_queue_count_threshold             : natural;           -- An alert with severity 'cmd_queue_count_threshold_severity' " + 
                      "will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.\n")
    file_handle.write("    cmd_queue_count_threshold_severity    : t_alert_level;     -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold.\n")
    file_handle.write("    result_queue_count_max                : natural;\n")
    file_handle.write("    result_queue_count_threshold          : natural;\n")
    file_handle.write("    result_queue_count_threshold_severity : t_alert_level;\n")
    file_handle.write("    bfm_config                            : t_bfm_config;      -- Configuration for the BFM. See BFM quick reference.\n")
    file_handle.write("    msg_id_panel                          : t_msg_id_panel;    -- VVC dedicated message ID panel.\n")
    file_handle.write("    unwanted_activity_severity            : t_alert_level;     -- Severity of alert to be initiated if unwanted activity on the DUT outputs is detected.\n")
    file_handle.write("  end record t_vvc_config;\n")
    print_linefeed(file_handle)
    if vvc_channels.__len__() == 1:
        file_handle.write("  type t_vvc_config_array is array (natural range <>) of t_vvc_config;\n")
    else:
        file_handle.write("  type t_vvc_config_array is array (t_channel range <>, natural range <>) of t_vvc_config;\n")
    print_linefeed(file_handle)
    file_handle.write("  constant C_" + vvc_name.upper() + "_VVC_CONFIG_DEFAULT : t_vvc_config := (\n")
    file_handle.write("    inter_bfm_delay                       => C_" + vvc_name.upper() + "_INTER_BFM_DELAY_DEFAULT,\n")
    file_handle.write("    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package\n")
    file_handle.write("    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,\n")
    file_handle.write("    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,\n")
    file_handle.write("    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,\n")
    file_handle.write("    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,\n")
    file_handle.write("    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,\n")
    file_handle.write("    bfm_config                            => C_" + vvc_name.upper() + "_BFM_CONFIG_DEFAULT,\n")
    file_handle.write("    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT,\n")
    file_handle.write("    unwanted_activity_severity            => C_UNWANTED_ACTIVITY_SEVERITY\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)
    file_handle.write("  type t_vvc_status is record\n")
    file_handle.write("    current_cmd_idx  : natural;\n")
    file_handle.write("    previous_cmd_idx : natural;\n")
    file_handle.write("    pending_cmd_cnt  : natural;\n")
    file_handle.write("  end record t_vvc_status;\n")
    print_linefeed(file_handle)
    if vvc_channels.__len__() == 1:
        file_handle.write("  type t_vvc_status_array is array (natural range <>) of t_vvc_status;\n")
    else:
        file_handle.write("  type t_vvc_status_array is array (t_channel range <>, natural range <>) of t_vvc_status;\n")
    print_linefeed(file_handle)
    file_handle.write("  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (\n")
    file_handle.write("    current_cmd_idx  => 0,\n")
    file_handle.write("    previous_cmd_idx => 0,\n")
    file_handle.write("    pending_cmd_cnt  => 0\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)
    if vvc_channels.__len__() == 1:
        file_handle.write("  shared variable shared_" + vvc_name.lower() + "_vvc_config : t_vvc_config_array(0 to "
                          "C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_" + vvc_name.upper() + "_VVC_CONFIG_DEFAULT);\n")
        file_handle.write("  shared variable shared_" + vvc_name.lower() + "_vvc_status : t_vvc_status_array(0 to "
                          "C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_VVC_STATUS_DEFAULT);\n")
    else:
        file_handle.write("  shared variable shared_" + vvc_name.lower() + "_vvc_config : t_vvc_config_array(t_channel'left"
                          " to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_" + vvc_name.upper() + "_VVC_CONFIG_DEFAULT));\n")
        file_handle.write("  shared variable shared_" + vvc_name.lower() + "_vvc_status : t_vvc_status_array(t_channel'left"
                          " to t_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_VVC_STATUS_DEFAULT));\n")
    if features["scoreboard"]:
        file_handle.write("  shared variable " + vvc_name.upper() + "_VVC_SB            : t_generic_sb;\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Methods dedicated to this VVC\n")
    file_handle.write("  -- - These procedures are called from the testbench in order for the VVC to execute\n")
    file_handle.write("  --   BFM calls towards the given interface. The VVC interpreter will queue these calls\n")
    file_handle.write("  --   and then the VVC executor will fetch the commands from the queue and handle the\n")
    file_handle.write("  --   actual BFM execution.\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)
    file_handle.write("  --<USER_INPUT> Please insert the VVC procedure declarations here \n")
    file_handle.write("  --Example with single VVC channel: \n")
    file_handle.write("  -- procedure " + vvc_name.lower() + "_write (\n")
    file_handle.write("  --   signal   VVCT                : inout t_vvc_target_record;\n")
    file_handle.write("  --   constant vvc_instance_idx    : in    integer;\n")
    file_handle.write("  --   constant addr                : in    unsigned;\n")
    file_handle.write("  --   constant data                : in    std_logic_vector;\n")
    file_handle.write("  --   constant msg                 : in    string;\n")
    file_handle.write("  --   constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;\n")
    file_handle.write("  --   constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs\n")
    file_handle.write("  -- );\n")
    print_linefeed(file_handle)
    file_handle.write("  --Example with multiple VVC channels: \n")
    file_handle.write("  -- procedure " + vvc_name.lower() + "_read (\n")
    file_handle.write("  --   signal   VVCT                : inout t_vvc_target_record;\n")
    file_handle.write("  --   constant vvc_instance_idx    : in    integer;\n")
    file_handle.write("  --   constant channel             : in    t_channel;\n")
    file_handle.write("  --   constant addr                : in    unsigned;\n")
    file_handle.write("  --   constant data                : in    std_logic_vector;\n")
    file_handle.write("  --   constant msg                 : in    string;\n")
    file_handle.write("  --   constant alert_level         : in    t_alert_level  := ERROR;\n")
    file_handle.write("  --   constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;\n")
    file_handle.write("  --   constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs\n")
    file_handle.write("  -- );\n")
    print_linefeed(file_handle)

    if features["transaction_info"]:
        file_handle.write("  " + division_line + "\n")
        file_handle.write("  -- Transaction info methods\n")
        file_handle.write("  " + division_line + "\n")
        file_handle.write("  procedure set_global_vvc_transaction_info (\n")
        file_handle.write("    signal   vvc_transaction_info_trigger : inout std_logic;\n")
        file_handle.write("    variable vvc_transaction_info_group   : inout t_transaction_group;\n")
        file_handle.write("    constant vvc_cmd                      : in t_vvc_cmd_record;\n")
        file_handle.write("    constant vvc_config                   : in t_vvc_config;\n")
        file_handle.write("    constant transaction_status           : in t_transaction_status;\n")
        file_handle.write("    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)
        file_handle.write("  procedure set_global_vvc_transaction_info (\n")
        file_handle.write("    signal   vvc_transaction_info_trigger : inout std_logic;\n")
        file_handle.write("    variable vvc_transaction_info_group   : inout t_transaction_group;\n")
        file_handle.write("    constant vvc_cmd                      : in t_vvc_cmd_record;\n")
        file_handle.write("    constant vvc_result                   : in t_vvc_result;\n")
        file_handle.write("    constant transaction_status           : in t_transaction_status;\n")
        file_handle.write("    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)
        file_handle.write("  procedure reset_vvc_transaction_info (\n")
        file_handle.write("    variable vvc_transaction_info_group  : inout t_transaction_group;\n")
        file_handle.write("    constant vvc_cmd                     : in t_vvc_cmd_record\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)

    file_handle.write("end package vvc_methods_pkg;\n")
    print_linefeed(file_handle)


def add_methods_pkg_body(file_handle, vvc_name, features):
    file_handle.write("package body vvc_methods_pkg is\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Methods dedicated to this VVC\n")
    file_handle.write("  " + division_line + "\n")
    print_linefeed(file_handle)
    file_handle.write("  --<USER_INPUT> Please insert the VVC procedure implementations here.\n")
    file_handle.write("  -- These procedures will be used to forward commands to the VVC executor, which will\n")
    file_handle.write("  -- call the corresponding BFM procedures. \n")
    file_handle.write("  -- Example using single channel:\n")
    file_handle.write("  -- procedure " + vvc_name.lower() + "_write( \n")
    file_handle.write("  --   signal   VVCT                : inout t_vvc_target_record;\n")
    file_handle.write("  --   constant vvc_instance_idx    : in    integer;\n")
    file_handle.write("  --   constant addr                : in    unsigned;\n")
    file_handle.write("  --   constant data                : in    std_logic_vector;\n")
    file_handle.write("  --   constant msg                 : in    string;\n")
    file_handle.write("  --   constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;\n")
    file_handle.write("  --   constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs\n")
    file_handle.write("  -- ) is\n")
    file_handle.write("  --   constant C_PROC_NAME : string := \"" + vvc_name.lower() + "_write\";\n")
    file_handle.write("  --   constant C_PROC_CALL : string := C_PROC_NAME & \"(\" & to_string(VVCT, vvc_instance_idx)  -- First part common for all\n")
    file_handle.write("  --            & \", \" & to_string(addr, HEX, AS_IS, INCL_RADIX) & \", \" & to_string(data, HEX, AS_IS, INCL_RADIX) & \")\";\n")
    file_handle.write("  --   variable v_normalised_addr    : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0) := \n"
                      "  --            normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, \"addr\", \"shared_vvc_cmd.addr\", C_PROC_CALL" +
                      " & \" called with too wide addr. \" & msg);\n")
    file_handle.write("  --   variable v_normalised_data    : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0) := \n"
                      "  --            normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, \"data\", \"shared_vvc_cmd.data\", C_PROC_CALL" +
                      " & \" called with too wide data. \" & msg);\n")
    file_handle.write("  --   variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;\n")
    file_handle.write("  -- begin\n")
    file_handle.write("  -- -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record\n")
    file_handle.write("  -- -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd\n")
    file_handle.write("  -- -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC\n")
    file_handle.write("  --   set_general_target_and_command_fields(VVCT, vvc_instance_idx, C_PROC_CALL, msg, QUEUED, WRITE);\n")
    file_handle.write("  --   shared_vvc_cmd.addr                := v_normalised_addr;\n")
    file_handle.write("  --   shared_vvc_cmd.data                := v_normalised_data;\n")
    file_handle.write("  --   shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;\n")
    file_handle.write("  --   if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then\n")
    file_handle.write("  --     v_msg_id_panel := parent_msg_id_panel;\n")
    file_handle.write("  --   end if;\n")
    file_handle.write("  --   send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);\n")
    file_handle.write("  -- end procedure;\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Example using multiple channels:\n")
    file_handle.write("  -- procedure " + vvc_name.lower() + "_receive (\n")
    file_handle.write("  --   signal   VVCT                : inout t_vvc_target_record;\n")
    file_handle.write("  --   constant vvc_instance_idx    : in    integer;\n")
    file_handle.write("  --   constant channel             : in    t_channel;\n")
    file_handle.write("  --   constant msg                 : in    string;\n")
    file_handle.write("  --   constant alert_level         : in    t_alert_level  := ERROR;\n")
    file_handle.write("  --   constant scope               : in    string         := C_VVC_CMD_SCOPE_DEFAULT;\n")
    file_handle.write("  --   constant parent_msg_id_panel : in    t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs\n")
    file_handle.write("  -- ) is\n")
    file_handle.write("  --   constant C_PROC_NAME : string := \"" + vvc_name.lower() + "_receive\";\n")
    file_handle.write("  --   constant C_PROC_CALL : string := C_PROC_NAME & \"(\" & to_string(VVCT, vvc_instance_idx, channel) & \")\";\n")
    file_handle.write("  --   variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;\n")
    file_handle.write("  -- begin\n")
    file_handle.write("  -- -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record\n")
    file_handle.write("  -- -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd\n")
    file_handle.write("  -- -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC\n")
    file_handle.write("  --   set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, C_PROC_CALL, msg, QUEUED, RECEIVE);\n")
    file_handle.write("  --   shared_vvc_cmd.alert_level         := alert_level;\n")
    file_handle.write("  --   shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;\n")
    file_handle.write("  --   if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then\n")
    file_handle.write("  --     v_msg_id_panel := parent_msg_id_panel;\n")
    file_handle.write("  --   end if;\n")
    file_handle.write("  --   send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);\n")
    file_handle.write("  -- end procedure;\n")
    print_linefeed(file_handle)

    if features["transaction_info"]:
        file_handle.write("  " + division_line + "\n")
        file_handle.write("  -- Transaction info methods\n")
        file_handle.write("  " + division_line + "\n")

        file_handle.write("  procedure set_global_vvc_transaction_info (\n")
        file_handle.write("    signal   vvc_transaction_info_trigger : inout std_logic;\n")
        file_handle.write("    variable vvc_transaction_info_group   : inout t_transaction_group;\n")
        file_handle.write("    constant vvc_cmd                      : in t_vvc_cmd_record;\n")
        file_handle.write("    constant vvc_config                   : in t_vvc_config;\n")
        file_handle.write("    constant transaction_status           : in t_transaction_status;\n")
        file_handle.write("    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT\n")
        file_handle.write("  ) is\n")
        file_handle.write("  begin\n")
        file_handle.write("  -- <USER_INPUT> Please insert the VVC operations here with the appropriate fields.\n")
        file_handle.write("  --  case vvc_cmd.operation is\n")
        file_handle.write("  --    when WRITE | READ =>\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.operation          := vvc_cmd.operation;\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.address            := vvc_cmd.addr;\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.data               := vvc_cmd.data;\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.vvc_meta.msg       := vvc_cmd.msg;\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.vvc_meta.cmd_idx   := vvc_cmd.cmd_idx;\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.transaction_status := transaction_status;\n")
        file_handle.write("  --      gen_pulse(vvc_transaction_info_trigger, 0 ns, \"pulsing global vvc transaction info trigger\", scope, ID_NEVER);\n")
        print_linefeed(file_handle)
        file_handle.write("  --    when others =>\n")
        file_handle.write("  --      alert(TB_ERROR, \"VVC operation not recognized\", scope);\n")
        file_handle.write("  --  end case;\n")
        print_linefeed(file_handle)
        file_handle.write("    wait for 0 ns;\n")
        file_handle.write("  end procedure set_global_vvc_transaction_info;\n")
        print_linefeed(file_handle)

        file_handle.write("  procedure set_global_vvc_transaction_info (\n")
        file_handle.write("    signal   vvc_transaction_info_trigger : inout std_logic;\n")
        file_handle.write("    variable vvc_transaction_info_group   : inout t_transaction_group;\n")
        file_handle.write("    constant vvc_cmd                      : in t_vvc_cmd_record;\n")
        file_handle.write("    constant vvc_result                   : in t_vvc_result;\n")
        file_handle.write("    constant transaction_status           : in t_transaction_status;\n")
        file_handle.write("    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT\n")
        file_handle.write("  ) is\n")
        file_handle.write("  begin\n")
        file_handle.write("  -- <USER_INPUT> Please insert the VVC operations here with the appropriate fields.\n")
        file_handle.write("  --  case vvc_cmd.operation is\n")
        file_handle.write("  --    when READ =>\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.data               := vvc_result;\n")
        file_handle.write("  --      vvc_transaction_info_group.bt.transaction_status := transaction_status;\n")
        file_handle.write("  --      gen_pulse(vvc_transaction_info_trigger, 0 ns, \"pulsing global vvc transaction info trigger\", scope, ID_NEVER);\n")
        print_linefeed(file_handle)
        file_handle.write("  --    when others =>\n")
        file_handle.write("  --      alert(TB_ERROR, \"VVC operation does not update vvc_result \", scope);\n")
        file_handle.write("  --  end case;\n")
        print_linefeed(file_handle)
        file_handle.write("    wait for 0 ns;\n")
        file_handle.write("  end procedure set_global_vvc_transaction_info;\n")
        print_linefeed(file_handle)

        file_handle.write("  procedure reset_vvc_transaction_info (\n")
        file_handle.write("    variable vvc_transaction_info_group  : inout t_transaction_group;\n")
        file_handle.write("    constant vvc_cmd                     : in t_vvc_cmd_record\n")
        file_handle.write("  ) is\n")
        file_handle.write("  begin\n")
        file_handle.write("  -- <USER_INPUT> Please insert the VVC operations here.\n")
        file_handle.write("  --  case vvc_cmd.operation is\n")
        file_handle.write("  --    when WRITE | READ =>\n")
        file_handle.write("  --      vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;\n")
        print_linefeed(file_handle)
        file_handle.write("  --    when others =>\n")
        file_handle.write("  --      null;\n")
        file_handle.write("  --  end case;\n")
        print_linefeed(file_handle)
        file_handle.write("    wait for 0 ns;\n")
        file_handle.write("  end procedure reset_vvc_transaction_info;\n")

        print_linefeed(file_handle)

    file_handle.write("end package body vvc_methods_pkg;\n")


def add_bfm_pkg_includes(file_handle):
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_util;\n")
    file_handle.write("context uvvm_util.uvvm_util_context;\n")
    print_linefeed(file_handle)
    file_handle.write(division_line + "\n")
    file_handle.write(division_line + "\n")


def add_bfm_pkg_header(file_handle, vvc_name):
    file_handle.write("package " + vvc_name.lower() + "_bfm_pkg is\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- Types and constants for " + vvc_name.upper() + " BFM\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  constant C_BFM_SCOPE : string := \"" + vvc_name.upper() + " BFM\";\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Optional interface record for BFM signals\n")
    file_handle.write("  -- type t_" + vvc_name.lower() + "_if is record\n")
    file_handle.write("    --<USER_INPUT> Insert all BFM signals here\n")
    file_handle.write("    -- Example:\n")
    file_handle.write("    -- cs      : std_logic;          -- to dut\n")
    file_handle.write("    -- addr    : unsigned;           -- to dut\n")
    file_handle.write("    -- rena    : std_logic;          -- to dut\n")
    file_handle.write("    -- wena    : std_logic;          -- to dut\n")
    file_handle.write("    -- wdata   : std_logic_vector;   -- to dut\n")
    file_handle.write("    -- ready   : std_logic;          -- from dut\n")
    file_handle.write("    -- rdata   : std_logic_vector;   -- from dut\n")
    file_handle.write("  -- end record t_" + vvc_name.lower() + "_if;\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Configuration record to be assigned in the test harness.\n")
    file_handle.write("  type t_" + vvc_name.lower() + "_bfm_config is record\n")
    file_handle.write("    --<USER_INPUT> Insert all BFM config parameters here\n")
    file_handle.write("    -- Example:\n")
    file_handle.write("    id_for_bfm               : t_msg_id; -- To replace default log msg IDs. <USER_INPUT> Adapt name to msg IDs used in this BFM\n")
    file_handle.write("    -- id_for_bfm_wait          : t_msg_id; -- To replace default log msg IDs. <USER_INPUT> Adapt name to msg IDs used in this BFM\n")
    file_handle.write("    -- id_for_bfm_poll          : t_msg_id; -- To replace default log msg IDs. <USER_INPUT> Adapt name to msg IDs used in this BFM\n")
    file_handle.write("    -- max_wait_cycles          : integer;\n")
    file_handle.write("    -- max_wait_cycles_severity : t_alert_level;\n")
    file_handle.write("    -- clock_period             : time;\n")
    file_handle.write("  end record t_" + vvc_name.lower() + "_bfm_config;\n")
    print_linefeed(file_handle)
    file_handle.write("  -- Define the default value for the BFM config\n")
    file_handle.write("  constant C_" + vvc_name.upper() + "_BFM_CONFIG_DEFAULT : t_" + vvc_name.lower() + "_bfm_config := (\n")
    file_handle.write("    --<USER_INPUT> Insert defaults for all BFM config parameters here\n")
    file_handle.write("    -- Example:\n")
    file_handle.write("    id_for_bfm               => ID_BFM      --<USER_INPUT> Adapt name and ID to msg IDs used in this BFM\n")
    file_handle.write("    -- id_for_bfm_wait          => ID_BFM_WAIT, --<USER_INPUT> Adapt name and ID to msg IDs used in this BFM\n")
    file_handle.write("    -- id_for_bfm_poll          => ID_BFM_POLL, --<USER_INPUT> Adapt name and ID to msg IDs used in this BFM\n")
    file_handle.write("    -- max_wait_cycles          => 10,\n")
    file_handle.write("    -- max_wait_cycles_severity => failure,\n")
    file_handle.write("    -- clock_period             => -1 ns\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- BFM procedures\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  --<USER_INPUT> Insert BFM procedure declarations here, e.g. read and write operations\n")
    file_handle.write("  -- It is recommended to also have an init function which sets the BFM signals to their default state\n")
    print_linefeed(file_handle)
    file_handle.write("end package " + vvc_name.lower() + "_bfm_pkg;\n")
    print_linefeed(file_handle)


def add_bfm_pkg_body(file_handle, vvc_name):
    file_handle.write("package body " + vvc_name.lower() + "_bfm_pkg is\n")
    print_linefeed(file_handle)
    file_handle.write("  --<USER_INPUT> Insert BFM procedure implementation here.\n")
    print_linefeed(file_handle)
    file_handle.write("end package body " + vvc_name.lower() + "_bfm_pkg;\n")


def generate_bfm_skeleton(vvc_name):
    f = open("output/" + vvc_name.lower() + "_bfm_pkg.vhd", 'w')
    add_vvc_header(f)
    add_bfm_pkg_includes(f)
    add_bfm_pkg_header(f, vvc_name)
    add_bfm_pkg_body(f, vvc_name)
    f.close()


def generate_vvc_methods_pkg_file(vvc_name, vvc_channels, features):
    f = open("output/vvc_methods_pkg.vhd", 'w')
    add_vvc_header(f)
    add_methods_pkg_includes(f, vvc_name, features)
    add_methods_pkg_header(f, vvc_name, vvc_channels, features)
    add_methods_pkg_body(f, vvc_name, features)
    f.close()


def generate_vvc_cmd_pkg_file(features):
    f = open("output/vvc_cmd_pkg.vhd", 'w')
    add_vvc_header(f)
    add_vvc_cmd_pkg_includes(f, features)
    add_vvc_cmd_pkg_header(f, features)
    add_vvc_cmd_pkg_body(f)
    f.close()


def add_transaction_pkg(file_handle, vvc_name, vvc_channels, features):
    add_vvc_header(file_handle)
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library uvvm_util;\n")
    file_handle.write("context uvvm_util.uvvm_util_context;\n")
    print_linefeed(file_handle)
    file_handle.write(division_line + "\n")
    file_handle.write(division_line + "\n")
    file_handle.write("package transaction_pkg is\n")
    print_linefeed(file_handle)
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  -- t_operation\n")
    file_handle.write("  -- - VVC and BFM operations\n")
    file_handle.write("  " + division_line + "\n")
    file_handle.write("  type t_operation is (\n")
    file_handle.write("    -- UVVM common\n")
    file_handle.write("    NO_OPERATION,\n")
    file_handle.write("    AWAIT_COMPLETION,\n")
    file_handle.write("    AWAIT_ANY_COMPLETION,\n")
    file_handle.write("    ENABLE_LOG_MSG,\n")
    file_handle.write("    DISABLE_LOG_MSG,\n")
    file_handle.write("    FLUSH_COMMAND_QUEUE,\n")
    file_handle.write("    FETCH_RESULT,\n")
    file_handle.write("    INSERT_DELAY,\n")
    file_handle.write("    TERMINATE_CURRENT_COMMAND\n")
    file_handle.write("    -- VVC local\n")
    file_handle.write("    --<USER_INPUT> Expand this type with enums for BFM procedures.\n")
    file_handle.write("    -- Example: \n")
    file_handle.write("    -- TRANSMIT, RECEIVE, EXPECT\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)
    file_handle.write("  --<USER_INPUT> Create constants for the maximum sizes to use in this VVC.\n")
    file_handle.write("  -- You can create VVCs with smaller sizes than these constants, but not larger.\n")
    file_handle.write("  -- For example, given a VVC with parallel data bus and address bus, constraints\n")
    file_handle.write("  -- should be added for maximum data length and address length.\n")
    file_handle.write("  -- Note: if these constants are to be flexible, create similar constants in adaptations_pkg\n")
    file_handle.write("  -- and use them to assign these constants, see other UVVM VIPs for guidance on how it's done.\n")
    file_handle.write("  -- Example:\n")
    file_handle.write("  constant C_VVC_CMD_DATA_MAX_LENGTH   : natural := 32;\n")
    file_handle.write("  --constant C_VVC_CMD_ADDR_MAX_LENGTH   : natural := 32;\n")
    file_handle.write("  constant C_VVC_CMD_STRING_MAX_LENGTH : natural := 300;\n")
    file_handle.write("  constant C_VVC_MAX_INSTANCE_NUM      : natural := C_MAX_VVC_INSTANCE_NUM;\n")
    print_linefeed(file_handle)

    if features["transaction_info"]:
        file_handle.write("  " + division_line + "\n")
        file_handle.write("  -- Transaction info types, constants and global signal\n")
        file_handle.write("  " + division_line + "\n")
        print_linefeed(file_handle)
        file_handle.write("  -- VVC Meta\n")
        file_handle.write("  type t_vvc_meta is record\n")
        file_handle.write("    msg     : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);\n")
        file_handle.write("    cmd_idx : integer;\n")
        file_handle.write("  end record t_vvc_meta;\n")
        print_linefeed(file_handle)
        file_handle.write("  constant C_VVC_META_DEFAULT : t_vvc_meta := (\n")
        file_handle.write("    msg     => (others => ' '),\n")
        file_handle.write("    cmd_idx => -1\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)
        file_handle.write("  -- NOTE:\n")
        file_handle.write("  --   If compound transaction is needed see example usage in Bitvis VIP SBI.\n")
        file_handle.write("  --   If sub transaction is needed see example usage in Bitvis VIP Avalon-MM.\n")
        file_handle.write("  -- Base transaction\n")
        file_handle.write("  type t_base_transaction is record\n")
        file_handle.write("    operation           : t_operation;\n")
        file_handle.write("    --<USER_INPUT> Insert transaction information here.\n")
        file_handle.write("    --address             : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0);\n")
        file_handle.write("    --data                : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);\n")
        file_handle.write("    vvc_meta            : t_vvc_meta;\n")
        file_handle.write("    transaction_status  : t_transaction_status;\n")
        file_handle.write("  end record t_base_transaction;\n")
        print_linefeed(file_handle)
        file_handle.write("  constant C_BASE_TRANSACTION_SET_DEFAULT : t_base_transaction := (\n")
        file_handle.write("    operation           => NO_OPERATION,\n")
        file_handle.write("    --<USER_INPUT> Insert transaction information here.\n")
        file_handle.write("    --address             => (others => '0'),\n")
        file_handle.write("    --data                => (others => '0'),\n")
        file_handle.write("    vvc_meta            => C_VVC_META_DEFAULT,\n")
        file_handle.write("    transaction_status  => INACTIVE\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)
        file_handle.write("  -- Transaction group\n")
        file_handle.write("  type t_transaction_group is record\n")
        file_handle.write("    bt : t_base_transaction;\n")
        file_handle.write("  end record t_transaction_group;\n")
        print_linefeed(file_handle)
        file_handle.write("  constant C_TRANSACTION_GROUP_DEFAULT : t_transaction_group := (\n")
        file_handle.write("    bt => C_BASE_TRANSACTION_SET_DEFAULT\n")
        file_handle.write("  );\n")
        print_linefeed(file_handle)
        if vvc_channels.__len__() == 1:
            file_handle.write("  -- Global vvc_transaction_info trigger signal\n")
            file_handle.write("  type t_" + vvc_name.lower() + "_transaction_trigger_array is array (natural range <>) of std_logic;\n")
            file_handle.write("  signal global_" + vvc_name.lower() + "_vvc_transaction_trigger : t_" + vvc_name.lower() +
                              "_transaction_trigger_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => '0');\n")
            print_linefeed(file_handle)
            file_handle.write("  -- Shared vvc_transaction_info info variable\n")
            file_handle.write("  type t_" + vvc_name.lower() + "_transaction_group_array is array (natural range <>) of t_transaction_group;\n")
            file_handle.write("  shared variable shared_" + vvc_name.lower() + "_vvc_transaction_info : t_" + vvc_name.lower() +
                              "_transaction_group_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_TRANSACTION_GROUP_DEFAULT);\n")
        else:
            first_channel = vvc_channels[0].name.upper()
            last_channel = vvc_channels[len(vvc_channels) - 1].name.upper()
            file_handle.write("  subtype t_sub_channel is t_channel range " + first_channel + " to " + last_channel + ";\n")
            print_linefeed(file_handle)
            file_handle.write("  -- Global vvc_transaction_info trigger signal\n")
            file_handle.write("  type t_" + vvc_name.lower() + "_transaction_trigger_array is array (t_sub_channel range <>, natural range <>) of std_logic;\n")
            file_handle.write("  signal global_" + vvc_name.lower() + "_vvc_transaction_trigger : t_" + vvc_name.lower() +
                              "_transaction_trigger_array(t_sub_channel'left to t_sub_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => '0'));\n")
            print_linefeed(file_handle)
            file_handle.write("  -- Shared vvc_transaction_info info variable\n")
            file_handle.write("  type t_" + vvc_name.lower() + "_transaction_group_array is array (t_sub_channel range <>, natural range <>) of t_transaction_group;\n")
            file_handle.write("  shared variable shared_" + vvc_name.lower() + "_vvc_transaction_info : t_" + vvc_name.lower() +
                              "_transaction_group_array(t_sub_channel'left to t_sub_channel'right, 0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => (others => C_TRANSACTION_GROUP_DEFAULT));\n")

    print_linefeed(file_handle)
    file_handle.write("end package transaction_pkg;\n")


def generate_transaction_pkg_file(vvc_name, vvc_channels, features):
    if features["transaction_pkg"]:
        f = open("output/transaction_pkg.vhd", 'w')
        add_transaction_pkg(f, vvc_name, vvc_channels, features)
        f.close()


def add_vvc_sb_pkg(file_handle, vvc_name, vvc_channels, features):
    add_vvc_header(file_handle)

    file_handle.write(division_line + "\n")
    file_handle.write("--  vvc_sb_pkg\n")
    file_handle.write(division_line + "\n")
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library bitvis_vip_scoreboard;\n")
    print_linefeed(file_handle)
    if features["transaction_pkg"]:
        file_handle.write("use work.transaction_pkg.all;\n")
    else:
        file_handle.write("use work.vvc_cmd_pkg.all;\n")
    print_linefeed(file_handle)
    file_handle.write("package vvc_sb_pkg is new bitvis_vip_scoreboard.generic_sb_pkg\n")
    file_handle.write("  generic map (\n")
    file_handle.write("    t_element         => std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0),\n")
    file_handle.write("    element_match     => std_match,\n")
    file_handle.write("    to_string_element => to_string\n")
    file_handle.write("  );\n")
    print_linefeed(file_handle)

    file_handle.write(division_line + "\n")
    file_handle.write("--  vvc_sb_support_pkg\n")
    file_handle.write(division_line + "\n")
    file_handle.write("library ieee;\n")
    file_handle.write("use ieee.std_logic_1164.all;\n")
    file_handle.write("use ieee.numeric_std.all;\n")
    print_linefeed(file_handle)
    file_handle.write("library bitvis_vip_scoreboard;\n")
    file_handle.write("use bitvis_vip_scoreboard.generic_sb_support_pkg.all;\n")
    print_linefeed(file_handle)
    if features["transaction_pkg"]:
        file_handle.write("use work.transaction_pkg.all;\n")
    else:
        file_handle.write("use work.vvc_cmd_pkg.all;\n")
    print_linefeed(file_handle)
    file_handle.write("package vvc_sb_support_pkg is\n")
    file_handle.write("  -- The data parameter used in the scoreboard procedures needs to have the same length as\n")
    file_handle.write("  -- the t_element defined in the VVC's built-in scoreboard, since even though it is a generic\n")
    file_handle.write("  -- type, it constrained during elaboration time.\n")
    file_handle.write("  -- This function is used to pad the data without having to know the exact length of t_element.\n")
    file_handle.write("  function pad_" + vvc_name.lower() + "_sb (\n")
    file_handle.write("    constant data : in std_logic_vector\n")
    file_handle.write("  ) return std_logic_vector;\n")
    file_handle.write("end package vvc_sb_support_pkg;\n")
    print_linefeed(file_handle)
    file_handle.write("package body vvc_sb_support_pkg is\n")
    file_handle.write("  function pad_" + vvc_name.lower() + "_sb (\n")
    file_handle.write("    constant data : in std_logic_vector\n")
    file_handle.write("  ) return std_logic_vector is \n")
    file_handle.write("  begin\n")
    file_handle.write("    return pad_sb_slv(data, C_VVC_CMD_DATA_MAX_LENGTH);\n")
    file_handle.write("  end function pad_" + vvc_name.lower() + "_sb;\n")
    file_handle.write("end package body vvc_sb_support_pkg;\n")
    print_linefeed(file_handle)


def generate_vvc_sb_pkg_file(vvc_name, vvc_channels, features):
    if features["scoreboard"]:
        f = open("output/vvc_sb_pkg.vhd", 'w')
        add_vvc_sb_pkg(f, vvc_name, vvc_channels, features)
        f.close()


def add_vvc_context(file_handle, vvc_name, features):
    add_vvc_header(file_handle)
    file_handle.write("context vvc_context is\n")
    file_handle.write("  library vip_" + vvc_name.lower() + ";\n")
    if features["transaction_pkg"]:
        file_handle.write("  use vip_" + vvc_name.lower() + ".transaction_pkg.all;\n")
    file_handle.write("  use vip_" + vvc_name.lower() + ".vvc_methods_pkg.all;\n")
    file_handle.write("  use vip_" + vvc_name.lower() + ".td_vvc_framework_common_methods_pkg.all;\n")
    file_handle.write("  use vip_" + vvc_name.lower() + "." + vvc_name.lower() + "_bfm_pkg.all;\n")
    file_handle.write("end context;\n")


def generate_vvc_context_file(vvc_name, features):
    f = open("output/vvc_context.vhd", 'w')
    add_vvc_context(f, vvc_name, features)
    f.close()


def generate_vvc_file(vvc_name, vvc_channels, features):

    # Create main VVC, or leaf VVCs if multiple channels
    for channel_idx, channel in enumerate(vvc_channels):

        num_of_queues = channel.number_of_executors()

        if channel.name == "NA":
            vvc_file_name = "output/" + vvc_name.lower() + "_vvc.vhd"
        else:
            vvc_file_name = "output/" + vvc_name.lower() + "_" + channel.name.lower() + "_vvc.vhd"
        f = open(vvc_file_name, 'w')

        add_vvc_header(f)
        add_leaf_includes(f, vvc_name, channel_idx, features)
        add_vvc_entity(f, vvc_name, channel.name)
        add_architecture_declaration(f, vvc_name, channel, features, num_of_queues)
        add_vvc_constructor(f, vvc_name)
        add_vvc_interpreter(f, channel, features, num_of_queues)
        add_vvc_executor(f, vvc_name, channel, channel_idx, features)
        if (num_of_queues > 1):
            for i in range(1, num_of_queues):
                add_vvc_pipeline_step(f, vvc_name, channel.executor_names[i], i, features)

        add_vvc_terminator(f)
        if features["unwanted_activity"]:
            add_clock_period(f)
            add_unwanted_activity_detection(f, vvc_name, channel.name)
        add_end_of_architecture(f)

        f.close()

    # Create wrapper if multiple channels
    if vvc_channels.__len__() != 1:
        vvc_file_name = "output/" + vvc_name.lower() + "_vvc.vhd"
        f = open(vvc_file_name, 'w')

        add_vvc_header(f)
        add_wrapper_includes(f, vvc_name)
        add_vvc_entity(f, vvc_name, "NA")
        add_wrapper_architecture_declaration(f, vvc_name)
        for channel in vvc_channels:
            add_leaf_vvc_entity(f, vvc_name, channel.name)
        add_wrapper_architecture_end(f)

        f.close()


# Entry point for the vvc_generator script
def main():
    vvc_name = "not_set"
    number_of_channels = 1
    vvc_channels = []
    vvc_name = get_vvc_name()

    features = get_generating_level()

    number_of_channels = get_number_of_channels()
    vvc_channels = set_channels(number_of_channels)
    number_of_channels_with_multiple_executors = 0

    print_multiple_executor_info()

    # Get number of channels with multiple executors
    if number_of_channels == 1:
        if yes_no_question("Shall the VVC have multiple executors?"):
            vvc_channels[0].append_executor(get_list_of_executors())
            number_of_channels_with_multiple_executors = 1
    else:
        number_of_channels_with_multiple_executors = get_number_of_channels_with_multiple_executors(number_of_channels)

    # If channels have multiple executors
    # One channel
    if number_of_channels_with_multiple_executors == 1 and number_of_channels > 1:
        for channel in range(0, number_of_channels):
            if yes_no_question("Shall channel " + vvc_channels[channel].get_name() + " have multiple executors?"):
                vvc_channels[channel].append_executor(get_list_of_executors())
                break

    # Multiple channels
    elif number_of_channels_with_multiple_executors > 1:

        # If equal names and numbers of executors, only type in information once
        if yes_no_question("Shall all channels with multiple executors have equal name and amount of executors?"):
            executor_names = get_list_of_executors()

            # If all channels
            if number_of_channels_with_multiple_executors == number_of_channels:
                for channel in range(0, number_of_channels):
                    vvc_channels[channel].append_executor(executor_names)

            # If not all channels, ask which one
            else:
                number_of_channels_added = 0
                for channel in range(0, number_of_channels):
                    if yes_no_question("Shall channel " + vvc_channels[channel].get_name() + " have multiple executors?"):
                        vvc_channels[channel].append_executor(executor_names)
                        number_of_channels_added += 1
                    if number_of_channels_added == number_of_channels - 1:
                        break

        # Individual names and numbers of executors, loop through channels
        else:
            number_of_channels_added = 0
            for channel in range(0, number_of_channels):
                if yes_no_question("Shall channel " + vvc_channels[channel].get_name() + " have multiple executors?"):
                    vvc_channels[channel].append_executor(get_list_of_executors())
                    number_of_channels_added += 1
                if number_of_channels_added == number_of_channels - 1:
                    break

    if not os.path.exists("output"):
        os.makedirs("output")

    generate_vvc_file(vvc_name, vvc_channels, features)
    generate_vvc_cmd_pkg_file(features)
    generate_vvc_methods_pkg_file(vvc_name, vvc_channels, features)
    generate_bfm_skeleton(vvc_name)
    generate_transaction_pkg_file(vvc_name, vvc_channels, features)
    generate_vvc_sb_pkg_file(vvc_name, vvc_channels, features)
    generate_vvc_context_file(vvc_name, features)

    print("\nThe vvc_generator script is now finished")
    print("The generated VVC can be found in the output folder")
    print("Note: generated code is provided as starting point for building a VVC.")
    print("      Please follow the instructions marked '--<USER_INPUT>' in the generated files.")

if __name__ == '__main__':
    main()
