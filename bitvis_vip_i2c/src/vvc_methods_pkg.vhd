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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.i2c_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;
use work.transaction_pkg.all;
use work.vvc_sb_pkg.all;

--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_methods_pkg is

  --===============================================================================================
  -- Types and constants for the I2C VVC
  --===============================================================================================
  constant C_VVC_NAME : string := "I2C_VVC";

  signal I2C_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT : t_vvc_target_record is I2C_VVCT;
  alias t_bfm_config is t_i2c_bfm_config;

  constant C_I2C_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => warning
  );

  type t_vvc_config is record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural; -- Maximum pending number in command queue before queue is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural; -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command queue exceeds this count.
                                                     -- Used for early warning if command queue is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level; -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural; -- Maximum number of unfetched results before result_queue is full.
    result_queue_count_threshold_severity : t_alert_level; -- An alert with severity 'result_queue_count_threshold_severity' will be issued if command queue exceeds this count.
                                                           -- Used for early warning if result queue is almost full. Will be ignored if set to 0.
    result_queue_count_threshold          : natural; -- Severity of alert to be initiated if exceeding result_queue_count_threshold
    bfm_config                            : t_i2c_bfm_config; -- Configuration for the BFM. See BFM quick reference
    msg_id_panel                          : t_msg_id_panel; -- VVC dedicated message ID panel
    parent_msg_id_panel                   : t_msg_id_panel; --UVVM: temporary fix for HVVC, remove in v3.0
    unwanted_activity_severity            : t_alert_level; -- Severity of alert to be initiated if unwanted activity on the DUT outputs is detected
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_I2C_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_I2C_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_I2C_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT,
    parent_msg_id_panel                   => C_VVC_MSG_ID_PANEL_DEFAULT,
    unwanted_activity_severity            => C_UNWANTED_ACTIVITY_SEVERITY
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

  -- Transaction information for the wave view during simulation
  type t_transaction_info is record
    operation                    : t_operation;
    msg                          : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    addr                         : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0);
    data                         : t_byte_array(0 to C_VVC_CMD_DATA_MAX_LENGTH - 1);
    num_bytes                    : natural;
    action_when_transfer_is_done : t_action_when_transfer_is_done;
    exp_ack                      : boolean;
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    addr                         => (others => '0'),
    data                         => (others => (others => '0')),
    num_bytes                    => 0,
    operation                    => NO_OPERATION,
    msg                          => (others => ' '),
    action_when_transfer_is_done => RELEASE_LINE_AFTER_TRANSFER,
    exp_ack                      => true
  );

  shared variable shared_i2c_vvc_config       : t_vvc_config_array(0 to C_VVC_MAX_INSTANCE_NUM - 1)       := (others => C_I2C_VVC_CONFIG_DEFAULT);
  shared variable shared_i2c_vvc_status       : t_vvc_status_array(0 to C_VVC_MAX_INSTANCE_NUM - 1)       := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_i2c_transaction_info : t_transaction_info_array(0 to C_VVC_MAX_INSTANCE_NUM - 1) := (others => C_TRANSACTION_INFO_DEFAULT);
  shared variable I2C_VVC_SB                  : t_generic_sb;

  --==========================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --   For details on how the BFM procedures work, see the QuickRef.
  --==========================================================================================

  -- *****************************************************************************
  --
  -- master transmit
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_master_transmit(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- single byte
  procedure i2c_master_transmit(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in std_logic_vector;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- *****************************************************************************
  --
  -- slave transmit
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_slave_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in t_byte_array;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- single byte
  procedure i2c_slave_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic_vector;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- *****************************************************************************
  --
  -- master receive
  --
  -- *****************************************************************************

  procedure i2c_master_receive(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant num_bytes                    : in natural;
    constant data_routing                 : in t_data_routing;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure i2c_master_receive(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant num_bytes                    : in natural;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- *****************************************************************************
  --
  -- master check
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_master_check(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- single byte
  procedure i2c_master_check(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in std_logic_vector;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure i2c_master_quick_command(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant msg                          : in string;
    constant rw_bit                       : in std_logic                      := C_WRITE_BIT;
    constant exp_ack                      : in boolean                        := true;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- *****************************************************************************
  --
  -- slave receive
  --
  -- *****************************************************************************
  procedure i2c_slave_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant num_bytes           : in natural;
    constant data_routing        : in t_data_routing;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure i2c_slave_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant num_bytes           : in natural;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- *****************************************************************************
  --
  -- slave check
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_slave_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in t_byte_array;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant rw_bit              : in std_logic      := '0'; -- Default write bit
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  -- single byte
  procedure i2c_slave_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic_vector;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant rw_bit              : in std_logic      := '0'; -- Default write bit
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  );

  procedure i2c_slave_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant rw_bit              : in std_logic;
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

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  --==============================================================================
  -- Methods dedicated to this VVC
  -- Notes:
  --   - shared_vvc_cmd is initialised to C_VVC_CMD_DEFAULT, and also reset to this after every command
  --==============================================================================

  -- master transmit
  procedure i2c_master_transmit(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                                           := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                                           := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) := normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with too wide address. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                   := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_TRANSMIT);
    shared_vvc_cmd.addr                         := v_normalized_addr;
    shared_vvc_cmd.data(0 to data'length - 1)   := data;
    shared_vvc_cmd.num_bytes                    := data'length;
    shared_vvc_cmd.action_when_transfer_is_done := action_when_transfer_is_done;
    shared_vvc_cmd.parent_msg_id_panel          := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure i2c_master_transmit(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in std_logic_vector;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                       := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                       := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_byte            : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) := normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array      : t_byte_array(0 to 0)         := (0 => v_normalized_data);
  begin
    i2c_master_transmit(VVCT, vvc_instance_idx, addr, v_byte_array, msg, action_when_transfer_is_done, scope, parent_msg_id_panel);
  end procedure;

  -- slave transmit
  procedure i2c_slave_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in t_byte_array;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name      : string         := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call      : string         := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_TRANSMIT);
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    shared_vvc_cmd.parent_msg_id_panel        := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure i2c_slave_transmit(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic_vector;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    variable v_byte            : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) := normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array      : t_byte_array(0 to 0)         := (0 => v_normalized_data);
  begin
    i2c_slave_transmit(VVCT, vvc_instance_idx, v_byte_array, msg, scope, parent_msg_id_panel);
  end procedure;

  -- master receive
  procedure i2c_master_receive(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant num_bytes                    : in natural;
    constant data_routing                 : in t_data_routing;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                                           := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                                           := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) := normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_NARROWER, "addr", "shared_vvc_cmd.addr", msg);
    variable v_msg_id_panel    : t_msg_id_panel                                   := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_RECEIVE);
    shared_vvc_cmd.addr                         := v_normalized_addr;
    shared_vvc_cmd.num_bytes                    := num_bytes;
    shared_vvc_cmd.data_routing                 := data_routing;
    shared_vvc_cmd.action_when_transfer_is_done := action_when_transfer_is_done;
    shared_vvc_cmd.parent_msg_id_panel          := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure i2c_master_receive(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant num_bytes                    : in natural;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    i2c_master_receive(VVCT, vvc_instance_idx, addr, num_bytes, NA, msg, action_when_transfer_is_done, scope, parent_msg_id_panel);
  end procedure;

  -- slave receive
  procedure i2c_slave_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant num_bytes           : in natural;
    constant data_routing        : in t_data_routing;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name      : string         := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call      : string         := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_RECEIVE);
    shared_vvc_cmd.num_bytes           := num_bytes;
    shared_vvc_cmd.data_routing        := data_routing;
    shared_vvc_cmd.parent_msg_id_panel := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure i2c_slave_receive(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant num_bytes           : in natural;
    constant msg                 : in string;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
  begin
    i2c_slave_receive(VVCT, vvc_instance_idx, num_bytes, NA, msg, scope, parent_msg_id_panel);
  end procedure;

  -- master check
  procedure i2c_master_check(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in t_byte_array;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                                           := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                                           := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) := normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with too wide address. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                   := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_CHECK);
    shared_vvc_cmd.addr                         := v_normalized_addr;
    shared_vvc_cmd.data(0 to data'length - 1)   := data;
    shared_vvc_cmd.num_bytes                    := data'length;
    shared_vvc_cmd.alert_level                  := alert_level;
    shared_vvc_cmd.action_when_transfer_is_done := action_when_transfer_is_done;
    shared_vvc_cmd.parent_msg_id_panel          := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure i2c_master_check(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant data                         : in std_logic_vector;
    constant msg                          : in string;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                       := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                       := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_byte            : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) := normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array      : t_byte_array(0 to 0)         := (0 => v_normalized_data);
  begin
    i2c_master_check(VVCT, vvc_instance_idx, addr, v_byte_array, msg, action_when_transfer_is_done, alert_level, scope, parent_msg_id_panel);
  end procedure;

  procedure i2c_master_quick_command(
    signal   VVCT                         : inout t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant addr                         : in unsigned;
    constant msg                          : in string;
    constant rw_bit                       : in std_logic                      := C_WRITE_BIT;
    constant exp_ack                      : in boolean                        := true;
    constant action_when_transfer_is_done : in t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in t_alert_level                  := error;
    constant scope                        : in string                         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel          : in t_msg_id_panel                 := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                                           := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                                           := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) := normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with too wide address. " & add_msg_delimiter(msg));
    variable v_msg_id_panel    : t_msg_id_panel                                   := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_QUICK_CMD);
    shared_vvc_cmd.addr                         := v_normalized_addr;
    shared_vvc_cmd.exp_ack                      := exp_ack;
    shared_vvc_cmd.alert_level                  := alert_level;
    shared_vvc_cmd.rw_bit                       := rw_bit;
    shared_vvc_cmd.action_when_transfer_is_done := action_when_transfer_is_done;
    shared_vvc_cmd.parent_msg_id_panel          := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  -- slave check
  procedure i2c_slave_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in t_byte_array;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant rw_bit              : in std_logic      := '0'; -- Default write bit
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name      : string         := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call      : string         := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_CHECK);
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    shared_vvc_cmd.alert_level                := alert_level;
    shared_vvc_cmd.rw_bit                     := rw_bit;
    shared_vvc_cmd.parent_msg_id_panel        := parent_msg_id_panel;
    if parent_msg_id_panel /= C_UNUSED_MSG_ID_PANEL then
      v_msg_id_panel := parent_msg_id_panel;
    end if;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, v_msg_id_panel);
  end procedure;

  procedure i2c_slave_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant data                : in std_logic_vector;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant rw_bit              : in std_logic      := '0'; -- Default write bit
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name         : string                       := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string                       := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_byte            : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) := normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array      : t_byte_array(0 to 0)         := (0 => v_normalized_data);
  begin
    i2c_slave_check(VVCT, vvc_instance_idx, v_byte_array, msg, alert_level, rw_bit, scope, parent_msg_id_panel);
  end procedure;

  -- slave check
  procedure i2c_slave_check(
    signal   VVCT                : inout t_vvc_target_record;
    constant vvc_instance_idx    : in integer;
    constant rw_bit              : in std_logic;
    constant msg                 : in string;
    constant alert_level         : in t_alert_level  := error;
    constant scope               : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant parent_msg_id_panel : in t_msg_id_panel := C_UNUSED_MSG_ID_PANEL -- Only intended for usage by parent HVVCs
  ) is
    constant proc_name          : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call          : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_dummy_byte_array : t_byte_array(0 to -1); -- Empty byte array to indicate that data is not checked
  begin
    i2c_slave_check(VVCT, vvc_instance_idx, v_dummy_byte_array, msg, alert_level, rw_bit, scope, parent_msg_id_panel);
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
      when MASTER_TRANSMIT | MASTER_RECEIVE | MASTER_CHECK |
           SLAVE_TRANSMIT | SLAVE_RECEIVE | SLAVE_CHECK | MASTER_QUICK_CMD =>
        vvc_transaction_info_group.bt.operation                    := vvc_cmd.operation;
        vvc_transaction_info_group.bt.addr                         := vvc_cmd.addr;
        vvc_transaction_info_group.bt.data                         := vvc_cmd.data;
        vvc_transaction_info_group.bt.num_bytes                    := vvc_cmd.num_bytes;
        vvc_transaction_info_group.bt.action_when_transfer_is_done := vvc_cmd.action_when_transfer_is_done;
        vvc_transaction_info_group.bt.exp_ack                      := vvc_cmd.exp_ack;
        vvc_transaction_info_group.bt.rw_bit                       := vvc_cmd.rw_bit;
        vvc_transaction_info_group.bt.vvc_meta.msg                 := vvc_cmd.msg;
        vvc_transaction_info_group.bt.vvc_meta.cmd_idx             := vvc_cmd.cmd_idx;
        vvc_transaction_info_group.bt.transaction_status           := transaction_status;
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
      when MASTER_RECEIVE | SLAVE_RECEIVE =>
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
      when MASTER_TRANSMIT | MASTER_RECEIVE | MASTER_CHECK |
           SLAVE_TRANSMIT | SLAVE_RECEIVE | SLAVE_CHECK | MASTER_QUICK_CMD =>
        vvc_transaction_info_group.bt := C_BASE_TRANSACTION_SET_DEFAULT;

      when others =>
        null;
    end case;

    wait for 0 ns;
  end procedure reset_vvc_transaction_info;

end package body vvc_methods_pkg;
