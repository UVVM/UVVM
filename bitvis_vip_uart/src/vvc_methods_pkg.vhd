--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved.
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

use work.uart_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;


--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_methods_pkg is

  constant C_VVC_NAME                     : string  := "UART_VVC";
  constant C_EXECUTOR_RESULT_ARRAY_DEPTH  : natural := 3;

  signal UART_VVCT   : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT    : t_vvc_target_record is UART_VVCT;
  alias t_bfm_config is t_uart_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_UART_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                          => NO_DELAY,
    delay_in_time                       => 0 ns,
    inter_bfm_delay_violation_severity  => WARNING
  );
  
  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;
    cmd_queue_count_max                   : natural;
    cmd_queue_count_threshold_severity    : t_alert_level;
    cmd_queue_count_threshold             : natural;
    bfm_config                            : t_uart_bfm_config; -- configuration record for UART BFM
    msg_id_panel                          : t_msg_id_panel;
  end record;

  type t_vvc_config_array is array (t_channel range <>, natural range <>) of t_vvc_config;

  constant C_UART_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_UART_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_UART_BFM_CONFIG_DEFAULT,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT
    );
    
  type t_vvc_status is
  record
    current_cmd_idx       : natural;
    previous_cmd_idx      : natural;
    pending_cmd_cnt       : natural;
  end record;

  type t_vvc_status_array is array (t_channel range <>, natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx      => 0,
    previous_cmd_idx     => 0,
    pending_cmd_cnt      => 0
  );
    
    
  type t_transaction_info_for_waveview is
  record
    operation       : t_operation;
    data            : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    msg             : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
  end record;

  type t_transaction_info_for_waveview_array is array (t_channel range <>, natural range <>) of t_transaction_info_for_waveview;

  constant C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT : t_transaction_info_for_waveview := (
    operation           =>  NO_OPERATION,
    data                => (others => '0'),
    msg                 => (others => ' ')
  );
    
  shared variable shared_uart_vvc_config : t_vvc_config_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) := (others => (others => C_UART_VVC_CONFIG_DEFAULT));
  shared variable shared_uart_vvc_status : t_vvc_status_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) := (others => (others => C_VVC_STATUS_DEFAULT));
  shared variable shared_uart_transaction_info_for_waveview : t_transaction_info_for_waveview_array(t_channel'left to t_channel'right, 0 to C_MAX_VVC_INSTANCE_NUM) := (others => (others => C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT));
  

  --==============================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to queue BFM calls 
  --   in the VVC command queue. The VVC will store and forward these calls to the 
  --   UART BFM when the command is at the from of the VVC command queue. 
  -- - For details on how the BFM procedures work, see uart_bfm_pkg.vhd.
  --==============================================================================

  procedure uart_transmit(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant channel            : in t_channel;
    constant data               : in std_logic_vector;
    constant msg                : in string
  );

  procedure uart_receive(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant channel            : in t_channel;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR
  );

  procedure uart_expect(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant channel            : in t_channel;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant max_receptions     : in natural       := 1;
    constant timeout            : in time          := 0 ns;
    constant alert_level        : in t_alert_level := ERROR
  );

end package vvc_methods_pkg;

package body vvc_methods_pkg is

  procedure uart_transmit(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant channel            : in t_channel;
    constant data               : in std_logic_vector;
    constant msg                : in string
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    -- Create command
    shared_vvc_cmd                               := C_VVC_CMD_DEFAULT;
    shared_vvc_cmd.operation                     := TRANSMIT;
    shared_vvc_cmd.data(data'length-1 downto 0)  := data;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, TRANSMIT);
    send_command_to_vvc(VVCT);
  end procedure;

  procedure uart_receive(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant channel            : in t_channel;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ")";
  begin
    -- Create command
    shared_vvc_cmd               := C_VVC_CMD_DEFAULT;
    shared_vvc_cmd.operation     := RECEIVE;
    shared_vvc_cmd.alert_level   := alert_level;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, RECEIVE);
    send_command_to_vvc(VVCT);
  end procedure;

  procedure uart_expect(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant channel            : in t_channel;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant max_receptions     : in natural       := 1;
    constant timeout            : in time          := 0 ns;
    constant alert_level        : in t_alert_level := ERROR
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx, channel)  -- First part common for all
        & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    -- Create command
    shared_vvc_cmd                               := C_VVC_CMD_DEFAULT;
    shared_vvc_cmd.operation                     := EXPECT;
    shared_vvc_cmd.data(data'length-1 downto 0)  := data;
    shared_vvc_cmd.alert_level                   := alert_level;
    shared_vvc_cmd.max_receptions                := max_receptions;
    shared_vvc_cmd.timeout                       := timeout;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, channel, proc_call, msg, QUEUED, EXPECT);
    send_command_to_vvc(VVCT);
  end procedure;

end package body vvc_methods_pkg;


