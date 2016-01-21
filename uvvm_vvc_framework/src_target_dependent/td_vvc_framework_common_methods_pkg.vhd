--========================================================================================================================
-- Copyright (c) 2016 by Bitvis AS.  All rights reserved. Patent pending.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not, 
-- contact Bitvis AS <support@bitvis.no>.
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
--
-- Note: This package will be compiled into every single VVC library.
--       As the type t_vvc_target_record is already compiled into every single VVC library,
--       the type definition will be unique for every library, and thus result in a unique
--       procedure signature for every VVC. Hence the shared variable shared_vvc_cmd will
--       refer to only the shared variable defined in the given library.
------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.vvc_cmd_pkg.all;
use work.td_target_support_pkg.all;


package td_vvc_framework_common_methods_pkg is

 --======================================================================
 -- Common Methods
 --======================================================================

  -------------------------------------------
  -- await_completion
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Awaits completion of all commands in the queue for the specified VVC, or
  --   until timeout.
  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  );

  -------------------------------------------
  -- await_completion
  -------------------------------------------
  -- See description above
  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  );

  -------------------------------------------
  -- await_completion
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Awaits completion of the specified command 'wanted_idx' in the queue for the specified VVC, or
  --   until timeout.
  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant wanted_idx         : in natural;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  );

  -------------------------------------------
  -- await_completion
  -------------------------------------------
  -- See description above
  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant wanted_idx         : in natural;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  );


  -------------------------------------------
  -- disable_log_msg
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Disables the specified msg_id for the VVC
  procedure disable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  );

  -------------------------------------------
  -- disable_log_msg
  -------------------------------------------
  -- See description above
  procedure disable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  );


  -------------------------------------------
  -- enable_log_msg
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Enables the specified msg_id for the VVC
  procedure enable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  );

  -------------------------------------------
  -- enable_log_msg
  -------------------------------------------
  -- See description above
  procedure enable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  );


  -------------------------------------------
  -- flush_command_queue
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Flushes the command queue of the specified VVC
  procedure flush_command_queue(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant msg                : in string := ""
  );

  -------------------------------------------
  -- flush_command_queue
  -------------------------------------------
  -- See description above
  procedure flush_command_queue(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg                : in string := ""
  );

  -------------------------------------------
  -- fetch_result
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Fetches result from a VVC
  -- - Requires that result is available (i.e. already executed in respective VVC)
  -- - Logs with ID ID_UVVM_CMD_RESULT
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant wanted_idx         : in integer;
    variable result             : out std_logic_vector;
    variable fetch_is_accepted  : out boolean;
    variable value_is_new       : out boolean;
    constant msg                : in string         := "";
    constant alert_level        : in t_alert_level  := TB_ERROR;
    constant caller_name        : in string         := "base_procedure"
  );
  
  -------------------------------------------
  -- fetch_result
  -------------------------------------------
  -- Same as above but without fetch_is_accepted and value_is_new.
  -- Will trigger alert with alert_level if not OK.
  -- Will trigger TB_WARNING if not new value, i.e., if the value
  -- has been fetched previously.
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant wanted_idx         : in integer;
    variable result             : out std_logic_vector;
    constant msg                : in string         := "";
    constant alert_level        : in t_alert_level  := TB_ERROR
  );

  -------------------------------------------
  -- fetch_result
  -------------------------------------------
  -- - This version does not use vvc_channel.
  -- - Fetches result from a VVC
  -- - Requires that result is available (i.e. already executed in respective VVC)
  -- - Logs with ID ID_UVVM_CMD_RESULT
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant wanted_idx         : in integer;
    variable result             : out std_logic_vector;
    variable fetch_is_accepted  : out boolean;
    variable value_is_new       : out boolean;
    constant msg                : in string         := "";
    constant alert_level        : in t_alert_level  := TB_ERROR
  );
  
  -------------------------------------------
  -- fetch_result
  -------------------------------------------
  -- Same as above but without fetch_is_accepted and value_is_new.
  -- Will trigger alert with alert_level if not OK.
  -- Will trigger TB_WARNING if not new value, i.e., if the value
  -- has been fetched previously.
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant wanted_idx         : in integer;
    variable result             : out std_logic_vector;
    constant msg                : in string         := "";
    constant alert_level        : in t_alert_level  := TB_ERROR
  );
  
  -------------------------------------------
  -- insert_delay
  -------------------------------------------
  -- VVC executor QUEUED command
  -- - Inserts delay for 'delay' clock cycles
  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant delay              : in natural;  -- in clock cycles
    constant msg                : in string  := ""
  );

  -------------------------------------------
  -- insert_delay
  -------------------------------------------
  -- See description above
  procedure insert_delay(
    signal   vvc_target           : inout t_vvc_target_record;
    constant vvc_instance_idx     : in integer;
    constant delay                : in natural;  -- in clock cycles
    constant msg                  : in string  := ""
  );

  -------------------------------------------
  -- insert_delay
  -------------------------------------------
  -- VVC executor QUEUED command
  -- - Inserts delay for a given time
  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant delay              : in time;
    constant msg                : in string  := ""
  );

  -------------------------------------------
  -- insert_delay
  -------------------------------------------
  -- See description above
  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant delay              : in time;
    constant msg                : in string  := ""
  );


  -------------------------------------------
  -- terminate_current_command
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Terminates the current command being processed in the VVC executor
  procedure terminate_current_command(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel   := NA;
    constant msg                : in string      := ""
  );

  -------------------------------------------
  -- terminate_all_commands
  -------------------------------------------
  -- VVC interpreter IMMEDIATE command
  -- - Terminates the current command being processed in the VVC executor, and
  --   flushes the command queue
  procedure terminate_all_commands(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel   := NA;
    constant msg                : in string      := ""
  );


