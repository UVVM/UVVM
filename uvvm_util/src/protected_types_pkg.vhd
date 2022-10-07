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
      attention   : t_attention := REGARD; -- count, expect, ignore
      number      : natural     := 1
    );
    impure function get(
      alert_level : t_alert_level;
      attention   : t_attention := REGARD
    ) return natural;
    procedure to_string(
      order : t_order
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
      number     : integer := 1
    );
    impure function get(
      check_type : t_check_type
    ) return natural;
    procedure to_string(
      order : t_order
    );
  end protected t_protected_check_counters;

  type t_protected_covergroup_status is protected
    impure function add_coverpoint(constant VOID : t_void) return integer;
    procedure remove_coverpoint(constant coverpoint_idx : in integer);
    procedure set_covpt_is_loaded(constant VOID : t_void);
    procedure set_name(constant coverpoint_idx : in integer; constant name : in string);
    procedure set_num_valid_bins(constant coverpoint_idx : in integer; constant num_bins : in natural);
    procedure set_num_covered_bins(constant coverpoint_idx : in integer; constant num_bins : in natural);
    procedure set_total_bin_min_hits(constant coverpoint_idx : in integer; constant min_hits : in natural);
    procedure set_total_bin_hits(constant coverpoint_idx : in integer; constant hits : in natural);
    procedure set_total_coverage_bin_hits(constant coverpoint_idx : in integer; constant hits : in natural);
    procedure set_total_goal_bin_hits(constant coverpoint_idx : in integer; constant hits : in natural);
    procedure set_coverage_weight(constant coverpoint_idx : in integer; constant weight : in natural);
    procedure set_bins_coverage_goal(constant coverpoint_idx : in integer; constant percentage : in positive range 1 to 100);
    procedure set_hits_coverage_goal(constant coverpoint_idx : in integer; constant percentage : in positive);
    procedure set_covpts_coverage_goal(constant percentage : in positive range 1 to 100);
    procedure set_num_tc_accumulated(constant coverpoint_idx : in integer; constant num_tc : in natural);
    procedure increment_valid_bin_count(constant coverpoint_idx : in integer);
    procedure increment_covered_bin_count(constant coverpoint_idx : in integer);
    procedure increment_min_hits_count(constant coverpoint_idx : in integer; constant min_hits : in natural);
    procedure increment_hits_count(constant coverpoint_idx : in integer);
    procedure increment_coverage_hits_count(constant coverpoint_idx : in integer);
    procedure increment_goal_hits_count(constant coverpoint_idx : in integer);
    impure function is_initialized(constant coverpoint_idx : integer) return boolean;
    impure function is_covpt_loaded(constant VOID : t_void) return boolean;
    impure function get_name(constant coverpoint_idx : integer) return string;
    impure function get_num_valid_bins(constant coverpoint_idx : integer) return natural;
    impure function get_num_covered_bins(constant coverpoint_idx : integer) return natural;
    impure function get_total_bin_min_hits(constant coverpoint_idx : integer) return natural;
    impure function get_total_bin_hits(constant coverpoint_idx : integer) return natural;
    impure function get_total_coverage_bin_hits(constant coverpoint_idx : integer) return natural;
    impure function get_total_goal_bin_hits(constant coverpoint_idx : integer) return natural;
    impure function get_coverage_weight(constant coverpoint_idx : integer) return natural;
    impure function get_bins_coverage_goal(constant coverpoint_idx : integer) return positive;
    impure function get_hits_coverage_goal(constant coverpoint_idx : integer) return positive;
    impure function get_covpts_coverage_goal(constant VOID : t_void) return positive;
    impure function get_num_tc_accumulated(constant coverpoint_idx : integer) return natural;
    impure function get_bins_coverage(constant coverpoint_idx : integer; constant cov_representation : t_coverage_representation) return real;
    impure function get_hits_coverage(constant coverpoint_idx : integer; constant cov_representation : t_coverage_representation) return real;
    impure function get_total_bins_coverage(constant VOID : t_void) return real;
    impure function get_total_hits_coverage(constant VOID : t_void) return real;
    impure function get_total_covpts_coverage(constant cov_representation : t_coverage_representation) return real;
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
      number      : natural     := 1
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
      order : t_order
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
    variable priv_check_counters             : t_check_counters_array;
    variable priv_counter_limit_alert_raised : boolean := False;

    -- Helper method for alerting when the maximum
    -- value for check_counter is reached.
    impure function priv_check_counter_limit_reached(
      check_type : t_check_type;
      number     : natural := 1
    ) return boolean is
    begin
      if priv_check_counters(check_type) = natural'high then
        if priv_counter_limit_alert_raised = false then
          report "check_counter limit reached" severity warning;
          priv_counter_limit_alert_raised := true;
        end if;
        return True;
      else
        return False;
      end if;
    end function priv_check_counter_limit_reached;

    procedure increment(
      check_type : t_check_type;
      number     : natural := 1
    ) is
    begin
      if C_ENABLE_CHECK_COUNTER then
        if priv_check_counter_limit_reached(check_type, number) = false then
          priv_check_counters(check_type) := priv_check_counters(check_type) + number;
        end if;
      end if;
    end procedure increment;

    procedure decrement(
      check_type : t_check_type;
      number     : integer := 1
    ) is
    begin
      if C_ENABLE_CHECK_COUNTER then
        if priv_check_counter_limit_reached(check_type, number) = false then
          priv_check_counters(check_type) := priv_check_counters(check_type) - number;
        end if;
      end if;
    end procedure decrement;

    impure function get(
      check_type : t_check_type
    ) return natural is
    begin
      return priv_check_counters(check_type);
    end function get;

    procedure to_string(
      order : t_order
    ) is
    begin
      to_string(priv_check_counters, order);
    end procedure to_string;

  end protected body t_protected_check_counters;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  type t_protected_covergroup_status is protected body
    type t_coverpoint_status is record
      initialized             : boolean;
      name                    : string(1 to C_FC_MAX_NAME_LENGTH);
      num_valid_bins          : natural; -- Number of valid bins (not ignore or illegal) in the coverpoint
      num_covered_bins        : natural; -- Number of covered bins (not ignore or illegal) in the coverpoint
      total_bin_min_hits      : natural; -- Number of total min_hits from all the bins in the coverpoint
      total_bin_hits          : natural; -- Number of total hits from all the bins in the coverpoint
      total_coverage_bin_hits : natural; -- Number of total hits from all the bins in the coverpoint (capped at min_hits)
      total_goal_bin_hits     : natural; -- Number of total hits from all the bins in the coverpoint (capped at min_hits x hits_goal)
      coverage_weight         : natural; -- Weight of the coverpoint used in overall coverage calculation
      bins_coverage_goal      : positive; -- Bins coverage goal of the coverpoint
      hits_coverage_goal      : positive; -- Hits coverage goal of the coverpoint
      num_tc_accumulated      : natural; -- Number of previous testcases which have accumulated coverage for the given coverpoint
    end record;
    constant C_COVERPOINT_STATUS_DEFAULT : t_coverpoint_status := (
      initialized             => false,
      name                    => (others => NUL),
      num_valid_bins          => 0,
      num_covered_bins        => 0,
      total_bin_min_hits      => 0,
      total_bin_hits          => 0,
      total_coverage_bin_hits => 0,
      total_goal_bin_hits     => 0,
      coverage_weight         => 1,
      bins_coverage_goal      => 100,
      hits_coverage_goal      => 100,
      num_tc_accumulated      => 0
    );
    type t_coverpoint_status_array is array (natural range <>) of t_coverpoint_status;

    variable priv_coverpoint_status_list : t_coverpoint_status_array(0 to C_FC_MAX_NUM_COVERPOINTS - 1) := (others => C_COVERPOINT_STATUS_DEFAULT);
    variable priv_coverpoint_name_idx    : natural                                                      := 1;
    variable priv_covpts_coverage_goal   : positive                                                     := 100;
    variable priv_loaded_coverpoint      : boolean                                                      := false;

    impure function add_coverpoint(
      constant VOID : t_void)
    return integer is
      constant C_COVERPOINT_NUM      : string  := to_string(priv_coverpoint_name_idx);
      variable v_next_coverpoint_idx : natural := 0;
    begin
      for i in 0 to C_FC_MAX_NUM_COVERPOINTS - 1 loop
        if not (priv_coverpoint_status_list(v_next_coverpoint_idx).initialized) then
          exit;
        end if;
        v_next_coverpoint_idx := v_next_coverpoint_idx + 1;
      end loop;

      if v_next_coverpoint_idx < C_FC_MAX_NUM_COVERPOINTS then
        priv_coverpoint_status_list(v_next_coverpoint_idx).name        := "Covpt_" & C_COVERPOINT_NUM & fill_string(NUL, C_FC_MAX_NAME_LENGTH - 6 - C_COVERPOINT_NUM'length);
        priv_coverpoint_status_list(v_next_coverpoint_idx).initialized := true;
        priv_coverpoint_name_idx                                       := priv_coverpoint_name_idx + 1;
        return v_next_coverpoint_idx;
      else
        return -1;                      -- Error: no more space in the list
      end if;
    end function;

    procedure remove_coverpoint(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx) := C_COVERPOINT_STATUS_DEFAULT;
    end procedure;

    procedure set_covpt_is_loaded(
      constant VOID : t_void) is
    begin
      priv_loaded_coverpoint := true;
    end procedure;

    procedure set_name(
      constant coverpoint_idx : in integer;
      constant name           : in string) is
    begin
      if name'length > C_FC_MAX_NAME_LENGTH then
        priv_coverpoint_status_list(coverpoint_idx).name := name(1 to C_FC_MAX_NAME_LENGTH);
      else
        priv_coverpoint_status_list(coverpoint_idx).name := name & fill_string(NUL, C_FC_MAX_NAME_LENGTH - name'length);
      end if;
    end procedure;

    procedure set_num_valid_bins(
      constant coverpoint_idx : in integer;
      constant num_bins       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_valid_bins := num_bins;
    end procedure;

    procedure set_num_covered_bins(
      constant coverpoint_idx : in integer;
      constant num_bins       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_covered_bins := num_bins;
    end procedure;

    procedure set_total_bin_min_hits(
      constant coverpoint_idx : in integer;
      constant min_hits       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits := min_hits;
    end procedure;

    procedure set_total_bin_hits(
      constant coverpoint_idx : in integer;
      constant hits           : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_hits := hits;
    end procedure;

    procedure set_total_coverage_bin_hits(
      constant coverpoint_idx : in integer;
      constant hits           : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_coverage_bin_hits := hits;
    end procedure;

    procedure set_total_goal_bin_hits(
      constant coverpoint_idx : in integer;
      constant hits           : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_goal_bin_hits := hits;
    end procedure;

    procedure set_coverage_weight(
      constant coverpoint_idx : in integer;
      constant weight         : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).coverage_weight := weight;
    end procedure;

    procedure set_bins_coverage_goal(
      constant coverpoint_idx : in integer;
      constant percentage     : in positive range 1 to 100) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).bins_coverage_goal := percentage;
    end procedure;

    procedure set_hits_coverage_goal(
      constant coverpoint_idx : in integer;
      constant percentage     : in positive) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).hits_coverage_goal := percentage;
    end procedure;

    procedure set_covpts_coverage_goal(
      constant percentage : in positive range 1 to 100) is
    begin
      priv_covpts_coverage_goal := percentage;
    end procedure;

    procedure set_num_tc_accumulated(
      constant coverpoint_idx : in integer;
      constant num_tc         : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_tc_accumulated := num_tc;
    end procedure;

    procedure increment_valid_bin_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_valid_bins := priv_coverpoint_status_list(coverpoint_idx).num_valid_bins + 1;
    end procedure;

    procedure increment_covered_bin_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).num_covered_bins := priv_coverpoint_status_list(coverpoint_idx).num_covered_bins + 1;
    end procedure;

    procedure increment_min_hits_count(
      constant coverpoint_idx : in integer;
      constant min_hits       : in natural) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits := priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits + min_hits;
    end procedure;

    procedure increment_hits_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_bin_hits := priv_coverpoint_status_list(coverpoint_idx).total_bin_hits + 1;
    end procedure;

    procedure increment_coverage_hits_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_coverage_bin_hits := priv_coverpoint_status_list(coverpoint_idx).total_coverage_bin_hits + 1;
    end procedure;

    procedure increment_goal_hits_count(
      constant coverpoint_idx : in integer) is
    begin
      priv_coverpoint_status_list(coverpoint_idx).total_goal_bin_hits := priv_coverpoint_status_list(coverpoint_idx).total_goal_bin_hits + 1;
    end procedure;

    impure function is_initialized(
      constant coverpoint_idx : integer)
    return boolean is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).initialized;
    end function;

    impure function is_covpt_loaded(
      constant VOID : t_void)
    return boolean is
    begin
      return priv_loaded_coverpoint;
    end function;

    impure function get_name(
      constant coverpoint_idx : integer)
    return string is
    begin
      return to_string(priv_coverpoint_status_list(coverpoint_idx).name);
    end function;

    impure function get_num_valid_bins(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).num_valid_bins;
    end function;

    impure function get_num_covered_bins(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).num_covered_bins;
    end function;

    impure function get_total_bin_min_hits(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits;
    end function;

    impure function get_total_bin_hits(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).total_bin_hits;
    end function;

    impure function get_total_coverage_bin_hits(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).total_coverage_bin_hits;
    end function;

    impure function get_total_goal_bin_hits(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).total_goal_bin_hits;
    end function;

    impure function get_coverage_weight(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).coverage_weight;
    end function;

    impure function get_bins_coverage_goal(
      constant coverpoint_idx : integer)
    return positive is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).bins_coverage_goal;
    end function;

    impure function get_hits_coverage_goal(
      constant coverpoint_idx : integer)
    return positive is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).hits_coverage_goal;
    end function;

    impure function get_covpts_coverage_goal(
      constant VOID : t_void)
    return positive is
    begin
      return priv_covpts_coverage_goal;
    end function;

    impure function get_num_tc_accumulated(
      constant coverpoint_idx : integer)
    return natural is
    begin
      return priv_coverpoint_status_list(coverpoint_idx).num_tc_accumulated;
    end function;

    -- Returns the percentage of covered_bins/valid_bins in the coverpoint
    impure function get_bins_coverage(
      constant coverpoint_idx     : integer;
      constant cov_representation : t_coverage_representation)
    return real is
      variable v_num_covered_bins : natural := priv_coverpoint_status_list(coverpoint_idx).num_covered_bins;
      variable v_num_valid_bins   : natural := priv_coverpoint_status_list(coverpoint_idx).num_valid_bins;
      variable v_coverage         : real;
    begin
      v_coverage := real(v_num_covered_bins) * 100.0 / real(v_num_valid_bins) when v_num_valid_bins > 0 else 0.0;
      if cov_representation = GOAL_CAPPED or cov_representation = GOAL_UNCAPPED then
        v_coverage := v_coverage * 100.0 / real(priv_coverpoint_status_list(coverpoint_idx).bins_coverage_goal);
      end if;
      if cov_representation = GOAL_CAPPED and v_coverage > 100.0 then
        v_coverage := 100.0;
      end if;
      return v_coverage;
    end function;

    -- Returns the percentage of total_hits/total_min_hits in the coverpoint
    impure function get_hits_coverage(
      constant coverpoint_idx     : integer;
      constant cov_representation : t_coverage_representation)
    return real is
      variable v_tot_coverage_bin_hits : natural := priv_coverpoint_status_list(coverpoint_idx).total_coverage_bin_hits;
      variable v_tot_goal_bin_hits     : natural := priv_coverpoint_status_list(coverpoint_idx).total_goal_bin_hits;
      variable v_tot_bin_hits          : natural := priv_coverpoint_status_list(coverpoint_idx).total_bin_hits;
      variable v_tot_bin_min_hits      : natural := priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits;
      variable v_tot_goal_bin_min_hits : real    := real(priv_coverpoint_status_list(coverpoint_idx).total_bin_min_hits * priv_coverpoint_status_list(coverpoint_idx).hits_coverage_goal) / 100.0;
      variable v_coverage              : real;
    begin
      if cov_representation = GOAL_CAPPED then
        v_coverage := real(v_tot_goal_bin_hits) * 100.0 / v_tot_goal_bin_min_hits when v_tot_goal_bin_min_hits > 0.0 else 0.0;
        v_coverage := 100.0 when v_coverage > 100.0;
      elsif cov_representation = GOAL_UNCAPPED then
        v_coverage := real(v_tot_bin_hits) * 100.0 / v_tot_goal_bin_min_hits when v_tot_goal_bin_min_hits > 0.0 else 0.0;
      else                              -- NO_GOAL
        v_coverage := real(v_tot_coverage_bin_hits) * 100.0 / real(v_tot_bin_min_hits) when v_tot_bin_min_hits > 0 else 0.0;
      end if;
      return v_coverage;
    end function;

    -- Returns the percentage of covered_bins/valid_bins for all the coverpoints
    impure function get_total_bins_coverage(
      constant VOID : t_void)
    return real is
      variable v_tot_covered_bins : natural := 0;
      variable v_tot_valid_bins   : natural := 0;
      variable v_coverage         : real;
    begin
      for i in 0 to C_FC_MAX_NUM_COVERPOINTS - 1 loop
        if priv_coverpoint_status_list(i).initialized then
          v_tot_covered_bins := v_tot_covered_bins + priv_coverpoint_status_list(i).num_covered_bins * priv_coverpoint_status_list(i).coverage_weight;
          v_tot_valid_bins   := v_tot_valid_bins + priv_coverpoint_status_list(i).num_valid_bins * priv_coverpoint_status_list(i).coverage_weight;
        end if;
      end loop;
      v_coverage := real(v_tot_covered_bins) * 100.0 / real(v_tot_valid_bins) when v_tot_valid_bins > 0 else 0.0;
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
      for i in 0 to C_FC_MAX_NUM_COVERPOINTS - 1 loop
        if priv_coverpoint_status_list(i).initialized then
          v_tot_bin_hits     := v_tot_bin_hits + priv_coverpoint_status_list(i).total_coverage_bin_hits * priv_coverpoint_status_list(i).coverage_weight;
          v_tot_bin_min_hits := v_tot_bin_min_hits + priv_coverpoint_status_list(i).total_bin_min_hits * priv_coverpoint_status_list(i).coverage_weight;
        end if;
      end loop;
      v_coverage := real(v_tot_bin_hits) * 100.0 / real(v_tot_bin_min_hits) when v_tot_bin_min_hits > 0 else 0.0;
      return v_coverage;
    end function;

    -- Returns the percentage of covered_coverpoints/total_coverpoints
    impure function get_total_covpts_coverage(
      constant cov_representation : t_coverage_representation)
    return real is
      variable v_tot_covered_covpts : natural := 0;
      variable v_tot_covpts         : natural := 0;
      variable v_coverage           : real;
    begin
      for i in 0 to C_FC_MAX_NUM_COVERPOINTS - 1 loop
        if priv_coverpoint_status_list(i).initialized then
          v_tot_covered_covpts := v_tot_covered_covpts + priv_coverpoint_status_list(i).coverage_weight when priv_coverpoint_status_list(i).total_coverage_bin_hits >= priv_coverpoint_status_list(i).total_bin_min_hits;
          v_tot_covpts         := v_tot_covpts + priv_coverpoint_status_list(i).coverage_weight;
        end if;
      end loop;
      v_coverage := real(v_tot_covered_covpts) * 100.0 / real(v_tot_covpts) when v_tot_covpts > 0 else 0.0;
      if cov_representation = GOAL_CAPPED or cov_representation = GOAL_UNCAPPED then
        v_coverage := v_coverage * 100.0 / real(priv_covpts_coverage_goal);
      end if;
      if cov_representation = GOAL_CAPPED and v_coverage > 100.0 then
        v_coverage := 100.0;
      end if;
      return v_coverage;
    end function;

  end protected body t_protected_covergroup_status;
  --------------------------------------------------------------------------------

end package body protected_types_pkg;
