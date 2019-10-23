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


library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;


package ti_protected_types_pkg is


  type t_inactivity_watchdog is protected

    impure function priv_are_all_vvc_inactive return boolean;

    impure function priv_register_vvc(
      constant name                   : in string;
      constant instance               : in natural;
      constant channel                : in t_channel := NA
    ) return integer;

    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant busy                   : boolean;
      constant last_cmd_idx_executed  : integer
    );

    impure function priv_get_num_registered_vvc return natural;

    procedure priv_list_registered_vvc(msg : string);    

  end protected;



end package ti_protected_types_pkg;

--=============================================================================
--=============================================================================

package body ti_protected_types_pkg is


  type t_inactivity_watchdog is protected body

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

    variable priv_registered_vvc  : t_registered_vvc_array(0 to C_MAX_VVC_INSTANCE_NUM) := (others => C_VVC_ITEM_DEFAULT);

    -- Counter for the number of VVCs that has registered
    variable priv_last_registered_vvc_idx : integer := -1;


    impure function priv_are_all_vvc_inactive return boolean is
    begin
      check_value(priv_last_registered_vvc_idx /= -1, TB_ERROR, "No VVC in activity watchdog register");

      for idx in 0 to priv_last_registered_vvc_idx loop
        if priv_registered_vvc(idx).vvc_state.busy = true then
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
      -- Set registered VVC index
      priv_last_registered_vvc_idx := priv_last_registered_vvc_idx + 1;
      -- Update register
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.name(1 to name'length)   := name;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.instance                 := instance;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_id.channel                  := channel;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.busy                  := false;
      priv_registered_vvc(priv_last_registered_vvc_idx).vvc_state.last_cmd_idx_executed := -1;
      -- Return index
      return priv_last_registered_vvc_idx;
    end function priv_register_vvc;


    procedure priv_report_vvc_activity(
      constant vvc_idx                : natural;
      constant busy                   : boolean;
      constant last_cmd_idx_executed  : integer
    ) is
    begin
      -- Update VVC status
      priv_registered_vvc(vvc_idx).vvc_state.busy                  := busy;
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
      log(ID_WATCHDOG, "Activity watchdog registered VVCs: " & msg);

      for idx in 0 to priv_last_registered_vvc_idx loop
        v_vvc := priv_registered_vvc(idx).vvc_id;

        if v_vvc.channel = NA then
          log(ID_WATCHDOG, to_string(idx+1) & ": " & v_vvc.name & " instance=" & to_string(v_vvc.instance));  
        else
          log(ID_WATCHDOG, to_string(idx+1) & ": " & v_vvc.name & " instance=" & to_string(v_vvc.instance) & ", channel=" & to_string(v_vvc.channel));            
        end if;
        
      end loop;
    end procedure priv_list_registered_vvc;


  end protected body t_inactivity_watchdog;




end package body ti_protected_types_pkg;