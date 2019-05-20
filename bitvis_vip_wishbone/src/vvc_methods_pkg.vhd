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

use work.wishbone_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;

--========================================================================================================================
--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the WISHBONE VVC 
  --========================================================================================================================
  constant C_VVC_NAME     : string := "WISHBONE_VVC";

  signal WISHBONE_VVCT     : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias  THIS_VVCT         : t_vvc_target_record is WISHBONE_VVCT;
  alias  t_bfm_config is t_wishbone_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_WISHBONE_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                          => NO_DELAY,
    delay_in_time                       => 0 ns,
    inter_bfm_delay_violation_severity  => WARNING
  );

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;     -- Minimum delay between BFM accesses from the VVC. If parameter delay_type is set to NO_DELAY, BFM accesses will be back to back, i.e. no delay.
    cmd_queue_count_max                   : natural;               -- Maximum pending number in command queue before queue is full. Adding additional commands will result in an ERROR.
    cmd_queue_count_threshold             : natural;               -- An alert with severity 'cmd_queue_count_threshold_severity' will be issued if command queue exceeds this count. Used for early warning if command queue is almost full. Will be ignored if set to 0.
    cmd_queue_count_threshold_severity    : t_alert_level;         -- Severity of alert to be initiated if exceeding cmd_queue_count_threshold
    result_queue_count_max                : natural;
    result_queue_count_threshold_severity : t_alert_level;
    result_queue_count_threshold          : natural;
    bfm_config                            : t_wishbone_bfm_config; -- Configuration for the BFM. See BFM quick reference                                                                                                                                                   
    msg_id_panel                          : t_msg_id_panel;        -- VVC dedicated message ID panel
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_WISHBONE_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_WISHBONE_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_WISHBONE_BFM_CONFIG_DEFAULT,
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
    msg             : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    -- Example:
    operation           =>  NO_OPERATION,
    addr                => (others => '0'),
    data                => (others => '0'),
    msg                 => (others => ' ')
  );


  shared variable shared_wishbone_vvc_config : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_WISHBONE_VVC_CONFIG_DEFAULT);
  shared variable shared_wishbone_vvc_status : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_wishbone_transaction_info : t_transaction_info_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_TRANSACTION_INFO_DEFAULT);


  --==========================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order for the VVC to execute
  --   BFM calls towards the given interface. The VVC interpreter will queue these calls
  --   and then the VVC executor will fetch the commands from the queue and handle the
  --   actual BFM execution.
  --   For details on how the BFM procedures work, see the QuickRef.
  --==========================================================================================

  procedure wishbone_write(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );
  
  procedure wishbone_read(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant msg                : in string;
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );
  
  procedure wishbone_check(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR;
    constant scope              : in string        := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

end package vvc_methods_pkg;


package body vvc_methods_pkg is


  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================

  procedure wishbone_write( 
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "wishbone_write";
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
    send_command_to_vvc(VVCT, scope => scope);
  end procedure;
  
  procedure wishbone_read(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant msg                : in string;
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "wishbone_read";
    constant proc_call : string := proc_name & "(" & to_string(VVCT, vvc_instance_idx)  -- First part common for all
        & ", " & to_string(addr, HEX, AS_IS, INCL_RADIX) & ")";
    variable v_normalised_addr    : unsigned(shared_vvc_cmd.addr'length-1 downto 0) :=
        normalize_and_check(addr, shared_vvc_cmd.addr, ALLOW_WIDER_NARROWER, "addr", "shared_vvc_cmd.addr", proc_call & " called with to wide address. " & add_msg_delimiter(msg));
  begin
    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVCT, vvc_instance_idx, proc_call, msg, QUEUED, READ);
    shared_vvc_cmd.operation                          := READ;
    shared_vvc_cmd.addr                               := v_normalised_addr;
    send_command_to_vvc(VVCT, scope => scope);
  end procedure;
  
  procedure wishbone_check(
    signal   VVCT               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant addr               : in unsigned;
    constant data               : in std_logic_vector;
    constant msg                : in string;
    constant alert_level        : in t_alert_level := ERROR;
    constant scope              : in string        := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "wishbone_check";
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
    send_command_to_vvc(VVCT, scope => scope);
  end procedure;

end package body vvc_methods_pkg;
