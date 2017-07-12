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

use work.avalon_mm_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;


--=================================================================================================
--=================================================================================================
--=================================================================================================
package vvc_methods_pkg is

  --===============================================================================================
  -- Types and constants for the SBI VVC 
  --===============================================================================================
  constant C_VVC_NAME     : string := "AVALON_MM_VVC";

  signal AVALON_MM_VVCT   : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT        : t_vvc_target_record is AVALON_MM_VVCT;
  alias  t_bfm_config is t_avalon_mm_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_AVALON_MM_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                          => NO_DELAY,
    delay_in_time                       => 0 ns,
    inter_bfm_delay_violation_severity  => WARNING
  );
  
  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay; -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;           -- Maximum pending number in command queue before queue is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;           -- An alert with severity “cmd_queue_count_threshold_severity” will be issued if command queue exceeds this count. Used for early warning if command queue is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;     -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural;        -- Maximum number of unfetched results before result_queue is full. 
    result_queue_count_threshold_severity : t_alert_level;  -- An alert with severity 'result_queue_count_threshold_severity' will be issued if command queue exceeds this count. Used for early warning if result queue is almost full. Will be ignored if set to 0.
    result_queue_count_threshold          : natural;        -- Severity of alert to be initiated if exceeding result_queue_count_threshold
    bfm_config                            : t_bfm_config;      -- Configuration for Avalon-MM BFM. See quick reference for Avalon-MM BFM
    use_read_pipeline                     : boolean;           -- When true, allows sending multiple read_requests before receiving a read_response
    num_pipeline_stages                   : natural;           -- Max read_requests in pipeline
    msg_id_panel                          : t_msg_id_panel;    -- VVC dedicated message ID panel
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_AVALON_MM_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_AVALON_MM_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX, --  from adaptation package
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_AVALON_MM_BFM_CONFIG_DEFAULT,
    use_read_pipeline                     => TRUE,
    num_pipeline_stages                   => 5,
    msg_id_panel                          => C_VVC_MSG_ID_PANEL_DEFAULT
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
  
  -- Transaction information to include in the wave view during simulation
  type t_transaction_info is
  record
    operation       : t_operation;
    addr            : unsigned(C_VVC_CMD_ADDR_MAX_LENGTH-1 downto 0);
    data            : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    byte_enable     : std_logic_vector(C_VVC_CMD_BYTE_ENABLE_MAX_LENGTH-1 downto 0);
    msg             : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    operation           =>  NO_OPERATION,
    addr                => (others => '0'),
    data                => (others => '0'),
    byte_enable         => (others => '1'),
    msg                 => (others => ' ')
  );
    
    
  shared variable shared_avalon_mm_vvc_config : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_AVALON_MM_VVC_CONFIG_DEFAULT);
  shared variable shared_avalon_mm_vvc_status : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_avalon_mm_transaction_info : t_transaction_info_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_TRANSACTION_INFO_DEFAULT);


  --==============================================================================
  -- Methods dedicated to this VVC
  -- - These procedures are called from the testbench in order to queue BFM calls 
  --   in the VVC command queue. The VVC will store and forward these calls to the 
  --   SBI BFM when the command is at the from of the VVC command queue. 
  -- - For details on how the BFM procedures work, see sbi_bfm_pkg.vhd or the 
  --   quickref.
  --==============================================================================

  -- Without byte enable
  procedure avalon_mm_write (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string
  );
  
  -- With byte enable
  procedure avalon_mm_write (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant byte_enable        : in std_logic_vector;
    constant msg                : in string
  );

  procedure avalon_mm_read (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant msg                : in string
  );

  procedure avalon_mm_check (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR
  );

  procedure avalon_mm_reset (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant num_rst_cycles     : in integer;
    constant msg                : in string
  );
  
  procedure avalon_mm_lock (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg                : in string
  );

  procedure avalon_mm_unlock (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg                : in string
  );

end package vvc_methods_pkg;

