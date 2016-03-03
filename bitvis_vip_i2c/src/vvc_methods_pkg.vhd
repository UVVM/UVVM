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
    inter_bfm_delay                    : t_inter_bfm_delay;
    cmd_queue_count_max                : natural;
    cmd_queue_count_threshold_severity : t_alert_level;
    cmd_queue_count_threshold          : natural;
    bfm_config                         : t_i2c_bfm_config;
    msg_id_panel                       : t_msg_id_panel;
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_I2C_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                    => C_I2C_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold_severity => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold          => C_CMD_QUEUE_COUNT_THRESHOLD,
    bfm_config                         => C_I2C_BFM_CONFIG_DEFAULT,
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
    operation : t_operation;
    msg       : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    addr      : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0);
    data      : t_byte_array(0 to C_VVC_CMD_DATA_MAX_LENGTH-1);
    num_bytes : natural;
    continue  : boolean;
  end record;

  type t_transaction_info_for_waveview_array is array (natural range <>) of t_transaction_info_for_waveview;

  constant C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT : t_transaction_info_for_waveview := (
    addr      => (others => '0'),
    data      => (others => (others => '0')),
    num_bytes => 0,
    operation => NO_OPERATION,
    msg       => (others => ' '),
    continue  => true
    );


  shared variable shared_i2c_vvc_config                    : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM)                    := (others => C_I2C_VVC_CONFIG_DEFAULT);
  shared variable shared_i2c_vvc_status                    : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM)                    := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_i2c_transaction_info_for_waveview : t_transaction_info_for_waveview_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_TRANSACTION_INFO_FOR_WAVEVIEW_DEFAULT);

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
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant continue         : in    boolean := false
    );

  -- single byte
  procedure i2c_master_transmit(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant continue         : in    boolean := false
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
  -- master check
  --
  -- *****************************************************************************

  -- multi-byte
  procedure i2c_master_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant continue         : in    boolean       := false;
    constant alert_level      : in    t_alert_level := error
    );

  -- single byte
  procedure i2c_master_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant continue         : in    boolean       := false;
    constant alert_level      : in    t_alert_level := error
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
    constant alert_level      : in    t_alert_level := error
    );

  -- single byte
  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    std_logic_vector;
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
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant continue         : in    boolean := false
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";

    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) :=
      normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_NARROWER, "addr", "shared_vvc_cmd.addr", msg);

  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                            := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_TRANSMIT);
    shared_vvc_cmd.addr                       := v_normalized_addr;
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    shared_vvc_cmd.continue                   := continue;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_master_transmit(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant continue         : in    boolean := false
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";

    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_master_transmit(VVCT, vvc_instance_idx, addr, v_byte_array, msg, continue);
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
    shared_vvc_cmd                            := C_VVC_CMD_DEFAULT;
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
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";

    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_slave_transmit(VVCT, vvc_instance_idx, v_byte_array, msg);
  end procedure;

  -- master check
  procedure i2c_master_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant continue         : in    boolean       := false;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";

    -- Normalize to the 10 bit addr width
    variable v_normalized_addr : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH - 1 downto 0) :=
      normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_NARROWER, "addr", "shared_vvc_cmd.addr", msg);
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                            := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, MASTER_CHECK);
    shared_vvc_cmd.addr                       := v_normalized_addr;
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    shared_vvc_cmd.alert_level                := alert_level;
    shared_vvc_cmd.continue                   := continue;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_master_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant addr             : in    unsigned;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant continue         : in    boolean       := false;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";

    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_master_check(VVCT, vvc_instance_idx, addr, v_byte_array, msg, continue, alert_level);
  end procedure;

  -- slave check
  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    t_byte_array;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    shared_vvc_cmd                            := C_VVC_CMD_DEFAULT;
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, SLAVE_CHECK);
    shared_vvc_cmd.data(0 to data'length - 1) := data;
    shared_vvc_cmd.num_bytes                  := data'length;
    shared_vvc_cmd.alert_level                := alert_level;
    send_command_to_vvc(VVCT);
  end procedure;

  procedure i2c_slave_check(
    signal VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx : in    integer;
    constant data             : in    std_logic_vector;
    constant msg              : in    string;
    constant alert_level      : in    t_alert_level := error
    ) is
    constant proc_name : string := get_procedure_name_from_instance_name(vvc_instance_idx'instance_name);
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx) & ")";

    variable v_byte : std_logic_vector(7 downto 0) := (others => '0');

    -- Normalize to the 8 bit data width
    variable v_normalized_data : std_logic_vector(7 downto 0) :=
      normalize_and_check(data, v_byte, ALLOW_NARROWER, "data", "v_byte", msg);

    variable v_byte_array : t_byte_array(0 to 0) := (0 => v_normalized_data);
  begin
    i2c_slave_check(VVCT, vvc_instance_idx, v_byte_array, msg, alert_level);
  end procedure;
end package body vvc_methods_pkg;


