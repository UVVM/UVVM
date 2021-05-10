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

  shared variable v_coverpoint : t_coverpoint;

  constant C_ADAPTIVE_WEIGHT : integer := -1;

begin

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_bin_idx          : natural := 0;
    variable v_invalid_bin_idx  : natural := 0;
    variable v_vector           : std_logic_vector(1 downto 0);

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
      variable v_bin       : t_cov_bin;
    begin
      if contains = VAL or contains = RAN or contains = TRN then
        v_bin := coverpoint.get_valid_bin(bin_idx);
      else
        v_bin := coverpoint.get_invalid_bin(bin_idx);
      end if;
      check_value(v_bin.cross_bins(0).contains = contains,       ERROR, "Checking bin type. Was: " & to_upper(to_string(v_bin.cross_bins(0).contains)) &
        ". Expected: " & to_upper(to_string(contains)), C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      for i in 0 to values'length-1 loop
        check_value(v_bin.cross_bins(0).values(i), values(i),    ERROR, "Checking bin values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      end loop;
      check_value(v_bin.cross_bins(0).num_values, values'length, ERROR, "Checking bin number of values", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      check_value(v_bin.cross_bins(0).transition_idx, 0,         ERROR, "Checking bin transition index", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      check_value(v_bin.min_hits, min_hits,                      ERROR, "Checking bin minimum hits", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      check_value(v_bin.rand_weight, rand_weight,                ERROR, "Checking bin randomization weight", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      check_value(to_string(v_bin.name), name,                   ERROR, "Checking bin name", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      check_value(v_bin.hits, hits,                              ERROR, "Checking bin hits", C_TB_SCOPE_DEFAULT, ID_NEVER, caller_name => C_PROC_NAME);
      bin_idx := bin_idx + 1;
      log(ID_POS_ACK, C_PROC_NAME & " => OK, for " & to_upper(to_string(contains)) & ":" & to_string(values));
    end procedure;

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

    procedure check_invalid_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type;
      constant values      : in    integer_vector;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
    begin
      check_bin(coverpoint, bin_idx, contains, values, 0, 0, name, hits);
    end procedure;

    procedure check_invalid_bin(
      variable coverpoint  : inout t_coverpoint;
      variable bin_idx     : inout natural;
      constant contains    : in    t_cov_bin_type;
      constant value       : in    integer;
      constant name        : in    string  := "";
      constant hits        : in    natural := 0) is
    begin
      check_bin(coverpoint, bin_idx, contains, (0 => value), 0, 0, name, hits);
    end procedure;

    procedure check_num_bins(
      variable coverpoint       : inout t_coverpoint;
      constant num_valid_bins   : in    natural;
      constant num_invalid_bins : in    natural) is
      constant C_PROC_NAME : string := "check_num_bins";
    begin
      check_value(coverpoint.get_num_valid_bins(VOID), num_valid_bins, ERROR, "Checking number of valid bins", C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
      check_value(coverpoint.get_num_invalid_bins(VOID), num_invalid_bins, ERROR, "Checking number of invalid bins", C_TB_SCOPE_DEFAULT, caller_name => C_PROC_NAME);
    end procedure;

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

    procedure sample_bins(
      variable coverpoint  : inout t_coverpoint;
      constant value       : in    integer;
      constant num_samples : in    positive := 1) is
    begin
      sample_bins(coverpoint, (0 => value), num_samples);
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
    if GC_TESTCASE = "basic" then
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
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(bin((210,211,212,213,214,215,216,217,218,219,220))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_bin(v_coverpoint, v_bin_idx, VAL, (202,204,206,208));
      check_bin(v_coverpoint, v_bin_idx, VAL, (210,211,212,213,214,215,216,217,218,219));

      sample_bins(v_coverpoint, (202,204,206,208), 1);
      sample_bins(v_coverpoint, (210,211,212,213,214,215,216,217,218,219), 1);
      sample_bins(v_coverpoint, (201,203,205,207,209,220), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-2;
      check_bin(v_coverpoint, v_bin_idx, VAL, (202,204,206,208), hits => 4);
      check_bin(v_coverpoint, v_bin_idx, VAL, (210,211,212,213,214,215,216,217,218,219), hits => 10);

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
      increment_expected_alerts(TB_WARNING,1);
      v_coverpoint.add_bins(bin_transition((420,421,422,423,424,425,426,427,428,429,430))); -- C_FC_MAX_NUM_BIN_VALUES = 10

      check_bin(v_coverpoint, v_bin_idx, TRN, (401,403,405,409));
      check_bin(v_coverpoint, v_bin_idx, TRN, (410,410,410,418,415,415,410));
      check_bin(v_coverpoint, v_bin_idx, TRN, (420,421,422,423,424,425,426,427,428,429));

      sample_bins(v_coverpoint, (401,403,405,409), 3);
      sample_bins(v_coverpoint, (410,410,410,418,415,415,410), 3);
      sample_bins(v_coverpoint, (420,421,422,423,424,425,426,427,428,429), 3);
      sample_bins(v_coverpoint, (401,403,405,408), 1);                         -- Sample values outside bins
      sample_bins(v_coverpoint, (410,410,410,418,415,414,410), 1);             -- Sample values outside bins
      sample_bins(v_coverpoint, (420,421,422,423,424,425,426,427,428,430), 1); -- Sample values outside bins

      v_bin_idx := v_bin_idx-3;
      check_bin(v_coverpoint, v_bin_idx, TRN, (401,403,405,409), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, TRN, (410,410,410,418,415,415,410), hits => 3);
      check_bin(v_coverpoint, v_bin_idx, TRN, (420,421,422,423,424,425,426,427,428,429), hits => 3);

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
      check_value(v_coverpoint.get_coverage(VOID), 100.0, ERROR, "Checking coverage", C_TB_SCOPE_DEFAULT);
      v_coverpoint.print_summary(VOID);

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