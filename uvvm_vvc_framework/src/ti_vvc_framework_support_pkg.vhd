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
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package ti_vvc_framework_support_pkg is

  constant C_VVC_NAME_MAX_LENGTH : natural := 20;

  ------------------------------------------------------------------------
  -- Common support types for UVVM
  ------------------------------------------------------------------------
  type t_immediate_or_queued is (NO_command_type, IMMEDIATE, QUEUED);

  type t_flag_record is record
    set        : std_logic;
    reset      : std_logic;
    is_active  : std_logic;
  end record;

  type t_uvvm_state is (IDLE, PHASE_A, PHASE_B, INIT_COMPLETED);

  type t_lastness   is (LAST, NOT_LAST);

  type t_broadcastable_cmd is (NO_CMD, ENABLE_LOG_MSG, DISABLE_LOG_MSG, FLUSH_COMMAND_QUEUE, INSERT_DELAY, AWAIT_COMPLETION, TERMINATE_CURRENT_COMMAND);

  constant C_BROADCAST_CMD_STRING_MAX_LENGTH        : natural := 300;

  type t_vvc_broadcast_cmd_record is record
    operation           : t_broadcastable_cmd;
    msg_id              : t_msg_id;
    msg                 : string(1 to C_BROADCAST_CMD_STRING_MAX_LENGTH);
    proc_call           : string(1 to C_BROADCAST_CMD_STRING_MAX_LENGTH);
    quietness           : t_quietness;
    delay               : time;
    timeout             : time;
    gen_integer         : integer;
  end record;

  constant C_VVC_BROADCAST_CMD_DEFAULT : t_vvc_broadcast_cmd_record := (
    operation           => NO_CMD,
    msg_id              => NO_ID,
    msg                 => (others => NUL),
    proc_call           => (others => NUL),
    quietness           => NON_QUIET,
    delay               => 0 ns,
    timeout             => 0 ns,
    gen_integer         => -1
  );


  type t_vvc_id is record
    name      : string(1 to C_VVC_NAME_MAX_LENGTH);
    instance  : natural;
    channel   : t_channel;
  end record;

  constant C_VVC_ID_DEFAULT : t_vvc_id := (
    name      => (others => ' '),
    instance  => 0,
    channel   => NA
  );

  type t_vvc_status is record
    busy      : boolean;
    cmd_idx   : integer; -- last_executed_cmd
  end record;

  constant  C_VVC_STATUS_DEFAULT : t_vvc_status := (
    busy    => false,
    cmd_idx => -1
  );

  type t_vvc_item is record
    vvc_id      : t_vvc_id;
    vvc_status  : t_vvc_status;
  end record;

  constant C_VVC_ITEM_DEFAULT : t_vvc_item := (
    vvc_id      => C_VVC_ID_DEFAULT,
    vvc_status  => C_VVC_STATUS_DEFAULT
  );



  ------------------------------------------------------------------------
  -- Common signals for acknowledging a pending command
  ------------------------------------------------------------------------
  shared variable shared_vvc_broadcast_cmd    : t_vvc_broadcast_cmd_record := C_VVC_BROADCAST_CMD_DEFAULT;
  signal VVC_BROADCAST                        : std_logic := 'L';


  ------------------------------------------------------------------------
  -- Common signal for signalling between VVCs, used during await_any_completion()
  -- Default (when not active): Z
  -- Awaiting: 1:
  -- Completed: 0
  -- This signal is a vector to support multiple sequencers calling await_any_completion simultaneously:
  -- - When calling await_any_completion, each sequencer specifies which bit in this global signal the VVCs shall use.
  ------------------------------------------------------------------------
  signal global_awaiting_completion : std_logic_vector(C_MAX_NUM_SEQUENCERS-1 downto 0);    -- ACK on global triggers


  ------------------------------------------------------------------------
  -- Shared variables for UVVM framework
  ------------------------------------------------------------------------
  shared variable shared_cmd_idx      : integer := 0;
  shared variable shared_uvvm_state   : t_uvvm_state := IDLE;


  -------------------------------------------
  -- flag_handler
  -------------------------------------------
  -- Flag handler is a general flag/semaphore handling mechanism between two separate processes/threads
  -- The idea is to allow one process to set a flag and another to reset it. The flag may then be used by both - or others
  -- May be used for a message from process 1 to process 2 with acknowledge; - like do-something & done, or valid & ack
  procedure flag_handler(
    signal flag : inout t_flag_record
  );


  -------------------------------------------
  -- set_flag
  -------------------------------------------
  -- Sets reset and is_active to 'Z' and pulses set_flag
  procedure set_flag(
    signal flag : inout t_flag_record
  );


  -------------------------------------------
  -- reset_flag
  -------------------------------------------
  -- Sets set and is_active to 'Z' and pulses reset_flag
  procedure reset_flag(
    signal flag : inout t_flag_record
  );


  -------------------------------------------
  -- await_uvvm_initialization
  -------------------------------------------
  -- Waits until uvvm has been initialized
  procedure await_uvvm_initialization(
    constant dummy : in t_void
  );


  -------------------------------------------
  -- format_command_idx
  -------------------------------------------
  -- Converts the command index to string, enclused by
  -- C_CMD_IDX_PREFIX and C_CMD_IDX_SUFFIX
 impure function format_command_idx(
    command_idx : integer
  ) return string;


  --***********************************************
  -- BROADCAST COMMANDS
  --***********************************************

  -------------------------------------------
  -- enable_log_msg (Broadcast)
  -------------------------------------------
  -- Enables a log message for all VVCs
  procedure enable_log_msg(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := "";
    constant quietness          : in t_quietness := NON_QUIET;
    constant scope              : in string      := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- disable_log_msg (Broadcast)
  -------------------------------------------
  -- Disables a log message for all VVCs
  procedure disable_log_msg(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := "";
    constant quietness          : in t_quietness := NON_QUIET;
    constant scope              : in string      := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- flush_command_queue (Broadcast)
  -------------------------------------------
  -- Flushes the command queue for all VVCs
  procedure flush_command_queue(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- insert_delay (Broadcast)
  -------------------------------------------
  -- Inserts delay into all VVCs (specified as number of clock cycles)
  procedure insert_delay(
    signal VVC_BROADCAST        : inout std_logic;
    constant delay              : in natural;  -- in clock cycles
    constant msg                : in string  := "";
    constant scope              : in string  := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- insert_delay (Broadcast)
  -------------------------------------------
  -- Inserts delay into all VVCs (specified as time)
  procedure insert_delay(
    signal VVC_BROADCAST        : inout std_logic;
    constant delay              : in time;
    constant msg                : in string  := "";
    constant scope              : in string  := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- await_completion (Broadcast)
  -------------------------------------------
  -- Wait for all VVCs to finish (specified as time)
  procedure await_completion(
    signal VVC_BROADCAST        : inout std_logic;
    constant timeout            : in time;
    constant msg                : in string  := "";
    constant scope              : in string  := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- terminate_current_command (Broadcast)
  -------------------------------------------
  -- terminates all current tasks
  procedure terminate_current_command(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg                : in string  := "";
    constant scope              : in string  := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- terminate_all_commands (Broadcast)
  -------------------------------------------
  -- terminates all tasks
  procedure terminate_all_commands(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg                : in string  := "";
    constant scope              : in string  := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );
  -------------------------------------------
  -- transmit_broadcast
  -------------------------------------------
  -- Common broadcast transmission routine
  procedure transmit_broadcast(
    signal VVC_BROADCAST        : inout std_logic;
    constant operation          : in t_broadcastable_cmd;
    constant proc_call          : in string;
    constant msg_id             : in t_msg_id;
    constant msg                : in string       := "";
    constant quietness          : in t_quietness  := NON_QUIET;
    constant delay              : in time         := 0 ns;
    constant delay_int          : in integer      := -1;
    constant timeout            : in time         := std.env.resolution_limit;
    constant scope              : in string       := C_TB_SCOPE_DEFAULT & "(uvvm)"
  );

  -------------------------------------------
  -- get_scope_for_log
  -------------------------------------------
  -- Returns a string with length <= C_LOG_SCOPE_WIDTH.
  -- Inputs vvc_name and channel are truncated to match C_LOG_SCOPE_WIDTH if to long.
  -- An alert is issued if C_MINIMUM_VVC_NAME_SCOPE_WIDTH and C_MINIMUM_CHANNEL_SCOPE_WIDTH
  -- are to long relative to C_LOG_SCOPE_WIDTH.
  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural;
    constant channel      : t_channel
  ) return string;

  -------------------------------------------
  -- get_scope_for_log
  -------------------------------------------
  -- Returns a string with length <= C_LOG_SCOPE_WIDTH.
  -- Input vvc_name is truncated to match C_LOG_SCOPE_WIDTH if to long.
  -- An alert is issued if C_MINIMUM_VVC_NAME_SCOPE_WIDTH
  -- is to long relative to C_LOG_SCOPE_WIDTH.
  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural
  ) return string;




-- ============================================================================
-- Activity Watchdog
-- ============================================================================

  shared variable shared_inactivity_watchdog : t_inactivity_watchdog;

  signal global_trigger_testcase_inactivity_watchdog : std_logic := 0;


  procedure activity_watchdog(
    constant timeout      : time;
    constant alert_level  : t_alert_level := ERROR;
    constant msg          : string := ""
  );


  type t_testcase_inactivity_watchdog is protected body

    function priv_are_all_vvc_inactive return boolean;

    function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel
    ) return integer;

    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant busy                   : boolean;
      constant last_executed_cmd_idx  : integer
    );
  end protected;


end package ti_vvc_framework_support_pkg;




package body ti_vvc_framework_support_pkg is

  ------------------------------------------------------------------------
  --
  ------------------------------------------------------------------------
  -- Flag handler is a general flag/semaphore handling mechanism between two separate processes/threads
  -- The idea is to allow one process to set a flag and another to reset it. The flag may then be used by both - or others
  -- May be used for a message from process 1 to process 2 with acknowledge; - like do-something & done, or valid & ack
  procedure flag_handler(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.reset <= 'Z';
    flag.set   <= 'Z';

    flag.is_active <= '0';
    wait until flag.set = '1';
    flag.is_active <= '1';
    wait until flag.reset = '1';
    flag.is_active <= '0';
  end procedure;

  procedure set_flag(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.reset <= 'Z';
    flag.is_active <= 'Z';
    gen_pulse(flag.set, 0 ns, "set flag");
  end procedure;

  procedure reset_flag(
    signal flag : inout t_flag_record
  ) is
  begin
    flag.set <= 'Z';
    flag.is_active <= 'Z';
    gen_pulse(flag.reset, 0 ns, "reset flag", C_TB_SCOPE_DEFAULT, ID_NEVER);
  end procedure;

  -- This procedure checks the shared_uvvm_state on each delta cycle
  procedure await_uvvm_initialization(
    constant dummy : in t_void) is
  begin
    while (shared_uvvm_state /= INIT_COMPLETED) loop
      wait for 0 ns;
    end loop;
  end procedure;

  impure function format_command_idx(
    command_idx : integer
  ) return string is
  begin
    return C_CMD_IDX_PREFIX & to_string(command_idx) & C_CMD_IDX_SUFFIX;
  end;


  procedure enable_log_msg(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := "";
    constant quietness          : in t_quietness := NON_QUIET;
    constant scope              : in string      := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "enable_log_msg";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_upper(to_string(msg_id)) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, ENABLE_LOG_MSG, proc_call, msg_id, msg, quietness, scope => scope);
  end procedure;


  procedure disable_log_msg(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := "";
    constant quietness          : in t_quietness := NON_QUIET;
    constant scope              : in string      := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "disable_log_msg";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_upper(to_string(msg_id)) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, DISABLE_LOG_MSG, proc_call, msg_id, msg, quietness, scope => scope);
  end procedure;


  procedure flush_command_queue(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "flush_command_queue";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    transmit_broadcast(VVC_BROADCAST, FLUSH_COMMAND_QUEUE, proc_call, NO_ID, msg, scope => scope);
  end procedure;


  procedure insert_delay(
    signal VVC_BROADCAST        : inout std_logic;
    constant delay              : in natural;  -- in clock cycles
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "insert_delay";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_string(delay) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, FLUSH_COMMAND_QUEUE, proc_call, NO_ID, msg, NON_QUIET, 0 ns, delay, scope => scope);
  end procedure;


  procedure insert_delay(
    signal VVC_BROADCAST        : inout std_logic;
    constant delay              : in time;
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "insert_delay";
    constant proc_call : string := proc_name & "(VVC_BROADCAST, " & to_string(delay) & ")";
  begin
    transmit_broadcast(VVC_BROADCAST, INSERT_DELAY, proc_call, NO_ID, msg, NON_QUIET, delay, scope => scope);
  end procedure;

  procedure await_completion(
    signal VVC_BROADCAST        : inout std_logic;
    constant timeout            : in time;
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "await_completion";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    transmit_broadcast(VVC_BROADCAST, AWAIT_COMPLETION, proc_call, NO_ID, msg, NON_QUIET, 0 ns, -1, timeout, scope);
  end procedure;

  procedure terminate_current_command(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "terminate_current_command";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    transmit_broadcast(VVC_BROADCAST, TERMINATE_CURRENT_COMMAND, proc_call, NO_ID, msg, scope => scope);
  end procedure;

  procedure terminate_all_commands(
    signal VVC_BROADCAST        : inout std_logic;
    constant msg                : in string := "";
    constant scope              : in string := C_TB_SCOPE_DEFAULT & "(uvvm)"
  ) is
    constant proc_name : string := "terminate_all_commands";
    constant proc_call : string := proc_name & "(VVC_BROADCAST)";
  begin
    flush_command_queue(VVC_BROADCAST, msg);
    terminate_current_command(VVC_BROADCAST, msg, scope => scope);
  end procedure;

  procedure transmit_broadcast(
    signal VVC_BROADCAST        : inout std_logic;
    constant operation          : in t_broadcastable_cmd;
    constant proc_call          : in string;
    constant msg_id             : in t_msg_id;
    constant msg                : in string       := "";
    constant quietness          : in t_quietness  := NON_QUIET;
    constant delay              : in time         := 0 ns;
    constant delay_int          : in integer      := -1;
    constant timeout            : in time         := std.env.resolution_limit;
    constant scope              : in string       := C_TB_SCOPE_DEFAULT & "(uvvm)") is
  begin
    await_semaphore_in_delta_cycles(protected_semaphore);

    -- Increment shared_cmd_idx. It is protected by the protected_semaphore and only one sequencer can access the variable at a time.
    shared_cmd_idx := shared_cmd_idx + 1;

    if global_show_msg_for_uvvm_cmd then
      log(ID_UVVM_SEND_CMD, to_string(proc_call) & ": " & add_msg_delimiter(to_string(msg))
          & format_command_idx(shared_cmd_idx), scope);
    else
      log(ID_UVVM_SEND_CMD, to_string(proc_call)
          & format_command_idx(shared_cmd_idx), scope);
    end if;

    shared_vvc_broadcast_cmd.operation   := operation;
    shared_vvc_broadcast_cmd.msg_id      := msg_id;
    shared_vvc_broadcast_cmd.msg         := (others => NUL); -- default empty
    shared_vvc_broadcast_cmd.msg(1 to msg'length) := msg;
    shared_vvc_broadcast_cmd.quietness   := quietness;
    shared_vvc_broadcast_cmd.timeout     := timeout;
    shared_vvc_broadcast_cmd.delay       := delay;
    shared_vvc_broadcast_cmd.gen_integer := delay_int;
    shared_vvc_broadcast_cmd.proc_call   := (others => NUL); -- default empty
    shared_vvc_broadcast_cmd.proc_call(1 to proc_call'length) := proc_call;

    if VVC_BROADCAST /= 'L' then
      -- a VVC is waiting for example in await_completion
      wait until VVC_BROADCAST = 'L';
    end if;

    -- Trigger the broadcast
    VVC_BROADCAST     <= '1';
    wait for 0 ns;
    -- set back to 'L' and wait until all VVCs have set it back
    VVC_BROADCAST <= 'L';

    wait until VVC_BROADCAST = 'L' for timeout;  -- Wait for executor
    if not (VVC_BROADCAST'event) and VVC_BROADCAST /= 'L' then            -- Indicates timeout
      tb_error("Timeout while waiting for the broadcast command to be ACK'ed", scope);
    else
      log(ID_UVVM_CMD_ACK, "ACK received for broadcast command" & format_command_idx(shared_cmd_idx), scope);
    end if;

    shared_vvc_broadcast_cmd  := C_VVC_BROADCAST_CMD_DEFAULT;

    wait for 0 ns;
    wait for 0 ns;
    wait for 0 ns;
    wait for 0 ns;
    wait for 0 ns;

    release_semaphore(protected_semaphore);

  end procedure;


  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural;
    constant channel      : t_channel
  ) return string is
    constant C_INSTANCE_IDX_STR          : string  := to_string(instance_idx);
    constant C_CHANNEL_STR               : string  := to_upper(to_string(channel));
    constant C_SCOPE_LENGTH              : natural := vvc_name'length + C_INSTANCE_IDX_STR'length + C_CHANNEL_STR'length + 2; -- +2 because of the two added commas
    variable v_vvc_name_truncation_value : integer;
    variable v_channel_truncation_value  : integer;
    variable v_vvc_name_truncation_idx   : integer;
    variable v_channel_truncation_idx    : integer;
  begin

    if (C_MINIMUM_VVC_NAME_SCOPE_WIDTH + C_MINIMUM_CHANNEL_SCOPE_WIDTH + C_INSTANCE_IDX_STR'length + 2) >  C_LOG_SCOPE_WIDTH then -- +2 because of the two added commas
      alert(TB_WARNING, "The combined width of C_MINIMUM_VVC_NAME_SCOPE_WIDTH and C_MINIMUM_CHANNEL_SCOPE_WIDTH cannot be greater than C_LOG_SCOPE_WIDTH - (number of characters in instance) - 2.", C_SCOPE);
    end if;

    -- If C_SCOPE_LENGTH is not greater than allowed width, return scope
    if C_SCOPE_LENGTH <= C_LOG_SCOPE_WIDTH then
      return vvc_name & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR;


    -- If C_SCOPE_LENGTH is greater than allowed width

    -- Check if vvc_name is greater than minimum width to truncate
    elsif vvc_name'length <= C_MINIMUM_VVC_NAME_SCOPE_WIDTH then
      return vvc_name & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR(1 to (C_CHANNEL_STR'length - (C_SCOPE_LENGTH-C_LOG_SCOPE_WIDTH)));

    -- Check if channel is greater than minimum width to truncate
    elsif C_CHANNEL_STR'length <= C_MINIMUM_CHANNEL_SCOPE_WIDTH then
      return vvc_name(1 to (vvc_name'length - (C_SCOPE_LENGTH-C_LOG_SCOPE_WIDTH))) & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR;

    -- If both vvc_name and channel is to be truncated
    else

      -- Calculate linear scaling of truncation between vvc_name and channel: (a*x)/(a+b), (b*x)/(a+b)
      v_vvc_name_truncation_idx  := integer(round(real(vvc_name'length * (C_SCOPE_LENGTH-C_LOG_SCOPE_WIDTH)))/real(vvc_name'length + C_CHANNEL_STR'length));
      v_channel_truncation_value := integer(round(real(C_CHANNEL_STR'length * (C_SCOPE_LENGTH-C_LOG_SCOPE_WIDTH)))/real(vvc_name'length + C_CHANNEL_STR'length));

      -- In case division ended with .5 and both rounded up
      if (v_vvc_name_truncation_idx + v_channel_truncation_value) > (C_SCOPE_LENGTH-C_LOG_SCOPE_WIDTH) then
        v_channel_truncation_value := v_channel_truncation_value - 1;
      end if;

      -- Character index to truncate
      v_vvc_name_truncation_idx := vvc_name'length - v_vvc_name_truncation_idx;
      v_channel_truncation_idx  := C_CHANNEL_STR'length - v_channel_truncation_value;

      -- If bellow minimum name width
      while v_vvc_name_truncation_idx < C_MINIMUM_VVC_NAME_SCOPE_WIDTH loop
        v_vvc_name_truncation_idx := v_vvc_name_truncation_idx + 1;
        v_channel_truncation_idx  := v_channel_truncation_idx - 1;
      end loop;

      -- If bellow minimum channel width
      while v_channel_truncation_idx < C_MINIMUM_CHANNEL_SCOPE_WIDTH loop
        v_channel_truncation_idx  := v_channel_truncation_idx + 1;
        v_vvc_name_truncation_idx := v_vvc_name_truncation_idx - 1;
      end loop;

      return vvc_name(1 to v_vvc_name_truncation_idx) & "," & C_INSTANCE_IDX_STR & "," & C_CHANNEL_STR(1 to v_channel_truncation_idx);

    end if;
  end function;

  impure function get_scope_for_log(
    constant vvc_name     : string;
    constant instance_idx : natural
  ) return string is
    constant C_INSTANCE_IDX_STR       : string  := to_string(instance_idx);
    constant C_SCOPE_LENGTH           : integer := vvc_name'length + C_INSTANCE_IDX_STR'length + 1; -- +1 because of the added comma
  begin

    if (C_MINIMUM_VVC_NAME_SCOPE_WIDTH + C_INSTANCE_IDX_STR'length + 1) >  C_LOG_SCOPE_WIDTH then -- +1 because of the added comma
      alert(TB_WARNING, "The width of C_MINIMUM_VVC_NAME_SCOPE_WIDTH cannot be greater than C_LOG_SCOPE_WIDTH - (number of characters in instance) - 1.", C_SCOPE);
    end if;

    -- If C_SCOPE_LENGTH is not greater than allowed width, return scope
    if C_SCOPE_LENGTH <= C_LOG_SCOPE_WIDTH then
      return vvc_name & "," & C_INSTANCE_IDX_STR;

    -- If C_SCOPE_LENGTH is greater than allowed width truncate vvc_name
    else
      return vvc_name(1 to (vvc_name'length - (C_SCOPE_LENGTH-C_LOG_SCOPE_WIDTH))) & "," & C_INSTANCE_IDX_STR;

    end if;
  end function;



-- ============================================================================
-- Activity Watchdog
-- ============================================================================


  -------------------------------------------------------------------------------
  -- Activity watchdog:
  -- Include this as a concurrent procedure from your testbench.
  -------------------------------------------------------------------------------
  procedure activity_watchdog(
    constant timeout      : time;
    constant alert_level  : t_alert_level := ERROR;
    constant msg          : string := ""
  ) is
    variable v_timeout    : time;
  begin
    wait for 0 ns;

    log(ID_WATCHDOG, "Starting activity watchdog: " & to_string(timeout)". " & msg);
    v_timeout       := timeout;

    loop
      wait until global_trigger_testcase_inactivity_watchdog for v_timeout;

      if not(global_trigger_testcase_inactivity_watchdog'event) and shared_inactivity_watchdog.priv_are_all_vvc_inactive then
          alert(alert_level, "Watchdog timer ended! " & msg);
      end if;

    end loop;
    wait;
  end procedure activity_watchdog;




  type t_testcase_inactivity_watchdog is protected body

    -- Array holding all registered VVCs
    type t_registered_vvc_array   is array (natural range <>) of t_vvc_item;
    variable priv_registered_vvc  : t_registered_vvc_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_VVC_ITEM_DEFAULT);
    -- Counter for the number of VVCs that has registered
    variable priv_last_registered_vvc_idx : integer := -1;


    function priv_are_all_vvc_inactive return boolean is
    begin
      for idx in 0 to priv_last_registered_vvc_idx loop
        if v_wd_monitored_vvc(idx).vvc_status.busy = true then
          return false;
        end if;
      end loop;

      return true;
    end function priv_are_all_vvc_inactive;

    function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel
    ) return integer is
    begin
      -- Set registered VVC index
      priv_last_registered_vvc_idx := priv_last_registered_vvc_idx + 1;

      -- Update register
      priv_wd_monitored_vvc(priv_last_registered_vvc_idx).vvc_id.name                      := name;
      priv_wd_monitored_vvc(priv_last_registered_vvc_idx).vvc_id.instance                  := instance;
      priv_wd_monitored_vvc(priv_last_registered_vvc_idx).vvc_id.channel                   := channel;
      priv_wd_monitored_vvc(priv_last_registered_vvc_idx).vvc_status.busy                  := false;
      priv_wd_monitored_vvc(priv_last_registered_vvc_idx).vvc_status.last_executed_cmd_idx := -1;

      -- Return index
      return priv_last_registered_vvc_idx;
    end function priv_register_vvc;


    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant busy                   : boolean;
      constant last_executed_cmd_idx  : integer
    ) is
    begin
      -- Update VVC status
      priv_wd_monitored_vvc(vvc_idx).vvc_status.busy                  := busy;
      priv_wd_monitored_vvc(vvc_idx).vvc_status.last_executed_cmd_idx := last_executed_cmd_idx;
    end procedure priv_report_vvc_activity;

  end protected testcase_inactivity_watchdog;



end package body ti_vvc_framework_support_pkg;

