--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------
--========================================================================================================================
-- This VVC was generated with Bitvis VVC Generator
--========================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.gpio_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;
use work.vvc_sb_pkg.all;

--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the GPIO VVC 
  --========================================================================================================================
  constant C_VVC_NAME : string := "GPIO_VVC";

  signal GPIO_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT  : t_vvc_target_record is GPIO_VVCT;
  alias t_bfm_config is t_gpio_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_GPIO_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => warning
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay;
    cmd_queue_count_max                   : natural;
    cmd_queue_count_threshold_severity    : t_alert_level;
    cmd_queue_count_threshold             : natural;
    result_queue_count_max                : natural; -- Maximum number of unfetched results before result_queue is full. 
    result_queue_count_threshold_severity : t_alert_level; -- An alert with severity 'result_queue_count_threshold_severity' will be issued if command queue exceeds this count.
    -- Used for early warning if result queue is almost full. Will be ignored if set to 0.
    result_queue_count_threshold          : natural; -- Severity of alert to be initiated if exceeding result_queue_count_threshold
    bfm_config                            : t_gpio_bfm_config;
    msg_id_panel                          : t_msg_id_panel;
    parent_msg_id_panel                   : t_msg_id_panel; --UVVM: temporary fix for HVVC, remove in v3.0
    unwanted_activity_severity            : t_alert_level; -- Severity of alert to be initiated if unwanted activity on the DUT outputs is detected
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_GPIO_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_GPIO_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_GPIO_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT,
    parent_msg_id_panel                   => C_VVC_MSG_ID_PANEL_DEFAULT,
    unwanted_activity_severity            => NO_ALERT
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

  type t_transaction_info is record
    operation : t_operation;
    msg       : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    data      : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH - 1 downto 0);
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    data      => (others => '0'),
    operation => NO_OPERATION,
    msg       => (others => ' ')
  );

  shared variable shared_gpio_vvc_config       : t_vvc_config_array(0 to C_VVC_MAX_INSTANCE_NUM - 1)       := (others => C_GPIO_VVC_CONFIG_DEFAULT);
  shared variable shared_gpio_vvc_status       : t_vvc_status_array(0 to C_VVC_MAX_INSTANCE_NUM - 1)       := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_gpio_transaction_info : t_transaction_info_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_TRANSACTION_INFO_DEFAULT);
  shared variable GPIO_VVC_SB                  : t_generic_sb;

  --==========================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --   For details on how the BFM procedures work, see the QuickRef.
  --==========================================================================================

  procedure gpio_set(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic_vector;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_set(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_get(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_routing        : in t_data_routing;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_get(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_check_stable(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant stable_req          : in time;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant timeout             : in time           := 1 us;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure gpio_expect_stable(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant stable_req          : in time;
    constant stable_req_from     : in t_from_point_in_time;
    constant timeout             : in time           := 1 us;
    constant msg                 : in string         := "";
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

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================

  procedure gpio_set(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic_vector;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "gpio_set";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & ", " & to_string(data, HEX, KEEP_LEADING_0, INCL_RADIX) & ")";
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data'length - 1 downto 0) := normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", proc_call & " called with too wide data. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                            := shared_msg_id_panel;
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SET);
    shared_vvc_cmd.data                := v_normalised_data;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure gpio_set(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    variable v_data_slv : std_logic_vector(0 downto 0);
  begin
    v_data_slv(0) := data;  -- Convert std_logic to slv.
    gpio_set(VVCT, vvc_instance_idx, v_data_slv, msg, scope, parent_msg_id_panel);
  end procedure;


  procedure gpio_get(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_routing        : in t_data_routing;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "gpio_get";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & ")";
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, GET);
    shared_vvc_cmd.data_routing        := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure gpio_get(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant msg                 : in string         := "";
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    gpio_get(VVCT, vvc_instance_idx, NA, msg, scope, parent_msg_id_panel);
  end procedure;

  procedure gpio_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "gpio_check";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(data_exp, HEX, KEEP_LEADING_0, INCL_RADIX) & ")";
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data_exp'length - 1 downto 0) := normalize_and_check(data_exp, shared_vvc_cmd.data_exp, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data_exp", proc_call & " called with too wide data. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                                := shared_msg_id_panel;
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, CHECK);
    shared_vvc_cmd.data_exp            := v_normalised_data;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure gpio_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    variable v_data_exp_slv : std_logic_vector(0 downto 0);
  begin
    v_data_exp_slv(0) := data_exp;  -- Convert std_logic to slv.
    gpio_check(VVCT, vvc_instance_idx, v_data_exp_slv, msg, alert_level, scope, parent_msg_id_panel);
  end procedure;

  procedure gpio_check_stable(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant stable_req          : in time;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "gpio_check_stable";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(data_exp, HEX, KEEP_LEADING_0, INCL_RADIX) & ", " & to_string(stable_req) & ")";
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data_exp'length - 1 downto 0) := normalize_and_check(data_exp, shared_vvc_cmd.data_exp, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data_exp", proc_call & " called with too wide data. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                                := shared_msg_id_panel;
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, CHECK_STABLE);
    shared_vvc_cmd.data_exp            := v_normalised_data;
    shared_vvc_cmd.stable_req          := stable_req;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure gpio_expect(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant timeout             : in time           := 1 us;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "gpio_expect";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(data_exp, HEX, KEEP_LEADING_0, INCL_RADIX) & ")";
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data_exp'length - 1 downto 0) := normalize_and_check(data_exp, shared_vvc_cmd.data_exp, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data_exp", proc_call & " called with too wide data. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                                := shared_msg_id_panel;
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, EXPECT);
    shared_vvc_cmd.data_exp            := v_normalised_data;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure gpio_expect_stable(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data_exp            : in std_logic_vector;
    constant stable_req          : in time;
    constant stable_req_from     : in t_from_point_in_time;
    constant timeout             : in time           := 1 us;
    constant msg                 : in string         := "";
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name : string := "gpio_expect_stable";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(data_exp, HEX, KEEP_LEADING_0, INCL_RADIX) & ", " & to_string(stable_req) & ")";
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data_exp'length - 1 downto 0) := normalize_and_check(data_exp, shared_vvc_cmd.data_exp, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data_exp", proc_call & " called with too wide data. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                                := shared_msg_id_panel;
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, EXPECT_STABLE);
    shared_vvc_cmd.data_exp            := v_normalised_data;
    shared_vvc_cmd.stable_req          := stable_req;
    shared_vvc_cmd.stable_req_from     := stable_req_from;
    shared_vvc_cmd.timeout             := timeout;
    shared_vvc_cmd.alert_level         := alert_level;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
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
      when SET | GET | CHECK | CHECK_STABLE | EXPECT | EXPECT_STABLE =>
        vvc_transaction_info_group.bt.operation          := vvc_cmd.operation;
        vvc_transaction_info_group.bt.data               := vvc_cmd.data;
        vvc_transaction_info_group.bt.data_exp           := vvc_cmd.data_exp;
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
      when GET =>
        vvc_transaction_info_group.bt.data               := vvc_result;
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
      when SET | GET | CHECK | CHECK_STABLE | EXPECT | EXPECT_STABLE =>
        vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;

      when others =>
        null;
    end case;

    wait for 0 ns;
  end procedure reset_vvc_transaction_info;

end package body vvc_methods_pkg;
