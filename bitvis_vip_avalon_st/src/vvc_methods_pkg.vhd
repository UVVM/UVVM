--================================================================================================================================
-- Copyright 2020 Bitvis
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.local_adaptations_pkg.all;
use work.avalon_st_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;

--================================================================================================================================
--================================================================================================================================
package vvc_methods_pkg is

  --==========================================================================================
  -- Types and constants for the AVALON_ST VVC 
  --==========================================================================================
  constant C_VVC_NAME : string := "AVALON_ST_VVC";

  signal AVALON_ST_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT       : t_vvc_target_record is AVALON_ST_VVCT;
  alias t_bfm_config is t_avalon_st_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_AVALON_ST_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural; -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural; -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level; -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold.
    result_queue_count_max                : natural;
    result_queue_count_threshold_severity : t_alert_level;
    result_queue_count_threshold          : natural;
    bfm_config                            : t_avalon_st_bfm_config; -- Configuration for the BFM. See BFM quick reference.
    msg_id_panel                          : t_msg_id_panel; -- VVC dedicated message ID panel.
    parent_msg_id_panel                   : t_msg_id_panel; --UVVM: temporary fix for HVVC, remove in v3.0
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_AVALON_ST_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_AVALON_ST_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_AVALON_ST_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT,
    parent_msg_id_panel                   => C_VVC_MSG_ID_PANEL_DEFAULT
  );

  type t_vvc_status is record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record;

  type t_vvc_status_array is array (natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );

  shared variable shared_avalon_st_vvc_config : t_vvc_config_array(0 to C_AVALON_ST_MAX_VVC_INSTANCE_NUM - 1) := (others => C_AVALON_ST_VVC_CONFIG_DEFAULT);
  shared variable shared_avalon_st_vvc_status : t_vvc_status_array(0 to C_AVALON_ST_MAX_VVC_INSTANCE_NUM - 1) := (others => C_VVC_STATUS_DEFAULT);

  --==========================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --==========================================================================================
  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant channel_value       : in std_logic_vector;
    constant data_array          : in t_slv_array;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure avalon_st_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_array          : in t_slv_array;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_array_len      : in natural;
    constant data_word_size      : in natural;
    constant data_routing        : in t_data_routing;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure avalon_st_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_array_len      : in natural;
    constant data_word_size      : in natural;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant channel_exp         : in std_logic_vector;
    constant data_exp            : in t_slv_array;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure avalon_st_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in t_slv_array;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  --==============================================================================
  -- Transaction info methods
  --==============================================================================
  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT);

  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_result                   : in t_vvc_result;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT);

  procedure reset_vvc_transaction_info(
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record);

  --==============================================================================
  -- VVC Activity
  --==============================================================================
  procedure update_vvc_activity_register(signal   global_trigger_vvc_activity_register : inout std_logic;
                                         variable vvc_status                           : inout t_vvc_status;
                                         constant activity                             : in t_activity;
                                         constant entry_num_in_vvc_activity_register   : in integer;
                                         constant last_cmd_idx_executed                : in natural;
                                         constant command_queue_is_empty               : in boolean;
                                         constant scope                                : in string := C_VVC_NAME);

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --==========================================================================================
  -- Methods dedicated to this VVC
  --==========================================================================================
  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Transmit
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant channel_value       : in std_logic_vector;
    constant data_array          : in t_slv_array;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "avalon_st_transmit";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(data_array'length) & " words, ch:" & to_string(channel_value, DEC, AS_IS) & ")";
    constant c_data_word_size  : natural                                                                := data_array(data_array'low)'length;
    variable v_normalized_chan : std_logic_vector(C_VVC_CMD_CHAN_MAX_LENGTH - 1 downto 0)               := normalize_and_check(channel_value, shared_vvc_cmd.channel_value, ALLOW_NARROWER, "channel", "shared_vvc_cmd.channel", proc_call & ". " & msg);
    variable v_normalized_data : t_slv_array(0 to data_array'length - 1)(c_data_word_size - 1 downto 0) := data_array;
    variable v_msg_id_panel    : t_msg_id_panel                                                         := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, TRANSMIT);
    shared_vvc_cmd.channel_value        := v_normalized_chan;
    for i in 0 to v_normalized_data'high loop
      shared_vvc_cmd.data_array(i)(c_data_word_size - 1 downto 0) := v_normalized_data(i);
    end loop;
    shared_vvc_cmd.data_array_length    := v_normalized_data'length;
    shared_vvc_cmd.data_array_word_size := c_data_word_size;
    shared_vvc_cmd.parent_msg_id_panel  := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure avalon_st_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_array          : in t_slv_array;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant channel_value : std_logic_vector(C_VVC_CMD_CHAN_MAX_LENGTH - 1 downto 0) := (others => '0');
  begin
    avalon_st_transmit(VVCT, vvc_instance_idx, channel_value, data_array, msg, scope, parent_msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Receive
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_array_len      : in natural;
    constant data_word_size      : in natural;
    constant data_routing        : in t_data_routing;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "avalon_st_receive";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ")";
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, RECEIVE);
    shared_vvc_cmd.data_array_length    := data_array_len;
    shared_vvc_cmd.data_array_word_size := data_word_size;
    shared_vvc_cmd.parent_msg_id_panel  := parent_msg_id_panel;
    shared_vvc_cmd.data_routing         := data_routing;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure avalon_st_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_array_len      : in natural;
    constant data_word_size      : in natural;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    -- call overloaded procedure
    avalon_st_receive(VVCT, vvc_instance_idx, data_array_len, data_word_size, TO_BUFFER, msg, scope, parent_msg_id_panel);
  end procedure;

  ---------------------------------------------------------------------------------------------
  -- Avalon-ST Expect
  ---------------------------------------------------------------------------------------------
  procedure avalon_st_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant channel_exp         : in std_logic_vector;
    constant data_exp            : in t_slv_array;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "avalon_st_expect";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(data_exp'length) & " words, ch:" & to_string(channel_exp, DEC, AS_IS) & ")";
    constant c_data_word_size  : natural                                                              := data_exp(data_exp'low)'length;
    variable v_normalized_chan : std_logic_vector(C_VVC_CMD_CHAN_MAX_LENGTH - 1 downto 0)             := normalize_and_check(channel_exp, shared_vvc_cmd.channel_value, ALLOW_NARROWER, "channel", "shared_vvc_cmd.channel", proc_call & ". " & msg);
    variable v_normalized_data : t_slv_array(0 to data_exp'length - 1)(c_data_word_size - 1 downto 0) := data_exp;
    variable v_msg_id_panel    : t_msg_id_panel                                                       := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, EXPECT);
    shared_vvc_cmd.channel_value        := v_normalized_chan;
    for i in 0 to v_normalized_data'high loop
      shared_vvc_cmd.data_array(i)(c_data_word_size - 1 downto 0) := v_normalized_data(i);
    end loop;
    shared_vvc_cmd.data_array_length    := v_normalized_data'length;
    shared_vvc_cmd.data_array_word_size := c_data_word_size;
    shared_vvc_cmd.alert_level          := alert_level;
    shared_vvc_cmd.parent_msg_id_panel  := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure avalon_st_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in t_slv_array;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant channel_exp : std_logic_vector(C_VVC_CMD_CHAN_MAX_LENGTH - 1 downto 0) := (others => '0');
  begin
    avalon_st_expect(VVCT, vvc_instance_idx, channel_exp, data_exp, msg, alert_level, scope, parent_msg_id_panel);
  end procedure;

  --==============================================================================
  -- Transaction info methods
  --==============================================================================
  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_config                   : in t_vvc_config;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT) is
  begin
    case vvc_cmd.operation is
      when TRANSMIT | RECEIVE | EXPECT =>
        vvc_transaction_info_group.bt.operation          := vvc_cmd.operation;
        vvc_transaction_info_group.bt.channel_value      := vvc_cmd.channel_value;
        vvc_transaction_info_group.bt.data_array         := vvc_cmd.data_array;
        vvc_transaction_info_group.bt.vvc_meta.msg       := vvc_cmd.msg;
        vvc_transaction_info_group.bt.vvc_meta.cmd_idx   := vvc_cmd.cmd_idx;
        vvc_transaction_info_group.bt.transaction_status := transaction_status;
        gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);

      when others =>
        alert(TB_ERROR, "VVC operation not recognized", scope);
    end case;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure set_global_vvc_transaction_info(
    signal   vvc_transaction_info_trigger : inout std_logic;
    variable vvc_transaction_info_group   : inout t_transaction_group;
    constant vvc_cmd                      : in t_vvc_cmd_record;
    constant vvc_result                   : in t_vvc_result;
    constant transaction_status           : in t_transaction_status;
    constant scope                        : in string := C_VVC_CMD_SCOPE_DEFAULT) is
  begin
    case vvc_cmd.operation is
      when RECEIVE =>
        vvc_transaction_info_group.bt.channel_value      := vvc_result.channel_value;
        vvc_transaction_info_group.bt.data_array         := vvc_result.data_array;
        vvc_transaction_info_group.bt.transaction_status := transaction_status;
        gen_pulse(vvc_transaction_info_trigger, 0 ns, "pulsing global vvc transaction info trigger", scope, ID_NEVER);

      when others =>
        alert(TB_ERROR, "VVC operation does not update vvc_result", scope);
    end case;

    wait for 0 ns;
  end procedure set_global_vvc_transaction_info;

  procedure reset_vvc_transaction_info(
    variable vvc_transaction_info_group : inout t_transaction_group;
    constant vvc_cmd                    : in t_vvc_cmd_record) is
  begin
    case vvc_cmd.operation is
      when TRANSMIT | RECEIVE | EXPECT =>
        vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;

      when others =>
        null;
    end case;

    wait for 0 ns;
  end procedure reset_vvc_transaction_info;

  --==============================================================================
  -- VVC Activity
  --==============================================================================
  procedure update_vvc_activity_register(signal   global_trigger_vvc_activity_register : inout std_logic;
                                         variable vvc_status                           : inout t_vvc_status;
                                         constant activity                             : in t_activity;
                                         constant entry_num_in_vvc_activity_register   : in integer;
                                         constant last_cmd_idx_executed                : in natural;
                                         constant command_queue_is_empty               : in boolean;
                                         constant scope                                : in string := C_VVC_NAME) is
    variable v_activity : t_activity := activity;
  begin
    -- Update vvc_status after a command has finished (during same delta cycle the activity register is updated)
    if activity = INACTIVE then
      vvc_status.previous_cmd_idx := last_cmd_idx_executed;
      vvc_status.current_cmd_idx  := 0;
    end if;

    if v_activity = INACTIVE and not (command_queue_is_empty) then
      v_activity := ACTIVE;
    end if;
    shared_vvc_activity_register.priv_report_vvc_activity(vvc_idx               => entry_num_in_vvc_activity_register,
                                                          activity              => v_activity,
                                                          last_cmd_idx_executed => last_cmd_idx_executed);
    if global_trigger_vvc_activity_register /= 'L' then
      wait until global_trigger_vvc_activity_register = 'L';
    end if;
    gen_pulse(global_trigger_vvc_activity_register, 0 ns, "pulsing global trigger for vvc activity register", scope, ID_NEVER);
  end procedure;

end package body vvc_methods_pkg;