package body vvc_methods_pkg is



  --==============================================================================
  -- Methods dedicated to this VVC
  -- Notes:
  --   - shared_vvc_cmd is initialised to C_VVC_CMD_DEFAULT, and also reset to this after every command
  --==============================================================================

  procedure avalon_mm_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string
  ) is
    constant proc_name : string := "avalon_mm_write";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_addr    : unsigned(shared_vvc_cmd.addr'length-1 downto 0) :=
        normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
    variable v_normalised_data    : std_logic_vector(shared_vvc_cmd.data'length-1 downto 0) :=
        normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", proc_call & " called with to wide data. " & add_msg_delimiter(msg));
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, WRITE);
    shared_vvc_cmd.addr                               := v_normalised_addr;
    shared_vvc_cmd.data                               := v_normalised_data;
    send_command_to_vvc(VVCT);
  end procedure;
  
  
  procedure avalon_mm_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant byte_enable        : in std_logic_vector;
    constant msg                : in string
  ) is
    constant proc_name : string := "avalon_mm_write";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) 
        & ", " & to_string(byte_enable, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_addr    : unsigned(shared_vvc_cmd.addr'length-1 downto 0) :=
        normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
    variable v_normalised_data    : std_logic_vector(shared_vvc_cmd.data'length-1 downto 0) :=
        normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", proc_call & " called with to wide data. " & add_msg_delimiter(msg));
    variable v_normalised_byte_ena    : std_logic_vector(shared_vvc_cmd.byte_enable'length-1 downto 0) :=
        normalize_and_check(byte_enable, shared_vvc_cmd.byte_enable, ALLOW_WIDER_NARROWER, "byte_enable", "shared_vvc_cmd.byte_enable", proc_call & " called with to wide byte_enable. " & add_msg_delimiter(msg));
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, WRITE);
    shared_vvc_cmd.addr                                           := v_normalised_addr;
    shared_vvc_cmd.data                                           := v_normalised_data;
    shared_vvc_cmd.byte_enable                                    := v_normalised_byte_ena;
    send_command_to_vvc(VVCT);
  end procedure;

  
  procedure avalon_mm_read(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant msg                : in string
  ) is
    constant proc_name : string := "avalon_mm_read";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_addr    : unsigned(shared_vvc_cmd.addr'length-1 downto 0) :=
        normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr",proc_call & " called with to wide address. " & add_msg_delimiter(msg));
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, READ);
    shared_vvc_cmd.operation                          := READ;
    shared_vvc_cmd.addr                               := v_normalised_addr;
    send_command_to_vvc(VVCT);
  end procedure;

  
  procedure avalon_mm_check(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR
  ) is
    constant proc_name : string := "avalon_mm_check";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ", " & to_string(data, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_addr    : unsigned(shared_vvc_cmd.addr'length-1 downto 0) :=
        normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
    variable v_normalised_data    : std_logic_vector(shared_vvc_cmd.data'length-1 downto 0) :=
        normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", proc_call & " called with to wide data. " & add_msg_delimiter(msg));
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, CHECK);
    shared_vvc_cmd.addr                               := v_normalised_addr;
    shared_vvc_cmd.data                               := v_normalised_data;
    shared_vvc_cmd.alert_level                        := alert_level;
    send_command_to_vvc(VVCT);
  end procedure;


  procedure avalon_mm_reset(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant num_rst_cycles     : in integer;
    constant msg                : in string
  ) is
    constant proc_name : string := "avalon_mm_reset";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(num_rst_cycles) & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, RESET);
    shared_vvc_cmd.gen_integer_array(0) := num_rst_cycles;
    send_command_to_vvc(VVCT);
  end procedure;
  

  procedure avalon_mm_lock (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg                : in string
  ) is
    constant proc_name : string := "avalon_mm_lock";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, LOCK);
    send_command_to_vvc(VVCT);
  end procedure;
  
  procedure avalon_mm_unlock (
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg                : in string
  ) is
    constant proc_name : string := "avalon_mm_unlock";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ")";
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, UNLOCK);
    send_command_to_vvc(VVCT);
  end procedure;  

end package body vvc_methods_pkg;


