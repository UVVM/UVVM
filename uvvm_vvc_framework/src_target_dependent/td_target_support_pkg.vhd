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

use work.vvc_cmd_pkg.all;


package td_target_support_pkg is

  type t_vvc_target_record is record  -- VVC dedicated to assure signature differences between equal common methods
    trigger              : std_logic;
    vvc_name             : string(1 to C_LOG_SCOPE_WIDTH-2);  -- as scope is vvc_name & ',' and number
    vvc_instance_idx     : integer;
    vvc_channel          : t_channel;
  end record;

  
  constant C_VVC_TARGET_RECORD_DEFAULT : t_vvc_target_record := (
    trigger            =>  '0',
    vvc_name           =>  (others => '?'),
    vvc_instance_idx   =>  -1,
    vvc_channel        =>  NA
    );   --


  -------------------------------------------
  -- to_string
  -------------------------------------------
  -- to_string method for VVC name, instance and channel
  -- - If channel is set to NA, it will not be included in the string
  function to_string(
    value         : t_vvc_target_record;
    vvc_instance  : integer   := -1;
    vvc_channel   : t_channel := NA
  )  return string;

    
  -------------------------------------------
  -- format_command_idx
  -------------------------------------------
  -- Returns an encapsulated command index as string
 impure function format_command_idx(
    command : t_vvc_cmd_record  -- VVC dedicated
  ) return string;

  
  -------------------------------------------
  -- send_command_to_vvc
  -------------------------------------------
  -- Sends command to VVC and waits for ACK or timeout
  -- - Logs with ID_UVVM_SEND_CMD when sending to VVC
  -- - Logs with ID_UVVM_CMD_ACK when ACK or timeout occurs
  procedure send_command_to_vvc(                  -- VVC dedicated shared command used  shared_vvc_cmd
    signal   vvc_target    : inout t_vvc_target_record;
    constant timeout       : in time  := 1 ps
  );

  
  -------------------------------------------
  -- set_vvc_target_defaults
  -------------------------------------------
  -- Returns a vvc target record with vvc_name and values specified in C_VVC_TARGET_RECORD_DEFAULT
  function set_vvc_target_defaults (
    constant  vvc_name  : in string
  ) return t_vvc_target_record;

  
  -------------------------------------------
  -- set_general_target_and_command_fields
  -------------------------------------------
  -- Sets target index and channel, and updates shared_vvc_cmd
  procedure set_general_target_and_command_fields (   -- VVC dedicated shared command used  shared_vvc_cmd
    signal target               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant proc_call          : in string;
    constant msg                : in string;
    constant command_type       : in t_immediate_or_queued;
    constant operation          : in t_operation
  );

  -------------------------------------------
  -- set_general_target_and_command_fields
  -------------------------------------------
  -- Sets target index and channel, and updates shared_vvc_cmd
  procedure set_general_target_and_command_fields (  -- VVC dedicated shared command used  shared_vvc_cmd
    signal target               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant proc_call          : in string;
    constant msg                : in string;
    constant command_type       : in t_immediate_or_queued;
    constant operation          : in t_operation
  );




end package td_target_support_pkg;



