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

use work.gpio_bfm_pkg.all;
use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;



--========================================================================================================================
package vvc_methods_pkg is

  --========================================================================================================================
  -- Types and constants for the GPIO VVC 
  --========================================================================================================================
  constant C_VVC_NAME : string := "GPIO_VVC";

  signal GPIO_VVCT : t_vvc_target_record := set_vvc_target_defaults(C_VVC_NAME);
  alias THIS_VVCT  : t_vvc_target_record is GPIO_VVCT;
  alias t_bfm_config is t_gpio_bfm_config;

  -- Type found in UVVM-Util types_pkg
  constant C_GPIO_INTER_BFM_DELAY_DEFAULT : t_inter_bfm_delay := (
    delay_type                         => NO_DELAY,
    delay_in_time                      => 0 ns,
    inter_bfm_delay_violation_severity => warning
    );

  type t_vvc_config is
  record
    inter_bfm_delay                       : t_inter_bfm_delay;
    cmd_queue_count_max                   : natural;
    cmd_queue_count_threshold_severity    : t_alert_level;
    cmd_queue_count_threshold             : natural;
    result_queue_count_max                : natural;  -- Maximum number of unfetched results before result_queue is full. 
    result_queue_count_threshold_severity : t_alert_level;  -- An alert with severity 'result_queue_count_threshold_severity' will be issued if command queue exceeds this count.
                                                      -- Used for early warning if result queue is almost full. Will be ignored if set to 0.
    result_queue_count_threshold          : natural;  -- Severity of alert to be initiated if exceeding result_queue_count_threshold
    bfm_config                            : t_gpio_bfm_config;
    msg_id_panel                          : t_msg_id_panel;
  end record;

  type t_vvc_config_array is array (natural range <>) of t_vvc_config;

  constant C_GPIO_VVC_CONFIG_DEFAULT : t_vvc_config := (
    inter_bfm_delay                       => C_GPIO_INTER_BFM_DELAY_DEFAULT,
    cmd_queue_count_max                   => C_CMD_QUEUE_COUNT_MAX,
    cmd_queue_count_threshold_severity    => C_CMD_QUEUE_COUNT_THRESHOLD_SEVERITY,
    cmd_queue_count_threshold             => C_CMD_QUEUE_COUNT_THRESHOLD,
    result_queue_count_max                => C_RESULT_QUEUE_COUNT_MAX,
    result_queue_count_threshold_severity => C_RESULT_QUEUE_COUNT_THRESHOLD_SEVERITY,
    result_queue_count_threshold          => C_RESULT_QUEUE_COUNT_THRESHOLD,
    bfm_config                            => C_GPIO_BFM_CONFIG_DEFAULT,
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

  type t_transaction_info is
  record
    operation : t_operation;
    msg       : string(1 to C_VVC_CMD_STRING_MAX_LENGTH);
    data      : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
  end record;

  type t_transaction_info_array is array (natural range <>) of t_transaction_info;

  constant C_TRANSACTION_INFO_DEFAULT : t_transaction_info := (
    data      => (others => '0'),
    operation => NO_OPERATION,
    msg       => (others => ' ')
    );


  shared variable shared_gpio_vvc_config       : t_vvc_config_array(0 to C_MAX_VVC_INSTANCE_NUM-1)       := (others => C_GPIO_VVC_CONFIG_DEFAULT);
  shared variable shared_gpio_vvc_status       : t_vvc_status_array(0 to C_MAX_VVC_INSTANCE_NUM-1)       := (others => C_VVC_STATUS_DEFAULT);
  shared variable shared_gpio_transaction_info : t_transaction_info_array(0 to C_MAX_VVC_INSTANCE_NUM-1) := (others => C_TRANSACTION_INFO_DEFAULT);


  --========================================================================================================================
  -- Methods dedicated to this VVC 
  -- - These procedures are called from the testbench in order to queue BFM calls 
  --   in the VVC command queue. The VVC will store and forward these calls to the
  --   GPIO BFM when the command is at the from of the VVC command queue.
  --========================================================================================================================

  procedure gpio_set(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant data         : in    std_logic_vector;
    constant msg          : in    string := ""
    );

  procedure gpio_get(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant msg          : in    string := ""
    );

  procedure gpio_check(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string        := "";
    constant alert_level  : in    t_alert_level := error
    );

  procedure gpio_expect(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant data_exp     : in    std_logic_vector;
    constant timeout      : in    time          := 1 us;
    constant msg          : in    string        := "";
    constant alert_level  : in    t_alert_level := error
    );


end package vvc_methods_pkg;


package body vvc_methods_pkg is


  --========================================================================================================================
  -- Methods dedicated to this VVC
  --========================================================================================================================


  procedure gpio_set(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant data         : in    std_logic_vector;
    constant msg          : in    string := ""
    ) is
    constant proc_name : string := "gpio_set";
    constant proc_call : string := proc_name & "(" & to_string(VVC, instance_idx)  -- First part common for all
                                   & ", " & ", " & to_string(data, HEX, KEEP_LEADING_0, INCL_RADIX) & ")";                                   
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data'length-1 downto 0) :=
      normalize_and_check(data, shared_vvc_cmd.data, ALLOW_WIDER_NARROWER, "data", "shared_vvc_cmd.data", proc_call & " called with to wide data. " & add_msg_delimiter(msg));
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVC, instance_idx, proc_call, msg, QUEUED, SET);
    shared_vvc_cmd.operation := SET;
    shared_vvc_cmd.data      := v_normalised_data;
    send_command_to_vvc(VVC);
  end procedure;


  procedure gpio_get(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant msg          : in    string := ""
    ) is
    constant proc_name : string := "gpio_get";
    constant proc_call : string := proc_name & "(" & to_string(VVC, instance_idx)  -- First part common for all
                                   & ", " & ")";
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVC, instance_idx, proc_call, msg, QUEUED, GET);
    shared_vvc_cmd.operation := GET;
    send_command_to_vvc(VVC);
  end procedure;


  procedure gpio_check(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant data_exp     : in    std_logic_vector;
    constant msg          : in    string        := "";
    constant alert_level  : in    t_alert_level := error
    ) is
    constant proc_name : string := "gpio_check";
    constant proc_call : string := proc_name & "(" & to_string(VVC, instance_idx)  -- First part common for all
                                   & ", " & to_string(data_exp, HEX, KEEP_LEADING_0, INCL_RADIX) & ")";                                   
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data_exp'length-1 downto 0) :=
      normalize_and_check(data_exp, shared_vvc_cmd.data_exp, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data_exp", proc_call & " called with to wide data. " & add_msg_delimiter(msg));
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVC, instance_idx, proc_call, msg, QUEUED, CHECK);
    shared_vvc_cmd.data_exp    := v_normalised_data;
    shared_vvc_cmd.alert_level := alert_level;
    shared_vvc_cmd.operation   := CHECK;
    send_command_to_vvc(VVC);
  end procedure;


  procedure gpio_expect(
    signal VVC            : inout t_vvc_target_record;
    constant instance_idx : in    integer;
    constant data_exp     : in    std_logic_vector;
    constant timeout      : in    time          := 1 us;
    constant msg          : in    string        := "";
    constant alert_level  : in    t_alert_level := error
    ) is
    constant proc_name : string := "gpio_expect";
    constant proc_call : string := proc_name & "(" & to_string(VVC, instance_idx)  -- First part common for all
                                   & ", " & to_string(data_exp, HEX, KEEP_LEADING_0, INCL_RADIX) & ")";                                   
    variable v_normalised_data : std_logic_vector(shared_vvc_cmd.data_exp'length-1 downto 0) :=
      normalize_and_check(data_exp, shared_vvc_cmd.data_exp, ALLOW_WIDER_NARROWER, "data_exp", "shared_vvc_cmd.data_exp", proc_call & " called with to wide data. " & add_msg_delimiter(msg));
  begin

    -- Create command by setting common global 'VVCT' signal record and dedicated VVC 'shared_vvc_cmd' record
    -- locking semaphore in set_general_target_and_command_fields to gain exclusive right to VVCT and shared_vvc_cmd
    -- semaphore gets unlocked in await_cmd_from_sequencer of the targeted VVC
    set_general_target_and_command_fields(VVC, instance_idx, proc_call, msg, QUEUED, EXPECT);
    shared_vvc_cmd.data_exp    := v_normalised_data;
    shared_vvc_cmd.timeout     := timeout;
    shared_vvc_cmd.alert_level := alert_level;
    send_command_to_vvc(VVC);
  end procedure;

end package body vvc_methods_pkg;
