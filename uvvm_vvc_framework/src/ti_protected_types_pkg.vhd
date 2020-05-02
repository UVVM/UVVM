--================================================================================================================================
-- Copyright 2020 Bitvis
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


library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;


package ti_protected_types_pkg is

  ------------------------------------------------------------
  -- Protected type to register and report VVC activity
  ------------------------------------------------------------
  type t_vvc_activity is protected

    impure function priv_are_all_vvc_inactive return boolean;

    impure function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel := NA
    ) return integer;

    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant activity               : t_activity;
      constant last_cmd_idx_executed  : integer
    );

    impure function priv_get_num_registered_vvc return natural;

    procedure priv_list_registered_vvc(msg : string);    

    impure function priv_get_vvc_idx_in_activity_register(
      constant vvc_name         : in string;
      constant vvc_instance_idx : in integer;
      constant vvc_channel      : in t_channel := NA
    ) return integer;

    impure function priv_get_vvc_activity(constant vvc_idx : natural) return t_activity;
    impure function priv_get_vvc_last_cmd_idx_executed(constant vvc_idx : natural) return integer;

  end protected;

  ------------------------------------------------------------
  -- Protected type to gather VVCs in a list
  ------------------------------------------------------------
  type t_vvc_list is protected

    procedure add(
      constant name     : in string;
      constant instance : in natural;
      constant channel  : in t_channel;
      constant cmd_idx  : in integer
    );

    procedure add(
      constant name     : in string;
      constant instance : in natural;
      constant channel  : in t_channel := NA
    );

    procedure add(
      constant name     : in string;
      constant instance : in natural;
      constant cmd_idx  : in integer
    );

    procedure priv_clean_list;

    impure function priv_get_name(
      constant vvc_idx  : in natural
    ) return string;

    impure function priv_get_instance(
      constant vvc_idx  : in natural
    ) return natural;

    impure function priv_get_channel(
      constant vvc_idx  : in natural
    ) return t_channel;

    impure function priv_get_cmd_idx(
      constant vvc_idx  : in natural
    ) return integer;

    impure function priv_get_vvc_info(
      constant vvc_idx : natural
    ) return string;

    impure function priv_get_vvc_list return string;

    impure function priv_get_num_vvc_in_list return natural;

  end protected;

end package ti_protected_types_pkg;

--=============================================================================
--=============================================================================