package body td_target_support_pkg is

  function to_string(
    value : t_vvc_target_record;
    vvc_instance : integer := -1;
    vvc_channel : t_channel:= NA
    )  return   string is
    variable v_instance : integer;
    variable v_channel  : t_channel;
  begin
    if vvc_instance = -1 then
      v_instance := value.vvc_instance_idx;
    else
      v_instance := vvc_instance;
    end if;
    if vvc_channel = NA then
      v_channel := value.vvc_channel;
    else
      v_channel := vvc_channel;
    end if;
    if v_channel = NA then
      return to_string(value.vvc_name) & "," & to_string(v_instance);
    else
      return to_string(value.vvc_name) & "," & to_string(v_instance) & "," & to_string(v_channel);
    end if;
  end;



  function set_vvc_target_defaults (
    constant  vvc_name  : in string
  ) return t_vvc_target_record is
    variable v_rec : t_vvc_target_record := C_VVC_TARGET_RECORD_DEFAULT;
  begin
    v_rec.vvc_name  := (others => NUL);
    v_rec.vvc_name(1 to vvc_name'length) := vvc_name;
    return v_rec;
  end function;

  procedure set_general_target_and_command_fields (
    signal target               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant vvc_channel        : in t_channel;
    constant proc_call          : in string;
    constant msg                : in string;
    constant command_type       : in t_immediate_or_queued;
    constant operation          : in t_operation
  )  is
  begin
    target.vvc_instance_idx <= vvc_instance_idx;
    target.vvc_channel      <= vvc_channel;
    shared_vvc_cmd.proc_call  := pad_string(proc_call, NUL, shared_vvc_cmd.proc_call'length);
    shared_vvc_cmd.msg  := (others => NUL); -- default empty
    shared_vvc_cmd.msg(1 to msg'length) := msg;
    shared_vvc_cmd.command_type := command_type;
    shared_vvc_cmd.operation := operation;
  end procedure;

  procedure set_general_target_and_command_fields (
    signal target               : inout t_vvc_target_record;
    constant vvc_instance_idx   : in integer;
    constant proc_call          : in string;
    constant msg                : in string;
    constant command_type       : in t_immediate_or_queued;
    constant operation          : in t_operation
  )  is
  begin
    set_general_target_and_command_fields(target, vvc_instance_idx, NA, proc_call, msg, command_type, operation);
  end procedure;

 impure function format_command_idx(
    command : t_vvc_cmd_record
  ) return string is
  begin
    return format_command_idx(command.cmd_idx);
  end;

  procedure send_command_to_vvc(
    signal   vvc_target    : inout t_vvc_target_record;
    constant timeout       : in time          := 1 ps
  ) is
    constant vvc_instance_idx  : integer := vvc_target.vvc_instance_idx;
    constant C_SCOPE         : string := C_TB_SCOPE_DEFAULT & "(uvvm)";
    constant C_CMD_INFO      : string := "uvvm cmd " & format_command_idx(shared_cmd_idx+1) & ": ";
  begin
    wait for 0 ns;  -- Waits one delta cycle
    check_value((shared_uvvm_state /= IDLE), TB_FAILURE, "UVVM will not work without initialize_uvvm instantiated as a concurrent procedure in the test harness", C_SCOPE, ID_NEVER);

    shared_cmd_idx := shared_cmd_idx + 1;
    
    shared_vvc_cmd.cmd_idx    := shared_cmd_idx;
    vvc_target.trigger    <= '1';

    if global_show_msg_for_uvvm_cmd then
      log(ID_UVVM_SEND_CMD, to_string(shared_vvc_cmd.proc_call) & ": " & to_string(shared_vvc_cmd.msg) & "."
          & format_command_idx(shared_cmd_idx), C_SCOPE);
    else
      log(ID_UVVM_SEND_CMD, to_string(shared_vvc_cmd.proc_call)
          & format_command_idx(shared_cmd_idx), C_SCOPE);
    end if;

    wait until global_vvc_ack = '1' for timeout;  -- Wait for executor
    if not (global_vvc_ack'event) then            -- Indicates timeout
      tb_error("Time out for " & C_CMD_INFO & " '" & to_string(shared_vvc_cmd.proc_call) & "' while waiting for acknowledge from VVC", C_SCOPE);
    else
      log(ID_UVVM_CMD_ACK, "ACK received.  " & format_command_idx(shared_cmd_idx), C_SCOPE);
    end if;

    -- clean up and prepare for next
    vvc_target.trigger <= 'L';
    wait for 0 ns;  -- wait for executor to stop driving global_vvc_ack
    wait for 0 ns;  -- Waits one delta cycle to allow VVC message progress
    wait for 0 ns;  -- Waits one delta cycle to allow VVC message progress
    shared_vvc_cmd  := C_VVC_CMD_DEFAULT;
  end procedure;

end package body td_target_support_pkg;


