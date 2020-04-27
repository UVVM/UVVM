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

    impure function priv_get_vvc_activity(vvc_idx : natural) return t_activity;
    impure function priv_get_vvc_last_cmd_idx_executed(vvc_idx : natural) return integer;
  end protected;



end package ti_protected_types_pkg;

--=============================================================================
--=============================================================================

package body ti_protected_types_pkg is


  type t_vvc_activity is protected body

    type t_vvc_item is record
      vvc_id     : t_vvc_id;
      vvc_state  : t_vvc_state;
    end record;
    constant C_VVC_ITEM_DEFAULT : t_vvc_item := (
      vvc_id     => C_VVC_ID_DEFAULT,
      vvc_state  => C_VVC_STATE_DEFAULT
    );


    -- Array holding all registered VVCs
    type t_registered_vvc_array   is array (natural range <>) of t_vvc_item;

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
      vvc_idx : natural
    ) return t_activity is
    begin
      check_value(priv_last_registered_vvc_idx >= vvc_idx, TB_ERROR, "Invalid index for VVC activity register: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      check_value(vvc_idx > -1, TB_ERROR, "Invalid index for VVC activity register: " & to_string(vvc_idx) & ".", C_TB_SCOPE_DEFAULT, ID_NEVER);
      return priv_registered_vvc(vvc_idx).vvc_state.activity;
    end function;


    impure function priv_get_vvc_last_cmd_idx_executed(
      vvc_idx : natural
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




end package body ti_protected_types_pkg;