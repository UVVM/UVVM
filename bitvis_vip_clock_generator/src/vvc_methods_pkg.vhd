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

use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;

--========================================================================================================================
--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the CLOCK_GENERATOR VVC
  --========================================================================================================================
  constant C_VVC_NAME : string := "CLOCK_GENERATOR_VVC";

  signal CLOCK_GENERATOR_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT             : t_vvc_target_record is CLOCK_GENERATOR_VVCT;
  alias t_bfm_config is t_void_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_CLOCK_GENERATOR_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => WARNING
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural; -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural; -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level; -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural;
    result_queue_count_threshold_severity : t_alert_level;
    result_queue_count_threshold          : natural;
    bfm_config                            : t_bfm_config;
    msg_id_panel                          : t_msg_id_panel; -- VVC dedicated message ID panel
    clock_name                            : string(1 to 30);
    clock_period                          : time;
    clock_high_time                       : time;
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_CLOCK_GENERATOR_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_CLOCK_GENERATOR_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_VOID_BFM_CONFIG,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT,
    clock_name                            => ("Set clock name", others => NUL),
    clock_period                          => 10 ns,
    clock_high_time                       => 5 ns
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

  -- Transaction information to include in the wave view during simulation
  type t_transaction_info is record
    operation : t_operation;
    msg       : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    --<USER_INPUT> Fields that could be useful to track in the waveview can be placed in this record.
    -- Example:
    -- addr            : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0);
    -- data            : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    --<USER_INPUT> Set the data fields added to the t_transaction_info record to
    -- their default values here.
    -- Example:
    -- addr                => (others => '0'),
    -- data                => (others => '0'),
    operation => NO_OPERATION,
    msg       => (others => ' ')
  );

  shared variable shared_clock_generator_vvc_config       : t_vvc_config_array(0 to C_VVC_MAX_INSTANCE_NUM - 1)       := (others => C_CLOCK_GENERATOR_VVC_CONFIG_DEFAULT);
  shared variable shared_clock_generator_vvc_status       : t_vvc_status_array(0 to C_VVC_MAX_INSTANCE_NUM - 1)       := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_clock_generator_transaction_info : t_transaction_info_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_TRANSACTION_INFO_DEFAULT);

  --==========================================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --   For details on how the BFM procedures work, see the QuickRef.
  --==========================================================================================

  procedure start_clock(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure stop_clock(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure set_clock_period(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant clock_period     : in time;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

  procedure set_clock_high_time(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant clock_high_time  : in time;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  );

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================

  procedure start_clock(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "start_clock";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ")";
  begin
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, START_CLOCK);
    send_command_to_vvc(VVCT, scope => scope);
  end procedure start_clock;

  procedure stop_clock(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "stop_clock";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ")";
  begin
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, STOP_CLOCK);
    send_command_to_vvc(VVCT, scope => scope);
  end procedure stop_clock;

  procedure set_clock_period(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant clock_period     : in time;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "set_clock_period";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(clock_period) & ")";
  begin
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SET_CLOCK_PERIOD);
    shared_vvc_cmd.clock_period := clock_period;
    send_command_to_vvc(VVCT, scope => scope);
  end procedure set_clock_period;

  procedure set_clock_high_time(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant clock_high_time  : in time;
    constant msg              : in string;
    constant scope            : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) is
    constant proc_name : string := "set_clock_high_time";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) -- First part common for all
                                   & ", " & to_string(clock_high_time) & ")";
  begin
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SET_CLOCK_HIGH_TIME);
    shared_vvc_cmd.clock_high_time := clock_high_time;
    send_command_to_vvc(VVCT, scope => scope);
  end procedure set_clock_high_time;

end package body vvc_methods_pkg;
