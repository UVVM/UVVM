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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.string_methods_pkg.all;

package protected_types_pkg is


  type t_protected_alert_attention_counters is protected
    procedure increment(
      alert_level : t_alert_level;
      attention   : t_attention := REGARD;  -- count, expect, ignore
      number      : natural := 1
    );
    impure function get(
      alert_level : t_alert_level;
      attention   : t_attention := REGARD
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
  end protected t_protected_acknowledge_cmd_idx;


  type t_protected_check_counters is protected
    procedure increment(
      check_type : t_check_type;
      number     : natural := 1
    );
    procedure decrement(
      check_type : t_check_type;
      number     : integer := -1
    );
    impure function get(
      check_type : t_check_type
    ) return natural;
    procedure to_string(
      order : t_order
    );
  end protected t_protected_check_counters;


  type t_protected_covergroup_status is protected
    impure function add_coverpoint(VOID : in t_void) return integer;
    procedure set_name(coverpoint_idx : in integer; name : in string);
    procedure set_num_valid_bins(coverpoint_idx : in integer; num_bins : in natural);
    procedure set_num_illegal_bins(coverpoint_idx : in integer; num_bins : in natural);
    procedure set_num_uncovered_bins(coverpoint_idx : in integer; num_bins : in natural);
    procedure set_total_bin_hits(coverpoint_idx : in integer; hits : in natural);
    procedure set_total_bin_min_hits(coverpoint_idx : in integer; min_hits : in natural);
    procedure set_coverage_weight(coverpoint_idx : in integer; weight : in positive);
    procedure set_coverage_goal(coverpoint_idx : in integer; percentage : in positive);
    procedure set_covergroup_coverage_goal(percentage : in positive);
    procedure increment_valid_bin_count(coverpoint_idx : in integer);
    procedure increment_illegal_bin_count(coverpoint_idx : in integer);
    procedure increment_covered_bin_count(coverpoint_idx : in integer);
    procedure increment_hits_count(coverpoint_idx : in integer);
    procedure increment_min_hits_count(coverpoint_idx : in integer; min_hits : in natural);
    impure function get_num_coverpoints(VOID : in t_void) return natural;
    impure function get_name(coverpoint_idx : in integer) return string;
    impure function get_num_valid_bins(coverpoint_idx : in integer) return natural;
    impure function get_num_illegal_bins(coverpoint_idx : in integer) return natural;
    impure function get_num_uncovered_bins(coverpoint_idx : in integer) return natural;
    impure function get_total_bin_hits(coverpoint_idx : in integer) return natural;
    impure function get_total_bin_min_hits(coverpoint_idx : in integer) return natural;
    impure function get_coverage_weight(coverpoint_idx : in integer) return positive;
    impure function get_coverage_goal(coverpoint_idx : in integer) return positive;
    impure function get_covergroup_coverage_goal(VOID : in t_void) return positive;
    impure function get_combined_coverage_goal(coverpoint_idx : in integer) return positive;
    impure function get_bins_coverage(coverpoint_idx : in integer) return real;
    impure function get_hits_coverage(coverpoint_idx : in integer) return real;
    impure function get_total_hits_coverage(VOID : in t_void) return real;
  end protected t_protected_covergroup_status;


end package protected_types_pkg;

--=============================================================================
--=============================================================================

package body protected_types_pkg is


  --------------------------------------------------------------------------------
  type t_protected_alert_attention_counters is protected body
    variable priv_alert_attention_counters : t_alert_attention_counters;

    procedure increment(
      alert_level : t_alert_level;
      attention   : t_attention := REGARD;
      number      : natural := 1
    ) is
    begin
      priv_alert_attention_counters(alert_level)(attention) := priv_alert_attention_counters(alert_level)(attention) + number;
    end;

    impure function get(
      alert_level : t_alert_level;
      attention   : t_attention := REGARD
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
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
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
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
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
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  type t_protected_check_counters is protected body
    variable priv_check_counters : t_check_counters_array;

    procedure increment(
      check_type : t_check_type;
      number     : natural := 1
    ) is
    begin
      priv_check_counters(check_type) := priv_check_counters(check_type) + number;
    end;

    procedure decrement(
      check_type : t_check_type;
      number     : integer := -1
    ) is
    begin
      priv_check_counters(check_type) := priv_check_counters(check_type) - number;
    end;

    impure function get(
      check_type : t_check_type
    ) return natural is
    begin
      return priv_check_counters(check_type);
    end;

    procedure to_string(
      order  : t_order
    ) is
    begin
      to_string(priv_check_counters, order);
    end;

  end protected body t_protected_check_counters;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  type t_protected_covergroup_status is protected body
    type t_coverpoint_status is record
      name               : string(1 to C_FC_MAX_NAME_LENGTH);
      num_valid_bins     : natural;
      num_illegal_bins   : natural;
      num_covered_bins   : natural;
      total_bin_hits     : natural;
      total_bin_min_hits : natural;
      coverage_weight    : positive;
      coverage_goal      : positive;
    end record;
    constant C_COVERPOINT_STATUS_DEFAULT : t_coverpoint_status := (
      name               => (others => NUL),
      num_valid_bins     => 0,
      num_illegal_bins   => 0,
      num_covered_bins   => 0,
      total_bin_hits     => 0,
      total_bin_min_hits => 0,
      coverage_weight    => 1,
      coverage_goal      => 100
    );
    type t_coverpoint_status_array is array (natural range <>) of t_coverpoint_status;

    variable priv_coverpoint_status_list    : t_coverpoint_status_array(0 to C_FC_MAX_NUM_COVERPOINTS-1) := (others => C_COVERPOINT_STATUS_DEFAULT);
    variable priv_last_added_coverpoint_idx : integer  := -1;
    variable priv_coverage_goal             : positive := 100;

    impure function add_coverpoint(
      constant VOID : in t_void)
    return integer is
      constant C_COVERPOINT_NUM : string := to_string(priv_last_added_coverpoint_idx + 2);
    begin
      if priv_last_added_coverpoint_idx < C_FC_MAX_NUM_COVERPOINTS-1 then
        priv_last_added_coverpoint_idx := priv_last_added_coverpoint_idx + 1;
        priv_coverpoint_status_list(priv_last_added_coverpoint_idx).name := "Covpt_" & C_COVERPOINT_NUM & fill_string(NUL, C_FC_MAX_NAME_LENGTH-6-C_COVERPOINT_NUM'length);
        return priv_last_added_coverpoint_idx;
      else
        return -1; -- Error: no more space in the list
      end if;
    end function;

    procedure set_name(
      constant coverpoint_idx : in integer;
      constant name           : in string) is
    begin
      if name'length > C_FC_MAX_NAME_LENGTH then
        priv_coverpoint_status_list(coverpoint_idx).name := name(1 to C_FC_MAX_NAME_LENGTH);
      else
        priv_coverpoint_status_list(coverpoint_idx).name := name & fill_string(NUL, C_FC_MAX_NAME_LENGTH-name'length);
      end if;
    end procedure;

    procedure set_num_valid_bins(
      constant coverpoint_idx : in integer;
      constant num_bins       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_valid_bins := num_bins;
    end procedure;

    procedure set_num_illegal_bins(
      constant coverpoint_idx : in integer;
      constant num_bins       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_illegal_bins := num_bins;
    end procedure;

    procedure set_num_uncovered_bins(
      constant coverpoint_idx : in integer;
      constant num_bins       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_covered_bins := priv_coverpoint_status_list(coverpoint_idx).num_valid_bins - num_bins;
    end procedure;

    procedure set_total_bin_hits(
      constant coverpoint_idx : in integer;
      constant hits           : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_hits := hits;
    end procedure;

    procedure set_total_bin_min_hits(
      constant coverpoint_idx : in integer;
      constant min_hits       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits := min_hits;
    end procedure;

    procedure set_coverage_weight(
      constant coverpoint_idx : in integer;
      constant weight         : in positive) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).coverage_weight := weight;
    end procedure;

    procedure set_coverage_goal(
      constant coverpoint_idx : in integer; 
      constant percentage     : in positive) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).coverage_goal := percentage;
    end procedure;

    procedure set_covergroup_coverage_goal(
      constant percentage : in positive) is
    begin
      priv_coverage_goal := percentage;
    end procedure;

    procedure increment_valid_bin_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_valid_bins := priv_coverpoint_status_list(coverpoint_idx).num_valid_bins + 1;
    end procedure;

    procedure increment_illegal_bin_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_illegal_bins := priv_coverpoint_status_list(coverpoint_idx).num_illegal_bins + 1;
    end procedure;

    procedure increment_covered_bin_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_covered_bins := priv_coverpoint_status_list(coverpoint_idx).num_covered_bins + 1;
    end procedure;

    procedure increment_hits_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_hits := priv_coverpoint_status_list(coverpoint_idx).total_bin_hits + 1;
    end procedure;

    procedure increment_min_hits_count(
      constant coverpoint_idx : in integer;
      constant min_hits       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits := priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits + min_hits;
    end procedure;

    impure function get_num_coverpoints(
      constant VOID : t_void)
    return natural is
    begin
      return priv_last_added_coverpoint_idx+1;
    end function;

    impure function get_name(
      constant coverpoint_idx : in integer)
    return string is
    begin
      return to_string(priv_coverpoint_status_list(coverpoint_idx).name);
    end function;

    impure function get_num_valid_bins(
      constant coverpoint_idx : in integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).num_valid_bins;
    end function;

    impure function get_num_illegal_bins(
      constant coverpoint_idx : in integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).num_illegal_bins;
    end function;

    impure function get_num_uncovered_bins(
      constant coverpoint_idx : in integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).num_valid_bins - priv_coverpoint_status_list(coverpoint_idx).num_covered_bins;
    end function;

    impure function get_total_bin_hits(
      constant coverpoint_idx : in integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).total_bin_hits;
    end function;

    impure function get_total_bin_min_hits(
      constant coverpoint_idx : in integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits;
    end function;

    impure function get_coverage_weight(
      constant coverpoint_idx : in integer)
    return positive is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).coverage_weight;
    end function;

    impure function get_coverage_goal(
      constant coverpoint_idx : in integer)
    return positive is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).coverage_goal;
    end function;

    impure function get_covergroup_coverage_goal(
      constant VOID : t_void)
    return positive is
    begin
      return priv_coverage_goal;
    end function;

    impure function get_combined_coverage_goal(
      constant coverpoint_idx : in integer)
    return positive is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).coverage_goal * priv_coverage_goal / 100;
    end function;

    -- Returns the percentage of covered_bins/valid_bins in the coverpoint
    impure function get_bins_coverage(
      constant coverpoint_idx : in integer)
    return real is
      variable v_num_covered_bins : natural := priv_coverpoint_status_list(coverpoint_idx).num_covered_bins;
      variable v_num_valid_bins   : natural := priv_coverpoint_status_list(coverpoint_idx).num_valid_bins;
      variable v_coverage         : real;
    begin
      v_coverage := real(v_num_covered_bins)*100.0/real(v_num_valid_bins) when v_num_valid_bins > 0 else 0.0;
      return v_coverage;
    end function;

    -- Returns the percentage of total_hits/total_min_hits in the coverpoint
    impure function get_hits_coverage(
      constant coverpoint_idx : in integer)
    return real is
      variable v_tot_bin_hits     : natural := priv_coverpoint_status_list(coverpoint_idx).total_bin_hits;
      variable v_tot_bin_min_hits : natural := priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits;
      variable v_coverage         : real;
    begin
      v_coverage := real(v_tot_bin_hits)*100.0/real(v_tot_bin_min_hits) when v_tot_bin_min_hits > 0 else 0.0;
      return v_coverage;
    end function;

    -- Returns the percentage of total_hits/total_min_hits for all the coverpoints
    impure function get_total_hits_coverage(
      constant VOID : t_void)
    return real is
      variable v_tot_bin_hits     : natural := 0;
      variable v_tot_bin_min_hits : natural := 0;
      variable v_coverage         : real;
    begin
      for i in 0 to priv_last_added_coverpoint_idx loop
        v_tot_bin_hits     := v_tot_bin_hits + priv_coverpoint_status_list(i).total_bin_hits * priv_coverpoint_status_list(i).coverage_weight;
        v_tot_bin_min_hits := v_tot_bin_min_hits + priv_coverpoint_status_list(i).total_bin_min_hits * priv_coverpoint_status_list(i).coverage_weight * priv_coverpoint_status_list(i).coverage_goal/100;
      end loop;
      v_coverage := real(v_tot_bin_hits)*100.0/real(v_tot_bin_min_hits) when v_tot_bin_min_hits > 0 else 0.0;
      return v_coverage;
    end function;

  end protected body t_protected_covergroup_status;
  --------------------------------------------------------------------------------

end package body protected_types_pkg;
