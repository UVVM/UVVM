--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
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

use work.ethernet_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;

--========================================================================================================================
--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the ETHERNET VVC
  --========================================================================================================================
  constant C_VVC_NAME     : string := "ETHERNET_HVVC";

  signal ETHERNET_VVCT     : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT         : t_vvc_target_record is ETHERNET_VVCT;
  alias  t_bfm_config is t_ethernet_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_ETHERNET_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                          => NO_DELAY,
    delay_in_time                       => 0 ns,
    inter_bfm_delay_violation_severity  => WARNING
  );

  constant C_ETHERNET_HVVC_MSG_ID_PANEL_DEFAULT : t_msg_id_panel := (
    ID_PACKET_INITIATE => ENABLED,
    ID_PACKET_COMPLETE => ENABLED,
    --ID_PACKET_HDR      => ENABLED,
    --ID_PACKET_DATA     => ENABLED,
    others             => DISABLED
  );

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;-- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;          -- Maximum pending number in command executor before executor is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;          -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command executor exceeds this count. Used for early warning if command executor is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;    -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural;
    result_queue_count_threshold_severity : t_alert_level;
    result_queue_count_threshold          : natural;
    bfm_config                            : t_ethernet_bfm_config; -- Configuration for the BFM. See BFM quick reference
    msg_id_panel                          : t_msg_id_panel;   -- VVC dedicated message ID panel
  end record;

  type t_vvc_config_array is array (t_channel range <>, natural range <>) of t_vvc_config;

  constant C_ETHERNET_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_ETHERNET_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_ETHERNET_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_ETHERNET_HVVC_MSG_ID_PANEL_DEFAULT
  );

  type t_vvc_status is
  record
    current_cmd_idx  : natural;
    previous_cmd_idx : natural;
    pending_cmd_cnt  : natural;
  end record;

  type t_vvc_status_array is array (t_channel range <>, natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx  => 0,
    previous_cmd_idx => 0,
    pending_cmd_cnt  => 0
  );

  -- Transaction information to include in the wave view during simulation
  type t_transaction_info is
  record
    operation      : t_operation;
    msg            : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    ethernet_frame : t_ethernet_frame;
  end record;

  type t_transaction_info_array is array (t_channel range <>, natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    operation      => NO_OPERATION,
    msg            => (others => ' '),
    ethernet_frame => C_ETHERNET_FRAME_DEFAULT
  );


  shared variable shared_ethernet_vvc_config : t_vvc_config_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => (others => C_ETHERNET_VVC_CONFIG_DEFAULT));
  shared variable shared_ethernet_vvc_status : t_vvc_status_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => (others => C_VVC_STATUS_DEFAULT));
  shared variable shared_ethernet_transaction_info : t_transaction_info_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => (others => C_TRANSACTION_INFO_DEFAULT));

  --========================================================================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to executor BFM calls
  --   in the VVC command executor. The VVC will store and forward these calls to the
  --   ETHERNET BFM when the command is at the from of the VVC command executor.
  --========================================================================================================================

  procedure ethernet_send(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_send(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_send(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_receive(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  );

end package vvc_methods_pkg;


package body vvc_methods_pkg is


  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================


  procedure ethernet_send(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_send";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ", MAC dest: " & to_string(std_logic_vector'(mac_destination(0) & mac_destination(1) & mac_destination(2) & mac_destination(3)
        & mac_destination(4) & mac_destination(5)), HEX, AS_IS, INCL_RADIX) & ", MAC src: " & to_string(std_logic_vector'(mac_source(0)
        & mac_source(1) & mac_source(2) & mac_source(3)
        & mac_source(4) & mac_source(5)), HEX, AS_IS, INCL_RADIX) & ")";
  begin
  -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
  -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
  -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, TRANSMIT);
    shared_vvc_cmd.mac_destination                := mac_destination;
    shared_vvc_cmd.mac_source                     := mac_source;
    shared_vvc_cmd.length                         := payload'length;
    shared_vvc_cmd.payload(0 to payload'length-1) := payload;
    shared_vvc_cmd.use_provided_msg_id_panel      := use_provided_msg_id_panel;
    shared_vvc_cmd.msg_id_panel                   := msg_id_panel;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, msg_id_panel);
  end procedure ethernet_send;

  procedure ethernet_send(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_send(VVCT, vvc_instance_idx, channel, mac_destination,
        shared_ethernet_vvc_config(channel,vvc_instance_idx).bfm_config.mac_source, payload, msg, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_send;

  procedure ethernet_send(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_send(VVCT, vvc_instance_idx, channel,
        shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination,
        shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source, payload, msg, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_send;


  procedure ethernet_receive(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant msg                       : in    string;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_receive";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel) & ")";
  begin
  -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
  -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
  -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, RECEIVE);
    shared_vvc_cmd.use_provided_msg_id_panel := use_provided_msg_id_panel;
    shared_vvc_cmd.msg_id_panel              := msg_id_panel;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, msg_id_panel);
  end procedure ethernet_receive;

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant mac_source                : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
    constant proc_name : string := "ethernet_expect";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ", MAC dest: " & to_string(std_logic_vector'(mac_destination(0) & mac_destination(1) & mac_destination(2) & mac_destination(3)
        & mac_destination(4) & mac_destination(5)), HEX, AS_IS, INCL_RADIX) & ", MAC src: " & to_string(std_logic_vector'(mac_source(0)
        & mac_source(1) & mac_source(2) & mac_source(3)
        & mac_source(4) & mac_source(5)), HEX, AS_IS, INCL_RADIX) & ")";
  begin
  -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
  -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
  -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, EXPECT);
    shared_vvc_cmd.mac_destination                := mac_destination;
    shared_vvc_cmd.mac_source                     := mac_source;
    shared_vvc_cmd.length                         := payload'length;
    shared_vvc_cmd.payload(0 to payload'length-1) := payload;
    shared_vvc_cmd.alert_level                    := alert_level;
    shared_vvc_cmd.use_provided_msg_id_panel      := use_provided_msg_id_panel;
    shared_vvc_cmd.msg_id_panel                   := msg_id_panel;
    send_command_to_vvc(VVCT, std.env.resolution_limit, scope, msg_id_panel);
  end procedure ethernet_expect;

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant mac_destination           : in    unsigned(47 downto 0);
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_expect(VVCT, vvc_instance_idx, channel, mac_destination,
        shared_ethernet_vvc_config(channel,vvc_instance_idx).bfm_config.mac_destination, payload, msg, alert_level, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_expect;

  procedure ethernet_expect(
    signal   VVCT                      : inout t_vvc_target_record;
    constant vvc_instance_idx          : in    integer;
    constant channel                   : in    t_channel;
    constant payload                   : in    t_byte_array;
    constant msg                       : in    string;
    constant alert_level               : in    t_alert_level               := ERROR;
    constant scope                     : in    string                      := C_VVC_CMD_SCOPE_DEFAULT;
    constant use_provided_msg_id_panel : in    t_use_provided_msg_id_panel := DO_NOT_USE_PROVIDED_MSG_ID_PANEL;
    constant msg_id_panel              : in    t_msg_id_panel              := shared_msg_id_panel
  ) is
  begin
    ethernet_expect(VVCT, vvc_instance_idx, channel,
        shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_source,
        shared_ethernet_vvc_config(channel, vvc_instance_idx).bfm_config.mac_destination, payload, msg, alert_level, scope, use_provided_msg_id_panel, msg_id_panel);
  end procedure ethernet_expect;

end package body vvc_methods_pkg;