end package td_vvc_framework_common_methods_pkg;




package body td_vvc_framework_common_methods_pkg is

--=========================================================================================
--  Methods
--=========================================================================================

-- NOTE: ALL VVCs using this td_vvc_framework_common_methods_pkg package MUST have the following declared in theor local vvc_cmd_pkg.
--       - The enumerated t_operation  (e.g. AWAIT_COMPLETION, ENABLE_LOG_MSG, etc.)
--       Any VVC based on an older version of td_vvc_framework_common_methods_pkg must - if new operators have been introduced in td_vvc_framework_common_methods_pkg either
--       a) include the new operator(s) in its t_operation, or
--       b) change the use-reference to an older common_methods package.


  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  ) is
    constant proc_name : string := "await_completion";
--    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_string(timeout, ns) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, AWAIT_COMPLETION);
    shared_vvc_cmd.gen_integer  := -1;  -- All commands must be completed (i.e. not just a selected command index)
    send_command_to_vvc(vvc_target, timeout);
  end procedure;

  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  ) is
  begin
    await_completion(vvc_target, vvc_instance_idx, NA, timeout, msg);
  end procedure;

  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant wanted_idx         : in natural;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  ) is
    constant proc_name : string := "await_completion";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_string(wanted_idx) & ", " & to_string(timeout, ns) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, AWAIT_COMPLETION);
    shared_vvc_cmd.gen_integer  := wanted_idx;
    send_command_to_vvc(vvc_target, timeout);
  end procedure;

  procedure await_completion(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant wanted_idx         : in natural;
    constant timeout            : in time          := 100 ns;
    constant msg                : in string        := ""
  ) is
  begin
    await_completion(vvc_target, vvc_instance_idx, NA, wanted_idx, timeout, msg);
  end procedure;


  procedure disable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  ) is
    constant proc_name : string := "disable_log_msg";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_upper(to_string(msg_id)) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, DISABLE_LOG_MSG);
    shared_vvc_cmd.msg_id  := msg_id;
    send_command_to_vvc(vvc_target);
  end procedure;

  procedure disable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  ) is
  begin
    disable_log_msg(vvc_target, vvc_instance_idx, NA, msg_id, msg);
  end procedure;

  procedure enable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  ) is
    constant proc_name : string := "enable_log_msg";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_upper(to_string(msg_id)) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, ENABLE_LOG_MSG);
    shared_vvc_cmd.msg_id  := msg_id;
    send_command_to_vvc(vvc_target);
  end procedure;

  procedure enable_log_msg(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg_id             : in t_msg_id;
    constant msg                : in string := ""
  ) is
  begin
    enable_log_msg(vvc_target, vvc_instance_idx, NA, msg_id, msg);
  end procedure;

  procedure flush_command_queue(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant msg                : in string := ""
  ) is
    constant proc_name : string := "flush_command_queue";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, FLUSH_COMMAND_QUEUE);
    send_command_to_vvc(vvc_target);
  end procedure;

  procedure flush_command_queue(
    signal   vvc_target     : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant msg            : in string := ""
  ) is
  begin
    flush_command_queue(vvc_target, vvc_instance_idx, NA, msg);
  end procedure;

  -- Requires that result is available (i.e. already executed in respective VVC)
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in    integer;
    constant vvc_channel        : in    t_channel;
    constant wanted_idx         : in    integer;
    variable result             : out   std_logic_vector;
    variable fetch_is_accepted  : out   boolean;
    variable value_is_new       : out   boolean;
    constant msg                : in    string    := "";
    constant alert_level        : in    t_alert_level := TB_ERROR;
    constant caller_name        : in    string    := "base_procedure"
  ) is
    constant proc_name : string := "fetch_result";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_string(wanted_idx) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, FETCH_RESULT);
    shared_vvc_cmd.gen_integer  := wanted_idx;
    send_command_to_vvc(vvc_target);
    -- Post process
    result  := shared_vvc_response.data(result'left downto 0);
    fetch_is_accepted   := shared_vvc_response.fetch_is_accepted;
    value_is_new  := shared_vvc_response.value_is_new;
    if caller_name = "base_procedure" then
      log(ID_UVVM_CMD_RESULT, proc_call & ": Legal=>" & to_string(shared_vvc_response.fetch_is_accepted) & ", New=>" & to_string(shared_vvc_response.value_is_new) & ", Result=>" & to_string(shared_vvc_response.data(result'range), HEX) & format_command_idx(shared_cmd_idx), C_SCOPE);    -- Get and ack the new command
    end if;
  end procedure;
  
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in    integer;
    constant vvc_channel        : in    t_channel;
    constant wanted_idx         : in    integer;
    variable result             : out   std_logic_vector;
    constant msg                : in    string    := "";
    constant alert_level        : in    t_alert_level := TB_ERROR
  ) is
    variable v_fetch_is_accepted : boolean;
    variable v_value_is_new      : boolean;
    constant proc_name           : string := "fetch_result";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_string(wanted_idx) & ")";
  begin
    fetch_result(vvc_target, vvc_instance_idx, vvc_channel, wanted_idx, result, v_fetch_is_accepted, v_value_is_new, msg, alert_level, proc_name & "_with_check_of_ok_and_new");
    if v_fetch_is_accepted and v_value_is_new then
      log(ID_UVVM_CMD_RESULT, proc_call & ": Legal=>" & to_string(v_fetch_is_accepted) & ", New=>" & to_string(v_value_is_new) & ", Result=>" & to_string(result, HEX) & format_command_idx(shared_cmd_idx), C_SCOPE);    -- Get and ack the new command
    elsif not v_fetch_is_accepted then  -- don't care about new if not OK
      alert(alert_level, "fetch_result(" & to_string(wanted_idx) &  "): " & msg & "." &
          " Failed. Trying to fetch result from not yet executed command or from command with no result stored.  " & format_command_idx(shared_cmd_idx), C_SCOPE);
    elsif not v_value_is_new then
      alert(TB_WARNING, "fetch_result(" & to_string(wanted_idx) & "): " & msg & "." &
          " Was already previously fetched. " & format_command_idx(shared_cmd_idx), C_SCOPE);
    end if;
  end procedure;

  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in    integer;
    constant wanted_idx         : in    integer;
    variable result             : out   std_logic_vector;
    variable fetch_is_accepted  : out   boolean;
    variable value_is_new       : out   boolean;
    constant msg                : in    string    := "";
    constant alert_level        : in    t_alert_level := TB_ERROR
  ) is
  begin
    fetch_result(vvc_target, vvc_instance_idx, NA, wanted_idx, result, fetch_is_accepted, value_is_new, msg, alert_level);
  end procedure;
  
  procedure fetch_result(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in    integer;
    constant wanted_idx         : in    integer;
    variable result             : out   std_logic_vector;
    constant msg                : in    string    := "";
    constant alert_level        : in    t_alert_level := TB_ERROR
  ) is
  begin
    fetch_result(vvc_target, vvc_instance_idx, NA, wanted_idx, result, msg, alert_level);
  end procedure;


  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant delay              : in natural;  -- in clock cycles
    constant msg                : in string        := ""
  ) is
    constant proc_name : string := "insert_delay";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_string(delay) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, QUEUED, INSERT_DELAY);
    shared_vvc_cmd.gen_integer  := delay;
    send_command_to_vvc(vvc_target);
  end procedure;

  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant delay              : in natural;  -- in clock cycles
    constant msg                : in string        := ""
  ) is
  begin
    insert_delay(vvc_target, vvc_instance_idx, NA, delay, msg);
  end procedure;


  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant delay              : in time;
    constant msg                : in string        := ""
  ) is
    constant proc_name : string := "insert_delay";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ", " & to_string(delay) & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, QUEUED, INSERT_DELAY_IN_TIME);
    shared_vvc_cmd.delay  := delay;
    send_command_to_vvc(vvc_target);
  end procedure;

  procedure insert_delay(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant delay              : in time;
    constant msg                : in string        := ""
  ) is
  begin
    insert_delay(vvc_target, vvc_instance_idx, NA, delay, msg);
  end procedure;


  procedure terminate_current_command(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel     := NA;
    constant msg                : in string        := ""
  ) is
    constant proc_name : string := "terminate_current_command";
    constant proc_call : string := proc_name & "(" & to_string(vvc_target, vvc_instance_idx, vvc_channel)  -- First part common for all
        & ")";
  begin
    set_general_target_and_command_fields(vvc_target, vvc_instance_idx, vvc_channel, proc_call, msg, IMMEDIATE, TERMINATE_CURRENT_COMMAND);
    send_command_to_vvc(vvc_target);
  end procedure;


  procedure terminate_all_commands(
    signal   vvc_target         : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel     := NA;
    constant msg                : in string        := ""
  ) is
  begin
    flush_command_queue(vvc_target, vvc_instance_idx, vvc_channel,msg);
    terminate_current_command(vvc_target, vvc_instance_idx, vvc_channel, msg);
  end procedure;

end package body td_vvc_framework_common_methods_pkg;

