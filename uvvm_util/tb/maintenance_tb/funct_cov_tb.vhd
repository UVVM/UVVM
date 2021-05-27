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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--HDLUnit:TB
entity funct_cov_tb is
  generic(
    GC_TESTCASE : string
  );
end entity;

architecture func of funct_cov_tb is

  type t_integer_array is array (natural range <>) of integer_vector;
  type t_cov_bin_type_array is array (natural range <>) of t_cov_bin_type;

  shared variable v_coverpoint   : t_coverpoint;
  shared variable v_coverpoint_b : t_coverpoint;
  shared variable v_cross_x2     : t_coverpoint;

  constant C_ADAPTIVE_WEIGHT : integer := -1;
  constant C_NULL            : integer := integer'left;

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_bin_idx          : natural := 0;
    variable v_invalid_bin_idx  : natural := 0;
    variable v_vector           : std_logic_vector(1 downto 0);
    variable v_rand             : t_rand;
    variable v_bin_val          : integer;
    variable v_min_hits         : natural;
    variable v_prev_min_hits    : natural := 0;
    variable v_value            : integer;

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
      constant contains    : in    t_cov_bin_type_array;
      constant values      : in    t_integer_array;
      constant min_hits    : in    natural;
      constant rand_weight : in    integer;
      constant name        : in    string;
      constant hits        : in    natural;
      constant ign_or_ill  : in    boolean;
      constant proc_call   : in    string) is
      variable v_bin          : t_cov_bin;
      variable v_bin_name_idx : natural;
      variable v_num_values   : natural;
    begin
      check_value(contains'length, values'length, TB_ERROR, "contains must be the same length as values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);

      if not(ign_or_ill) then
        v_bin          := coverpoint.get_valid_bin(bin_idx);
        v_bin_name_idx := bin_idx + coverpoint.get_num_invalid_bins(VOID);
      else
        v_bin          := coverpoint.get_invalid_bin(bin_idx);
        v_bin_name_idx := bin_idx + coverpoint.get_num_valid_bins(VOID);
      end if;

      for i in 0 to values'length-1 loop
        check_value(v_bin.cross_bins(i).contains = contains(i),       ERROR, "Checking bin type. Was: " & to_upper(to_string(v_bin.cross_bins(i).contains)) &
          ". Expected: " & to_upper(to_string(contains(i))), C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
        v_num_values := 0;
        for j in 0 to values(i)'length-1 loop
          if values(i)(j) /= C_NULL then
            check_value(v_bin.cross_bins(i).values(j), values(i)(j),  ERROR, "Checking bin values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
            v_num_values := v_num_values + 1;
          end if;
        end loop;
        check_value(v_bin.cross_bins(i).num_values, v_num_values,     ERROR, "Checking bin number of values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
        check_value(v_bin.cross_bins(i).transition_idx, 0,            ERROR, "Checking bin transition index", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      end loop;
      check_value(v_bin.min_hits, min_hits,                           ERROR, "Checking bin minimum hits", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      check_value(v_bin.rand_weight, rand_weight,                     ERROR, "Checking bin randomization weight", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      if name = "" then
        check_value(to_string(v_bin.name), "bin_" & to_string(v_bin_name_idx), ERROR, "Checking bin name", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      else
        check_value(to_string(v_bin.name), name,                      ERROR, "Checking bin name", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);
      end if;
      check_value(v_bin.hits, hits,                                   ERROR, "Checking bin hits", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => proc_call);

      bin_idx := bin_idx + 1;
      log(ID_POS_ACK, proc_call & " => OK, for " & v_bin.name);
    end procedure;

    -- Overload
    procedure check_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type;
      constant values      : in    integer_vector;
      constant min_hits    : in    natural := 1;
      constant rand_weight : in    integer := C_ADAPTIVE_WEIGHT;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
      constant C_PROC_NAME : string := "check_bin";
      variable v_values    : t_integer_array(0 to 0)(values'range) := (0 => values);
    begin
      check_bin(coverpoint, bin_idx, (0 => contains), v_values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload
    procedure check_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type;
      constant value       : in    integer;
      constant min_hits    : in    natural := 1;
      constant rand_weight : in    integer := C_ADAPTIVE_WEIGHT;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
    begin
      check_bin(coverpoint, bin_idx, contains, (0 => value), min_hits, rand_weight, name, hits);
    end procedure;

    -- Overload for crossed bins
    procedure check_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type_array;
      constant values      : in    t_integer_array;
      constant min_hits    : in    natural := 1;
      constant rand_weight : in    integer := C_ADAPTIVE_WEIGHT;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
      constant C_PROC_NAME : string := "check_cross_bin";
    begin
      check_bin(coverpoint, bin_idx, contains, values, min_hits, rand_weight, name, hits, false, C_PROC_NAME);
    end procedure;

    -- Overload for ignore and illegal bins
    procedure check_invalid_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type;
      constant values      : in    integer_vector;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
      constant C_PROC_NAME : string := "check_invalid_bin";
      variable v_values    : t_integer_array(0 to 0)(values'range) := (0 => values);
    begin
      check_bin(coverpoint, bin_idx, (0 => contains), v_values, 0, 0, name, hits, true, C_PROC_NAME);
    end procedure;

    -- Overload for ignore and illegal bins
    procedure check_invalid_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type;
      constant value       : in    integer;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
    begin
      check_invalid_bin(coverpoint, bin_idx, contains, (0 => value), name, hits);
    end procedure;

    -- Overload for ignore and illegal crossed bins
    procedure check_invalid_cross_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type_array;
      constant values      : in    t_integer_array;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
      constant C_PROC_NAME : string := "check_invalid_cross_bin";
    begin
      check_bin(coverpoint, bin_idx, contains, values, 0, 0, name, hits, true, C_PROC_NAME);
    end procedure;

    -- Checks the number of bins in the coverpoint
    procedure check_num_bins(
      variable coverpoint       : inout t_coverpoint;
      constant num_valid_bins   : in    natural;
      constant num_invalid_bins : in    natural) is
      constant C_PROC_NAME : string := "check_num_bins";
    begin
      check_value(coverpoint.get_num_valid_bins(VOID), num_valid_bins, ERROR, "Checking number of valid bins", C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
      check_value(coverpoint.get_num_invalid_bins(VOID), num_invalid_bins, ERROR, "Checking number of invalid bins", C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
    end procedure;

    -- Samples several values in the coverpoint a number of times
    procedure sample_bins(
      variable coverpoint  : inout t_coverpoint;
      constant values      : in    integer_vector;
      constant num_samples : in    positive := 1) is
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
      constant value       : in    integer;
      constant num_samples : in    positive := 1) is
    begin
      sample_bins(coverpoint, (0 => value), num_samples);
    end procedure;

    -- Overload
    procedure sample_cross_bins(
      variable coverpoint  : inout t_coverpoint;
      constant values      : in    t_integer_array;
      constant num_samples : in    positive := 1) is
    begin
      for i in 1 to num_samples loop
        for j in values'range loop
          coverpoint.sample_coverage(values(j));
        end loop;
      end loop;
    end procedure;

    -- Checks the coverage in the coverpoint
    procedure check_coverage(
      variable coverpoint : inout t_coverpoint;
      constant coverage   : in    real) is
      constant C_PROC_NAME : string := "check_coverage";
    begin
      if coverpoint.get_coverage(VOID) = coverage then
        if coverpoint.coverage_completed(VOID) and coverage = 100.0 then
          log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_string(coverage,2) & "% - Coverage completed");
        elsif not(coverpoint.coverage_completed(VOID)) and coverage < 100.0 then
          log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_string(coverage,2) & "%");
        else
          alert(ERROR, C_PROC_NAME & " => Failed, coverage_completed() returned wrong value");
        end if;
      else
        alert(ERROR, C_PROC_NAME & " => Failed, for " & to_string(coverpoint.get_coverage(VOID),2) & "%, expected " & to_string(coverage,2) & "%");
      end if;
    end procedure;

    -- Checks that the number of hits from a bin in the coverpoint
    -- is greater than a certain value
    procedure check_bin_hits_is_greater(
      variable coverpoint  : inout t_coverpoint;
      constant bin_idx     : in    natural;
      constant min_hits    : in    natural) is
      constant C_PROC_NAME : string := "check_bin_hits_is_greater";
      variable v_bin       : t_cov_bin;
    begin
      v_bin := coverpoint.get_valid_bin(bin_idx);
      check_value(v_bin.hits > min_hits, ERROR, "Checking bin " & to_upper(to_string(v_bin.cross_bins(0).contains)) & ":" &
        to_string(v_bin.cross_bins(0).values(0 to v_bin.cross_bins(0).num_values-1)) & " was selected for randomization",
        C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
    end procedure;

    -- Generates random numbers from the uncovered bins and samples the coverpoint.
    -- Checks that the randomization follows the weighted distribution by checking
    -- at which iteration number the bin was covered.
    procedure randomize_and_check_distribution(
      variable coverpoint            : inout t_coverpoint;
      constant bin_covered_iteration : in    integer_vector) is
      type t_test_bin is record
        value     : natural;
        min_hits  : natural;
        iteration : natural;
        counter   : natural;
      end record;
      type t_test_bin_array is array (natural range <>) of t_test_bin;
      constant C_PROC_NAME        : string := "randomize_and_check_distribution";
      variable v_bin_vector       : t_cov_bin_vector(0 to coverpoint.get_num_valid_bins(VOID)-1);
      variable v_test_bins        : t_test_bin_array(0 to bin_covered_iteration'length-1) := (others => (others => 0));
      variable v_idx              : natural := 0;
      variable v_total_iterations : natural := 0;
      variable v_margin           : natural;
    begin
      v_bin_vector := coverpoint.get_valid_bins(VOID);

      -- Copy the necessary information to the test vector
      for i in 0 to v_bin_vector'length-1 loop
        -- We assume that only the new bins meant for the current test will have 0 hits
        if v_bin_vector(i).hits = 0 then
          check_value(v_idx < bin_covered_iteration'length, TB_ERROR, "bin_covered_iteration length must be the same size as the number of bins to randomize", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
          v_test_bins(v_idx).value     := v_bin_vector(i).cross_bins(0).values(0);
          v_test_bins(v_idx).min_hits  := v_bin_vector(i).min_hits;
          v_test_bins(v_idx).iteration := bin_covered_iteration(v_idx);
          v_total_iterations := v_total_iterations + v_bin_vector(i).min_hits;
          v_idx := v_idx + 1;
        end if;
      end loop;

      v_margin := integer(real(v_total_iterations)*0.15);
      for i in 1 to v_total_iterations loop
        v_value := coverpoint.rand(VOID);
        coverpoint.sample_coverage(v_value);

        for j in v_test_bins'range loop
          if v_value = v_test_bins(j).value then
            v_test_bins(j).counter := v_test_bins(j).counter + 1;
          end if;
          if v_test_bins(j).counter = v_test_bins(j).min_hits then
            check_value_in_range(i, v_test_bins(j).iteration-v_margin, v_test_bins(j).iteration+v_margin, ERROR, "Bin " & to_string(j) &
              " covered in expected iteration", C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
            v_test_bins(j).counter := 0;
          end if;
        end loop;
      end loop;
    end procedure;

  begin

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Functional Coverage package - " & GC_TESTCASE);
    -------------------------------------------------------------------------------------------
    enable_log_msg(ID_FUNCT_COV);
    enable_log_msg(ID_FUNCT_COV_BINS);
    enable_log_msg(ID_FUNCT_COV_RAND);
    enable_log_msg(ID_FUNCT_COV_SAMPLE);
    enable_log_msg(ID_FUNCT_COV_CONFIG);

    --===================================================================================
    if GC_TESTCASE = "fc_basic" then
    --===================================================================================
      v_coverpoint.set_name("MY_COVERPOINT");
      check_value("MY_COVERPOINT", v_coverpoint.get_name(VOID), ERROR, "Checking name");
      v_coverpoint.set_scope("MY_SCOPE");
      check_value("MY_SCOPE", v_coverpoint.get_scope(VOID), ERROR, "Checking scope");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with single values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(bin(-101));
      v_coverpoint.add_bins(bin(-100));
      v_coverpoint.add_bins(bin(100));
      v_coverpoint.add_bins(bin(101));

      check_bin(v_coverpoint, v_bin_idx, VAL, -101);
      check_bin(v_coverpoint, v_bin_idx, VAL, -100);
      check_bin(v_coverpoint, v_bin_idx, VAL,  100);
      check_bin(v_coverpoint, v_bin_idx, VAL,  101);

      sample_bins(v_coverpoint, (-101,-100,100,101), 1);
      sample_bins(v_coverpoint, (-103,-102,102,103), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-4;
      check_bin(v_coverpoint, v_bin_idx, VAL, -101, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, -100, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL,  100, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL,  101, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with multiple values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(bin((202,204,206,208)));
      v_coverpoint.add_bins(bin((210,211,212,213,214,215,216,217,218,219)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(bin((220,221,222,223,224,225,226,227,228,229,230))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_bin(v_coverpoint, v_bin_idx, VAL, (202,204,206,208));
      check_bin(v_coverpoint, v_bin_idx, VAL, (210,211,212,213,214,215,216,217,218,219));
      check_bin(v_coverpoint, v_bin_idx, VAL, (220,221,222,223,224,225,226,227,228,229));

      sample_bins(v_coverpoint, (202,204,206,208), 1);
      sample_bins(v_coverpoint, (210,211,212,213,214,215,216,217,218,219), 1);
      sample_bins(v_coverpoint, (220,221,222,223,224,225,226,227,228,229), 1);
      sample_bins(v_coverpoint, (201,203,205,207,209,230), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-3;
      check_bin(v_coverpoint, v_bin_idx, VAL, (202,204,206,208), hits => 4);
      check_bin(v_coverpoint, v_bin_idx, VAL, (210,211,212,213,214,215,216,217,218,219), hits => 10);
      check_bin(v_coverpoint, v_bin_idx, VAL, (220,221,222,223,224,225,226,227,228,229), hits => 10);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with ranges of values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(bin_range(300,309,1));
      v_coverpoint.add_bins(bin_range(311,315,2));
      v_coverpoint.add_bins(bin_range(320,328,3));
      v_coverpoint.add_bins(bin_range(330,334,20));
      v_coverpoint.add_bins(bin_range(341,343));
      v_coverpoint.add_bins(bin_range(355,355));
      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_coverpoint.add_bins(bin_range(363,361));

      check_bin(v_coverpoint, v_bin_idx, RAN, (300,309));
      check_bin(v_coverpoint, v_bin_idx, RAN, (311,312));
      check_bin(v_coverpoint, v_bin_idx, RAN, (313,315));
      check_bin(v_coverpoint, v_bin_idx, RAN, (320,322));
      check_bin(v_coverpoint, v_bin_idx, RAN, (323,325));
      check_bin(v_coverpoint, v_bin_idx, RAN, (326,328));
      check_bin(v_coverpoint, v_bin_idx, VAL, 330);
      check_bin(v_coverpoint, v_bin_idx, VAL, 331);
      check_bin(v_coverpoint, v_bin_idx, VAL, 332);
      check_bin(v_coverpoint, v_bin_idx, VAL, 333);
      check_bin(v_coverpoint, v_bin_idx, VAL, 334);
      check_bin(v_coverpoint, v_bin_idx, VAL, 341);
      check_bin(v_coverpoint, v_bin_idx, VAL, 342);
      check_bin(v_coverpoint, v_bin_idx, VAL, 343);
      check_bin(v_coverpoint, v_bin_idx, VAL, 355);

      sample_bins(v_coverpoint, (300,301,302,303,304,305,306,307,308,309), 1);
      sample_bins(v_coverpoint, (311,312,313,314,315), 1);
      sample_bins(v_coverpoint, (320,321,322,323,324,325,326,327,328), 1);
      sample_bins(v_coverpoint, (330,331,332,333,334), 1);
      sample_bins(v_coverpoint, (341,342,343), 1);
      sample_bins(v_coverpoint, (355), 1);
      sample_bins(v_coverpoint, (310,316,317,318,319,329,335,340,344,354,356), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-15;
      check_bin(v_coverpoint, v_bin_idx, RAN, (300,309), hits => 10);
      check_bin(v_coverpoint, v_bin_idx, RAN, (311,312), hits => 2);
      check_bin(v_coverpoint, v_bin_idx, RAN, (313,315), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, RAN, (320,322), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, RAN, (323,325), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, RAN, (326,328), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, VAL, 330, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 331, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 332, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 333, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 334, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 341, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 342, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 343, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 355, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins created from a vector");
      ------------------------------------------------------------
      v_coverpoint.add_bins(bin_vector(v_vector,1));
      v_coverpoint.add_bins(bin_vector(v_vector,2));
      v_coverpoint.add_bins(bin_vector(v_vector,3));
      v_coverpoint.add_bins(bin_vector(v_vector,20));
      v_coverpoint.add_bins(bin_vector(v_vector));

      check_bin(v_coverpoint, v_bin_idx, RAN, (0,3));
      check_bin(v_coverpoint, v_bin_idx, RAN, (0,1));
      check_bin(v_coverpoint, v_bin_idx, RAN, (2,3));
      check_bin(v_coverpoint, v_bin_idx, RAN, (0,0));
      check_bin(v_coverpoint, v_bin_idx, RAN, (1,1));
      check_bin(v_coverpoint, v_bin_idx, RAN, (2,3));
      check_bin(v_coverpoint, v_bin_idx, VAL, 0);
      check_bin(v_coverpoint, v_bin_idx, VAL, 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 2);
      check_bin(v_coverpoint, v_bin_idx, VAL, 3);
      check_bin(v_coverpoint, v_bin_idx, VAL, 0);
      check_bin(v_coverpoint, v_bin_idx, VAL, 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 2);
      check_bin(v_coverpoint, v_bin_idx, VAL, 3);

      sample_bins(v_coverpoint, (0,1,2,3), 1);
      sample_bins(v_coverpoint, (-1,4,5,6), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-14;
      check_bin(v_coverpoint, v_bin_idx, RAN, (0,3), hits => 4);
      check_bin(v_coverpoint, v_bin_idx, RAN, (0,1), hits => 2);
      check_bin(v_coverpoint, v_bin_idx, RAN, (2,3), hits => 2);
      check_bin(v_coverpoint, v_bin_idx, RAN, (0,0), hits => 1);
      check_bin(v_coverpoint, v_bin_idx, RAN, (1,1), hits => 1);
      check_bin(v_coverpoint, v_bin_idx, RAN, (2,3), hits => 2);
      check_bin(v_coverpoint, v_bin_idx, VAL, 0, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 1, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 2, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 3, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 0, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 1, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 2, hits => 1);
      check_bin(v_coverpoint, v_bin_idx, VAL, 3, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(bin_transition((401,403,405,409)));
      v_coverpoint.add_bins(bin_transition((410,410,410,418,415,415,410)));
      v_coverpoint.add_bins(bin_transition((420,421,422,423,424,425,426,427,428,429)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(bin_transition((430,431,432,433,434,435,436,437,438,439,440))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_bin(v_coverpoint, v_bin_idx, TRN, (401,403,405,409));
      check_bin(v_coverpoint, v_bin_idx, TRN, (410,410,410,418,415,415,410));
      check_bin(v_coverpoint, v_bin_idx, TRN, (420,421,422,423,424,425,426,427,428,429));
      check_bin(v_coverpoint, v_bin_idx, TRN, (430,431,432,433,434,435,436,437,438,439));

      sample_bins(v_coverpoint, (401,403,405,409), 3);
      sample_bins(v_coverpoint, (410,410,410,418,415,415,410), 3);
      sample_bins(v_coverpoint, (420,421,422,423,424,425,426,427,428,429), 3);
      sample_bins(v_coverpoint, (430,431,432,433,434,435,436,437,438,439), 3);
      sample_bins(v_coverpoint, (401,403,405,408), 1);                         -- Sample values outside bins
      sample_bins(v_coverpoint, (410,410,410,418,415,414,410), 1);             -- Sample values outside bins
      sample_bins(v_coverpoint, (420,421,422,423,424,425,426,427,428,430), 1); -- Sample values outside bins
      sample_bins(v_coverpoint, (430,431,432,433,434,435,436,437,438,440), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-4;
      check_bin(v_coverpoint, v_bin_idx, TRN, (401,403,405,409), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, TRN, (410,410,410,418,415,415,410), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, TRN, (420,421,422,423,424,425,426,427,428,429), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, TRN, (430,431,432,433,434,435,436,437,438,439), hits => 3);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore bins with single values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(ignore_bin(-2001));
      v_coverpoint.add_bins(ignore_bin(-2000));
      v_coverpoint.add_bins(ignore_bin(2000));
      v_coverpoint.add_bins(ignore_bin(2001));

      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, -2001);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, -2000);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE,  2000);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE,  2001);

      sample_bins(v_coverpoint, (-2001,-2000,2000,2001), 1);
      sample_bins(v_coverpoint, (-2003,-2002,2002,2003), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-4;
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, -2001, hits => 1);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, -2000, hits => 1);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE,  2000, hits => 1);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE,  2001, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore bins with ranges of values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(ignore_bin_range(2100,2109));
      v_coverpoint.add_bins(ignore_bin_range(2115,2115));
      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_coverpoint.add_bins(ignore_bin_range(2129,2126));

      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, RAN_IGNORE, (2100,2109));
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, 2115);

      sample_bins(v_coverpoint, (2100,2101,2102,2103,2104,2105,2106,2107,2108,2109), 1);
      sample_bins(v_coverpoint, (2115), 1);
      sample_bins(v_coverpoint, (2110,2111,2114,2116), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-2;
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, RAN_IGNORE, (2100,2109), hits => 10);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, 2115, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(ignore_bin_transition((2201,2203,2205,2209)));
      v_coverpoint.add_bins(ignore_bin_transition((2210,2210,2210,2218,2215,2215,2210)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(ignore_bin_transition((2220,2221,2222,2223,2224,2225,2226,2227,2228,2229,2230))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2201,2203,2205,2209));
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2210,2210,2210,2218,2215,2215,2210));
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2220,2221,2222,2223,2224,2225,2226,2227,2228,2229));

      sample_bins(v_coverpoint, (2201,2203,2205,2209), 3);
      sample_bins(v_coverpoint, (2210,2210,2210,2218,2215,2215,2210), 3);
      sample_bins(v_coverpoint, (2220,2221,2222,2223,2224,2225,2226,2227,2228,2229), 3);
      sample_bins(v_coverpoint, (2201,2203,2205,2208), 1);                               -- Sample values outside bins
      sample_bins(v_coverpoint, (2210,2210,2210,2218,2215,2214,2210), 1);                -- Sample values outside bins
      sample_bins(v_coverpoint, (2220,2221,2222,2223,2224,2225,2226,2227,2228,2230), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-3;
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2201,2203,2205,2209), hits => 3);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2210,2210,2210,2218,2215,2215,2210), hits => 3);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2220,2221,2222,2223,2224,2225,2226,2227,2228,2229), hits => 3);

      v_coverpoint.set_illegal_bin_alert_level(WARNING);
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal bins with single values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(illegal_bin(-3001));
      v_coverpoint.add_bins(illegal_bin(-3000));
      v_coverpoint.add_bins(illegal_bin(3000));
      v_coverpoint.add_bins(illegal_bin(3001));

      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, -3001);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, -3000);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL,  3000);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL,  3001);

      increment_expected_alerts(WARNING,4);
      sample_bins(v_coverpoint, (-3001,-3000,3000,3001), 1);
      sample_bins(v_coverpoint, (-3003,-3002,3002,3003), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-4;
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, -3001, hits => 1);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, -3000, hits => 1);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL,  3000, hits => 1);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL,  3001, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal bins with ranges of values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(illegal_bin_range(3100,3109));
      v_coverpoint.add_bins(illegal_bin_range(3115,3115));
      increment_expected_alerts_and_stop_limit(TB_ERROR,1);
      v_coverpoint.add_bins(illegal_bin_range(3129,3126));

      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, RAN_ILLEGAL, (3100,3109));
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, 3115);

      increment_expected_alerts(WARNING,11);
      sample_bins(v_coverpoint, (3100,3101,3102,3103,3104,3105,3106,3107,3108,3109), 1);
      sample_bins(v_coverpoint, (3115), 1);
      sample_bins(v_coverpoint, (3110,3111,3114,3116), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-2;
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, RAN_ILLEGAL, (3100,3109), hits => 10);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, 3115, hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal bins with transitions of values");
      ------------------------------------------------------------
      v_coverpoint.add_bins(illegal_bin_transition((3201,3203,3205,3209)));
      v_coverpoint.add_bins(illegal_bin_transition((3210,3210,3210,3218,3215,3215,3210)));
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(illegal_bin_transition((3220,3221,3222,3223,3224,3225,3226,3227,3228,3229,3230))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3201,3203,3205,3209));
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3210,3210,3210,3218,3215,3215,3210));
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3220,3221,3222,3223,3224,3225,3226,3227,3228,3229));

      increment_expected_alerts(WARNING,9);
      sample_bins(v_coverpoint, (3201,3203,3205,3209), 3);
      sample_bins(v_coverpoint, (3210,3210,3210,3218,3215,3215,3210), 3);
      sample_bins(v_coverpoint, (3220,3221,3222,3223,3224,3225,3226,3227,3228,3229), 3);
      sample_bins(v_coverpoint, (3201,3203,3205,3208), 1);                               -- Sample values outside bins
      sample_bins(v_coverpoint, (3210,3210,3210,3218,3215,3214,3210), 1);                -- Sample values outside bins
      sample_bins(v_coverpoint, (3220,3221,3222,3223,3224,3225,3226,3227,3228,3230), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-3;
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3201,3203,3205,3209), hits => 3);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3210,3210,3210,3218,3215,3215,3210), hits => 3);
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3220,3221,3222,3223,3224,3225,3226,3227,3228,3229), hits => 3);

      check_num_bins(v_coverpoint, v_bin_idx, v_invalid_bin_idx);
      check_coverage(v_coverpoint, 100.0);
      v_coverpoint.print_summary(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing minimum coverage");
      ------------------------------------------------------------
      v_bin_idx         := 0;
      v_invalid_bin_idx := 0;

      for i in 1 to 10 loop
        v_bin_val  := v_rand.rand(100,500);
        v_min_hits := v_rand.rand(1,20);
        v_coverpoint_b.add_bins(bin(v_bin_val), v_min_hits);

        check_bin(v_coverpoint_b, v_bin_idx, VAL, v_bin_val, v_min_hits);

        -- Check the coverage increases when the bin is sampled until it is 100%
        for j in 0 to v_min_hits-1 loop
          check_coverage(v_coverpoint_b, 100.0*real(j+v_prev_min_hits)/real(v_min_hits+v_prev_min_hits));
          sample_bins(v_coverpoint_b, v_bin_val, 1);
        end loop;
        check_coverage(v_coverpoint_b, 100.0);

        v_bin_idx := v_bin_idx-1;
        check_bin(v_coverpoint_b, v_bin_idx, VAL, v_bin_val, v_min_hits, hits => v_min_hits);
        v_prev_min_hits := v_prev_min_hits + v_min_hits;
      end loop;

      v_coverpoint_b.print_summary(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing coverpoint name and scope");
      ------------------------------------------------------------
      v_coverpoint_b.set_name("MY_COVERPOINT_2_abcdefghiklmno"); -- C_FC_MAX_NAME_LENGTH = 20
      check_value("MY_COVERPOINT_2_abcd", v_coverpoint_b.get_name(VOID), ERROR, "Checking name");
      v_coverpoint_b.set_scope("MY_SCOPE_2");
      check_value("MY_SCOPE_2", v_coverpoint_b.get_scope(VOID), ERROR, "Checking scope");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin names");
      ------------------------------------------------------------
      v_coverpoint_b.add_bins(bin(1000));
      v_coverpoint_b.add_bins(bin(1001), "my_bin_1");
      v_coverpoint_b.add_bins(bin(1002), 5, "my_bin_2");
      v_coverpoint_b.add_bins(bin(1003), 5, 1, "my_bin_3");
      v_coverpoint_b.add_bins(bin(1004), 5, 1, "my_bin_long_name_abcdefghijklmno"); -- C_FC_MAX_NAME_LENGTH = 20

      check_bin(v_coverpoint_b, v_bin_idx, VAL, 1000);
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 1001, name => "my_bin_1");
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 1002, 5, name => "my_bin_2");
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 1003, 5, 1, name => "my_bin_3");
      check_bin(v_coverpoint_b, v_bin_idx, VAL, 1004, 5, 1, name => "my_bin_long_name_abc");

      v_coverpoint_b.print_summary(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing bin overlap");
      ------------------------------------------------------------
      v_coverpoint_b.add_bins(bin(2000));
      v_coverpoint_b.add_bins(bin(2000));
      v_coverpoint_b.add_bins(bin(2000));
      v_coverpoint_b.add_bins(bin((2100,2101,2102,2113,2114)));
      v_coverpoint_b.add_bins(bin((2114,2115,2116,2117)));
      v_coverpoint_b.add_bins(bin_range(2200,2250,1));
      v_coverpoint_b.add_bins(bin_range(2249,2299,1));
      sample_bins(v_coverpoint_b, (2000,2001), 1);
      sample_bins(v_coverpoint_b, (2113,2114,2115), 1);
      sample_bins(v_coverpoint_b, (2248,2249,2250,2251), 1);

      v_coverpoint_b.detect_bin_overlap(true);
      increment_expected_alerts(TB_WARNING, 4);
      sample_bins(v_coverpoint_b, (2000,2001), 1);
      sample_bins(v_coverpoint_b, (2113,2114,2115), 1);
      sample_bins(v_coverpoint_b, (2248,2249,2250,2251), 1);

      v_coverpoint_b.print_summary(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_rand" then
    --===================================================================================
      disable_log_msg(ID_FUNCT_COV_SAMPLE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization doesn't select ignore or illegal bins");
      ------------------------------------------------------------
      v_coverpoint.add_bins(ignore_bin(2000), "bin_0");
      v_coverpoint.add_bins(ignore_bin_range(2100,2109), "bin_1");
      v_coverpoint.add_bins(ignore_bin_transition((2201,2203,2205,2209)), "bin_2");
      v_coverpoint.add_bins(illegal_bin(3000), "bin_3");
      v_coverpoint.add_bins(illegal_bin_range(3100,3109), "bin_4");
      v_coverpoint.add_bins(illegal_bin_transition((3201,3203,3205,3209)), "bin_5");

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with single values");
      ------------------------------------------------------------
      v_min_hits := 1;
      v_coverpoint.add_bins(bin_range(1,50));

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 50*v_min_hits loop
        v_value := v_coverpoint.rand(VOID);
        v_coverpoint.sample_coverage(v_value);
      end loop;

      for i in 1 to 50 loop
        check_bin(v_coverpoint, v_bin_idx, VAL, i, v_min_hits, hits => v_min_hits);
      end loop;
      check_coverage(v_coverpoint, 100.0);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with multiple values");
      ------------------------------------------------------------
      v_min_hits := 2;
      v_coverpoint.add_bins(bin((200,201,202,203,204)), v_min_hits);
      v_coverpoint.add_bins(bin((210,211,212,213,214)), v_min_hits);
      v_coverpoint.add_bins(bin((220,221,222,223,224)), v_min_hits);
      v_coverpoint.add_bins(bin((230,231,232,233,234)), v_min_hits);
      v_coverpoint.add_bins(bin((240,241,242,243,244)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5*v_min_hits loop
        v_value := v_coverpoint.rand(VOID);
        v_coverpoint.sample_coverage(v_value);
      end loop;

      check_bin(v_coverpoint, v_bin_idx, VAL, (200,201,202,203,204), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, VAL, (210,211,212,213,214), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, VAL, (220,221,222,223,224), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, VAL, (230,231,232,233,234), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, VAL, (240,241,242,243,244), v_min_hits, hits => v_min_hits);
      check_coverage(v_coverpoint, 100.0);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with a range of values");
      ------------------------------------------------------------
      v_min_hits := 3;
      v_coverpoint.add_bins(bin_range(300,309,1), v_min_hits);
      v_coverpoint.add_bins(bin_range(310,319,1), v_min_hits);
      v_coverpoint.add_bins(bin_range(320,329,1), v_min_hits);
      v_coverpoint.add_bins(bin_range(330,339,1), v_min_hits);
      v_coverpoint.add_bins(bin_range(340,349,1), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5*v_min_hits loop
        v_value := v_coverpoint.rand(VOID);
        v_coverpoint.sample_coverage(v_value);
      end loop;

      check_bin(v_coverpoint, v_bin_idx, RAN, (300,309), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, RAN, (310,319), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, RAN, (320,329), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, RAN, (330,339), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, RAN, (340,349), v_min_hits, hits => v_min_hits);
      check_coverage(v_coverpoint, 100.0);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among bins with a transition of values");
      ------------------------------------------------------------
      v_min_hits := 4;
      v_coverpoint.add_bins(bin_transition((400,402,404,406,408)), v_min_hits);
      v_coverpoint.add_bins(bin_transition((410,412,414,416,418)), v_min_hits);
      v_coverpoint.add_bins(bin_transition((420,422,424,426,428)), v_min_hits);
      v_coverpoint.add_bins(bin_transition((430,432,434,436,438)), v_min_hits);
      v_coverpoint.add_bins(bin_transition((440,442,444,446,448)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to 5*5*v_min_hits loop
        v_value := v_coverpoint.rand(VOID);
        v_coverpoint.sample_coverage(v_value);
      end loop;

      check_bin(v_coverpoint, v_bin_idx, TRN, (400,402,404,406,408), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, TRN, (410,412,414,416,418), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, TRN, (420,422,424,426,428), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, TRN, (430,432,434,436,438), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, TRN, (440,442,444,446,448), v_min_hits, hits => v_min_hits);
      check_coverage(v_coverpoint, 100.0);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization among different types of bins");
      ------------------------------------------------------------
      v_min_hits := 5;
      v_coverpoint.add_bins(bin(60), v_min_hits);
      v_coverpoint.add_bins(bin((250,251,252,253,254)), v_min_hits);
      v_coverpoint.add_bins(bin_range(350,359,1), v_min_hits);
      v_coverpoint.add_bins(bin_transition((450,452,454,456,458)), v_min_hits);

      -- Randomize and sample the exact number of times to cover all bins
      for i in 1 to (3+1*5)*v_min_hits loop
        v_value := v_coverpoint.rand(VOID);
        v_coverpoint.sample_coverage(v_value);
      end loop;

      check_bin(v_coverpoint, v_bin_idx, VAL, 60,                    v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, VAL, (250,251,252,253,254), v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, RAN, (350,359),             v_min_hits, hits => v_min_hits);
      check_bin(v_coverpoint, v_bin_idx, TRN, (450,452,454,456,458), v_min_hits, hits => v_min_hits);
      check_coverage(v_coverpoint, 100.0);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing all bins are selected for randomization when coverage is complete");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNCT_COV_RAND);

      log(ID_SEQUENCER, "Calling rand() 1000 times");
      for i in 1 to 1000 loop
        v_value := v_coverpoint.rand(VOID);
        v_coverpoint.sample_coverage(v_value);
      end loop;

      -- By checking that the number of hits in the bins is greater than their minimum coverage,
      -- we can assure that every bin was selected for randomization after the previous tests.
      for i in 0 to v_bin_idx-1 loop
        if i < 50 then
          check_bin_hits_is_greater(v_coverpoint, i, 1);
        elsif i < 55 then
          check_bin_hits_is_greater(v_coverpoint, i, 2);
        elsif i < 60 then
          check_bin_hits_is_greater(v_coverpoint, i, 3);
        elsif i < 65 then
          check_bin_hits_is_greater(v_coverpoint, i, 4);
        elsif i < 69 then
          check_bin_hits_is_greater(v_coverpoint, i, 5);
        else
          alert(TB_ERROR, "check_bin_hits_is_greater() => Unexpected bin_idx: " & to_string(i));
        end if;
      end loop;

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Checking that ignore and invalid bins were never selected during randomization");
      ------------------------------------------------------------
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_IGNORE, 2000,                   hits => 0, name => "bin_0");
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, RAN_IGNORE, (2100,2109),            hits => 0, name => "bin_1");
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_IGNORE, (2201,2203,2205,2209),  hits => 0, name => "bin_2");
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, VAL_ILLEGAL, 3000,                  hits => 0, name => "bin_3");
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, RAN_ILLEGAL, (3100,3109),           hits => 0, name => "bin_4");
      check_invalid_bin(v_coverpoint, v_invalid_bin_idx, TRN_ILLEGAL, (3201,3203,3205,3209), hits => 0, name => "bin_5");

      v_coverpoint.print_summary(VERBOSE);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing randomization weight - Adaptive");
      ------------------------------------------------------------
      disable_log_msg(ID_FUNCT_COV_RAND);

      -- The adaptive randomization weight will ensure that all bins are covered
      -- almost at the same time, i.e. around the same number of iterations.
      v_coverpoint_b.add_bins(bin(1), 100);
      v_coverpoint_b.add_bins(bin(2), 100);
      v_coverpoint_b.add_bins(bin(3), 100);
      v_coverpoint_b.add_bins(bin(4), 100);
      randomize_and_check_distribution(v_coverpoint_b, (400,400,400,400));

      v_coverpoint_b.add_bins(bin(5), 100);
      v_coverpoint_b.add_bins(bin(6), 200);
      v_coverpoint_b.add_bins(bin(7), 300);
      v_coverpoint_b.add_bins(bin(8), 400);
      randomize_and_check_distribution(v_coverpoint_b, (1000,1000,1000,1000));

      v_coverpoint_b.add_bins(bin(9), 500);
      v_coverpoint_b.add_bins(bin(10), 50);
      v_coverpoint_b.add_bins(bin(11), 50);
      randomize_and_check_distribution(v_coverpoint_b, (600,600,600));

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
      v_coverpoint_b.add_bins(bin(12), 100, 1);
      v_coverpoint_b.add_bins(bin(13), 100, 1);
      v_coverpoint_b.add_bins(bin(14), 100, 1);
      v_coverpoint_b.add_bins(bin(15), 100, 1);
      randomize_and_check_distribution(v_coverpoint_b, (400,400,400,400));

      v_coverpoint_b.add_bins(bin(16), 100, 1);   -- prob=0.10->0.16->0.33   iteration = 400
      v_coverpoint_b.add_bins(bin(17), 100, 2);   -- prob=0.20->0.33->0.66   iteration = 300 + (100 - 250*0.2-(300-250)*0.33)/0.66 = 350
      v_coverpoint_b.add_bins(bin(18), 100, 3);   -- prob=0.30->0.50         iteration = 250 + (100 - 250*0.3)/0.5 = 300
      v_coverpoint_b.add_bins(bin(19), 100, 4);   -- prob=0.40               iteration = 100/0.4 = 250
      randomize_and_check_distribution(v_coverpoint_b, (400,350,300,250));

      v_coverpoint_b.add_bins(bin(20), 100, 100); -- prob=0.50               iteration = 100/0.5 = 200
      v_coverpoint_b.add_bins(bin(21), 100, 50);  -- prob=0.25               iteration = 300
      v_coverpoint_b.add_bins(bin(22), 100, 50);  -- prob=0.25               iteration = 300
      randomize_and_check_distribution(v_coverpoint_b, (200,300,300));

      v_coverpoint_b.add_bins(bin(23), 100, 1);   -- prob=0.25               iteration = 100/0.25 = 400
      v_coverpoint_b.add_bins(bin(24), 200, 1);   -- prob=0.25->0.33         iteration = 400 + (200 - 400*0.25)/0.33 = 700
      v_coverpoint_b.add_bins(bin(25), 300, 1);   -- prob=0.25->0.33->0.50   iteration = 700 + (300 - 400*0.25-(700-400)*0.33)/0.5 = 900
      v_coverpoint_b.add_bins(bin(26), 400, 1);   -- prob=0.25->0.33->0.50   iteration = 1000
      randomize_and_check_distribution(v_coverpoint_b, (400,700,900,1000));

      v_coverpoint_b.add_bins(bin(27), 100, 1);
      v_coverpoint_b.add_bins(bin(28), 200, 2);
      v_coverpoint_b.add_bins(bin(29), 300, 3);
      v_coverpoint_b.add_bins(bin(30), 400, 4);
      randomize_and_check_distribution(v_coverpoint_b, (1000,1000,1000,1000));

      v_coverpoint_b.add_bins(bin(27), 100, 4);   -- prob=0.40               iteration = 100/0.4 = 250
      v_coverpoint_b.add_bins(bin(28), 200, 3);   -- prob=0.30->0.50         iteration = 250 + (200 - 250*0.3)/0.5 = 500
      v_coverpoint_b.add_bins(bin(29), 300, 2);   -- prob=0.20->0.33->0.66   iteration = 500 + (300 - 250*0.2-(500-250)*0.33)/0.66 = 750
      v_coverpoint_b.add_bins(bin(30), 400, 1);   -- prob=0.10->0.16->0.33   iteration = 1000
      randomize_and_check_distribution(v_coverpoint_b, (250,500,750,1000));

      v_coverpoint_b.print_summary(VERBOSE);

    --===================================================================================
    elsif GC_TESTCASE = "fc_cross" then
    --===================================================================================
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with single values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin(-100), bin(100));
      v_cross_x2.add_cross(bin(-101), bin(101));
      v_cross_x2.add_cross(bin(-102), bin(102));

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((0 => -100),(0 => 100)));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((0 => -101),(0 => 101)));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((0 => -102),(0 => 102)));

      sample_cross_bins(v_cross_x2, ((-100,100),(-101,101),(-102,102)), 1);
      sample_cross_bins(v_cross_x2, ((-100,105),(-105,101),(-105,105)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-3;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((0 => -100),(0 => 100)), hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((0 => -101),(0 => 101)), hits => 1);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((0 => -102),(0 => 102)), hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with multiple values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin((201,202)), bin((214,215)));
      v_cross_x2.add_cross(bin((222,224,226)), bin((231,233,235)));

      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((201,202),(214,215)));
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((222,224,226),(231,233,235)));

      sample_cross_bins(v_cross_x2, ((201,214),(201,215),(202,214),(202,215)), 1);
      sample_cross_bins(v_cross_x2, ((222,231),(222,233),(222,235),(224,231),(224,233),(224,235),(226,231),(226,233),(226,235)), 1);
      sample_cross_bins(v_cross_x2, ((201,213),(202,216),(223,231),(225,233),(227,235)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-2;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((201,202),(214,215)), hits => 4);
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((222,224,226),(231,233,235)), hits => 9);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with ranges of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin_range(300,307,1), bin_range(311,315,1));
      v_cross_x2.add_cross(bin_range(321,329,3), bin_range(331,335,2));

      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((300,307),(311,315)));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((321,323),(331,332)));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((321,323),(333,335)));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((324,326),(331,332)));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((324,326),(333,335)));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((327,329),(331,332)));
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((327,329),(333,335)));

      sample_cross_bins(v_cross_x2, ((300,311),(301,312),(302,313),(303,314),(304,315),(305,314),(306,313),(307,312)), 1);
      sample_cross_bins(v_cross_x2, ((321,331),(321,332),(322,331),(322,332),(323,331),(323,332)), 1);
      sample_cross_bins(v_cross_x2, ((321,333),(321,334),(321,335),(322,333),(322,334),(322,335),(323,333),(323,334),(323,335)), 1);
      sample_cross_bins(v_cross_x2, ((324,331),(324,332),(325,331),(325,332),(326,331),(326,332)), 1);
      sample_cross_bins(v_cross_x2, ((324,333),(324,334),(324,335),(325,333),(325,334),(325,335),(326,333),(326,334),(326,335)), 1);
      sample_cross_bins(v_cross_x2, ((327,331),(327,332),(328,331),(328,332),(329,331),(329,332)), 1);
      sample_cross_bins(v_cross_x2, ((327,333),(327,334),(327,335),(328,333),(328,334),(328,335),(329,333),(329,334),(329,335)), 1);
      sample_cross_bins(v_cross_x2, ((300,310),(307,316),(320,331),(330,335)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-7;
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((300,307),(311,315)), hits => 8);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((321,323),(331,332)), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((321,323),(333,335)), hits => 9);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((324,326),(331,332)), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((324,326),(333,335)), hits => 9);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((327,329),(331,332)), hits => 6);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,RAN), ((327,329),(333,335)), hits => 9);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin_transition((401,403,405)), bin_transition((416,417,418)));
      v_cross_x2.add_cross(bin_transition((421,425,429,428)), bin_transition((439,438,437,436)));

      check_cross_bin(v_cross_x2, v_bin_idx, (TRN,TRN), ((401,403,405),(416,417,418)));
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN,TRN), ((421,425,429,428),(439,438,437,436)));

      sample_cross_bins(v_cross_x2, ((401,416),(403,417),(405,418)), 3);
      sample_cross_bins(v_cross_x2, ((421,439),(425,438),(429,437),(428,436)), 3);
      sample_cross_bins(v_cross_x2, ((401,416),(403,417),(405,419)), 1);           -- Sample values outside bins
      sample_cross_bins(v_cross_x2, ((421,439),(425,438),(429,437),(429,436)), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-2;
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN,TRN), ((401,403,405),(416,417,418)), hits => 3);
      check_cross_bin(v_cross_x2, v_bin_idx, (TRN,TRN), ((421,425,429,428),(439,438,437,436)), hits => 3);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore cross with single values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin(-2001), ignore_bin(2001));
      v_cross_x2.add_cross(ignore_bin(-2002), ignore_bin(2002));
      v_cross_x2.add_cross(ignore_bin(-2003), ignore_bin(2003));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,VAL_IGNORE), ((0 => -2001),(0 => 2001)));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,VAL_IGNORE), ((0 => -2002),(0 => 2002)));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,VAL_IGNORE), ((0 => -2003),(0 => 2003)));

      sample_cross_bins(v_cross_x2, ((-2001,2001),(-2002,2002),(-2003,2003)), 1);
      sample_cross_bins(v_cross_x2, ((-2001,2005),(-2005,2002),(-2005,2005)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-3;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,VAL_IGNORE), ((0 => -2001),(0 => 2001)), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,VAL_IGNORE), ((0 => -2002),(0 => 2002)), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,VAL_IGNORE), ((0 => -2003),(0 => 2003)), hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore cross with ranges of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin_range(2100,2107), ignore_bin_range(2115,2119));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE,RAN_IGNORE), ((2100,2107),(2115,2119)));

      sample_cross_bins(v_cross_x2, ((2100,2115),(2101,2116),(2102,2117),(2103,2118),(2104,2119),(2105,2118),(2106,2117),(2107,2116)), 1);
      sample_cross_bins(v_cross_x2, ((2100,2114),(2107,2120),(2108,2115),(2109,2119)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-1;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_IGNORE,RAN_IGNORE), ((2100,2107),(2115,2119)), hits => 8);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing ignore cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(ignore_bin_transition((2201,2203,2205,2207)), ignore_bin_transition((2212,2214,2216,2218)));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE,TRN_IGNORE), ((2201,2203,2205,2207),(2212,2214,2216,2218)));

      sample_cross_bins(v_cross_x2, ((2201,2212),(2203,2214),(2205,2216),(2207,2218)), 3);
      sample_cross_bins(v_cross_x2, ((2201,2212),(2203,2214),(2205,2216),(2207,2219)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-1;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE,TRN_IGNORE), ((2201,2203,2205,2207),(2212,2214,2216,2218)), hits => 3);

      v_cross_x2.set_illegal_bin_alert_level(WARNING);
      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal cross with single values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(illegal_bin(-3001), illegal_bin(3001));
      v_cross_x2.add_cross(illegal_bin(-3002), illegal_bin(3002));
      v_cross_x2.add_cross(illegal_bin(-3003), illegal_bin(3003));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,VAL_ILLEGAL), ((0 => -3001),(0 => 3001)));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,VAL_ILLEGAL), ((0 => -3002),(0 => 3002)));
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,VAL_ILLEGAL), ((0 => -3003),(0 => 3003)));

      increment_expected_alerts(WARNING,3);
      sample_cross_bins(v_cross_x2, ((-3001,3001),(-3002,3002),(-3003,3003)), 1);
      sample_cross_bins(v_cross_x2, ((-3001,3005),(-3005,3002),(-3005,3005)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-3;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,VAL_ILLEGAL), ((0 => -3001),(0 => 3001)), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,VAL_ILLEGAL), ((0 => -3002),(0 => 3002)), hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,VAL_ILLEGAL), ((0 => -3003),(0 => 3003)), hits => 1);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal cross with ranges of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(illegal_bin_range(3100,3107), illegal_bin_range(3115,3119));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_ILLEGAL,RAN_ILLEGAL), ((3100,3107),(3115,3119)));

      increment_expected_alerts(WARNING,8);
      sample_cross_bins(v_cross_x2, ((3100,3115),(3101,3116),(3102,3117),(3103,3118),(3104,3119),(3105,3118),(3106,3117),(3107,3116)), 1);
      sample_cross_bins(v_cross_x2, ((3100,3114),(3107,3120),(3108,3115),(3109,3119)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-1;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (RAN_ILLEGAL,RAN_ILLEGAL), ((3100,3107),(3115,3119)), hits => 8);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing illegal cross with transitions of values");
      ------------------------------------------------------------
      v_cross_x2.add_cross(illegal_bin_transition((3201,3203,3205,3207)), illegal_bin_transition((3212,3214,3216,3218)));

      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL,TRN_ILLEGAL), ((3201,3203,3205,3207),(3212,3214,3216,3218)));

      increment_expected_alerts(WARNING,3);
      sample_cross_bins(v_cross_x2, ((3201,3212),(3203,3214),(3205,3216),(3207,3218)), 3);
      sample_cross_bins(v_cross_x2, ((3201,3212),(3203,3214),(3205,3216),(3207,3219)), 1); -- Sample values outside bins

      v_invalid_bin_idx := v_invalid_bin_idx-1;
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL,TRN_ILLEGAL), ((3201,3203,3205,3207),(3212,3214,3216,3218)), hits => 3);

      ------------------------------------------------------------
      log(ID_LOG_HDR, "Testing cross with different bins");
      ------------------------------------------------------------
      v_cross_x2.add_cross(bin(4000), bin((4010,4015,4019)), "cross_0");
      v_cross_x2.add_cross(bin_range(4100,4107,1), bin_transition((4111,4112,4115)), "cross_1");
      v_cross_x2.add_cross(ignore_bin(4201), ignore_bin_range(4212,4215), "cross_2");
      v_cross_x2.add_cross(ignore_bin_transition((4302,4304,4306)), ignore_bin(4315), "cross_3");
      v_cross_x2.add_cross(illegal_bin(4402), illegal_bin_range(4415,4417), "cross_4");
      v_cross_x2.add_cross(illegal_bin_transition((4505,4506)), illegal_bin(4516), "cross_5");
      v_cross_x2.add_cross(bin((4601,4609)), ignore_bin_range(4611,4613), "cross_6");
      v_cross_x2.add_cross(ignore_bin_transition((4701,4702,4703,4704)), bin((4715,4716)), "cross_7");
      v_cross_x2.add_cross(bin(4803), illegal_bin_range(4817,4819), "cross_8");
      v_cross_x2.add_cross(illegal_bin_transition((4901,4902,4903)), bin(4917), "cross_9");

      -- Since all unconstrained vectors in an aggregate type need to have the same length, we use C_NULL to fill the vectors
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((4000,C_NULL,C_NULL),(4010,4015,4019)),                                  name => "cross_0");
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,TRN), ((4100,4107,C_NULL),(4111,4112,4115)),                                    name => "cross_1");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,RAN_IGNORE), ((4201,C_NULL),(4212,4215)),                name => "cross_2");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE,VAL_IGNORE), ((4302,4304,4306),(4315,C_NULL,C_NULL)),    name => "cross_3");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,RAN_ILLEGAL), ((4402,C_NULL),(4415,4417)),              name => "cross_4");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL,VAL_ILLEGAL), ((4505,4506),(4516,C_NULL)),              name => "cross_5");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL,RAN_IGNORE), ((4601,4609),(4611,4613)),                         name => "cross_6");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE,VAL), ((4701,4702,4703,4704),(4715,4716,C_NULL,C_NULL)), name => "cross_7");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL,RAN_ILLEGAL), ((4803,C_NULL),(4817,4819)),                      name => "cross_8");
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL,VAL), ((4901,4902,4903),(4917,C_NULL,C_NULL)),          name => "cross_9");

      sample_cross_bins(v_cross_x2, ((4000,4010),(4000,4015),(4000,4019)), 1);
      sample_cross_bins(v_cross_x2, ((4100,4111),(4101,4112),(4102,4115),(4103,4111),(4104,4112),(4105,4115)), 1);
      sample_cross_bins(v_cross_x2, ((4201,4212),(4201,4213),(4201,4214),(4201,4215)), 1);
      sample_cross_bins(v_cross_x2, ((4302,4315),(4304,4315),(4306,4315)), 1);
      increment_expected_alerts(WARNING,3);
      sample_cross_bins(v_cross_x2, ((4402,4415),(4402,4416),(4402,4417)), 1);
      increment_expected_alerts(WARNING,2);
      sample_cross_bins(v_cross_x2, ((4505,4516),(4506,4516)), 1);
      sample_cross_bins(v_cross_x2, ((4601,4611),(4601,4612),(4601,4613),(4609,4611),(4609,4612),(4609,4613)), 1);
      sample_cross_bins(v_cross_x2, ((4701,4715),(4702,4715),(4703,4715),(4704,4715),(4701,4716),(4702,4716),(4703,4716),(4704,4716)), 1);
      increment_expected_alerts(WARNING,3);
      sample_cross_bins(v_cross_x2, ((4803,4817),(4803,4818),(4803,4819)), 1);
      sample_cross_bins(v_cross_x2, ((4901,4917),(4902,4917),(4903,4917)), 1);

      v_bin_idx := v_bin_idx-2;
      v_invalid_bin_idx := v_invalid_bin_idx-8;
      check_cross_bin(v_cross_x2, v_bin_idx, (VAL,VAL), ((4000,C_NULL,C_NULL),(4010,4015,4019)),                                  name => "cross_0", hits => 3);
      check_cross_bin(v_cross_x2, v_bin_idx, (RAN,TRN), ((4100,4107,C_NULL),(4111,4112,4115)),                                    name => "cross_1", hits => 2);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_IGNORE,RAN_IGNORE), ((4201,C_NULL),(4212,4215)),                name => "cross_2", hits => 4);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE,VAL_IGNORE), ((4302,4304,4306),(4315,C_NULL,C_NULL)),    name => "cross_3", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL_ILLEGAL,RAN_ILLEGAL), ((4402,C_NULL),(4415,4417)),              name => "cross_4", hits => 3);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL,VAL_ILLEGAL), ((4505,4506),(4516,C_NULL)),              name => "cross_5", hits => 1);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL,RAN_IGNORE), ((4601,4609),(4611,4613)),                         name => "cross_6", hits => 6);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_IGNORE,VAL), ((4701,4702,4703,4704),(4715,4716,C_NULL,C_NULL)), name => "cross_7", hits => 2);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (VAL,RAN_ILLEGAL), ((4803,C_NULL),(4817,4819)),                      name => "cross_8", hits => 3);
      check_invalid_cross_bin(v_cross_x2, v_invalid_bin_idx, (TRN_ILLEGAL,VAL), ((4901,4902,4903),(4917,C_NULL,C_NULL)),          name => "cross_9", hits => 1);

      check_num_bins(v_cross_x2, v_bin_idx, v_invalid_bin_idx);
      check_coverage(v_cross_x2, 100.0);
      v_cross_x2.print_summary(VERBOSE);

    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- Allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED");
    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end architecture func;