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

architecture common_arch of methods_tb is
  constant C_RANDOM_MIN_VALUE : integer := 10;
  constant C_RANDOM_MAX_VALUE : integer := 13;
  type t_int_array is array (C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE) of integer;
  signal counter : t_int_array                  := (others => 0); -- For counting results of random functions
  signal slv8    : std_logic_vector(7 downto 0) := (others => '0');
begin

  p_main : process
    variable v_seed1             : positive := 1;
    variable v_seed2             : positive := 1;
    variable v_int               : integer;
    variable v_real              : real;
    variable v_time              : time;
    variable v_sl                : std_logic;
    variable v_slv5_a            : std_logic_vector(4 downto 0);
    variable v_slv5_b            : std_logic_vector(4 downto 0);
    variable v_slv8              : std_logic_vector(7 downto 0);
    variable v_uns5_a            : unsigned(4 downto 0);
    variable v_uns5_b            : unsigned(4 downto 0);
    variable v_uns8              : unsigned(7 downto 0);
    variable v_sig5_a            : signed(4 downto 0);
    variable v_sig5_b            : signed(4 downto 0);
    variable v_sig8              : signed(7 downto 0);
    variable v_sig32             : signed(31 downto 0);
    variable v_sig33             : signed(32 downto 0);
    variable v_slv_array         : t_slv_array(2 downto 0)(3 downto 0);
    variable v_slv_array_32      : t_slv_array(31 downto 0)(7 downto 0);
    variable v_slv32_array       : t_slv_array(1 to 2)(31 downto 0);
    variable v_slv256_array      : t_slv_array(1 downto 0)(255 downto 0);
    variable v_unsigned_array    : t_unsigned_array(2 downto 0)(3 downto 0);
    variable v_unsigned_array_32 : t_unsigned_array(31 downto 0)(7 downto 0);
    variable v_unsigned32_array  : t_unsigned_array(1 to 2)(31 downto 0);
    variable v_unsigned256_array : t_unsigned_array(1 downto 0)(255 downto 0);
    variable v_signed_array      : t_signed_array(2 downto 0)(3 downto 0);
    variable v_signed_array_32   : t_signed_array(31 downto 0)(7 downto 0);
    variable v_signed33_array    : t_signed_array(1 to 2)(32 downto 0);
    variable v_signed256_array   : t_signed_array(1 downto 0)(255 downto 0);
    variable v_string            : string(1 to 10);
    -- TC: byte_and_slv_arrays
    variable v_idx                    : natural;
    variable v_byte                   : std_logic_vector(7 downto 0);
    variable v_byte_array             : t_byte_array(0 to 9);
    variable v_slv_array_as_byte      : t_slv_array(0 to 9)(7 downto 0);
    variable v_slv_array_as_3_byte    : t_slv_array(0 to 9)(23 downto 0);
    variable v_byte_desc_array        : t_byte_array(9 downto 0);
    variable v_slv_desc_array_as_byte : t_slv_array(9 downto 0)(7 downto 0);
    variable v_slv                    : std_logic_vector(8 * v_byte_array'length - 1 downto 0);
    variable v_slv_not_byte_multiple  : std_logic_vector(8 * v_byte_array'length - 5 downto 0);

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "random_functions" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Verifying basic random functions", C_SCOPE);
      randomize(12, 14);
      randomize(14, 12);

      ----------------------------------------------------------------
      log(ID_LOG_HDR, "std_logic_vector / std_logic", C_SCOPE);
      ----------------------------------------------------------------
      log(ID_SEQUENCER, "-- Test the random SLV function (not self checking)", C_SCOPE);
      for i in 1 to 5 loop
        v_slv8 := random(v_slv8'length);
        log(ID_SEQUENCER, "Random function slv8 = " & to_string(v_slv8), C_SCOPE);
      end loop;

      log(ID_SEQUENCER, "-- Test the random SLV procedure (not self checking)", C_SCOPE);
      for i in 1 to 5 loop
        random(v_seed1, v_seed2, v_slv8);
        log(ID_SEQUENCER, "Random procedure slv8 = " & to_string(v_slv8), C_SCOPE);
      end loop;

      log(ID_SEQUENCER, "-- Test the random SL function (not self checking)", C_SCOPE);
      for i in 1 to 10 loop
        v_sl := random(VOID);
        log(ID_SEQUENCER, "Random function sl = " & to_string(v_sl), C_SCOPE);
      end loop;

      log(ID_SEQUENCER, "-- Test the random SL procedure (not self checking)", C_SCOPE);
      for i in 1 to 10 loop
        random(v_seed1, v_seed2, v_sl);
        log(ID_SEQUENCER, "Random procedure sl = " & to_string(v_sl), C_SCOPE);
      end loop;

      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Integer", C_SCOPE);
      ----------------------------------------------------------------
      log(ID_SEQUENCER, "-- Test the random integer function", C_SCOPE);
      for i in 1 to 100 loop
        v_int      := random(C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE);
        -- Check that the number is in the requested range
        check_value_in_range(v_int, C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE, error, "Random integer function in range, OK", C_SCOPE, ID_NEVER);
        counter(v_int) <= counter(v_int) + 1;     -- Keep track of how many times the random value got this value
        wait for 0 ns;
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "integer function: counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

      log(ID_SEQUENCER, "-- Test the random integer procedure", C_SCOPE);
      for i in 1 to 100 loop
        random(C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE, v_seed1, v_seed2, v_int);
        check_value_in_range(v_int, C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE, error, "Random integer procedure in range, OK", C_SCOPE, ID_NEVER);
        counter(v_int) <= counter(v_int) + 1;       -- Keep track of how many times the random value got this value
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "integer procedure: counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

      log(ID_SEQUENCER, "-- Test the max limit", C_SCOPE);
      for i in 1 to 10 loop
        random(0, integer'right, v_seed1, v_seed2, v_int);
        check_value_in_range(v_int, 0, integer'right, error, "Random integer function in range, OK", C_SCOPE, ID_NEVER);
      end loop;

      log(ID_SEQUENCER, "-- Test the min & max limits (not self checking)", C_SCOPE);
      for i in 1 to 10 loop
        random(integer'left, integer'right, v_seed1, v_seed2, v_int);
        log(ID_SEQUENCER, "Random int procedure = " & to_string(v_int), C_SCOPE);
      end loop;

      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Real", C_SCOPE);
      ----------------------------------------------------------------
      log(ID_SEQUENCER, "-- Test the random real function", C_SCOPE);
      for i in 1 to 5 loop
        v_real := random(0.01, 0.03);
        log(ID_SEQUENCER, "Random real function = " & to_string(v_real, "%f"), C_SCOPE);
        check_value_in_range(v_real, 0.01, 0.03, error, "Random real function in range, OK", C_SCOPE, ID_NEVER);
      end loop;

      log(ID_SEQUENCER, "-- Test the random real procedure", C_SCOPE);
      for i in 1 to 5 loop
        random(0.01, 0.03, v_seed1, v_seed2, v_real);
        log(ID_SEQUENCER, "Random real procedure = " & to_string(v_real, "%f"), C_SCOPE);
        check_value_in_range(v_real, 0.01, 0.03, error, "Random real procedure in range, OK", C_SCOPE, ID_NEVER);
      end loop;

      ----------------------------------------------------------------
      log(ID_LOG_HDR, "Time", C_SCOPE);
      ----------------------------------------------------------------
      log(ID_SEQUENCER, "-- Test the random time function", C_SCOPE);
      for i in 1 to 100 loop
        v_time             := random(1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE);
        -- Check that the number is in the requested range
        check_value_in_range(v_time, 1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE, error, "Random time function in range, OK", C_SCOPE, ID_NEVER);
        counter(v_time / 1 ns) <= counter(v_time / 1 ns) + 1; -- Keep track of how many times the random value got this value
        wait for 0 ns;
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time function (ns) : counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

      log(ID_SEQUENCER, "-- Test the random time function with default time resolution", C_SCOPE);
      for i in 1 to 100 loop
        v_time             := random(1 ms * C_RANDOM_MIN_VALUE, 1 ms * C_RANDOM_MAX_VALUE);
        -- Check that the number is in the requested range
        check_value_in_range(v_time, 1 ms * C_RANDOM_MIN_VALUE, 1 ms * C_RANDOM_MAX_VALUE, error, "Random time function in range, OK", C_SCOPE, ID_NEVER);
        counter(v_time / 1 ms) <= counter(v_time / 1 ms) + 1; -- Keep track of how many times the random value got this value
        wait for 0 ns;
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time function (ms) : counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

      log(ID_SEQUENCER, "-- Test the random time function with explicit time resolution", C_SCOPE);
      increment_expected_alerts(TB_WARNING, 1);
      for i in 1 to 100 loop
        v_time             := random(1 ms * C_RANDOM_MIN_VALUE, 1 ms * C_RANDOM_MAX_VALUE, ps);
        -- Check that the number is in the requested range
        check_value_in_range(v_time, 1 ms * C_RANDOM_MIN_VALUE, 1 ms * C_RANDOM_MAX_VALUE, error, "Random time function in range, OK", C_SCOPE, ID_NEVER);
        counter(v_time / 1 ms) <= counter(v_time / 1 ms) + 1; -- Keep track of how many times the random value got this value
        wait for 0 ns;
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time function (ms) : counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;
      shared_warned_rand_time_res := false; -- Reset to test warning in procedure call

      log(ID_SEQUENCER, "-- Test the random time procedure", C_SCOPE);
      for i in 1 to 100 loop
        random(1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE, v_seed1, v_seed2, v_time);
        check_value_in_range(v_time, 1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE, error, "Random time procedure in range, OK", C_SCOPE, ID_NEVER);
        counter(v_time / 1 ns) <= counter(v_time / 1 ns) + 1; -- Keep track of how many times the random value got this value
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time procedure (ns) : counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

      log(ID_SEQUENCER, "-- Test the random time procedure with default time resolution", C_SCOPE);
      for i in 1 to 100 loop
        random(1 ms * C_RANDOM_MIN_VALUE, 1 ms * C_RANDOM_MAX_VALUE, v_seed1, v_seed2, v_time);
        check_value_in_range(v_time, 1 ms * C_RANDOM_MIN_VALUE, 1 ms * C_RANDOM_MAX_VALUE, error, "Random time procedure in range, OK", C_SCOPE, ID_NEVER);
        counter(v_time / 1 ms) <= counter(v_time / 1 ms) + 1; -- Keep track of how many times the random value got this value
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time procedure (ms) : counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

      log(ID_SEQUENCER, "-- Test the random time procedure with explicit time resolution", C_SCOPE);
      increment_expected_alerts(TB_WARNING, 1);
      for i in 1 to 100 loop
        random(1 sec * C_RANDOM_MIN_VALUE, 1 sec * C_RANDOM_MAX_VALUE, ps, v_seed1, v_seed2, v_time);
        check_value_in_range(v_time, 1 sec * C_RANDOM_MIN_VALUE, 1 sec * C_RANDOM_MAX_VALUE, error, "Random time procedure in range, OK", C_SCOPE, ID_NEVER);
        counter(v_time / 1 sec) <= counter(v_time / 1 sec) + 1; -- Keep track of how many times the random value got this value
      end loop;
      -- Print statistics over the random values
      for i in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time procedure (sec) : counter(" & to_string(i, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(counter(i), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        counter(i) <= 0;
      end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "normalise" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying normalise", C_SCOPE);

      log("\rCheck normalise for slv");
      -- slv: No errors expected
      v_slv8   := x"00";
      v_slv5_a := "10101";
      v_slv5_b := "01010";
      v_slv8   := normalise(v_slv5_a, v_slv8, ALLOW_NARROWER, "v_slv5_a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5_a, error, "", C_SCOPE);
      v_slv8   := x"00";
      v_slv8   := normalise(v_slv5_a, v_slv8, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5_a, error, "", C_SCOPE);
      v_slv5_b := "00000";
      v_slv8   := "00010101";
      v_slv5_b := normalise(v_slv8, v_slv5_a, ALLOW_WIDER, "v_slv5_a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5_b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5_b := "00000";
      v_slv5_b := normalise(v_slv8, v_slv5_a, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5_b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5_b := normalise(v_slv5_a, v_slv5_b, ALLOW_EXACT_ONLY, "v_slv5_a", "v_slv5_b", "");
      check_value(v_slv5_a, v_slv5_b, error, "", C_SCOPE);
      v_slv5_b := normalise(v_slv5_a, v_slv5_b, ALLOW_NARROWER, "v_slv5_a", "v_slv5_b", "");
      v_slv5_b := normalise(v_slv5_a, v_slv5_b, ALLOW_WIDER, "v_slv5_a", "v_slv5_b", "");
      v_slv5_b := normalise(v_slv5_a, v_slv5_b, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv5_b", "");

      -- slv: Provoking errors
      v_slv8                := x"00";
      v_slv5_a              := "10101";
      v_slv5_b              := "01010";
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv8                := normalise(v_slv5_a, v_slv8, ALLOW_WIDER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv8                := normalise(v_slv5_a, v_slv8, ALLOW_EXACT_ONLY, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR) ;
      v_slv5_b              := normalise(v_slv8, v_slv5_a, ALLOW_NARROWER, "v_slv8", "v_slv5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR) ;
      v_slv5_b              := normalise(v_slv8, v_slv5_a, ALLOW_EXACT_ONLY, "v_slv8", "v_slv5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv8                := x"55";
      v_slv5_b              := normalise(v_slv8, v_slv5_a, ALLOW_WIDER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b              := "00000";
      v_slv5_b              := normalise(v_slv8, v_slv5_a, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b              := normalise(v_slv8(-1 downto 0), v_slv5_a, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR) ;
      v_slv5_b(-1 downto 0) := normalise(v_slv8, v_slv5_a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");

      log("\rCheck normalise for unsigned");
      -- unsigned: No errors expected
      v_uns8   := x"00";
      v_uns5_a := "10101";
      v_uns5_b := "01010";
      v_uns8   := normalise(v_uns5_a, v_uns8, ALLOW_NARROWER, "v_uns5_a", "v_uns8", "");
      check_value(v_uns8, "000" & v_uns5_a, error, "", C_SCOPE);
      v_uns8   := x"00";
      v_uns8   := normalise(v_uns5_a, v_uns8, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      check_value(v_uns8, "000" & v_uns5_a, error, "", C_SCOPE);
      v_uns5_b := "00000";
      v_uns8   := "00010101";
      v_uns5_b := normalise(v_uns8, v_uns5_a, ALLOW_WIDER, "v_uns5_a", "v_uns8", "");
      check_value(to_integer(v_uns5_b), to_integer(v_uns8), error, "", C_SCOPE);
      v_uns5_b := "00000";
      v_uns5_b := normalise(v_uns8, v_uns5_a, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      check_value(to_integer(v_uns5_b), to_integer(v_uns8), error, "", C_SCOPE);
      v_uns5_b := normalise(v_uns5_a, v_uns5_b, ALLOW_EXACT_ONLY, "v_uns5_a", "v_uns5_b", "");
      check_value(v_uns5_a, v_uns5_b, error, "", C_SCOPE);
      v_uns5_b := normalise(v_uns5_a, v_uns5_b, ALLOW_NARROWER, "v_uns5_a", "v_uns5_b", "");
      v_uns5_b := normalise(v_uns5_a, v_uns5_b, ALLOW_WIDER, "v_uns5_a", "v_uns5_b", "");
      v_uns5_b := normalise(v_uns5_a, v_uns5_b, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns5_b", "");

      -- unsigned: Provoking errors
      v_uns8                := x"00";
      v_uns5_a              := "10101";
      v_uns5_b              := "01010";
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns8                := normalise(v_uns5_a, v_uns8, ALLOW_WIDER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns8                := normalise(v_uns5_a, v_uns8, ALLOW_EXACT_ONLY, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := normalise(v_uns8, v_uns5_a, ALLOW_NARROWER, "v_uns8", "v_uns5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := normalise(v_uns8, v_uns5_a, ALLOW_EXACT_ONLY, "v_uns8", "v_uns5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns8                := x"55";
      v_uns5_b              := normalise(v_uns8, v_uns5_a, ALLOW_WIDER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := "00000";
      v_uns5_b              := normalise(v_uns8, v_uns5_a, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := normalise(v_uns8(-1 downto 0), v_uns5_a, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b(-1 downto 0) := normalise(v_uns8, v_uns5_a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");

      log("\rCheck normalise for signed");
      -- signed: No errors expected
      v_sig8   := x"00";
      v_sig5_a := "10101";
      v_sig5_b := "01010";
      v_sig8   := normalise(v_sig5_a, v_sig8, ALLOW_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig8   := x"00";
      v_sig8   := normalise(v_sig5_a, v_sig8, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig8   := "00010101";
      v_sig5_b := normalise(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig5_b, v_sig8, error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig5_b := normalise(v_sig8, v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig5_b, v_sig8, error, "", C_SCOPE);
      v_sig8   := x"00";
      v_sig5_a := "01010";
      v_sig5_b := "10101";
      v_sig8   := normalise(v_sig5_a, v_sig8, ALLOW_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig8   := x"00";
      v_sig8   := normalise(v_sig5_a, v_sig8, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig8   := "11110101";
      v_sig5_b := normalise(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      check_value(to_integer(v_sig5_b), to_integer(v_sig8), error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig5_b := normalise(v_sig8, v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(to_integer(v_sig5_b), to_integer(v_sig8), error, "", C_SCOPE);
      v_sig5_b := normalise(v_sig5_a, v_sig5_b, ALLOW_EXACT_ONLY, "v_sig5_a", "v_sig5_b", "");
      v_sig5_b := normalise(v_sig5_a, v_sig5_b, ALLOW_NARROWER, "v_sig5_a", "v_sig5_b", "");
      v_sig5_b := normalise(v_sig5_a, v_sig5_b, ALLOW_WIDER, "v_sig5_a", "v_sig5_b", "");
      v_sig5_b := normalise(v_sig5_a, v_sig5_b, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig5_b", "");

      -- signed: Provoking errors
      v_sig8                := x"00";
      v_sig5_a              := "10101";
      v_sig5_b              := "01010";
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := normalise(v_sig5_a, v_sig8, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := normalise(v_sig5_a, v_sig8, ALLOW_EXACT_ONLY, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := normalise(v_sig8, v_sig5_a, ALLOW_NARROWER, "v_sig8", "v_sig5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := normalise(v_sig8, v_sig5_a, ALLOW_EXACT_ONLY, "v_sig8", "v_sig5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := x"55";
      v_sig5_b              := normalise(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := "00000";
      v_sig5_b              := normalise(v_sig8, v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := "10110101";
      v_sig5_b              := normalise(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := normalise(v_sig8(-1 downto 0), v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b(-1 downto 0) := normalise(v_sig8, v_sig5_a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");

      log("\rCheck normalise and check_value for t_slv_array");
      v_slv_array_32 := (others => (others => '0'));
      v_slv_array(0) := "1001";
      v_slv_array(1) := "0110";
      v_slv_array(2) := "1010";
      v_slv_array_32 := normalise(v_slv_array, v_slv_array_32, ALLOW_NARROWER, "v_slv_array", "v_slv_array_32", "");
      check_value(v_slv_array_32(2 downto 0), v_slv_array, error, "", C_SCOPE);

      log("\rCheck normalise and check_value for t_signed_array");
      v_signed_array_32 := (others => (others => '0'));
      v_signed_array(0) := "1001";
      v_signed_array(1) := "0110";
      v_signed_array(2) := "1010";
      v_signed_array_32 := normalise(v_signed_array, v_signed_array_32, ALLOW_NARROWER, "v_signed_array", "v_signed_array_32", "");
      for idx in 0 to v_slv_array'length - 1 loop
        check_value(to_integer(unsigned(v_slv_array_32(idx))), to_integer(unsigned(v_slv_array(idx))), error, "", C_SCOPE);
      end loop;

      log("\rCheck normalise and check_value for t_unsigned_array");
      v_unsigned_array_32 := (others => (others => '0'));
      v_unsigned_array(0) := "1001";
      v_unsigned_array(1) := "0110";
      v_unsigned_array(2) := "1010";
      v_unsigned_array_32 := normalise(v_unsigned_array, v_unsigned_array_32, ALLOW_NARROWER, "v_unsigned_array", "v_unsigned_array_32", "");
      check_value(v_unsigned_array_32(2 downto 0), v_unsigned_array, error, "", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "normalize_and_check" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying normalize_and_check", C_SCOPE);

      log("\rCheck normalize_and_check for slv");
      -- slv: No errors expected
      v_slv8   := x"00";
      v_slv5_a := "10101";
      v_slv5_b := "01010";
      v_slv8   := normalize_and_check(v_slv5_a, v_slv8, ALLOW_NARROWER, "v_slv5_a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5_a, error, "", C_SCOPE);
      v_slv8   := x"00";
      v_slv8   := normalize_and_check(v_slv5_a, v_slv8, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5_a, error, "", C_SCOPE);
      v_slv5_b := "00000";
      v_slv8   := "00010101";
      v_slv5_b := normalize_and_check(v_slv8, v_slv5_a, ALLOW_WIDER, "v_slv5_a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5_b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5_b := "00000";
      v_slv5_b := normalize_and_check(v_slv8, v_slv5_a, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5_b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5_b := normalize_and_check(v_slv5_a, v_slv5_b, ALLOW_EXACT_ONLY, "v_slv5_a", "v_slv5_b", "");
      check_value(v_slv5_a, v_slv5_b, error, "", C_SCOPE);
      v_slv5_b := normalize_and_check(v_slv5_a, v_slv5_b, ALLOW_NARROWER, "v_slv5_a", "v_slv5_b", "");
      v_slv5_b := normalize_and_check(v_slv5_a, v_slv5_b, ALLOW_WIDER, "v_slv5_a", "v_slv5_b", "");
      v_slv5_b := normalize_and_check(v_slv5_a, v_slv5_b, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv5_b", "");

      -- slv: Provoking errors
      v_slv8                := x"00";
      v_slv5_a              := "10101";
      v_slv5_b              := "01010";
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv8                := normalize_and_check(v_slv5_a, v_slv8, ALLOW_WIDER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv8                := normalize_and_check(v_slv5_a, v_slv8, ALLOW_EXACT_ONLY, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b              := normalize_and_check(v_slv8, v_slv5_a, ALLOW_NARROWER, "v_slv8", "v_slv5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b              := normalize_and_check(v_slv8, v_slv5_a, ALLOW_EXACT_ONLY, "v_slv8", "v_slv5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv8                := x"55";
      v_slv5_b              := normalize_and_check(v_slv8, v_slv5_a, ALLOW_WIDER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b              := "00000";
      v_slv5_b              := normalize_and_check(v_slv8, v_slv5_a, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b              := normalize_and_check(v_slv8(-1 downto 0), v_slv5_a, ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_slv5_b(-1 downto 0) := normalize_and_check(v_slv8, v_slv5_a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_slv5_a", "v_slv8", "");

      log("\rCheck normalize_and_check for unsigned");
      -- unsigned: No errors expected
      v_uns8   := x"00";
      v_uns5_a := "10101";
      v_uns5_b := "01010";
      v_uns8   := normalize_and_check(v_uns5_a, v_uns8, ALLOW_NARROWER, "v_uns5_a", "v_uns8", "");
      check_value(v_uns8, "000" & v_uns5_a, error, "", C_SCOPE);
      v_uns8   := x"00";
      v_uns8   := normalize_and_check(v_uns5_a, v_uns8, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      check_value(v_uns8, "000" & v_uns5_a, error, "", C_SCOPE);
      v_uns5_b := "00000";
      v_uns8   := "00010101";
      v_uns5_b := normalize_and_check(v_uns8, v_uns5_a, ALLOW_WIDER, "v_uns5_a", "v_uns8", "");
      check_value(to_integer(v_uns5_b), to_integer(v_uns8), error, "", C_SCOPE);
      v_uns5_b := "00000";
      v_uns5_b := normalize_and_check(v_uns8, v_uns5_a, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      check_value(to_integer(v_uns5_b), to_integer(v_uns8), error, "", C_SCOPE);
      v_uns5_b := normalize_and_check(v_uns5_a, v_uns5_b, ALLOW_EXACT_ONLY, "v_uns5_a", "v_uns5_b", "");
      check_value(v_uns5_a, v_uns5_b, error, "", C_SCOPE);
      v_uns5_b := normalize_and_check(v_uns5_a, v_uns5_b, ALLOW_NARROWER, "v_uns5_a", "v_uns5_b", "");
      v_uns5_b := normalize_and_check(v_uns5_a, v_uns5_b, ALLOW_WIDER, "v_uns5_a", "v_uns5_b", "");
      v_uns5_b := normalize_and_check(v_uns5_a, v_uns5_b, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns5_b", "");

      -- unsigned: Provoking errors
      v_uns8                := x"00";
      v_uns5_a              := "10101";
      v_uns5_b              := "01010";
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns8                := normalize_and_check(v_uns5_a, v_uns8, ALLOW_WIDER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns8                := normalize_and_check(v_uns5_a, v_uns8, ALLOW_EXACT_ONLY, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := normalize_and_check(v_uns8, v_uns5_a, ALLOW_NARROWER, "v_uns8", "v_uns5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := normalize_and_check(v_uns8, v_uns5_a, ALLOW_EXACT_ONLY, "v_uns8", "v_uns5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns8                := x"55";
      v_uns5_b              := normalize_and_check(v_uns8, v_uns5_a, ALLOW_WIDER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := "00000";
      v_uns5_b              := normalize_and_check(v_uns8, v_uns5_a, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b              := normalize_and_check(v_uns8(-1 downto 0), v_uns5_a, ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_uns5_b(-1 downto 0) := normalize_and_check(v_uns8, v_uns5_a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_uns5_a", "v_uns8", "");

      log("\rCheck normalize_and_check for signed");
      -- signed: No errors expected
      v_sig8   := x"00";
      v_sig5_a := "10101";
      v_sig5_b := "01010";
      v_sig8   := normalize_and_check(v_sig5_a, v_sig8, ALLOW_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig8   := x"00";
      v_sig8   := normalize_and_check(v_sig5_a, v_sig8, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig8   := "00010101";
      v_sig5_b := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig5_b, v_sig8, error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig5_b := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig5_b, v_sig8, error, "", C_SCOPE);
      v_sig8   := x"00";
      v_sig5_a := "01010";
      v_sig5_b := "10101";
      v_sig8   := normalize_and_check(v_sig5_a, v_sig8, ALLOW_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig8   := x"00";
      v_sig8   := normalize_and_check(v_sig5_a, v_sig8, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(v_sig8, to_signed(to_integer(v_sig5_a), 8), error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig8   := "11110101";
      v_sig5_b := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      check_value(to_integer(v_sig5_b), to_integer(v_sig8), error, "", C_SCOPE);
      v_sig5_b := "00000";
      v_sig5_b := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      check_value(to_integer(v_sig5_b), to_integer(v_sig8), error, "", C_SCOPE);
      v_sig5_b := normalize_and_check(v_sig5_a, v_sig5_b, ALLOW_EXACT_ONLY, "v_sig5_a", "v_sig5_b", "");
      v_sig5_b := normalize_and_check(v_sig5_a, v_sig5_b, ALLOW_NARROWER, "v_sig5_a", "v_sig5_b", "");
      v_sig5_b := normalize_and_check(v_sig5_a, v_sig5_b, ALLOW_WIDER, "v_sig5_a", "v_sig5_b", "");
      v_sig5_b := normalize_and_check(v_sig5_a, v_sig5_b, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig5_b", "");

      -- signed: Provoking errors
      v_sig8                := x"00";
      v_sig5_a              := "10101";
      v_sig5_b              := "01010";
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := normalize_and_check(v_sig5_a, v_sig8, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := normalize_and_check(v_sig5_a, v_sig8, ALLOW_EXACT_ONLY, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := normalize_and_check(v_sig8, v_sig5_a, ALLOW_NARROWER, "v_sig8", "v_sig5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := normalize_and_check(v_sig8, v_sig5_a, ALLOW_EXACT_ONLY, "v_sig8", "v_sig5_a", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := x"55";
      v_sig5_b              := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := "00000";
      v_sig5_b              := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig8                := "10110101";
      v_sig5_b              := normalize_and_check(v_sig8, v_sig5_a, ALLOW_WIDER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b              := normalize_and_check(v_sig8(-1 downto 0), v_sig5_a, ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");
      increment_expected_alerts_and_stop_limit(TB_ERROR);
      v_sig5_b(-1 downto 0) := normalize_and_check(v_sig8, v_sig5_a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_sig5_a", "v_sig8", "");

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "setting_output_file_name" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing runtime setting of output file", C_SCOPE);

      log("Setting output file");
      if C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME then
        increment_expected_alerts(warning, 2);
      end if;

      set_log_file_name(GC_TESTCASE & "_testLog2.txt");
      set_alert_file_name(GC_TESTCASE & "_alertLog2.txt");

      log("This string should be written to testLog2.txt");
      log("This string should also be written to testLog2.txt");
      increment_expected_alerts(TB_WARNING);
      alert(TB_WARNING, "This alert should be written to alertLog2.txt");

      set_log_file_name(GC_TESTCASE & "_testLog3.txt", ID_SEQUENCER);
      set_alert_file_name(GC_TESTCASE & "_alertLog3.txt", ID_SEQUENCER);

      set_log_file_name(GC_TESTCASE & "_Log.txt");
      set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "string_methods" then
    ------------------------------------------------------------------------------------------------------------------------------
      v_slv8   := x"17";
      v_slv5_a := "10111";
      log("Valid hex, no radix");
      check_value(to_string(v_slv8, HEX), "17", error, "to_string x""17"", HEX", C_SCOPE);
      check_value(to_string(v_slv8, BIN), "00010111", error, "to_string x""17"", BIN", C_SCOPE);
      check_value(to_string(v_slv5_a, HEX), "17", error, "to_string x""17"", HEX", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID), "17", error, "to_string x""17"", HEX_BIN_IF_INVALID", C_SCOPE);

      log("Invalid hex, no radix");
      v_slv8 := "0X010111";
      check_value(to_string(v_slv8, HEX), "X7", error, "to_string b""0x010111"", HEX", C_SCOPE);
      check_value(to_string(v_slv8, BIN), "0X010111", error, "to_string b""0x010111"", BIN", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID), "X7 (b""0X010111"")", error, "to_string b""0x010111"", HEX_BIN_IF_INVALID", C_SCOPE);

      log("Valid hex, Radix");
      v_slv8 := x"17";
      check_value(to_string(v_slv8, HEX, AS_IS, INCL_RADIX), "x""17""", error, "to_string b""0x010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, BIN, AS_IS, INCL_RADIX), "b""00010111""", error, "to_string b""00010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX), "x""17""", error, "to_string b""0x010111"", HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX", C_SCOPE);

      log("Invalid hex, Radix");
      v_slv8 := "0X010111";
      check_value(to_string(v_slv8, HEX, AS_IS, INCL_RADIX), "x""X7""", error, "to_string b""0x010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, BIN, AS_IS, INCL_RADIX), "b""0X010111""", error, "to_string b""0x010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX), "x""X7"" (b""0X010111"")", error, "to_string b""0x010111"", HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX", C_SCOPE);

      log("Signed, positive");
      v_sig8 := x"17";                    -- +23 decimal
      check_value(to_string(v_sig8, DEC), "23", error, "to_string x""17"", DEC", C_SCOPE);
      check_value(to_string(v_sig8, HEX), "17", error, "to_string x""17"", HEX", C_SCOPE);
      check_value(to_string(v_sig8, BIN), "00010111", error, "to_string x""17"", BIN", C_SCOPE);
      check_value(to_string(v_sig8, HEX, AS_IS, INCL_RADIX), "x""17""", error, "to_string b""0x010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_sig8, BIN, AS_IS, INCL_RADIX), "b""00010111""", error, "to_string b""00010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);

      log("Signed, negative");
      v_sig8 := x"97";                    -- -105 decimal
      check_value(to_string(v_sig8, DEC), "-105", error, "to_string x""97"", DEC", C_SCOPE);
      check_value(to_string(v_sig8, HEX), "97", error, "to_string x""97"", HEX", C_SCOPE);
      check_value(to_string(v_sig8, BIN), "10010111", error, "to_string x""97"", BIN", C_SCOPE);
      check_value(to_string(v_sig8, HEX, AS_IS, INCL_RADIX), "x""97""", error, "to_string b""0x10010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_sig8, BIN, AS_IS, INCL_RADIX), "b""10010111""", error, "to_string b""10010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);

      v_sig32 := x"80030201";             -- -2147286527 decimal
      check_value(to_string(v_sig32, DEC), "-2147286527", error, "to_string x""80030201"", DEC", C_SCOPE);

      v_sig33 := 33x"1FEDCBA98";
      check_value(to_string(v_sig33, DEC), "1FEDCBA98 (too wide to be converted to integer)", error, "to_string x""1FEDCBA98"", DEC", C_SCOPE);

      log("Integer as DEC");
      v_int := 150;
      check_value(to_string(v_int, DEC, EXCL_RADIX), "150", error, "to_string 150, DEC, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, DEC, INCL_RADIX), "d""150""", error, "to_string d""150"", DEC, INCL_RADIX", C_SCOPE);
      log("Integer as BIN");
      check_value(to_string(v_int, BIN, EXCL_RADIX), "10010110", error, "to_string 10010110, BIN, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, BIN, INCL_RADIX), "b""10010110""", error, "to_string b""10010110"", BIN, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, BIN, INCL_RADIX, KEEP_LEADING_0), "b""00000000000000000000000010010110""", error, "to_string b""00000000000000000000000010010110"", BIN, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);
      log("Integer as HEX");
      check_value(to_string(v_int, HEX, EXCL_RADIX), "96", error, "to_string 96, HEX, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, HEX, INCL_RADIX), "x""96""", error, "to_string x""96"", HEX, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, HEX, INCL_RADIX, KEEP_LEADING_0), "x""00000096""", error, "to_string x""00000096"", HEX, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);
      log("Integer as DEC");
      v_int := -150;
      check_value(to_string(v_int, DEC, EXCL_RADIX), "-150", error, "to_string -150, DEC, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, DEC, INCL_RADIX), "d""-150""", error, "to_string d""-150"", DEC, INCL_RADIX", C_SCOPE);
      log("Integer as BIN");
      check_value(to_string(v_int, BIN, EXCL_RADIX), "11111111111111111111111101101010", error, "to_string 11111111111111111111111101101010, BIN, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, BIN, INCL_RADIX), "b""11111111111111111111111101101010""", error, "to_string b""11111111111111111111111101101010"", BIN, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, BIN, INCL_RADIX, KEEP_LEADING_0), "b""11111111111111111111111101101010""", error, "to_string b""11111111111111111111111101101010"", BIN, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);
      log("Integer as HEX");
      check_value(to_string(v_int, HEX, EXCL_RADIX), "FFFFFF6A", error, "to_string FFFFFF6A, HEX, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, HEX, INCL_RADIX), "x""FFFFFF6A""", error, "to_string x""FFFFFF6A"", HEX, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_int, HEX, INCL_RADIX, KEEP_LEADING_0), "x""FFFFFF6A""", error, "to_string x""FFFFFF6A"", HEX, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);

      -- Log "ASCII test" - Test ascii_to_char()
      v_string(1)  := ascii_to_char(65);
      v_string(2)  := ascii_to_char(83);
      v_string(3)  := ascii_to_char(67);
      v_string(4)  := ascii_to_char(73);
      v_string(5)  := ascii_to_char(73);
      v_string(6)  := ascii_to_char(32); -- Space
      v_string(7)  := ascii_to_char(116);
      v_string(8)  := ascii_to_char(101);
      v_string(9)  := ascii_to_char(115);
      v_string(10) := ascii_to_char(116);
      log(v_string);

      -- One and two backslash-r
      log("\rlog using one backslash-r");
      log("\r\rlog using two backslash-r");

      -- Conversion from character to ascii integer
      log("\rCheck char_to_ascii");
      check_value(char_to_ascii('A'), 65, error, "Check ascii value for A");
      check_value(char_to_ascii('a'), 97, error, "Check ascii value for a");

      log("\rCheck to_string on illegal characters");
      check_value(to_string("abcdef A z Z 0 9" & NUL & ",:;#.End"), "abcdef A z Z 0 9,:;#.End", error, "to_string() for illegal chars");

      log("\rCheck function remove_initial_chars()");
      check_value(remove_initial_chars("abcdef", 3), "def", error, "remove_initial_chars() case 1");
      check_value(remove_initial_chars("abcdef", 1), "bcdef", error, "remove_initial_chars() case 1");
      check_value(remove_initial_chars("abcdef", 0), "abcdef", error, "remove_initial_chars() case 1");
      check_value(remove_initial_chars("abcdef", 6), "", error, "remove_initial_chars() case 1");

      log("\rCheck functions pos_of_*() and get_string_between_delimiters()");
      check_value(pos_of_leftmost('c', "abc", 5), 3, error, "leftmost c in abc");
      check_value(pos_of_leftmost('c', "a bcdcdc", 5), 4, error, "leftmost c in a bcdcdc");
      check_value(pos_of_leftmost('c', "a bxdcdx", 5), 6, error, "leftmost c in a bxdcdx, with default 5");

      check_value(pos_of_rightmost('c', "abc", 5), 3, error, "rightmost c in abc");
      check_value(pos_of_rightmost('c', "a bcdcdc", 5), 8, error, "rightmost c in a bcdcdc");
      check_value(pos_of_rightmost('c', "a bxdcdx", 5), 6, error, "rightmost c in a bxdcdx, with default 5");

      check_value(get_string_between_delimiters("a bxdcdx", 'b', 'd', right), "xdc", error, "delimeters case 1");
      check_value(get_string_between_delimiters("a bxdcdx", 'b', 'd', right), "xdc", error, "delimeters case 2");
      check_value(get_string_between_delimiters(":abc,:def:,ghi", ':', ',', right), "", error, "delimeters case 3");
      check_value(get_string_between_delimiters(":abc,:def:,ghi", ':', ',', right, 2), "abc", error, "delimeters case 4");
      check_value(get_string_between_delimiters(":abc,:def:,ghi", ':', ':', right, 1), "def", error, "delimeters case 5");
      check_value(get_string_between_delimiters(":abc,:def:,ghi", ':', ':', right, 2), "abc,", error, "delimeters case 6");

      log("\rCheck functions get_*_name_from_instance_name()");
      check_value(get_process_name_from_instance_name(v_slv8'instance_name), "p_main", error, "get_process_name....");
      check_value(get_entity_name_from_instance_name(slv8'instance_name), "methods_tb", error, "get_entity_name.... 1");
      check_value(get_entity_name_from_instance_name(v_slv8'instance_name), "methods_tb", error, "get_entity_name.... 2");

      log(ID_LOG_HDR, "Printing with pad_string()", C_SCOPE);
      log(pad_string("Fill on right with space", ' ', 40, left));
      log(pad_string("Fill on left with space", ' ', 40, right));
      log(pad_string("Fill on right with X", 'X', 40, left));
      log(pad_string("Fill on left with Y", 'Y', 40, right));

      log("\rCheck t_slv_array(2 downto 0)(3 downto 0)");
      v_slv_array(0) := x"9";
      v_slv_array(1) := x"A";
      v_slv_array(2) := x"6";
      check_value(to_string(v_slv_array, HEX), "(6, A, 9)", error, "to_string() for t_slv_array(2 downto 0)(3 downto 0) as HEX");
      check_value(to_string(v_slv_array, DEC), "(6, 10, 9)", error, "to_string() for t_slv_array(2 downto 0)(3 downto 0) as DEC");
      check_value(to_string(v_slv_array, BIN), "(0110, 1010, 1001)", error, "to_string() for t_slv_array(2 downto 0)(3 downto 0) as BIN");
      v_slv_array(1) := (others => 'U');
      check_value(to_string(v_slv_array, HEX_BIN_IF_INVALID), "(6, X (b""UUUU""), 9)", error, "to_string() for t_slv_array(2 downto 0)(3 downto 0) as HEX_BIN_IF_INVALID");

      log("\rCheck long t_slv_array(31 downto 0)(7 downto 0)");
      for idx in 0 to v_slv_array_32'length - 1 loop
        v_slv_array_32(idx) := std_logic_vector(to_unsigned(idx, v_slv_array_32(0)'length));
      end loop;
      check_value(to_string(v_slv_array_32, HEX), "(1F, 1E, 1D, 1C, 1B, 1A, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 0F, 0E, 0D, 0C, 0B, 0A, 09, 08, 07, 06, 05, 04, 03, 02, 01, 00)", error, "to_string() for t_slv_array(31 downto 0)(7 downto 0) as HEX");
      check_value(to_string(v_slv_array_32, DEC), "(31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)", error, "to_string() for t_slv_array(31 downto 0)(7 downto 0) as BIN");
      check_value(to_string(v_slv_array_32, BIN), "(00011111, 00011110, 00011101, 00011100, 00011011, 00011010, 00011001, 00011000, 00010111, 00010110, 00010101, 00010100, 00010011, 00010010, 00010001, 00010000, 00001111, 00001110, 00001101, 00001100, 00001011, 00001010, 00001001, 00001000, 00000111, 00000110, 00000101, 00000100, 00000011, 00000010, 00000001, 00000000)", error, "to_string() for t_slv_array(31 downto 0)(7 downto 0) as BIN");
      --    1F        1e        1d        1c        1b        1a        19        18        17        16        15        14        13        12        11        10        0f        0E        0d          0c        0b        0a        09        08        07        06        05        04        03        02        01        00
      v_slv_array_32(v_slv_array_32'low)  := (others => 'U');
      v_slv_array_32(v_slv_array_32'high) := (others => 'U');
      check_value(to_string(v_slv_array_32, HEX_BIN_IF_INVALID), "(XX (b""UUUUUUUU""), 1E, 1D, 1C, 1B, 1A, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 0F, 0E, 0D, 0C, 0B, 0A, 09, 08, 07, 06, 05, 04, 03, 02, 01, XX (b""UUUUUUUU""))", error, "to_string() for t_slv_array(31 downto 0)(7 downto 0) as HEX_BIN_IF_INVALID");

      log("\nCheck 32 bit wide t_slv_array");
      -- 32 bit wide in order to trigger the message "(too wide to be converted to integer)
      v_slv32_array(1) := x"01234567";
      v_slv32_array(2) := x"FEDCBA98";
      check_value(to_string(v_slv32_array, HEX), "(01234567, FEDCBA98)", error, "to_string for t_slv_array(1 to 2)(31 downto 0) as HEX");
      check_value(to_string(v_slv32_array, DEC, KEEP_LEADING_0, INCL_RADIX), "(x""01234567 (too wide to be converted to integer)"", x""FEDCBA98 (too wide to be converted to integer)"")", error, "to_string for t_slv_array(1 to 2)(31 downto 0) as DEC");
      check_value(to_string(v_slv32_array, BIN), "(00000001001000110100010101100111, 11111110110111001011101010011000)", error, "to_string for t_slv_array(1 to 2)(31 downto 0) as BIN");
      v_slv32_array(2) := (others => 'U');
      check_value(to_string(v_slv32_array, HEX_BIN_IF_INVALID), "(01234567, XXXXXXXX (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""))", error, "to_string for t_slv_array(1 to 2)(31 downto 0) as HEX_BIN_IF_INVALID");

      log("\nCheck 256 bit wide t_slv_array");
      v_slv256_array(1) := x"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
      v_slv256_array(0) := x"FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210";
      check_value(to_string(v_slv256_array, HEX, KEEP_LEADING_0, INCL_RADIX), "(x""0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"", x""FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210"")", error, "to_string for t_slv_array(1 downto 0)(255 downto 0) as HEX");
      check_value(to_string(v_slv256_array, DEC, KEEP_LEADING_0, INCL_RADIX), "(x""0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF (too wide to be converted to integer)"", x""FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210 (too wide to be converted to integer)"")", error, "to_string for t_slv_array(1 downto 0)(255 downto 0) as DEC");
      check_value(to_string(v_slv256_array, BIN, KEEP_LEADING_0, INCL_RADIX), "(b""0000000100100011010001010110011110001001101010111100110111101111000000010010001101000101011001111000100110101011110011011110111100000001001000110100010101100111100010011010101111001101111011110000000100100011010001010110011110001001101010111100110111101111"", b""1111111011011100101110101001100001110110010101000011001000010000111111101101110010111010100110000111011001010100001100100001000011111110110111001011101010011000011101100101010000110010000100001111111011011100101110101001100001110110010101000011001000010000"")", error, "to_string for t_slv_array(1 downto 0)(255 downto 0) as BIN");
      v_slv256_array(1) := (others => 'U');
      v_slv256_array(0) := (others => 'U');
      check_value(to_string(v_slv256_array, HEX_BIN_IF_INVALID, KEEP_LEADING_0, INCL_RADIX), "(x""XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"" (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""), x""XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"" (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""))", error, "to_string for t_slv_array(1 downto 0)(255 downto 0) as HEX_BIN_IF_INVALID");

      log("\rCheck t_signed_array(2 downto 0)(3 downto 0)");
      v_signed_array(0) := "1101";      -- -3
      v_signed_array(1) := "0011";      -- +3
      v_signed_array(2) := "1001";      -- -7
      check_value(to_string(v_signed_array, HEX), "(9, 3, D)", error, "to_string() for t_signed_array(2 downto 0)(3 downto 0) as HEX");
      check_value(to_string(v_signed_array, DEC), "(-7, 3, -3)", error, "to_string() for t_signed_array(2 downto 0)(3 downto 0) as DEC");
      check_value(to_string(v_signed_array, BIN), "(1001, 0011, 1101)", error, "to_string() for t_signed_array(2 downto 0)(3 downto 0) as BIN");
      v_signed_array(1) := (others => 'U');
      check_value(to_string(v_signed_array, HEX_BIN_IF_INVALID), "(9, X (b""UUUU""), D)", error, "to_string() for t_signed_array(2 downto 0)(3 downto 0) as HEX_BIN_IF_INVALID");

      log("\nCheck 33 bit wide t_signed_array");
      -- 33 bit wide in order to trigger the message "(too wide to be converted to integer)
      v_signed33_array(1) := 33x"001234567";
      v_signed33_array(2) := 33x"1FEDCBA98";
      check_value(to_string(v_signed33_array, HEX), "(001234567, 1FEDCBA98)", error, "to_string for t_signed_array(1 to 2)(32 downto 0) as HEX");
      check_value(to_string(v_signed33_array, DEC, KEEP_LEADING_0, INCL_RADIX), "(x""001234567"" (too wide to be converted to integer), x""1FEDCBA98"" (too wide to be converted to integer))", error, "to_string for t_signed_array(1 to 2)(32 downto 0) as DEC");
      check_value(to_string(v_signed33_array, BIN), "(000000001001000110100010101100111, 111111110110111001011101010011000)", error, "to_string for t_signed_array(1 to 2)(32 downto 0) as BIN");
      v_signed33_array(2) := (others => 'U');
      check_value(to_string(v_signed33_array, HEX_BIN_IF_INVALID), "(001234567, XXXXXXXXX (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""))", error, "to_string for t_signed_array(1 to 2)(32 downto 0) as HEX_BIN_IF_INVALID");

      log("\nCheck 256 bit wide t_signed_array");
      v_signed256_array(1) := x"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
      v_signed256_array(0) := x"FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210";
      check_value(to_string(v_signed256_array, HEX, KEEP_LEADING_0, INCL_RADIX), "(x""0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"", x""FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210"")", error, "to_string for t_signed_array(1 downto 0)(255 downto 0) as HEX");
      check_value(to_string(v_signed256_array, DEC, KEEP_LEADING_0, INCL_RADIX), "(x""0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"" (too wide to be converted to integer), x""FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210"" (too wide to be converted to integer))", error, "to_string for t_signed_array(1 downto 0)(255 downto 0) as DEC");
      check_value(to_string(v_signed256_array, BIN, KEEP_LEADING_0, INCL_RADIX), "(b""0000000100100011010001010110011110001001101010111100110111101111000000010010001101000101011001111000100110101011110011011110111100000001001000110100010101100111100010011010101111001101111011110000000100100011010001010110011110001001101010111100110111101111"", b""1111111011011100101110101001100001110110010101000011001000010000111111101101110010111010100110000111011001010100001100100001000011111110110111001011101010011000011101100101010000110010000100001111111011011100101110101001100001110110010101000011001000010000"")", error, "to_string for t_signed_array(1 downto 0)(255 downto 0) as BIN");
      v_signed256_array(1) := (others => 'U');
      v_signed256_array(0) := (others => 'U');
      check_value(to_string(v_signed256_array, HEX_BIN_IF_INVALID, KEEP_LEADING_0, INCL_RADIX), "(x""XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"" (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""), x""XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"" (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""))", error, "to_string for t_signed_array(1 downto 0)(255 downto 0) as HEX_BIN_IF_INVALID");

      log("\rCheck t_unsigned_array(2 downto 0)(3 downto 0)");
      v_unsigned_array(0) := "1101";    -- D
      v_unsigned_array(1) := "0011";    -- 3
      v_unsigned_array(2) := "1001";    -- 9
      check_value(to_string(v_unsigned_array, HEX), "(9, 3, D)", error, "to_string() for t_unsigned_array(2 downto 0)(3 downto 0) as HEX");
      check_value(to_string(v_unsigned_array, DEC), "(9, 3, 13)", error, "to_string() for t_unsigned_array(2 downto 0)(3 downto 0) as DEC");
      check_value(to_string(v_unsigned_array, BIN), "(1001, 0011, 1101)", error, "to_string() for t_unsigned_array(2 downto 0)(3 downto 0) as BIN");
      v_unsigned_array(1) := (others => 'U'); -- 3
      check_value(to_string(v_unsigned_array, HEX_BIN_IF_INVALID), "(9, X (b""UUUU""), D)", error, "to_string() for t_unsigned_array(2 downto 0)(3 downto 0) as HEX_BIN_IF_INVALID");

      log("\nCheck 32 bit wide t_unsigned_array");
      -- 32 bit wide in order to trigger the message "(too wide to be converted to integer)
      v_unsigned32_array(1) := x"01234567";
      v_unsigned32_array(2) := x"FEDCBA98";
      check_value(to_string(v_unsigned32_array, HEX), "(01234567, FEDCBA98)", error, "to_string for t_unsigned_array(1 to 2)(31 downto 0) as HEX");
      check_value(to_string(v_unsigned32_array, DEC, KEEP_LEADING_0, INCL_RADIX), "(x""01234567 (too wide to be converted to integer)"", x""FEDCBA98 (too wide to be converted to integer)"")", error, "to_string for t_unsigned_array(1 to 2)(31 downto 0) as DEC");
      check_value(to_string(v_unsigned32_array, BIN), "(00000001001000110100010101100111, 11111110110111001011101010011000)", error, "to_string for t_unsigned_array(1 to 2)(31 downto 0) as BIN");
      v_unsigned32_array(2) := (others => 'U');
      check_value(to_string(v_unsigned32_array, HEX_BIN_IF_INVALID), "(01234567, XXXXXXXX (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""))", error, "to_string for t_unsigned_array(1 to 2)(31 downto 0) as HEX_BIN_IF_INVALID");

      log("\nCheck 256 bit wide t_unsigned_array");
      v_unsigned256_array(1) := x"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
      v_unsigned256_array(0) := x"FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210";
      check_value(to_string(v_unsigned256_array, HEX, KEEP_LEADING_0, INCL_RADIX), "(x""0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"", x""FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210"")", error, "to_string for t_unsigned_array(1 downto 0)(255 downto 0) as HEX");
      check_value(to_string(v_unsigned256_array, DEC, KEEP_LEADING_0, INCL_RADIX), "(x""0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF (too wide to be converted to integer)"", x""FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210 (too wide to be converted to integer)"")", error, "to_string for t_unsigned_array(1 downto 0)(255 downto 0) as DEC");
      check_value(to_string(v_unsigned256_array, BIN, KEEP_LEADING_0, INCL_RADIX), "(b""0000000100100011010001010110011110001001101010111100110111101111000000010010001101000101011001111000100110101011110011011110111100000001001000110100010101100111100010011010101111001101111011110000000100100011010001010110011110001001101010111100110111101111"", b""1111111011011100101110101001100001110110010101000011001000010000111111101101110010111010100110000111011001010100001100100001000011111110110111001011101010011000011101100101010000110010000100001111111011011100101110101001100001110110010101000011001000010000"")", error, "to_string for t_unsigned_array(1 downto 0)(255 downto 0) as BIN");
      v_unsigned256_array(1) := (others => 'U');
      v_unsigned256_array(0) := (others => 'U');
      check_value(to_string(v_unsigned256_array, HEX_BIN_IF_INVALID, KEEP_LEADING_0, INCL_RADIX), "(x""XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"" (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""), x""XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"" (b""UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU""))", error, "to_string for t_unsigned_array(1 downto 0)(255 downto 0) as HEX_BIN_IF_INVALID");

      log("\rVerifying justify()");
      --Log pre-appended info is 80 chars long
      log(ID_SEQUENCER, justify("    Left", left, C_LOG_LINE_WIDTH - 80, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("    Left", left, C_LOG_LINE_WIDTH - 80, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("    Center", center, C_LOG_LINE_WIDTH - 80, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("    Center", center, C_LOG_LINE_WIDTH - 80, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("    Right", right, C_LOG_LINE_WIDTH - 80, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("    Right", right, C_LOG_LINE_WIDTH - 80, SKIP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("Truncate last word", left, 13, KEEP_LEADING_SPACE, DISALLOW_TRUNCATE));
      log(ID_SEQUENCER, justify("Truncate last word", left, 13, KEEP_LEADING_SPACE, ALLOW_TRUNCATE));

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "byte_and_slv_arrays" then
    ------------------------------------------------------------------------------------------------------------------------------
      -------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing and verifying convert_byte_array_to_slv_array");
      -------------------------------------------------------------------------------------
      log(ID_SEQUENCER, "Byte-to-byte, default byte position");
      v_slv_array_as_byte := (others => (others => '0'));
      -- build 10x1 bytes
      for idx in 1 to 10 loop
        v_byte_array(idx - 1) := std_logic_vector(to_unsigned(idx, v_byte_array(idx - 1)'length));
      end loop;
      -- convert
      v_slv_array_as_byte := convert_byte_array_to_slv_array(v_byte_array, 1); -- LOWER_BYTE_LEFT
      -- check result
      for idx in 1 to 10 loop
        v_byte := v_slv_array_as_byte(idx - 1);
        check_value(v_byte = v_byte_array(idx - 1), error, "Checking convert_byte_array_to_slv_array() result, byte #" & to_string(idx - 1));
      end loop;

      log(ID_SEQUENCER, "Byte-to-3xbyte testing, LOWER_BYTE_LEFT");
      v_slv_array_as_3_byte := (others => (others => '0'));
      -- build 3x3 bytes
      for idx in 1 to 9 loop
        v_byte_array(idx - 1) := random(v_byte_array(idx - 1)'length);
      end loop;
      -- convert
      v_slv_array_as_3_byte(0 to 2) := convert_byte_array_to_slv_array(v_byte_array, 3, LOWER_BYTE_LEFT);
      --check result
      v_idx := 0;
      for idx in 1 to 3 loop
        v_byte := v_slv_array_as_3_byte(idx - 1)(23 downto 16);
        check_value(v_byte = v_byte_array(v_idx), error, "Checking convert_byte_array_to_slv_array(), byte #" & to_string(v_idx));
        v_byte := v_slv_array_as_3_byte(idx - 1)(15 downto 8);
        check_value(v_byte = v_byte_array(v_idx + 1), error, "Checking convert_byte_array_to_slv_array(), byte #" & to_string(v_idx + 1));
        v_byte := v_slv_array_as_3_byte(idx - 1)(7 downto 0);
        check_value(v_byte = v_byte_array(v_idx + 2), error, "Checking convert_byte_array_to_slv_array(), byte #" & to_string(v_idx + 2));
        v_idx  := v_idx + 3;
      end loop;

      log(ID_SEQUENCER, "Byte-to-3xbyte testing, LOWER_BYTE_RIGHT");
      v_slv_array_as_3_byte := (others => (others => '0'));
      -- convert
      v_slv_array_as_3_byte(0 to 2) := convert_byte_array_to_slv_array(v_byte_array, 3, LOWER_BYTE_RIGHT);
      -- check result
      v_idx := 0;
      for idx in 1 to 3 loop
        v_byte := v_slv_array_as_3_byte(idx - 1)(7 downto 0);
        check_value(v_byte = v_byte_array(v_idx), error, "Checking convert_byte_array_to_slv_array(), byte #" & to_string(v_idx));
        v_byte := v_slv_array_as_3_byte(idx - 1)(15 downto 8);
        check_value(v_byte = v_byte_array(v_idx + 1), error, "Checking convert_byte_array_to_slv_array(), byte #" & to_string(v_idx + 1));
        v_byte := v_slv_array_as_3_byte(idx - 1)(23 downto 16);
        check_value(v_byte = v_byte_array(v_idx + 2), error, "Checking convert_byte_array_to_slv_array(), byte #" & to_string(v_idx + 2));
        v_idx  := v_idx + 3;
      end loop;

      -------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing and verifying convert_slv_array_to_byte_array");
      -------------------------------------------------------------------------------------
      log(ID_SEQUENCER, "Byte to byte testing, default byte position, ascending t_byte_array");
      v_byte_array := (others => (others => '0'));
      -- build 10x1 bytes
      for idx in 1 to 10 loop
        v_slv_array_as_byte(idx - 1) := std_logic_vector(to_unsigned(idx, v_slv_array_as_byte(idx - 1)'length));
      end loop;
      -- convert
      v_byte_array := convert_slv_array_to_byte_array(v_slv_array_as_byte, LOWER_BYTE_LEFT);
      -- check result
      for idx in 1 to 10 loop
        v_byte := v_slv_array_as_byte(idx - 1);
        check_value(v_byte = v_byte_array(idx - 1), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(idx - 1));
      end loop;

      log(ID_SEQUENCER, "Byte to byte testing, default byte position, descending t_byte_array");
      v_byte_desc_array := (others => (others => '0'));
      -- build 10x1 bytes
      for idx in 1 to 10 loop
        v_slv_desc_array_as_byte(idx - 1) := std_logic_vector(to_unsigned(idx, v_slv_desc_array_as_byte(idx - 1)'length));
      end loop;
      -- convert
      v_byte_desc_array := convert_slv_array_to_byte_array(v_slv_desc_array_as_byte, LOWER_BYTE_LEFT);
      -- check result
      for idx in 1 to 10 loop
        v_byte := v_slv_desc_array_as_byte(idx - 1);
        check_value(v_byte = v_byte_desc_array(idx - 1), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(idx - 1));
      end loop;

      log(ID_SEQUENCER, "Byte to byte testing, ascending byte vector, ascending t_byte_array");
      v_byte_array := (others => (others => '0'));
      -- convert
      v_byte_array(0 to 1) := convert_slv_array_to_byte_array(t_slv_array'(8x"A0", 8x"A1"), LOWER_BYTE_LEFT);
      -- check result
      check_value(8x"A0" = v_byte_array(0), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(0));
      check_value(8x"A1" = v_byte_array(1), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(1));

      log(ID_SEQUENCER, "3xbyte to byte testing, LOWER_BYTE_LEFT, ascending t_byte_array");
      v_byte_array := (others => (others => '0'));
      -- build 3x3 bytes
      for idx in 1 to 3 loop
        v_slv_array_as_3_byte(idx - 1) := random(v_slv_array_as_3_byte(idx - 1)'length);
      end loop;
      -- convert
      v_byte_array(0 to 8) := convert_slv_array_to_byte_array(v_slv_array_as_3_byte(0 to 2), LOWER_BYTE_LEFT);
      -- check result
      v_idx := 0;
      for idx in 1 to 3 loop
        v_byte := v_slv_array_as_3_byte(idx - 1)(23 downto 16);
        check_value(v_byte = v_byte_array(v_idx), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(v_idx));
        v_byte := v_slv_array_as_3_byte(idx - 1)(15 downto 8);
        check_value(v_byte = v_byte_array(v_idx + 1), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(v_idx + 1));
        v_byte := v_slv_array_as_3_byte(idx - 1)(7 downto 0);
        check_value(v_byte = v_byte_array(v_idx + 2), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(v_idx + 2));
        v_idx  := v_idx + 3;
      end loop;

      log(ID_SEQUENCER, "3xbyte to byte testing, LOWER_BYTE_RIGHT, ascending t_byte_array");
      -- convert
      v_byte_array(0 to 8) := convert_slv_array_to_byte_array(v_slv_array_as_3_byte(0 to 2), LOWER_BYTE_RIGHT);
      -- check result
      v_idx := 0;
      for idx in 1 to 3 loop
        v_byte := v_slv_array_as_3_byte(idx - 1)(7 downto 0);
        check_value(v_byte = v_byte_array(v_idx), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(v_idx));
        v_byte := v_slv_array_as_3_byte(idx - 1)(15 downto 8);
        check_value(v_byte = v_byte_array(v_idx + 1), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(v_idx + 1));
        v_byte := v_slv_array_as_3_byte(idx - 1)(23 downto 16);
        check_value(v_byte = v_byte_array(v_idx + 2), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(v_idx + 2));
        v_idx  := v_idx + 3;
      end loop;

      -------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing and verifying convert_byte_array_to_slv");
      -------------------------------------------------------------------------------------
      log(ID_SEQUENCER, "Byte endianness: LOWER_BYTE_LEFT");
      v_slv := (others => '0');
      -- fill byte array
      for idx in 0 to 9 loop
        v_byte_array(idx) := std_logic_vector(to_unsigned(idx, v_byte_array(idx)'length));
      end loop;
      -- convert
      v_slv := convert_byte_array_to_slv(v_byte_array, LOWER_BYTE_LEFT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := v_slv(8 * (10 - idx) - 1 downto 8 * (9 - idx));
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_byte_array_to_slv() result, byte #" & to_string(idx));
      end loop;

      log(ID_SEQUENCER, "Byte endianness: LOWER_BYTE_RIGHT");
      v_slv := (others => '0');
      -- fill byte array
      for idx in 0 to 9 loop
        v_byte_array(idx) := std_logic_vector(to_unsigned(idx, v_byte_array(idx)'length));
      end loop;
      -- convert
      v_slv := convert_byte_array_to_slv(v_byte_array, LOWER_BYTE_RIGHT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := v_slv(8 * (idx + 1) - 1 downto 8 * idx);
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_byte_array_to_slv() result, byte #" & to_string(idx));
      end loop;

      -------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing and verifying convert_slv_to_byte_array");
      -------------------------------------------------------------------------------------
      log(ID_SEQUENCER, "Byte endianness: LOWER_BYTE_LEFT");
      v_byte_array := (others => (others => '0'));
      -- fill slv
      for idx in 0 to 9 loop
        v_slv(8 * (10 - idx) - 1 downto 8 * (9 - idx)) := std_logic_vector(to_unsigned(idx, 8));
      end loop;
      -- convert
      v_byte_array := convert_slv_to_byte_array(v_slv, LOWER_BYTE_LEFT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := v_slv(8 * (10 - idx) - 1 downto 8 * (9 - idx));
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_slv_to_byte_array() result, byte #" & to_string(idx));
      end loop;

      log(ID_SEQUENCER, "Byte endianness: LOWER_BYTE_LEFT - Check padding when std_logic_vector not multiple of byte");
      v_byte_array := (others => (others => '0'));
      -- fill slv
      v_slv_not_byte_multiple := (others => '1');
      -- convert
      v_byte_array := convert_slv_to_byte_array(v_slv_not_byte_multiple, LOWER_BYTE_LEFT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := (others => '1') when idx < 9 else "1111ZZZZ";
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_slv_to_byte_array() result, byte #" & to_string(idx));
      end loop;

      log(ID_SEQUENCER, "Byte endianness: LOWER_BYTE_RIGHT");
      v_byte_array := (others => (others => '0'));
      -- fill slv
      for idx in 0 to 9 loop
        v_slv(8 * (idx + 1) - 1 downto 8 * idx) := std_logic_vector(to_unsigned(idx, 8));
      end loop;
      -- convert
      v_byte_array := convert_slv_to_byte_array(v_slv, LOWER_BYTE_RIGHT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := v_slv(8 * (idx + 1) - 1 downto 8 * idx);
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_slv_to_byte_array() result, byte #" & to_string(idx));
      end loop;

      log(ID_SEQUENCER, "Byte endianness: LOWER_BYTE_RIGHT - Check padding when std_logic_vector not multiple of byte");
      v_byte_array := (others => (others => '0'));
      -- fill slv
      v_slv_not_byte_multiple := (others => '1');
      -- convert
      v_byte_array := convert_slv_to_byte_array(v_slv_not_byte_multiple, LOWER_BYTE_RIGHT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := (others => '1') when idx < 9 else "1111ZZZZ";
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_slv_to_byte_array() result, byte #" & to_string(idx));
      end loop;
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;              -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                          -- to stop completely
  end process p_main;

end architecture common_arch;
