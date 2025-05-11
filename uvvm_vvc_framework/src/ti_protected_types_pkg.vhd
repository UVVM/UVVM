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
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package ti_protected_types_pkg is

  ------------------------------------------------------------
  -- Protected type to register and report VVC activity
  ------------------------------------------------------------
  type t_vvc_activity is protected

    -- Add a new VVC to the activity register and return its index
    impure function priv_register_vvc(
      constant name          : in string;
      constant instance      : in natural;
      constant channel       : in t_channel := NA;
      constant num_executors : in positive  := 1
    ) return integer;

    -- Update a VVC's state
    procedure priv_report_vvc_activity(
      constant vvc_idx                : in natural;
      constant executor_id            : in natural;
      constant activity               : in t_activity;
      constant last_cmd_idx_executed  : in integer;
      constant cmd_completed          : in boolean
    );

    -- DEPRECATE: will be removed in v3
    procedure priv_report_vvc_activity(
      constant vvc_idx               : in natural;
      constant activity              : in t_activity;
      constant last_cmd_idx_executed : in integer
    );

    -- Add a cmd_idx to the pending command index list
    procedure priv_add_pending_cmd_idx(
      constant vvc_idx         : in natural;
      constant pending_cmd_idx : in integer
    );

    -- Remove a cmd_idx from the pending command index list
    procedure priv_remove_pending_cmd_idx(
      constant vvc_idx         : in natural;
      constant pending_cmd_idx : in integer
    );

    -- Print the list of registered VVCs
    procedure priv_list_registered_vvc(
      constant msg : in string
    );

    -- Get a VVC's index in the activity register
    impure function priv_get_vvc_idx(
      constant name     : in string;
      constant instance : in integer;
      constant channel  : in t_channel := NA
    ) return integer;

    -- Get a VVC's index in the activity register after skipping a number of matches,
    -- e.g. when using ALL_INSTANCES or ALL_CHANNELS
    impure function priv_get_vvc_idx(
      constant skip_num_of_matches : in natural;
      constant name                : in string;
      constant instance            : in integer;
      constant channel             : in t_channel := NA
    ) return integer;

    -- Get a VVC's name
    impure function priv_get_vvc_name(
      constant vvc_idx : in natural
    ) return string;

    -- Get a VVC's instance
    impure function priv_get_vvc_instance(
      constant vvc_idx : in natural
    ) return integer;

    -- Get a VVC's channel
    impure function priv_get_vvc_channel(
      constant vvc_idx : in natural
    ) return t_channel;

    -- Get a VVC's activity
    impure function priv_get_vvc_activity(
      constant vvc_idx : in natural
    ) return t_activity;

    -- Check if the cmd_idx has been executed
    impure function priv_is_cmd_idx_executed(
      constant vvc_idx : in natural;
      constant cmd_idx : in integer
    ) return boolean;

    -- Get a VVC's name, instance and channel
    impure function priv_get_vvc_info(
      constant vvc_idx : in natural
    ) return string;

    -- Get the total number of registered VVCs matching the name, instance
    -- and channel, e.g. (UART_VVC, 1, ALL_CHANNELS) returns 2 (RX & TX)
    impure function priv_get_num_registered_vvc_matches(
      constant name     : in string;
      constant instance : in integer;
      constant channel  : in t_channel := NA
    ) return natural;

    -- Get the total number of registered VVCs
    impure function priv_get_num_registered_vvcs(
      constant void : t_void
    ) return natural;

    -- Check if all registered VVCs are INACTIVE
    impure function priv_are_all_vvc_inactive(
      constant void : t_void
    ) return boolean;

  end protected;

  ------------------------------------------------------------
  -- Protected type to gather VVC's info in a list
  ------------------------------------------------------------
  type t_prot_vvc_list is protected

    procedure add(
      constant name         : in string;
      constant instance     : in integer;
      constant channel      : in t_channel := NA;
      constant scope        : in string;
      constant msg_id_panel : in t_msg_id_panel
    );

    procedure add(
      constant name         : in string;
      constant instance     : in integer;
      constant scope        : in string;
      constant msg_id_panel : in t_msg_id_panel
    );

    procedure clear_list(
      constant void : in t_void
    );

    function priv_instance_to_string(
      constant instance : in integer
    ) return string;

    impure function priv_get_name(
      constant vvc_idx : in natural
    ) return string;

    impure function priv_get_instance(
      constant vvc_idx : in natural
    ) return integer;

    impure function priv_get_channel(
      constant vvc_idx : in natural
    ) return t_channel;

    impure function priv_get_vvc_info(
      constant vvc_idx : in natural
    ) return string;

    impure function priv_get_vvc_list(idx : natural := natural'low) return string;

    impure function priv_get_num_vvc_in_list return natural;

  end protected;

  alias t_vvc_info_list is t_prot_vvc_list;

end package ti_protected_types_pkg;

--=============================================================================
--=============================================================================

package body ti_protected_types_pkg is

  ------------------------------------------------------------
  -- Protected type to register and report VVC activity
  ------------------------------------------------------------
  type t_vvc_activity is protected body

    type t_activity_array is array (natural range <>) of t_activity;

    type t_activity_array_ptr is access t_activity_array;

    type t_cmd_idx_list_ptr is access integer_vector;

    type t_vvc_id is record
      name     : string(1 to C_MAX_VVC_NAME_LENGTH);
      instance : natural;
      channel  : t_channel;
    end record;

    type t_vvc_state is record
      activity              : t_activity_array_ptr; -- Each executor inside a VVC has its own activity status.
      last_cmd_idx_executed : integer;              -- Last (highest) command index executed inside a VVC. Not exactly true when using out-of-order commands.
      pending_cmd_idx_list  : t_cmd_idx_list_ptr;   -- Pending command indexes running in the VVC executors. Not used in VVCs with a single executor.
    end record;

    type t_vvc_item is record
      vvc_id    : t_vvc_id;
      vvc_state : t_vvc_state;
    end record;

    type t_registered_vvc_array is array (natural range <>) of t_vvc_item;

    -- Array holding all registered VVCs
    variable priv_registered_vvc          : t_registered_vvc_array(0 to C_MAX_TB_VVC_NUM);
    -- Counter for the number of VVCs that has registered
    variable priv_last_registered_vvc_idx : integer                                       := -1;

    impure function priv_register_vvc(
      constant name          : in string;
      constant instance      : in natural;
      constant channel       : in t_channel := NA;
      constant num_executors : in positive  := 1
    ) return integer is
    begin
      if priv_last_registered_vvc_idx >= C_MAX_TB_VVC_NUM then
        alert(TB_ERROR, "Number of registered VVCs exceed C_MAX_TB_VVC_NUM.\n" & "Increase C_MAX_TB_VVC_NUM in adaptations package.");
      end if;

      -- Update register only if a duplicated VVC ID is not found in the registered VVC array.
      if priv_get_vvc_idx(name, instance, channel) = -1 then
        -- Set registered VVC index
        priv_last_registered_vvc_idx                                                          := priv_last_registered_vvc_idx + 1;

        -- Update register
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.name                         := (others => NUL);
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.name(1 to name'length)       := to_upper(name);
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.instance                     := instance;
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.channel                      := channel;
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.activity                  := new t_activity_array(0 to num_executors - 1);
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.activity.all              := (0 to num_executors - 1 => INACTIVE);
        priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.last_cmd_idx_executed     := -1;
        if num_executors > 1 then -- Only VVCs with multiple executors use this list
          priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.pending_cmd_idx_list    := new integer_vector(0 to 0); -- Start with one element, it expands automatically
          priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.pending_cmd_idx_list(0) := 0;
        end if;
      -- Alert if a duplicated VVC ID is found in the registered VVC array
      else
        if priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.channel = NA then
          alert(TB_ERROR, "Instance " & to_string(instance) & " of " & to_upper(name) & " is already in use. Choose a different instance number.");
        else
          alert(TB_ERROR, "Instance " & to_string(instance) & " of " & to_upper(name) & ", Channel " & to_upper(to_string(channel)) & " is already in use. Choose a different instance number.");
        end if;
      end if;

      -- Return index
      return priv_last_registered_vvc_idx;
    end function;

    procedure priv_report_vvc_activity(
      constant vvc_idx                : in natural;
      constant executor_id            : in natural;
      constant activity               : in t_activity;
      constant last_cmd_idx_executed  : in integer;
      constant cmd_completed          : in boolean
    ) is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_report_vvc_activity() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      check_value_in_range(executor_id, 0, priv_registered_vvc(vvc_idx).vvc_state.activity'length - 1, TB_ERROR,
                           "priv_report_vvc_activity() => executor_id invalid range: " & to_string(executor_id) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      -- Update VVC status
      priv_registered_vvc(vvc_idx).vvc_state.activity(executor_id)   := activity;
      -- Since cmd_idx is always incrementing, the highest index will be the last executed
      -- Note that in case of VVCs with multiple executors, any pending commands with a lower index will be identified in the pending_cmd_idx_list
      if last_cmd_idx_executed > priv_registered_vvc(vvc_idx).vvc_state.last_cmd_idx_executed then
        priv_registered_vvc(vvc_idx).vvc_state.last_cmd_idx_executed := last_cmd_idx_executed;
      end if;
      -- In VVCs with multiple executors, remove the last_cmd_idx_executed from the pending_cmd_idx_list when it is completed
      if executor_id > 0 and last_cmd_idx_executed > 0 and cmd_completed then
        priv_remove_pending_cmd_idx(vvc_idx, last_cmd_idx_executed);
      end if;
    end procedure;

    -- DEPRECATE: will be removed in v3
    procedure priv_report_vvc_activity(
      constant vvc_idx               : in natural;
      constant activity              : in t_activity;
      constant last_cmd_idx_executed : in integer
    ) is
    begin
      priv_report_vvc_activity(vvc_idx, 0, activity, last_cmd_idx_executed, false);
    end procedure;

    procedure priv_add_pending_cmd_idx(
      constant vvc_idx         : in natural;
      constant pending_cmd_idx : in integer
    ) is
      variable v_copy_ptr : t_cmd_idx_list_ptr;
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_add_pending_cmd_idx() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);

      -- Add the pending_cmd_idx to an empty element in the list
      for i in priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list'range loop
        if priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(i) = 0 then
          priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(i) := pending_cmd_idx;
          return;
        end if;
      end loop;

      -- Expand the list if no more empty elements in the list and add the pending_cmd_idx
      v_copy_ptr := priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list;
      priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list                             := new integer_vector(0 to v_copy_ptr'length);
      priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(0 to v_copy_ptr'length - 1) := v_copy_ptr.all;
      priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(v_copy_ptr'length)          := pending_cmd_idx;
      DEALLOCATE(v_copy_ptr);
    end procedure;

    procedure priv_remove_pending_cmd_idx(
      constant vvc_idx         : in natural;
      constant pending_cmd_idx : in integer
    ) is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_remove_pending_cmd_idx() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);

      -- Remove the pending_cmd_idx from the list
      for i in priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list'range loop
        if priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(i) = pending_cmd_idx then
          priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(i) := 0;
          return;
        end if;
      end loop;
      alert(TB_ERROR, "priv_remove_pending_cmd_idx() => Trying to remove pending_cmd_idx, but not found in the pending_cmd_idx_list.\n" &
            "Make sure priv_add_pending_cmd_idx() is used in the VVC.", C_TB_SCOPE_DEFAULT);
    end procedure;

    procedure priv_list_registered_vvc(
      constant msg : in string
    ) is
      variable v_vvc : t_vvc_id;
    begin
      log(ID_VVC_ACTIVITY, "VVC activity registered VVCs: " & msg);

      for idx in 0 to priv_last_registered_vvc_idx loop
        v_vvc := priv_registered_vvc(idx).vvc_id;
        if v_vvc.channel = NA then
          log(ID_VVC_ACTIVITY, to_string(idx + 1) & ": " & v_vvc.name & " instance=" & to_string(v_vvc.instance));
        else
          log(ID_VVC_ACTIVITY, to_string(idx + 1) & ": " & v_vvc.name & " instance=" & to_string(v_vvc.instance) & ", channel=" & to_string(v_vvc.channel));
        end if;
      end loop;
    end procedure;

    impure function priv_get_vvc_idx(
      constant name     : in string;
      constant instance : in integer;
      constant channel  : in t_channel := NA
    ) return integer is
    begin
      for idx in 0 to priv_last_registered_vvc_idx loop
        if priv_registered_vvc(idx).vvc_id.name(1 to name'length) = to_upper(name) and priv_registered_vvc(idx).vvc_id.instance = instance and priv_registered_vvc(idx).vvc_id.channel = channel then
          return idx;                   -- vvc was found
        end if;
      end loop;

      return -1;                        -- not found
    end function;

    impure function priv_get_vvc_idx(
      constant skip_num_of_matches : in natural;
      constant name                : in string;
      constant instance            : in integer;
      constant channel             : in t_channel := NA
    ) return integer is
      variable v_match_num : natural := 0;
    begin
      for idx in 0 to priv_last_registered_vvc_idx loop
        if priv_registered_vvc(idx).vvc_id.name(1 to name'length) = to_upper(name) and (priv_registered_vvc(idx).vvc_id.instance = instance or instance = ALL_INSTANCES) and (priv_registered_vvc(idx).vvc_id.channel = channel or channel = ALL_CHANNELS) then
          if v_match_num < skip_num_of_matches then
            v_match_num := v_match_num + 1;
          else
            return idx;                 -- vvc was found
          end if;
        end if;
      end loop;

      return -1;                        -- not found
    end function;

    impure function priv_get_vvc_name(
      constant vvc_idx : in natural
    ) return string is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_get_vvc_name() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_registered_vvc(vvc_idx).vvc_id.name;
    end function;

    impure function priv_get_vvc_instance(
      constant vvc_idx : in natural
    ) return integer is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_get_vvc_instance() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_registered_vvc(vvc_idx).vvc_id.instance;
    end function;

    impure function priv_get_vvc_channel(
      constant vvc_idx : in natural
    ) return t_channel is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_get_vvc_channel() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_registered_vvc(vvc_idx).vvc_id.channel;
    end function;

    impure function priv_get_vvc_activity(
      constant vvc_idx : in natural
    ) return t_activity is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_get_vvc_activity() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      for i in priv_registered_vvc(vvc_idx).vvc_state.activity'range loop
        if priv_registered_vvc(vvc_idx).vvc_state.activity(i) = ACTIVE then
          return ACTIVE;
        end if;
      end loop;
      return INACTIVE;
    end function;

    impure function priv_is_cmd_idx_executed(
      constant vvc_idx : in natural;
      constant cmd_idx : in integer
    ) return boolean is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_get_vvc_last_cmd_idx_executed() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      -- In VVCs with a single executor, when last_cmd_idx_executed is less
      -- than the cmd_idx, it means that the command hasn't been executed
      if priv_registered_vvc(vvc_idx).vvc_state.last_cmd_idx_executed < cmd_idx then
        return false;
      end if;
      -- In VVCs with multiple executors, a command with cmd_idx could be still running in
      -- one executor while a different executor has completed another command and updated
      -- last_cmd_idx_executed with a higher value.
      -- To ensure that the command with cmd_idx has indeed completed, we check pending_cmd_idx_list
      if priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list /= null then
        for i in priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list'range loop
          if cmd_idx = priv_registered_vvc(vvc_idx).vvc_state.pending_cmd_idx_list(i) then
            return false;
          end if;
        end loop;
      end if;

      return true;
    end function;

    impure function priv_get_vvc_info(
      constant vvc_idx : in natural
    ) return string is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_registered_vvc_idx, TB_ERROR,
                           "priv_get_vvc_info() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      if priv_registered_vvc(vvc_idx).vvc_id.channel = NA then
        return priv_registered_vvc(vvc_idx).vvc_id.name & "," & to_string(priv_registered_vvc(vvc_idx).vvc_id.instance);
      else
        return priv_registered_vvc(vvc_idx).vvc_id.name & "," & to_string(priv_registered_vvc(vvc_idx).vvc_id.instance) & "," & to_upper(to_string(priv_registered_vvc(vvc_idx).vvc_id.channel));
      end if;
    end function;

    impure function priv_get_num_registered_vvc_matches(
      constant name     : in string;
      constant instance : in integer;
      constant channel  : in t_channel := NA
    ) return natural is
      variable v_num_instances : natural := 0;
    begin
      for idx in 0 to priv_last_registered_vvc_idx loop
        if priv_registered_vvc(idx).vvc_id.name = to_upper(name) and (priv_registered_vvc(idx).vvc_id.instance = instance or instance = ALL_INSTANCES) and (priv_registered_vvc(idx).vvc_id.channel = channel or channel = ALL_CHANNELS) then
          v_num_instances := v_num_instances + 1;
        end if;
      end loop;

      return v_num_instances;
    end function;

    impure function priv_get_num_registered_vvcs(
      constant void : t_void
    ) return natural is
    begin
      return priv_last_registered_vvc_idx + 1;
    end function;

    impure function priv_are_all_vvc_inactive(
      constant void : t_void
    ) return boolean is
    begin
      check_value(priv_last_registered_vvc_idx /= -1, TB_ERROR, "No VVCs in activity register", C_TB_SCOPE_DEFAULT, ID_NEVER);

      for idx in 0 to priv_last_registered_vvc_idx loop
        for sub_idx in priv_registered_vvc(idx).vvc_state.activity'range loop
          if priv_registered_vvc(idx).vvc_state.activity(sub_idx) = ACTIVE then
            return false;
          end if;
        end loop;
      end loop;
      return true;
    end function;

  end protected body t_vvc_activity;

  ------------------------------------------------------------
  -- Protected type to gather VVC's info in a list
  ------------------------------------------------------------
  type t_prot_vvc_list is protected body

    type t_vvc_item is record
      name     : string(1 to C_MAX_VVC_NAME_LENGTH);
      instance : integer;
      channel  : t_channel;
    end record;
    constant C_VVC_ITEM_DEFAULT : t_vvc_item := (
      name     => (others => NUL),
      instance => 0,
      channel  => NA
    );
    type t_vvc_item_array is array (natural range <>) of t_vvc_item;

    -- Array holding the VVCs info
    variable priv_vvc_list           : t_vvc_item_array(0 to C_MAX_TB_VVC_NUM) := (others => C_VVC_ITEM_DEFAULT);
    -- Counter for the number of VVCs in the list
    variable priv_last_added_vvc_idx : integer                                 := -1;

    procedure add(
      constant name         : in string;
      constant instance     : in integer;
      constant channel      : in t_channel := NA;
      constant scope        : in string;
      constant msg_id_panel : in t_msg_id_panel
    ) is
      variable v_duplicate : boolean := false;
    begin
      if priv_last_added_vvc_idx >= C_MAX_TB_VVC_NUM then
        alert(TB_ERROR, "Number of VVCs in the list exceed C_MAX_TB_VVC_NUM.\n" & "Increase C_MAX_TB_VVC_NUM in adaptations package.", scope);
      end if;

      -- Check if VVC was previously added
      for idx in 0 to priv_last_added_vvc_idx loop
        if priv_vvc_list(idx).name(1 to name'length) = to_upper(name) and priv_vvc_list(idx).instance = instance and priv_vvc_list(idx).channel = channel then
          v_duplicate := true;
          exit;
        end if;
      end loop;

      if v_duplicate then
        alert(TB_WARNING, to_upper(name) & "," & priv_instance_to_string(instance) & "," & to_string(channel) & " was previously added to the list.");
      else
        -- Set VVC index
        priv_last_added_vvc_idx                                       := priv_last_added_vvc_idx + 1;
        -- Update register
        priv_vvc_list(priv_last_added_vvc_idx).name(1 to name'length) := to_upper(name);
        priv_vvc_list(priv_last_added_vvc_idx).instance               := instance;
        priv_vvc_list(priv_last_added_vvc_idx).channel                := channel;

        if channel = NA then
          log(ID_AWAIT_COMPLETION_LIST, "Adding: " & to_upper(name) & "," & priv_instance_to_string(instance) & " to the list.", scope, msg_id_panel);
        else
          log(ID_AWAIT_COMPLETION_LIST, "Adding: " & to_upper(name) & "," & priv_instance_to_string(instance) & "," & to_string(channel) & " to the list.", scope, msg_id_panel);
        end if;
      end if;
    end procedure;

    procedure add(
      constant name         : in string;
      constant instance     : in integer;
      constant scope        : in string;
      constant msg_id_panel : in t_msg_id_panel
    ) is
    begin
      add(name, instance, NA, scope, msg_id_panel);
    end procedure;

    procedure clear_list(
      constant void : in t_void
    ) is
    begin
      priv_vvc_list := (others => C_VVC_ITEM_DEFAULT);
      priv_last_added_vvc_idx := -1;
    end procedure;

    function priv_instance_to_string(
      constant instance : in integer
    ) return string is
    begin
      if instance = ALL_INSTANCES then
        return "ALL_INSTANCES";
      else
        return to_string(instance);
      end if;
    end function;

    impure function priv_get_name(
      constant vvc_idx : in natural
    ) return string is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_added_vvc_idx, TB_ERROR,
                           "priv_get_name() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).name;
    end function;

    impure function priv_get_instance(
      constant vvc_idx : in natural
    ) return integer is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_added_vvc_idx, TB_ERROR,
                           "priv_get_instance() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).instance;
    end function;

    impure function priv_get_channel(
      constant vvc_idx : in natural
    ) return t_channel is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_added_vvc_idx, TB_ERROR,
                           "priv_get_channel() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).channel;
    end function;

    impure function priv_get_vvc_info(
      constant vvc_idx : in natural
    ) return string is
    begin
      check_value_in_range(vvc_idx, 0, priv_last_added_vvc_idx, TB_ERROR,
                           "priv_get_vvc_info() => vvc_idx invalid range: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      if priv_vvc_list(vvc_idx).channel = NA then
        return priv_vvc_list(vvc_idx).name & "," & priv_instance_to_string(priv_vvc_list(vvc_idx).instance);
      else
        return priv_vvc_list(vvc_idx).name & "," & priv_instance_to_string(priv_vvc_list(vvc_idx).instance) & "," & to_string(priv_vvc_list(vvc_idx).channel);
      end if;
    end function;

    impure function priv_get_vvc_list(idx : natural := natural'low) return string is
    begin
      if priv_last_added_vvc_idx = -1 then
        alert(TB_ERROR, "priv_get_vvc_list() => vvc_list is empty!");
        return " ";
      elsif idx < priv_last_added_vvc_idx then
        return "(" & priv_get_vvc_info(idx) & ")" & string'(priv_get_vvc_list(idx + 1));
      else
        return "(" & priv_get_vvc_info(idx) & ")";
      end if;
    end function;

    impure function priv_get_num_vvc_in_list return natural is
    begin
      return priv_last_added_vvc_idx + 1;
    end function;

  end protected body t_prot_vvc_list;

end package body ti_protected_types_pkg;
