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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--HDLRegression:TB
entity func_cov_tb is
  generic(
    GC_TESTCASE  : string;
    GC_FILE_PATH : string := ""
  );
end entity;

architecture func of func_cov_tb is

  type t_integer_array is array (natural range <>) of integer_vector;
  type t_cov_bin_type_array is array (natural range <>) of t_cov_bin_type;
  type t_weight_type is (ADAPTIVE, EXPLICIT);

  shared variable shared_coverpoint    : t_coverpoint;
  signal shared_coverpoint_initialized : std_logic := '0';

  constant C_ADAPTIVE_WEIGHT : integer := -1;
  constant C_NULL            : integer := integer'left;

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_coverpoint_a : t_coverpoint;
    variable v_coverpoint_b : t_coverpoint;
    variable v_coverpoint_c : t_coverpoint;
    variable v_coverpoint_d : t_coverpoint;
    variable v_coverpoint_e : t_coverpoint;
    variable v_cross_x2     : t_coverpoint;
    variable v_cross_x2_b   : t_coverpoint;
    variable v_cross_x3     : t_coverpoint;
    variable v_cross_x3_b   : t_coverpoint;
    variable v_cross_x4     : t_coverpoint;
    variable v_cross_x5     : t_coverpoint;
    variable v_cross_x6     : t_coverpoint;
    variable v_cross_x7     : t_coverpoint;
    variable v_cross_x8     : t_coverpoint;
    variable v_cross_x9     : t_coverpoint;
    variable v_cross_x10    : t_coverpoint;
    variable v_cross_x11    : t_coverpoint;
    variable v_cross_x12    : t_coverpoint;
    variable v_cross_x13    : t_coverpoint;
    variable v_cross_x14    : t_coverpoint;
    variable v_cross_x15    : t_coverpoint;

    variable v_bin_idx         : natural := 0;
    variable v_invalid_bin_idx : natural := 0;
    variable v_vector          : std_logic_vector(1 downto 0);
    variable v_rand            : t_rand;
    variable v_seeds           : t_positive_vector(0 to 1);
    variable v_bin_val         : integer;
    variable v_num_bins        : natural;
    variable v_min_hits        : natural;
    variable v_total_min_hits  : real;
    variable v_prev_min_hits   : natural := 0;
    variable v_goal            : natural;
    variable v_value           : integer;
    variable v_values_x2       : integer_vector(0 to 1);
    variable v_values_x3       : integer_vector(0 to 2);

    ------------------------------------------------------------------------------
    -- Procedures and functions
    ------------------------------------------------------------------------------
    -- Checks that the bin information matches the one stored in the coverpoint.
    -- The bin_idx is used to fetch the correct bin from the coverpoint. Note that
    -- there is one index for the valid bins (VAL,RAN,TRN) and another one for the
    -- ignore/illegal bins. The bin_idx will be incremented at the end of the procedure
    -- so that the bins can be checked sequentially.
    procedure check_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type_array;
      constant values      : in t_integer_array;
      constant min_hits    : in natural;
      constant rand_weight : in integer;
      constant name        : in string;
      constant hits        : in natural;
      constant ign_or_ill  : in boolean;
      constant proc_call   : in string) is
      variable v_bin          : t_cov_bin;
      variable v_bin_name_idx : natural;
      variable v_num_values   : natural;
    begin
      check_value(contains'length, values'length, TB_ERROR, "contains must be the same length as values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);

      if not (ign_or_ill) then
        v_bin          := coverpoint.get_valid_bin(bin_idx);
        v_bin_name_idx := bin_idx + coverpoint.get_num_invalid_bins(VOID);
      else
        v_bin          := coverpoint.get_invalid_bin(bin_idx);
        v_bin_name_idx := bin_idx + coverpoint.get_num_valid_bins(VOID);
      end if;

      for i in 0 to values'length - 1 loop
        check_value(v_bin.cross_bins(i).contains = contains(i), ERROR, "Checking bin type. Was: " & to_upper(to_string(v_bin.cross_bins(i).contains)) & ". Expected: " & to_upper(to_string(contains(i))), C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
        v_num_values := 0;
        for j in 0 to values(i)'length - 1 loop
          if values(i)(j) /= C_NULL then
            check_value(v_bin.cross_bins(i).values(j), values(i)(j), ERROR, "Checking bin values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
            v_num_values := v_num_values + 1;
          end if;
        end loop;
        check_value(v_bin.cross_bins(i).num_values, v_num_values, ERROR, "Checking bin number of values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      end loop;
      check_value(v_bin.min_hits, min_hits, ERROR, "Checking bin minimum hits", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      check_value(v_bin.rand_weight, rand_weight, ERROR, "Checking bin randomization weight", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      if name = "" then
        check_value(to_string(v_bin.name), "bin_" & to_string(v_bin_name_idx), ERROR, "Checking bin name", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      else
        check_value(to_string(v_bin.name), name, ERROR, "Checking bin name", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      end if;
      check_value(v_bin.hits, hits, ERROR, "Checking bin hits", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);

      bin_idx := bin_idx + 1;
      log(ID_POS_ACK, proc_call & " => OK, for " & v_bin.name);
    end procedure;

    -- Overload
    procedure check_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type;
      constant values      : in integer_vector;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
      constant C_PROC_NAME : string                                := "check_bin";
      variable v_values    : t_integer_array(0 to 0)(values'range) := (0 => values);
    begin
      check_bin(coverpoint, bin_idx, (0 => contains), v_values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload
    procedure check_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type;
      constant value       : in integer;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
    begin
      check_bin(coverpoint, bin_idx, contains, (0 => value), min_hits, rand_weight, name, hits);
    end procedure;

    -- Overload for crossed bins
    procedure check_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type_array;
      constant values      : in t_integer_array;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
      constant C_PROC_NAME : string := "check_cross_bin";
    begin
      check_bin(coverpoint, bin_idx, contains, values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload for crossed bins
    procedure check_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type_array;
      constant values_1    : in integer_vector;
      constant values_2    : in integer_vector;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
      constant C_PROC_NAME : string                                                    := "check_cross_bin";
      variable v_values    : t_integer_array(0 to 1)(0 to C_FC_MAX_NUM_BIN_VALUES - 1) := (others => (others => C_NULL));
    begin
      v_values(0)(0 to values_1'length - 1) := values_1;
      v_values(1)(0 to values_2'length - 1) := values_2;
      check_bin(coverpoint, bin_idx, contains, v_values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload for crossed bins
    procedure check_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type_array;
      constant values_1    : in integer_vector;
      constant values_2    : in integer_vector;
      constant values_3    : in integer_vector;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
      constant C_PROC_NAME : string                                                    := "check_cross_bin";
      variable v_values    : t_integer_array(0 to 2)(0 to C_FC_MAX_NUM_BIN_VALUES - 1) := (others => (others => C_NULL));
    begin
      v_values(0)(0 to values_1'length - 1) := values_1;
      v_values(1)(0 to values_2'length - 1) := values_2;
      v_values(2)(0 to values_3'length - 1) := values_3;
      check_bin(coverpoint, bin_idx, contains, v_values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload for crossed bins
    procedure check_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type_array;
      constant values_1    : in integer_vector;
      constant values_2    : in integer_vector;
      constant values_3    : in integer_vector;
      constant values_4    : in integer_vector;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
      constant C_PROC_NAME : string                                                    := "check_cross_bin";
      variable v_values    : t_integer_array(0 to 3)(0 to C_FC_MAX_NUM_BIN_VALUES - 1) := (others => (others => C_NULL));
    begin
      v_values(0)(0 to values_1'length - 1) := values_1;
      v_values(1)(0 to values_2'length - 1) := values_2;
      v_values(2)(0 to values_3'length - 1) := values_3;
      v_values(3)(0 to values_4'length - 1) := values_4;
      check_bin(coverpoint, bin_idx, contains, v_values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload for crossed bins
    procedure check_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in t_cov_bin_type_array;
      constant values_1    : in integer_vector;
      constant values_2    : in integer_vector;
      constant values_3    : in integer_vector;
      constant values_4    : in integer_vector;
      constant values_5    : in integer_vector;
      constant min_hits    : in natural := 1;
      constant rand_weight : in integer := C_ADAPTIVE_WEIGHT;
      constant name        : in string  := "";
      constant hits        : in natural := 0) is
      constant C_PROC_NAME : string                                                    := "check_cross_bin";
      variable v_values    : t_integer_array(0 to 4)(0 to C_FC_MAX_NUM_BIN_VALUES - 1) := (others => (others => C_NULL));
    begin
      v_values(0)(0 to values_1'length - 1) := values_1;
      v_values(1)(0 to values_2'length - 1) := values_2;
      v_values(2)(0 to values_3'length - 1) := values_3;
      v_values(3)(0 to values_4'length - 1) := values_4;
      v_values(4)(0 to values_5'length - 1) := values_5;
      check_bin(coverpoint, bin_idx, contains, v_values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload for ignore and illegal bins
    procedure check_invalid_bin(
      variable coverpoint : inout t_coverpoint;
      variable bin_idx    : inout natural;
      constant contains   : in t_cov_bin_type;
      constant values     : in integer_vector;
      constant name       : in string  := "";
      constant hits       : in natural := 0) is
      constant C_PROC_NAME : string                                := "check_invalid_bin";
      variable v_values    : t_integer_array(0 to 0)(values'range) := (0 => values);
    begin
      check_bin(coverpoint, bin_idx, (0 => contains), v_values, 0, 0, name, hits, true, C_PROC_NAME);
    end procedure;

    -- Overload for ignore and illegal bins
    procedure check_invalid_bin(
      variable coverpoint : inout t_coverpoint;
      variable bin_idx    : inout natural;
      constant contains   : in t_cov_bin_type;
      constant value      : in integer;
      constant name       : in string  := "";
      constant hits       : in natural := 0) is
    begin
      check_invalid_bin(coverpoint, bin_idx, contains, (0 => value), name, hits);
    end procedure;

    -- Overload for ignore and illegal crossed bins
    procedure check_invalid_cross_bin(
      variable coverpoint : inout t_coverpoint;
      variable bin_idx    : inout natural;
      constant contains   : in t_cov_bin_type_array;
      constant values_1   : in integer_vector;
      constant values_2   : in integer_vector;
      constant name       : in string  := "";
      constant hits       : in natural := 0) is
      constant C_PROC_NAME : string                                                                      := "check_invalid_cross_bin";
      variable v_values    : t_integer_array(0 to 1)(0 to MAXIMUM(values_1'length, values_2'length) - 1) := (others => (others => C_NULL));
    begin
      v_values(0)(0 to values_1'length - 1) := values_1;
      v_values(1)(0 to values_2'length - 1) := values_2;
      check_bin(coverpoint, bin_idx, contains, v_values, 0, 0, name, hits, true, C_PROC_NAME);
    end procedure;

    -- Checks the number of bins in the coverpoint
    procedure check_num_bins(
      variable coverpoint       : inout t_coverpoint;
      constant num_valid_bins   : in natural;
      constant num_invalid_bins : in natural) is
      constant C_PROC_NAME : string := "check_num_bins";
    begin
      check_value(coverpoint.get_num_valid_bins(VOID), num_valid_bins, ERROR, "Checking number of valid bins", caller_name => C_PROC_NAME);
      check_value(coverpoint.get_num_invalid_bins(VOID), num_invalid_bins, ERROR, "Checking number of invalid bins", caller_name => C_PROC_NAME);
    end procedure;

    -- Samples several values in the coverpoint a number of times
    procedure sample_bins(
      variable coverpoint  : inout t_coverpoint;
      constant values      : in integer_vector;
      constant num_samples : in positive := 1) is
    begin
      for i in 1 to num_samples loop
        for j in values'range loop
          coverpoint.sample_coverage(values(j));
        end loop;
      end loop;
    end procedure;

    -- Overload
    procedure sample_bins(
      variable coverpoint  : inout t_coverpoint;
      constant value       : in integer;
      constant num_samples : in positive := 1) is
    begin
      sample_bins(coverpoint, (0 => value), num_samples);
    end procedure;

    -- Overload
    procedure sample_cross_bins(
      variable coverpoint  : inout t_coverpoint;
      constant values      : in t_integer_array;
      constant num_samples : in positive := 1) is
    begin
      for i in 1 to num_samples loop
        for j in values'range loop
          coverpoint.sample_coverage(values(j));
        end loop;
      end loop;
    end procedure;

    -- Checks the bins coverage in the coverpoint
    procedure check_bins_coverage(
      variable coverpoint : inout t_coverpoint;
      constant coverage   : in real;
      constant use_goal   : in boolean := false) is
      constant C_PROC_NAME : string := "check_bins_coverage" & return_string_if_true("(% of goal)", use_goal);
    begin
      -- Use string representation to round the real number
      if to_string(coverpoint.get_coverage(BINS, use_goal), 2) /= to_string(coverage, 2) then
        alert(ERROR, C_PROC_NAME & " => Failed, for " & to_string(coverpoint.get_coverage(BINS, use_goal), 2) & "%, expected " & to_string(coverage, 2) & "%");
        return;
      end if;
      if coverpoint.coverage_completed(BINS) and coverage = 100.0 then
        log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_string(coverage, 2) & "% - Coverage completed");
      elsif not (coverpoint.coverage_completed(BINS)) and coverage < 100.0 then
        log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_string(coverage, 2) & "%");
      else
        alert(ERROR, C_PROC_NAME & " => Failed, coverage_completed() returned wrong value: " & to_upper(to_string(coverpoint.coverage_completed(BINS))));
      end if;
    end procedure;

    -- Checks the hits coverage in the coverpoint
    procedure check_hits_coverage(
      variable coverpoint : inout t_coverpoint;
      constant coverage   : in real;
      constant use_goal   : in boolean := false) is
      constant C_PROC_NAME : string := "check_hits_coverage" & return_string_if_true("(% of goal)", use_goal);
    begin
      -- Use string representation to round the real number
      if to_string(coverpoint.get_coverage(HITS, use_goal), 2) /= to_string(coverage, 2) then
        alert(ERROR, C_PROC_NAME & " => Failed, for " & to_string(coverpoint.get_coverage(HITS, use_goal), 2) & "%, expected " & to_string(coverage, 2) & "%");
        return;
      end if;
      if coverpoint.coverage_completed(HITS) and coverage = 100.0 then
        log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_string(coverage, 2) & "% - Coverage completed");
      elsif not (coverpoint.coverage_completed(HITS)) and coverage < 100.0 then
        log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_string(coverage, 2) & "%");
      else
        alert(ERROR, C_PROC_NAME & " => Failed, coverage_completed() returned wrong value: " & to_upper(to_string(coverpoint.coverage_completed(HITS))));
      end if;
    end procedure;

    -- Checks that the bins and hits coverage is complete
    procedure check_coverage_completed(
      variable coverpoint : inout t_coverpoint;
      constant use_goal   : in boolean := false) is
    begin
      check_bins_coverage(coverpoint, 100.0, use_goal);
      check_hits_coverage(coverpoint, 100.0, use_goal);
    end procedure;

    -- Checks that the number of hits from a bin in the coverpoint
    -- is greater than a certain value
    procedure check_bin_hits_is_greater(
      variable coverpoint : inout t_coverpoint;
      constant bin_idx    : in natural;
      constant min_hits   : in natural) is
      constant C_PROC_NAME : string := "check_bin_hits_is_greater";
      variable v_bin       : t_cov_bin;
    begin
      v_bin := coverpoint.get_valid_bin(bin_idx);
      check_value(v_bin.hits > min_hits, ERROR, "Checking " & v_bin.name & " was selected for randomization",
                  C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
    end procedure;

    -- Generates and samples enough random numbers to cover the min_hits for all the valid bins.
    -- Checks that the randomization follows the weighted distribution by checking at which
    -- iteration number each bin was covered.
    procedure randomize_and_check_distribution(
      variable coverpoint            : inout t_coverpoint;
      constant weight_type           : in t_weight_type;
      constant bin_covered_iteration : in integer_vector) is
      type t_test_bin is record
        value     : natural;
        min_hits  : natural;
        iteration : natural;
        counter   : natural;
      end record;
      type t_test_bin_array is array (natural range <>) of t_test_bin;
      constant C_PROC_NAME        : string                                                  := "randomize_and_check_distribution";
      variable v_bin_vector       : t_cov_bin_vector(0 to coverpoint.get_num_valid_bins(VOID) - 1);
      variable v_hits_goal        : natural                                                 := coverpoint.get_hits_coverage_goal(VOID);
      variable v_test_bins        : t_test_bin_array(0 to bin_covered_iteration'length - 1) := (others => (others => 0));
      variable v_idx              : natural                                                 := 0;
      variable v_total_iterations : natural                                                 := 0;
      variable v_margin           : natural;
      variable v_rand_val         : integer_vector(0 to coverpoint.get_num_bins_crossed(VOID) - 1);
    begin
      -- Copy the necessary information to the test vector
      v_bin_vector := coverpoint.get_valid_bins(VOID);
      for i in 0 to v_bin_vector'length - 1 loop
        check_value(v_idx < bin_covered_iteration'length, TB_ERROR, "bin_covered_iteration length must be the same size as the number of bins to randomize", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
        v_test_bins(v_idx).value     := v_bin_vector(i).cross_bins(0).values(0); -- Only use the first value to simplify the check (we assume all bins first values are different)
        v_test_bins(v_idx).min_hits  := (v_bin_vector(i).min_hits * v_hits_goal) / 100;
        v_test_bins(v_idx).iteration := (bin_covered_iteration(v_idx) * v_hits_goal) / 100;
        v_total_iterations           := v_total_iterations + v_test_bins(v_idx).min_hits;
        v_idx                        := v_idx + 1;
      end loop;
      check_value(v_idx, bin_covered_iteration'length, TB_ERROR, "bin_covered_iteration length must be the same size as the number of bins to randomize", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);

      log("Generating " & to_string(v_total_iterations) & " random values");
      v_margin := integer(real(v_total_iterations) * 0.10) when weight_type = ADAPTIVE else
                  integer(real(v_total_iterations) * 0.15); -- EXPLICIT
      for i in 1 to v_total_iterations loop
        v_rand_val := coverpoint.rand(SAMPLE_COV);

        for j in v_test_bins'range loop
          if v_rand_val(0) = v_test_bins(j).value then
            v_test_bins(j).counter := v_test_bins(j).counter + 1;
          end if;
          if v_test_bins(j).counter = v_test_bins(j).min_hits then
            check_value_in_range(i, v_test_bins(j).iteration - v_margin, v_test_bins(j).iteration + v_margin, ERROR, "Bin " & to_string(j) & " covered in expected iteration", C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
            v_test_bins(j).counter := 0;
          end if;
        end loop;
      end loop;

      -- Check all bins were covered with the exact number of hits
      for i in v_test_bins'range loop
        check_value(v_test_bins(i).counter, 0, ERROR, "Bin value was generated more times than expected", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      end loop;
    end procedure;

    -- Overload
    procedure delete_coverpoint(
      variable coverpoint : inout t_coverpoint) is
    begin
      coverpoint.delete_coverpoint(VOID);
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
    end procedure;

    procedure load_coverage_db_quiet (
      variable coverpoint       : inout t_coverpoint;
      constant path             : in string;
      constant report_verbosity : in t_report_verbosity := HOLES_ONLY
    ) is
    begin
      disable_log_msg(ID_FUNC_COV_CONFIG, QUIET);
      coverpoint.load_coverage_db(path, report_verbosity => report_verbosity);
      enable_log_msg(ID_FUNC_COV_CONFIG, QUIET);
    end procedure;

    procedure write_coverage_db_quiet (
      variable coverpoint : inout t_coverpoint;
      constant path       : in string
    ) is
    begin
      disable_log_msg(ID_FUNC_COV_CONFIG, QUIET);
      coverpoint.write_coverage_db(path);
      enable_log_msg(ID_FUNC_COV_CONFIG, QUIET);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Functional Coverage package - " & GC_TESTCASE);
    -------------------------------------------------------------------------------------------
    enable_log_msg(ID_FUNC_COV_BINS);
    enable_log_msg(ID_FUNC_COV_BINS_INFO);
    enable_log_msg(ID_FUNC_COV_RAND);
    enable_log_msg(ID_FUNC_COV_SAMPLE);
    enable_log_msg(ID_FUNC_COV_CONFIG);

    --===================================================================================
    if GC_TESTCASE = "fc_bins" then
      --===================================================================================
      shared_coverpoint.set_name("MY_COVERPOINT");
      check_value(shared_coverpoint.get_name(VOID), "MY_COVERPOINT", ERROR, "Checking name");
      shared_coverpoint.set_scope("MY_SCOPE");
      check_value(shared_coverpoint.get_scope(VOID), "MY_SCOPE", ERROR, "Checking scope");

      shared_coverpoint.set_num_allocated_bins(40);
      shared_coverpoint.set_num_allocated_bins_increment(5);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Wait 100 ns until the coverpoint is initialized");
      ------------------------------------------------------------
      wait for 100 ns;

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with single values");
      ------------------------------------------------------------
      shared_coverpoint.add_bins(bin(-101));
      shared_coverpoint.add_bins(bin(-100));
      shared_coverpoint.add_bins(bin(100));
      shared_coverpoint.add_bins(bin(101));
      gen_pulse(shared_coverpoint_initialized, 0 ns, "Unblocking p_sampling process", msg_id => ID_NEVER);
      wait for 0 ns;                    -- Wait a delta cycle so that p_sampling can finish

      check_bin(shared_coverpoint, v_bin_idx, VAL, -101);
      check_bin(shared_coverpoint, v_bin_idx, VAL, -100);
      check_bin(shared_coverpoint, v_bin_idx, VAL, 100);
      check_bin(shared_coverpoint, v_bin_idx, VAL, 101);

      sample_bins(shared_coverpoint, (-101, -100, 100, 101), 1);
      sample_bins(shared_coverpoint, (-103, -102, 102, 103), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 4;
      check_bin(shared_coverpoint, v_bin_idx, VAL, -101, hits => 1);
      check_bin(shared_coverpoint, v_bin_idx, VAL, -100, hits => 1);
      check_bin(shared_coverpoint, v_bin_idx, VAL, 100, hits => 1);
      check_bin(shared_coverpoint, v_bin_idx, VAL, 101, hits => 1);

      delete_coverpoint(shared_coverpoint);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with multiple values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin((202, 204, 206, 208)));
      v_coverpoint_a.add_bins(bin((210, 211, 212, 213, 214, 215, 216, 217, 218, 219)));
      increment_expected_alerts(TB_WARNING, 1);
      v_coverpoint_a.add_bins(bin((220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_bin(v_coverpoint_a, v_bin_idx, VAL, (202, 204, 206, 208));
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (210, 211, 212, 213, 214, 215, 216, 217, 218, 219));
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (220, 221, 222, 223, 224, 225, 226, 227, 228, 229));

      sample_bins(v_coverpoint_a, (202, 204, 206, 208), 1);
      sample_bins(v_coverpoint_a, (210, 211, 212, 213, 214, 215, 216, 217, 218, 219), 1);
      sample_bins(v_coverpoint_a, (220, 221, 222, 223, 224, 225, 226, 227, 228, 229), 1);
      sample_bins(v_coverpoint_a, (201, 203, 205, 207, 209, 230), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 3;
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (202, 204, 206, 208), hits => 4);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (210, 211, 212, 213, 214, 215, 216, 217, 218, 219), hits => 10);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (220, 221, 222, 223, 224, 225, 226, 227, 228, 229), hits => 10);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with ranges of values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_range(300, 309));
      v_coverpoint_a.add_bins(bin_range(311, 315, 2));
      v_coverpoint_a.add_bins(bin_range(320, 328, 3));
      v_coverpoint_a.add_bins(bin_range(330, 334, 20));
      v_coverpoint_a.add_bins(bin_range(341, 343, 0));
      v_coverpoint_a.add_bins(bin_range(355, 355));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_coverpoint_a.add_bins(bin_range(363, 361));

      check_bin(v_coverpoint_a, v_bin_idx, RAN, (300, 309));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (311, 312));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (313, 315));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (320, 322));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (323, 325));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (326, 328));
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 330);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 331);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 332);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 333);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 334);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 341);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 342);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 343);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 355);

      sample_bins(v_coverpoint_a, (300, 301, 302, 303, 304, 305, 306, 307, 308, 309), 1);
      sample_bins(v_coverpoint_a, (311, 312, 313, 314, 315), 1);
      sample_bins(v_coverpoint_a, (320, 321, 322, 323, 324, 325, 326, 327, 328), 1);
      sample_bins(v_coverpoint_a, (330, 331, 332, 333, 334), 1);
      sample_bins(v_coverpoint_a, (341, 342, 343), 1);
      sample_bins(v_coverpoint_a, (355), 1);
      sample_bins(v_coverpoint_a, (310, 316, 317, 318, 319, 329, 335, 340, 344, 354, 356), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 15;
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (300, 309), hits => 10);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (311, 312), hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (313, 315), hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (320, 322), hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (323, 325), hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (326, 328), hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 330, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 331, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 332, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 333, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 334, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 341, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 342, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 343, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 355, hits => 1);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins created from a vector");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_vector(v_vector));
      v_coverpoint_a.add_bins(bin_vector(v_vector, 2));
      v_coverpoint_a.add_bins(bin_vector(v_vector, 3));
      v_coverpoint_a.add_bins(bin_vector(v_vector, 20));
      v_coverpoint_a.add_bins(bin_vector(v_vector, 0));

      check_bin(v_coverpoint_a, v_bin_idx, RAN, (0, 3));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (0, 1));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (2, 3));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (0, 0));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (1, 1));
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (2, 3));
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 0);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 3);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 0);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 3);

      sample_bins(v_coverpoint_a, (0, 1, 2, 3), 1);
      sample_bins(v_coverpoint_a, (-1, 4, 5, 6), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 14;
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (0, 3), hits => 4);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (0, 1), hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (2, 3), hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (0, 0), hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (1, 1), hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (2, 3), hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 0, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 3, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 0, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2, hits => 1);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 3, hits => 1);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_transition((401, 403, 401)));
      v_coverpoint_a.add_bins(bin_transition((401, 403, 401, 409)));
      v_coverpoint_a.add_bins(bin_transition((410, 410, 410, 418, 415, 415, 410)));
      v_coverpoint_a.add_bins(bin_transition((420, 421, 422, 423, 424, 425, 426, 427, 428, 429)));
      increment_expected_alerts(TB_WARNING, 1);
      v_coverpoint_a.add_bins(bin_transition((430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_bin(v_coverpoint_a, v_bin_idx, TRN, (401, 403, 401));
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (401, 403, 401, 409));
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (410, 410, 410, 418, 415, 415, 410));
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (420, 421, 422, 423, 424, 425, 426, 427, 428, 429));
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (430, 431, 432, 433, 434, 435, 436, 437, 438, 439));

      sample_bins(v_coverpoint_a, (401, 403, 401, 409), 2);
      sample_bins(v_coverpoint_a, (401, 403, 401, 403, 401, 409), 2);
      sample_bins(v_coverpoint_a, (401, 403, 401, 403, 401, 403, 401, 409), 2);
      sample_bins(v_coverpoint_a, (401, 403, 401, 401, 403, 401, 409), 2);
      sample_bins(v_coverpoint_a, (410, 410, 410, 418, 415, 415, 410), 3);
      sample_bins(v_coverpoint_a, (420, 421, 422, 423, 424, 425, 426, 427, 428, 429), 3);
      sample_bins(v_coverpoint_a, (430, 431, 432, 433, 434, 435, 436, 437, 438, 439), 3);
      sample_bins(v_coverpoint_a, (410, 410, 410, 418, 415, 414, 410), 1); -- Sample values outside bins
      sample_bins(v_coverpoint_a, (420, 421, 422, 423, 424, 425, 426, 427, 428, 430), 1); -- Sample values outside bins
      sample_bins(v_coverpoint_a, (430, 431, 432, 433, 434, 435, 436, 437, 438, 440), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 5;
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (401, 403, 401), hits => 12);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (401, 403, 401, 409), hits => 8);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (410, 410, 410, 418, 415, 415, 410), hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (420, 421, 422, 423, 424, 425, 426, 427, 428, 429), hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (430, 431, 432, 433, 434, 435, 436, 437, 438, 439), hits => 3);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore bins with single values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(ignore_bin(-2001));
      v_coverpoint_a.add_bins(ignore_bin(-2000));
      v_coverpoint_a.add_bins(ignore_bin(2000));
      v_coverpoint_a.add_bins(ignore_bin(2001));

      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, -2001);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, -2000);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2000);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2001);

      sample_bins(v_coverpoint_a, (-2001, -2000, 2000, 2001), 1);
      sample_bins(v_coverpoint_a, (-2003, -2002, 2002, 2003), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 4;
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, -2001, hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, -2000, hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2000, hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2001, hits => 1);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore bins with ranges of values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(ignore_bin_range(2100, 2109));
      v_coverpoint_a.add_bins(ignore_bin_range(2115, 2115));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_coverpoint_a.add_bins(ignore_bin_range(2129, 2126));

      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (2100, 2109));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2115);

      sample_bins(v_coverpoint_a, (2100, 2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109), 1);
      sample_bins(v_coverpoint_a, (2115), 1);
      sample_bins(v_coverpoint_a, (2110, 2111, 2114, 2116), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 2;
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (2100, 2109), hits => 10);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2115, hits => 1);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(ignore_bin_transition((2201, 2203, 2201)));
      v_coverpoint_a.add_bins(ignore_bin_transition((2201, 2203, 2201, 2209)));
      v_coverpoint_a.add_bins(ignore_bin_transition((2210, 2210, 2210, 2218, 2215, 2215, 2210)));
      increment_expected_alerts(TB_WARNING, 1);
      v_coverpoint_a.add_bins(ignore_bin_transition((2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2229, 2230))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2201, 2203, 2201));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2201, 2203, 2201, 2209));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2210, 2210, 2210, 2218, 2215, 2215, 2210));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2229));

      sample_bins(v_coverpoint_a, (2201, 2203, 2201, 2209), 2);
      sample_bins(v_coverpoint_a, (2201, 2203, 2201, 2203, 2201, 2209), 2);
      sample_bins(v_coverpoint_a, (2201, 2203, 2201, 2203, 2201, 2203, 2201, 2209), 2);
      sample_bins(v_coverpoint_a, (2201, 2203, 2201, 2201, 2203, 2201, 2209), 2);
      sample_bins(v_coverpoint_a, (2210, 2210, 2210, 2218, 2215, 2215, 2210), 3);
      sample_bins(v_coverpoint_a, (2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2229), 3);
      sample_bins(v_coverpoint_a, (2210, 2210, 2210, 2218, 2215, 2214, 2210), 1); -- Sample values outside bins
      sample_bins(v_coverpoint_a, (2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2230), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 4;
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2201, 2203, 2201), hits => 12);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2201, 2203, 2201, 2209), hits => 8);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2210, 2210, 2210, 2218, 2215, 2215, 2210), hits => 3);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2220, 2221, 2222, 2223, 2224, 2225, 2226, 2227, 2228, 2229), hits => 3);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal bins with single values");
      ------------------------------------------------------------
      v_coverpoint_a.set_illegal_bin_alert_level(WARNING);
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");

      v_coverpoint_a.add_bins(illegal_bin(-3001));
      v_coverpoint_a.add_bins(illegal_bin(-3000));
      v_coverpoint_a.add_bins(illegal_bin(3000));
      v_coverpoint_a.add_bins(illegal_bin(3001));

      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, -3001);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, -3000);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3000);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3001);

      increment_expected_alerts(WARNING, 4);
      sample_bins(v_coverpoint_a, (-3001, -3000, 3000, 3001), 1);
      sample_bins(v_coverpoint_a, (-3003, -3002, 3002, 3003), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 4;
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, -3001, hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, -3000, hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3000, hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3001, hits => 1);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal bins with ranges of values");
      ------------------------------------------------------------
      v_coverpoint_a.set_illegal_bin_alert_level(WARNING);
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");

      v_coverpoint_a.add_bins(illegal_bin_range(3100, 3109));
      v_coverpoint_a.add_bins(illegal_bin_range(3115, 3115));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_coverpoint_a.add_bins(illegal_bin_range(3129, 3126));

      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (3100, 3109));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3115);

      increment_expected_alerts(WARNING, 11);
      sample_bins(v_coverpoint_a, (3100, 3101, 3102, 3103, 3104, 3105, 3106, 3107, 3108, 3109), 1);
      sample_bins(v_coverpoint_a, (3115), 1);
      sample_bins(v_coverpoint_a, (3110, 3111, 3114, 3116), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 2;
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (3100, 3109), hits => 10);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3115, hits => 1);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint_a.set_illegal_bin_alert_level(WARNING);
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");

      v_coverpoint_a.add_bins(illegal_bin_transition((3201, 3203, 3201)));
      v_coverpoint_a.add_bins(illegal_bin_transition((3201, 3203, 3201, 3209)));
      v_coverpoint_a.add_bins(illegal_bin_transition((3210, 3210, 3210, 3218, 3215, 3215, 3210)));
      increment_expected_alerts(TB_WARNING, 1);
      v_coverpoint_a.add_bins(illegal_bin_transition((3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3229, 3230))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3201, 3203, 3201));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3201, 3203, 3201, 3209));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3210, 3210, 3210, 3218, 3215, 3215, 3210));
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3229));

      increment_expected_alerts(WARNING, 26);
      sample_bins(v_coverpoint_a, (3201, 3203, 3201, 3209), 2);
      sample_bins(v_coverpoint_a, (3201, 3203, 3201, 3203, 3201, 3209), 2);
      sample_bins(v_coverpoint_a, (3201, 3203, 3201, 3203, 3201, 3203, 3201, 3209), 2);
      sample_bins(v_coverpoint_a, (3201, 3203, 3201, 3201, 3203, 3201, 3209), 2);
      sample_bins(v_coverpoint_a, (3210, 3210, 3210, 3218, 3215, 3215, 3210), 3);
      sample_bins(v_coverpoint_a, (3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3229), 3);
      sample_bins(v_coverpoint_a, (3210, 3210, 3210, 3218, 3215, 3214, 3210), 1); -- Sample values outside bins
      sample_bins(v_coverpoint_a, (3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3230), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 4;
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3201, 3203, 3201), hits => 12);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3201, 3203, 3201, 3209), hits => 8);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3210, 3210, 3210, 3218, 3215, 3215, 3210), hits => 3);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3220, 3221, 3222, 3223, 3224, 3225, 3226, 3227, 3228, 3229), hits => 3);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing concatenation of bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(4000) & bin((4100, 4110, 4120)) & bin_range(4200, 4209, 2) & bin_transition((4300, 4302, 4304, 4305)), "concatenated");
      v_coverpoint_a.add_bins(bin_range(4400, 4450) & ignore_bin(4401) & ignore_bin_range(4410, 4420) & ignore_bin_transition((4400, 4425, 4450)), "concatenated");

      check_bin(v_coverpoint_a, v_bin_idx, VAL, 4000, name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (4100, 4110, 4120), name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (4200, 4204), name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (4205, 4209), name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (4300, 4302, 4304, 4305), name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (4400, 4450), name => "concatenated");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 4401, name => "concatenated");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (4410, 4420), name => "concatenated");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (4400, 4425, 4450), name => "concatenated");

      sample_bins(v_coverpoint_a, (4000), 1);
      sample_bins(v_coverpoint_a, (4100, 4110, 4120), 1);
      sample_bins(v_coverpoint_a, (4200, 4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4209), 1);
      sample_bins(v_coverpoint_a, (4300, 4302, 4304, 4305), 1);
      sample_bins(v_coverpoint_a, (4400, 4402, 4449, 4450), 1);
      sample_bins(v_coverpoint_a, (4401, 4410, 4420, 4400, 4425, 4450), 1); -- Sample ignore bins (note that first 2 values of transition are valid bins)

      v_bin_idx         := v_bin_idx - 6;
      v_invalid_bin_idx := v_invalid_bin_idx - 3;
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 4000, hits => 1, name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (4100, 4110, 4120), hits => 3, name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (4200, 4204), hits => 5, name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (4205, 4209), hits => 5, name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (4300, 4302, 4304, 4305), hits => 1, name => "concatenated");
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (4400, 4450), hits => 6, name => "concatenated");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 4401, hits => 1, name => "concatenated");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (4410, 4420), hits => 2, name => "concatenated");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (4400, 4425, 4450), hits => 1, name => "concatenated");

      check_num_bins(v_coverpoint_a, v_bin_idx, v_invalid_bin_idx);
      check_coverage_completed(v_coverpoint_a);
      v_coverpoint_a.report_coverage(VERBOSE);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins and ignore bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_transition((5000, 5001, 5010)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5001, 5020)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5001, 5030)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5002, 5010)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5002, 5020)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5002, 5030)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5003, 5010)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5003, 5020)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5003, 5030)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5004, 5010)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5004, 5020)), "transition");
      v_coverpoint_a.add_bins(bin_transition((5000, 5004, 5030)), "transition");
      v_coverpoint_a.add_bins(ignore_bin_transition((5000, 5001, 5010)), "ignore_transition");
      v_coverpoint_a.add_bins(ignore_bin_transition((5000, 5002)), "ignore_transition");
      v_coverpoint_a.add_bins(ignore_bin_transition((5003, 5010)), "ignore_transition");
      v_coverpoint_a.add_bins(ignore_bin(5004), "ignore_value");

      sample_bins(v_coverpoint_a, (5000, 5001, 5010), 1);
      sample_bins(v_coverpoint_a, (5000, 5001, 5020), 1);
      sample_bins(v_coverpoint_a, (5000, 5001, 5030), 1);
      sample_bins(v_coverpoint_a, (5000, 5002, 5010), 1);
      sample_bins(v_coverpoint_a, (5000, 5002, 5020), 1);
      sample_bins(v_coverpoint_a, (5000, 5002, 5030), 1);
      sample_bins(v_coverpoint_a, (5000, 5003, 5010), 1);
      sample_bins(v_coverpoint_a, (5000, 5003, 5020), 1);
      sample_bins(v_coverpoint_a, (5000, 5003, 5030), 1);
      sample_bins(v_coverpoint_a, (5000, 5004, 5010), 1);
      sample_bins(v_coverpoint_a, (5000, 5004, 5020), 1);
      sample_bins(v_coverpoint_a, (5000, 5004, 5030), 1);

      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5001, 5010), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5001, 5020), hits => 1, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5001, 5030), hits => 1, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5002, 5010), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5002, 5020), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5002, 5030), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5003, 5010), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5003, 5020), hits => 1, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5003, 5030), hits => 1, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5004, 5010), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5004, 5020), hits => 0, name => "transition");
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (5000, 5004, 5030), hits => 0, name => "transition");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (5000, 5001, 5010), hits => 1, name => "ignore_transition");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (5000, 5002), hits => 3, name => "ignore_transition");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (5003, 5010), hits => 1, name => "ignore_transition");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 5004, hits => 3, name => "ignore_value");

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing minimum coverage");
      ------------------------------------------------------------
      increment_expected_alerts(TB_WARNING, 9); -- For adding bins after sampling warnings
      for i in 1 to 10 loop
        v_bin_val  := v_rand.rand(100, 500);
        v_min_hits := v_rand.rand(1, 20);
        v_coverpoint_a.add_bins(bin(v_bin_val), v_min_hits);

        check_bin(v_coverpoint_a, v_bin_idx, VAL, v_bin_val, v_min_hits);

        -- Check the coverage increases when the bin is sampled until it is 100%
        for j in 0 to v_min_hits - 1 loop
          check_bins_coverage(v_coverpoint_a, 100.0 * real(i - 1) / real(i));
          check_hits_coverage(v_coverpoint_a, 100.0 * real(j + v_prev_min_hits) / real(v_min_hits + v_prev_min_hits));
          sample_bins(v_coverpoint_a, v_bin_val, 1);
        end loop;
        check_coverage_completed(v_coverpoint_a);

        v_bin_idx       := v_bin_idx - 1;
        check_bin(v_coverpoint_a, v_bin_idx, VAL, v_bin_val, v_min_hits, hits => v_min_hits);
        v_prev_min_hits := v_prev_min_hits + v_min_hits;
      end loop;

      v_coverpoint_a.report_coverage(VERBOSE);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin names");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(1000));
      v_coverpoint_a.add_bins(bin(1001), "my_bin_1");
      v_coverpoint_a.add_bins(bin(1002), 5, "my_bin_2");
      v_coverpoint_a.add_bins(bin(1003), 5, 1, "my_bin_3");
      v_coverpoint_a.add_bins(bin(1004), 5, 1, "my_bin_long_name_abcdefghijklmno"); -- C_FC_MAX_NAME_LENGTH = 20

      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1000);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1001, name => "my_bin_1");
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1002, 5, name => "my_bin_2");
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1003, 5, 1, name => "my_bin_3");
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 1004, 5, 1, name => "my_bin_long_name_abc");

      v_coverpoint_a.report_coverage(VERBOSE);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin overlap - valid bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(2000));
      v_coverpoint_a.add_bins(bin(2000));
      v_coverpoint_a.add_bins(bin(2000));
      v_coverpoint_a.add_bins(bin((2100, 2101, 2102, 2113, 2114)));
      v_coverpoint_a.add_bins(bin((2114, 2115, 2116, 2117)));
      v_coverpoint_a.add_bins(bin_range(2200, 2250));
      v_coverpoint_a.add_bins(bin_range(2249, 2299));

      sample_bins(v_coverpoint_a, (2000, 2001), 1);
      sample_bins(v_coverpoint_a, (2113, 2114, 2115), 1);
      sample_bins(v_coverpoint_a, (2248, 2249, 2250, 2251), 1);

      v_coverpoint_a.set_bin_overlap_alert_level(TB_WARNING);
      check_value(v_coverpoint_a.get_bin_overlap_alert_level(VOID) = TB_WARNING, ERROR, "Checking bin overlap alert level");
      increment_expected_alerts(TB_WARNING, 4);
      sample_bins(v_coverpoint_a, (2000, 2001), 1);
      sample_bins(v_coverpoint_a, (2113, 2114, 2115), 1);
      sample_bins(v_coverpoint_a, (2248, 2249, 2250, 2251), 1);

      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2000, hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2000, hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 2000, hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (2100, 2101, 2102, 2113, 2114), hits => 4);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (2114, 2115, 2116, 2117), hits => 4);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (2200, 2250), hits => 6);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (2249, 2299), hits => 6);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin overlap - valid and ignore bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_range(3000, 3020), "overlap");
      v_coverpoint_a.add_bins(ignore_bin_range(3005, 3015));

      sample_bins(v_coverpoint_a, (3000, 3004, 3005, 3006, 3014, 3015, 3016, 3020), 1);

      check_bin(v_coverpoint_a, v_bin_idx, RAN, (3000, 3020), hits => 4, name => "overlap");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (3005, 3015), hits => 4);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin overlap - valid and illegal bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_range(3100, 3120), "overlap");
      v_coverpoint_a.add_bins(illegal_bin_range(3105, 3115));

      v_coverpoint_a.set_illegal_bin_alert_level(WARNING);
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");
      increment_expected_alerts(WARNING, 4);
      sample_bins(v_coverpoint_a, (3100, 3104, 3105, 3106, 3114, 3115, 3116, 3120), 1);

      check_bin(v_coverpoint_a, v_bin_idx, RAN, (3100, 3120), hits => 4, name => "overlap");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (3105, 3115), hits => 4);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin overlap - ignore and illegal bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(ignore_bin_range(3200, 3220));
      v_coverpoint_a.add_bins(illegal_bin_range(3205, 3215));

      v_coverpoint_a.set_illegal_bin_alert_level(WARNING);
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");
      increment_expected_alerts(WARNING, 4);
      sample_bins(v_coverpoint_a, (3200, 3204, 3205, 3206, 3214, 3215, 3216, 3220), 1);

      -- Illegal bin takes precedence over ignore bin, even though both are counted
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (3200, 3220), hits => 8);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (3205, 3215), hits => 4);

      v_coverpoint_a.report_coverage(VERBOSE);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverpoint name and scope");
      ------------------------------------------------------------
      v_coverpoint_a.set_name("MY_COVERPOINT_2_abcdefghiklmno"); -- C_FC_MAX_NAME_LENGTH = 20
      check_value(v_coverpoint_a.get_name(VOID), "MY_COVERPOINT_2_abcd", ERROR, "Checking name");
      v_coverpoint_a.set_scope("MY_SCOPE_2");
      check_value(v_coverpoint_a.get_scope(VOID), "MY_SCOPE_2", ERROR, "Checking scope");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverpoint num bins allocation error");
      ------------------------------------------------------------
      v_coverpoint_a.set_num_allocated_bins(50);
      v_coverpoint_a.set_num_allocated_bins(10);
      v_coverpoint_a.add_bins(bin_range(1, 10, 10));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_coverpoint_a.set_num_allocated_bins(5);

      delete_coverpoint(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing C_FC_MAX_NUM_NEW_BINS limit");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNC_COV_BINS_INFO);
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS, C_FC_MAX_NUM_NEW_BINS)); -- OK
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS, C_FC_MAX_NUM_NEW_BINS + 1)); -- OK

      increment_expected_alerts_and_stop_limit(TB_ERROR, 6);
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 1, C_FC_MAX_NUM_NEW_BINS)); -- OK
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 1, C_FC_MAX_NUM_NEW_BINS + 1)); -- ERROR
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 1, C_FC_MAX_NUM_NEW_BINS + 2)); -- ERROR

      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 2, C_FC_MAX_NUM_NEW_BINS)); -- OK
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 2, C_FC_MAX_NUM_NEW_BINS + 1)); -- ERROR
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 2, C_FC_MAX_NUM_NEW_BINS + 2)); -- ERROR
      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS + 2, C_FC_MAX_NUM_NEW_BINS + 3)); -- ERROR

      v_coverpoint_a.add_bins(bin_range(1, C_FC_MAX_NUM_NEW_BINS, 0) & bin(0)); -- ERROR

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing C_FC_MAX_PROC_CALL_LENGTH limit");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNC_COV_BINS_INFO);
      v_coverpoint_a.add_bins(bin(integer'left));
      v_coverpoint_a.add_bins(ignore_bin(integer'left));
      v_coverpoint_a.add_bins(illegal_bin(integer'left));
      v_coverpoint_a.add_bins(bin_range(integer'left, integer'left + 1, integer'right));
      v_coverpoint_a.add_bins(bin_transition((0, 1, 2, 3, 4, 5, 6, 7, 8, 9)));
      v_coverpoint_a.add_bins(bin_transition((100000000, 100000001, 100000002, 100000003, 100000004, 100000005, 100000006, 100000007, 100000008, 100000009)));

      v_coverpoint_a.add_bins(bin(integer'left) & bin(integer'left));
      v_coverpoint_a.add_bins(ignore_bin(integer'left) & ignore_bin(integer'left));
      v_coverpoint_a.add_bins(illegal_bin(integer'left) & illegal_bin(integer'left));
      v_coverpoint_a.add_bins(bin_range(integer'left, integer'left + 1, integer'right) & bin_range(integer'left, integer'left + 1, integer'right));
      v_coverpoint_a.add_bins(bin_transition((0, 1, 2, 3, 4, 5, 6, 7, 8, 9)) & bin_transition((0, 1, 2, 3, 4, 5, 6, 7, 8, 9)));
      v_coverpoint_a.add_bins(bin_transition((100000000, 100000001, 100000002, 100000003, 100000004, 100000005, 100000006, 100000007, 100000008, 100000009)) & bin_transition((100000000, 100000001, 100000002, 100000003, 100000004, 100000005, 100000006, 100000007, 100000008, 100000009)));

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing C_FC_MAX_NUM_COVERPOINTS limit");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(0));
      v_coverpoint_b.add_bins(bin(0));
      v_coverpoint_c.add_bins(bin(0));
      v_coverpoint_d.add_bins(bin(0));
      v_coverpoint_e.add_bins(bin(0));
      v_cross_x2.add_bins(bin(0));
      v_cross_x2_b.add_bins(bin(0));
      v_cross_x3.add_bins(bin(0));
      v_cross_x3_b.add_bins(bin(0));
      v_cross_x4.add_bins(bin(0));
      v_cross_x5.add_bins(bin(0));
      v_cross_x6.add_bins(bin(0));
      v_cross_x7.add_bins(bin(0));
      v_cross_x8.add_bins(bin(0));
      v_cross_x9.add_bins(bin(0));
      v_cross_x10.add_bins(bin(0));
      v_cross_x11.add_bins(bin(0));
      v_cross_x12.add_bins(bin(0));
      v_cross_x13.add_bins(bin(0));
      v_cross_x14.add_bins(bin(0));
      increment_expected_alerts_and_stop_limit(TB_FAILURE, 1); -- C_FC_MAX_NUM_COVERPOINTS = 20
      v_cross_x15.set_scope("scope");   -- Avoid several error alerts by using this procedure which does not access the covergroup status register

    --===================================================================================
    elsif GC_TESTCASE = "fc_cross_bin" then
      --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with single values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin(-100), bin(100));
      v_cross_x2.add_cross(bin(-101), bin(101));
      v_cross_x2.add_cross(bin(-102), bin(102));

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => -100), (0 => 100));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => -101), (0 => 101));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => -102), (0 => 102));

      sample_cross_bins(v_cross_x2, ((-100, 100), (-101, 101), (-102, 102)), 1);
      sample_cross_bins(v_cross_x2, ((-100, 105), (-105, 101), (-105, 105)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 3;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => -100), (0 => 100), hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => -101), (0 => 101), hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => -102), (0 => 102), hits => 1);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with multiple values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin((201, 202)), bin((214, 215)));
      v_cross_x2.add_cross(bin((222, 224, 226)), bin((231, 233, 235, 237)));

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (201, 202), (214, 215));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (222, 224, 226), (231, 233, 235, 237));

      sample_cross_bins(v_cross_x2, ((201, 214), (201, 215), (202, 214), (202, 215)), 1);
      sample_cross_bins(v_cross_x2, ((222, 231), (222, 233), (222, 235), (222, 237), (224, 231), (224, 233), (224, 235), (224, 237), (226, 231), (226, 233), (226, 235), (226, 237)), 1);
      sample_cross_bins(v_cross_x2, ((201, 213), (202, 216), (223, 231), (225, 233), (227, 235)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 2;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (201, 202), (214, 215), hits => 4);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (222, 224, 226), (231, 233, 235, 237), hits => 12);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with ranges of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin_range(300, 307), bin_range(311, 315));
      v_cross_x2.add_cross(bin_range(321, 329, 3), bin_range(331, 335, 2));

      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (300, 307), (311, 315));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (321, 323), (331, 332));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (321, 323), (333, 335));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (324, 326), (331, 332));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (324, 326), (333, 335));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (327, 329), (331, 332));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (327, 329), (333, 335));

      sample_cross_bins(v_cross_x2, ((300, 311), (301, 312), (302, 313), (303, 314), (304, 315), (305, 314), (306, 313), (307, 312)), 1);
      sample_cross_bins(v_cross_x2, ((321, 331), (321, 332), (322, 331), (322, 332), (323, 331), (323, 332)), 1);
      sample_cross_bins(v_cross_x2, ((321, 333), (321, 334), (321, 335), (322, 333), (322, 334), (322, 335), (323, 333), (323, 334), (323, 335)), 1);
      sample_cross_bins(v_cross_x2, ((324, 331), (324, 332), (325, 331), (325, 332), (326, 331), (326, 332)), 1);
      sample_cross_bins(v_cross_x2, ((324, 333), (324, 334), (324, 335), (325, 333), (325, 334), (325, 335), (326, 333), (326, 334), (326, 335)), 1);
      sample_cross_bins(v_cross_x2, ((327, 331), (327, 332), (328, 331), (328, 332), (329, 331), (329, 332)), 1);
      sample_cross_bins(v_cross_x2, ((327, 333), (327, 334), (327, 335), (328, 333), (328, 334), (328, 335), (329, 333), (329, 334), (329, 335)), 1);
      sample_cross_bins(v_cross_x2, ((300, 310), (307, 316), (320, 331), (330, 335)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 7;
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (300, 307), (311, 315), hits => 8);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (321, 323), (331, 332), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (321, 323), (333, 335), hits => 9);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (324, 326), (331, 332), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (324, 326), (333, 335), hits => 9);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (327, 329), (331, 332), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (327, 329), (333, 335), hits => 9);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin_transition((401, 403, 401)), bin_transition((416, 417, 418)));
      v_cross_x2.add_cross(bin_transition((401, 403, 401, 405)), bin_transition((416, 417, 418, 419)));
      v_cross_x2.add_cross(bin_transition((428, 427, 425, 421)), bin_transition((431, 434, 434, 439)));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_cross_x2_b.add_cross(bin_transition((428, 427, 425, 421)), bin_transition((431, 434, 434, 439, 434)));

      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (401, 403, 401), (416, 417, 418));
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (401, 403, 401, 405), (416, 417, 418, 419));
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (428, 427, 425, 421), (431, 434, 434, 439));

      sample_cross_bins(v_cross_x2, ((401, 416), (403, 417), (401, 418)), 2);
      sample_cross_bins(v_cross_x2, ((401, 416), (403, 417), (401, 416), (403, 417), (401, 418), (405, 419)), 2);
      sample_cross_bins(v_cross_x2, ((401, 416), (403, 417), (401, 419), (401, 416), (403, 417), (401, 418), (405, 419)), 2);
      sample_cross_bins(v_cross_x2, ((428, 431), (427, 434), (425, 434), (421, 439)), 3);
      sample_cross_bins(v_cross_x2, ((428, 431), (427, 434), (425, 434), (420, 439)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 3;
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (401, 403, 401), (416, 417, 418), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (401, 403, 401, 405), (416, 417, 418, 419), hits => 4);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (428, 427, 425, 421), (431, 434, 434, 439), hits => 3);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore cross with single values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin(-2001), ignore_bin(2001));
      v_cross_x2.add_cross(ignore_bin(-2002), ignore_bin(2002));
      v_cross_x2.add_cross(ignore_bin(-2003), ignore_bin(2003));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => -2001), (0 => 2001));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => -2002), (0 => 2002));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => -2003), (0 => 2003));

      sample_cross_bins(v_cross_x2, ((-2001, 2001), (-2002, 2002), (-2003, 2003)), 1);
      sample_cross_bins(v_cross_x2, ((-2001, 2005), (-2005, 2002), (-2005, 2005)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 3;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => -2001), (0 => 2001), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => -2002), (0 => 2002), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => -2003), (0 => 2003), hits => 1);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore cross with ranges of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin_range(2100, 2107), ignore_bin_range(2115, 2119));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN_IGNORE), (2100, 2107), (2115, 2119));

      sample_cross_bins(v_cross_x2, ((2100, 2115), (2101, 2116), (2102, 2117), (2103, 2118), (2104, 2119), (2105, 2118), (2106, 2117), (2107, 2116)), 1);
      sample_cross_bins(v_cross_x2, ((2100, 2114), (2107, 2120), (2108, 2115), (2109, 2119)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 1;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN_IGNORE), (2100, 2107), (2115, 2119), hits => 8);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin_transition((2201, 2203, 2201)), ignore_bin_transition((2206, 2207, 2208)));
      v_cross_x2.add_cross(ignore_bin_transition((2201, 2203, 2201, 2205)), ignore_bin_transition((2206, 2207, 2208, 2209)));
      v_cross_x2.add_cross(ignore_bin_transition((2218, 2217, 2215, 2211)), ignore_bin_transition((2212, 2214, 2216, 2218)));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_cross_x2_b.add_cross(ignore_bin_transition((2228, 2227, 2225, 2221)), ignore_bin_transition((2231, 2234, 2234, 2239, 2234)));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2201, 2203, 2201), (2206, 2207, 2208));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2201, 2203, 2201, 2205), (2206, 2207, 2208, 2209));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2218, 2217, 2215, 2211), (2212, 2214, 2216, 2218));

      sample_cross_bins(v_cross_x2, ((2201, 2206), (2203, 2207), (2201, 2208)), 2);
      sample_cross_bins(v_cross_x2, ((2201, 2206), (2203, 2207), (2201, 2206), (2203, 2207), (2201, 2208), (2205, 2209)), 2);
      sample_cross_bins(v_cross_x2, ((2201, 2206), (2203, 2207), (2201, 2209), (2201, 2206), (2203, 2207), (2201, 2208), (2205, 2209)), 2);
      sample_cross_bins(v_cross_x2, ((2218, 2212), (2217, 2214), (2215, 2216), (2211, 2218)), 3);
      sample_cross_bins(v_cross_x2, ((2218, 2212), (2217, 2214), (2215, 2216), (2211, 2219)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 3;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2201, 2203, 2201), (2206, 2207, 2208), hits => 6);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2201, 2203, 2201, 2205), (2206, 2207, 2208, 2209), hits => 4);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2218, 2217, 2215, 2211), (2212, 2214, 2216, 2218), hits => 3);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal cross with single values");
      ------------------------------------------------------------
      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");

      v_cross_x2.add_cross(illegal_bin(-3001), illegal_bin(3001));
      v_cross_x2.add_cross(illegal_bin(-3002), illegal_bin(3002));
      v_cross_x2.add_cross(illegal_bin(-3003), illegal_bin(3003));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => -3001), (0 => 3001));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => -3002), (0 => 3002));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => -3003), (0 => 3003));

      increment_expected_alerts(WARNING, 3);
      sample_cross_bins(v_cross_x2, ((-3001, 3001), (-3002, 3002), (-3003, 3003)), 1);
      sample_cross_bins(v_cross_x2, ((-3001, 3005), (-3005, 3002), (-3005, 3005)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 3;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => -3001), (0 => 3001), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => -3002), (0 => 3002), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => -3003), (0 => 3003), hits => 1);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal cross with ranges of values");
      ------------------------------------------------------------
      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");
      v_cross_x2.add_cross(illegal_bin_range(3100, 3107), illegal_bin_range(3115, 3119));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_ILLEGAL, RAN_ILLEGAL), (3100, 3107), (3115, 3119));

      increment_expected_alerts(WARNING, 8);
      sample_cross_bins(v_cross_x2, ((3100, 3115), (3101, 3116), (3102, 3117), (3103, 3118), (3104, 3119), (3105, 3118), (3106, 3117), (3107, 3116)), 1);
      sample_cross_bins(v_cross_x2, ((3100, 3114), (3107, 3120), (3108, 3115), (3109, 3119)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 1;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_ILLEGAL, RAN_ILLEGAL), (3100, 3107), (3115, 3119), hits => 8);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");
      v_cross_x2.add_cross(illegal_bin_transition((3201, 3203, 3201)), illegal_bin_transition((3212, 3214, 3216)));
      v_cross_x2.add_cross(illegal_bin_transition((3201, 3203, 3201, 3205)), illegal_bin_transition((3212, 3214, 3216, 3218)));
      v_cross_x2.add_cross(illegal_bin_transition((3228, 3227, 3225, 3221)), illegal_bin_transition((3231, 3234, 3234, 3239)));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_cross_x2_b.add_cross(illegal_bin_transition((3228, 3227, 3225, 3221)), illegal_bin_transition((3231, 3234, 3234, 3239, 3234)));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3201, 3203, 3201), (3212, 3214, 3216));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3201, 3203, 3201, 3205), (3212, 3214, 3216, 3218));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3228, 3227, 3225, 3221), (3231, 3234, 3234, 3239));

      increment_expected_alerts(WARNING, 9);
      sample_cross_bins(v_cross_x2, ((3201, 3212), (3203, 3214), (3201, 3216)), 2);
      sample_cross_bins(v_cross_x2, ((3201, 3212), (3203, 3214), (3201, 3212), (3203, 3214), (3201, 3216), (3205, 3218)), 2);
      sample_cross_bins(v_cross_x2, ((3228, 3231), (3227, 3234), (3225, 3234), (3221, 3239)), 3);
      sample_cross_bins(v_cross_x2, ((3228, 3231), (3227, 3234), (3225, 3234), (3220, 3239)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx - 3;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3201, 3203, 3201), (3212, 3214, 3216), hits => 4);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3201, 3203, 3201, 3205), (3212, 3214, 3216, 3218), hits => 2);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3228, 3227, 3225, 3221), (3231, 3234, 3234, 3239), hits => 3);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with different bins");
      ------------------------------------------------------------
      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");

      v_cross_x2.add_cross(bin(4000), bin((4010, 4015, 4019)), "cross_0");
      v_cross_x2.add_cross(bin_range(4100, 4107), bin_transition((4111, 4112, 4115)), "cross_1");
      v_cross_x2.add_cross(ignore_bin(4201), ignore_bin_range(4212, 4215), "cross_2");
      v_cross_x2.add_cross(ignore_bin_transition((4302, 4304, 4306)), ignore_bin(4315), "cross_3");
      v_cross_x2.add_cross(illegal_bin(4402), illegal_bin_range(4415, 4417), "cross_4");
      v_cross_x2.add_cross(illegal_bin_transition((4505, 4506)), illegal_bin(4516), "cross_5");
      v_cross_x2.add_cross(bin((4601, 4609)), ignore_bin_range(4611, 4613), "cross_6");
      v_cross_x2.add_cross(ignore_bin_transition((4701, 4702, 4703, 4704)), bin((4715, 4716)), "cross_7");
      v_cross_x2.add_cross(bin(4803), illegal_bin_range(4817, 4819), "cross_8");
      v_cross_x2.add_cross(illegal_bin_transition((4901, 4902, 4903)), bin(4917), "cross_9");
      v_cross_x2.add_cross(ignore_bin(5000), illegal_bin_range(5010, 5050), "cross_10");
      v_cross_x2.add_cross(illegal_bin_transition((5105, 5110, 5115)), ignore_bin(5150), "cross_11");

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 4000), (4010, 4015, 4019), name => "cross_0");
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, TRN), (4100, 4107), (4111, 4112, 4115), name => "cross_1");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, RAN_IGNORE), (0 => 4201), (4212, 4215), name => "cross_2");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, VAL_IGNORE), (4302, 4304, 4306), (0 => 4315), name => "cross_3");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, RAN_ILLEGAL), (0 => 4402), (4415, 4417), name => "cross_4");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL_ILLEGAL), (4505, 4506), (0 => 4516), name => "cross_5");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, RAN_IGNORE), (4601, 4609), (4611, 4613), name => "cross_6");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, VAL), (4701, 4702, 4703, 4704), (4715, 4716), name => "cross_7");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, RAN_ILLEGAL), (0 => 4803), (4817, 4819), name => "cross_8");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL), (4901, 4902, 4903), (0 => 4917), name => "cross_9");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, RAN_ILLEGAL), (0 => 5000), (5010, 5050), name => "cross_10");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL_IGNORE), (5105, 5110, 5115), (0 => 5150), name => "cross_11");

      sample_cross_bins(v_cross_x2, ((4000, 4010), (4000, 4015), (4000, 4019)), 1);
      sample_cross_bins(v_cross_x2, ((4100, 4111), (4101, 4112), (4102, 4115), (4103, 4111), (4104, 4112), (4105, 4115)), 1);
      sample_cross_bins(v_cross_x2, ((4201, 4212), (4201, 4213), (4201, 4214), (4201, 4215)), 1);
      sample_cross_bins(v_cross_x2, ((4302, 4315), (4304, 4315), (4306, 4315)), 1);
      increment_expected_alerts(WARNING, 3);
      sample_cross_bins(v_cross_x2, ((4402, 4415), (4402, 4416), (4402, 4417)), 1);
      increment_expected_alerts(WARNING, 1);
      sample_cross_bins(v_cross_x2, ((4505, 4516), (4506, 4516)), 1);
      sample_cross_bins(v_cross_x2, ((4601, 4611), (4601, 4612), (4601, 4613), (4609, 4611), (4609, 4612), (4609, 4613)), 1);
      sample_cross_bins(v_cross_x2, ((4701, 4715), (4702, 4715), (4703, 4715), (4704, 4715), (4701, 4716), (4702, 4716), (4703, 4716), (4704, 4716)), 1);
      increment_expected_alerts(WARNING, 4);
      sample_cross_bins(v_cross_x2, ((4803, 4817), (4803, 4818), (4803, 4819)), 1);
      sample_cross_bins(v_cross_x2, ((4901, 4917), (4902, 4917), (4903, 4917)), 1);
      increment_expected_alerts(WARNING, 4);
      sample_cross_bins(v_cross_x2, ((5000, 5010), (5000, 5025), (5000, 5050)), 1);
      sample_cross_bins(v_cross_x2, ((5105, 5150), (5110, 5150), (5115, 5150)), 1);

      v_bin_idx         := v_bin_idx - 2;
      v_invalid_bin_idx := v_invalid_bin_idx - 10;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 4000), (4010, 4015, 4019), name => "cross_0", hits => 3);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, TRN), (4100, 4107), (4111, 4112, 4115), name => "cross_1", hits => 2);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, RAN_IGNORE), (0 => 4201), (4212, 4215), name => "cross_2", hits => 4);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, VAL_IGNORE), (4302, 4304, 4306), (0 => 4315), name => "cross_3", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, RAN_ILLEGAL), (0 => 4402), (4415, 4417), name => "cross_4", hits => 3);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL_ILLEGAL), (4505, 4506), (0 => 4516), name => "cross_5", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, RAN_IGNORE), (4601, 4609), (4611, 4613), name => "cross_6", hits => 6);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, VAL), (4701, 4702, 4703, 4704), (4715, 4716), name => "cross_7", hits => 2);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, RAN_ILLEGAL), (0 => 4803), (4817, 4819), name => "cross_8", hits => 3);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL), (4901, 4902, 4903), (0 => 4917), name => "cross_9", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, RAN_ILLEGAL), (0 => 5000), (5010, 5050), name => "cross_10", hits => 3);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL_IGNORE), (5105, 5110, 5115), (0 => 5150), name => "cross_11", hits => 1);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross using concatenation of bins");
      ------------------------------------------------------------
      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");

      v_cross_x2.add_cross(bin(6000) & bin(6005) & bin(6010), bin_range(6100, 6150, 2), "concatenated");
      v_cross_x2.add_cross(bin_range(6200, 6250) & ignore_bin_range(6220, 6240), bin_range(6350, 6399) & illegal_bin(6375), "concatenated");

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6000), (6100, 6124), name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6000), (6125, 6150), name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6005), (6100, 6124), name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6005), (6125, 6150), name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6010), (6100, 6124), name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6010), (6125, 6150), name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (6200, 6250), (6350, 6399), name => "concatenated");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, VAL_ILLEGAL), (6200, 6250), (0 => 6375), name => "concatenated");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN), (6220, 6240), (6350, 6399), name => "concatenated");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, VAL_ILLEGAL), (6220, 6240), (0 => 6375), name => "concatenated");

      sample_cross_bins(v_cross_x2, ((6000, 6100), (6000, 6124), (6000, 6125), (6000, 6150)), 1);
      sample_cross_bins(v_cross_x2, ((6005, 6100), (6005, 6124), (6005, 6125), (6005, 6150)), 1);
      sample_cross_bins(v_cross_x2, ((6010, 6100), (6010, 6124), (6010, 6125), (6010, 6150)), 1);
      increment_expected_alerts(WARNING, 2);
      sample_cross_bins(v_cross_x2, ((6200, 6350), (6219, 6374), (6241, 6376), (6250, 6399)), 1);
      sample_cross_bins(v_cross_x2, ((6200, 6375), (6250, 6375)), 1); -- Sample illegal bins
      sample_cross_bins(v_cross_x2, ((6220, 6350), (6240, 6399)), 1); -- Sample ignore bins

      v_bin_idx         := v_bin_idx - 7;
      v_invalid_bin_idx := v_invalid_bin_idx - 3;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6000), (6100, 6124), hits => 2, name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6000), (6125, 6150), hits => 2, name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6005), (6100, 6124), hits => 2, name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6005), (6125, 6150), hits => 2, name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6010), (6100, 6124), hits => 2, name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 6010), (6125, 6150), hits => 2, name => "concatenated");
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (6200, 6250), (6350, 6399), hits => 4, name => "concatenated");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, VAL_ILLEGAL), (6200, 6250), (0 => 6375), hits => 2, name => "concatenated");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN), (6220, 6240), (6350, 6399), hits => 2, name => "concatenated");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, VAL_ILLEGAL), (6220, 6240), (0 => 6375), hits => 0, name => "concatenated");

      check_num_bins(v_cross_x2, v_bin_idx, v_invalid_bin_idx);
      check_coverage_completed(v_cross_x2);
      v_cross_x2.report_coverage(VERBOSE);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross and ignore cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin_transition((7000, 7001, 7010)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7001, 7020)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7001, 7030)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7002, 7010)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7002, 7020)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7002, 7030)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7003, 7010)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7003, 7020)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7003, 7030)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7004, 7010)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7004, 7020)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(bin_transition((7000, 7004, 7030)), bin_transition((7100, 7102, 7104)), "transition");
      v_cross_x2.add_cross(ignore_bin_transition((7000, 7001, 7010)), ignore_bin_transition((7100, 7102, 7104)), "ignore_transition"); -- ignores
      v_cross_x2.add_cross(ignore_bin_transition((7000, 7001, 7020)), ignore_bin_transition((7100, 7102, 7105)), "ignore_transition"); -- doesn't ignore
      v_cross_x2.add_cross(ignore_bin_transition((7000, 7002)), ignore_bin_transition((7100, 7102)), "ignore_transition"); -- ignores
      v_cross_x2.add_cross(ignore_bin_transition((7003, 7010)), ignore_bin_transition((7102, 7104)), "ignore_transition"); -- ignores
      v_cross_x2.add_cross(ignore_bin_transition((7000, 7004, 7010)), bin(7100), "ignore_transition"); -- doesn't ignore
      v_cross_x2.add_cross(ignore_bin_transition((7000, 7004, 7020)), bin(7104), "ignore_transition"); -- ignores

      sample_cross_bins(v_cross_x2, ((7000, 7100), (7001, 7102), (7010, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7001, 7102), (7020, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7001, 7102), (7030, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7002, 7102), (7010, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7002, 7102), (7020, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7002, 7102), (7030, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7003, 7102), (7010, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7003, 7102), (7020, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7003, 7102), (7030, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7004, 7102), (7010, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7004, 7102), (7020, 7104)), 1);
      sample_cross_bins(v_cross_x2, ((7000, 7100), (7004, 7102), (7030, 7104)), 1);

      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7001, 7010), (7100, 7102, 7104), hits => 0, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7001, 7020), (7100, 7102, 7104), hits => 1, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7001, 7030), (7100, 7102, 7104), hits => 1, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7002, 7010), (7100, 7102, 7104), hits => 0, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7002, 7020), (7100, 7102, 7104), hits => 0, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7002, 7030), (7100, 7102, 7104), hits => 0, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7003, 7010), (7100, 7102, 7104), hits => 0, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7003, 7020), (7100, 7102, 7104), hits => 1, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7003, 7030), (7100, 7102, 7104), hits => 1, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7004, 7010), (7100, 7102, 7104), hits => 1, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7004, 7020), (7100, 7102, 7104), hits => 0, name => "transition");
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (7000, 7004, 7030), (7100, 7102, 7104), hits => 1, name => "transition");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (7000, 7001, 7010), (7100, 7102, 7104), hits => 1, name => "ignore_transition");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (7000, 7001, 7020), (7100, 7102, 7105), hits => 0, name => "ignore_transition");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (7000, 7002), (7100, 7102), hits => 3, name => "ignore_transition");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (7003, 7010), (7102, 7104), hits => 1, name => "ignore_transition");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, VAL), (7000, 7004, 7010), (0 => 7100), hits => 0, name => "ignore_transition");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, VAL), (7000, 7004, 7020), (0 => 7104), hits => 1, name => "ignore_transition");

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing minimum coverage");
      ------------------------------------------------------------
      increment_expected_alerts(TB_WARNING, 9); -- For adding bins after sampling warnings
      for i in 1 to 10 loop
        v_bin_val  := v_rand.rand(100, 500);
        v_min_hits := v_rand.rand(1, 20);
        v_cross_x2.add_cross(bin(v_bin_val), bin(v_bin_val + 100), v_min_hits);

        check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => v_bin_val), (0 => v_bin_val + 100), v_min_hits);

        -- Check the coverage increases when the bin is sampled until it is 100%
        for j in 0 to v_min_hits - 1 loop
          check_bins_coverage(v_cross_x2, 100.0 * real(i - 1) / real(i));
          check_hits_coverage(v_cross_x2, 100.0 * real(j + v_prev_min_hits) / real(v_min_hits + v_prev_min_hits));
          sample_cross_bins(v_cross_x2, (0 => (v_bin_val, v_bin_val + 100)), 1);
        end loop;
        check_coverage_completed(v_cross_x2);

        v_bin_idx       := v_bin_idx - 1;
        check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => v_bin_val), (0 => v_bin_val + 100), v_min_hits, hits => v_min_hits);
        v_prev_min_hits := v_prev_min_hits + v_min_hits;
      end loop;

      v_cross_x2.report_coverage(VERBOSE);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin names");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin(1000), bin(2000));
      v_cross_x2.add_cross(bin(1001), bin(2001), "my_bin_1");
      v_cross_x2.add_cross(bin(1002), bin(2002), 5, "my_bin_2");
      v_cross_x2.add_cross(bin(1003), bin(2003), 5, 1, "my_bin_3");

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 1000), (0 => 2000));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 1001), (0 => 2001), name => "my_bin_1");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 1002), (0 => 2002), 5, name => "my_bin_2");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 1003), (0 => 2003), 5, 1, name => "my_bin_3");

      v_cross_x2.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of 3 elements");
      ------------------------------------------------------------
      v_cross_x3.add_cross(bin(100), bin(200), bin(300));
      v_cross_x3.add_cross(bin(101), bin(201), bin(301));
      v_cross_x3.add_cross(bin(102), bin(202), bin(302));

      v_bin_idx := 0;
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300));
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 301));
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 102), (0 => 202), (0 => 302));

      v_cross_x3.sample_coverage((100, 200, 300));
      v_cross_x3.sample_coverage((101, 201, 301));
      v_cross_x3.sample_coverage((102, 202, 302));
      v_cross_x3.sample_coverage((100, 200, 301)); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 3;
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), hits => 1);
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 301), hits => 1);
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 102), (0 => 202), (0 => 302), hits => 1);

      v_cross_x3.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of 4 elements");
      ------------------------------------------------------------
      v_cross_x4.add_cross(bin(100), bin(200), bin(300), bin(400));
      v_cross_x4.add_cross(bin(101), bin(201), bin(301), bin(401));
      v_cross_x4.add_cross(bin(102), bin(202), bin(302), bin(402));

      v_bin_idx := 0;
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400));
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 301), (0 => 401));
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 102), (0 => 202), (0 => 302), (0 => 402));

      v_cross_x4.sample_coverage((100, 200, 300, 400));
      v_cross_x4.sample_coverage((101, 201, 301, 401));
      v_cross_x4.sample_coverage((102, 202, 302, 402));
      v_cross_x4.sample_coverage((100, 200, 300, 401)); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 3;
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400), hits => 1);
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 301), (0 => 401), hits => 1);
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 102), (0 => 202), (0 => 302), (0 => 402), hits => 1);

      v_cross_x4.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of 5 elements");
      ------------------------------------------------------------
      v_cross_x5.add_cross(bin(100), bin(200), bin(300), bin(400), bin(500));
      v_cross_x5.add_cross(bin(101), bin(201), bin(301), bin(401), bin(501));
      v_cross_x5.add_cross(bin(102), bin(202), bin(302), bin(402), bin(502));

      v_bin_idx := 0;
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400), (0 => 500));
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 301), (0 => 401), (0 => 501));
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 102), (0 => 202), (0 => 302), (0 => 402), (0 => 502));

      v_cross_x5.sample_coverage((100, 200, 300, 400, 500));
      v_cross_x5.sample_coverage((101, 201, 301, 401, 501));
      v_cross_x5.sample_coverage((102, 202, 302, 402, 502));
      v_cross_x5.sample_coverage((100, 200, 300, 400, 501)); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 3;
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400), (0 => 500), hits => 1);
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 301), (0 => 401), (0 => 501), hits => 1);
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 102), (0 => 202), (0 => 302), (0 => 402), (0 => 502), hits => 1);

      v_cross_x5.report_coverage(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_cross_covpt" then
      --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of coverpoints with different bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(100));
      v_coverpoint_a.add_bins(bin_range(200, 207));
      v_coverpoint_a.add_bins(ignore_bin(300));
      v_coverpoint_a.add_bins(ignore_bin_range(400, 407));
      v_coverpoint_a.add_bins(illegal_bin_transition((501, 503, 505)));

      v_coverpoint_b.add_bins(bin((1002, 1004, 1006)));
      v_coverpoint_b.add_bins(bin_transition((1116, 1117, 1118)));
      v_coverpoint_b.add_bins(ignore_bin_transition((1212, 1214, 1216)));
      v_coverpoint_b.add_bins(illegal_bin(1310));
      v_coverpoint_b.add_bins(illegal_bin_range(1415, 1419));

      v_cross_x2.add_cross(v_coverpoint_a, v_coverpoint_b);

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (1002, 1004, 1006), name => "bin_0");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, TRN), (0 => 100), (1116, 1117, 1118), name => "bin_1");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, TRN_IGNORE), (0 => 100), (1212, 1214, 1216), name => "bin_2");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, VAL_ILLEGAL), (0 => 100), (0 => 1310), name => "bin_3");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, RAN_ILLEGAL), (0 => 100), (1415, 1419), name => "bin_4");
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, VAL), (200, 207), (1002, 1004, 1006), name => "bin_5");
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, TRN), (200, 207), (1116, 1117, 1118), name => "bin_6");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, TRN_IGNORE), (200, 207), (1212, 1214, 1216), name => "bin_7");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, VAL_ILLEGAL), (200, 207), (0 => 1310), name => "bin_8");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, RAN_ILLEGAL), (200, 207), (1415, 1419), name => "bin_9");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL), (0 => 300), (1002, 1004, 1006), name => "bin_10");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, TRN), (0 => 300), (1116, 1117, 1118), name => "bin_11");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, TRN_IGNORE), (0 => 300), (1212, 1214, 1216), name => "bin_12");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_ILLEGAL), (0 => 300), (0 => 1310), name => "bin_13");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, RAN_ILLEGAL), (0 => 300), (1415, 1419), name => "bin_14");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, VAL), (400, 407), (1002, 1004, 1006), name => "bin_15");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, TRN), (400, 407), (1116, 1117, 1118), name => "bin_16");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, TRN_IGNORE), (400, 407), (1212, 1214, 1216), name => "bin_17");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, VAL_ILLEGAL), (400, 407), (0 => 1310), name => "bin_18");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN_ILLEGAL), (400, 407), (1415, 1419), name => "bin_19");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL), (501, 503, 505), (1002, 1004, 1006), name => "bin_20");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN), (501, 503, 505), (1116, 1117, 1118), name => "bin_21");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_IGNORE), (501, 503, 505), (1212, 1214, 1216), name => "bin_22");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL_ILLEGAL), (501, 503, 505), (0 => 1310), name => "bin_23");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, RAN_ILLEGAL), (501, 503, 505), (1415, 1419), name => "bin_24");

      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = WARNING, ERROR, "Checking illegal bin alert level");
      increment_expected_alerts(WARNING, 13);
      sample_cross_bins(v_cross_x2, ((100, 1004), (100, 1116), (100, 1117), (100, 1118), (100, 1212), (100, 1214), (100, 1216), (100, 1310), (100, 1419)), 1);
      sample_cross_bins(v_cross_x2, ((200, 1004), (201, 1116), (202, 1117), (203, 1118), (204, 1212), (205, 1214), (206, 1216), (207, 1310), (206, 1419)), 1);
      sample_cross_bins(v_cross_x2, ((300, 1004), (300, 1116), (300, 1117), (300, 1118), (300, 1212), (300, 1214), (300, 1216), (300, 1310), (300, 1419)), 1);
      sample_cross_bins(v_cross_x2, ((400, 1004), (401, 1116), (402, 1117), (403, 1118), (404, 1212), (405, 1214), (406, 1216), (407, 1310), (406, 1419)), 1);
      sample_cross_bins(v_cross_x2, ((501, 1004), (503, 1004), (505, 1004), (501, 1116), (503, 1117), (505, 1118), (501, 1212), (503, 1214), (505, 1216),
                                     (501, 1310), (503, 1310), (505, 1310), (501, 1419), (503, 1419), (505, 1419)), 1);

      v_bin_idx         := v_bin_idx - 4;
      v_invalid_bin_idx := v_invalid_bin_idx - 21;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (1002, 1004, 1006), name => "bin_0", hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, TRN), (0 => 100), (1116, 1117, 1118), name => "bin_1", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, TRN_IGNORE), (0 => 100), (1212, 1214, 1216), name => "bin_2", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, VAL_ILLEGAL), (0 => 100), (0 => 1310), name => "bin_3", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL, RAN_ILLEGAL), (0 => 100), (1415, 1419), name => "bin_4", hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, VAL), (200, 207), (1002, 1004, 1006), name => "bin_5", hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, TRN), (200, 207), (1116, 1117, 1118), name => "bin_6", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, TRN_IGNORE), (200, 207), (1212, 1214, 1216), name => "bin_7", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, VAL_ILLEGAL), (200, 207), (0 => 1310), name => "bin_8", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN, RAN_ILLEGAL), (200, 207), (1415, 1419), name => "bin_9", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL), (0 => 300), (1002, 1004, 1006), name => "bin_10", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, TRN), (0 => 300), (1116, 1117, 1118), name => "bin_11", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, TRN_IGNORE), (0 => 300), (1212, 1214, 1216), name => "bin_12", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_ILLEGAL), (0 => 300), (0 => 1310), name => "bin_13", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, RAN_ILLEGAL), (0 => 300), (1415, 1419), name => "bin_14", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, VAL), (400, 407), (1002, 1004, 1006), name => "bin_15", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, TRN), (400, 407), (1116, 1117, 1118), name => "bin_16", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, TRN_IGNORE), (400, 407), (1212, 1214, 1216), name => "bin_17", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, VAL_ILLEGAL), (400, 407), (0 => 1310), name => "bin_18", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN_ILLEGAL), (400, 407), (1415, 1419), name => "bin_19", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL), (501, 503, 505), (1002, 1004, 1006), name => "bin_20", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN), (501, 503, 505), (1116, 1117, 1118), name => "bin_21", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_IGNORE), (501, 503, 505), (1212, 1214, 1216), name => "bin_22", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, VAL_ILLEGAL), (501, 503, 505), (0 => 1310), name => "bin_23", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, RAN_ILLEGAL), (501, 503, 505), (1415, 1419), name => "bin_24", hits => 1);

      check_num_bins(v_cross_x2, v_bin_idx, v_invalid_bin_idx);
      check_coverage_completed(v_cross_x2);
      v_cross_x2.report_coverage(VERBOSE);

      delete_coverpoint(v_coverpoint_a);
      delete_coverpoint(v_coverpoint_b);
      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing minimum coverage");
      ------------------------------------------------------------
      v_min_hits := v_rand.rand(1, 20);
      v_coverpoint_a.add_bins(bin(100), v_min_hits + 10, "bin_a");
      v_coverpoint_b.add_bins(bin(200), v_min_hits + 20, "bin_b");
      v_cross_x2.add_cross(v_coverpoint_a, v_coverpoint_b, v_min_hits);

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (0 => 200), v_min_hits);

      -- Check the coverage increases when the bin is sampled until it is 100%
      for j in 0 to v_min_hits - 1 loop
        check_hits_coverage(v_cross_x2, 100.0 * real(j) / real(v_min_hits));
        sample_cross_bins(v_cross_x2, (0 => (100, 200)), 1);
      end loop;
      check_coverage_completed(v_cross_x2);

      v_bin_idx := v_bin_idx - 1;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (0 => 200), v_min_hits, hits => v_min_hits);

      v_cross_x2.report_coverage(VERBOSE);

      delete_coverpoint(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin names");
      ------------------------------------------------------------
      v_cross_x2.add_cross(v_coverpoint_a, v_coverpoint_b);
      v_cross_x2.add_cross(v_coverpoint_a, v_coverpoint_b, "my_bin_1");
      v_cross_x2.add_cross(v_coverpoint_a, v_coverpoint_b, 5, "my_bin_2");
      v_cross_x2.add_cross(v_coverpoint_a, v_coverpoint_b, 5, 1, "my_bin_3");

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (0 => 200));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (0 => 200), name => "my_bin_1");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (0 => 200), 5, name => "my_bin_2");
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 100), (0 => 200), 5, 1, name => "my_bin_3");

      delete_coverpoint(v_coverpoint_a);
      delete_coverpoint(v_coverpoint_b);
      delete_coverpoint(v_cross_x2);
      v_cross_x2.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of 3 elements");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(100) & bin(101));
      v_coverpoint_b.add_bins(bin(200) & bin(201));
      v_coverpoint_c.add_bins(bin(300));
      v_cross_x3.add_cross(v_coverpoint_a, v_coverpoint_b, v_coverpoint_c);

      v_bin_idx := 0;
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300));
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 100), (0 => 201), (0 => 300));
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 101), (0 => 200), (0 => 300));
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 300));

      v_cross_x3.sample_coverage((100, 200, 300));
      v_cross_x3.sample_coverage((100, 201, 300));
      v_cross_x3.sample_coverage((101, 200, 300));
      v_cross_x3.sample_coverage((101, 201, 300));
      v_cross_x3.sample_coverage((100, 200, 301)); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 4;
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), hits => 1);
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 100), (0 => 201), (0 => 300), hits => 1);
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 101), (0 => 200), (0 => 300), hits => 1);
      check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 300), hits => 1);

      v_cross_x3.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of 4 elements");
      ------------------------------------------------------------
      v_coverpoint_d.add_bins(bin(400));
      v_cross_x4.add_cross(v_coverpoint_a, v_coverpoint_b, v_coverpoint_c, v_coverpoint_d);

      v_bin_idx := 0;
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400));
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 100), (0 => 201), (0 => 300), (0 => 400));
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 101), (0 => 200), (0 => 300), (0 => 400));
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 300), (0 => 400));

      v_cross_x4.sample_coverage((100, 200, 300, 400));
      v_cross_x4.sample_coverage((100, 201, 300, 400));
      v_cross_x4.sample_coverage((101, 200, 300, 400));
      v_cross_x4.sample_coverage((101, 201, 300, 400));
      v_cross_x4.sample_coverage((100, 200, 300, 401)); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 4;
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400), hits => 1);
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 100), (0 => 201), (0 => 300), (0 => 400), hits => 1);
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 101), (0 => 200), (0 => 300), (0 => 400), hits => 1);
      check_cross_bin(v_cross_x4, v_bin_idx, (VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 300), (0 => 400), hits => 1);

      v_cross_x4.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross of 5 elements");
      ------------------------------------------------------------
      v_coverpoint_e.add_bins(bin(500));
      v_cross_x5.add_cross(v_coverpoint_a, v_coverpoint_b, v_coverpoint_c, v_coverpoint_d, v_coverpoint_e);

      v_bin_idx := 0;
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400), (0 => 500));
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 100), (0 => 201), (0 => 300), (0 => 400), (0 => 500));
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 101), (0 => 200), (0 => 300), (0 => 400), (0 => 500));
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 300), (0 => 400), (0 => 500));

      v_cross_x5.sample_coverage((100, 200, 300, 400, 500));
      v_cross_x5.sample_coverage((100, 201, 300, 400, 500));
      v_cross_x5.sample_coverage((101, 200, 300, 400, 500));
      v_cross_x5.sample_coverage((101, 201, 300, 400, 500));
      v_cross_x5.sample_coverage((100, 200, 300, 400, 501)); -- Sample values outside bins

      v_bin_idx := v_bin_idx - 4;
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 100), (0 => 200), (0 => 300), (0 => 400), (0 => 500), hits => 1);
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 100), (0 => 201), (0 => 300), (0 => 400), (0 => 500), hits => 1);
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 101), (0 => 200), (0 => 300), (0 => 400), (0 => 500), hits => 1);
      check_cross_bin(v_cross_x5, v_bin_idx, (VAL, VAL, VAL, VAL, VAL), (0 => 101), (0 => 201), (0 => 300), (0 => 400), (0 => 500), hits => 1);

      v_cross_x5.report_coverage(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_rand_bin" then
      --===================================================================================
      disable_log_msg(ID_FUNC_COV_SAMPLE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing seeds");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Check default seed values for uninitialized coverpoint");
      v_seeds := v_coverpoint_a.get_rand_seeds(VOID);
      check_value(v_seeds(0), C_RAND_INIT_SEED_1, ERROR, "Checking initial seed 1");
      check_value(v_seeds(1), C_RAND_INIT_SEED_2, ERROR, "Checking initial seed 2");

      log(ID_SEQUENCER, "Check default seed values using default name for initialized coverpoint");
      v_coverpoint_a.set_bin_overlap_alert_level(NO_ALERT); -- Initializes coverpoint
      v_seeds := v_coverpoint_a.get_rand_seeds(VOID);
      check_value(v_seeds(0), 85514, ERROR, "Checking initial seed 1");
      check_value(v_seeds(1), 85614, ERROR, "Checking initial seed 2");

      log(ID_SEQUENCER, "Set and get seeds with vector value");
      v_seeds(0) := 500;
      v_seeds(1) := 5000;
      v_coverpoint_b.set_rand_seeds(v_seeds);
      v_coverpoint_b.set_bin_overlap_alert_level(NO_ALERT); -- To check that coverpoint is already initialized and won't overwrite the seeds
      v_seeds    := v_coverpoint_b.get_rand_seeds(VOID);
      check_value(v_seeds(0), 500, ERROR, "Checking seed 1");
      check_value(v_seeds(1), 5000, ERROR, "Checking seed 2");

      log(ID_SEQUENCER, "Set and get seeds with positive values");
      v_seeds(0) := 800;
      v_seeds(1) := 8000;
      v_coverpoint_c.set_rand_seeds(v_seeds(0), v_seeds(1));
      v_coverpoint_c.set_bin_overlap_alert_level(NO_ALERT); -- To check that coverpoint is already initialized and won't overwrite the seeds
      v_coverpoint_c.get_rand_seeds(v_seeds(0), v_seeds(1));
      check_value(v_seeds(0), 800, ERROR, "Checking seed 1");
      check_value(v_seeds(1), 8000, ERROR, "Checking seed 2");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization doesn't select ignore or illegal bins");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(ignore_bin(2000), "bin_0");
      v_coverpoint_a.add_bins(ignore_bin_range(2100, 2109), "bin_1");
      v_coverpoint_a.add_bins(ignore_bin_transition((2201, 2203, 2205, 2209)), "bin_2");
      v_coverpoint_a.add_bins(illegal_bin(3000), "bin_3");
      v_coverpoint_a.add_bins(illegal_bin_range(3100, 3109), "bin_4");
      v_coverpoint_a.add_bins(illegal_bin_transition((3201, 3203, 3205, 3209)), "bin_5");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with single values");
      ------------------------------------------------------------
      v_min_hits := 1;
      v_coverpoint_a.add_bins(bin_range(1, 50, 0));

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 50 * v_min_hits loop
        v_value := v_coverpoint_a.rand(NO_SAMPLE_COV);
        v_coverpoint_a.sample_coverage(v_value);
      end loop;

      for i in 1 to 50 loop
        check_bin(v_coverpoint_a, v_bin_idx, VAL, i, v_min_hits, hits => v_min_hits);
      end loop;
      check_coverage_completed(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with multiple values");
      ------------------------------------------------------------
      v_min_hits := 2;
      increment_expected_alerts(TB_WARNING, 5); -- For adding bins after sampling warnings
      v_coverpoint_a.add_bins(bin((200, 201, 202, 203, 204)), v_min_hits);
      v_coverpoint_a.add_bins(bin((210, 211, 212, 213, 214)), v_min_hits);
      v_coverpoint_a.add_bins(bin((220, 221, 222, 223, 224)), v_min_hits);
      v_coverpoint_a.add_bins(bin((230, 231, 232, 233, 234)), v_min_hits);
      v_coverpoint_a.add_bins(bin((240, 241, 242, 243, 244)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5 * v_min_hits loop
        v_value := v_coverpoint_a.rand(SAMPLE_COV);
      end loop;

      check_bin(v_coverpoint_a, v_bin_idx, VAL, (200, 201, 202, 203, 204), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (210, 211, 212, 213, 214), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (220, 221, 222, 223, 224), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (230, 231, 232, 233, 234), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (240, 241, 242, 243, 244), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with a range of values");
      ------------------------------------------------------------
      v_min_hits := 3;
      increment_expected_alerts(TB_WARNING, 5); -- For adding bins after sampling warnings
      v_coverpoint_a.add_bins(bin_range(300, 309), v_min_hits);
      v_coverpoint_a.add_bins(bin_range(310, 319), v_min_hits);
      v_coverpoint_a.add_bins(bin_range(320, 329), v_min_hits);
      v_coverpoint_a.add_bins(bin_range(330, 339), v_min_hits);
      v_coverpoint_a.add_bins(bin_range(340, 349), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5 * v_min_hits loop
        v_value := v_coverpoint_a.rand(SAMPLE_COV);
      end loop;

      check_bin(v_coverpoint_a, v_bin_idx, RAN, (300, 309), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (310, 319), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (320, 329), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (330, 339), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (340, 349), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with a transition of values");
      ------------------------------------------------------------
      v_min_hits := 4;
      increment_expected_alerts(TB_WARNING, 5); -- For adding bins after sampling warnings
      v_coverpoint_a.add_bins(bin_transition((400, 402, 404, 406, 408)), v_min_hits);
      v_coverpoint_a.add_bins(bin_transition((410, 412, 414, 416, 418)), v_min_hits);
      v_coverpoint_a.add_bins(bin_transition((420, 422, 424, 426, 428)), v_min_hits);
      v_coverpoint_a.add_bins(bin_transition((438, 436, 434, 432, 430)), v_min_hits);
      v_coverpoint_a.add_bins(bin_transition((440, 443, 443, 447, 443)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5 * 5 * v_min_hits loop
        v_value := v_coverpoint_a.rand(SAMPLE_COV);
      end loop;

      check_bin(v_coverpoint_a, v_bin_idx, TRN, (400, 402, 404, 406, 408), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (410, 412, 414, 416, 418), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (420, 422, 424, 426, 428), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (438, 436, 434, 432, 430), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (440, 443, 443, 447, 443), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among different types of bins");
      ------------------------------------------------------------
      v_min_hits := 5;
      increment_expected_alerts(TB_WARNING, 4); -- For adding bins after sampling warnings
      v_coverpoint_a.add_bins(bin(60), v_min_hits);
      v_coverpoint_a.add_bins(bin((250, 251, 252, 253, 254)), v_min_hits);
      v_coverpoint_a.add_bins(bin_range(350, 359), v_min_hits);
      v_coverpoint_a.add_bins(bin_transition((450, 452, 452, 458, 455)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to (3 + 5) * v_min_hits loop
        v_value := v_coverpoint_a.rand(SAMPLE_COV);
      end loop;

      check_bin(v_coverpoint_a, v_bin_idx, VAL, 60, v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (250, 251, 252, 253, 254), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (350, 359), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (450, 452, 452, 458, 455), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_coverpoint_a);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing all bins are selected for randomization when coverage is complete");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNC_COV_RAND);

      log(ID_SEQUENCER, "Calling rand() 1000 times");
      for i in 1 to 1000 loop
        v_value := v_coverpoint_a.rand(SAMPLE_COV);
      end loop;

      -- By checking that the number of hits in the bins is greater than their minimum coverage,
      -- we can assure that every bin was selected for randomization after the previous tests.
      for i in 0 to v_bin_idx - 1 loop
        if i < 50 then
          check_bin_hits_is_greater(v_coverpoint_a, i, 1);
        elsif i < 55 then
          check_bin_hits_is_greater(v_coverpoint_a, i, 2);
        elsif i < 60 then
          check_bin_hits_is_greater(v_coverpoint_a, i, 3);
        elsif i < 65 then
          check_bin_hits_is_greater(v_coverpoint_a, i, 4);
        elsif i < 69 then
          check_bin_hits_is_greater(v_coverpoint_a, i, 5);
        else
          alert(TB_ERROR, "check_bin_hits_is_greater() => Unexpected bin_idx: " & to_string(i));
        end if;
      end loop;

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Checking that ignore and invalid bins were never selected during randomization");
      ------------------------------------------------------------
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 2000, hits => 0, name => "bin_0");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (2100, 2109), hits => 0, name => "bin_1");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (2201, 2203, 2205, 2209), hits => 0, name => "bin_2");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 3000, hits => 0, name => "bin_3");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (3100, 3109), hits => 0, name => "bin_4");
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (3201, 3203, 3205, 3209), hits => 0, name => "bin_5");

      v_coverpoint_a.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization weight - Adaptive");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNC_COV_RAND);

      -- The adaptive randomization weight will ensure that all bins are covered
      -- almost at the same time, i.e. around the same number of iterations.
      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(1), 100);
      v_coverpoint_b.add_bins(bin(2), 100);
      v_coverpoint_b.add_bins(bin(3), 100);
      v_coverpoint_b.add_bins(bin(4), 100);
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (400, 400, 400, 400));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(5), 100);
      v_coverpoint_b.add_bins(bin(6), 200);
      v_coverpoint_b.add_bins(bin(7), 300);
      v_coverpoint_b.add_bins(bin(8), 400);
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (1000, 1000, 1000, 1000));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(9), 500);
      v_coverpoint_b.add_bins(bin(10), 50);
      v_coverpoint_b.add_bins(bin(11), 50);
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (600, 600, 600));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (600, 600, 600));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (600, 600, 600));

      log(ID_LOG_HDR, "Testing randomization weight - Adaptive (using hits goal)");
      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.set_hits_coverage_goal(200);
      v_coverpoint_b.add_bins(bin(1), 100);
      v_coverpoint_b.add_bins(bin(2), 100);
      v_coverpoint_b.add_bins(bin(3), 100);
      v_coverpoint_b.add_bins(bin(4), 100);
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (400, 400, 400, 400));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.set_hits_coverage_goal(50);
      v_coverpoint_b.add_bins(bin(5), 100);
      v_coverpoint_b.add_bins(bin(6), 200);
      v_coverpoint_b.add_bins(bin(7), 300);
      v_coverpoint_b.add_bins(bin(8), 400);
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_coverpoint_b, ADAPTIVE, (1000, 1000, 1000, 1000));

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization weight - Explicit");
      ------------------------------------------------------------
      -- When using explicit randomization weights the bins will be covered
      -- at different times, depending also on the min_hits parameter.
      -- The iteration number when the bin will be covered can be estimated by
      -- using the formula: iteration = min_hits / probability
      -- Note that when a bin has been covered it will no longer be selected
      -- for randomization, so the probability for the other bins will change,
      -- which needs to be taken into account in the formula.
      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(12), 100, 1);
      v_coverpoint_b.add_bins(bin(13), 100, 1);
      v_coverpoint_b.add_bins(bin(14), 100, 1);
      v_coverpoint_b.add_bins(bin(15), 100, 1);
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 400, 400, 400));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 400, 400, 400));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 400, 400, 400));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(16), 100, 1); -- prob=0.10->0.16->0.33   iteration = 400
      v_coverpoint_b.add_bins(bin(17), 100, 2); -- prob=0.20->0.33->0.66   iteration = 300 + (100 - 250*0.2-(300-250)*0.33)/0.66 = 350
      v_coverpoint_b.add_bins(bin(18), 100, 3); -- prob=0.30->0.50         iteration = 250 + (100 - 250*0.3)/0.5 = 300
      v_coverpoint_b.add_bins(bin(19), 100, 4); -- prob=0.40               iteration = 100/0.4 = 250
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 350, 300, 250));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(20), 100, 100); -- prob=0.50               iteration = 100/0.5 = 200
      v_coverpoint_b.add_bins(bin(21), 100, 50); -- prob=0.25               iteration = 300
      v_coverpoint_b.add_bins(bin(22), 100, 50); -- prob=0.25               iteration = 300
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (200, 300, 300));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (200, 300, 300));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (200, 300, 300));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(23), 100, 1); -- prob=0.25               iteration = 100/0.25 = 400
      v_coverpoint_b.add_bins(bin(24), 200, 1); -- prob=0.25->0.33         iteration = 400 + (200 - 400*0.25)/0.33 = 700
      v_coverpoint_b.add_bins(bin(25), 300, 1); -- prob=0.25->0.33->0.50   iteration = 700 + (300 - 400*0.25-(700-400)*0.33)/0.5 = 900
      v_coverpoint_b.add_bins(bin(26), 400, 1); -- prob=0.25->0.33->0.50   iteration = 1000
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 700, 900, 1000));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(27), 100, 1);
      v_coverpoint_b.add_bins(bin(28), 200, 2);
      v_coverpoint_b.add_bins(bin(29), 300, 3);
      v_coverpoint_b.add_bins(bin(30), 400, 4);
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (1000, 1000, 1000, 1000));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.add_bins(bin(27), 100, 4); -- prob=0.40               iteration = 100/0.4 = 250
      v_coverpoint_b.add_bins(bin(28), 200, 3); -- prob=0.30->0.50         iteration = 250 + (200 - 250*0.3)/0.5 = 500
      v_coverpoint_b.add_bins(bin(29), 300, 2); -- prob=0.20->0.33->0.66   iteration = 500 + (300 - 250*0.2-(500-250)*0.33)/0.66 = 750
      v_coverpoint_b.add_bins(bin(30), 400, 1); -- prob=0.10->0.16->0.33   iteration = 1000
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (250, 500, 750, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (250, 500, 750, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (250, 500, 750, 1000));

      log(ID_LOG_HDR, "Testing randomization weight - Explicit (using hits goal)");
      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.set_hits_coverage_goal(200);
      v_coverpoint_b.add_bins(bin(16), 100, 1); -- prob=0.10->0.16->0.33   iteration = 400
      v_coverpoint_b.add_bins(bin(17), 100, 2); -- prob=0.20->0.33->0.66   iteration = 300 + (100 - 250*0.2-(300-250)*0.33)/0.66 = 350
      v_coverpoint_b.add_bins(bin(18), 100, 3); -- prob=0.30->0.50         iteration = 250 + (100 - 250*0.3)/0.5 = 300
      v_coverpoint_b.add_bins(bin(19), 100, 4); -- prob=0.40               iteration = 100/0.4 = 250
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 350, 300, 250));

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_b.set_hits_coverage_goal(50);
      v_coverpoint_b.add_bins(bin(23), 100, 1); -- prob=0.25               iteration = 100/0.25 = 400
      v_coverpoint_b.add_bins(bin(24), 200, 1); -- prob=0.25->0.33         iteration = 400 + (200 - 400*0.25)/0.33 = 700
      v_coverpoint_b.add_bins(bin(25), 300, 1); -- prob=0.25->0.33->0.50   iteration = 700 + (300 - 400*0.25-(700-400)*0.33)/0.5 = 900
      v_coverpoint_b.add_bins(bin(26), 400, 1); -- prob=0.25->0.33->0.50   iteration = 1000
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_coverpoint_b, EXPLICIT, (400, 700, 900, 1000));

      v_coverpoint_b.report_coverage(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_rand_cross" then
      --===================================================================================
      disable_log_msg(ID_FUNC_COV_SAMPLE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization doesn't select ignore or illegal bins");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin(2000), ignore_bin(2001), "bin_0");
      v_cross_x2.add_cross(ignore_bin_range(2100, 2109), ignore_bin_range(2110, 2115), "bin_1");
      v_cross_x2.add_cross(ignore_bin_transition((2201, 2203, 2205)), ignore_bin_transition((2212, 2214, 2216)), "bin_2");
      v_cross_x2.add_cross(illegal_bin(3000), illegal_bin(3001), "bin_3");
      v_cross_x2.add_cross(illegal_bin_range(3100, 3109), illegal_bin_range(3110, 3115), "bin_4");
      v_cross_x2.add_cross(illegal_bin_transition((3201, 3203, 3205)), illegal_bin_transition((3212, 3214, 3216)), "bin_5");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with single values");
      ------------------------------------------------------------
      v_min_hits := 1;
      v_cross_x2.add_cross(bin_range(1, 50, 0), bin(100));

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 50 * v_min_hits loop
        v_values_x2 := v_cross_x2.rand(NO_SAMPLE_COV);
        v_cross_x2.sample_coverage(v_values_x2);
      end loop;

      for i in 1 to 50 loop
        check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => i), (0 => 100), v_min_hits, hits => v_min_hits);
      end loop;
      check_coverage_completed(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with multiple values");
      ------------------------------------------------------------
      v_min_hits := 2;
      increment_expected_alerts(TB_WARNING, 5); -- For adding bins after sampling warnings
      v_cross_x2.add_cross(bin((200, 201, 202)), bin((205, 206, 207)), v_min_hits);
      v_cross_x2.add_cross(bin((210, 211, 212)), bin((215, 216, 217)), v_min_hits);
      v_cross_x2.add_cross(bin((220, 221, 222)), bin((225, 226, 227)), v_min_hits);
      v_cross_x2.add_cross(bin((230, 231, 232)), bin((235, 236, 237)), v_min_hits);
      v_cross_x2.add_cross(bin((240, 241, 242)), bin((245, 246, 247)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5 * v_min_hits loop
        v_values_x2 := v_cross_x2.rand(SAMPLE_COV);
      end loop;

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (200, 201, 202), (205, 206, 207), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (210, 211, 212), (215, 216, 217), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (220, 221, 222), (225, 226, 227), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (230, 231, 232), (235, 236, 237), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (240, 241, 242), (245, 246, 247), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with a range of values");
      ------------------------------------------------------------
      v_min_hits := 3;
      increment_expected_alerts(TB_WARNING, 5); -- For adding bins after sampling warnings
      v_cross_x2.add_cross(bin_range(300, 304), bin_range(305, 309), v_min_hits);
      v_cross_x2.add_cross(bin_range(310, 314), bin_range(315, 319), v_min_hits);
      v_cross_x2.add_cross(bin_range(320, 324), bin_range(325, 329), v_min_hits);
      v_cross_x2.add_cross(bin_range(330, 334), bin_range(335, 339), v_min_hits);
      v_cross_x2.add_cross(bin_range(340, 344), bin_range(345, 349), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5 * v_min_hits loop
        v_values_x2 := v_cross_x2.rand(SAMPLE_COV);
      end loop;

      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (300, 304), (305, 309), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (310, 314), (315, 319), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (320, 324), (325, 329), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (330, 334), (335, 339), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (340, 344), (345, 349), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with a transition of values");
      ------------------------------------------------------------
      v_min_hits := 4;
      increment_expected_alerts(TB_WARNING, 5); -- For adding bins after sampling warnings
      v_cross_x2.add_cross(bin_transition((400, 402, 404)), bin_transition((405, 407, 409)), v_min_hits);
      v_cross_x2.add_cross(bin_transition((410, 412, 414)), bin_transition((415, 417, 419)), v_min_hits);
      v_cross_x2.add_cross(bin_transition((420, 422, 424)), bin_transition((425, 427, 429)), v_min_hits);
      v_cross_x2.add_cross(bin_transition((430, 432, 434)), bin_transition((439, 437, 435)), v_min_hits);
      v_cross_x2.add_cross(bin_transition((440, 442, 442)), bin_transition((445, 445, 449)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 3 * 5 * v_min_hits loop
        v_values_x2 := v_cross_x2.rand(SAMPLE_COV);
      end loop;

      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (400, 402, 404), (405, 407, 409), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (410, 412, 414), (415, 417, 419), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (420, 422, 424), (425, 427, 429), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (430, 432, 434), (439, 437, 435), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (440, 442, 442), (445, 445, 449), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among different types of bins");
      ------------------------------------------------------------
      v_min_hits := 5;
      increment_expected_alerts(TB_WARNING, 4); -- For adding bins after sampling warnings
      v_cross_x2.add_cross(bin(60), bin((250, 251, 252, 253, 254)), v_min_hits);
      v_cross_x2.add_cross(bin(70), bin_range(352, 355), v_min_hits);
      v_cross_x2.add_cross(bin_transition((450, 452, 454, 456, 458)), bin(80), v_min_hits);
      v_cross_x2.add_cross(bin_range(360, 369), bin_transition((466, 463, 463, 464, 461)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to (2 + 5 * 2) * v_min_hits loop
        v_values_x2 := v_cross_x2.rand(SAMPLE_COV);
      end loop;

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 60), (250, 251, 252, 253, 254), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, RAN), (0 => 70), (352, 355), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, VAL), (450, 452, 454, 456, 458), (0 => 80), v_min_hits, hits => v_min_hits);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, TRN), (360, 369), (466, 463, 463, 464, 461), v_min_hits, hits => v_min_hits);
      check_coverage_completed(v_cross_x2);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing all bins are selected for randomization when coverage is complete");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNC_COV_RAND);

      log(ID_SEQUENCER, "Calling rand() 1000 times");
      for i in 1 to 1000 loop
        v_values_x2 := v_cross_x2.rand(SAMPLE_COV);
      end loop;

      -- By checking that the number of hits in the bins is greater than their minimum coverage,
      -- we can assure that every bin was selected for randomization after the previous tests.
      for i in 0 to v_bin_idx - 1 loop
        if i < 50 then
          check_bin_hits_is_greater(v_cross_x2, i, 1);
        elsif i < 55 then
          check_bin_hits_is_greater(v_cross_x2, i, 2);
        elsif i < 60 then
          check_bin_hits_is_greater(v_cross_x2, i, 3);
        elsif i < 65 then
          check_bin_hits_is_greater(v_cross_x2, i, 4);
        elsif i < 69 then
          check_bin_hits_is_greater(v_cross_x2, i, 5);
        else
          alert(TB_ERROR, "check_bin_hits_is_greater() => Unexpected bin_idx: " & to_string(i));
        end if;
      end loop;

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Checking that ignore and invalid bins were never selected during randomization");
      ------------------------------------------------------------
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => 2000), (0 => 2001), hits => 0, name => "bin_0");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN_IGNORE), (2100, 2109), (2110, 2115), hits => 0, name => "bin_1");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (2201, 2203, 2205), (2212, 2214, 2216), hits => 0, name => "bin_2");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => 3000), (0 => 3001), hits => 0, name => "bin_3");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_ILLEGAL, RAN_ILLEGAL), (3100, 3109), (3110, 3115), hits => 0, name => "bin_4");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (3201, 3203, 3205), (3212, 3214, 3216), hits => 0, name => "bin_5");

      v_cross_x2.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization weight - Adaptive");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNC_COV_RAND);

      -- The adaptive randomization weight will ensure that all bins are covered
      -- almost at the same time, i.e. around the same number of iterations.
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(1), bin(100), 100);
      v_cross_x2_b.add_cross(bin(2), bin(100), 100);
      v_cross_x2_b.add_cross(bin(3), bin(100), 100);
      v_cross_x2_b.add_cross(bin(4), bin(100), 100);
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (400, 400, 400, 400));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(5), bin(200), 100);
      v_cross_x2_b.add_cross(bin(6), bin(200), 200);
      v_cross_x2_b.add_cross(bin(7), bin(200), 300);
      v_cross_x2_b.add_cross(bin(8), bin(200), 400);
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (1000, 1000, 1000, 1000));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(9), bin(300), 500);
      v_cross_x2_b.add_cross(bin(10), bin(300), 50);
      v_cross_x2_b.add_cross(bin(11), bin(300), 50);
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (600, 600, 600));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (600, 600, 600));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (600, 600, 600));

      log(ID_LOG_HDR, "Testing randomization weight - Adaptive (using hits goal)");
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.set_hits_coverage_goal(200);
      v_cross_x2_b.add_cross(bin(1), bin(100), 100);
      v_cross_x2_b.add_cross(bin(2), bin(100), 100);
      v_cross_x2_b.add_cross(bin(3), bin(100), 100);
      v_cross_x2_b.add_cross(bin(4), bin(100), 100);
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (400, 400, 400, 400));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (400, 400, 400, 400));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.set_hits_coverage_goal(50);
      v_cross_x2_b.add_cross(bin(5), bin(200), 100);
      v_cross_x2_b.add_cross(bin(6), bin(200), 200);
      v_cross_x2_b.add_cross(bin(7), bin(200), 300);
      v_cross_x2_b.add_cross(bin(8), bin(200), 400);
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_cross_x2_b, ADAPTIVE, (1000, 1000, 1000, 1000));

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization weight - Explicit");
      ------------------------------------------------------------
      -- When using explicit randomization weights the bins will be covered
      -- at different times, depending also on the min_hits parameter.
      -- The iteration number when the bin will be covered can be estimated by
      -- using the formula: iteration = min_hits / probability
      -- Note that when a bin has been covered it will no longer be selected
      -- for randomization, so the probability for the other bins will change,
      -- which needs to be taken into account in the formula.
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(12), bin(400), 100, 1);
      v_cross_x2_b.add_cross(bin(13), bin(400), 100, 1);
      v_cross_x2_b.add_cross(bin(14), bin(400), 100, 1);
      v_cross_x2_b.add_cross(bin(15), bin(400), 100, 1);
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 400, 400, 400));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 400, 400, 400));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 400, 400, 400));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(16), bin(500), 100, 1); -- prob=0.10->0.16->0.33   iteration = 400
      v_cross_x2_b.add_cross(bin(17), bin(500), 100, 2); -- prob=0.20->0.33->0.66   iteration = 300 + (100 - 250*0.2-(300-250)*0.33)/0.66 = 350
      v_cross_x2_b.add_cross(bin(18), bin(500), 100, 3); -- prob=0.30->0.50         iteration = 250 + (100 - 250*0.3)/0.5 = 300
      v_cross_x2_b.add_cross(bin(19), bin(500), 100, 4); -- prob=0.40               iteration = 100/0.4 = 250
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 350, 300, 250));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(20), bin(600), 100, 100); -- prob=0.50               iteration = 100/0.5 = 200
      v_cross_x2_b.add_cross(bin(21), bin(600), 100, 50); -- prob=0.25               iteration = 300
      v_cross_x2_b.add_cross(bin(22), bin(600), 100, 50); -- prob=0.25               iteration = 300
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (200, 300, 300));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (200, 300, 300));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (200, 300, 300));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(23), bin(700), 100, 1); -- prob=0.25               iteration = 100/0.25 = 400
      v_cross_x2_b.add_cross(bin(24), bin(700), 200, 1); -- prob=0.25->0.33         iteration = 400 + (200 - 400*0.25)/0.33 = 700
      v_cross_x2_b.add_cross(bin(25), bin(700), 300, 1); -- prob=0.25->0.33->0.50   iteration = 700 + (300 - 400*0.25-(700-400)*0.33)/0.5 = 900
      v_cross_x2_b.add_cross(bin(26), bin(700), 400, 1); -- prob=0.25->0.33->0.50   iteration = 1000
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 700, 900, 1000));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(27), bin(800), 100, 1);
      v_cross_x2_b.add_cross(bin(28), bin(800), 200, 2);
      v_cross_x2_b.add_cross(bin(29), bin(800), 300, 3);
      v_cross_x2_b.add_cross(bin(30), bin(800), 400, 4);
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (1000, 1000, 1000, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (1000, 1000, 1000, 1000));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(27), bin(900), 100, 4); -- prob=0.40               iteration = 100/0.4 = 250
      v_cross_x2_b.add_cross(bin(28), bin(900), 200, 3); -- prob=0.30->0.50         iteration = 250 + (200 - 250*0.3)/0.5 = 500
      v_cross_x2_b.add_cross(bin(29), bin(900), 300, 2); -- prob=0.20->0.33->0.66   iteration = 500 + (300 - 250*0.2-(500-250)*0.33)/0.66 = 750
      v_cross_x2_b.add_cross(bin(30), bin(900), 400, 1); -- prob=0.10->0.16->0.33   iteration = 1000
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (250, 500, 750, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (250, 500, 750, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (250, 500, 750, 1000));

      log(ID_LOG_HDR, "Testing randomization weight - Explicit (using hits goal)");
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.set_hits_coverage_goal(200);
      v_cross_x2_b.add_cross(bin(16), bin(500), 100, 1); -- prob=0.10->0.16->0.33   iteration = 400
      v_cross_x2_b.add_cross(bin(17), bin(500), 100, 2); -- prob=0.20->0.33->0.66   iteration = 300 + (100 - 250*0.2-(300-250)*0.33)/0.66 = 350
      v_cross_x2_b.add_cross(bin(18), bin(500), 100, 3); -- prob=0.30->0.50         iteration = 250 + (100 - 250*0.3)/0.5 = 300
      v_cross_x2_b.add_cross(bin(19), bin(500), 100, 4); -- prob=0.40               iteration = 100/0.4 = 250
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 350, 300, 250));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 350, 300, 250));

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.set_hits_coverage_goal(50);
      v_cross_x2_b.add_cross(bin(23), bin(700), 100, 1); -- prob=0.25               iteration = 100/0.25 = 400
      v_cross_x2_b.add_cross(bin(24), bin(700), 200, 1); -- prob=0.25->0.33         iteration = 400 + (200 - 400*0.25)/0.33 = 700
      v_cross_x2_b.add_cross(bin(25), bin(700), 300, 1); -- prob=0.25->0.33->0.50   iteration = 700 + (300 - 400*0.25-(700-400)*0.33)/0.5 = 900
      v_cross_x2_b.add_cross(bin(26), bin(700), 400, 1); -- prob=0.25->0.33->0.50   iteration = 1000
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 700, 900, 1000));
      randomize_and_check_distribution(v_cross_x2_b, EXPLICIT, (400, 700, 900, 1000));

      v_cross_x2_b.report_coverage(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_database" then
      --===================================================================================
      -- 1. Load from non-existing file
      -- 2. Write sampled coverpoint to file1
      -- 3. Write sampled cross to file2
      -- 4. Write sampled max-sized cross to file3
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load database from a non-existing file");
      ------------------------------------------------------------
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_coverpoint_a.load_coverage_db("dummy.txt");
      v_coverpoint_a.clear_coverage(VOID);

      increment_expected_alerts(TB_NOTE, 1);
      v_cross_x2.load_coverage_db("dummy.txt", alert_level_if_not_found => TB_NOTE);
      v_cross_x2.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing write database to a file - coverpoint");
      ------------------------------------------------------------
      -- Add bins
      v_coverpoint_a.add_bins(bin(10));
      v_coverpoint_a.add_bins(bin(20), 8, 20, "single");
      v_coverpoint_a.add_bins(bin((30, 35, 39)), 9, 30, "multiple");
      v_coverpoint_a.add_bins(bin_range(40, 49, 2), 15, 40, "range");
      v_coverpoint_a.add_bins(bin_transition((50, 51, 52, 53, 54, 55, 56, 57, 58, 59)), 5, 50, "transition");
      v_coverpoint_a.add_bins(ignore_bin(100));
      v_coverpoint_a.add_bins(ignore_bin(110), 1000, 500, "ignore_single");
      v_coverpoint_a.add_bins(ignore_bin_range(121, 125), 1000, 500, "ignore_range");
      v_coverpoint_a.add_bins(ignore_bin_transition((132, 134, 136, 138)), 1000, 500, "ignore_transition");
      v_coverpoint_a.add_bins(illegal_bin(200));
      v_coverpoint_a.add_bins(illegal_bin(210), 1000, 500, "illegal_single");
      v_coverpoint_a.add_bins(illegal_bin_range(226, 229), 1000, 500, "illegal_range");
      v_coverpoint_a.add_bins(illegal_bin_transition((231, 237, 237, 238, 235, 231)), 1000, 500, "illegal_transition");

      -- Set configuration
      v_coverpoint_a.set_name("MY_COVERPOINT");
      v_coverpoint_a.set_scope("MY_SCOPE");
      v_coverpoint_a.set_illegal_bin_alert_level(TB_NOTE);
      v_coverpoint_a.set_bin_overlap_alert_level(TB_WARNING);
      v_coverpoint_a.set_overall_coverage_weight(5);
      v_coverpoint_a.set_bins_coverage_goal(50);
      v_coverpoint_a.set_hits_coverage_goal(200);
      fc_set_covpts_coverage_goal(80);

      -- Sample coverage
      increment_expected_alerts(TB_NOTE, 6);
      sample_bins(v_coverpoint_a, (20), 2);
      sample_bins(v_coverpoint_a, (30, 35, 39), 1);
      sample_bins(v_coverpoint_a, (40, 41, 42, 43, 44), 1);
      sample_bins(v_coverpoint_a, (45, 46, 47, 48, 49), 1);
      sample_bins(v_coverpoint_a, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 1);
      sample_bins(v_coverpoint_a, (110), 1);
      sample_bins(v_coverpoint_a, (121, 122, 123, 124, 125), 1);
      sample_bins(v_coverpoint_a, (132, 134, 136, 138), 2);
      sample_bins(v_coverpoint_a, (210), 1);
      sample_bins(v_coverpoint_a, (226, 227, 228, 229), 1);
      sample_bins(v_coverpoint_a, (231, 237, 237, 238, 235, 231), 1);

      v_coverpoint_a.report_coverage(VERBOSE); -- Bins: 0.0% / 0.0%, Hits: 30.19% / 15.09%
      write_coverage_db_quiet(v_coverpoint_a, GC_FILE_PATH & "db_coverpoint.txt");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing write database to a file - cross");
      ------------------------------------------------------------
      -- Add bins
      v_cross_x2.add_cross(bin(10), bin(1010));
      v_cross_x2.add_cross(bin(20), bin(1020), 8, 20, "single");
      v_cross_x2.add_cross(bin((30, 35, 39)), bin((1030, 1035, 1039)), 9, 30, "multiple");
      v_cross_x2.add_cross(bin_range(40, 49, 2), bin_range(1040, 1049), 15, 40, "range");
      v_cross_x2.add_cross(bin_transition((50, 51, 52, 53, 54, 55)), bin_transition((1050, 1051, 1052, 1053, 1054, 1055)), 5, 50, "transition");
      v_cross_x2.add_cross(ignore_bin(100), ignore_bin(1100));
      v_cross_x2.add_cross(ignore_bin(110), ignore_bin(1110), 1000, 500, "ignore_single");
      v_cross_x2.add_cross(ignore_bin_range(121, 125), ignore_bin_range(1121, 1125), 1000, 500, "ignore_range");
      v_cross_x2.add_cross(ignore_bin_transition((132, 134, 136, 138)), ignore_bin_transition((1132, 1134, 1136, 1138)), 1000, 500, "ignore_transition");
      v_cross_x2.add_cross(illegal_bin(200), illegal_bin(1200));
      v_cross_x2.add_cross(illegal_bin(210), illegal_bin(1210), 1000, 500, "illegal_single");
      v_cross_x2.add_cross(illegal_bin_range(226, 229), illegal_bin_range(1226, 1229), 1000, 500, "illegal_range");
      v_cross_x2.add_cross(illegal_bin_transition((231, 237, 237)), illegal_bin_transition((1231, 1237, 1237)), 1000, 500, "illegal_transition");

      -- Set configuration
      v_cross_x2.set_name("MY_CROSS");
      v_cross_x2.set_scope("NEW_SCOPE");
      v_cross_x2.set_illegal_bin_alert_level(TB_WARNING);
      v_cross_x2.set_bin_overlap_alert_level(TB_ERROR);
      v_cross_x2.set_overall_coverage_weight(8);
      v_cross_x2.set_bins_coverage_goal(50);
      v_cross_x2.set_hits_coverage_goal(75);
      fc_set_covpts_coverage_goal(90);

      -- Sample coverage
      increment_expected_alerts(TB_WARNING, 6);
      sample_cross_bins(v_cross_x2, (0 => (20, 1020)), 2);
      sample_cross_bins(v_cross_x2, ((30, 1030), (35, 1035), (39, 1039)), 1);
      sample_cross_bins(v_cross_x2, ((40, 1040), (41, 1041), (42, 1042), (43, 1043), (44, 1044)), 1);
      sample_cross_bins(v_cross_x2, ((45, 1045), (46, 1046), (47, 1047), (48, 1048), (49, 1049)), 1);
      sample_cross_bins(v_cross_x2, ((50, 1050), (51, 1051), (52, 1052), (53, 1053), (54, 1054), (55, 1055)), 1);
      sample_cross_bins(v_cross_x2, (0 => (110, 1110)), 1);
      sample_cross_bins(v_cross_x2, ((121, 1121), (122, 1122), (123, 1123), (124, 1124), (125, 1125)), 1);
      sample_cross_bins(v_cross_x2, ((132, 1132), (134, 1134), (136, 1136), (138, 1138)), 2);
      sample_cross_bins(v_cross_x2, (0 => (210, 1210)), 1);
      sample_cross_bins(v_cross_x2, ((226, 1226), (227, 1227), (228, 1228), (229, 1229)), 1);
      sample_cross_bins(v_cross_x2, ((231, 1231), (237, 1237), (237, 1237)), 1);

      v_cross_x2.report_coverage(VERBOSE); -- Bins: 0.0% / 0.0%, Hits: 30.19% / 40.25%
      write_coverage_db_quiet(v_cross_x2, GC_FILE_PATH & "db_cross.txt");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing write database to a file - max data");
      ------------------------------------------------------------
      -- Add bins
      v_cross_x3.add_cross(bin_range(1, 100, 0), bin(200), bin(300)); -- TODO: use 16-cross

      -- Sample coverage
      for i in 1 to 25 loop
        v_cross_x3.sample_coverage((i, 200, 300));
      end loop;

      v_cross_x3.report_coverage(VERBOSE); -- Bins: 25.00%, Hits: 25.00%
      write_coverage_db_quiet(v_cross_x3, GC_FILE_PATH & "db_cross_max.txt");

      fc_report_overall_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing adding bins after sampling");
      ------------------------------------------------------------
      increment_expected_alerts(TB_WARNING, 1);
      v_coverpoint_b.add_bins(bin(10));
      v_coverpoint_b.sample_coverage(10);
      v_coverpoint_b.add_bins(bin(10));
      v_bin_idx := 0;
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 10, hits => 1);
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 10, hits => 0);

      log(ID_SEQUENCER, "Check bins can be safely added after clearing the coverage");
      v_coverpoint_b.clear_coverage(VOID);
      v_coverpoint_b.add_bins(bin(10));
      check_value(v_coverpoint_b.get_num_valid_bins(VOID), 3, ERROR, "Checking number of valid bins");

      increment_expected_alerts(TB_WARNING, 1);
      v_cross_x2_b.add_cross(bin(10), bin(1010));
      v_cross_x2_b.sample_coverage((10, 1010));
      v_cross_x2_b.add_cross(bin(10), bin(1010));
      v_bin_idx := 0;
      check_cross_bin(v_cross_x2_b, v_bin_idx, (VAL, VAL), (0 => 10), (0 => 1010), hits => 1);
      check_cross_bin(v_cross_x2_b, v_bin_idx, (VAL, VAL), (0 => 10), (0 => 1010), hits => 0);

      log(ID_SEQUENCER, "Check bins can be safely added after deleting the coverpoint");
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(10), bin(1010));
      check_value(v_cross_x2_b.get_num_valid_bins(VOID), 1, ERROR, "Checking number of valid bins");

      v_coverpoint_b.delete_coverpoint(VOID);
      v_cross_x2_b.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing adding bins after load_coverage_db()");
      ------------------------------------------------------------
      increment_expected_alerts(TB_WARNING, 1);
      load_coverage_db_quiet(v_coverpoint_b, GC_FILE_PATH & "db_coverpoint.txt");
      v_coverpoint_b.add_bins(bin(10));
      check_value(v_coverpoint_b.get_num_valid_bins(VOID), 7, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Check bins can be safely added after clearing the coverage");
      v_coverpoint_b.clear_coverage(VOID);
      v_coverpoint_b.add_bins(bin(10));
      check_value(v_coverpoint_b.get_num_valid_bins(VOID), 8, ERROR, "Checking number of valid bins");

      increment_expected_alerts(TB_WARNING, 1);
      load_coverage_db_quiet(v_cross_x2_b, GC_FILE_PATH & "db_cross.txt");
      v_cross_x2_b.add_cross(bin(10), bin(1010));
      check_value(v_cross_x2_b.get_num_valid_bins(VOID), 7, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Check bins can be safely added after deleting the coverpoint");
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x2_b.add_cross(bin(10), bin(1010));
      check_value(v_cross_x2_b.get_num_valid_bins(VOID), 1, ERROR, "Checking number of valid bins");

      v_coverpoint_b.delete_coverpoint(VOID);
      v_cross_x2_b.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing sampling before load_coverage_db()");
      ------------------------------------------------------------
      increment_expected_alerts(TB_WARNING, 1);
      v_coverpoint_b.add_bins(bin(10));
      v_coverpoint_b.sample_coverage(10);
      load_coverage_db_quiet(v_coverpoint_b, GC_FILE_PATH & "db_coverpoint.txt");
      v_bin_idx := 0;
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 10, name => "bin_0", hits => 0);

      increment_expected_alerts(TB_WARNING, 1);
      load_coverage_db_quiet(v_coverpoint_c, GC_FILE_PATH & "db_coverpoint.txt");
      load_coverage_db_quiet(v_coverpoint_c, GC_FILE_PATH & "db_coverpoint.txt");

      log(ID_SEQUENCER, "Check DB can be safely loaded after clearing the coverage");
      v_coverpoint_d.add_bins(bin(10));
      v_coverpoint_d.sample_coverage(10);
      v_coverpoint_d.clear_coverage(VOID);
      load_coverage_db_quiet(v_coverpoint_d, GC_FILE_PATH & "db_coverpoint.txt");

      log(ID_SEQUENCER, "Check DB can be safely loaded after deleting the coverpoint");
      v_coverpoint_e.add_bins(bin(10));
      v_coverpoint_e.sample_coverage(10);
      v_coverpoint_e.delete_coverpoint(VOID);
      load_coverage_db_quiet(v_coverpoint_e, GC_FILE_PATH & "db_coverpoint.txt");

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_c.delete_coverpoint(VOID);
      v_coverpoint_d.delete_coverpoint(VOID);
      v_coverpoint_e.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing loading to coverpoint with different num_bins_crossed");
      ------------------------------------------------------------
      v_cross_x2_b.add_cross(bin(1), bin(2));
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      load_coverage_db_quiet(v_cross_x2_b, GC_FILE_PATH & "db_coverpoint.txt");

      v_cross_x2_b.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing accumulated testcases counter");
      ------------------------------------------------------------
      v_coverpoint_a.load_coverage_db("dummy.txt", alert_level_if_not_found => NO_ALERT);
      v_coverpoint_a.report_coverage(VOID);
      fc_report_overall_coverage(VERBOSE);

      load_coverage_db_quiet(v_coverpoint_b, GC_FILE_PATH & "db_coverpoint.txt");
      fc_report_overall_coverage(VERBOSE);
      write_coverage_db_quiet(v_coverpoint_b, GC_FILE_PATH & "db_coverpoint.txt");

      load_coverage_db_quiet(v_coverpoint_c, GC_FILE_PATH & "db_coverpoint.txt");
      fc_report_overall_coverage(VERBOSE);
      write_coverage_db_quiet(v_coverpoint_c, GC_FILE_PATH & "db_coverpoint.txt");

      load_coverage_db_quiet(v_coverpoint_d, GC_FILE_PATH & "db_coverpoint.txt");
      fc_report_overall_coverage(VERBOSE);

      log(ID_SEQUENCER, "Check accumulated testcases counter is reset after clearing the coverage");
      v_coverpoint_c.clear_coverage(VOID);
      v_coverpoint_c.report_coverage(VOID);
      fc_report_overall_coverage(VERBOSE);

      log(ID_SEQUENCER, "Check accumulated testcases counter is reset after deleting the coverpoint");
      v_coverpoint_d.delete_coverpoint(VOID);
      v_coverpoint_d.report_coverage(VOID);
      fc_report_overall_coverage(VERBOSE);

      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_c.delete_coverpoint(VOID);
      v_coverpoint_d.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing clearing a coverpoint's coverage");
      ------------------------------------------------------------
      v_coverpoint_a.set_illegal_bin_alert_level(TB_ERROR);
      sample_bins(v_coverpoint_a, (231, 237, 237), 1);
      v_coverpoint_a.clear_coverage(VOID);
      sample_bins(v_coverpoint_a, (238, 235, 231), 1); -- To test transition_mask is cleared

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 10, name => "bin_0", hits => 0);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 20, 8, 20, "single", hits => 0);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (30, 35, 39), 9, 30, "multiple", hits => 0);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (40, 44), 15, 40, "range", hits => 0);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (45, 49), 15, 40, "range", hits => 0);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 5, 50, "transition", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 100, "bin_6", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 110, "ignore_single", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (121, 125), "ignore_range", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (132, 134, 136, 138), "ignore_transition", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 200, "bin_10", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 210, "illegal_single", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (226, 229), "illegal_range", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (231, 237, 237, 238, 235, 231), "illegal_transition", hits => 0);
      check_bins_coverage(v_coverpoint_a, 0.0);
      check_bins_coverage(v_coverpoint_a, 0.0, use_goal => true);
      check_hits_coverage(v_coverpoint_a, 0.0);
      check_hits_coverage(v_coverpoint_a, 0.0, use_goal => true);
      v_coverpoint_a.report_coverage(VERBOSE);

      v_coverpoint_a.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing accumulating coverage in random order - WARNING_ON_NEW_BINS");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(1) & bin(2));
      sample_bins(v_coverpoint_a, (1, 2), 3);
      v_coverpoint_a.write_coverage_db("db_accumulated.txt");

      log(ID_SEQUENCER, "Load to empty coverpoint");
      v_coverpoint_b.load_coverage_db("db_accumulated.txt");
      v_bin_idx := 0;
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_value(v_coverpoint_b.get_num_valid_bins(VOID), 2, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with same bins");
      v_coverpoint_c.add_bins(bin(1) & bin(2));
      v_coverpoint_c.load_coverage_db("db_accumulated.txt");
      v_bin_idx := 0;
      check_bin(v_coverpoint_c, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_coverpoint_c, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_value(v_coverpoint_c.get_num_valid_bins(VOID), 2, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with same bins, but different name");
      v_coverpoint_d.add_bins(bin(1) & bin(2), "new_bins");
      v_coverpoint_d.load_coverage_db("db_accumulated.txt");
      v_bin_idx := 0;
      check_bin(v_coverpoint_d, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_coverpoint_d, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_value(v_coverpoint_d.get_num_valid_bins(VOID), 2, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with one of the same bins");
      v_coverpoint_e.add_bins(bin(1));
      v_coverpoint_e.load_coverage_db("db_accumulated.txt");
      v_bin_idx := 0;
      check_bin(v_coverpoint_e, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_coverpoint_e, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_value(v_coverpoint_e.get_num_valid_bins(VOID), 2, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with same bins plus an extra bin");
      increment_expected_alerts(TB_WARNING, 1);
      v_cross_x2_b.add_bins(bin(1) & bin(2) & bin(3));
      v_cross_x2_b.load_coverage_db("db_accumulated.txt"); -- ALERT of new bin_3
      v_bin_idx := 0;
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 3, name => "bin_2", hits => 0);
      check_value(v_cross_x2_b.get_num_valid_bins(VOID), 3, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with same bins, but different min_hits");
      increment_expected_alerts(TB_WARNING, 2);
      v_cross_x3_b.add_bins(bin(1) & bin(2), 10);
      v_cross_x3_b.load_coverage_db("db_accumulated.txt"); -- ALERT of mismatching bin_1 and bin_2
      v_bin_idx := 0;
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 1, min_hits => 10, name => "bin_0", hits => 0);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 2, min_hits => 10, name => "bin_1", hits => 0);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 1, min_hits => 1, name => "bin_0", hits => 3);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 2, min_hits => 1, name => "bin_1", hits => 3);
      check_value(v_cross_x3_b.get_num_valid_bins(VOID), 4, ERROR, "Checking number of valid bins");

      v_coverpoint_a.delete_coverpoint(VOID);
      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_c.delete_coverpoint(VOID);
      v_coverpoint_d.delete_coverpoint(VOID);
      v_coverpoint_e.delete_coverpoint(VOID);
      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x3_b.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing accumulating coverage in random order - ERROR_ON_NEW_BINS");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Load to coverpoint with same bins plus an extra bin");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      v_cross_x2_b.add_bins(bin(1) & bin(2) & bin(3));
      v_cross_x2_b.load_coverage_db("db_accumulated.txt", ERROR_ON_NEW_BINS); -- ALERT of new bin_3
      v_bin_idx := 0;
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 3, name => "bin_2", hits => 0);
      check_value(v_cross_x2_b.get_num_valid_bins(VOID), 3, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with same bins, but different min_hits");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 2);
      v_cross_x3_b.add_bins(bin(1) & bin(2), 10);
      v_cross_x3_b.load_coverage_db("db_accumulated.txt", ERROR_ON_NEW_BINS); -- ALERT of mismatching bin_1 and bin_2
      v_bin_idx := 0;
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 1, min_hits => 10, name => "bin_0", hits => 0);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 2, min_hits => 10, name => "bin_1", hits => 0);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 1, min_hits => 1, name => "bin_0", hits => 3);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 2, min_hits => 1, name => "bin_1", hits => 3);
      check_value(v_cross_x3_b.get_num_valid_bins(VOID), 4, ERROR, "Checking number of valid bins");

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x3_b.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing accumulating coverage in random order - NO_ALERT_ON_NEW_BINS");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Load to coverpoint with same bins plus an extra bin");
      v_cross_x2_b.add_bins(bin(1) & bin(2) & bin(3));
      v_cross_x2_b.load_coverage_db("db_accumulated.txt", NO_ALERT_ON_NEW_BINS);
      v_bin_idx := 0;
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 1, name => "bin_0", hits => 3);
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 2, name => "bin_1", hits => 3);
      check_bin(v_cross_x2_b, v_bin_idx, VAL, 3, name => "bin_2", hits => 0);
      check_value(v_cross_x2_b.get_num_valid_bins(VOID), 3, ERROR, "Checking number of valid bins");

      log(ID_SEQUENCER, "Load to coverpoint with same bins, but different min_hits");
      v_cross_x3_b.add_bins(bin(1) & bin(2), 10);
      v_cross_x3_b.load_coverage_db("db_accumulated.txt", NO_ALERT_ON_NEW_BINS);
      v_bin_idx := 0;
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 1, min_hits => 10, name => "bin_0", hits => 0);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 2, min_hits => 10, name => "bin_1", hits => 0);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 1, min_hits => 1, name => "bin_0", hits => 3);
      check_bin(v_cross_x3_b, v_bin_idx, VAL, 2, min_hits => 1, name => "bin_1", hits => 3);
      check_value(v_cross_x3_b.get_num_valid_bins(VOID), 4, ERROR, "Checking number of valid bins");

      v_cross_x2_b.delete_coverpoint(VOID);
      v_cross_x3_b.delete_coverpoint(VOID);

    --===================================================================================
    elsif GC_TESTCASE = "fc_database_2" then
      -- IMPORTANT: This testcase must be run after fc_database since it checks the accumulated
      -- coverage when running testcases in sequence
      --===================================================================================
      -- 1. Load coverpoint from file1, check, sample and write back to file1
      -- 2. Load cross from file2, check, sample and write back to file2
      -- 3. Load max-sized cross from file3, check, sample and write back to file3
      -- 4. Load coverpoint from file1 into coverpoint_b, check and sample
      -- 5. Load cross from file2 into cross_b, check and sample
      -- 6. Load max-sized cross from file3 into max-sized cross_b, check and sample
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load and write database from a file - coverpoint");
      ------------------------------------------------------------
      load_coverage_db_quiet(v_coverpoint_a, GC_FILE_PATH & "db_coverpoint.txt", report_verbosity => NON_VERBOSE);

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 10, name => "bin_0", hits => 0);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, 20, 8, 20, "single", hits => 2);
      check_bin(v_coverpoint_a, v_bin_idx, VAL, (30, 35, 39), 9, 30, "multiple", hits => 3);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (40, 44), 15, 40, "range", hits => 5);
      check_bin(v_coverpoint_a, v_bin_idx, RAN, (45, 49), 15, 40, "range", hits => 5);
      check_bin(v_coverpoint_a, v_bin_idx, TRN, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 5, 50, "transition", hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 100, "bin_6", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_IGNORE, 110, "ignore_single", hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_IGNORE, (121, 125), "ignore_range", hits => 5);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_IGNORE, (132, 134, 136, 138), "ignore_transition", hits => 2);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 200, "bin_10", hits => 0);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, VAL_ILLEGAL, 210, "illegal_single", hits => 1);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, RAN_ILLEGAL, (226, 229), "illegal_range", hits => 4);
      check_invalid_bin(v_coverpoint_a, v_invalid_bin_idx, TRN_ILLEGAL, (231, 237, 237, 238, 235, 231), "illegal_transition", hits => 1);
      check_num_bins(v_coverpoint_a, 6, 8);
      check_bins_coverage(v_coverpoint_a, 0.0);
      check_bins_coverage(v_coverpoint_a, 0.0, use_goal => true); -- goal=50
      check_hits_coverage(v_coverpoint_a, 30.19);
      check_hits_coverage(v_coverpoint_a, 15.09, use_goal => true); -- goal=200
      check_value(v_coverpoint_a.get_num_bins_crossed(VOID), 1, ERROR, "Checking num_bins_crossed");

      -- Check configuration
      check_value(v_coverpoint_a.get_name(VOID), "MY_COVERPOINT", ERROR, "Checking name");
      check_value(v_coverpoint_a.get_scope(VOID), "MY_SCOPE", ERROR, "Checking scope");
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = TB_NOTE, ERROR, "Checking illegal bin alert level");
      check_value(v_coverpoint_a.get_bin_overlap_alert_level(VOID) = TB_WARNING, ERROR, "Checking bin overlap alert level");
      check_value(v_coverpoint_a.get_overall_coverage_weight(VOID), 5, ERROR, "Checking coverage weight");
      check_value(v_coverpoint_a.get_bins_coverage_goal(VOID), 50, ERROR, "Checking bins coverage goal");
      check_value(v_coverpoint_a.get_hits_coverage_goal(VOID), 200, ERROR, "Checking hits coverage goal");
      check_value(fc_get_covpts_coverage_goal(VOID), 80, ERROR, "Checking coverpoints coverage goal");
      v_seeds := v_coverpoint_a.get_rand_seeds(VOID);
      check_value(v_seeds(0) /= C_RAND_INIT_SEED_1, ERROR, "Checking seed 1");
      check_value(v_seeds(1) /= C_RAND_INIT_SEED_2, ERROR, "Checking seed 2");

      -- Sample coverage
      increment_expected_alerts(TB_NOTE, 6);
      sample_bins(v_coverpoint_a, (20), 2);
      sample_bins(v_coverpoint_a, (30, 35, 39), 1);
      sample_bins(v_coverpoint_a, (40, 41, 42, 43, 44), 1);
      sample_bins(v_coverpoint_a, (45, 46, 47, 48, 49), 1);
      sample_bins(v_coverpoint_a, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 1);
      sample_bins(v_coverpoint_a, (110), 1);
      sample_bins(v_coverpoint_a, (121, 122, 123, 124, 125), 1);
      sample_bins(v_coverpoint_a, (132, 134, 136, 138), 2);
      sample_bins(v_coverpoint_a, (210), 1);
      sample_bins(v_coverpoint_a, (226, 227, 228, 229), 1);
      sample_bins(v_coverpoint_a, (231, 237, 237, 238, 235, 231), 1);

      v_coverpoint_a.report_coverage(VERBOSE); -- Bins: 0.0% / 0.0%, Hits: 60.38% / 30.19%
      write_coverage_db_quiet(v_coverpoint_a, GC_FILE_PATH & "db_coverpoint.txt");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load and write database from a file - cross");
      ------------------------------------------------------------
      load_coverage_db_quiet(v_cross_x2, GC_FILE_PATH & "db_cross.txt", report_verbosity => NON_VERBOSE);

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 10), (0 => 1010), name => "bin_0", hits => 0);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (0 => 20), (0 => 1020), 8, 20, "single", hits => 2);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL, VAL), (30, 35, 39), (1030, 1035, 1039), 9, 30, "multiple", hits => 3);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (40, 44), (1040, 1049), 15, 40, "range", hits => 5);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN, RAN), (45, 49), (1040, 1049), 15, 40, "range", hits => 5);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN, TRN), (50, 51, 52, 53, 54, 55), (1050, 1051, 1052, 1053, 1054, 1055), 5, 50, "transition", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => 100), (0 => 1100), "bin_6", hits => 0);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => 110), (0 => 1110), "ignore_single", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE, RAN_IGNORE), (121, 125), (1121, 1125), "ignore_range", hits => 5);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (132, 134, 136, 138), (1132, 1134, 1136, 1138), "ignore_transition", hits => 2);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => 200), (0 => 1200), "bin_10", hits => 0);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => 210), (0 => 1210), "illegal_single", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_ILLEGAL, RAN_ILLEGAL), (226, 229), (1226, 1229), "illegal_range", hits => 4);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (231, 237, 237), (1231, 1237, 1237), "illegal_transition", hits => 1);
      check_num_bins(v_cross_x2, 6, 8);
      check_bins_coverage(v_cross_x2, 0.0);
      check_bins_coverage(v_cross_x2, 0.0, use_goal => true); -- goal=50
      check_hits_coverage(v_cross_x2, 30.19);
      check_hits_coverage(v_cross_x2, 40.25, use_goal => true); -- goal=75
      check_value(v_cross_x2.get_num_bins_crossed(VOID), 2, ERROR, "Checking num_bins_crossed");

      -- Check configuration
      check_value(v_cross_x2.get_name(VOID), "MY_CROSS", ERROR, "Checking name");
      check_value(v_cross_x2.get_scope(VOID), "NEW_SCOPE", ERROR, "Checking scope");
      check_value(v_cross_x2.get_illegal_bin_alert_level(VOID) = TB_WARNING, ERROR, "Checking illegal bin alert level");
      check_value(v_cross_x2.get_bin_overlap_alert_level(VOID) = TB_ERROR, ERROR, "Checking bin overlap alert level");
      check_value(v_cross_x2.get_overall_coverage_weight(VOID), 8, ERROR, "Checking coverage weight");
      check_value(v_cross_x2.get_bins_coverage_goal(VOID), 50, ERROR, "Checking bins coverage goal");
      check_value(v_cross_x2.get_hits_coverage_goal(VOID), 75, ERROR, "Checking hits coverage goal");
      check_value(fc_get_covpts_coverage_goal(VOID), 90, ERROR, "Checking coverpoints coverage goal");
      v_seeds := v_cross_x2.get_rand_seeds(VOID);
      check_value(v_seeds(0) /= C_RAND_INIT_SEED_1, ERROR, "Checking seed 1");
      check_value(v_seeds(1) /= C_RAND_INIT_SEED_2, ERROR, "Checking seed 2");

      -- Sample coverage
      increment_expected_alerts(TB_WARNING, 6);
      sample_cross_bins(v_cross_x2, (0 => (20, 1020)), 2);
      sample_cross_bins(v_cross_x2, ((30, 1030), (35, 1035), (39, 1039)), 1);
      sample_cross_bins(v_cross_x2, ((40, 1040), (41, 1041), (42, 1042), (43, 1043), (44, 1044)), 1);
      sample_cross_bins(v_cross_x2, ((45, 1045), (46, 1046), (47, 1047), (48, 1048), (49, 1049)), 1);
      sample_cross_bins(v_cross_x2, ((50, 1050), (51, 1051), (52, 1052), (53, 1053), (54, 1054), (55, 1055)), 1);
      sample_cross_bins(v_cross_x2, (0 => (110, 1110)), 1);
      sample_cross_bins(v_cross_x2, ((121, 1121), (122, 1122), (123, 1123), (124, 1124), (125, 1125)), 1);
      sample_cross_bins(v_cross_x2, ((132, 1132), (134, 1134), (136, 1136), (138, 1138)), 2);
      sample_cross_bins(v_cross_x2, (0 => (210, 1210)), 1);
      sample_cross_bins(v_cross_x2, ((226, 1226), (227, 1227), (228, 1228), (229, 1229)), 1);
      sample_cross_bins(v_cross_x2, ((231, 1231), (237, 1237), (237, 1237)), 1);

      v_cross_x2.report_coverage(VERBOSE); -- Bins: 0.0% / 0.0%, Hits: 60.38% / 80.50%
      write_coverage_db_quiet(v_cross_x2, GC_FILE_PATH & "db_cross.txt");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load and write database from a file - max data");
      ------------------------------------------------------------
      load_coverage_db_quiet(v_cross_x3, GC_FILE_PATH & "db_cross_max.txt");

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      for i in 1 to 100 loop
        if i < 26 then
          check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => i), (0 => 200), (0 => 300), name => "bin_" & to_string(i - 1), hits => 1);
        else
          check_cross_bin(v_cross_x3, v_bin_idx, (VAL, VAL, VAL), (0 => i), (0 => 200), (0 => 300), name => "bin_" & to_string(i - 1), hits => 0);
        end if;
      end loop;
      check_num_bins(v_cross_x3, 100, 0);
      check_bins_coverage(v_cross_x3, 25.0);
      check_bins_coverage(v_cross_x3, 25.0, use_goal => true); -- goal=100
      check_hits_coverage(v_cross_x3, 25.0);
      check_hits_coverage(v_cross_x3, 25.0, use_goal => true); -- goal=100
      check_value(v_cross_x3.get_num_bins_crossed(VOID), 3, ERROR, "Checking num_bins_crossed");

      -- Sample coverage
      for i in 26 to 50 loop
        v_cross_x3.sample_coverage((i, 200, 300));
      end loop;

      v_cross_x3.report_coverage(VERBOSE); -- Bins: 50.00%, Hits: 50.00%
      write_coverage_db_quiet(v_cross_x3, GC_FILE_PATH & "db_cross_max.txt");

      fc_report_overall_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load database from a file - coverpoint");
      ------------------------------------------------------------
      load_coverage_db_quiet(v_coverpoint_b, GC_FILE_PATH & "db_coverpoint.txt");

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 10, name => "bin_0", hits => 0);
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 20, 8, 20, "single", hits => 4);
      check_bin(v_coverpoint_b, v_bin_idx, VAL, (30, 35, 39), 9, 30, "multiple", hits => 6);
      check_bin(v_coverpoint_b, v_bin_idx, RAN, (40, 44), 15, 40, "range", hits => 10);
      check_bin(v_coverpoint_b, v_bin_idx, RAN, (45, 49), 15, 40, "range", hits => 10);
      check_bin(v_coverpoint_b, v_bin_idx, TRN, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 5, 50, "transition", hits => 2);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, VAL_IGNORE, 100, "bin_6", hits => 0);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, VAL_IGNORE, 110, "ignore_single", hits => 2);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, RAN_IGNORE, (121, 125), "ignore_range", hits => 10);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, TRN_IGNORE, (132, 134, 136, 138), "ignore_transition", hits => 4);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, VAL_ILLEGAL, 200, "bin_10", hits => 0);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, VAL_ILLEGAL, 210, "illegal_single", hits => 2);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, RAN_ILLEGAL, (226, 229), "illegal_range", hits => 8);
      check_invalid_bin(v_coverpoint_b, v_invalid_bin_idx, TRN_ILLEGAL, (231, 237, 237, 238, 235, 231), "illegal_transition", hits => 2);
      check_num_bins(v_coverpoint_b, 6, 8);
      check_bins_coverage(v_coverpoint_b, 0.0);
      check_bins_coverage(v_coverpoint_b, 0.0, use_goal => true); -- goal=50
      check_hits_coverage(v_coverpoint_b, 60.38);
      check_hits_coverage(v_coverpoint_b, 30.19, use_goal => true); -- goal=200
      check_value(v_coverpoint_b.get_num_bins_crossed(VOID), 1, ERROR, "Checking num_bins_crossed");
      v_seeds           := v_coverpoint_b.get_rand_seeds(VOID);
      check_value(v_seeds(0) /= C_RAND_INIT_SEED_1, ERROR, "Checking seed 1");
      check_value(v_seeds(1) /= C_RAND_INIT_SEED_2, ERROR, "Checking seed 2");

      -- Sample coverage
      sample_bins(v_coverpoint_b, (10), 2);
      sample_bins(v_coverpoint_b, (20), 12);
      sample_bins(v_coverpoint_b, (30, 35, 39), 4);
      sample_bins(v_coverpoint_b, (40, 41, 42, 43, 44), 4);
      sample_bins(v_coverpoint_b, (45, 46, 47, 48, 49), 4);
      sample_bins(v_coverpoint_b, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 8);

      check_coverage_completed(v_coverpoint_b);
      check_coverage_completed(v_coverpoint_b, use_goal => true);
      v_coverpoint_b.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load database from a file - cross");
      ------------------------------------------------------------
      load_coverage_db_quiet(v_cross_x2_b, GC_FILE_PATH & "db_cross.txt");

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      check_cross_bin(v_cross_x2_b, v_bin_idx, (VAL, VAL), (0 => 10), (0 => 1010), name => "bin_0", hits => 0);
      check_cross_bin(v_cross_x2_b, v_bin_idx, (VAL, VAL), (0 => 20), (0 => 1020), 8, 20, "single", hits => 4);
      check_cross_bin(v_cross_x2_b, v_bin_idx, (VAL, VAL), (30, 35, 39), (1030, 1035, 1039), 9, 30, "multiple", hits => 6);
      check_cross_bin(v_cross_x2_b, v_bin_idx, (RAN, RAN), (40, 44), (1040, 1049), 15, 40, "range", hits => 10);
      check_cross_bin(v_cross_x2_b, v_bin_idx, (RAN, RAN), (45, 49), (1040, 1049), 15, 40, "range", hits => 10);
      check_cross_bin(v_cross_x2_b, v_bin_idx, (TRN, TRN), (50, 51, 52, 53, 54, 55), (1050, 1051, 1052, 1053, 1054, 1055), 5, 50, "transition", hits => 2);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => 100), (0 => 1100), "bin_6", hits => 0);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (VAL_IGNORE, VAL_IGNORE), (0 => 110), (0 => 1110), "ignore_single", hits => 2);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (RAN_IGNORE, RAN_IGNORE), (121, 125), (1121, 1125), "ignore_range", hits => 10);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (TRN_IGNORE, TRN_IGNORE), (132, 134, 136, 138), (1132, 1134, 1136, 1138), "ignore_transition", hits => 4);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => 200), (0 => 1200), "bin_10", hits => 0);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (VAL_ILLEGAL, VAL_ILLEGAL), (0 => 210), (0 => 1210), "illegal_single", hits => 2);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (RAN_ILLEGAL, RAN_ILLEGAL), (226, 229), (1226, 1229), "illegal_range", hits => 8);
      check_invalid_cross_bin(v_cross_x2_b, v_invalid_bin_idx, (TRN_ILLEGAL, TRN_ILLEGAL), (231, 237, 237), (1231, 1237, 1237), "illegal_transition", hits => 2);
      check_num_bins(v_cross_x2_b, 6, 8);
      check_bins_coverage(v_cross_x2_b, 0.0);
      check_bins_coverage(v_cross_x2_b, 0.0, use_goal => true); -- goal=50
      check_hits_coverage(v_cross_x2_b, 60.38);
      check_hits_coverage(v_cross_x2_b, 80.50, use_goal => true); -- goal=75
      check_value(v_cross_x2_b.get_num_bins_crossed(VOID), 2, ERROR, "Checking num_bins_crossed");
      v_seeds           := v_cross_x2_b.get_rand_seeds(VOID);
      check_value(v_seeds(0) /= C_RAND_INIT_SEED_1, ERROR, "Checking seed 1");
      check_value(v_seeds(1) /= C_RAND_INIT_SEED_2, ERROR, "Checking seed 2");

      -- Sample coverage
      sample_cross_bins(v_cross_x2_b, (0 => (10, 1010)), 1);
      sample_cross_bins(v_cross_x2_b, (0 => (20, 1020)), 4);
      sample_cross_bins(v_cross_x2_b, ((30, 1030), (35, 1035), (39, 1039)), 1);
      sample_cross_bins(v_cross_x2_b, ((40, 1040), (41, 1041), (42, 1042), (43, 1043), (44, 1044)), 1);
      sample_cross_bins(v_cross_x2_b, ((45, 1045), (46, 1046), (47, 1047), (48, 1048), (49, 1049)), 1);
      sample_cross_bins(v_cross_x2_b, ((50, 1050), (51, 1051), (52, 1052), (53, 1053), (54, 1054), (55, 1055)), 3);

      check_coverage_completed(v_cross_x2_b);
      check_coverage_completed(v_cross_x2_b, use_goal => true);
      v_cross_x2_b.report_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing load database from a file - max data");
      ------------------------------------------------------------
      load_coverage_db_quiet(v_cross_x3_b, GC_FILE_PATH & "db_cross_max.txt");

      -- Check bins and coverage
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;
      for i in 1 to 100 loop
        if i < 51 then
          check_cross_bin(v_cross_x3_b, v_bin_idx, (VAL, VAL, VAL), (0 => i), (0 => 200), (0 => 300), name => "bin_" & to_string(i - 1), hits => 1);
        else
          check_cross_bin(v_cross_x3_b, v_bin_idx, (VAL, VAL, VAL), (0 => i), (0 => 200), (0 => 300), name => "bin_" & to_string(i - 1), hits => 0);
        end if;
      end loop;
      check_num_bins(v_cross_x3_b, 100, 0);
      check_bins_coverage(v_cross_x3_b, 50.0);
      check_bins_coverage(v_cross_x3_b, 50.0, use_goal => true); -- goal=100
      check_hits_coverage(v_cross_x3_b, 50.0);
      check_hits_coverage(v_cross_x3_b, 50.0, use_goal => true); -- goal=100
      check_value(v_cross_x3_b.get_num_bins_crossed(VOID), 3, ERROR, "Checking num_bins_crossed");

      -- Sample coverage
      for i in 51 to 100 loop
        v_cross_x3_b.sample_coverage((i, 200, 300));
      end loop;

      check_coverage_completed(v_cross_x3_b);
      check_coverage_completed(v_cross_x3_b, use_goal => true);
      v_cross_x3_b.report_coverage(VERBOSE);

      fc_report_overall_coverage(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_database_3" then
      -- IMPORTANT: This testcase only generates database files which are to be tested with
      -- the python script for coverage accumulation. This test is intended for when running
      -- testcases in parallel
      --===================================================================================
      disable_log_msg(ID_FUNC_COV_BINS_INFO);
      disable_log_msg(ID_FUNC_COV_SAMPLE);

      fc_set_covpts_coverage_goal(50);  -- Will be used for the whole testcase, i.e. all the coverpoints

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverpoint with same bins and different coverage values");
      ------------------------------------------------------------
      -- Add bins
      v_coverpoint_a.add_bins(bin(10));
      v_coverpoint_a.add_bins(bin(20), 8, 20, "single");
      v_coverpoint_a.add_bins(bin((30, 35, 39)), 9, 30, "multiple");
      v_coverpoint_a.add_bins(bin_range(40, 49, 2), 15, 40, "range");
      v_coverpoint_a.add_bins(bin_transition((50, 51, 52, 53, 54, 55, 56, 57, 58, 59)), 5, 50, "transition");
      v_coverpoint_a.add_bins(ignore_bin(100));
      v_coverpoint_a.add_bins(ignore_bin(110), 1000, 500, "ignore_single");
      v_coverpoint_a.add_bins(ignore_bin_range(121, 125), 1000, 500, "ignore_range");
      v_coverpoint_a.add_bins(ignore_bin_transition((132, 134, 136, 138)), 1000, 500, "ignore_transition");
      v_coverpoint_a.add_bins(illegal_bin(200));
      v_coverpoint_a.add_bins(illegal_bin(210), 1000, 500, "illegal_single");
      v_coverpoint_a.add_bins(illegal_bin_range(226, 229), 1000, 500, "illegal_range");
      v_coverpoint_a.add_bins(illegal_bin_transition((231, 237, 237, 238, 235, 231)), 1000, 500, "illegal_transition");

      -- Set configuration
      v_coverpoint_a.set_name("Covpt_A");
      v_coverpoint_a.set_illegal_bin_alert_level(TB_NOTE);
      v_coverpoint_a.set_overall_coverage_weight(5);
      v_coverpoint_a.set_bins_coverage_goal(50);
      v_coverpoint_a.set_hits_coverage_goal(200);

      -- Sample coverage
      increment_expected_alerts(TB_NOTE, 6);
      sample_bins(v_coverpoint_a, (20), 2);
      sample_bins(v_coverpoint_a, (30, 35, 39), 1);
      sample_bins(v_coverpoint_a, (40, 41, 42, 43, 44), 1);
      sample_bins(v_coverpoint_a, (45, 46, 47, 48, 49), 1);
      sample_bins(v_coverpoint_a, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 1);
      sample_bins(v_coverpoint_a, (110), 1);
      sample_bins(v_coverpoint_a, (121, 122, 123, 124, 125), 1);
      sample_bins(v_coverpoint_a, (132, 134, 136, 138), 2);
      sample_bins(v_coverpoint_a, (210), 1);
      sample_bins(v_coverpoint_a, (226, 227, 228, 229), 1);
      sample_bins(v_coverpoint_a, (231, 237, 237, 238, 235, 231), 1);

      -- Write to file 1
      v_coverpoint_a.write_coverage_db("db_covpt_parallel_1.txt");
      -- Write to file 2
      v_coverpoint_a.write_coverage_db("db_covpt_parallel_2.txt");

      -- Use same coverpoint and sample different coverage
      v_coverpoint_a.clear_coverage(VOID);
      sample_bins(v_coverpoint_a, (10), 1);
      sample_bins(v_coverpoint_a, (20), 4);
      sample_bins(v_coverpoint_a, (30, 35, 39), 1);
      sample_bins(v_coverpoint_a, (40, 41, 42, 43, 44), 1);
      sample_bins(v_coverpoint_a, (45, 46, 47, 48, 49), 1);
      sample_bins(v_coverpoint_a, (50, 51, 52, 53, 54, 55, 56, 57, 58, 59), 3);

      -- Write to file 3
      v_coverpoint_a.write_coverage_db("db_covpt_parallel_3.txt");

      -----------------------------------------------------------------------
      -- Expected result
      -----------------------------------------------------------------------
      --Coverpoint:              Covpt_A    (accumulated over 3 testcases)
      --Goal:                    Bins: 50%,       Hits: 200%
      --% of Goal:               Bins: 100.00%,   Hits: 50.00%
      --% of Goal (uncapped):    Bins: 200.00%,   Hits: 50.00%
      --Coverage (for goal 100): Bins: 100.00%,   Hits: 100.00%
      -----------------------------------------------------------------------

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with different number of bins and coverage values");
      ------------------------------------------------------------
      -- Add bins
      v_cross_x2.add_cross(bin(10), bin(1010));
      v_cross_x2.add_cross(bin(20), bin(1020), 8, 20, "single");
      v_cross_x2.add_cross(bin((30, 35, 39)), bin((1030, 1035, 1039)), 9, 30, "multiple");
      v_cross_x2.add_cross(bin_range(40, 49, 2), bin_range(1040, 1049), 15, 40, "range");
      v_cross_x2.add_cross(bin_transition((50, 51, 52, 53, 54, 55)), bin_transition((1050, 1051, 1052, 1053, 1054, 1055)), 5, 50, "transition");
      v_cross_x2.add_cross(ignore_bin(100), ignore_bin(1100));
      v_cross_x2.add_cross(ignore_bin(110), ignore_bin(1110), 1000, 500, "ignore_single");
      v_cross_x2.add_cross(ignore_bin_range(121, 125), ignore_bin_range(1121, 1125), 1000, 500, "ignore_range");
      v_cross_x2.add_cross(ignore_bin_transition((132, 134, 136, 138)), ignore_bin_transition((1132, 1134, 1136, 1138)), 1000, 500, "ignore_transition");
      v_cross_x2.add_cross(illegal_bin(200), illegal_bin(1200));
      v_cross_x2.add_cross(illegal_bin(210), illegal_bin(1210), 1000, 500, "illegal_single");
      v_cross_x2.add_cross(illegal_bin_range(226, 229), illegal_bin_range(1226, 1229), 1000, 500, "illegal_range");
      v_cross_x2.add_cross(illegal_bin_transition((231, 237, 237)), illegal_bin_transition((1231, 1237, 1237)), 1000, 500, "illegal_transition");

      -- Add bins
      --v_cross_x2_b.add_cross(bin(10), bin(1010)); -- unused
      v_cross_x2_b.add_cross(bin(10), bin(10000)); -- new
      v_cross_x2_b.add_cross(bin(10), bin(10001)); -- new
      v_cross_x2_b.add_cross(bin(20), bin(1020), 8, 20, "single");
      v_cross_x2_b.add_cross(bin((30, 35, 39)), bin((1030, 1035, 1039)), 9, 30, "multiple");
      v_cross_x2_b.add_cross(bin_range(40, 49, 2), bin_range(1040, 1049), 15, 40, "range");
      v_cross_x2_b.add_cross(bin_transition((50, 51, 52, 53, 54, 55)), bin_transition((1050, 1051, 1052, 1053, 1054, 1055)), 5, 50, "transition");
      --v_cross_x2_b.add_cross(ignore_bin(100), ignore_bin(1100)); -- unused
      v_cross_x2_b.add_cross(ignore_bin(100), ignore_bin(20000)); -- new
      v_cross_x2_b.add_cross(ignore_bin(100), ignore_bin(20001)); -- new
      v_cross_x2_b.add_cross(ignore_bin(110), ignore_bin(1110), 1000, 500, "ignore_single");
      v_cross_x2_b.add_cross(ignore_bin_range(121, 125), ignore_bin_range(1121, 1125), 1000, 500, "ignore_range");
      v_cross_x2_b.add_cross(ignore_bin_transition((132, 134, 136, 138)), ignore_bin_transition((1132, 1134, 1136, 1138)), 1000, 500, "ignore_transition");
      --v_cross_x2_b.add_cross(illegal_bin(200), illegal_bin(1200)); -- unused
      v_cross_x2_b.add_cross(illegal_bin(200), illegal_bin(30000)); -- new
      v_cross_x2_b.add_cross(illegal_bin(200), illegal_bin(30001)); -- new
      v_cross_x2_b.add_cross(illegal_bin(210), illegal_bin(1210), 1000, 500, "illegal_single");
      v_cross_x2_b.add_cross(illegal_bin_range(226, 229), illegal_bin_range(1226, 1229), 1000, 500, "illegal_range");
      v_cross_x2_b.add_cross(illegal_bin_transition((231, 237, 237)), illegal_bin_transition((1231, 1237, 1237)), 1000, 500, "illegal_transition");

      -- Set configuration
      v_cross_x2.set_name("Cross_B");
      v_cross_x2.set_illegal_bin_alert_level(TB_WARNING);
      v_cross_x2.set_overall_coverage_weight(8);
      v_cross_x2.set_bins_coverage_goal(50);
      v_cross_x2.set_hits_coverage_goal(75);

      -- Set configuration
      v_cross_x2_b.set_name("Cross_B");
      v_cross_x2_b.set_illegal_bin_alert_level(TB_WARNING);
      v_cross_x2_b.set_overall_coverage_weight(8);
      v_cross_x2_b.set_bins_coverage_goal(50);
      v_cross_x2_b.set_hits_coverage_goal(75);

      -- Sample coverage
      increment_expected_alerts(TB_WARNING, 6);
      sample_cross_bins(v_cross_x2, (0 => (20, 1020)), 2);
      sample_cross_bins(v_cross_x2, ((30, 1030), (35, 1035), (39, 1039)), 1);
      sample_cross_bins(v_cross_x2, ((40, 1040), (41, 1041), (42, 1042), (43, 1043), (44, 1044)), 1);
      sample_cross_bins(v_cross_x2, ((45, 1045), (46, 1046), (47, 1047), (48, 1048), (49, 1049)), 1);
      sample_cross_bins(v_cross_x2, ((50, 1050), (51, 1051), (52, 1052), (53, 1053), (54, 1054), (55, 1055)), 1);
      sample_cross_bins(v_cross_x2, (0 => (110, 1110)), 1);
      sample_cross_bins(v_cross_x2, ((121, 1121), (122, 1122), (123, 1123), (124, 1124), (125, 1125)), 1);
      sample_cross_bins(v_cross_x2, ((132, 1132), (134, 1134), (136, 1136), (138, 1138)), 2);
      sample_cross_bins(v_cross_x2, (0 => (210, 1210)), 1);
      sample_cross_bins(v_cross_x2, ((226, 1226), (227, 1227), (228, 1228), (229, 1229)), 1);
      sample_cross_bins(v_cross_x2, ((231, 1231), (237, 1237), (237, 1237)), 1);

      v_cross_x2.write_coverage_db("db_cross_parallel_1.txt");

      -- Sample coverage
      increment_expected_alerts(TB_WARNING, 8);
      sample_cross_bins(v_cross_x2_b, (0 => (10, 10000)), 5);
      sample_cross_bins(v_cross_x2_b, (0 => (10, 10001)), 3);
      sample_cross_bins(v_cross_x2_b, (0 => (20, 1020)), 8);
      sample_cross_bins(v_cross_x2_b, ((30, 1030), (35, 1035), (39, 1039)), 5);
      sample_cross_bins(v_cross_x2_b, ((40, 1040), (41, 1041), (42, 1042), (43, 1043), (44, 1044)), 2);
      sample_cross_bins(v_cross_x2_b, ((45, 1045), (46, 1046), (47, 1047), (48, 1048), (49, 1049)), 2);
      sample_cross_bins(v_cross_x2_b, ((50, 1050), (51, 1051), (52, 1052), (53, 1053), (54, 1054), (55, 1055)), 4);
      sample_cross_bins(v_cross_x2_b, (0 => (100, 20000)), 1);
      sample_cross_bins(v_cross_x2_b, (0 => (100, 20001)), 1);
      sample_cross_bins(v_cross_x2_b, (0 => (110, 1110)), 1);
      sample_cross_bins(v_cross_x2_b, ((121, 1121), (122, 1122), (123, 1123), (124, 1124), (125, 1125)), 1);
      sample_cross_bins(v_cross_x2_b, ((132, 1132), (134, 1134), (136, 1136), (138, 1138)), 2);
      sample_cross_bins(v_cross_x2_b, (0 => (200, 30000)), 1);
      sample_cross_bins(v_cross_x2_b, (0 => (200, 30001)), 1);
      sample_cross_bins(v_cross_x2_b, (0 => (210, 1210)), 1);
      sample_cross_bins(v_cross_x2_b, ((226, 1226), (227, 1227), (228, 1228), (229, 1229)), 1);
      sample_cross_bins(v_cross_x2_b, ((231, 1231), (237, 1237), (237, 1237)), 1);

      v_cross_x2_b.write_coverage_db("db_cross_parallel_2.txt");

      -----------------------------------------------------------------------
      -- Expected result
      -----------------------------------------------------------------------
      --Coverpoint:              Cross_B    (accumulated over 2 testcases)
      --Goal:                    Bins: 50%,       Hits: 75%
      --% of Goal:               Bins: 100.00%,   Hits: 99.39%
      --% of Goal (uncapped):    Bins: 175.00%,   Hits: 172.12%
      --Coverage (for goal 100): Bins: 87.50%,    Hits: 98.18%
      -----------------------------------------------------------------------

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with different bins and coverage values");
      ------------------------------------------------------------
      -- Add bins
      v_cross_x3.add_cross(bin_range(1, 10), bin(200), bin(300));
      v_cross_x3.add_cross(bin_range(11, 20), bin(210), bin(310));
      v_cross_x3.add_cross(bin_range(21, 30), bin(220), bin(320));

      -- Add bins
      v_cross_x3_b.add_cross(bin_range(1, 10), bin(200), bin(400));
      v_cross_x3_b.add_cross(bin_range(11, 20), bin(210), bin(410));
      v_cross_x3_b.add_cross(bin_range(21, 30), bin(220), bin(420));

      -- Set configuration
      v_cross_x3.set_name("Cross_C");
      v_cross_x3.set_overall_coverage_weight(6);
      v_cross_x3.set_hits_coverage_goal(150);

      -- Set configuration
      v_cross_x3_b.set_name("Cross_C");
      v_cross_x3_b.set_overall_coverage_weight(6);
      v_cross_x3_b.set_hits_coverage_goal(150);

      -- Sample coverage
      sample_cross_bins(v_cross_x3, (0 => (5, 200, 300)), 3);
      sample_cross_bins(v_cross_x3, (0 => (15, 210, 310)), 3);
      sample_cross_bins(v_cross_x3, (0 => (25, 220, 320)), 3);

      v_cross_x3.write_coverage_db("db_cross_parallel_3.txt");

      -- Sample coverage
      sample_cross_bins(v_cross_x3_b, (0 => (5, 200, 400)), 3);
      sample_cross_bins(v_cross_x3_b, (0 => (15, 210, 410)), 3);
      sample_cross_bins(v_cross_x3_b, (0 => (25, 220, 420)), 3);

      v_cross_x3_b.write_coverage_db("db_cross_parallel_4.txt");

      -----------------------------------------------------------------------
      -- Expected result
      -----------------------------------------------------------------------
      --Coverpoint:              Cross_C    (accumulated over 2 testcases)
      --Goal:                    Bins: 100%,      Hits: 150%
      --% of Goal:               Bins: 100.00%,   Hits: 100.00%
      --% of Goal (uncapped):    Bins: 100.00%,   Hits: 200.00%
      --Coverage (for goal 100): Bins: 100.00%,   Hits: 100.00%
      -----------------------------------------------------------------------

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with a single coverage file");
      ------------------------------------------------------------
      -- Add bins
      v_cross_x4.add_cross(bin_range(1, 10, 0), bin(200), bin(300), bin(400)); -- TODO: use 16-cross

      -- Set configuration
      v_cross_x4.set_name("Cross_D");

      -- Sample coverage
      for i in 1 to 10 loop
        v_cross_x4.sample_coverage((i, 200, 300, 400));
      end loop;

      v_cross_x4.write_coverage_db("db_cross_parallel_5.txt");

    -----------------------------------------------------------------------
    -- Expected result
    -----------------------------------------------------------------------
    --Coverpoint:              Cross_D
    --Coverage (for goal 100): Bins: 100.00%,   Hits: 100.00%
    -----------------------------------------------------------------------

    -----------------------------------------------------------------------
    -- Expected final result
    -----------------------------------------------------------------------
    --Goal:                    Covpts: 50%
    --% of Goal:               Covpts: 100.00%
    --% of Goal (uncapped):    Covpts: 120.00%
    --Coverage (for goal 100): Covpts: 60.00%,   Bins: 94.29%,   Hits: 98.93%
    --======================================================================================================================================================
    --     COVERPOINT        COVERAGE WEIGHT        COVERED BINS     COVERAGE(BINS|HITS)    GOAL(BINS|HITS)    % OF GOAL(BINS|HITS)    NUM TESTCASES
    --      Covpt_A                 5                  6 / 6          100.00% | 100.00%        50% | 200%        100.00% | 50.00%            3
    --      Cross_B                 8                  7 / 8           87.50% | 98.18%         50% | 75%         100.00% | 99.39%            2
    --      Cross_C                 6                  6 / 6          100.00% | 100.00%       100% | 150%        100.00% | 100.00%           2
    --      Cross_D                 1                 10 / 10         100.00% | 100.00%       100% | 100%        100.00% | 100.00%           1
    --======================================================================================================================================================
    -----------------------------------------------------------------------

    --===================================================================================
    elsif GC_TESTCASE = "fc_reports" then
      --===================================================================================
      disable_log_msg(ID_FUNC_COV_SAMPLE);
      disable_log_msg(ID_FUNC_COV_RAND);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing empty reports");
      ------------------------------------------------------------
      v_coverpoint_a.report_config(VOID);
      v_coverpoint_a.report_coverage(VERBOSE);
      fc_report_overall_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverpoint reports");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin_range(0, 125), 8, "mem_addr_low");
      v_coverpoint_a.add_bins(bin((126, 127, 128)), "mem_addr_mid");
      v_coverpoint_a.add_bins(bin_range(129, 255), 4, "mem_addr_high");
      v_coverpoint_a.add_bins(bin_transition((0, 1, 2, 3)), 2, 10, "transition_1");
      v_coverpoint_a.add_bins(bin_transition((0, 15, 127, 248, 249, 250, 251, 252, 253, 254)), 2, 10, "transition_2");
      v_coverpoint_a.add_bins(ignore_bin(100), 10, 10, "ignore_addr"); -- min_hits and rand_weight are discarded
      v_coverpoint_a.add_bins(ignore_bin_transition((1000, 15, 127, 248, 249, 250, 251, 252, 253, 254)), "ignore_transition");
      v_coverpoint_a.add_bins(illegal_bin_range(256, 511), 10, 10, "illegal_addr"); -- min_hits and rand_weight are discarded
      v_coverpoint_a.add_bins(illegal_bin_transition((2000, 15, 127, 248, 249, 250, 251, 252, 253, 254)), 2, "illegal_transition");
      v_coverpoint_a.sample_coverage(1);
      v_coverpoint_a.sample_coverage(2);
      v_coverpoint_a.sample_coverage(127);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      v_coverpoint_a.sample_coverage(500);
      sample_bins(v_coverpoint_a, (0, 15, 127, 248, 249, 250, 251, 252, 253, 254), 2);

      v_coverpoint_a.report_coverage(VERBOSE);
      v_coverpoint_a.report_coverage(NON_VERBOSE);
      v_coverpoint_a.report_coverage(VOID);
      v_coverpoint_a.report_coverage(HOLES_ONLY);

      v_coverpoint_a.report_coverage(VERBOSE, rand_weight_col => SHOW_RAND_WEIGHT);
      v_coverpoint_a.report_coverage(NON_VERBOSE, rand_weight_col => SHOW_RAND_WEIGHT);
      v_coverpoint_a.report_coverage(HOLES_ONLY, rand_weight_col => SHOW_RAND_WEIGHT);

      v_coverpoint_a.set_bins_coverage_goal(50);
      v_coverpoint_a.report_coverage(VERBOSE);
      v_coverpoint_a.report_coverage(NON_VERBOSE);
      v_coverpoint_a.report_coverage(HOLES_ONLY);

      v_coverpoint_a.report_config(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross reports");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin(10), bin_range(0, 15));
      v_cross_x2.add_cross(bin(20), bin_range(16, 31));
      v_cross_x2.add_cross(bin(30), bin_range(32, 63));
      v_cross_x2.add_cross(bin((10, 20, 30)), illegal_bin_range(64, 127), "illegal_bin");
      v_cross_x2.report_coverage(VERBOSE);

      v_cross_x3.add_cross(bin(10) & bin(20) & bin(30), bin_range(0, 7) & bin_range(8, 15), bin(1000));
      v_cross_x3.report_coverage(VERBOSE);

      v_coverpoint_b.add_bins(bin_vector(v_vector, 0));
      v_coverpoint_c.add_bins(bin_range(0, 127));
      v_cross_x2_b.add_cross(v_coverpoint_b, v_coverpoint_c);
      v_cross_x2_b.report_coverage(VERBOSE);

      v_coverpoint_d.add_bins(bin(1000) & bin(2000) & bin(3000));
      v_cross_x3_b.add_cross(v_cross_x2_b, v_coverpoint_d);
      v_cross_x3_b.report_coverage(VERBOSE);

      v_cross_x2.report_config(VOID);
      v_cross_x3.report_config(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing overall reports");
      ------------------------------------------------------------
      while not (v_cross_x2.coverage_completed(BINS_AND_HITS)) loop
        v_values_x2 := v_cross_x2.rand(SAMPLE_COV);
      end loop;
      while not (v_cross_x3.coverage_completed(BINS_AND_HITS)) loop
        v_values_x3 := v_cross_x3.rand(SAMPLE_COV);
      end loop;
      while not (v_cross_x2_b.coverage_completed(BINS_AND_HITS)) loop
        v_values_x2 := v_cross_x2_b.rand(SAMPLE_COV);
      end loop;
      while not (v_cross_x3_b.coverage_completed(BINS_AND_HITS)) loop
        v_values_x3 := v_cross_x3_b.rand(SAMPLE_COV);
      end loop;

      fc_report_overall_coverage(VERBOSE);
      fc_report_overall_coverage(NON_VERBOSE);
      fc_report_overall_coverage(VOID);
      fc_report_overall_coverage(HOLES_ONLY);

      fc_set_covpts_coverage_goal(25);
      fc_report_overall_coverage(VERBOSE);
      fc_report_overall_coverage(NON_VERBOSE);
      fc_report_overall_coverage(HOLES_ONLY);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing reports written to a file");
      ------------------------------------------------------------
      v_coverpoint_a.report_config(GC_TESTCASE & "_Report_config.txt", write_mode);
      v_cross_x2.report_config(GC_TESTCASE & "_Report_config.txt");
      v_cross_x3.report_config(GC_TESTCASE & "_Report_config.txt");

      v_coverpoint_a.report_coverage(VERBOSE, GC_TESTCASE & "_Report_coverage.txt", write_mode);
      v_cross_x2.report_coverage(VERBOSE, GC_TESTCASE & "_Report_coverage.txt");
      v_cross_x3.report_coverage(VERBOSE, GC_TESTCASE & "_Report_coverage.txt");
      fc_report_overall_coverage(NON_VERBOSE, GC_TESTCASE & "_Report_coverage.txt");

      fc_report_overall_coverage(VERBOSE, GC_TESTCASE & "_Report_coverage_overall.txt", write_mode);

    --===================================================================================
    elsif GC_TESTCASE = "fc_coverage" then
      --===================================================================================
      check_value(fc_get_overall_coverage(COVPTS), 0.0, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 0.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 0.0, ERROR, "Checking hits overall coverage");
      check_value(not fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage NOT completed");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverage status with default goals (100)");
      ------------------------------------------------------------
      v_num_bins       := 15;
      v_min_hits       := 10;
      v_total_min_hits := real(v_num_bins * v_min_hits);
      v_coverpoint_a.add_bins(bin_range(1, v_num_bins, 0), v_min_hits);

      for bin in 1 to v_num_bins loop
        for hits in 1 to v_min_hits loop
          check_bins_coverage(v_coverpoint_a, 100.0 * real(bin - 1) / real(v_num_bins));
          check_hits_coverage(v_coverpoint_a, 100.0 * real((bin - 1) * v_min_hits + hits - 1) / v_total_min_hits);
          v_coverpoint_a.sample_coverage(bin);
        end loop;
      end loop;
      check_coverage_completed(v_coverpoint_a);
      check_value(v_coverpoint_a.coverage_completed(BINS_AND_HITS), ERROR, "Checking coverage_completed(BINS_AND_HITS)");

      log(ID_LOG_HDR, "Continue sampling bins and check coverage remains 100%");
      for i in 1 to 50 loop
        v_coverpoint_a.sample_coverage(i mod 20); -- Sample also values outside the bins
      end loop;
      check_coverage_completed(v_coverpoint_a);
      check_value(v_coverpoint_a.coverage_completed(BINS_AND_HITS), ERROR, "Checking coverage_completed(BINS_AND_HITS)");

      v_coverpoint_a.report_coverage(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverage status with configured hits goal < 100");
      ------------------------------------------------------------
      v_num_bins       := 10;
      v_min_hits       := 10;
      v_total_min_hits := real(v_num_bins * v_min_hits);
      v_coverpoint_b.add_bins(bin_range(1, v_num_bins, 0), v_min_hits);
      v_goal           := 50;
      v_min_hits       := v_min_hits * v_goal / 100;
      v_total_min_hits := v_total_min_hits * real(v_goal) / 100.0;
      v_coverpoint_b.set_hits_coverage_goal(v_goal);
      check_value(v_coverpoint_b.get_hits_coverage_goal(VOID), v_goal, ERROR, "Checking hits coverage goal");

      for bin in 1 to v_num_bins loop
        for hits in 1 to v_min_hits loop
          check_bins_coverage(v_coverpoint_b, 0.0, use_goal => true);
          check_hits_coverage(v_coverpoint_b, 100.0 * real((bin - 1) * v_min_hits + hits - 1) / v_total_min_hits, use_goal => true);
          v_coverpoint_b.sample_coverage(bin);
        end loop;
      end loop;
      check_bins_coverage(v_coverpoint_b, 0.0, use_goal => true);
      check_hits_coverage(v_coverpoint_b, 100.0, use_goal => true);

      log(ID_LOG_HDR, "Continue sampling bins and check hits coverage remains 100%");
      for bin in 1 to v_num_bins loop
        for hits in 1 to v_min_hits loop
          check_bins_coverage(v_coverpoint_b, 100.0 * real(bin - 1) / real(v_num_bins), use_goal => true);
          check_hits_coverage(v_coverpoint_b, 100.0, use_goal => true);
          v_coverpoint_b.sample_coverage(bin);
        end loop;
      end loop;
      check_coverage_completed(v_coverpoint_b, use_goal => true);
      check_value(v_coverpoint_b.coverage_completed(BINS_AND_HITS), ERROR, "Checking coverage_completed(BINS_AND_HITS)");

      v_coverpoint_b.report_coverage(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverage status with configured hits goal > 100");
      ------------------------------------------------------------
      v_num_bins       := 10;
      v_min_hits       := 10;
      v_total_min_hits := real(v_num_bins * v_min_hits);
      v_coverpoint_c.add_bins(bin_range(1, v_num_bins, 0), v_min_hits);
      v_goal           := 200;
      v_min_hits       := v_min_hits * v_goal / 100;
      v_total_min_hits := v_total_min_hits * real(v_goal) / 100.0;
      v_coverpoint_c.set_hits_coverage_goal(v_goal);
      check_value(v_coverpoint_c.get_hits_coverage_goal(VOID), v_goal, ERROR, "Checking hits coverage goal");

      for bin in 1 to v_num_bins loop
        for hits in 1 to v_min_hits loop
          if hits <= v_min_hits * 100 / v_goal then
            check_bins_coverage(v_coverpoint_c, 100.0 * real(bin - 1) / real(v_num_bins), use_goal => true);
          else
            check_bins_coverage(v_coverpoint_c, 100.0 * real(bin) / real(v_num_bins), use_goal => true);
          end if;
          check_hits_coverage(v_coverpoint_c, 100.0 * real((bin - 1) * v_min_hits + hits - 1) / v_total_min_hits, use_goal => true);
          v_coverpoint_c.sample_coverage(bin);
        end loop;
      end loop;
      check_coverage_completed(v_coverpoint_c, use_goal => true);
      check_value(v_coverpoint_c.coverage_completed(BINS_AND_HITS), ERROR, "Checking coverage_completed(BINS_AND_HITS)");

      v_coverpoint_c.report_coverage(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverage status with configured bins goal < 100");
      ------------------------------------------------------------
      v_num_bins       := 10;
      v_min_hits       := 10;
      v_total_min_hits := real(v_num_bins * v_min_hits);
      v_coverpoint_d.add_bins(bin_range(1, v_num_bins, 0), v_min_hits);
      v_goal           := 70;
      v_num_bins       := v_num_bins * v_goal / 100;
      v_coverpoint_d.set_bins_coverage_goal(v_goal);
      check_value(v_coverpoint_d.get_bins_coverage_goal(VOID), v_goal, ERROR, "Checking bins coverage goal");

      for bin in 1 to v_num_bins loop
        for hits in 1 to v_min_hits loop
          check_bins_coverage(v_coverpoint_d, 100.0 * real(bin - 1) / real(v_num_bins), use_goal => true);
          check_hits_coverage(v_coverpoint_d, 100.0 * real((bin - 1) * v_min_hits + hits - 1) / v_total_min_hits, use_goal => true);
          v_coverpoint_d.sample_coverage(bin);
        end loop;
      end loop;
      check_bins_coverage(v_coverpoint_d, 100.0, use_goal => true);
      check_hits_coverage(v_coverpoint_d, 70.0, use_goal => true);

      log(ID_LOG_HDR, "Continue sampling bins and check bins coverage remains 100%");
      for bin in v_num_bins + 1 to v_num_bins * 100 / v_goal loop
        for hits in 1 to v_min_hits loop
          check_bins_coverage(v_coverpoint_d, 100.0, use_goal => true);
          check_hits_coverage(v_coverpoint_d, 100.0 * real((bin - 1) * v_min_hits + hits - 1) / v_total_min_hits, use_goal => true);
          v_coverpoint_d.sample_coverage(bin);
        end loop;
      end loop;
      check_coverage_completed(v_coverpoint_d, use_goal => true);
      check_value(v_coverpoint_d.coverage_completed(BINS_AND_HITS), ERROR, "Checking coverage_completed(BINS_AND_HITS)");

      v_coverpoint_d.report_coverage(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverage status with configured bins and hits goals");
      ------------------------------------------------------------
      v_coverpoint_d.clear_coverage(VOID);
      v_coverpoint_d.set_bins_coverage_goal(50);
      v_coverpoint_d.set_hits_coverage_goal(50);
      check_value(v_coverpoint_d.get_bins_coverage_goal(VOID), 50, ERROR, "Checking bins coverage goal");
      check_value(v_coverpoint_d.get_hits_coverage_goal(VOID), 50, ERROR, "Checking hits coverage goal");

      for bin in 1 to 5 loop
        sample_bins(v_coverpoint_d, bin, 5);
      end loop;
      check_bins_coverage(v_coverpoint_d, 0.0, use_goal => true);
      check_hits_coverage(v_coverpoint_d, 50.0, use_goal => true);
      check_value(v_coverpoint_d.get_coverage(BINS, percentage_of_goal => false), 0.0, ERROR, "check_bins_coverage");
      check_value(v_coverpoint_d.get_coverage(HITS, percentage_of_goal => false), 25.0, ERROR, "check_hits_coverage");

      for bin in 1 to 5 loop
        sample_bins(v_coverpoint_d, bin, 5);
      end loop;
      check_bins_coverage(v_coverpoint_d, 100.0, use_goal => true);
      check_hits_coverage(v_coverpoint_d, 50.0, use_goal => true);
      check_value(v_coverpoint_d.get_coverage(BINS, percentage_of_goal => false), 50.0, ERROR, "check_bins_coverage");
      check_value(v_coverpoint_d.get_coverage(HITS, percentage_of_goal => false), 50.0, ERROR, "check_hits_coverage");

      for bin in 6 to 10 loop
        sample_bins(v_coverpoint_d, bin, 5);
      end loop;
      check_bins_coverage(v_coverpoint_d, 100.0, use_goal => true);
      check_hits_coverage(v_coverpoint_d, 100.0, use_goal => true);
      check_value(v_coverpoint_d.get_coverage(BINS, percentage_of_goal => false), 50.0, ERROR, "check_bins_coverage");
      check_value(v_coverpoint_d.get_coverage(HITS, percentage_of_goal => false), 75.0, ERROR, "check_hits_coverage");

      for bin in 6 to 10 loop
        sample_bins(v_coverpoint_d, bin, 5);
      end loop;
      check_bins_coverage(v_coverpoint_d, 100.0, use_goal => true);
      check_hits_coverage(v_coverpoint_d, 100.0, use_goal => true);
      check_value(v_coverpoint_d.get_coverage(BINS, percentage_of_goal => false), 100.0, ERROR, "check_bins_coverage");
      check_value(v_coverpoint_d.get_coverage(HITS, percentage_of_goal => false), 100.0, ERROR, "check_hits_coverage");

      v_coverpoint_d.report_coverage(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing overall coverage status");
      ------------------------------------------------------------
      v_cross_x2.add_bins(bin(0) & bin(1), 10);
      v_cross_x3.add_bins(bin(0), 10);
      v_cross_x2_b.add_bins(bin(0), 10);
      v_cross_x3_b.add_bins(bin(0), 10);
      v_goal := 75;
      fc_set_covpts_coverage_goal(v_goal);
      check_value(fc_get_covpts_coverage_goal(VOID), v_goal, ERROR, "Checking coverpoints coverage goal");

      check_value(fc_get_overall_coverage(COVPTS), 50.0, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 90.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 90.0, ERROR, "Checking hits overall coverage");
      check_value(not fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage NOT completed");

      sample_bins(v_cross_x2, (0, 1), 10);
      sample_bins(v_cross_x3, 0, 10);

      check_value(fc_get_overall_coverage(COVPTS), 75.0, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 96.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 96.0, ERROR, "Checking hits overall coverage");
      check_value(fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage completed");

      sample_bins(v_cross_x2_b, 0, 10);
      sample_bins(v_cross_x3_b, 0, 10);

      check_value(fc_get_overall_coverage(COVPTS), 100.0, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 100.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 100.0, ERROR, "Checking hits overall coverage");
      check_value(fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage completed");

      fc_report_overall_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing overall coverage weight");
      ------------------------------------------------------------
      v_cross_x2.clear_coverage(VOID);
      v_cross_x3.clear_coverage(VOID);
      v_cross_x2_b.clear_coverage(VOID);
      v_cross_x3_b.clear_coverage(VOID);
      v_cross_x2.set_overall_coverage_weight(3);
      v_cross_x3.set_overall_coverage_weight(3);
      v_cross_x2_b.set_overall_coverage_weight(3);
      v_cross_x3_b.set_overall_coverage_weight(3);
      check_value(v_cross_x2.get_overall_coverage_weight(VOID), 3, ERROR, "Checking overall coverage weight");
      check_value(v_cross_x3.get_overall_coverage_weight(VOID), 3, ERROR, "Checking overall coverage weight");
      check_value(v_cross_x2_b.get_overall_coverage_weight(VOID), 3, ERROR, "Checking overall coverage weight");
      check_value(v_cross_x3_b.get_overall_coverage_weight(VOID), 3, ERROR, "Checking overall coverage weight");

      check_value(fc_get_overall_coverage(COVPTS), 25.0, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 75.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 75.0, ERROR, "Checking hits overall coverage");
      check_value(not fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage NOT completed");

      sample_bins(v_cross_x2, (0, 1), 10);
      sample_bins(v_cross_x3, 0, 10);

      check_value(fc_get_overall_coverage(COVPTS), 62.5, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 90.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 90.0, ERROR, "Checking hits overall coverage");
      check_value(not fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage NOT completed");

      sample_bins(v_cross_x2_b, 0, 10);
      sample_bins(v_cross_x3_b, 0, 10);

      check_value(fc_get_overall_coverage(COVPTS), 100.0, ERROR, "Checking coverpoints overall coverage");
      check_value(fc_get_overall_coverage(BINS), 100.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 100.0, ERROR, "Checking hits overall coverage");
      check_value(fc_overall_coverage_completed(VOID), ERROR, "Checking overall coverage completed");

      fc_report_overall_coverage(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_init_delete" then
      --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing methods with uninitialized coverpoint");
      ------------------------------------------------------------
      check_value(fc_get_covpts_coverage_goal(VOID), 100, ERROR, "fc_get_covpts_coverage_goal(VOID)");
      check_value(fc_get_overall_coverage(COVPTS), 0.0, ERROR, "fc_get_overall_coverage(COVPTS)");
      check_value(fc_get_overall_coverage(BINS), 0.0, ERROR, "fc_get_overall_coverage(BINS)");
      check_value(fc_get_overall_coverage(HITS), 0.0, ERROR, "fc_get_overall_coverage(HITS)");
      check_value(fc_overall_coverage_completed(VOID), false, ERROR, "fc_overall_coverage_completed(VOID)");
      fc_report_overall_coverage(VERBOSE);

      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = ERROR, ERROR, "get_illegal_bin_alert_level(VOID)");
      check_value(v_coverpoint_a.get_bin_overlap_alert_level(VOID) = NO_ALERT, ERROR, "get_bin_overlap_alert_level(VOID)");
      check_value(v_coverpoint_a.get_overall_coverage_weight(VOID), 1, ERROR, "get_overall_coverage_weight(VOID)");
      check_value(v_coverpoint_a.get_bins_coverage_goal(VOID), 100, ERROR, "get_bins_coverage_goal(VOID)");
      check_value(v_coverpoint_a.get_hits_coverage_goal(VOID), 100, ERROR, "get_hits_coverage_goal(VOID)");
      check_value(v_coverpoint_a.get_name(VOID), "", ERROR, "get_name(VOID)");
      check_value(v_coverpoint_a.get_scope(VOID), C_TB_SCOPE_DEFAULT, ERROR, "get_scope(VOID)");
      check_value(v_coverpoint_a.is_defined(VOID), false, ERROR, "is_defined(VOID)");
      check_value(v_coverpoint_a.get_coverage(BINS), 0.0, ERROR, "Checking get_coverage(BINS)");
      check_value(v_coverpoint_a.get_coverage(HITS), 0.0, ERROR, "Checking get_coverage(HITS)");
      check_value(v_coverpoint_a.coverage_completed(BINS), false, ERROR, "coverage_completed(BINS)");
      check_value(v_coverpoint_a.coverage_completed(HITS), false, ERROR, "coverage_completed(HITS)");
      check_value(v_coverpoint_a.coverage_completed(BINS_AND_HITS), false, ERROR, "coverage_completed(BINS_AND_HITS)");
      v_seeds := v_coverpoint_a.get_rand_seeds(VOID);
      check_value(v_seeds(0), C_RAND_INIT_SEED_1, ERROR, "Checking seed 1");
      check_value(v_seeds(1), C_RAND_INIT_SEED_2, ERROR, "Checking seed 2");
      v_coverpoint_a.report_coverage(VOID);
      v_coverpoint_a.report_config(VOID);
      v_coverpoint_a.clear_coverage(VOID);
      v_coverpoint_a.delete_coverpoint(VOID);

      increment_expected_alerts_and_stop_limit(TB_ERROR, 5);
      v_value             := v_coverpoint_a.rand(NO_SAMPLE_COV);
      v_values_x2(0 to 0) := v_coverpoint_a.rand(NO_SAMPLE_COV);
      v_coverpoint_a.sample_coverage(5);
      v_coverpoint_a.sample_coverage((5, 6, 7));
      v_coverpoint_a.write_coverage_db("db_file.txt");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing deleting a coverpoint");
      ------------------------------------------------------------
      log(ID_SEQUENCER, "Set up the coverpoint");
      v_coverpoint_a.set_name("MY_COVERPOINT");
      v_coverpoint_a.set_scope("MY_SCOPE");
      v_coverpoint_a.set_illegal_bin_alert_level(FAILURE);
      v_coverpoint_a.set_bin_overlap_alert_level(TB_ERROR);
      v_coverpoint_a.set_overall_coverage_weight(5);
      v_coverpoint_a.set_bins_coverage_goal(50);
      v_coverpoint_a.set_hits_coverage_goal(200);
      v_coverpoint_a.add_bins(bin_range(1, 100, 0));
      v_coverpoint_a.add_bins(ignore_bin_range(101, 200));
      for i in 1 to 50 loop
        v_coverpoint_a.sample_coverage(i);
      end loop;
      v_coverpoint_a.set_rand_seeds(12345, 67890);

      log(ID_SEQUENCER, "Check the coverpoint has the right configuration");
      check_value(v_coverpoint_a.get_name(VOID), "MY_COVERPOINT", ERROR, "Checking name");
      check_value(v_coverpoint_a.get_scope(VOID), "MY_SCOPE", ERROR, "Checking scope");
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = FAILURE, ERROR, "Checking illegal bin alert level");
      check_value(v_coverpoint_a.get_bin_overlap_alert_level(VOID) = TB_ERROR, ERROR, "Checking bin overlap alert level");
      check_value(v_coverpoint_a.get_overall_coverage_weight(VOID), 5, ERROR, "Checking coverage weight");
      check_value(v_coverpoint_a.get_bins_coverage_goal(VOID), 50, ERROR, "Checking bins coverage goal");
      check_value(v_coverpoint_a.get_hits_coverage_goal(VOID), 200, ERROR, "Checking hits coverage goal");
      check_value(v_coverpoint_a.is_defined(VOID), true, ERROR, "Checking is_defined(VOID)");
      check_value(v_coverpoint_a.get_num_bins_crossed(VOID), 1, ERROR, "Checking num_bins_crossed");
      check_value(v_coverpoint_a.get_num_valid_bins(VOID), 100, ERROR, "Checking num_valid_bins");
      check_value(v_coverpoint_a.get_num_invalid_bins(VOID), 1, ERROR, "Checking num_invalid_bins");
      check_value(v_coverpoint_a.get_coverage(BINS), 50.0, ERROR, "Checking bins coverage");
      check_value(v_coverpoint_a.get_coverage(HITS), 50.0, ERROR, "Checking hits coverage");
      check_value(fc_get_overall_coverage(COVPTS), 0.0, ERROR, "Checking covpts overall coverage");
      check_value(fc_get_overall_coverage(BINS), 50.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 50.0, ERROR, "Checking hits overall coverage");
      v_seeds := v_coverpoint_a.get_rand_seeds(VOID);
      check_value(v_seeds(0), 12345, ERROR, "Checking seed 1");
      check_value(v_seeds(1), 67890, ERROR, "Checking seed 2");
      v_coverpoint_a.report_coverage(VOID);
      v_coverpoint_a.report_config(VOID);
      fc_report_overall_coverage(VERBOSE);

      log(ID_SEQUENCER, "Delete and check the coverpoint has default values");
      v_coverpoint_a.delete_coverpoint(VOID);
      check_value(v_coverpoint_a.get_name(VOID), "", ERROR, "Checking name");
      check_value(v_coverpoint_a.get_scope(VOID), C_TB_SCOPE_DEFAULT, ERROR, "Checking scope");
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = ERROR, ERROR, "Checking illegal bin alert level");
      check_value(v_coverpoint_a.get_bin_overlap_alert_level(VOID) = NO_ALERT, ERROR, "Checking bin overlap alert level");
      check_value(v_coverpoint_a.get_overall_coverage_weight(VOID), 1, ERROR, "Checking coverage weight");
      check_value(v_coverpoint_a.get_bins_coverage_goal(VOID), 100, ERROR, "Checking bins coverage goal");
      check_value(v_coverpoint_a.get_hits_coverage_goal(VOID), 100, ERROR, "Checking hits coverage goal");
      check_value(v_coverpoint_a.is_defined(VOID), false, ERROR, "Checking is_defined(VOID)");
      check_value(v_coverpoint_a.get_num_bins_crossed(VOID), -1, ERROR, "Checking num_bins_crossed");
      check_value(v_coverpoint_a.get_num_valid_bins(VOID), 0, ERROR, "Checking num_valid_bins");
      check_value(v_coverpoint_a.get_num_invalid_bins(VOID), 0, ERROR, "Checking num_invalid_bins");
      check_value(v_coverpoint_a.get_coverage(BINS), 0.0, ERROR, "Checking bins coverage");
      check_value(v_coverpoint_a.get_coverage(HITS), 0.0, ERROR, "Checking hits coverage");
      check_value(fc_get_overall_coverage(COVPTS), 0.0, ERROR, "Checking covpts overall coverage");
      check_value(fc_get_overall_coverage(BINS), 0.0, ERROR, "Checking bins overall coverage");
      check_value(fc_get_overall_coverage(HITS), 0.0, ERROR, "Checking hits overall coverage");
      v_seeds := v_coverpoint_a.get_rand_seeds(VOID);
      check_value(v_seeds(0), C_RAND_INIT_SEED_1, ERROR, "Checking seed 1");
      check_value(v_seeds(1), C_RAND_INIT_SEED_2, ERROR, "Checking seed 2");
      v_coverpoint_a.report_coverage(VOID);
      v_coverpoint_a.report_config(VOID);
      fc_report_overall_coverage(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing deleting several coverpoints");
      ------------------------------------------------------------
      v_coverpoint_a.add_bins(bin(1));
      v_coverpoint_b.add_bins(bin(2));
      v_coverpoint_c.add_bins(bin(3));
      v_coverpoint_d.add_bins(bin(4));
      fc_report_overall_coverage(VERBOSE);

      v_coverpoint_a.delete_coverpoint(VOID); -- 1st
      v_coverpoint_c.delete_coverpoint(VOID); -- 3rd
      v_coverpoint_d.delete_coverpoint(VOID); -- 4th
      fc_report_overall_coverage(VERBOSE);

      v_coverpoint_a.add_cross(bin(1000), bin(2000));
      v_coverpoint_c.add_cross(bin(1001), bin(2001));
      v_coverpoint_d.add_cross(bin(1002), bin(2002));
      fc_report_overall_coverage(VERBOSE);

      v_coverpoint_a.delete_coverpoint(VOID);
      v_coverpoint_b.delete_coverpoint(VOID);
      v_coverpoint_c.delete_coverpoint(VOID);
      v_coverpoint_d.delete_coverpoint(VOID);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing initializing coverpoints with config procedures");
      ------------------------------------------------------------
      -- The following "set" procedures will initialize each coverpoint (use different variables for each config)
      v_coverpoint_a.set_illegal_bin_alert_level(FAILURE);
      check_value(v_coverpoint_a.get_illegal_bin_alert_level(VOID) = FAILURE, ERROR, "get_illegal_bin_alert_level(VOID)");
      v_coverpoint_b.set_bin_overlap_alert_level(TB_WARNING);
      check_value(v_coverpoint_b.get_bin_overlap_alert_level(VOID) = TB_WARNING, ERROR, "get_bin_overlap_alert_level(VOID)");
      v_coverpoint_c.set_overall_coverage_weight(5);
      check_value(v_coverpoint_c.get_overall_coverage_weight(VOID), 5, ERROR, "get_overall_coverage_weight(VOID)");
      v_coverpoint_d.set_bins_coverage_goal(75);
      check_value(v_coverpoint_d.get_bins_coverage_goal(VOID), 75, ERROR, "get_bins_coverage_goal(VOID)");
      v_cross_x2.set_hits_coverage_goal(300);
      check_value(v_cross_x2.get_hits_coverage_goal(VOID), 300, ERROR, "get_hits_coverage_goal(VOID)");
      v_cross_x2_b.set_name("MY_COVERPOINT");
      check_value(v_cross_x2_b.get_name(VOID), "MY_COVERPOINT", ERROR, "get_name(VOID)");
      v_cross_x3.set_scope("MY_SCOPE");
      check_value(v_cross_x3.get_scope(VOID), "MY_SCOPE", ERROR, "get_scope(VOID)");
      v_cross_x4.set_rand_seeds(12345, 67890);
      v_seeds := v_cross_x4.get_rand_seeds(VOID);
      check_value(v_seeds(0), 12345, ERROR, "Checking seed 1");
      check_value(v_seeds(1), 67890, ERROR, "Checking seed 2");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing methods with initialized coverpoint without bins");
      ------------------------------------------------------------
      check_value(v_coverpoint_a.is_defined(VOID), false, ERROR, "is_defined(VOID)");
      v_coverpoint_a.write_coverage_db("db_file.txt");

      increment_expected_alerts_and_stop_limit(TB_ERROR, 4);
      v_value             := v_coverpoint_a.rand(NO_SAMPLE_COV);
      v_values_x2(0 to 0) := v_coverpoint_a.rand(NO_SAMPLE_COV);
      v_coverpoint_a.sample_coverage(5);
      v_coverpoint_a.sample_coverage((5, 6, 7));

    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- Allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED");
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

  p_sampling : process
    constant C_SCOPE      : string := "p_sampling";
    constant C_CLK_PERIOD : time   := 10 ns;
  begin
    if GC_TESTCASE = "fc_bins" then
      -- To avoid that log files from different test cases (run in separate
      -- simulations) overwrite each other.
      set_log_file_name(GC_TESTCASE & "_Log.txt");
      set_alert_file_name(GC_TESTCASE & "_Alert.txt");

      log(ID_SEQUENCER, "Waiting for coverpoint to be initialized", C_SCOPE);
      wait until shared_coverpoint_initialized'event;
      log(ID_SEQUENCER, "Coverpoint initialized, ready to sample", C_SCOPE);
      shared_coverpoint.sample_coverage(10000);
      wait;
    end if;
    wait;
  end process p_sampling;

end architecture func;
