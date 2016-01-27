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

use work.axilite_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;


--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_methods_pkg is

  --===============================================================================================
  -- Types and constants for the AXILITE VVC 
  --===============================================================================================
  constant C_VVC_NAME            : string := "AXILITE_VVC";

  signal AXILITE_VVCT  : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT     : t_vvc_target_record is AXILITE_VVCT;
  alias  t_bfm_config is t_axilite_bfm_config;

  type t_executor_result is record
    cmd_idx           : natural;   -- from UVVM handshake mechanism
    data              : std_logic_vector(127 downto 0);
    value_is_new      : boolean;   -- turn true/false for put/fetch
    fetch_is_accepted : boolean;
  end record;

  type t_executor_result_array is array (natural range <>) of t_executor_result;
  
  -- Type found in UVVM-Util types_pkg
  constant C_AXILITE_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
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
    bfm_config                            : t_axilite_bfm_config;
    msg_id_panel                          : t_msg_id_panel;
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_AXILITE_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                     => C_AXILITE_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                 => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold_severity  => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold           => C_CMD_QUEUE_COUNT_THRESHOLD,
    bfm_config                          => C_AXILITE_BFM_CONFIG_DEFAULT,
    msg_id_panel                        => C_VVC_MSG_ID_PANEL_DEFAULT
    );
    
  type t_vvc_status is
  record
    current_cmd_idx       : natural;
    previous_cmd_idx      : natural;
    pending_cmd_cnt       : natural;
  end record;

  type t_vvc_status_array is array (natural range <>) of t_vvc_status;

  constant C_VVC_STATUS_DEFAULT : t_vvc_status := (
    current_cmd_idx      => 0,
    previous_cmd_idx     => 0,
    pending_cmd_cnt      => 0
  );
  
  type t_transaction_info_for_waveview is
  record
    operation           : t_operation;
    addr                : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0);
    data                : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    byte_enable         : std_logic_vector(C_VVC_CMD_BYTE_ENABLE_MAX_LENGTH-1 downto 0);
    msg                 : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
  end record;

  type t_transaction_info_for_waveview_array is array (natural range <>) of t_transaction_info_for_waveview;

  constant C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT : t_transaction_info_for_waveview := (
    operation           =>  NO_OPERATION,
    addr                => (others => '0'),
    data                => (others => '0'),
    byte_enable         => (others => '1'),
    msg                 => (others => ' ')
  );
    
    
  shared variable shared_axilite_vvc_config : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_AXILITE_VVC_CONFIG_DEFAULT);
  shared variable shared_axilite_vvc_status : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_axilite_transaction_info_for_waveview : t_transaction_info_for_waveview_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT);


  --==============================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to queue BFM calls 
  --   in the VVC command queue. The VVC will store and forward these calls to the 
  --   AXILITE BFM when the command is at the from of the VVC command queue. 
  -- - For details on how the BFM procedures work, see axilite_bfm_pkg.vhd and
  --   the quickref under doc/.
  --==============================================================================

  procedure axilite_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant byte_enable        : in std_logic_vector;
    constant msg                : in string
  );
  
  procedure axilite_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string
  );

  procedure axilite_read(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant msg                : in string
  );

  procedure axilite_check(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant alert_level        : in t_alert_level    := ERROR
  );

end package vvc_methods_pkg;

package body vvc_methods_pkg is



  --==============================================================================
  -- Methods dedicated to this VVC
  -- Notes:
  --   - shared_vvc_cmd is initialised to C_VVC_CMD_DEFAULT, and also reset to this after every command
  --==============================================================================

  procedure axilite_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant byte_enable        : in std_logic_vector;
    constant msg                : in string
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) 
        & ", " & to_string(byte_enable, BIN, AS_IS, INCL_RADIX) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                                             := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, WRITE);
    shared_vvc_cmd.addr(addr'length-1 downto 0)                := addr;
    shared_vvc_cmd.data(data'length-1 downto 0)                := data;
    shared_vvc_cmd.byte_enable(byte_enable'length-1 downto 0)  := byte_enable;
    send_command_to_vvc(VVCT);
  end procedure;
  
  procedure axilite_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                                    := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, WRITE);
    shared_vvc_cmd.addr(addr'length-1 downto 0)       := addr;
    shared_vvc_cmd.data(data'length-1 downto 0)       := data;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure axilite_read(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant msg                : in string
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                                    := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, READ);
    shared_vvc_cmd.operation                          := READ;
    shared_vvc_cmd.addr(addr'length-1 downto 0)       := addr;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure axilite_check(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR
  ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                                    := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, CHECK);
    shared_vvc_cmd.addr(addr'length-1 downto 0)       := addr;
    shared_vvc_cmd.data(data'length-1 downto 0)       := data;
    shared_vvc_cmd.alert_level                        := alert_level;
    send_command_to_vvc(VVCT);
  end procedure;


end package body vvc_methods_pkg;


