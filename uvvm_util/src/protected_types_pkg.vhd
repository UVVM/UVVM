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
use IEEE.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;


use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.string_methods_pkg.all;

package protected_types_pkg is


  type t_protected_alert_attention_counters is protected
    procedure increment(
      alert_level   : t_alert_level;
      attention    : t_attention := REGARD;  -- count, expect, ignore
      number     : natural := 1
      );
    impure function get(
      alert_level: t_alert_level;
      attention    : t_attention := REGARD
      ) return natural;
    procedure to_string(
      order  : t_order
      );
  end protected t_protected_alert_attention_counters;

  type t_protected_semaphore is protected
    impure function get_semaphore return boolean;
    procedure release_semaphore;
  end protected t_protected_semaphore;

  type t_protected_acknowledge_cmd_idx is protected

    impure function set_index(index : integer) return boolean;
    impure function get_index return integer;
    procedure release_index;
  end protected  t_protected_acknowledge_cmd_idx;

end package protected_types_pkg;

--=============================================================================
--=============================================================================

package body protected_types_pkg is


--------------------------------------------------------------------------------
  type t_protected_alert_attention_counters is protected body
    variable priv_alert_attention_counters : t_alert_attention_counters;

    procedure increment(
      alert_level: t_alert_level;
      attention    : t_attention := REGARD;
      number     : natural := 1
      ) is
    begin
      priv_alert_attention_counters(alert_level)(attention) := priv_alert_attention_counters(alert_level)(attention) + number;
    end;


    impure function get(
      alert_level: t_alert_level;
      attention    : t_attention := REGARD
      ) return natural is
    begin
      return priv_alert_attention_counters(alert_level)(attention);
    end;

    procedure to_string(
      order  : t_order
      ) is
    begin
      to_string(priv_alert_attention_counters, order);
    end;

  end protected body t_protected_alert_attention_counters;

  type t_protected_semaphore is protected body

    variable v_priv_semaphore_taken : boolean := false;

    impure function get_semaphore return boolean is
    begin
      if v_priv_semaphore_taken = false then
        -- semaphore was free
        v_priv_semaphore_taken := true;
        return true;
      else
        -- semaphore was not free
        return false;
      end if;
    end;

    procedure release_semaphore is
    begin
      v_priv_semaphore_taken := false;
    end procedure;
  end protected body t_protected_semaphore;


  type t_protected_acknowledge_cmd_idx is protected body

    variable v_priv_idx : integer := -1;

    impure function set_index(index : integer) return boolean is
    begin
    -- for broadcast
      if v_priv_idx = -1 or v_priv_idx = index then
        -- index was now set
        v_priv_idx := index;
        return true;
      else
        -- index was set by another vvc
        return false;
      end if;
    end;

    impure function get_index return integer is
    begin
      return v_priv_idx;
    end;

    procedure release_index is
    begin
      v_priv_idx := -1;
    end procedure;
  end protected body t_protected_acknowledge_cmd_idx;

end package body protected_types_pkg;
