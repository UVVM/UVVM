--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

use work.vvc_cmd_pkg.all;

package td_target_support_pkg is

  signal global_vvc_ack                         : std_logic; -- ACK on global triggers
  signal global_vvc_busy                        : std_logic := 'L'; -- ACK on global triggers
  shared variable protected_multicast_semaphore : t_protected_semaphore;
  shared variable protected_acknowledge_index   : t_protected_acknowledge_cmd_idx;

  type t_vvc_target_record_unresolved is record -- VVC dedicated to assure signature differences between equal common methods
    trigger          : std_logic;
    vvc_name         : string(1 to C_VVC_NAME_MAX_LENGTH); -- as scope is vvc_name & ',' and number
    vvc_instance_idx : integer;
    vvc_channel      : t_channel;
  end record;

  constant C_VVC_TARGET_RECORD_DEFAULT : t_vvc_target_record_unresolved := (
    trigger          => 'L',
    vvc_name         => (others => '?'),
    vvc_instance_idx => -1,
    vvc_channel      => NA
  );                                    --
  type t_vvc_target_record_drivers is array (natural range <>) of t_vvc_target_record_unresolved;

  function resolved(input_vector : t_vvc_target_record_drivers) return t_vvc_target_record_unresolved;

  subtype t_vvc_target_record is resolved t_vvc_target_record_unresolved;

  constant C_VVC_INDEX_NOT_FOUND : integer := -1;

  -------------------------------------------
  -- to_string
  -------------------------------------------
  -- to_string method for VVC name, instance and channel
  -- - If channel is set to NA, it will not be included in the string
  function to_string(
    value        : t_vvc_target_record;
    vvc_instance : integer   := -1;
    vvc_channel  : t_channel := NA
  ) return string;

  -------------------------------------------
  -- format_command_idx
  -------------------------------------------
  -- Returns an encapsulated command index as string
  impure function format_command_idx(
    command : t_vvc_cmd_record          -- VVC dedicated
  ) return string;

  -------------------------------------------
  -- send_command_to_vvc
  -------------------------------------------
  -- Sends command to VVC and waits for ACK or timeout
  -- - Logs with ID_UVVM_SEND_CMD when sending to VVC
  -- - Logs with ID_UVVM_CMD_ACK when ACK or timeout occurs
  procedure send_command_to_vvc(        -- VVC dedicated shared command used  shared_vvc_cmd
    signal   vvc_target   : inout t_vvc_target_record;
    constant timeout      : in time           := std.env.resolution_limit;
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  );

  -------------------------------------------
  -- set_vvc_target_defaults
  -------------------------------------------
  -- Returns a vvc target record with vvc_name and values specified in C_VVC_TARGET_RECORD_DEFAULT
  function set_vvc_target_defaults(
    constant vvc_name : in string;
    constant scope    : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) return t_vvc_target_record;

  -------------------------------------------
  -- set_general_target_and_command_fields
  -------------------------------------------
  -- Sets target index and channel, and updates shared_vvc_cmd
  procedure set_general_target_and_command_fields( -- VVC dedicated shared command used  shared_vvc_cmd
    signal   target           : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant proc_call        : in string;
    constant msg              : in string;
    constant command_type     : in t_immediate_or_queued;
    constant operation        : in t_operation
  );

  -------------------------------------------
  -- set_general_target_and_command_fields
  -------------------------------------------
  -- Sets target index and channel, and updates shared_vvc_cmd
  procedure set_general_target_and_command_fields( -- VVC dedicated shared command used  shared_vvc_cmd
    signal   target           : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant vvc_channel      : in t_channel;
    constant proc_call        : in string;
    constant msg              : in string;
    constant command_type     : in t_immediate_or_queued;
    constant operation        : in t_operation
  );
  -------------------------------------------
  -- acknowledge_cmd
  -------------------------------------------
  -- Drives global_vvc_ack signal (to '1') for 1 delta cycle, then sets it back to 'Z'.
  procedure acknowledge_cmd(
    signal   vvc_ack     : inout std_logic;
    constant command_idx : in natural
  );

  --
  -- Helper procedure for getting the VVC index in the VVC activity register
  -- and the number of instances of this VVC.
  --
  procedure get_vvc_index_in_activity_register(
    signal   vvc_target                   : in t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant vvc_channel                  : in t_channel;
    variable vvc_idx_in_activity_register : inout t_integer_array(0 to C_MAX_TB_VVC_NUM);
    variable num_vvc_instances            : inout natural range 0 to C_MAX_TB_VVC_NUM
  );