package body ti_protected_types_pkg is

  ------------------------------------------------------------
  -- Protected type to register and report VVC activity
  ------------------------------------------------------------
  type t_vvc_activity is protected body

    type t_vvc_item is record
      vvc_id     : t_vvc_id;
      vvc_state  : t_vvc_state;
    end record;
    constant C_VVC_ITEM_DEFAULT : t_vvc_item := (
      vvc_id     => C_VVC_ID_DEFAULT,
      vvc_state  => C_VVC_STATE_DEFAULT
    );
    type t_registered_vvc_array   is array (natural range <>) of t_vvc_item;


    -- Array holding all registered VVCs
    variable priv_registered_vvc  : t_registered_vvc_array(0 to C_MAX_TB_VVC_NUM) := (others => C_VVC_ITEM_DEFAULT);
    -- Counter for the number of VVCs that has registered
    variable priv_last_registered_vvc_idx : integer := -1;


    impure function priv_are_all_vvc_inactive return boolean is
    begin
      check_value(priv_last_registered_vvc_idx /= -1, TB_ERROR, "No VVC in activity watchdog register", C_TB_SCOPE_DEFAULT, ID_NEVER);

      for idx in 0 to priv_last_registered_vvc_idx loop
        if priv_registered_vvc(idx).vvc_state.activity = ACTIVE then
          return false;
        end if;
      end loop;
      return true;
    end function priv_are_all_vvc_inactive;

    impure function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel := NA
    ) return integer is
    begin
      if C_MAX_TB_VVC_NUM <= priv_last_registered_vvc_idx then
        alert(tb_error, "Number of registered VVCs exceed C_MAX_TB_VVC_NUM.\n"&
                         "Increase C_MAX_TB_VVC_NUM in adaptations package.");
      end if;

      -- Set registered VVC index
      priv_last_registered_vvc_idx := priv_last_registered_vvc_idx + 1;
      -- Update register
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.name(1 to name'length)   := name;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.instance                 := instance;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.channel                  := channel;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.activity              := INACTIVE;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.last_cmd_idx_executed := -1;
      -- Return index
      return priv_last_registered_vvc_idx;
    end function priv_register_vvc;

    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant activity               : t_activity;
      constant last_cmd_idx_executed  : integer
    ) is
    begin
      -- Update VVC status
      priv_registered_vvc(vvc_idx).vvc_state.activity              := activity;
      priv_registered_vvc(vvc_idx).vvc_state.last_cmd_idx_executed := last_cmd_idx_executed;
    end procedure priv_report_vvc_activity;

    impure function priv_get_num_registered_vvc return natural is
    begin
      if priv_last_registered_vvc_idx = -1 then
        return 0;
      else
        return priv_last_registered_vvc_idx + 1;
      end if;
    end function priv_get_num_registered_vvc;

    procedure priv_list_registered_vvc(msg : string) is
      variable v_vvc : t_vvc_id;
    begin
      log(ID_VVC_ACTIVITY, "VVC activity registered VVCs: " & msg);

      for idx in 0 to priv_last_registered_vvc_idx loop
        v_vvc := priv_registered_vvc(idx).vvc_id;

        if v_vvc.channel = NA then
          log(ID_VVC_ACTIVITY, to_string(idx+1) & ": " & v_vvc.name & " instance=" & to_string(v_vvc.instance));  
        else
          log(ID_VVC_ACTIVITY, to_string(idx+1) & ": " & v_vvc.name & " instance=" & to_string(v_vvc.instance) & ", channel=" & to_string(v_vvc.channel));            
        end if;
        
      end loop;
    end procedure priv_list_registered_vvc;

    impure function priv_get_vvc_activity(
      constant vvc_idx : natural
    ) return t_activity is
    begin
      check_value(priv_last_registered_vvc_idx >= vvc_idx, TB_ERROR, "Invalid index for VVC activity register: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      check_value(vvc_idx > -1, TB_ERROR, "Invalid index for VVC activity register: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_registered_vvc(vvc_idx).vvc_state.activity;
    end function;

    impure function priv_get_vvc_last_cmd_idx_executed(
      constant vvc_idx : natural
    ) return integer is
    begin
      check_value(priv_last_registered_vvc_idx >= vvc_idx, TB_ERROR, "Invalid index for VVC activity register: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      check_value(vvc_idx > -1, TB_ERROR, "Invalid index for VVC activity register: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_registered_vvc(vvc_idx).vvc_state.last_cmd_idx_executed;
    end function;

    impure function priv_get_vvc_idx_in_activity_register(
      constant vvc_name         : in string;
      constant vvc_instance_idx : in integer;
      constant vvc_channel      : in t_channel := NA
    ) return integer is
    begin
      for idx in 0 to priv_last_registered_vvc_idx loop
        
        if priv_registered_vvc(idx).vvc_id.name     = vvc_name and
          priv_registered_vvc(idx).vvc_id.instance  = vvc_instance_idx and
          priv_registered_vvc(idx).vvc_id.channel   = vvc_channel then
          -- vvc was found
          return idx;
        end if;

      end loop;

      -- not found
      return -1;
    end function priv_get_vvc_idx_in_activity_register;

  end protected body t_vvc_activity;


  ------------------------------------------------------------
  -- Protected type to gather VVCs in a list
  ------------------------------------------------------------
  type t_vvc_list is protected body

    type t_vvc_item is record
      name      : string(1 to C_MAX_VVC_NAME_LENGTH);
      instance  : natural;
      channel   : t_channel;
      cmd_idx   : integer;
    end record;
    constant C_VVC_ITEM_DEFAULT : t_vvc_item := (
      name      => (others => NUL),
      instance  => 0,
      channel   => NA,
      cmd_idx   => 0
    );
    type t_vvc_item_array is array (natural range <>) of t_vvc_item;


    -- Array holding the VVCs info
    variable priv_vvc_list : t_vvc_item_array(0 to C_MAX_TB_VVC_NUM) := (others => C_VVC_ITEM_DEFAULT);
    -- Counter for the number of VVCs in the list
    variable priv_last_added_vvc_idx : integer := -1;


    procedure add(
      constant name     : in string;
      constant instance : in natural;
      constant channel  : in t_channel;
      constant cmd_idx  : in integer
    ) is
      variable v_duplicate : boolean := false;
    begin
      if priv_last_added_vvc_idx >= C_MAX_TB_VVC_NUM then
        alert(tb_error, "Number of VVCs in the list exceed C_MAX_TB_VVC_NUM.\n" & "Increase C_MAX_TB_VVC_NUM in adaptations package.");
      end if;

      -- Check if VVC was previously added
      for idx in 0 to priv_last_added_vvc_idx loop
        if priv_vvc_list(idx).name(1 to name'length) = name and
          priv_vvc_list(idx).instance = instance and
          priv_vvc_list(idx).channel  = channel and
          priv_vvc_list(idx).cmd_idx  = cmd_idx then
          v_duplicate := true;
          exit;
        end if;
      end loop;

      if v_duplicate then
        alert(tb_warning, name & "," & to_string(instance) & "," & to_string(channel) & "," & to_string(cmd_idx) &  " was previously added to the list.");
      else
        -- Set VVC index
        priv_last_added_vvc_idx := priv_last_added_vvc_idx + 1;
        -- Update register
        priv_vvc_list(priv_last_added_vvc_idx).name(1 to name'length) := name;
        priv_vvc_list(priv_last_added_vvc_idx).instance               := instance;
        priv_vvc_list(priv_last_added_vvc_idx).channel                := channel;
        priv_vvc_list(priv_last_added_vvc_idx).cmd_idx                := cmd_idx;

        if channel = NA then
          if cmd_idx = -1 then
            log(ID_AWAIT_COMPLETION, "Adding: " & name & "," & to_string(instance) & " to the list.");  
          else
            log(ID_AWAIT_COMPLETION, "Adding: " & name & "," & to_string(instance) & ",[" & to_string(cmd_idx) & "] to the list.");  
          end if;
        else
          if cmd_idx = -1 then
            log(ID_AWAIT_COMPLETION, "Adding: " & name & "," & to_string(instance) & "," & to_string(channel) & " to the list.");            
          else
            log(ID_AWAIT_COMPLETION, "Adding: " & name & "," & to_string(instance) & "," & to_string(channel) & ",[" & to_string(cmd_idx) & "] to the list.");            
          end if;
        end if;
      end if;
    end procedure add;

    procedure add(
      constant name     : in string;
      constant instance : in natural;
      constant channel  : in t_channel := NA
    ) is
    begin
      add(name, instance, channel, -1);
    end procedure add;

    procedure add(
      constant name     : in string;
      constant instance : in natural;
      constant cmd_idx  : in integer
    ) is
    begin
      add(name, instance, NA, cmd_idx);
    end procedure add;

    procedure priv_clean_list is
    begin
      priv_vvc_list := (others => C_VVC_ITEM_DEFAULT);
      priv_last_added_vvc_idx := -1;
    end procedure priv_clean_list;

    impure function priv_get_name(
      constant vvc_idx  : in natural
    ) return string is
    begin
      check_value_in_range(vvc_idx, 0, C_MAX_TB_VVC_NUM, ERROR, "priv_get_name() => vvc_idx invalid range", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).name;
    end function;

    impure function priv_get_instance(
      constant vvc_idx  : in natural
    ) return natural is
    begin
      check_value_in_range(vvc_idx, 0, C_MAX_TB_VVC_NUM, ERROR, "priv_get_instance() => vvc_idx invalid range", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).instance;
    end function;

    impure function priv_get_channel(
      constant vvc_idx  : in natural
    ) return t_channel is
    begin
      check_value_in_range(vvc_idx, 0, C_MAX_TB_VVC_NUM, ERROR, "priv_get_channel() => vvc_idx invalid range", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).channel;
    end function;

    impure function priv_get_cmd_idx(
      constant vvc_idx  : in natural
    ) return integer is
    begin
      check_value_in_range(vvc_idx, 0, C_MAX_TB_VVC_NUM, ERROR, "priv_get_cmd_idx() => vvc_idx invalid range", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_vvc_list(vvc_idx).cmd_idx;
    end function;

    impure function priv_get_vvc_info(
      constant vvc_idx : natural
    ) return string is
    begin
      check_value_in_range(vvc_idx, 0, C_MAX_TB_VVC_NUM, ERROR, "priv_get_vvc_info() => vvc_idx invalid range", C_TB_SCOPE_DEFAULT, ID_NEVER);
      if priv_vvc_list(vvc_idx).channel = NA then
        if priv_vvc_list(vvc_idx).cmd_idx = -1 then
          return priv_vvc_list(vvc_idx).name & "," & to_string(priv_vvc_list(vvc_idx).instance);
        else
          return priv_vvc_list(vvc_idx).name & "," & to_string(priv_vvc_list(vvc_idx).instance) & ",[" & to_string(priv_vvc_list(vvc_idx).cmd_idx) & "]";
        end if;
      else
        if priv_vvc_list(vvc_idx).cmd_idx = -1 then
          return priv_vvc_list(vvc_idx).name & "," & to_string(priv_vvc_list(vvc_idx).instance) & "," & to_string(priv_vvc_list(vvc_idx).channel); 
        else
          return priv_vvc_list(vvc_idx).name & "," & to_string(priv_vvc_list(vvc_idx).instance) & "," & to_string(priv_vvc_list(vvc_idx).channel) &
            ",[" & to_string(priv_vvc_list(vvc_idx).cmd_idx) & "]"; 
        end if;
      end if;
    end function priv_get_vvc_info;

    impure function priv_get_vvc_list return string is
      variable v_line     : line;
      variable v_line_len : integer;
      variable v_string   : string(1 to 500);
    begin
      for idx in 0 to priv_last_added_vvc_idx loop
        write(v_line, "(" & priv_get_vvc_info(idx) & ")");
        if idx < priv_last_added_vvc_idx then
          write(v_line, ',');
        end if;
      end loop;
      v_line_len := v_line'length;
      v_string(1 to v_line_len) := v_line.all;
      deallocate(v_line);
      return v_string(1 to v_line_len);
    end function priv_get_vvc_list;

    impure function priv_get_num_vvc_in_list return natural is
    begin
      return priv_last_added_vvc_idx + 1;
    end function;

  end protected body t_vvc_list;

end package body ti_protected_types_pkg;