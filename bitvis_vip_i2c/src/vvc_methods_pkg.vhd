--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

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
use work.td_vvc_framework_common_methods_pkg.all;
use work.td_target_support_pkg.all;


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

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;  -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;  -- Maximum pending number in command queue before queue is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;  -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command queue exceeds this count.
                                                      -- Used for early warning if command queue is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;  -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural;  -- Maximum number of unfetched results before result_queue is full.
    result_queue_count_threshold_severity : t_alert_level;  -- An alert with severity 'result_queue_count_threshold_severity' will be issued if command queue exceeds this count.
                                                            -- Used for early warning if result queue is almost full. Will be ignored if set to 0.
    result_queue_count_threshold          : natural;  -- Severity of alert to be initiated if exceeding result_queue_count_threshold
    bfm_config                            : t_i2c_bfm_config;  -- Configuration for the BFM. See BFM quick reference
    msg_id_panel                          : t_msg_id_panel;  -- VVC dedicated message ID panel
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
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT
    );

  type t_vvc_status is
  record
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
  type t_transaction_info is
  record
    operation                    : t_operation;
    msg                          : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    addr                         : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0);
    data                         : t_byte_array(0 to C_VVC_CMD_DATA_MAX_LENGTH-1);
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


  shared variable shared_i2c_vvc_config       : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM)       := (others => C_I2C_VVC_CONFIG_DEFAULT);
  shared variable shared_i2c_vvc_status       : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM)       := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_i2c_transaction_info : t_transaction_info_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_TRANSACTION_INFO_DEFAULT);

  --==============================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to queue BFM calls
  --   in the VVC command queue. The VVC will store and forward these calls to the
  --   I2C BFM when the command is at the from of the VVC command queue.
  -- - For details on how the BFM procedures work, see i2c_bfm_pkg.vhd or the
  --   quickref.
  --==============================================================================

  -- *****************************************************************************
  --
  -- master transmit
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_master_transmit(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    t_byte_array;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER
    );

  -- single byte
  procedure i2c_master_transmit(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    std_logic_vector;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER
    );

  -- *****************************************************************************
  --
  -- slave transmit
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_slave_transmit(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    t_byte_array;
    constant msg              : in    string
    );

  -- single byte
  procedure i2c_slave_transmit(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    std_logic_vector;
    constant msg              : in    string
    );


  -- *****************************************************************************
  --
  -- master receive
  --
  -- *****************************************************************************

  procedure i2c_master_receive(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant num_bytes                    : in    natural;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER
    );

  -- *****************************************************************************
  --
  -- master check
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_master_check(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    t_byte_array;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in    t_alert_level                  := error
    );

  -- single byte
  procedure i2c_master_check(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    std_logic_vector;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in    t_alert_level                  := error
    );


  procedure i2c_master_quick_command(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant msg                          : in    string;
    constant rw_bit                       : in    std_logic                      := C_WRITE_BIT;
    constant exp_ack                      : in    boolean                        := true;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in    t_alert_level                  := error
    );

  -- *****************************************************************************
  --
  -- slave receive
  --
  -- *****************************************************************************
  procedure i2c_slave_receive(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant num_bytes        : in    natural;
    constant msg              : in    string
    );

  -- *****************************************************************************
  --
  -- slave check
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error;
    constant rw_bit           : in    std_logic     := '0'  -- Default write bit
    );

  -- single byte
  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error;
    constant rw_bit           : in    std_logic     := '0'  -- Default write bit
    );

  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant rw_bit           : in    std_logic;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );

end package vvc_methods_pkg;

package body vvc_methods_pkg is



  --==============================================================================
  -- Methods dedicated to this VVC
  -- Notes:
  --   - shared_vvc_cmd is initialised to C_VVC_CMD_DEFAULT, and also reset to this after every command
  --==============================================================================

  -- master transmit
  procedure i2c_master_transmit(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    t_byte_array;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) :=
      normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_TRANSMIT);
    shared_vvc_cmd.addr                         := v_normalized_addr;
    shared_vvc_cmd.data(0 to data'length - 1)   := data;
    shared_vvc_cmd.num_bytes                    := data'length;
    shared_vvc_cmd.action_when_transfer_is_done := action_when_transfer_is_done;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_master_transmit(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    std_logic_vector;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_master_transmit(VVCT, vvc_instance_idx, addr, v_byte_array, msg, action_when_transfer_is_done);
  end procedure;

  -- slave transmit
  procedure i2c_slave_transmit(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    t_byte_array;
    constant msg              : in    string
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_TRANSMIT);
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_slave_transmit(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    std_logic_vector;
    constant msg              : in    string
    ) is
    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_slave_transmit(VVCT, vvc_instance_idx, v_byte_array, msg);
  end procedure;

  -- master receive
  procedure i2c_master_receive(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant num_bytes                    : in    natural;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) :=
      normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_NARROWER, "addr", "shared_vvc_cmd.addr", msg);
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_RECEIVE);
    shared_vvc_cmd.addr                         := v_normalized_addr;
    shared_vvc_cmd.num_bytes                    := num_bytes;
    shared_vvc_cmd.action_when_transfer_is_done := action_when_transfer_is_done;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_slave_receive(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant num_bytes        : in    natural;
    constant msg              : in    string
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_RECEIVE);
    shared_vvc_cmd.num_bytes := num_bytes;
    send_command_to_vvc(VVCT);
  end procedure;


  -- master check
  procedure i2c_master_check(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    t_byte_array;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in    t_alert_level                  := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) :=
      normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
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
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_master_check(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant data                         : in    std_logic_vector;
    constant msg                          : in    string;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in    t_alert_level                  := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_master_check(VVCT, vvc_instance_idx, addr, v_byte_array, msg, action_when_transfer_is_done, alert_level);
  end procedure;

  procedure i2c_master_quick_command(
    signal VVCT                           : inout t_vvc_target_record;
    constant vvc_instance_idx             : in    integer;
    constant addr                         : in    unsigned;
    constant msg                          : in    string;
    constant rw_bit                       : in    std_logic                      := C_WRITE_BIT;
    constant exp_ack                      : in    boolean                        := true;
    constant action_when_transfer_is_done : in    t_action_when_transfer_is_done := RELEASE_LINE_AFTER_TRANSFER;
    constant alert_level                  : in    t_alert_level                  := error
    ) is
    constant proc_name         : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call         : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) :=
      normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
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
    send_command_to_vvc(VVCT);
  end procedure;

  -- slave check
  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error;
    constant rw_bit           : in    std_logic     := '0'  -- Default write bit
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_CHECK);
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    shared_vvc_cmd.alert_level                := alert_level;
    shared_vvc_cmd.rw_bit                     := rw_bit;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error;
    constant rw_bit           : in    std_logic     := '0'  -- Default write bit
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');
    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);
    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_slave_check(VVCT, vvc_instance_idx, v_byte_array, msg, alert_level, rw_bit);
  end procedure;


  -- slave check
  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant rw_bit           : in    std_logic;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
    variable v_dummy_byte_array : t_byte_array(0 to -1);  -- Empty byte array to indicate that data is not checked
  begin
    i2c_slave_check(VVCT, vvc_instance_idx, v_dummy_byte_array, msg, alert_level, rw_bit);
  end procedure;


end package body vvc_methods_pkg;
