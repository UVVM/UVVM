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
use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.types_pkg.all;
use work.adaptations_pkg.all;
use work.string_methods_pkg.all;

package protected_types_pkg is

  type t_protected_alert_attention_counters is protected
    procedure increment(alert_level : t_alert_level; attention : t_attention := REGARD; number : natural := 1);
    impure function get(alert_level : t_alert_level; attention : t_attention := REGARD) return natural;
    procedure to_string(order : t_order);
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
    procedure increment(check_type : t_check_type; number : natural := 1);
    procedure decrement(check_type : t_check_type; number : integer := 1);
    impure function get(check_type : t_check_type) return natural;
    procedure to_string(order : t_order);
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

  type t_sb_activity is protected
    impure function register_sb(constant name : string; constant instance : natural) return integer;
    procedure increment_sb_element_cnt(constant sb_index : in integer);
    procedure decrement_sb_element_cnt(constant sb_index : in integer; constant value : in natural := 1);
    procedure reset_sb_element_cnt(constant sb_index : in integer);
    procedure enable_sb(constant sb_index : in integer);
    procedure disable_sb(constant sb_index : in integer);
    impure function get_num_registered_sb(constant void : t_void) return natural;
    impure function get_num_enabled_sb(constant void : t_void) return natural;
    impure function get_sb_name(constant sb_index : integer) return string;
    impure function get_sb_instance(constant sb_index : integer) return natural;
    impure function get_sb_element_cnt(constant sb_index : integer) return natural;
    impure function is_enabled(constant sb_index : integer) return boolean;
  end protected t_sb_activity;

  type t_seeds is protected
    procedure set_rand_seeds(constant str : in string; variable seed1 : out positive; variable seed2 : out positive);
    procedure update_and_get_seeds(constant scope : in string; constant instance_name : in string; variable seeds : inout t_positive_vector(0 to 1));
  end protected t_seeds;

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
      variable v_line                            : line;
      variable v_more_than_expected_alerts       : boolean := false;
      variable v_less_than_expected_alerts       : boolean := false;
      variable v_more_than_expected_minor_alerts : boolean := false;
      variable v_less_than_expected_minor_alerts : boolean := false;
      constant C_PREFIX                          : string  := C_LOG_PREFIX & "     ";
    begin
      if order = INTERMEDIATE then
        write(v_line,
              LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
              "*** INTERMEDIATE SUMMARY OF ALL ALERTS ***" & LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
              "                          REGARDED   EXPECTED  IGNORED      Comment?" & LF);
      else                                -- order=FINAL
        write(v_line,
              LF & fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
              "*** FINAL SUMMARY OF ALL ALERTS ***" & LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
              "                          REGARDED   EXPECTED  IGNORED      Comment?" & LF);
      end if;

      for i in NOTE to t_alert_level'right loop
        write(v_line, "          " & to_upper(to_string(i, 13, LEFT)) & ": "); -- Severity
        for j in t_attention'left to t_attention'right loop
          write(v_line, to_string(integer'(priv_alert_attention_counters(i)(j)), 6, RIGHT, KEEP_LEADING_SPACE) & "    ");
        end loop;
        if (priv_alert_attention_counters(i)(REGARD) = priv_alert_attention_counters(i)(EXPECT)) then
          write(v_line, "     ok" & LF);
        else
          write(v_line, "     *** " & to_string(i, 0) & " ***" & LF);
          if (i > MANUAL_CHECK) then
            if (priv_alert_attention_counters(i)(REGARD) < priv_alert_attention_counters(i)(EXPECT)) then
              v_less_than_expected_alerts := true;
            else
              v_more_than_expected_alerts := true;
            end if;
          else
            if (priv_alert_attention_counters(i)(REGARD) < priv_alert_attention_counters(i)(EXPECT)) then
              v_less_than_expected_minor_alerts := true;
            else
              v_more_than_expected_minor_alerts := true;
            end if;
          end if;
        end if;
      end loop;
      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
      -- Print a conclusion when called from the FINAL part of the test sequencer
      -- but not when called from in the middle of the test sequence (order=INTERMEDIATE)
      if order = FINAL then
        if v_more_than_expected_alerts then
          write(v_line, ">> Simulation FAILED, with unexpected serious alert(s)" & LF);
        elsif v_less_than_expected_alerts then
          write(v_line, ">> Simulation FAILED: Mismatch between counted and expected serious alerts" & LF);
        elsif v_more_than_expected_minor_alerts or v_less_than_expected_minor_alerts then
          write(v_line, ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts, but mismatch in minor alerts" & LF);
        else
          write(v_line, ">> Simulation SUCCESS: No mismatch between counted and expected serious alerts" & LF);
        end if;
        write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);
      end if;

      -- Format the report
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);

      -- Write the report to the log destination
      write_line_to_log_destination(v_line);
      deallocate(v_line);
    end;

  end protected body t_protected_alert_attention_counters;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  type t_protected_semaphore is protected body
    variable priv_semaphore_taken : boolean := false;

    impure function get_semaphore return boolean is
    begin
      if priv_semaphore_taken = false then
        -- semaphore was free
        priv_semaphore_taken := true;
        return true;
      else
        -- semaphore was not free
        return false;
      end if;
    end;

    procedure release_semaphore is
    begin
      priv_semaphore_taken := false;
    end procedure;
  end protected body t_protected_semaphore;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  type t_protected_acknowledge_cmd_idx is protected body
    variable priv_idx : integer := -1;

    impure function set_index(index : integer) return boolean is
    begin
      -- for broadcast
      if priv_idx = -1 or priv_idx = index then
        -- index was now set
        priv_idx := index;
        return true;
      else
        -- index was set by another vvc
        return false;
      end if;
    end;

    impure function get_index return integer is
    begin
      return priv_idx;
    end;

    procedure release_index is
    begin
      priv_idx := -1;
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
      variable v_line   : line;
      constant C_PREFIX : string := C_LOG_PREFIX & "     ";
    begin
      if order = INTERMEDIATE then
        write(v_line,
              LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
              "*** INTERMEDIATE SUMMARY OF ALL CHECK COUNTERS ***" & LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
      else                                -- order=FINAL
        write(v_line,
              LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF &
              "*** FINAL SUMMARY OF ALL CHECK COUNTERS ***" & LF &
              fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF);
      end if;

      for i in CHECK_VALUE to t_check_type'right loop
        write(v_line, "          " & to_upper(to_string(i, 22, LEFT)) & ": ");
        write(v_line, to_string(integer'(priv_check_counters(i)), 10, RIGHT, KEEP_LEADING_SPACE) & "    ");
        write(v_line, "" & LF);
      end loop;

      write(v_line, fill_string('=', (C_LOG_LINE_WIDTH - C_PREFIX'length)) & LF & LF);

      -- Format the report
      wrap_lines(v_line, 1, 1, C_LOG_LINE_WIDTH - C_PREFIX'length);
      prefix_lines(v_line, C_PREFIX);

      -- Write the report to the log destination
      write_line_to_log_destination(v_line);
      deallocate(v_line);
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
      constant name           : in string
    ) is
      constant C_NAME_NORMALISED  : string(1 to name'length) := name;
    begin
      if C_NAME_NORMALISED'length > C_FC_MAX_NAME_LENGTH then
        priv_coverpoint_status_list(coverpoint_idx).name := C_NAME_NORMALISED(1 to C_FC_MAX_NAME_LENGTH);
      else
        priv_coverpoint_status_list(coverpoint_idx).name := C_NAME_NORMALISED & fill_string(NUL, C_FC_MAX_NAME_LENGTH - C_NAME_NORMALISED'length);
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
  --------------------------------------------------------------------------------
  type t_sb_activity is protected body

    type t_sb_item is record
      name         : string(1 to C_LOG_SCOPE_WIDTH);
      instance     : natural;
      num_elements : natural;
      enabled      : boolean;
    end record;

    constant C_SB_ITEM_DEFAULT : t_sb_item := (
      name         => (others => NUL),
      instance     => 0,
      num_elements => 0,
      enabled      => false
    );

    type t_sb_array is array (natural range <>) of t_sb_item;

    variable priv_sb_array               : t_sb_array(0 to C_MAX_SB_INDEX) := (others => C_SB_ITEM_DEFAULT);
    variable priv_last_registered_sb_idx : integer                         := -1;
    variable priv_num_enabled_sb         : natural                         := 0;

    impure function register_sb(
      constant name     : string;
      constant instance : natural
    ) return integer is
    begin
      if priv_last_registered_sb_idx < C_MAX_SB_INDEX then
        priv_last_registered_sb_idx                                       := priv_last_registered_sb_idx + 1;
        priv_sb_array(priv_last_registered_sb_idx).name(1 to name'length) := to_upper(name);
        priv_sb_array(priv_last_registered_sb_idx).instance               := instance;
        priv_sb_array(priv_last_registered_sb_idx).num_elements           := 0;
        return priv_last_registered_sb_idx;
      else
        return -1;
      end if;
    end function;

    procedure increment_sb_element_cnt(
      constant sb_index : in integer
    ) is
    begin
      if sb_index >= 0 then
        priv_sb_array(sb_index).num_elements := priv_sb_array(sb_index).num_elements + 1;
      end if;
    end procedure;

    procedure decrement_sb_element_cnt(
      constant sb_index : in integer;
      constant value    : in natural := 1
    ) is
    begin
      if sb_index >= 0 then
        for i in 1 to value loop
          if priv_sb_array(sb_index).num_elements > 0 then
            priv_sb_array(sb_index).num_elements := priv_sb_array(sb_index).num_elements - 1;
          end if;
        end loop;
      end if;
    end procedure;

    procedure reset_sb_element_cnt(
      constant sb_index : in integer
    ) is
    begin
      if sb_index >= 0 then
        priv_sb_array(sb_index).num_elements := 0;
      end if;
    end procedure;

    procedure enable_sb(
      constant sb_index : in integer
    ) is
    begin
      if sb_index >= 0 then
        priv_sb_array(sb_index).enabled := true;
        priv_num_enabled_sb             := priv_num_enabled_sb + 1;
      end if;
    end procedure;

    procedure disable_sb(
      constant sb_index : in integer
    ) is
    begin
      if sb_index >= 0 then
        priv_sb_array(sb_index).enabled := false;
        priv_num_enabled_sb             := priv_num_enabled_sb - 1;
      end if;
    end procedure;

    impure function get_num_registered_sb(
      constant void : t_void
    ) return natural is
    begin
      return priv_last_registered_sb_idx + 1;
    end function;

    impure function get_num_enabled_sb(
      constant void : t_void
    ) return natural is
    begin
      return priv_num_enabled_sb;
    end function;

    impure function get_sb_name(
      constant sb_index : integer
    ) return string is
    begin
      if sb_index >= 0 then
        return to_string(priv_sb_array(sb_index).name);
      else
        return "";
      end if;
    end function;

    impure function get_sb_instance(
      constant sb_index : integer
    ) return natural is
    begin
      if sb_index >= 0 then
        return priv_sb_array(sb_index).instance;
      else
        return 0;
      end if;
    end function;

    impure function get_sb_element_cnt(
      constant sb_index : integer
    ) return natural is
    begin
      if sb_index >= 0 then
        return priv_sb_array(sb_index).num_elements;
      else
        return 0;
      end if;
    end function;

    impure function is_enabled(
      constant sb_index : integer
    ) return boolean is
    begin
      if sb_index >= 0 then
        return priv_sb_array(sb_index).enabled;
      else
        return false;
      end if;
    end function;

  end protected body t_sb_activity;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  type t_seeds is protected body

    type t_seeds_item;

    type t_seeds_array_ptr is access t_seeds_item;

    type t_seeds_id is record
      scope         : string(1 to C_LOG_SCOPE_WIDTH);
      instance_name : string(1 to C_RAND_MAX_INSTANCE_NAME_LENGTH);
      seeds         : t_positive_vector(0 to 1);
    end record;

    type t_seeds_item is record
      seeds_id   : t_seeds_id;
      next_seeds : t_seeds_array_ptr;
    end record;

    variable priv_head : t_seeds_array_ptr; -- Head of the linked list
    variable priv_last_registered_seeds : integer := -1; -- Counter for the number of registered seeds

    -- Set randomization seeds from a string.
    -- Identical to the set_rand_seeds() procedure defined in methods_pkg.
    -- Required to be redefined here to avoid circular dependency.
    procedure set_rand_seeds(
      constant str   : in  string;
      variable seed1 : out positive;
      variable seed2 : out positive
    ) is
      constant C_STR_LEN : natural := str'length;
      constant C_MAX_POS : natural := integer'right;
    begin
      seed1 := C_RAND_INIT_SEED_1;
      seed2 := C_RAND_INIT_SEED_2;
      -- Create the seeds by accumulating the ASCII values of the string,
      -- multiplied by a factor so they are widely spread, and making sure
      -- they don't overflow the positive range.
      for i in 1 to C_STR_LEN / 2 loop
        seed1 := (seed1 + char_to_ascii(str(i)) * 128) mod C_MAX_POS;
      end loop;
        seed2 := (seed2 + seed1) mod C_MAX_POS;
      for i in C_STR_LEN / 2 + 1 to C_STR_LEN loop
        seed2 := (seed2 + char_to_ascii(str(i)) * 128) mod C_MAX_POS;
      end loop;
    end procedure;

    -- Manage randomization seeds using a dictionary-like linked list.
    -- This procedure uses the standard linked list algorithm with scope/instance_name as the keys and seeds as the value in a key-value pair.
    -- If the linked list is empty or the keys are not found, generate new seeds and store them in the linked list.
    -- If the keys are found, generate and update the seeds in the linked list.
    -- The updated seeds are accessible via the inout variable.
    procedure update_and_get_seeds(
      constant scope         : in string;
      constant instance_name : in string;
      variable seeds         : inout t_positive_vector(0 to 1)
    ) is
      variable v_seeds_item : t_seeds_array_ptr;
      variable v_node       : t_seeds_array_ptr;
      variable v_found      : boolean := false;
      variable v_str        : string(1 to scope'length + instance_name'length);
      variable v_rand       : real;
    begin
      -- Linked list is not empty
      if priv_last_registered_seeds > -1 then
        -- Set v_node to the head of the linked list
        v_node := priv_head;
        -- Loop through each node in the linked list
        for idx in 0 to priv_last_registered_seeds loop
          -- Update the seeds if the keys are found in the searched node
          if v_node.seeds_id.scope(1 to scope'length) = scope and v_node.seeds_id.instance_name(1 to instance_name'length) = instance_name then
            v_found := true;
            -- Generate and update the seeds
            uniform(v_node.seeds_id.seeds(0), v_node.seeds_id.seeds(1), v_rand); -- ignore the generated random real number
            -- Assign the updated seeds to the inout variable
            seeds(0) := v_node.seeds_id.seeds(0);
            seeds(1) := v_node.seeds_id.seeds(1);
            exit;
          -- Set the pointer to reference the next node
          elsif v_node.next_seeds /= null then
            v_node := v_node.next_seeds;
          end if;
        end loop;
      end if;

      -- Linked list is empty, or the keys are not found in the linked list
      if priv_last_registered_seeds = -1 or v_found = false then
        -- Concatenate scope and instance_name to create a new string
        v_str := scope & instance_name;
        -- Generate the seeds
        set_rand_seeds(v_str, seeds(0), seeds(1));
        -- Dynamically allocate a new seeds_item and update seeds_id
        v_seeds_item                                                   := new t_seeds_item;
        v_seeds_item.seeds_id.scope(1 to scope'length)                 := scope;
        v_seeds_item.seeds_id.instance_name(1 to instance_name'length) := instance_name;
        v_seeds_item.seeds_id.seeds                                    := seeds;

        -- New seeds_item is appended to the end of the linked list or becomes the head node if the linked list is empty
        if priv_last_registered_seeds = -1 then
          priv_head := v_seeds_item;
        else
          v_node.next_seeds := v_seeds_item;
        end if;

        -- Increment the registered seeds index
        priv_last_registered_seeds := priv_last_registered_seeds + 1;
      end if;
    end procedure;

  end protected body t_seeds;
  --------------------------------------------------------------------------------

end package body protected_types_pkg;