end package td_target_support_pkg;

package body td_target_support_pkg is

  function resolved(input_vector : t_vvc_target_record_drivers) return t_vvc_target_record_unresolved is
    -- if none of the drives want to drive the target return value of first driver (which we need to drive at least the target name)
    constant C_LINE_LENGTH_MAX : natural                        := 100; -- VVC idx list string length
    variable v_result          : t_vvc_target_record_unresolved := input_vector(input_vector'low);
    variable v_cnt             : integer                        := 0;
    variable v_instance_string : string(1 to C_LINE_LENGTH_MAX) := (others => NUL);
    variable v_line            : line;
    variable v_width           : integer                        := 0;
  begin
    if input_vector'length = 1 then
      return input_vector(input_vector'low);
    else
      for i in input_vector'range loop
        -- The VVC is used if instance_idx is not -1 (which is the default value)
        if input_vector(i).vvc_instance_idx /= -1 then
          -- count the number of sequencer trying to access the VVC
          v_cnt    := v_cnt + 1;
          v_result := input_vector(i);
          -- generating string with all instance_idx for report in case of failure
          write(v_line, string'(" "));
          write(v_line, input_vector(i).vvc_instance_idx);

          -- Ensure there is room for the last item and dots
          v_width := v_line'length;
          if v_width > (C_LINE_LENGTH_MAX - 15) then
            write(v_line, string'("..."));
            exit;
          end if;
        end if;
      end loop;

      if v_width > 0 then
        v_instance_string(1 to v_width) := v_line.all;
      end if;
      deallocate(v_line);
      check_value(v_cnt < 2, TB_FAILURE, "Arbitration mechanism failed. Check VVC " & to_string(v_result.vvc_name) & " implementation and semaphore handling. Crashing instances with numbers " & v_instance_string(1 to v_width), "Multiple scopes", ID_NEVER);
      return v_result;
    end if;
  end resolved;

  function to_string(
    value        : t_vvc_target_record;
    vvc_instance : integer   := -1;
    vvc_channel  : t_channel := NA
  ) return string is
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
      if vvc_instance = -2 then
        return to_string(value.vvc_name) & ",ALL_INSTANCES";
      else
        return to_string(value.vvc_name) & "," & to_string(v_instance);
      end if;
    else
      if vvc_instance = -2 then
        return to_string(value.vvc_name) & ",ALL_INSTANCES" & "," & to_upper(to_string(v_channel));
      else
        return to_string(value.vvc_name) & "," & to_string(v_instance) & "," & to_upper(to_string(v_channel));
      end if;
    end if;
  end;

  function set_vvc_target_defaults(
    constant vvc_name : in string;
    constant scope    : in string := C_VVC_CMD_SCOPE_DEFAULT
  ) return t_vvc_target_record is
    variable v_rec : t_vvc_target_record := C_VVC_TARGET_RECORD_DEFAULT;
  begin
    if vvc_name'length > C_MAX_VVC_NAME_LENGTH then
      alert(TB_FAILURE, "vvc_name is too long. Shorten name or set C_MAX_VVC_NAME_LENGTH in adaptation_pkg to desired length.", scope);
    end if;
    v_rec.vvc_name                       := (others => NUL);
    v_rec.vvc_name(1 to vvc_name'length) := vvc_name;
    return v_rec;
  end function;

  procedure set_general_target_and_command_fields(
    signal   target           : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant vvc_channel      : in t_channel;
    constant proc_call        : in string;
    constant msg              : in string;
    constant command_type     : in t_immediate_or_queued;
    constant operation        : in t_operation
  ) is
  begin
    -- As shared_vvc_cmd is a shared variable we have to get exclusive access to it. Therefor we have to lock the protected_semaphore here.
    -- It is unlocked again in await_cmd_from_sequencer after it is copied localy or in send_command_to_vvc if no VVC acknowledges the command.
    -- It is guaranteed that no time delay occurs, only delta cycle delay.
    await_semaphore_in_delta_cycles(protected_semaphore);
    shared_vvc_cmd                      := C_VVC_CMD_DEFAULT;
    target.vvc_instance_idx             <= vvc_instance_idx;
    target.vvc_channel                  <= vvc_channel;
    shared_vvc_cmd.proc_call            := pad_string(proc_call, NUL, shared_vvc_cmd.proc_call'length);
    shared_vvc_cmd.msg                  := (others => NUL); -- default empty
    shared_vvc_cmd.msg(1 to msg'length) := msg;
    shared_vvc_cmd.command_type         := command_type;
    shared_vvc_cmd.operation            := operation;

    -- Wait a delta cycle for target signal values update
    wait for 0 ns;
  end procedure;

  procedure set_general_target_and_command_fields(
    signal   target           : inout t_vvc_target_record;
    constant vvc_instance_idx : in integer;
    constant proc_call        : in string;
    constant msg              : in string;
    constant command_type     : in t_immediate_or_queued;
    constant operation        : in t_operation
  ) is
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
    signal   vvc_target   : inout t_vvc_target_record;
    constant timeout      : in time           := std.env.resolution_limit;
    constant scope        : in string         := C_VVC_CMD_SCOPE_DEFAULT;
    constant msg_id_panel : in t_msg_id_panel := shared_msg_id_panel
  ) is
    constant C_CMD_INFO                     : string                                 := "uvvm cmd " & format_command_idx(shared_cmd_idx + 1) & ": ";
    variable v_ack_cmd_idx                  : integer                                := -1;
    variable v_start_time                   : time;
    variable v_local_vvc_cmd                : t_vvc_cmd_record;
    variable v_local_cmd_idx                : integer;
    variable v_was_multicast                : boolean                                := false;
    variable v_vvc_idx_in_activity_register : t_integer_array(0 to C_MAX_TB_VVC_NUM) := (others => -1);
    variable v_num_vvc_instances            : natural range 0 to C_MAX_TB_VVC_NUM    := 0;

    variable v_vvc_instance_idx : integer   := vvc_target.vvc_instance_idx;
    variable v_vvc_channel      : t_channel := vvc_target.vvc_channel;

  begin

    check_value((shared_uvvm_state /= IDLE), TB_FAILURE, "UVVM will not work without uvvm_vvc_framework.ti_uvvm_engine instantiated in the test harness", scope, ID_NEVER, msg_id_panel);

    -- Default to ALL_INSTANCES and/or ALL_CHANNELS if these are not set in vvc_target
    if v_vvc_instance_idx = -1 then
      v_vvc_instance_idx := ALL_INSTANCES;
    end if;
    if v_vvc_channel = NA then
      v_vvc_channel := ALL_CHANNELS;
    end if;
    -- Get the corresponding index from the vvc activity register
    get_vvc_index_in_activity_register(vvc_target,
                                       v_vvc_instance_idx,
                                       v_vvc_channel,
                                       v_vvc_idx_in_activity_register,
                                       v_num_vvc_instances);

    -- increment shared_cmd_inx. It is protected by the protected_semaphore and only one sequencer can access the variable at a time.
    shared_cmd_idx := shared_cmd_idx + 1;

    shared_vvc_cmd.cmd_idx := shared_cmd_idx;

    if global_show_msg_for_uvvm_cmd then
      log(ID_UVVM_SEND_CMD, to_string(shared_vvc_cmd.proc_call) & ": " & add_msg_delimiter(to_string(shared_vvc_cmd.msg)) & "." & format_command_idx(shared_cmd_idx), scope, msg_id_panel);
    else
      log(ID_UVVM_SEND_CMD, to_string(shared_vvc_cmd.proc_call) & format_command_idx(shared_cmd_idx), scope, msg_id_panel);
    end if;
    wait for 0 ns;
    if (vvc_target.vvc_instance_idx = ALL_INSTANCES) then
      await_semaphore_in_delta_cycles(protected_multicast_semaphore);
      if global_vvc_busy /= 'L' then
        wait until global_vvc_busy = 'L';
      end if;
      v_was_multicast := true;
    end if;
    v_start_time    := now;
    -- semaphore "protected_semaphore" gets released after "wait for 0 ns" in await_cmd_from_sequencer
    -- Before the semaphore is released copy shared_vvc_cmd to local variable, so that the shared_vvc_cmd can be used by other VVCs.
    v_local_vvc_cmd := shared_vvc_cmd;
    -- copy the shared_cmd_idx as it can be changed during this function after the semaphore is released
    v_local_cmd_idx := shared_cmd_idx;

    -- trigger the target -> vvc continues in await_cmd_from_sequencer
    vvc_target.trigger <= '1';
    wait for 0 ns;
    -- the default value of vvc_target drives trigger to 'L' again
    vvc_target         <= set_vvc_target_defaults(vvc_target.vvc_name, scope);

    while v_ack_cmd_idx /= v_local_cmd_idx loop
      wait until global_vvc_ack = '1' for ((v_start_time + timeout) - now);
      v_ack_cmd_idx := protected_acknowledge_index.get_index;

      if not (global_vvc_ack'event) then
        tb_error("Time out for " & C_CMD_INFO & " '" & to_string(v_local_vvc_cmd.proc_call) & "' while waiting for acknowledge from VVC", scope);
        -- lock the sequencer for 5 delta cycles as it can take so long to get every VVC in normal mode again
        wait for 0 ns;
        wait for 0 ns;
        wait for 0 ns;
        wait for 0 ns;
        wait for 0 ns;
        -- release the semaphore as no VVC can do this
        release_semaphore(protected_semaphore);
        return;
      end if;
    end loop;

    if (v_was_multicast = true) then
      release_semaphore(protected_multicast_semaphore);
    end if;

    -- VVCs registered in the VVC activity register release semaphore now.
    if v_num_vvc_instances > 0 then
      release_semaphore(protected_semaphore);
    end if;

    -- VVCs registered in the VVC activity register release semaphore now.
    if v_num_vvc_instances > 0 then
      release_semaphore(protected_semaphore);
    end if;

    log(ID_UVVM_CMD_ACK, "ACK received.  " & format_command_idx(v_local_cmd_idx), scope, msg_id_panel);

    -- clean up and prepare for next
    wait for 0 ns;                      -- wait for executor to stop driving global_vvc_ack
  end procedure;

  procedure acknowledge_cmd(
    signal   vvc_ack     : inout std_logic;
    constant command_idx : in natural
  ) is
  begin
    -- Drive ack signal for 1 delta cycle only one command index can be acknowledged simultaneously.
    while (protected_acknowledge_index.set_index(command_idx) = false) loop
      -- if it can't set the acknowledge_index wait for one delta cycle and try again
      wait for 0 ns;
    end loop;
    vvc_ack <= '1';
    wait until vvc_ack = '1';
    vvc_ack <= 'Z';
    wait for 0 ns;
    protected_acknowledge_index.release_index;
  end procedure;

  --
  -- Helper procedure for getting the VVC index in the VVC activity register
  -- and the number of instances of this VVC.
  --
  procedure get_vvc_index_in_activity_register(
    signal   vvc_target                   : in t_vvc_target_record;
    constant vvc_instance_idx             : in integer;
    constant vvc_channel                  : in t_channel;
    variable vvc_idx_in_activity_register : inout t_integer_array(0 to C_MAX_TB_VVC_NUM);
    variable num_vvc_instances            : inout natural range 0 to C_MAX_TB_VVC_NUM
  ) is
  begin
    if vvc_instance_idx = ALL_INSTANCES or vvc_channel = ALL_CHANNELS then

      -- Check how many instances or channels of this VVC are registered in the vvc activity register
      num_vvc_instances := shared_vvc_activity_register.priv_get_num_registered_vvc_matches(vvc_target.vvc_name,
                                                                                            vvc_instance_idx, vvc_channel);
      -- Get the index for every instance or channel of this VVC
      for j in 0 to num_vvc_instances - 1 loop
        vvc_idx_in_activity_register(j) := shared_vvc_activity_register.priv_get_vvc_idx(j, vvc_target.vvc_name,
                                                                                         vvc_instance_idx, vvc_channel);
      end loop;

    else
      -- Get the index for a specific VVC
      vvc_idx_in_activity_register(0) := shared_vvc_activity_register.priv_get_vvc_idx(vvc_target.vvc_name,
                                                                                       vvc_instance_idx, vvc_channel);
      num_vvc_instances               := 0 when vvc_idx_in_activity_register(0) = C_VVC_INDEX_NOT_FOUND else 1;

    end if;
  end procedure;

end package body td_target_support_pkg;
