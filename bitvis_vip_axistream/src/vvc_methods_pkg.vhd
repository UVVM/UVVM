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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.axistream_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;

--========================================================================================================================
--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the AXISTREAM VVC 
  --========================================================================================================================
  constant C_VVC_NAME : string := "AXISTREAM_VVC";

  signal AXISTREAM_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT       : t_vvc_target_record is AXISTREAM_VVCT;
  alias t_bfm_config is t_axistream_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_AXISTREAM_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => warning
    );

  type t_vvc_config is
  record
    inter_bfm_delay                    : t_inter_bfm_delay;
    cmd_queue_count_max                : natural;
    cmd_queue_count_threshold_severity : t_alert_level;
    cmd_queue_count_threshold          : natural;
    bfm_config                         : t_axistream_bfm_config;
    msg_id_panel                       : t_msg_id_panel;
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_AXISTREAM_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                    => C_AXISTREAM_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold_severity => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold          => C_CMD_QUEUE_COUNT_THRESHOLD,
    bfm_config                         => C_AXISTREAM_BFM_CONFIG_DEFAULT,
    msg_id_panel                       => C_VVC_MSG_ID_PANEL_DEFAULT
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

  type t_transaction_info_for_waveview is
  record
    operation      : t_operation;
    numPacketsSent : natural;
    msg            : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
  end record;

  type t_transaction_info_for_waveview_array is array (natural range <>) of t_transaction_info_for_waveview;

  constant C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT : t_transaction_info_for_waveview := (
    operation      => NO_OPERATION,
    numPacketsSent => 0,
    msg            => (others => ' ')
    );


  shared variable shared_axistream_vvc_config                    : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM-1)                    := (others => C_AXISTREAM_VVC_CONFIG_DEFAULT);
  shared variable shared_axistream_vvc_status                    : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM-1)                    := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_axistream_transaction_info_for_waveview : t_transaction_info_for_waveview_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT);


  --========================================================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order to queue BFM calls 
  --   in the VVC command queue. The VVC will store and forward these calls to the
  --   AXISTREAM BFM when the command is at the from of the VVC command queue.
  --========================================================================================================================


  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, replace this with a wider type:
    constant msg              : in    string
    );

  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant msg              : in    string
    );

  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );

  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    );

end package vvc_methods_pkg;


package body vvc_methods_pkg is


  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================


  -- These procedures will be used to forward commands to the VVC executor, which will
  -- call the corresponding BFM procedures. 
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant user_array       : in    t_user_array;  -- If you need support for more bits per data byte, edit axistream_bfm_pkg.t_user_array  
    constant msg              : in    string
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                   & ", " & to_string(data_array'length, 5) & " bytes)";
  begin
    shared_vvc_cmd := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, TRANSMIT);

    -- Sanity check to avoid confusing fatal error
    check_value(data_array'length > 0, TB_ERROR, proc_call & "data_array length must be > 0", "VVC");

    -- Generate cmd record
    shared_vvc_cmd.data_array(0 to data_array'high) := data_array;
    shared_vvc_cmd.user_array(0 to user_array'high) := user_array;
    shared_vvc_cmd.data_array_length                := data_array'length;
    shared_vvc_cmd.user_array_length                := user_array'length;

    -- Send command record
    send_command_to_vvc(VVCT);
  end procedure;

  -- Overload without the user_array argument
  procedure axistream_transmit(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant msg              : in    string
    ) is
    -- Default user data : We don't know c_user_array length (how many words to send), so assume tdata = 8 bits (one data_array byte per word) 
    constant c_user_array : t_user_array(0 to C_VVC_CMD_DATA_MAX_WORDS-1) := (others => (others => '0'));
  begin
    axistream_transmit(VVCT, vvc_instance_idx, data_array, c_user_array, msg);
  end procedure;

  -- Overload for specifying the expected tuser (user_array)
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant user_array       : in    t_user_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                   & ", " & to_string(data_array'length) & "B)";
  begin
    shared_vvc_cmd                                  := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, EXPECT);
    -- Generate cmd record
    shared_vvc_cmd.data_array(0 to data_array'high) := data_array;
    shared_vvc_cmd.user_array(0 to user_array'high) := user_array;  -- user_array Length = data_array_length
    shared_vvc_cmd.data_array_length                := data_array'length;
    shared_vvc_cmd.user_array_length                := user_array'length;

--      shared_vvc_cmd.readyLowArray(0 to data_array'high) := (others => 0); -- default  no ready deassertion
    shared_vvc_cmd.alert_level := alert_level;
    send_command_to_vvc(VVCT);
  end procedure;

  -- Overload for calling axiStreamExpect() without a value for user_array:
  -- user_array will be set to don't care
  procedure axistream_expect(
    signal   VVCT             : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data_array       : in    t_slv8_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
                                   & ", " & to_string(data_array'length) & "B)";
    -- Default user data 
    -- Don't know #bytes in AXIStream tdata, so user_array length is unknown. 
    -- Make the array as short as possible for best simulation time during the check performed in the BFM. 
    constant c_user_array : t_user_array(0 downto 0) := (others => (others => '-'));
  begin
    axistream_expect(VVCT, vvc_instance_idx, data_array, c_user_array, msg, alert_level);
  end procedure;

end package body vvc_methods_pkg;
