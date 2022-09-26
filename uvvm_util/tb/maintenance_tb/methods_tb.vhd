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
-- VHDL unit     : UVVM Utility Library : methods_tb
--
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use std.textio.all;

-- Import library with context. VHDL 2008 only!
library uvvm_util;
context uvvm_util.uvvm_util_context;

--hdlregression:tb
entity methods_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

architecture func of methods_tb is
  type testing_array is array (0 to 3) of integer;
  signal test_array : testing_array := (0, 1, 2, 3);

  signal bol         : boolean                        := false;
  signal slv8        : std_logic_vector(7 downto 0)   := (others => '0');
  signal slv8_to     : std_logic_vector(0 to 7)       := (others => '0');
  signal slv128      : std_logic_vector(127 downto 0) := (others => '1');
  signal u8          : unsigned(7 downto 0)           := (others => '0');
  signal s8          : signed(7 downto 0)             := (others => '0');
  signal i           : integer                        := 0;
  signal r           : real                           := 0.0;
  signal sl          : std_logic                      := '0';
  signal clk100M     : std_logic;
  signal clk100M_ena : boolean                        := true;

  signal clk200M     : std_logic;
  signal clk200M_ena : boolean := true;

  signal clk50M : std_logic;

  signal clk500M     : std_logic;
  signal clk500M_ena : boolean := true;
  signal clk500M_cnt : natural;

  signal clk10M_ena : boolean := true;

  -- Clock signals with duty cycles.
  -- Name: clk<frequency>_percentage_<high_percentage>_<low_percentage>
  signal clk100M_percentage_60_40 : std_logic;
  signal clk100M_percentage_10_90 : std_logic;
  signal clk100M_percentage_90_10 : std_logic;

  signal clk10M_percentage_99_1 : std_logic;
  signal clk10M_percentage_1_99 : std_logic;

  signal clk500M_percentage_25_50 : std_logic;

  -- Name: clk<frequency>_time_<high_time in ns>_<low_time in ns>
  signal clk100M_time_4_6 : std_logic;
  signal clk100M_time_1_9 : std_logic;
  signal clk100M_time_9_1 : std_logic;

  signal clk10M_time_99_1 : std_logic;
  signal clk10M_time_1_99 : std_logic;

  constant C_CLK100M_PERIOD : time := 10 ns;
  constant C_CLK200M_PERIOD : time := 5 ns;
  constant C_CLK50M_PERIOD  : time := 20 ns;
  constant C_CLK10M_PERIOD  : time := 100 ns;

  constant C_CLK500M_PERIOD : time := 2 ns;
  constant C_CLK250G_PERIOD : time := 4 ps;

  constant C_RANDOM_MIN_VALUE : integer     := 10;
  constant C_RANDOM_MAX_VALUE : integer     := 13;
  type t_int_array is array (C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE) of integer;
  -- For counting results of random functions
  signal ctr                  : t_int_array := (others => 0);

  -- Adjustable clock signals
  -- Name: adj_clk<frequency>_percentage_<high_percentage>_<low_percentage>
  signal adj_clk100M                 : std_logic;
  signal adj_clk100M_high_percentage : natural range 0 to 100 := 50;
  signal adj_clk100M_ena             : boolean                := false;
  constant C_ADJ_CLK100M_PERIOD      : time                   := 10 ns;

  -- Synchronization
  signal p_clk_cnt_ena   : boolean := true;
  signal p_sync_test_ena : boolean := false;

  -- Watchdog timer control signal
  signal watchdog_ctrl_terminate : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_init      : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_extend    : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_reinit    : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;

begin

  ------------------------------------------------
  -- Process: watchdog timer
  ------------------------------------------------
  -- These timers should have a minimum timeout that covers all the
  -- tests in this testbench or else it will fail.
  watchdog_timer(watchdog_ctrl_terminate, 8100 ns, error, "Watchdog A");
  watchdog_timer(watchdog_ctrl_init, 8200 ns, error, "Watchdog B");
  watchdog_timer(watchdog_ctrl_extend, 8300 ns, error, "Watchdog C");
  watchdog_timer(watchdog_ctrl_reinit, 100 us, error, "Watchdog D");

  ------------------------------------------------
  -- Process: clock generator
  ------------------------------------------------
  clock_generator(clk50M, C_CLK50M_PERIOD); -- Always enabled
  clock_generator(clk500M, clk500M_cnt, C_CLK500M_PERIOD);

  -- Overloaded version with enable signal as argument
  clock_generator(clk100M, clk100M_ena, C_CLK100M_PERIOD, "Clk100M");
  clock_generator(clk200M, clk200M_ena, C_CLK200M_PERIOD, "Clk200M");

  -- Overloaded versions with duty cycles
  -- percentage
  clock_generator(clk100M_percentage_60_40, clk100M_ena, C_CLK100M_PERIOD, "Clk100M_60p_duty", 60);
  clock_generator(clk100M_percentage_10_90, clk100M_ena, C_CLK100M_PERIOD, "Clk100M_10p_duty", 10);
  clock_generator(clk100M_percentage_90_10, clk100M_ena, C_CLK100M_PERIOD, "Clk100M_90p_duty", 90);
  clock_generator(clk10M_percentage_99_1, clk10M_ena, C_CLK10M_PERIOD, "Clk10M_99p_duty", 99);
  clock_generator(clk10M_percentage_1_99, clk10M_ena, C_CLK10M_PERIOD, "Clk10M_1p_duty", 1);
  clock_generator(clk10M_percentage_1_99, clk10M_ena, C_CLK10M_PERIOD, "Clk10M_1p_duty", 1);
  -- time
  clock_generator(clk100M_time_4_6, clk100M_ena, C_CLK100M_PERIOD, "Clk100M_4t_duty", 4 ns);
  clock_generator(clk100M_time_1_9, clk100M_ena, C_CLK100M_PERIOD, "Clk100M_1t_duty", 1 ns);
  clock_generator(clk100M_time_9_1, clk100M_ena, C_CLK100M_PERIOD, "Clk100M_9t_duty", 9 ns);
  clock_generator(clk10M_time_99_1, clk10M_ena, C_CLK10M_PERIOD, "Clk10M_99t_duty", 99 ns);
  clock_generator(clk10M_time_1_99, clk10M_ena, C_CLK10M_PERIOD, "Clk10M_1t_duty", 1 ns);

  -- Adjustable clock
  adjustable_clock_generator(adj_clk100M, adj_clk100M_ena, C_ADJ_CLK100M_PERIOD, "adj_clk100M", adj_clk100M_high_percentage);

  p_clk_cnt : process
    variable v_clk_cnt : natural;
    constant C_SCOPE   : string := "TB seq";
  begin
    if not p_clk_cnt_ena then
      wait until p_clk_cnt_ena;
    end if;
    v_clk_cnt := clk500M_cnt;

    loop
      wait until clk500M = '0';
      if p_clk_cnt_ena then
        check_value(clk500M_cnt, v_clk_cnt, error, "Verifying clk_cnt", C_SCOPE, ID_NEVER);
      else
        exit;
      end if;
      wait until clk500M = '1';

      if v_clk_cnt < natural'right then
        v_clk_cnt := v_clk_cnt + 1;
      else
        v_clk_cnt := 0;
      end if;
    end loop;
  end process;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_slv4                   : std_logic_vector(3 downto 0);
    variable v_slv5a                  : std_logic_vector(4 downto 0);
    variable v_slv5b                  : std_logic_vector(4 downto 0);
    variable v_slv8                   : std_logic_vector(7 downto 0);
    variable v_sl                     : std_logic;
    variable v_u4                     : unsigned(3 downto 0);
    variable v_u5a                    : unsigned(4 downto 0);
    variable v_u5b                    : unsigned(4 downto 0);
    variable v_u6                     : unsigned(5 downto 0);
    variable v_u8                     : unsigned(7 downto 0);
    variable v_u32                    : unsigned(31 downto 0);
    variable v_s4                     : signed(3 downto 0);
    variable v_s5a                    : signed(4 downto 0);
    variable v_s5b                    : signed(4 downto 0);
    variable v_s8                     : signed(7 downto 0);
    variable v_s32                    : signed(31 downto 0);
    variable v_s33                    : signed(32 downto 0);
    variable v_r                      : real;
    variable v_i                      : integer;
    variable v_ia                     : integer;
    variable v_ib                     : integer;
    variable v_t                      : time;
    variable v_b                      : boolean;
    variable v_seed1                  : positive := 1;
    variable v_seed2                  : positive := 1;
    constant C_SCOPE                  : string   := "TB seq";
    variable v_string                 : string(1 to 10);
    variable v_line                   : line;
    variable v_local_hierarchy_tree   : t_hierarchy_linked_list;
    variable v_dummy_hierarchy_node   : t_hierarchy_node(name(1 to C_HIERARCHY_NODE_NAME_LENGTH));
    variable v_alert_stop_limit       : natural;
    variable v_alert_count            : natural;
    variable v_slv_array              : t_slv_array(2 downto 0)(3 downto 0);
    variable v_slv_array_32           : t_slv_array(31 downto 0)(7 downto 0);
    variable v_slv32_array            : t_slv_array(1 to 2)(31 downto 0);
    variable v_slv256_array           : t_slv_array(1 downto 0)(255 downto 0);
    variable v_signed_array           : t_signed_array(2 downto 0)(3 downto 0);
    variable v_signed_array_32        : t_signed_array(31 downto 0)(7 downto 0);
    variable v_signed33_array         : t_signed_array(1 to 2)(32 downto 0);
    variable v_signed256_array        : t_signed_array(1 downto 0)(255 downto 0);
    variable v_unsigned_array         : t_unsigned_array(2 downto 0)(3 downto 0);
    variable v_unsigned_array_32      : t_unsigned_array(31 downto 0)(7 downto 0);
    variable v_unsigned32_array       : t_unsigned_array(1 to 2)(31 downto 0);
    variable v_unsigned256_array      : t_unsigned_array(1 downto 0)(255 downto 0);
    -- convert t_slv_array to/from t_byte_array
    variable v_idx                    : natural;
    variable v_byte                   : std_logic_vector(7 downto 0);
    variable v_byte_array             : t_byte_array(0 to 9);
    variable v_slv_array_as_byte      : t_slv_array(0 to 9)(7 downto 0);
    variable v_slv_array_as_3_byte    : t_slv_array(0 to 9)(23 downto 0);
    variable v_byte_desc_array        : t_byte_array(9 downto 0);
    variable v_slv_desc_array_as_byte : t_slv_array(9 downto 0)(7 downto 0);
    -- convert slv to/from t_byte_array
    variable v_slv                    : std_logic_vector(8 * v_byte_array'length - 1 downto 0);
    variable v_slv_not_byte_multiple  : std_logic_vector(8 * v_byte_array'length - 5 downto 0);

    --alias uvvm_status is shared_uvvm_status.simulation_successful;
    alias found_unexpected_simulation_warnings_or_worse is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
    alias found_unexpected_simulation_errors_or_worse is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;
    alias mismatch_on_expected_simulation_warnings_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse;
    alias mismatch_on_expected_simulation_errors_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse;

    -- check_value() with t_slv_array, t_signed_array, t_unsigned_array
    variable v_exp_slv_array        : t_slv_array(0 to 1)(0 to 3);
    variable v_exp_slv_array_4      : t_slv_array(0 to 3)(0 to 3);
    variable v_exp_slv_array_revers : t_slv_array(1 downto 0)(0 to 3);
    variable v_value_slv_array      : t_slv_array(2 to 3)(0 to 3);
    variable v_exp_signed_array     : t_signed_array(0 to 1)(0 to 3);
    variable v_value_signed_array   : t_signed_array(2 to 3)(0 to 3);
    variable v_exp_unsigned_array   : t_unsigned_array(0 to 1)(0 to 3);
    variable v_value_unsigned_array : t_unsigned_array(2 to 3)(0 to 3);

    -- Check clock periods in clock_generator
    procedure test_clock_period(
      signal   clock               : std_logic;
      constant clk_period          : time;
      constant clk_high_percentage : natural range 1 to 99 := 50
    ) is
      variable v_first_half_clk_period : time := clk_period * clk_high_percentage / 100;
    begin
      -- Check clock period (high and low duration)
      await_value(clock, '1', 0 ns, clk_period, error, "Clock generator, check that clock started", C_SCOPE);
      wait for v_first_half_clk_period;
      check_stable(clock, v_first_half_clk_period, error, "Clock generator, check clock high duration", C_SCOPE);
      wait for 0 ns;
      check_value(clock, '0', error, "Clock generator. Check high to low transition", C_SCOPE);
      wait for clk_period - v_first_half_clk_period;
      check_stable(clock, clk_period - v_first_half_clk_period, error, "Clock generator, check clock low duration", C_SCOPE);
      wait for 0 ns;
      check_value(clock, '1', error, "Clock generator. Check low to high transition", C_SCOPE);
    end procedure;

    -- Check clock duty cycle in clock_generator
    procedure test_clock_duty_cycle(
      signal   clock         : std_logic;
      constant clk_period    : time;
      constant clk_high_time : time
    ) is
    begin
      check_value(clk_high_time < clk_period, TB_ERROR, "test_clock_duty_cycle: parameter clk_high_time must be lower than parameter clk_period!", C_TB_SCOPE_DEFAULT, ID_NEVER);
      -- Check clock period (high and low duration)
      await_value(clock, '1', 0 ns, clk_period, error, "Clock generator, check that clock started", C_SCOPE);
      wait for clk_high_time;
      check_stable(clock, clk_high_time, error, "Clock generator, check clock high duration", C_SCOPE);
      wait for 0 ns;
      check_value(clock, '0', error, "Clock generator. Check high to low transition", C_SCOPE);
      wait for clk_period - clk_high_time;
      check_stable(clock, clk_period - clk_high_time, error, "Clock generator, check clock low duration", C_SCOPE);
      wait for 0 ns;
      check_value(clock, '1', error, "Clock generator. Check low to high transition", C_SCOPE);
    end procedure;

    --  Check the clock enable and clock period in clock_generator
    procedure test_clock_enable_and_period(
      signal   clock      : std_logic;
      signal   clock_ena  : inout boolean;
      constant clk_period : time
    ) is
    begin
      -- Check that it is quiet when disabled
      clock_ena <= false;
      wait for 10 * clk_period;
      check_stable(clock, 9 * clk_period, error, "Check that clock is quiet when disabled", C_SCOPE);

      -- While the clock is enabled, test the clk period
      clock_ena <= true;
      test_clock_period(clock, clk_period);

      -- Check disabling the clock
      clock_ena <= false;
      wait for clk_period + 100 ns;
      check_stable(clock, 100 ns, error, "Check that clock actually stopped", C_SCOPE);
    end procedure;

    procedure test_adjustable_clock_error_handling(
      signal   adj_clock                   : std_logic;
      signal   adj_clk100M_high_percentage : inout natural range 0 to 100;
      signal   adj_clk100M_ena             : inout boolean;
      constant adj_clk_period              : time
    ) is
    begin
      -- Set high_percentage to illegal value 0
      adj_clk100M_ena             <= false;
      adj_clk100M_high_percentage <= 0;
      wait for 0 ns;
      adj_clk100M_ena             <= true;
      wait for 0 ns;                    --adj_clk_period;
      adj_clk100M_ena             <= false;
      wait for adj_clk_period;

      -- Set high_percentage to illegal value 100
      adj_clk100M_high_percentage <= 100;
      wait for 0 ns;
      adj_clk100M_ena             <= true;
      wait for 0 ns;
      adj_clk100M_ena             <= false;
      wait for adj_clk_period;

      -- Set high_percentage to legal value 50
      adj_clk100M_high_percentage <= 50;
      wait for 0 ns;
      adj_clk100M_ena             <= true;
      wait for adj_clk_period;
      adj_clk100M_ena             <= false;

    end procedure;

    procedure test_adjustable_clock_enable_and_period(
      signal   adj_clock                   : std_logic;
      signal   adj_clk100M_high_percentage : inout natural range 0 to 100;
      signal   adj_clk100M_ena             : inout boolean;
      constant adj_clk_period              : time
    ) is
      variable v_high_period : time;
      variable v_low_period  : time;
    begin
      -- Check that clock is quiet when disabled
      adj_clk100M_ena <= false;
      wait for 10 * adj_clk_period;
      check_stable(adj_clock, 9 * adj_clk_period, error, "Check that adjustable clock is quiet when disabled", C_SCOPE);

      -- Set 50/50 duty cycle, test the clk period
      adj_clk100M_high_percentage <= 50;
      adj_clk100M_ena             <= true;
      v_high_period               := adj_clk_period / 2; -- 50% high duration
      v_low_period                := adj_clk_period - v_high_period; -- 50% low duration
      wait for v_high_period;
      check_value(adj_clock'last_event, v_high_period, error, "Checking rising edge.", C_SCOPE);
      check_value(adj_clock, '1', error, "Check that adjustable clock is set to high during the period.", C_SCOPE);
      check_stable(adj_clock, v_high_period, error, "Check adjustable clock is stable during high period.", C_SCOPE);
      wait for v_low_period;
      check_value(adj_clock'last_event, v_low_period, error, "Checking falling edge.", C_SCOPE);
      check_value(adj_clock, '0', error, "Check that adjustable clock is set to low during the period.", C_SCOPE);
      check_stable(adj_clock, v_low_period, error, "Check adjustable clock is stable during low period.", C_SCOPE);

      adj_clk100M_ena <= false;
      wait for 2 * adj_clk_period;

      -- Set 25/75 duty cycle, test the clk period
      adj_clk100M_high_percentage <= 25;
      adj_clk100M_ena             <= true;
      v_high_period               := 25 * adj_clk_period / 100; -- 25% high duration
      v_low_period                := adj_clk_period - v_high_period; -- 75% low duration
      wait for v_high_period;
      check_value(adj_clock'last_event, v_high_period, error, "Checking rising edge.", C_SCOPE);
      check_value(adj_clock, '1', error, "Check that adjustable clock is set to high during the period.", C_SCOPE);
      check_stable(adj_clock, v_high_period, error, "Check adjustable clock is stable during high period.", C_SCOPE);
      wait for v_low_period;
      check_value(adj_clock'last_event, v_low_period, error, "Checking falling edge.", C_SCOPE);
      check_value(adj_clock, '0', error, "Check that adjustable clock is set to low during the period.", C_SCOPE);
      check_stable(adj_clock, v_low_period, error, "Check adjustable clock is stable during low period.", C_SCOPE);

      adj_clk100M_ena <= false;
      wait for 2 * adj_clk_period;

      -- Set 99/1 duty cycle, test the clk period
      adj_clk100M_high_percentage <= 99;
      adj_clk100M_ena             <= true;
      v_high_period               := 99 * adj_clk_period / 100; -- 99% high duration
      v_low_period                := adj_clk_period - v_high_period; -- 1% low duration
      wait for v_high_period;
      check_value(adj_clock'last_event, v_high_period, error, "Checking rising edge.", C_SCOPE);
      check_value(adj_clock, '1', error, "Check that adjustable clock is set to high during the period, high: " & to_string(v_high_period) & ", low: " & to_string(v_low_period), C_SCOPE);
      check_stable(adj_clock, v_high_period, error, "Check adjustable clock is stable during high period, high: " & to_string(v_high_period) & ", low: " & to_string(v_low_period), C_SCOPE);
      wait for v_low_period;
      check_value(adj_clock'last_event, v_low_period, error, "Checking falling edge.", C_SCOPE);
      check_value(adj_clock, '0', error, "Check that adjustable clock is set to low during the period, high: " & to_string(v_high_period) & ", low: " & to_string(v_low_period), C_SCOPE);
      check_stable(adj_clock, v_low_period, error, "Check adjustable clock is stable during low period, high: " & to_string(v_high_period) & ", low: " & to_string(v_low_period), C_SCOPE);

      adj_clk100M_ena <= false;
    end procedure;

    -- Check the simulation_success update behavior
    procedure test_uvvm_status_simulation_successful(
      constant test_alert_type : t_alert_level
    ) is
      constant C_FAIL_STATUS_STRING        : string := "Expected that shared_uvvm_status indicate fail.";
      constant C_SUCCESS_STATUS_STRING     : string := "Expected that shared_uvvm_status indicate success.";
      constant C_MISMATCH_STATUS_STRING    : string := "Expected that shared_uvvm_status indicate mismatch.";
      constant C_NO_MISMATCH_STATUS_STRING : string := "Expected that shared_uvvm_status indicate no mismatch.";
    begin
      -- Update TB alert stop limit
      if (test_alert_type = TB_ERROR) or (test_alert_type = failure) or (test_alert_type = TB_FAILURE) then
        v_alert_stop_limit := get_alert_stop_limit(test_alert_type);
        set_alert_stop_limit(test_alert_type, v_alert_stop_limit + 2);
      end if;

      -- Set alert
      alert(test_alert_type, "Setting " & to_string(test_alert_type) & " alert for shared_uvvm_status simulation_successful status test.");

      -- Check that uvvm_status.simulation_successful indicate fail
      case test_alert_type is
        when warning =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when TB_WARNING =>
          ---check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when error =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_ERROR =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when failure =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_FAILURE =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when others =>
          null;
      end case;

      -- Update expected alert
      if (test_alert_type /= NO_ALERT) then
        increment_expected_alerts(test_alert_type, 1);
      end if;

      -- Check that uvvm_status indicate simulation success
      --check_value(uvvm_status, 1, ERROR, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);

      -- Increment expected alert
      if (test_alert_type /= NO_ALERT) then
        increment_expected_alerts(test_alert_type, 1);
      end if;

      -- Check that uvvm_status.simulation_successful indicate fail
      case test_alert_type is
        when warning =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when TB_WARNING =>
          ---check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when error =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_ERROR =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when failure =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_FAILURE =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when others =>
          null;
      end case;

      -- Update alert
      alert(test_alert_type, "Setting " & to_string(test_alert_type) & " alert for shared_uvvm_status simulation_successful status test.");

      -- Check that uvvm_status indicate simulation success
      --check_value(uvvm_status, 1, ERROR, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    randomise(12, 14);
    randomize(14, 12);
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    set_alert_stop_limit(warning, 0);
    set_alert_stop_limit(error, 0);     -- 0 = Never stop
    wait for 1 ns;

    if GC_TESTCASE = "basic_log_alert" then
      --------------------------------------------------------------------------------------
      -- Verifying logging and alerts
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying logging and alerts", "");
      log(ID_LOG_HDR, "My Log header ");
      log(ID_BFM, "My short message", "My scope");
      alert(note, "my_msg dasdsa dasd as dad ad asd asd as das dasd adas dasd asda sdas das das das dsa dsa das das das das das das dasdasdasd asd", "my_scope");
      log(ID_BFM, "My long message  qqqqq w wwwww ee eee r rr r r t tt ttttttt y yyyyyyyy uuuuuuuu iii ii ii o o ooo o o ppppppp  aaaaaaaa              ssss ddddddffffff ffffff gggggg hhhhhh jjjjj" & LF & "ekstra", "My long scope............");
      log(ID_BFM, "My multiline message " & LF & "qqqqq w wwwww ee eee r rr r r t" & LF & "11 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " & "extra" & LF & "lkkl fdafd fdsf sdfsdfsd f sdfsd f ds fsd fsdfsd f sdf sdf sdf dfsdfdsfsdf ds f dsf ds fsd fsd fsd fdsf sdf sdfsdf dsfds f sdfsdfsdf sdf dsf  BSN\nBSN \b fsd fs" & LF & "fdfdf sdfsd fsdf sd fds fsd fsd fs df sdf sdf sdf sd fsd fsdfsd fsdfsd fsd fsd f sdf sdf sd f sdf sdf d f df sdf ds fsd f sdf dsf ", "My .........");
      alert(error, "my_msg dasdas das dasdasdasd as das da sd asdas dasdasd  dasdasdsdasdas das d asd as das das das das dasdasdas das das d as das das dasd", "my_scope");
      log(ID_BFM, "Kort multiline" & LF & "ddasdadad" & LF & "daddfad ", "");
      log("Check various versions of linefeed (pre, post, only)");
      log("\n Pre, followed by blank");
      log("\nPre, followed by char");
      log("Post, preceeded by blank \n");
      log("Post, preceeded by char\n");
      log("Next is single linefeed only");
      log("\n");
      log("Linefeeds completed. Please check above");
      log("");
      log("1");
      log("Above two lines: First empty string, then single char.");

      --------------------------------------------------------------------------------------
      -- Verifying shared_uvvm_status.simulation_successful
      --   t_alert_type (NO_ALERT, NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK, ERROR, TB_ERROR, FAILURE, TB_FAILURE)
      --------------------------------------------------------------------------------------
      check_value(found_unexpected_simulation_warnings_or_worse, 1, error, "Alert check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse expected and actual mismatch");
      check_value(found_unexpected_simulation_errors_or_worse, 1, error, "Alert check shared_uvvm_status.found_unexpected_simulation_errors_or_worse expected and actual mismatch");
      increment_expected_alerts(error, 1);
      increment_expected_alerts(note, 1);
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, "Alert check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse correctly updated");
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, "Alert check shared_uvvm_status.found_unexpected_simulation_errors_or_worse correctly updated");

      -- Check all alert level types
      for test_alert in uvvm_util.types_pkg.t_alert_level loop
        test_uvvm_status_simulation_successful(test_alert);
      end loop;

    elsif GC_TESTCASE = "enable_disable_log_msg" then
      --------------------------------------------------------------------------------------
      -- Verifying disable_log_msg and enable_log_msg
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying disable_log_msg and enable_log_msg", "");
      log(ID_BFM, "ID_BFM enabled", "My scope");
      check_value(is_log_msg_enabled(ID_BFM), true, error, "check ID_BFM enabled");
      disable_log_msg(ID_BFM);
      check_value(is_log_msg_enabled(ID_BFM), false, error, "check ID_BFM disabled");
      check_value(is_log_msg_enabled(ID_LOG_HDR), true, error, "check ID_LOG_HDR enabled");
      log(ID_BFM, "ID_BFM disabled. Should not be written", "My scope");
      enable_log_msg(ID_BFM);
      log(ID_BFM, "ID_BFM re-enabled. Should be written", "My scope");

      log("Verifying disable_log_msg() with QUIET. Next line should be empty.");
      disable_log_msg(ID_BFM, "THIS MESSAGE SHOULD NOT BE VISIBLE", QUIET);
      log(ID_BFM, "This shall be invisible");
      log(ID_SEQUENCER, "This shall be visible");
      enable_log_msg(ID_BFM, QUIET);
      log("This log message shall be visible");

      log("Verifying that attempting to enable ID_NEVER triggers an alert.");
      increment_expected_alerts(TB_WARNING, 1);
      enable_log_msg(ID_NEVER, "This shall trigger a TB_WARNING.");

      log("Testing ID_LOG_MSG_CTRL and ALL_MESSAGES");
      disable_log_msg(ALL_MESSAGES);
      log(ID_SEQUENCER, "This should not be visible");
      enable_log_msg(ID_SEQUENCER);
      log(ID_SEQUENCER, "This should be visible (and enabling of ID_SEQUENCER should be visible)");

      log("Testing ID_LOG_MSG_CTRL and ALL_MESSAGES with QUIET");
      disable_log_msg(ALL_MESSAGES);
      log(ID_SEQUENCER, "This should not be visible");
      enable_log_msg(ID_SEQUENCER, QUIET);
      log(ID_SEQUENCER, "This should be visible (and enabling of ID_SEQUENCER should not be visible)");

    elsif GC_TESTCASE = "check_value" then
      --------------------------------------------------------------------------------------
      -- Verifying check_value
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_value", "");
      -- Boolean
      v_b     := check_value(14 > 6, error, "A must be higher than B, OK", C_SCOPE);
      check_value(v_b, error, "check_value with return value shall return true when OK", C_SCOPE);
      -- SLV
      v_slv5a := "01111";
      v_slv5b := "01111";
      check_value(v_slv5a, v_slv5b, error, "My msg1, OK", C_SCOPE);
      v_slv5b := "01110";
      check_value(v_slv5a, v_slv5b, error, "My msg2, Fail", C_SCOPE);
      check_value(std_logic_vector'("100101"), "10010-", error, "My msg3a, OK", C_SCOPE);
      check_value(std_logic_vector'("100101"), "100101", error, "My msg3b, OK", C_SCOPE);
      v_b     := check_value(std_logic_vector'("100101"), "100100", error, "My msg3c, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", error, "My msg (none), OK", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", error, "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "10010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "111010", error, "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("110010"), "111010", error, "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("110010"), "111010", error, "My msg BIN, Fail", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "10010", error, "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "110010", error, "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "0010010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0010010"), "010010", error, "My msg BIN, OK", C_SCOPE, BIN);

      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("0000010010"), "000010-10", error, "My msg HEX, OK", C_SCOPE, HEX);

      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg BIN, AS_IS, OK", C_SCOPE, BIN, AS_IS);
      check_value(std_logic_vector'("0000010010"), "000010010", error, "My msg HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "000010-10", error, "My msg HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "00--10-10", error, "My msg dontcare-in-extended-width HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_STD, error, "My msg dontcare-in-extended-width HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_EXACT, error, "My msg dontcare-in-extended-width HEX, AS_IS, Fail", C_SCOPE, HEX, AS_IS);

      -- MATCH_STD_INCL_Z
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("01Z0"), "----", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z with don't care", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("01Z0"), "01--", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z with don't care", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("01Z0"), "01-1", MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z with don't care, FAIL", C_SCOPE, HEX, AS_IS);
      increment_expected_alerts(error, 1);

      -- MATCH_STD_INCL_ZXUW
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("000X0X00X0"), "000X0X00X0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("000U0U00U0"), "000U0U00U0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("000W0W00W0"), "000W0W00W0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0Z0X0U00W0"), "0Z0X0U00W0", MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);

      check_value(std_logic_vector'("0000010010"), "0000010010", error, "My msg HEX_BIN_IF_INVALID, OK", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("0000011111"), "0000010010", error, "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("00000U00U0"), "0000010010", error, "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      increment_expected_alerts(error, 2);

      -- wide vector
      check_value(slv128, slv128, error, "Test wide vector, HEX, OK", C_SCOPE, HEX, AS_IS);
      check_value(slv128, slv128, error, "Test wide vector, DEC, OK", C_SCOPE, DEC, AS_IS);

      -- boolean
      -- As function
      v_b := check_value(true, true, error, "Boolean check true vs true, OK");
      check_value(v_b, error, "check_value should return true");
      v_b := check_value(true, false, error, "Boolean check true vs false, Fail");
      check_value(not v_b, error, "check_value should return false");
      v_b := check_value(false, true, error, "Boolean check false vs true, Fail");
      check_value(not v_b, error, "check_value should return false");
      v_b := check_value(false, false, error, "Boolean check false vs false, OK");
      check_value(v_b, error, "check_value should return true");
      increment_expected_alerts(error, 2);

      -- As procedure
      check_value(true, true, error, "Boolean check true vs true, OK");
      check_value(true, false, error, "Boolean check true vs false, Fail");
      check_value(false, true, error, "Boolean check false vs true, Fail");
      check_value(false, false, error, "Boolean check false vs false, OK");
      increment_expected_alerts(error, 2);

      -- Unsigned
      v_u5a := "01100";
      v_u5b := "11100";
      v_u6  := "101100";
      check_value(v_u5a, v_u5a, error, "My msg U, BIN, AS_IS, OK", C_SCOPE, BIN);
      check_value(v_u5a, v_u5b, error, "My msg U, BIN, AS_IS, Fail", C_SCOPE, BIN);
      v_b   := check_value(v_u5a, v_u6, error, "My msg U, BIN, AS_IS, Fail", C_SCOPE, BIN);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- signed
      v_s8 := "10101100";
      check_value(v_s8, v_s8, error, "My msg S, BIN, AS_IS, OK", C_SCOPE, BIN);
      v_b  := check_value(v_s8, "10101101", error, "My msg S, BIN, AS_IS, Fail", C_SCOPE, BIN);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- Integer
      v_ia := 5;
      v_ib := 23456;
      check_value(v_ia, 5, error, "My msg I, OK", C_SCOPE);
      check_value(v_ia, 12345, error, "My msg I, Fail", C_SCOPE);
      v_b  := check_value(v_ia, v_ib, warning, "My msg I, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- Real
      v_r := 5222.01;
      check_value(v_r, 5222.01, error, "My msg I, OK", C_SCOPE);
      v_b := check_value(v_r, 1421.02, warning, "My msg I, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);

      -- Std_logic
      v_b := check_value('1', '1', warning, "My msg SL, OK", C_SCOPE);
      check_value(v_b, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_b := check_value('1', '0', warning, "My msg SL, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value('0', '-', warning, "My msg SL, OK, use default match_strictness", C_SCOPE);
      check_value('1', '-', MATCH_STD, warning, "My msg SL, OK", C_SCOPE);
      check_value('L', '0', MATCH_STD, warning, "My msg SL, OK", C_SCOPE);
      check_value('1', 'H', MATCH_EXACT, warning, "My msg SL, Fail", C_SCOPE);
      check_value('-', '1', MATCH_EXACT, warning, "My msg SL, Fail", C_SCOPE);
      -- MATCH_STD_INCL_Z
      check_value('Z', 'Z', MATCH_STD_INCL_Z, error, "Check MATCH_STD_INCL_Z", C_SCOPE);
      -- MATCH_STD_INCL_ZXUW
      check_value('Z', 'Z', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('X', 'X', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('U', 'U', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('W', 'W', MATCH_STD_INCL_ZXUW, error, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);

      -- time
      v_t := 15 ns;
      v_b := check_value(15 ns, 74 ps, warning, "My msg I, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(15 ns, 14 ns, warning, "My msg I, Fail", C_SCOPE);
      check_value(v_t, 15 ns, warning, "My msg I, OK", C_SCOPE);
      check_value(v_t, 15.0 ns, warning, "My msg I, OK", C_SCOPE);
      check_value(v_t, 15000 ps, warning, "My msg I, OK", C_SCOPE);
      check_value(v_t, 74 ps, warning, "My msg I, Fail", C_SCOPE);

      increment_expected_alerts(error, 12);
      increment_expected_alerts(warning, 8);

      -- Check UVVM successful status
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, "Check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse correctly updated");
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, "Check shared_uvvm_status.found_unexpected_simulation_errors_or_worse correctly updated");

      -- Check value reporting with padding of short SLV
      increment_expected_alerts(tb_warning, 3);
      check_value(std_logic_vector'("00110010"), std_logic_vector'("0010"), tb_warning, "Check padding of different check_value SLV lengths (actual>expected)");
      check_value(std_logic_vector'("1010"), std_logic_vector'("00110010"), tb_warning, "Check padding of different check_value SLV lengths (actual<expected)");
      check_value(std_logic_vector'("00001010"), std_logic_vector'("00110010"), tb_warning, "Check padding of different check_value SLV lengths (actual=expected)");

      ----------------------------------------------------------------------------
      -- Check value with unequal array indexes for t_slv/signed/unsigned_array
      ----------------------------------------------------------------------------
      -- Verify check_value array index conversion
      v_exp_slv_array(0)   := x"A";
      v_exp_slv_array(1)   := x"B";
      v_value_slv_array(2) := x"A";
      v_value_slv_array(3) := x"B";
      check_value(v_value_slv_array, v_exp_slv_array, tb_warning, "check_value with t_slv_array of different array indexes");

      v_exp_signed_array(0)   := x"C";
      v_exp_signed_array(1)   := x"D";
      v_value_signed_array(2) := x"C";
      v_value_signed_array(3) := x"D";
      check_value(v_value_signed_array, v_exp_signed_array, tb_warning, "check_value with t_signed_array of different array indexes");

      v_exp_unsigned_array(0)   := x"E";
      v_exp_unsigned_array(1)   := x"F";
      v_value_unsigned_array(2) := x"E";
      v_value_unsigned_array(3) := x"F";
      check_value(v_value_unsigned_array, v_exp_unsigned_array, tb_warning, "check_value with t_unsigned_array of different array indexes");

      -- Verify check_value with array conversion catch errors
      increment_expected_alerts(tb_warning, 3);
      v_exp_slv_array(1)      := x"C";
      v_exp_signed_array(1)   := x"A";
      v_exp_unsigned_array(1) := x"D";
      check_value(v_value_slv_array, v_exp_slv_array, tb_warning, "2check_value with t_slv_array of different array indexes");
      check_value(v_value_signed_array, v_exp_signed_array, tb_warning, "2check_value with t_signed_array of different array indexes");
      check_value(v_value_unsigned_array, v_exp_unsigned_array, tb_warning, "2check_value with t_unsigned_array of different array indexes");

      log(ID_SEQUENCER, "Incrementing alert_stop_limit(TB_ERROR) for 1 provoked tb_error to pass in simulation.", C_SCOPE);
      set_alert_stop_limit(TB_ERROR, 2);

      -- verify warning with arrays of different directions and unequal lengths
      v_exp_slv_array        := (others => "1010");
      v_exp_slv_array_4      := (others => "1010");
      v_exp_slv_array_revers := (others => "1010");
      increment_expected_alerts(tb_error, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_4, tb_warning, "check_value with different array lenghts");
      increment_expected_alerts(tb_warning, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_revers, tb_warning, "check_value with different array directions");

      report_check_counters(VOID);

    elsif GC_TESTCASE = "check_stable" then
      --------------------------------------------------------------------------------------
      -- Verifying check_stable
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_stable", "");
      bol  <= true;
      slv8 <= (others => '1');
      u8   <= (others => '1');
      s8   <= (others => '1');
      i    <= 14;
      r    <= 1337.14;
      sl   <= '1';
      wait for 10 ns;
      check_stable(bol, 9 ns, error, "Stable boolean OK", C_SCOPE);
      check_stable(slv8, 9 ns, error, "Stable slv OK", C_SCOPE);
      check_stable(u8, 9 ns, error, "Stable unsigned OK", C_SCOPE);
      check_stable(s8, 9 ns, error, "Stable signed OK", C_SCOPE);
      check_stable(i, 9 ns, error, "Stable integer OK", C_SCOPE);
      check_stable(r, 9 ns, error, "Stable real OK", C_SCOPE);
      check_stable(sl, 9 ns, error, "Stable std_logic OK", C_SCOPE);
      check_stable(bol, 11 ns, error, "Stable boolean Fail", C_SCOPE);
      check_stable(slv8, 11 ns, error, "Stable slv Fail", C_SCOPE);
      check_stable(u8, 11 ns, error, "Stable unsigned Fail", C_SCOPE);
      check_stable(s8, 11 ns, error, "Stable signed Fail", C_SCOPE);
      check_stable(i, 11 ns, error, "Stable integer Fail", C_SCOPE);
      check_stable(r, 11 ns, error, "Stable real Fail", C_SCOPE);
      check_stable(sl, 11 ns, error, "Stable std_logic Fail", C_SCOPE);

      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 20 ns, error, "Stable slv OK", C_SCOPE);
      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 30 ns, error, "Stable slv OK", C_SCOPE);
      increment_expected_alerts(error, 7);

      report_check_counters(VOID);

    elsif GC_TESTCASE = "await_stable" then
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_stable");
      --------------------------------------------------------------------------------------

      --
      -- await_stable(boolean)
      --

      -- FROM_NOW, FROM_NOW
      bol <= transport bol after 30 ns; -- No 'Event
      await_stable(bol, 50 ns, FROM_NOW, 51 ns, FROM_NOW, error, "bol: No 'event, Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      bol <= transport not bol after 30 ns;
      await_stable(bol, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "bol: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      bol <= transport not bol after 30 ns;
      await_stable(bol, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "bol: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(bol, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "bol: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(bol, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "bol: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "bol: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      bol <= not bol;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "bol: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      bol <= not bol;
      wait for 11 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "bol: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      bol <= not bol;
      wait for 10 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "bol: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      bol <= not bol;
      wait for 100 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "bol: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      bol <= not bol;
      wait for 100 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "bol: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "bol: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "bol: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "bol: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(std_logic)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "sl: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "sl: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      await_stable(sl, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "sl: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(sl, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "sl: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(sl, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "sl: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      sl <= not sl;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      sl <= not sl;
      wait for 11 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "sl: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "sl: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "sl: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(std_logic_vector)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "slv8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "slv8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      await_stable(slv8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "slv8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(slv8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "slv8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(slv8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "slv8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      slv8 <= not slv8;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      slv8 <= not slv8;
      wait for 11 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "slv8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "slv8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "slv8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(unsigned)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(u8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "u8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      u8 <= transport not u8 after 30 ns;
      await_stable(u8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "u8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      u8 <= transport not u8 after 30 ns;
      await_stable(u8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "u8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(u8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "u8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(u8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "u8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "u8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      u8 <= not u8;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "u8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      u8 <= not u8;
      wait for 11 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "u8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      u8 <= not u8;
      wait for 10 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "u8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      u8 <= not u8;
      wait for 100 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "u8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      u8 <= not u8;
      wait for 100 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "u8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "u8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "u8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "u8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(signed)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(s8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "s8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      s8 <= transport not s8 after 30 ns;
      await_stable(s8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "s8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      s8 <= transport not s8 after 30 ns;
      await_stable(s8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "s8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(s8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "s8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(s8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "s8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "s8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      s8 <= not s8;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "s8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      s8 <= not s8;
      wait for 11 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "s8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      s8 <= not s8;
      wait for 10 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "s8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      s8 <= not s8;
      wait for 100 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "s8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      s8 <= not s8;
      wait for 100 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "s8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "s8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "s8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "s8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(integer)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(i, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "i: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      i <= transport i + 1 after 30 ns;
      await_stable(i, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "i: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      i <= transport i + 1 after 30 ns;
      await_stable(i, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "i: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(i, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "i: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(i, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "i: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "i: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      i <= i + 1;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "i: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      i <= i + 1;
      wait for 11 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "i: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      i <= i + 1;
      wait for 10 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "i: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      i <= i + 1;
      wait for 100 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "i: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      i <= i + 1;
      wait for 100 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "i: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "i: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "i: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "i: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(real)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(r, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "r: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      r <= transport r + 1.0 after 30 ns;
      await_stable(r, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "r: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      r <= transport r + 1.0 after 30 ns;
      await_stable(r, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "r: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(r, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "r: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(r, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "r: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "r: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      r <= r + 1.0;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "r: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      r <= r + 1.0;
      wait for 11 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "r: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      r <= r + 1.0;
      wait for 10 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "r: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      r <= r + 1.0;
      wait for 100 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "r: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      r <= r + 1.0;
      wait for 100 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "r: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "r: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "r: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "r: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

    elsif GC_TESTCASE = "await_change" then
      --------------------------------------------------------------------------------------
      -- Verifying await_change
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_change");
      bol <= transport false after 2 ns;
      await_change(bol, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      bol <= transport true after 3 ns;
      await_change(bol, 3 ns, 5 ns, error, "Change within time window 1, OK", C_SCOPE);
      bol <= transport false after 4 ns;
      await_change(bol, 3 ns, 5 ns, error, "Change within time window 2, OK", C_SCOPE);
      bol <= transport true after 5 ns;
      await_change(bol, 3 ns, 5 ns, error, "Change within time window 3, OK", C_SCOPE);
      await_change(bol, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      sl <= transport '0' after 2 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      sl <= transport '1' after 3 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '0' after 4 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 5 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      slv8 <= transport "00000001" after 2 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      slv8 <= transport "00000010" after 3 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change within time window 2, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change within time window 3, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      u8 <= transport "00000001" after 2 ns;
      await_change(u8, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      u8 <= transport "00000010" after 3 ns;
      await_change(u8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000011" after 4 ns;
      await_change(u8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000100" after 5 ns;
      await_change(u8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000101" after 6 ns;
      await_change(u8, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      s8 <= transport "00000001" after 2 ns;
      await_change(s8, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      s8 <= transport "00000010" after 3 ns;
      await_change(s8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000011" after 4 ns;
      await_change(s8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000100" after 5 ns;
      await_change(s8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000101" after 6 ns;
      await_change(s8, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      i <= transport 1 after 2 ns;
      await_change(i, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      i <= transport 2 after 3 ns;
      await_change(i, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      i <= transport 3 after 4 ns;
      await_change(i, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      i <= transport 4 after 5 ns;
      await_change(i, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      i <= transport 5 after 6 ns;
      await_change(i, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      r <= transport 1.0 after 2 ns;
      await_change(r, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      r <= transport 2.0 after 3 ns;
      await_change(r, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      r <= transport 3.0 after 4 ns;
      await_change(r, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      r <= transport 4.0 after 5 ns;
      await_change(r, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      r <= transport 5.0 after 6 ns;
      await_change(r, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

    --------------------------------------------------------------------------------------
    -- Verifying await_stable
    --------------------------------------------------------------------------------------
    -- log(ID_LOG_HDR, "Verifying await_stable");
    -- sl <= '0';
    -- wait for 10 ns;
    -- await_stable(sl, 20 ns, 11 ns, ERROR, "Stable, OK", C_SCOPE);
    -- sl <= '0';
    -- wait for 10 ns;
    -- await_stable(sl, 20 ns, 9 ns, ERROR, "Stable timeout, Fail", C_SCOPE);
    -- increment_expected_alerts(ERROR);

    elsif GC_TESTCASE = "await_value" then
      --------------------------------------------------------------------------------------
      -- Verifying await_value
      --------------------------------------------------------------------------------------
      -- await_value : SLV
      log(ID_LOG_HDR, "Verifying await_value");
      slv8 <= "00000000";
      slv8 <= transport "00000001" after 2 ns;
      await_value(slv8, "00000001", 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00000010" after 3 ns;
      await_value(slv8, "00000010", 3 ns, 5 ns, error, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "000000011", 3 ns, 5 ns, error, "Change within time window 2, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_value(slv8, "0000100", 3 ns, 5 ns, error, "Change within time window 3, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_value(slv8, "00000101", 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      slv8 <= transport "00000110" after 1 ns;
      slv8 <= transport "00000111" after 2 ns;
      slv8 <= transport "00001000" after 4 ns;
      await_value(slv8, "00001000", 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      await_value(slv8, "100010011", 3 ns, 5 ns, error, "Different width, Fail", C_SCOPE);
      slv8 <= transport "00001001" after 0 ns;
      await_value(slv8, "00001001", 0 ns, 1 ns, error, "Changed immediately, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00001111" after 0 ns;
      slv8 <= transport "10000000" after 1 ns;
      await_value(slv8, "00001111", 0 ns, 0 ns, error, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(slv8, "00001111", 0 ns, 1 ns, error, "Val=exp already, No signal'event. OK. Log in HEX", C_SCOPE, HEX);
      await_value(slv8, "00001111", 0 ns, 2 ns, error, "Val=exp already, No signal'event. OK. Log in DECimal", C_SCOPE, DEC);
      slv8 <= "10000000";
      wait for 1 ns;
      await_value(slv8, "10000000", 0 ns, 0 ns, error, "Val=exp already, No signal'event. OK. ", C_SCOPE, HEX);
      await_value(slv8, "10000000", 1 ns, 2 ns, error, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE, HEX);

      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "00000011", MATCH_EXACT, 3 ns, 5 ns, error, "Change within time window 2, exact match, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "10110001" after 4 ns;
      await_value(slv8, "10--0001", MATCH_STD, 3 ns, 5 ns, error, "Change within time window 2, STD match, OK", C_SCOPE);

      -- MATCH_STD_INCL_Z
      wait for 10 ns;
      slv8 <= transport "1011000Z" after 4 ns;
      await_value(slv8, "1011000Z", MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Change within time window 3, STD match including Z, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "Z011000Z" after 4 ns;
      await_value(slv8, "1011000Z", MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Different values, STD match including Z, Fail", C_SCOPE);

      -- MATCH_STD_INCL_ZXUW
      wait for 10 ns;
      slv8 <= transport "1W1U0X0Z" after 4 ns;
      await_value(slv8, "1W1U0X0Z", MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window 3, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "1W110X0Z" after 4 ns;
      await_value(slv8, "1W1U1X0Z", MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 1", C_SCOPE);

      increment_expected_alerts(error, 6);

      -- await_value : unsigned
      u8 <= "00000000";
      u8 <= transport "00000001" after 2 ns;
      await_value(u8, "00000001", 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      u8 <= transport "00000010" after 3 ns;
      await_value(u8, "00000010", 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000101" after 6 ns;
      await_value(u8, "00000101", 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      u8 <= transport "00001111" after 0 ns;
      u8 <= transport "10000000" after 1 ns;
      await_value(u8, "00001111", 0 ns, 0 ns, error, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(u8, "00001111", 0 ns, 0 ns, error, "Changed immediately, OK. Log in HEX", C_SCOPE, HEX);
      await_value(u8, "00001111", 0 ns, 2 ns, error, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);
      increment_expected_alerts(error, 2);

      -- await_value : signed
      s8 <= "00000000";
      s8 <= transport "00000001" after 2 ns;
      await_value(s8, "00000001", 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      s8 <= transport "00000010" after 3 ns;
      await_value(s8, "00000010", 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000101" after 6 ns;
      await_value(s8, "00000101", 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      s8 <= transport "00001111" after 0 ns;
      await_value(s8, "00001111", 0 ns, 1 ns, error, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);
      increment_expected_alerts(error, 2);

      -- await_value : boolean
      bol <= false;
      bol <= transport true after 2 ns;
      await_value(bol, true, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      bol <= transport false after 3 ns;
      await_value(bol, false, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      bol <= transport true after 6 ns;
      await_value(bol, true, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      bol <= transport false after 0 ns;
      await_value(bol, false, 0 ns, 1 ns, error, "Changed immediately, OK. ", C_SCOPE);
      bol <= true;
      wait for 0 ns;
      bol <= transport false after 1 ns;
      await_value(bol, true, 0 ns, 2 ns, error, "Val=exp already, No signal'event. OK. ", C_SCOPE);
      bol <= true;
      wait for 0 ns;
      await_value(bol, true, 1 ns, 2 ns, error, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);

      increment_expected_alerts(error, 3);

      -- await_value : std_logic
      sl <= '0';
      sl <= transport '1' after 2 ns;
      await_value(sl, '1', 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, '0', 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_value(sl, '1', 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 0 ns;
      wait for 0 ns;
      sl <= transport '1' after 1 ns;
      await_value(sl, '0', 0 ns, 2 ns, error, "Changed immediately, OK. ", C_SCOPE);
      sl <= '1';
      wait for 10 ns;
      await_value(sl, '1', 1 ns, 2 ns, error, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'L' after 3 ns;
      await_value(sl, '0', MATCH_STD, 3 ns, 5 ns, error, "Change within time window to weak, expecting forced, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'H', MATCH_STD, 3 ns, 5 ns, error, "Change within time window to forced, expecting weak, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, 'L', MATCH_EXACT, 3 ns, 5 ns, error, "Change within time window to forced, expecting weak, FAIL", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'H' after 3 ns;
      await_value(sl, '1', MATCH_EXACT, 3 ns, 5 ns, error, "Change within time window to weak, expecting forced, FAIL", C_SCOPE);
      wait for 10 ns;

      -- MATCH_STD_INCL_Z
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'Z' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Change within time window, STD match including Z, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Different values, STD match including Z, Fail", C_SCOPE);

      -- MATCH_STD_INCL_ZXUW
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'Z' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 2", C_SCOPE);

      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'X' after 3 ns;
      await_value(sl, 'X', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'X', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 3", C_SCOPE);

      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'U' after 3 ns;
      await_value(sl, 'U', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'U', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 4", C_SCOPE);

      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'W' after 3 ns;
      await_value(sl, 'W', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'W', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 5", C_SCOPE);

      increment_expected_alerts(error, 10);

      -- await_value : integer
      i <= 0;
      i <= transport 1 after 2 ns;
      await_value(i, 1, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      i <= transport 2 after 3 ns;
      await_value(i, 2, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      i <= transport 3 after 6 ns;
      await_value(i, 3, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      i <= transport 15 after 0 ns;
      wait for 0 ns;
      i <= transport 16 after 1 ns;
      await_value(i, 15, 0 ns, 2 ns, error, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      i <= 17;
      wait for 0 ns;
      await_value(i, 17, 1 ns, 2 ns, error, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);
      increment_expected_alerts(error, 3);

      -- await_value : real
      r <= 0.0;
      r <= transport 1.0 after 2 ns;
      await_value(r, 1.0, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      r <= transport 2.0 after 3 ns;
      await_value(r, 2.0, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      r <= transport 3.0 after 6 ns;
      await_value(r, 3.0, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      r <= transport 15.0 after 0 ns;
      wait for 0 ns;
      r <= transport 16.0 after 1 ns;
      await_value(r, 15.0, 0 ns, 2 ns, error, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      r <= 17.0;
      wait for 0 ns;
      await_value(r, 17.0, 1 ns, 2 ns, error, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);
      increment_expected_alerts(error, 3);

    elsif GC_TESTCASE = "byte_and_slv_arrays" then
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
      v_slv_array_as_3_byte         := (others => (others => '0'));
      -- build 3x3 bytes
      for idx in 1 to 9 loop
        v_byte_array(idx - 1) := random(v_byte_array(idx - 1)'length);
      end loop;
      -- convert
      v_slv_array_as_3_byte(0 to 2) := convert_byte_array_to_slv_array(v_byte_array, 3, LOWER_BYTE_LEFT);
      --check result
      v_idx                         := 0;
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
      v_slv_array_as_3_byte         := (others => (others => '0'));
      -- convert
      v_slv_array_as_3_byte(0 to 2) := convert_byte_array_to_slv_array(v_byte_array, 3, LOWER_BYTE_RIGHT);
      -- check result
      v_idx                         := 0;
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
      v_byte_array         := (others => (others => '0'));
      -- convert
      v_byte_array(0 to 1) := convert_slv_array_to_byte_array(t_slv_array'(8x"A0", 8x"A1"), LOWER_BYTE_LEFT);
      -- check result
      check_value(8x"A0" = v_byte_array(0), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(0));
      check_value(8x"A1" = v_byte_array(1), error, "Checking convert_slv_array_to_byte_array(), byte #" & to_string(1));

      log(ID_SEQUENCER, "3xbyte to byte testing, LOWER_BYTE_LEFT, ascending t_byte_array");
      v_byte_array         := (others => (others => '0'));
      -- build 3x3 bytes
      for idx in 1 to 3 loop
        v_slv_array_as_3_byte(idx - 1) := random(v_slv_array_as_3_byte(idx - 1)'length);
      end loop;
      -- convert
      v_byte_array(0 to 8) := convert_slv_array_to_byte_array(v_slv_array_as_3_byte(0 to 2), LOWER_BYTE_LEFT);
      -- check result
      v_idx                := 0;
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
      v_idx                := 0;
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
      v_byte_array            := (others => (others => '0'));
      -- fill slv
      v_slv_not_byte_multiple := (others => '1');
      -- convert
      v_byte_array            := convert_slv_to_byte_array(v_slv_not_byte_multiple, LOWER_BYTE_LEFT);
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
      v_byte_array            := (others => (others => '0'));
      -- fill slv
      v_slv_not_byte_multiple := (others => '1');
      -- convert
      v_byte_array            := convert_slv_to_byte_array(v_slv_not_byte_multiple, LOWER_BYTE_RIGHT);
      -- check result
      for idx in 0 to 9 loop
        v_byte := (others => '1') when idx < 9 else "1111ZZZZ";
        check_value(v_byte = v_byte_array(idx), error, "Checking convert_slv_to_byte_array() result, byte #" & to_string(idx));
      end loop;

    elsif GC_TESTCASE = "random_functions" then
      --------------------------------------------------------------------------
      -- Random functions
      --------------------------------------------------------------------------
      -- Test the random SLV function
      -- (Not self checking)
      for iteration in 1 to 5 loop
        v_slv8 := random(v_slv8'length);
        log(ID_SEQUENCER, "Random function slv8 = " & to_string(v_slv8), C_SCOPE);
      end loop;

      -- Test the random SLV procedure
      -- (not self checking)
      for iteration in 1 to 5 loop
        random(v_seed1, v_seed2, v_slv8);
        log(ID_SEQUENCER, "Random procedure slv8 = " & to_string(v_slv8), C_SCOPE);
      end loop;

      -- Test the random SL function
      -- (Not self checking)
      for iteration in 1 to 10 loop
        v_sl := random(VOID);
        log(ID_SEQUENCER, "Random function sl = " & to_string(v_sl), C_SCOPE);
      end loop;

      -- Test the random SL procedure
      -- (not self checking)
      for iteration in 1 to 10 loop
        random(v_seed1, v_seed2, v_sl);
        log(ID_SEQUENCER, "Random procedure sl = " & to_string(v_sl), C_SCOPE);
      end loop;

      -- Test the random integer function
      for iteration in 1 to 100 loop
        v_ia      := random(C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE);
        -- Check that the number is in the requested range
        check_value_in_range(v_ia, C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE, error, "Random integer function in range, OK", C_SCOPE, ID_NEVER);
        ctr(v_ia) <= ctr(v_ia) + 1;     -- Keep track of how many times the random value got this value
        wait for 0 ns;
      end loop;
      -- Print statistics over the random values
      for iteration in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "integer function: ctr(" & to_string(iteration, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(ctr(iteration), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        ctr(iteration) <= 0;
      end loop;

      -- Test the random integer procedure
      for iteration in 1 to 100 loop
        random(C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE, v_seed1, v_seed2, v_i);
        check_value_in_range(v_i, C_RANDOM_MIN_VALUE, C_RANDOM_MAX_VALUE, error, "Random integer procedure in range, OK", C_SCOPE, ID_NEVER);
        ctr(v_i) <= ctr(v_i) + 1;       -- Keep track of how many times the random value got this value
      end loop;
      -- Print statistics over the random values
      for iteration in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "integer procedure: ctr(" & to_string(iteration, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(ctr(iteration), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        ctr(iteration) <= 0;
      end loop;
      -- Test the max limit
      for iteration in 1 to 10 loop
        random(0, integer'right, v_seed1, v_seed2, v_i);
        check_value_in_range(v_i, 0, integer'right, error, "Random integer function in range, OK", C_SCOPE, ID_NEVER);
      end loop;
      -- Test the min & max limits (not self checking)
      for iteration in 1 to 10 loop
        random(integer'left, integer'right, v_seed1, v_seed2, v_i);
        log(ID_SEQUENCER, "Random int procedure = " & to_string(v_i), C_SCOPE);
      end loop;

      -- Test the random real function
      for iteration in 1 to 5 loop
        v_r := random(0.01, 0.03);
        log(ID_SEQUENCER, "Random real function = " & to_string(v_r, "%f"), C_SCOPE);
        check_value_in_range(v_r, 0.01, 0.03, error, "Random real function in range, OK", C_SCOPE, ID_NEVER);
      end loop;
      -- Test the random real procedure
      for iteration in 1 to 5 loop
        random(0.01, 0.03, v_seed1, v_seed2, v_r);
        log(ID_SEQUENCER, "Random real procedure = " & to_string(v_r, "%f"), C_SCOPE);
        check_value_in_range(v_r, 0.01, 0.03, error, "Random real procedure in range, OK", C_SCOPE, ID_NEVER);
      end loop;

      -- Test the random time function
      for iteration in 1 to 100 loop
        v_t             := random(1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE);
        -- Check that the number is in the requested range
        check_value_in_range(v_t, 1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE, error, "Random time function in range, OK", C_SCOPE, ID_NEVER);
        ctr(v_t / 1 ns) <= ctr(v_t / 1 ns) + 1; -- Keep track of how many times the random value got this value
        wait for 0 ns;
      end loop;
      -- Print statistics over the random values
      for iteration in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time function (ns) : ctr(" & to_string(iteration, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(ctr(iteration), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        ctr(iteration) <= 0;
      end loop;

      -- Test the random time procedure
      for iteration in 1 to 100 loop
        random(1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE, v_seed1, v_seed2, v_t);
        check_value_in_range(v_t, 1 ns * C_RANDOM_MIN_VALUE, 1 ns * C_RANDOM_MAX_VALUE, error, "Random time procedure in range, OK", C_SCOPE, ID_NEVER);
        ctr(v_t / 1 ns) <= ctr(v_t / 1 ns) + 1; -- Keep track of how many times the random value got this value
      end loop;
      -- Print statistics over the random values
      for iteration in C_RANDOM_MIN_VALUE to C_RANDOM_MAX_VALUE loop
        log(ID_SEQUENCER, "time procedure (ns) : ctr(" & to_string(iteration, 2, right, KEEP_LEADING_SPACE) & ") = " & to_string(ctr(iteration), 8, right, KEEP_LEADING_SPACE), C_SCOPE);
        -- Reset counter
        ctr(iteration) <= 0;
      end loop;

    elsif GC_TESTCASE = "check_value_in_range" then
      --------------------------------------------------------------------------
      -- Check_value_in_range
      --------------------------------------------------------------------------
      -- check_value_in_range : integer
      v_ia := 3;
      check_value_in_range(v_ia, 3, 4, error, "Check_value_in_range, OK", C_SCOPE);
      v_b  := check_value_in_range(v_ia, 2, 3, error, "Check_value_in_range, OK", C_SCOPE);
      check_value(v_b, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_b  := check_value_in_range(v_ia, 4, 5, error, "Check_value_in_range, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);

      increment_expected_alerts(error, 1);

      -- check_value_in_range : unsigned
      v_u32 := x"80000000";             -- +2^31 (2147483648)
      check_value_in_range(v_u32, x"00000001", x"80000001", error, "Check 2147483648 between 1 and 2147483649, OK", C_SCOPE);
      check_value_in_range(v_u32, x"00000001", x"7FFFFFFF", error, "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      v_b   := check_value_in_range(v_u32, x"00000001", x"7FFFFFFF", error, "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      -- check_value_in_range : signed
      v_s32 := x"80000001";             -- -2^31 (-2147483647)
      check_value_in_range(v_s32, x"80000000", x"00000001", error, "Check -2147483647 between -2147483648 and 1, OK", C_SCOPE);
      check_value_in_range(v_s32, x"80000002", x"00000001", error, "Check -2147483647 between -2147483646 and 1, Fail", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- check_value_in_range : time
      v_t := 3 ns;
      check_value_in_range(v_t, 2 ns, 5 ns, error, "Check time in range, OK", C_SCOPE);
      v_b := check_value_in_range(v_t, 3 ns, 5 ns, error, "Check time in range, OK", C_SCOPE);
      check_value(v_b, error, "check_value with return value shall return true when OK", C_SCOPE);
      v_b := check_value_in_range(v_t, 4 ns, 5 ns, error, "Check time in range, Fail", C_SCOPE);
      check_value(not v_b, error, "check_value with return value shall return false when Fail", C_SCOPE);
      increment_expected_alerts(error);

      report_check_counters(VOID);

    elsif GC_TESTCASE = "string_methods" then
      --------------------------------------------------------------------------
      -- Checking some details of string_methods
      --------------------------------------------------------------------------
      v_slv8  := x"17";
      v_slv5a := "10111";
      log("Valid hex, no radix");
      check_value(to_string(v_slv8, HEX), "17", error, "to_string x""17"", HEX", C_SCOPE);
      check_value(to_string(v_slv8, BIN), "00010111", error, "to_string x""17"", BIN", C_SCOPE);
      check_value(to_string(v_slv5a, HEX), "17", error, "to_string x""17"", HEX", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID), "17", error, "to_string x""17"", HEX_BIN_IF_INVALID", C_SCOPE);

      log("Invalid hex, no radix");
      v_slv8 := "0X010111";
      check_value(to_string(v_slv8, HEX), "X7", error, "to_string b""0x010111"", HEX", C_SCOPE);
      check_value(to_string(v_slv8, BIN), "0X010111", error, "to_string b""0x010111"", BIN", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID), "X7 (b""0X010111"")", error, "to_string b""0x010111"", HEX_BIN_IF_INVALID", C_SCOPE);

      log("Valid hex, Radix");
      v_slv8 := x"17";
      check_value(to_string(v_slv8, HEX, AS_IS, INCL_RADIX), "x""17""", error,
                  "to_string b""0x010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, BIN, AS_IS, INCL_RADIX), "b""00010111""", error,
                  "to_string b""00010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX), "x""17""", error,
                  "to_string b""0x010111"", HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX", C_SCOPE);

      log("Invalid hex, Radix");
      v_slv8 := "0X010111";
      check_value(to_string(v_slv8, HEX, AS_IS, INCL_RADIX), "x""X7""", error,
                  "to_string b""0x010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, BIN, AS_IS, INCL_RADIX), "b""0X010111""", error,
                  "to_string b""0x010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_slv8, HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX), "x""X7"" (b""0X010111"")", error,
                  "to_string b""0x010111"", HEX_BIN_IF_INVALID, AS_IS, INCL_RADIX", C_SCOPE);

      log("Signed , positive");
      v_s8 := x"17";                    -- +23 decimal
      check_value(to_string(v_s8, DEC), "23", error, "to_string x""17"", DEC", C_SCOPE);
      check_value(to_string(v_s8, HEX), "17", error, "to_string x""17"", HEX", C_SCOPE);
      check_value(to_string(v_s8, BIN), "00010111", error, "to_string x""17"", BIN", C_SCOPE);
      check_value(to_string(v_s8, HEX, AS_IS, INCL_RADIX), "x""17""", error,
                  "to_string b""0x010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_s8, BIN, AS_IS, INCL_RADIX), "b""00010111""", error,
                  "to_string b""00010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);

      log("Signed , negative ");
      v_s8 := x"97";                    -- -105 decimal
      check_value(to_string(v_s8, DEC), "-105", error, "to_string x""97"", DEC", C_SCOPE);
      check_value(to_string(v_s8, HEX), "97", error, "to_string x""97"", HEX", C_SCOPE);
      check_value(to_string(v_s8, BIN), "10010111", error, "to_string x""97"", BIN", C_SCOPE);
      check_value(to_string(v_s8, HEX, AS_IS, INCL_RADIX), "x""97""", error,
                  "to_string b""0x10010111"", HEX, AS_IS, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_s8, BIN, AS_IS, INCL_RADIX), "b""10010111""", error,
                  "to_string b""10010111"", BIN, AS_IS, INCL_RADIX", C_SCOPE);

      v_s32 := x"80030201";             -- -2147286527 decimal
      check_value(to_string(v_s32, DEC), "-2147286527", error, "to_string x""80030201"", DEC", C_SCOPE);

      v_s33 := 33x"1FEDCBA98";
      check_value(to_string(v_s33, DEC), "1FEDCBA98 (too wide to be converted to integer)", error, "to_string x""1FEDCBA98"", DEC", C_SCOPE);

      log("Integer as DEC");
      v_i := 150;
      check_value(to_string(v_i, DEC, EXCL_RADIX), "150", error, "to_string 150, DEC, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, DEC, INCL_RADIX), "d""150""", error, "to_string d""150"", DEC, INCL_RADIX", C_SCOPE);
      log("Integer as BIN");
      check_value(to_string(v_i, BIN, EXCL_RADIX), "10010110", error, "to_string 10010110, BIN, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, BIN, INCL_RADIX), "b""10010110""", error, "to_string b""10010110"", BIN, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, BIN, INCL_RADIX, KEEP_LEADING_0), "b""00000000000000000000000010010110""", error, "to_string b""00000000000000000000000010010110"", BIN, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);
      log("Integer as HEX");
      check_value(to_string(v_i, HEX, EXCL_RADIX), "96", error, "to_string 96, HEX, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, HEX, INCL_RADIX), "x""96""", error, "to_string x""96"", HEX, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, HEX, INCL_RADIX, KEEP_LEADING_0), "x""00000096""", error, "to_string x""00000096"", HEX, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);
      log("Integer as DEC");
      v_i := -150;
      check_value(to_string(v_i, DEC, EXCL_RADIX), "-150", error, "to_string -150, DEC, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, DEC, INCL_RADIX), "d""-150""", error, "to_string d""-150"", DEC, INCL_RADIX", C_SCOPE);
      log("Integer as BIN");
      check_value(to_string(v_i, BIN, EXCL_RADIX), "11111111111111111111111101101010", error, "to_string 11111111111111111111111101101010, BIN, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, BIN, INCL_RADIX), "b""11111111111111111111111101101010""", error, "to_string b""11111111111111111111111101101010"", BIN, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, BIN, INCL_RADIX, KEEP_LEADING_0), "b""11111111111111111111111101101010""", error, "to_string b""11111111111111111111111101101010"", BIN, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);
      log("Integer as HEX");
      check_value(to_string(v_i, HEX, EXCL_RADIX), "FFFFFF6A", error, "to_string FFFFFF6A, HEX, EXCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, HEX, INCL_RADIX), "x""FFFFFF6A""", error, "to_string x""FFFFFF6A"", HEX, INCL_RADIX", C_SCOPE);
      check_value(to_string(v_i, HEX, INCL_RADIX, KEEP_LEADING_0), "x""FFFFFF6A""", error, "to_string x""FFFFFF6A"", HEX, INCL_RADIX, KEEP_LEADING_0", C_SCOPE);

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

    elsif GC_TESTCASE = "clock_generators" then
      --
      -- Test clock_generators
      --
      set_alert_stop_limit(TB_ERROR, 2);

      log(ID_LOG_HDR, "Verify CLK100M");
      test_clock_enable_and_period(clk100M, clk100M_ena, C_CLK100M_PERIOD);
      log(ID_LOG_HDR, "Verify CLK200M");
      test_clock_enable_and_period(clk200M, clk200M_ena, C_CLK200M_PERIOD);

      log(ID_LOG_HDR, "Verify CLK50M");
      -- Wait until clock transitions, then verify periods
      await_value(clk50M, '1', 0 ns, 1 ns + C_CLK50M_PERIOD / 2, error, "Wait until Clk50M goes high", C_SCOPE);
      await_value(clk50M, '0', 0 ns, 1 ns + C_CLK50M_PERIOD / 2, error, "Wait until Clk50M goes low", C_SCOPE);
      wait for C_CLK50M_PERIOD / 2;     -- Wait until Clk50M goes high
      test_clock_period(clk50M, C_CLK50M_PERIOD);

      log(ID_LOG_HDR, "Verify Duty Cycles");
      clk100M_ena <= true;
      -- Verifying both time and percentage versions using
      -- time and percentage tests.
      test_clock_period(clk100M_percentage_60_40, C_CLK100M_PERIOD, 60);
      test_clock_period(clk100M_percentage_10_90, C_CLK100M_PERIOD, 10);
      test_clock_period(clk100M_percentage_90_10, C_CLK100M_PERIOD, 90);
      test_clock_duty_cycle(clk100M_percentage_60_40, C_CLK100M_PERIOD, 6 ns);
      test_clock_duty_cycle(clk100M_percentage_10_90, C_CLK100M_PERIOD, 1 ns);
      test_clock_duty_cycle(clk100M_percentage_90_10, C_CLK100M_PERIOD, 9 ns);
      test_clock_period(clk100M_time_4_6, C_CLK100M_PERIOD, 40);
      test_clock_period(clk100M_time_1_9, C_CLK100M_PERIOD, 10);
      test_clock_period(clk100M_time_9_1, C_CLK100M_PERIOD, 90);
      test_clock_duty_cycle(clk100M_time_4_6, C_CLK100M_PERIOD, 4 ns);
      test_clock_duty_cycle(clk100M_time_1_9, C_CLK100M_PERIOD, 1 ns);
      test_clock_duty_cycle(clk100M_time_9_1, C_CLK100M_PERIOD, 9 ns);

      log(ID_LOG_HDR, "Verify Adjustable_CLK100M");
      test_adjustable_clock_enable_and_period(adj_clk100M, adj_clk100M_high_percentage, adj_clk100M_ena, C_ADJ_CLK100M_PERIOD);
      wait for 100 ns;

      log(ID_LOG_HDR, "Verify Adjustable_CLK100M alert handling");
      set_alert_stop_limit(TB_ERROR, get_alert_stop_limit(TB_ERROR) + 2);
      increment_expected_alerts(TB_ERROR, 2);
      test_adjustable_clock_error_handling(adj_clk100M, adj_clk100M_high_percentage, adj_clk100M_ena, C_ADJ_CLK100M_PERIOD);

      clk10M_ena <= false;              -- Must synchronize clk10M
      wait for 10 * C_CLK10M_PERIOD;
      clk10M_ena <= true;
      test_clock_period(clk10M_percentage_99_1, C_CLK10M_PERIOD, 99);
      test_clock_period(clk10M_percentage_1_99, C_CLK10M_PERIOD, 1);
      test_clock_duty_cycle(clk10M_percentage_99_1, C_CLK10M_PERIOD, 99 ns);
      test_clock_duty_cycle(clk10M_percentage_1_99, C_CLK10M_PERIOD, 1 ns);
      test_clock_period(clk10M_time_99_1, C_CLK10M_PERIOD, 99);
      test_clock_period(clk10M_time_1_99, C_CLK10M_PERIOD, 1);
      test_clock_duty_cycle(clk10M_time_99_1, C_CLK10M_PERIOD, 99 ns);
      test_clock_duty_cycle(clk10M_time_1_99, C_CLK10M_PERIOD, 1 ns);

      sl <= '0';
      wait for 10 ns;
      gen_pulse(sl, 50 ns, BLOCKING, "test pulse 50 ns, blocking");
      wait for 0 ns;                    -- Wait for signal to be updated
      wait for 0 ns;                    -- Wait for signal to be updated, needs some delta cycles
      check_value(sl, '0', error, "pulse generator, blocking mode, pulse done", C_SCOPE);
      wait for 100 ns;

      sl <= '0';
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(sl, 51 ns, "test pulse 50 ns, blocking by default");
      wait for 0 ns;                    -- Wait for signal to be updated
      check_value(sl, '0', error, "pulse generator, blocking mode by default, pulse done", C_SCOPE);
      wait for 100 ns;

      -- Test a pulse for one delta cycle
      sl <= '0';
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(sl, 0 ns, "Pulse for a delta cycle");
      wait for 0 ns;                    -- Wait for signal to be updated
      check_value(sl, '0', error, "pulse for 0 ns, blocking mode, pulse done", C_SCOPE);
      check_value(sl'last_event, 0 ns, error, "pulse for 0 ns. Check that it actually pulsed for a delta cycle", C_SCOPE);
      check_value(sl'last_value, '1', error, "pulse for 0 ns, check that it actually pulsed for a delta cycle", C_SCOPE);
      wait for 100 ns;

      sl <= '0';
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(sl, 50 ns, NON_BLOCKING, "Pulse non_blocking");
      wait for 0 ns;                    -- Wait for signal to be updated
      check_value(sl, '1', error, "pulse generator, start of high period", C_SCOPE);
      await_value(sl, '0', 50 ns, 50 ns, error, "Pulse generator, end of high period", C_SCOPE);

      -- Pulse a certain number of clock periods
      clk100M_ena <= true;              -- Clock must be running
      sl          <= '0';
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(sl, clk100M, 10, "Test pulse 10 clk periods");
      check_value(sl'delayed(0 ns)'last_event, 10 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;                    -- Wait for signal to be updated
      check_value(sl, '0', error, "pulse for 10 clk periods, pulse done", C_SCOPE);
      check_value(sl'last_event, 0 ns, error, "pulse for 10 clk periods. Check that it actually pulsed for a delta cycle", C_SCOPE);
      check_value(sl'last_value, '1', error, "pulse for 10 clk periods, check that it actually pulsed for a delta cycle", C_SCOPE);
      wait for 100 ns;

      -- Pulse a sl when line was the same value before
      increment_expected_alerts(TB_ERROR);
      sl <= '0';
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(sl, '0', 50 ns, "Test pulse sl with same value as it was before");
      wait for 0 ns;
      check_value(sl, '0', error, "Check the value after the pulse");

      -- Pulse a sl when line was the same value before
      sl <= 'L';
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(sl, '1', 50 ns, "Test pulse sl ");
      wait for 0 ns;
      check_value(sl, 'L', error, "Check the value after the pulse");

      -- Pulse a slv defined as "to"
      slv8_to <= (others => '0');
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8_to, x"AB", clk100M, 2, "Test pulse slv defined as 'to' for 2 clks");
      check_value(slv8_to'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8_to'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8_to'last_value, x"AB", error, "Check what the value was during the pulse");
      check_value(slv8_to, x"00", error, "Check the value after the pulse");

      -- Pulse a slv defined as "downto"
      slv8 <= (others => '0');
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8, x"AB", clk100M, 2, "Test pulse slv defined as 'downto' for 2 clks");
      check_value(slv8'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8'last_value, x"AB", error, "Check what the value was during the pulse");
      check_value(slv8, x"00", error, "Check the value after the pulse");

      -- Pulse a slv defined as "to" with don't care
      slv8_to <= (others => '1');
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8_to, x"-6", clk100M, 2, "Test pulse slv defined as 'to' with don't care for 2 clks");
      check_value(slv8_to'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8_to'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8_to'last_value, x"F6", error, "Check what the value was during the pulse");
      check_value(slv8_to, x"FF", error, "Check the value after the pulse");

      -- Pulse a slv defined as "downto" with don't care
      slv8 <= "11001100";
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8, "-0-1-0-1", clk100M, 2, "Test pulse slv defined as 'downto' with don't care for 2 clks");
      check_value(slv8'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8'last_value, "10011001", error, "Check what the value was during the pulse");
      check_value(slv8, "11001100", error, "Check the value after the pulse");

      -- Pulse a slv defined as "to" with don't care
      slv8_to <= "11111111";
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8_to, "0-0-0-0-", clk100M, 2, "Test pulse slv defined as 'to' for 2 clks");
      check_value(slv8_to'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8_to'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8_to'last_value, x"55", error, "Check what the value was during the pulse");
      check_value(slv8_to, x"FF", error, "Check the value after the pulse");

      -- Pulse a slv defined as "to" without pulse_value
      slv8_to <= x"23";
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8_to, clk100M, 2, "Test pulse slv defined as 'to' for 2 clks");
      check_value(slv8_to'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8_to'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8_to'last_value, x"FF", error, "Check what the value was during the pulse");
      check_value(slv8_to, x"23", error, "Check the value after the pulse");

      -- Pulse a slv defined as "downto" without pulse_value
      slv8 <= x"23";
      wait for 0 ns;                    -- Wait for signal to update
      gen_pulse(slv8, clk100M, 2, "Test pulse slv for 2 clks");
      check_value(slv8'delayed(0 ns)'last_event, 2 * C_CLK100M_PERIOD, error, "Check start of pulse");
      wait for 0 ns;
      check_value(slv8'last_event, 0 ns, error, "Check pulse is just done");
      check_value(slv8'last_value, x"FF", error, "Check what the value was during the pulse");
      check_value(slv8, x"23", error, "Check the value after the pulse");
      wait for 100 ns;

      -- Pulse a slv to a value it was already with check of signal value
      sl <= '1';
      wait for 0 ns;                    -- wait for signal to update
      set_alert_stop_limit(TB_ERROR, get_alert_stop_limit(TB_ERROR) + 1);
      increment_expected_alerts(TB_ERROR, 1); -- expect TB_ERROR
      gen_pulse(sl, '1', 10 ns, "Test pulse sl to a value it was already.");
      check_value(sl, '1', error, "Check what the value was during the pulse.");
      wait for 0 ns;
      check_value(sl, '1', error, "Check what the value was after the pulse");
      wait for 100 ns;

      log(ID_SEQUENCER, "Check that gen_pulse() outputs TB_ERROR for combination NON_BLOCKING + 0 ns duration", "");
      sl <= '0';
      wait for 0 ns;
      set_alert_stop_limit(TB_ERROR, get_alert_stop_limit(TB_ERROR) + 1);
      increment_expected_alerts(TB_ERROR, 1); -- expect TB_ERROR
      gen_pulse(sl, '1', 0 ns, NON_BLOCKING, "NON_BLOCKING pulse for a delta cycle (0 ns)");
      wait for 0 ns;
      check_value(sl, '0', error, "pulse for 0 ns, blocking mode, pulse done", C_SCOPE);
      check_value(sl'last_event, 0 ns, error, "pulse for 0 ns. Check that it actually pulsed for a delta cycle", C_SCOPE);
      check_value(sl'last_value, '1', error, "pulse for 0 ns, check that it actually pulsed for a delta cycle", C_SCOPE);
      wait for 100 ns;

    -- Verify that clock_counter wraps when reaching natural'right.
    --wait until clk500M = '1';
    --p_clk_cnt_ena <= false;
    --clk500M_cnt   <= force in (natural'right-8);  -- Force output from clock_generator to a value that is almost natural'right
    --wait until clk500M = '0';
    --wait until clk500M = '1';
    --clk500M_cnt   <= release in;
    --wait until clk500M_cnt = natural'right;
    --wait for C_CLK500M_PERIOD + 1 ns;
    --check_value(clk500M_cnt, 0, error, "Verifying cnt wrap");
    --wait for C_CLK500M_PERIOD + 1 ns;
    --check_value(clk500M_cnt, 1, error, "Verifying increment after wrap");

    elsif GC_TESTCASE = "normalise" then
      --==================================================================================================
      -- BFM common pkg
      --------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "Verifying normalise", "");

      set_alert_stop_limit(TB_ERROR, 27);

      log("\rCheck normalise for slv");
      -- slv: No errors expected
      v_slv8  := x"00";
      v_slv5a := "10101";
      v_slv5b := "01010";
      v_slv8  := normalise(v_slv5a, v_slv8, ALLOW_NARROWER, "v_slv5a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5a, error, "", C_SCOPE);
      v_slv8  := x"00";
      v_slv8  := normalise(v_slv5a, v_slv8, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5a, error, "", C_SCOPE);
      v_slv5b := "00000";
      v_slv8  := "00010101";
      v_slv5b := normalise(v_slv8, v_slv5a, ALLOW_WIDER, "v_slv5a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5b := "00000";
      v_slv5b := normalise(v_slv8, v_slv5a, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5b := normalise(v_slv5a, v_slv5b, ALLOW_EXACT_ONLY, "v_slv5a", "v_slv5b", "");
      check_value(v_slv5a, v_slv5b, error, "", C_SCOPE);

      v_slv5b := normalise(v_slv5a, v_slv5b, ALLOW_NARROWER, "v_slv5a", "v_slv5b", "");
      v_slv5b := normalise(v_slv5a, v_slv5b, ALLOW_WIDER, "v_slv5a", "v_slv5b", "");
      v_slv5b := normalise(v_slv5a, v_slv5b, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv5b", "");

      -- slv: Provoking errors.
      v_slv8               := x"00";
      v_slv5a              := "10101";
      v_slv5b              := "01010";
      increment_expected_alerts(TB_ERROR);
      v_slv8               := normalise(v_slv5a, v_slv8, ALLOW_WIDER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv8               := normalise(v_slv5a, v_slv8, ALLOW_EXACT_ONLY, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := normalise(v_slv8, v_slv5a, ALLOW_NARROWER, "v_slv8", "v_slv5a", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := normalise(v_slv8, v_slv5a, ALLOW_EXACT_ONLY, "v_slv8", "v_slv5a", "");
      increment_expected_alerts(TB_ERROR);
      v_slv8               := x"55";
      v_slv5b              := normalise(v_slv8, v_slv5a, ALLOW_WIDER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := "00000";
      v_slv5b              := normalise(v_slv8, v_slv5a, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := normalise(v_slv8(-1 downto 0), v_slv5a, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b(-1 downto 0) := normalise(v_slv8, v_slv5a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");

      log("\rCheck normalise for unsigned");
      -- unsigned: No errors expected
      v_u8  := x"00";
      v_u5a := "10101";
      v_u5b := "01010";
      v_u8  := normalise(v_u5a, v_u8, ALLOW_NARROWER, "v_u5a", "v_u8", "");
      check_value(v_u8, "000" & v_u5a, error, "", C_SCOPE);
      v_u8  := x"00";
      v_u8  := normalise(v_u5a, v_u8, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      check_value(v_u8, "000" & v_u5a, error, "", C_SCOPE);
      v_u5b := "00000";
      v_u8  := "00010101";
      v_u5b := normalise(v_u8, v_u5a, ALLOW_WIDER, "v_u5a", "v_u8", "");
      check_value(to_integer(v_u5b), to_integer(v_u8), error, "", C_SCOPE);
      v_u5b := "00000";
      v_u5b := normalise(v_u8, v_u5a, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      check_value(to_integer(v_u5b), to_integer(v_u8), error, "", C_SCOPE);
      v_u5b := normalise(v_u5a, v_u5b, ALLOW_EXACT_ONLY, "v_u5a", "v_u5b", "");
      check_value(v_u5a, v_u5b, error, "", C_SCOPE);

      v_u5b := normalise(v_u5a, v_u5b, ALLOW_NARROWER, "v_u5a", "v_u5b", "");
      v_u5b := normalise(v_u5a, v_u5b, ALLOW_WIDER, "v_u5a", "v_u5b", "");
      v_u5b := normalise(v_u5a, v_u5b, ALLOW_WIDER_NARROWER, "v_u5a", "v_u5b", "");

      -- unsigned: Provoking errors.
      v_u8               := x"00";
      v_u5a              := "10101";
      v_u5b              := "01010";
      increment_expected_alerts(TB_ERROR);
      v_u8               := normalise(v_u5a, v_u8, ALLOW_WIDER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u8               := normalise(v_u5a, v_u8, ALLOW_EXACT_ONLY, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := normalise(v_u8, v_u5a, ALLOW_NARROWER, "v_u8", "v_u5a", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := normalise(v_u8, v_u5a, ALLOW_EXACT_ONLY, "v_u8", "v_u5a", "");
      increment_expected_alerts(TB_ERROR);
      v_u8               := x"55";
      v_u5b              := normalise(v_u8, v_u5a, ALLOW_WIDER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := "00000";
      v_u5b              := normalise(v_u8, v_u5a, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := normalise(v_u8(-1 downto 0), v_u5a, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b(-1 downto 0) := normalise(v_u8, v_u5a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");

      log("\rCheck normalise for signed");
      -- signed: No errors expected
      v_s8  := x"00";
      v_s5a := "10101";
      v_s5b := "01010";
      v_s8  := normalise(v_s5a, v_s8, ALLOW_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s8  := x"00";
      v_s8  := normalise(v_s5a, v_s8, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s5b := "00000";
      v_s8  := "00010101";
      v_s5b := normalise(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      check_value(v_s5b, v_s8, error, "", C_SCOPE);
      v_s5b := "00000";
      v_s5b := normalise(v_s8, v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s5b, v_s8, error, "", C_SCOPE);

      v_s8  := x"00";
      v_s5a := "01010";
      v_s5b := "10101";
      v_s8  := normalise(v_s5a, v_s8, ALLOW_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s8  := x"00";
      v_s8  := normalise(v_s5a, v_s8, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s5b := "00000";
      v_s8  := "11110101";
      v_s5b := normalise(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      check_value(to_integer(v_s5b), to_integer(v_s8), error, "", C_SCOPE);
      v_s5b := "00000";
      v_s5b := normalise(v_s8, v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(to_integer(v_s5b), to_integer(v_s8), error, "", C_SCOPE);

      v_s5b := normalise(v_s5a, v_s5b, ALLOW_EXACT_ONLY, "v_s5a", "v_s5b", "");
      v_s5b := normalise(v_s5a, v_s5b, ALLOW_NARROWER, "v_s5a", "v_s5b", "");
      v_s5b := normalise(v_s5a, v_s5b, ALLOW_WIDER, "v_s5a", "v_s5b", "");
      v_s5b := normalise(v_s5a, v_s5b, ALLOW_WIDER_NARROWER, "v_s5a", "v_s5b", "");

      -- signed: Provoking errors.
      v_s8               := x"00";
      v_s5a              := "10101";
      v_s5b              := "01010";
      increment_expected_alerts(TB_ERROR);
      v_s8               := normalise(v_s5a, v_s8, ALLOW_WIDER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s8               := normalise(v_s5a, v_s8, ALLOW_EXACT_ONLY, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := normalise(v_s8, v_s5a, ALLOW_NARROWER, "v_s8", "v_s5a", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := normalise(v_s8, v_s5a, ALLOW_EXACT_ONLY, "v_s8", "v_s5a", "");
      increment_expected_alerts(TB_ERROR);
      v_s8               := x"55";
      v_s5b              := normalise(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := "00000";
      v_s5b              := normalise(v_s8, v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s8               := "10110101";
      v_s5b              := normalise(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := normalise(v_s8(-1 downto 0), v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b(-1 downto 0) := normalise(v_s8, v_s5a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");

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

    elsif GC_TESTCASE = "normalize_and_check" then
      log(ID_LOG_HDR, "Verifying normalize_and_check", "");

      set_alert_stop_limit(TB_ERROR, 51);

      log("\rCheck normalize_and_check for slv");
      -- slv: No errors expected
      v_slv8  := x"00";
      v_slv5a := "10101";
      v_slv5b := "01010";
      v_slv8  := normalize_and_check(v_slv5a, v_slv8, ALLOW_NARROWER, "v_slv5a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5a, error, "", C_SCOPE);
      v_slv8  := x"00";
      v_slv8  := normalize_and_check(v_slv5a, v_slv8, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      check_value(v_slv8, "000" & v_slv5a, error, "", C_SCOPE);
      v_slv5b := "00000";
      v_slv8  := "00010101";
      v_slv5b := normalize_and_check(v_slv8, v_slv5a, ALLOW_WIDER, "v_slv5a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5b := "00000";
      v_slv5b := normalize_and_check(v_slv8, v_slv5a, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      check_value(to_integer(unsigned(v_slv5b)), to_integer(unsigned(v_slv8)), error, "", C_SCOPE);
      v_slv5b := normalize_and_check(v_slv5a, v_slv5b, ALLOW_EXACT_ONLY, "v_slv5a", "v_slv5b", "");
      check_value(v_slv5a, v_slv5b, error, "", C_SCOPE);

      v_slv5b := normalize_and_check(v_slv5a, v_slv5b, ALLOW_NARROWER, "v_slv5a", "v_slv5b", "");
      v_slv5b := normalize_and_check(v_slv5a, v_slv5b, ALLOW_WIDER, "v_slv5a", "v_slv5b", "");
      v_slv5b := normalize_and_check(v_slv5a, v_slv5b, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv5b", "");

      -- slv: Provoking errors.
      v_slv8               := x"00";
      v_slv5a              := "10101";
      v_slv5b              := "01010";
      increment_expected_alerts(TB_ERROR);
      v_slv8               := normalize_and_check(v_slv5a, v_slv8, ALLOW_WIDER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv8               := normalize_and_check(v_slv5a, v_slv8, ALLOW_EXACT_ONLY, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := normalize_and_check(v_slv8, v_slv5a, ALLOW_NARROWER, "v_slv8", "v_slv5a", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := normalize_and_check(v_slv8, v_slv5a, ALLOW_EXACT_ONLY, "v_slv8", "v_slv5a", "");
      increment_expected_alerts(TB_ERROR);
      v_slv8               := x"55";
      v_slv5b              := normalize_and_check(v_slv8, v_slv5a, ALLOW_WIDER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := "00000";
      v_slv5b              := normalize_and_check(v_slv8, v_slv5a, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b              := normalize_and_check(v_slv8(-1 downto 0), v_slv5a, ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");
      increment_expected_alerts(TB_ERROR);
      v_slv5b(-1 downto 0) := normalize_and_check(v_slv8, v_slv5a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_slv5a", "v_slv8", "");

      log("\rCheck normalize_and_check for unsigned");
      -- unsigned: No errors expected
      v_u8  := x"00";
      v_u5a := "10101";
      v_u5b := "01010";
      v_u8  := normalize_and_check(v_u5a, v_u8, ALLOW_NARROWER, "v_u5a", "v_u8", "");
      check_value(v_u8, "000" & v_u5a, error, "", C_SCOPE);
      v_u8  := x"00";
      v_u8  := normalize_and_check(v_u5a, v_u8, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      check_value(v_u8, "000" & v_u5a, error, "", C_SCOPE);
      v_u5b := "00000";
      v_u8  := "00010101";
      v_u5b := normalize_and_check(v_u8, v_u5a, ALLOW_WIDER, "v_u5a", "v_u8", "");
      check_value(to_integer(v_u5b), to_integer(v_u8), error, "", C_SCOPE);
      v_u5b := "00000";
      v_u5b := normalize_and_check(v_u8, v_u5a, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      check_value(to_integer(v_u5b), to_integer(v_u8), error, "", C_SCOPE);
      v_u5b := normalize_and_check(v_u5a, v_u5b, ALLOW_EXACT_ONLY, "v_u5a", "v_u5b", "");
      check_value(v_u5a, v_u5b, error, "", C_SCOPE);

      v_u5b := normalize_and_check(v_u5a, v_u5b, ALLOW_NARROWER, "v_u5a", "v_u5b", "");
      v_u5b := normalize_and_check(v_u5a, v_u5b, ALLOW_WIDER, "v_u5a", "v_u5b", "");
      v_u5b := normalize_and_check(v_u5a, v_u5b, ALLOW_WIDER_NARROWER, "v_u5a", "v_u5b", "");

      -- unsigned: Provoking errors.
      v_u8               := x"00";
      v_u5a              := "10101";
      v_u5b              := "01010";
      increment_expected_alerts(TB_ERROR);
      v_u8               := normalize_and_check(v_u5a, v_u8, ALLOW_WIDER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u8               := normalize_and_check(v_u5a, v_u8, ALLOW_EXACT_ONLY, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := normalize_and_check(v_u8, v_u5a, ALLOW_NARROWER, "v_u8", "v_u5a", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := normalize_and_check(v_u8, v_u5a, ALLOW_EXACT_ONLY, "v_u8", "v_u5a", "");
      increment_expected_alerts(TB_ERROR);
      v_u8               := x"55";
      v_u5b              := normalize_and_check(v_u8, v_u5a, ALLOW_WIDER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := "00000";
      v_u5b              := normalize_and_check(v_u8, v_u5a, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b              := normalize_and_check(v_u8(-1 downto 0), v_u5a, ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");
      increment_expected_alerts(TB_ERROR);
      v_u5b(-1 downto 0) := normalize_and_check(v_u8, v_u5a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_u5a", "v_u8", "");

      log("\rCheck normalize_and_check for signed");
      -- signed: No errors expected
      v_s8  := x"00";
      v_s5a := "10101";
      v_s5b := "01010";
      v_s8  := normalize_and_check(v_s5a, v_s8, ALLOW_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s8  := x"00";
      v_s8  := normalize_and_check(v_s5a, v_s8, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s5b := "00000";
      v_s8  := "00010101";
      v_s5b := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      check_value(v_s5b, v_s8, error, "", C_SCOPE);
      v_s5b := "00000";
      v_s5b := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s5b, v_s8, error, "", C_SCOPE);

      v_s8  := x"00";
      v_s5a := "01010";
      v_s5b := "10101";
      v_s8  := normalize_and_check(v_s5a, v_s8, ALLOW_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s8  := x"00";
      v_s8  := normalize_and_check(v_s5a, v_s8, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(v_s8, to_signed(to_integer(v_s5a), 8), error, "", C_SCOPE);
      v_s5b := "00000";
      v_s8  := "11110101";
      v_s5b := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      check_value(to_integer(v_s5b), to_integer(v_s8), error, "", C_SCOPE);
      v_s5b := "00000";
      v_s5b := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      check_value(to_integer(v_s5b), to_integer(v_s8), error, "", C_SCOPE);

      v_s5b := normalize_and_check(v_s5a, v_s5b, ALLOW_EXACT_ONLY, "v_s5a", "v_s5b", "");
      v_s5b := normalize_and_check(v_s5a, v_s5b, ALLOW_NARROWER, "v_s5a", "v_s5b", "");
      v_s5b := normalize_and_check(v_s5a, v_s5b, ALLOW_WIDER, "v_s5a", "v_s5b", "");
      v_s5b := normalize_and_check(v_s5a, v_s5b, ALLOW_WIDER_NARROWER, "v_s5a", "v_s5b", "");

      -- signed: Provoking errors.
      v_s8               := x"00";
      v_s5a              := "10101";
      v_s5b              := "01010";
      increment_expected_alerts(TB_ERROR);
      v_s8               := normalize_and_check(v_s5a, v_s8, ALLOW_WIDER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s8               := normalize_and_check(v_s5a, v_s8, ALLOW_EXACT_ONLY, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := normalize_and_check(v_s8, v_s5a, ALLOW_NARROWER, "v_s8", "v_s5a", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := normalize_and_check(v_s8, v_s5a, ALLOW_EXACT_ONLY, "v_s8", "v_s5a", "");
      increment_expected_alerts(TB_ERROR);
      v_s8               := x"55";
      v_s5b              := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := "00000";
      v_s5b              := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s8               := "10110101";
      v_s5b              := normalize_and_check(v_s8, v_s5a, ALLOW_WIDER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b              := normalize_and_check(v_s8(-1 downto 0), v_s5a, ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");
      increment_expected_alerts(TB_ERROR);
      v_s5b(-1 downto 0) := normalize_and_check(v_s8, v_s5a(-1 downto 0), ALLOW_WIDER_NARROWER, "v_s5a", "v_s8", "");

    elsif GC_TESTCASE = "log_text_block" then
      log(ID_LOG_HDR, "Verifying log with text block input", "");
      -- Setting up a preformated string
      write(v_line, "TEST OF MULTILINE LOG without formatting" & LF & "First line " & LF & "Second line " & LF & "Third line" & LF & "Fourth line" & LF & "END OF LOG");
      log("Logging data without formatting");
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED);

      write(v_line, "TEST OF MULTILINE LOG with formatting" & LF & "First line " & LF & "Second line " & LF & "Third line" & LF & "Fourth line" & LF & "END OF LOG");
      log("Logging data with formatting");
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "Logging data with Bitvis formatting");

      log("Logging data with empty text block");
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "This header should be printed", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "This header should be printed, with notification", C_SCOPE, shared_msg_id_panel, NOTIFY_IF_BLOCK_EMPTY);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "This header should not be not printed", C_SCOPE, shared_msg_id_panel, SKIP_LOG_IF_BLOCK_EMPTY);

      log("Logging with unformatted text to specified file");
      -- Logging to file with unformatted text
      -- Logging to a specified file (primary.txt)
      write(v_line, "This block should be logged to primary.txt only (unformatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED, ".", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "primary.txt", write_mode);
      write(v_line, "This block should be logged to primary.txt and console (unformatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED, ".", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, CONSOLE_AND_LOG, "primary.txt", append_mode);

      -- Logging to another specified file (secondary.txt)
      write(v_line, "This block should be logged to secondary.txt only (unformatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED, ".", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "secondary.txt", write_mode);

      log("Logging with formatted text");
      -- Logging to file with formatted text
      -- Logging to a specified file (primary.txt)
      write(v_line, "This block should be logged to primary.txt only (formatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "primary.txt", append_mode);
      write(v_line, "This block should be logged to primary.txt and console (formatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, CONSOLE_AND_LOG, "primary.txt", append_mode);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "the content of this block is empty", C_SCOPE, shared_msg_id_panel, NOTIFY_IF_BLOCK_EMPTY, CONSOLE_AND_LOG, "primary.txt", append_mode);

      log("Logging to secondary file");
      -- Logging to another specified file (secondary.txt)
      write(v_line, "This block should be logged to secondary.txt only (formatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "secondary.txt", append_mode);

      log("Logging to console only");
      -- Logging to another specified file (secondary.txt)
      write(v_line, "LOGGING" & LF & "TO" & LF & "CONSOLE" & LF & "ONLY");
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, CONSOLE_ONLY);

    elsif GC_TESTCASE = "log_to_file" then
      log(ID_LOG_HDR, "Test of log with specified destination");
      -- Test of log function with output destination specified
      log(ID_SEQUENCER, "Line to console and log", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG);
      log(ID_SEQUENCER, "Line to log only ", C_SCOPE, shared_msg_id_panel, LOG_ONLY);
      log(ID_SEQUENCER, "Line to console only", C_SCOPE, shared_msg_id_panel, CONSOLE_ONLY);
      log(ID_SEQUENCER, "Line to specified file only", C_SCOPE, shared_msg_id_panel, LOG_ONLY, GC_TESTCASE & "_file1.txt", write_mode);
      --join(output_path(runner_cfg), "file1.txt"), write_mode);
      log(ID_SEQUENCER, "Line to specified file and console", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG, GC_TESTCASE & "_file2.txt", write_mode);
      --join(output_path(runner_cfg), "file2.txt"), write_mode);
      log(ID_SEQUENCER, "Line to specified file and console, append", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG, GC_TESTCASE & "_file2.txt", append_mode);
      --join(output_path(runner_cfg), "file2.txt"), append_mode);
      set_log_destination(CONSOLE_ONLY);
      log(ID_SEQUENCER, "Line to console only", C_SCOPE);
      set_log_destination(LOG_ONLY);
      log(ID_SEQUENCER, "Line to log only", C_SCOPE);
      set_log_destination(CONSOLE_AND_LOG, QUIET);
      log(ID_SEQUENCER, "Line to console and log", C_SCOPE);

      -- Provoking errors
      set_alert_stop_limit(TB_ERROR, 53);
      log(ID_SEQUENCER, "log with error", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG, "");
      log(ID_SEQUENCER, "log with error", C_SCOPE, shared_msg_id_panel, LOG_ONLY, "");
      increment_expected_alerts(TB_ERROR, 2);

    elsif GC_TESTCASE = "log_header_formatting" then
      -- Test of log headers
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
      log(ID_LOG_HDR, "This is a normal header (ID_LOG_HDR)");
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
      log(ID_LOG_HDR_LARGE, "This is a large header (ID_LOG_HDR_LARGE)");
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
      log(ID_LOG_HDR_XL, "This is an extra large header (ID_LOG_HDR_XL)");
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");

    elsif GC_TESTCASE = "alert_summary_report" then
      -- NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK

      -- Test of ignored alert
      log(ID_LOG_HDR, "Testing alert summary report");

      log("Testing without any major or minor alerts");
      report_alert_counters(FINAL);

      log("Testing NOTE");
      alert(NOTE, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(NOTE);

      log("Testing TB_NOTE");
      alert(TB_NOTE, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(TB_NOTE);

      log("Testing WARNING");
      alert(WARNING, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(WARNING);

      log("Testing TB_WARNING");
      alert(TB_WARNING, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(TB_WARNING);

      log("Testing MANUAL_CHECK");
      alert(MANUAL_CHECK, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(MANUAL_CHECK);

      log("Testing final summeray, all OK");

    elsif GC_TESTCASE = "ignored_alerts" then
      -- Test of ignored alert
      log(ID_LOG_HDR, "Testing alert_level NO_ALERT and related functions");
      alert(NO_ALERT, "This alert shall not cause simulation stop, nor be visible in the transcript", C_SCOPE);
      log("Testing set of NO_ALERT alert stop limit (should fail)");
      set_alert_stop_limit(NO_ALERT, 2);
      check_value(get_alert_stop_limit(NO_ALERT), 0, TB_ERROR, "Verifying that alert stop limit for NO_ALERT is 0 (never)", C_SCOPE);
      log("Testing set of NO_ALERT alert attention (should fail)");
      set_alert_attention(NO_ALERT, REGARD);
      check_value(get_alert_attention(NO_ALERT) = IGNORE, TB_ERROR, "Verifying that alert attention for NO_ALERT is IGNORE", C_SCOPE);
      log("Testing increment_expected_alerts for NO_ALERT (should fail)");
      increment_expected_alerts(NO_ALERT, 4);
      increment_expected_alerts(TB_WARNING, 3);

      log("Testing increment_expected_alerts_and_stop_limit");
      v_alert_stop_limit := get_alert_stop_limit(TB_FAILURE);
      v_alert_count      := get_alert_counter(TB_FAILURE);
      increment_expected_alerts_and_stop_limit(TB_FAILURE);
      check_value(get_alert_stop_limit(TB_FAILURE) = (v_alert_stop_limit + 1), TB_ERROR, "Verifying that TB_WARNING alert stop limit was incremented", C_SCOPE);
      check_value(true = false, TB_FAILURE, "Cause TB_FAILURE trigger", C_SCOPE);

    elsif GC_TESTCASE = "hierarchical_alerts_report" then
      -- NOTE, TB_NOTE, WARNING, TB_WARNING, MANUAL_CHECK

      log(ID_LOG_HDR, "Verifying hierarchy linked list minor alerts report summary", "");

      v_local_hierarchy_tree.initialize_hierarchy(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => 0));

      v_local_hierarchy_tree.insert_in_tree((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.print_hierarchical_log;

      log("Enabling all alert levels in entire hierarchy. Minor alerts for alle nodes triggered.");
      v_local_hierarchy_tree.enable_all_alert_levels("TB seq");

      log("Testing NOTE with fourth_node");
      v_local_hierarchy_tree.alert("fourth_node", NOTE);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("fourth_node", NOTE);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing TB_NOTE with third_node");
      v_local_hierarchy_tree.alert("third_node", TB_NOTE);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("third_node", TB_NOTE);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing WARNING with second_node");
      v_local_hierarchy_tree.alert("second_node", WARNING);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("second_node", WARNING);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing TB_WARNING with first_node");
      v_local_hierarchy_tree.alert("first_node", TB_WARNING);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("first_node", TB_WARNING);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing MANUAL_CHECK with TB seq");
      v_local_hierarchy_tree.alert("TB seq", MANUAL_CHECK);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("TB seq", MANUAL_CHECK);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

    elsif GC_TESTCASE = "hierarchical_alerts" then
      -- Hierarchy linked list pkg
      --------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "Verifying hierarchy linked list", "");

      -- Verifying:
      --  initialize_hierarchy
      --  is_empty()
      --  is_not_empty()
      --  get_size()
      --  clear()
      --  contains_scope()
      --  contains_scope_return_data()
      --
      check_value(v_local_hierarchy_tree.is_empty, error, "Verifying that local hierarchy tree is empty before first init!");
      for i in 1 to 10 loop
        -- Initialize hierarchy tree
        v_local_hierarchy_tree.initialize_hierarchy(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => 0));
        check_value(v_local_hierarchy_tree.is_not_empty, error, "Verifying that local hierarchy tree is not empty!");
        check_value(v_local_hierarchy_tree.get_size, 1, error, "Verifying size!");
        check_value(v_local_hierarchy_tree.contains_scope(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH)), error, "Verifying scope is in tree");
        v_local_hierarchy_tree.contains_scope_return_data(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), v_b, v_dummy_hierarchy_node);
        check_value(v_b, error, "Verifying that scope was found");
        check_value(v_dummy_hierarchy_node = (justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), error, "Verifying that node is identical with what was inserted");
        if i > 1 then
          for j in 1 to i - 1 loop
            v_local_hierarchy_tree.insert_in_tree((justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
            check_value(v_local_hierarchy_tree.get_size, j + 1, error, "Verifying size!");
            check_value(v_local_hierarchy_tree.contains_scope(justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH)), error, "Verifying scope is in tree");
            v_local_hierarchy_tree.contains_scope_return_data(justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH), v_b, v_dummy_hierarchy_node);
            check_value(v_b, error, "Verifying that scope was found");
            check_value(v_dummy_hierarchy_node = (justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), error, "Verifying that node is identical with what was inserted");
          end loop;
        end if;

        v_local_hierarchy_tree.clear;
        check_value(v_local_hierarchy_tree.is_empty, error, "Verifying that local hierarchy tree is empty after iteration!");
      end loop;

      -- Verify data structure details:
      --  insert_in_tree()
      --  get_parent_scope()
      --  change_parent()
      v_local_hierarchy_tree.initialize_hierarchy(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => 0));

      v_local_hierarchy_tree.insert_in_tree((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.print_hierarchical_log;

      v_local_hierarchy_tree.change_parent(justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.print_hierarchical_log;

      -- This test case is commented out because it will trigger a failure (intentionally)
      -- The test case is that we try to assign a new parent to first_node, but the new parent is a child of first_node
      -- v_local_hierarchy_tree.change_parent(justify("first_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), justify("third_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT));
      -- check_value(v_local_hierarchy_tree.get_parent_scope((justify("first_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT))) = justify("third_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope!");
      -- v_local_hierarchy_tree.print_hierarchical_log;

      --  Alert related
      log("Verifying that expected alerts propagate correctly.");
      check_value(v_local_hierarchy_tree.get_expected_alerts("first_node", note) = 0, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("second_node", note) = 0, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("third_node", note) = 0, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("fourth_node", note) = 0, error, "Verifying expected alerts!");
      v_local_hierarchy_tree.set_expected_alerts("fourth_node", note, 14);
      check_value(v_local_hierarchy_tree.get_expected_alerts("fourth_node", note) = 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("third_node", note), 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("first_node", note), 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("TB seq", note), 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("second_node", note), 0, error, "Verifying expected alerts!");
      v_local_hierarchy_tree.increment_expected_alerts("fourth_node", note);
      check_value(v_local_hierarchy_tree.get_expected_alerts("fourth_node", note) = 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("third_node", note), 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("first_node", note), 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("TB seq", note), 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("second_node", note), 0, error, "Verifying expected alerts!");
      v_local_hierarchy_tree.print_hierarchical_log;

      v_local_hierarchy_tree.set_expected_alerts("fourth_node", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("third_node", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("first_node", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("TB seq", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("second_node", note, 0);
      log("Verifying that alerts propagate correctly for all alert levels");
      for alert_level in note to t_alert_level'right loop

        v_local_hierarchy_tree.alert("fourth_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("third_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("second_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("first_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("TB seq", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));

        v_local_hierarchy_tree.alert("fourth_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("third_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("second_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("first_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("TB seq", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));

        v_local_hierarchy_tree.increment_expected_alerts("fourth_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("third_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("second_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("first_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("first_node", alert_level); -- Two here since there are two separate branches of children that can cause alerts.
        v_local_hierarchy_tree.increment_expected_alerts("TB seq", alert_level);
      end loop;

      v_local_hierarchy_tree.print_hierarchical_log;

      log("Verifying hierarchical stop limits");

      for alert_level in note to t_alert_level'right loop
        check_value(v_local_hierarchy_tree.get_top_level_stop_limit(alert_level), 0, error, "Verifying top level stop limit default implicitly!");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 0, error, "Verifying top level stop limit default explicitly!");
        v_local_hierarchy_tree.set_top_level_stop_limit(alert_level, 400);
        check_value(v_local_hierarchy_tree.get_top_level_stop_limit(alert_level), 400, error, "Verifying top level stop limit change implicitly!");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 400, error, "Verifying top level stop limit change explicitly!");
        v_local_hierarchy_tree.set_top_level_stop_limit(alert_level, 0);
        check_value(v_local_hierarchy_tree.get_top_level_stop_limit(alert_level), 0, error, "Verifying top level stop limit back to default implicitly!");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 0, error, "Verifying top level stop limit back to default explicitly!");

        --  What test cases are required for hierarchical stop limits?
        --    1.  Set stop limit. Verify that it propagates.
        --    2.  Increment stop limit. Verify that it propagates.
        --    3.  Verify that the simulation actually stops when the limits
        --        are reached on each hierarchy level
        --        -- How to do that? Manually...
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 0, error, "Verifying that second node has 0 as stop limit before starting test");
        v_local_hierarchy_tree.set_stop_limit("fourth_node", alert_level, 1337);
        -- Shall propagate to third->first->tbseq
        check_value(v_local_hierarchy_tree.get_stop_limit("fourth_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("third_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("first_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 1337, error, "Verifying stop limit propagation");
        --Verify that other branch was not touched
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 0, error, "Verifying that other branches did not receive new stop limit");

        -- Verify increment on second node. Shall not increase for first_node since first node has a higher value already
        v_local_hierarchy_tree.increment_stop_limit("second_node", alert_level, 14);
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 14, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("first_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("third_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("fourth_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 1337, error, "Verifying stop limit propagation");
        -- Verify increment on third node. Second and fourth node shall not change now.
        v_local_hierarchy_tree.increment_stop_limit("third_node", alert_level);
        check_value(v_local_hierarchy_tree.get_stop_limit("third_node", alert_level), 1338, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("first_node", alert_level), 1338, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 1338, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("fourth_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 14, error, "Verifying stop limit propagation");
      end loop;

      -- Verify that the simulation stops at the limits. Must be done manually.
      -- v_local_hierarchy_tree.set_top_level_stop_limit(TB_WARNING, 13);
      -- for i in 1 to 14 loop
      -- v_local_hierarchy_tree.alert("second_node", TB_WARNING);
      -- end loop;

      log("Verifying alert level printing for several nodes");
      alert(MANUAL_CHECK, "VERIFY THIS");

      -- Disable all alert levels for the top node.
      -- No alerts shall then be printed for any alert level
      log("Disabling all alert levels in entire hierarchy. No alerts between this log message and the next.");
      v_local_hierarchy_tree.disable_all_alert_levels("TB seq");
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("second_node", TB_ERROR);
      v_local_hierarchy_tree.alert("first_node", TB_ERROR);
      v_local_hierarchy_tree.alert("TB seq", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is an ERROR.");

      -- Enable all alert levels for the top node.
      -- All other nodes shall then give alerts on all alert levels since it propagates downwards.
      log("Enabling all alert levels in entire hierarchy. Some alerts between this log message and the next.");
      v_local_hierarchy_tree.enable_all_alert_levels("TB seq");
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("second_node", TB_ERROR);
      v_local_hierarchy_tree.alert("first_node", TB_ERROR);
      v_local_hierarchy_tree.alert("TB seq", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is CORRECT.");

      -- Then disable specific alert level from third_node
      -- Verify that all alerts from nodes other than third_node and fourth_node are printed
      log("Disabling TB_ERROR alert level for third_node and downwards (fourth_node). No alerts for these nodes at this alert level between this log message and the next. All others shall have alerts printed.");
      v_local_hierarchy_tree.disable_alert_level("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is an ERROR.");
      v_local_hierarchy_tree.alert("second_node", TB_ERROR);
      v_local_hierarchy_tree.alert("first_node", TB_ERROR);
      v_local_hierarchy_tree.alert("TB seq", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is CORRECT.");
      log("Enabling TB_ERROR for third_node and fourth_node again");
      v_local_hierarchy_tree.enable_alert_level("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is CORRECT.");

      v_local_hierarchy_tree.clear;

    --==================================================================================================
    -- Alert hierarchy pkg
    --------------------------------------------------------------------------------------

    -- To properly verify this you need to enable hierarchical alerts by setting the following
    -- in adaptations:

    -- constant C_DEFAULT_STOP_LIMIT : t_alert_counters := (note to manual_check => 0,
    -- -- others               => 0);
    -- constant C_ENABLE_HIERARCHICAL_ALERTS : boolean := true;

    --log(ID_LOG_HDR, "Verifying alert hierarchy pkg", "");
    --clear_hierarchy(VOID);
    --initialize_hierarchy;
    --add_to_alert_hierarchy("test_hier_0", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_1", "test_hier_0", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_2", "test_hier_1", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_3", "test_hier_1", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_4", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_5", "test_hier_4", C_DEFAULT_STOP_LIMIT);

    --hierarchical_alert(WARNING, "this is a test", "test_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_1", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_2", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_3", C_DEFAULT_ALERT_ATTENTION(WARNING));

    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --print_hierarchical_log(INTERMEDIATE);

    ---- Set expected alerts to 5 ERRORs, stop limit to 6 ERRORs, then give 5 ERRORs.
    --set_expected_alerts("test_hier_5", ERROR, 5);
    --set_stop_limit("test_hier_5", ERROR, 6);
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

    ---- Increment expected and stop limit. Then give another error.
    --increment_expected_alerts("test_hier_5", ERROR);
    --increment_stop_limit("test_hier_5", ERROR);
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

    ---- Trigger an alert with a non-registered scope to verify that the automatic
    ---- registration works.
    --hierarchical_alert(WARNING, "this is a test", "auto_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));

    --print_hierarchical_log(FINAL);

    --clear_hierarchy(VOID);

    ---- Verify that global and hierarchical alert counters match.
    --initialize_hierarchy;
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, NOTE);
    --hierarchical_alert(NOTE, "this is a test", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(NOTE));

    --for i in 1 to 5 loop
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, WARNING);
    --hierarchical_alert(WARNING, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(WARNING));
    --end loop;

    --for i in 1 to 3 loop
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, TB_WARNING);
    --hierarchical_alert(TB_WARNING, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(TB_WARNING));
    --end loop;

    ---- Problem here is that if one sets the limit to zero and then starts to increment,
    ---- the limit will be 1, and the test will fail.
    --set_stop_limit(C_BASE_HIERARCHY_LEVEL, ERROR, 87);

    --for i in 1 to 86 loop
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, ERROR);
    --hierarchical_alert(ERROR, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(ERROR));
    --end loop;

    --set_stop_limit(C_BASE_HIERARCHY_LEVEL, TB_ERROR, 53);
    --for i in 1 to 52 loop
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, TB_ERROR);
    --hierarchical_alert(TB_ERROR, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(TB_ERROR));
    --end loop;

    --print_hierarchical_log(FINAL);
    --clear_hierarchy(VOID);

    ---- Verify that sorting the hierarchy tree works.
    --initialize_hierarchy;
    --add_to_alert_hierarchy("test_hier_0", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_1", "test_hier_0", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_2", "test_hier_1", C_DEFAULT_STOP_LIMIT);
    --hierarchical_alert(WARNING, "this is a test", "auto_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --add_to_alert_hierarchy("test_hier_3", "test_hier_1", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_4", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_6", "test_hier_3", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_5", "test_hier_4", C_DEFAULT_STOP_LIMIT);

    --hierarchical_alert(WARNING, "this is a test", "test_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_1", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_2", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_3", C_DEFAULT_ALERT_ATTENTION(WARNING));

    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

    --global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);

    ---- global_sorted_hierarchy_tree.clear;
    --clear_hierarchy(VOID);

    ---- Verify that parent registration overrides child's own registration.
    --initialize_hierarchy;
    --add_to_alert_hierarchy("child", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --check_value(global_hierarchy_tree.get_parent_scope(justify("child", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify(C_BASE_HIERARCHY_LEVEL, C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
    --add_to_alert_hierarchy("parent", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --check_value(global_hierarchy_tree.get_parent_scope(justify("parent", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify(C_BASE_HIERARCHY_LEVEL, C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
    --add_to_alert_hierarchy("child", "parent", C_DEFAULT_STOP_LIMIT);
    --check_value(global_hierarchy_tree.get_parent_scope(justify("child", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify("parent", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
    --add_to_alert_hierarchy("child", "test0", C_DEFAULT_STOP_LIMIT);
    --check_value(global_hierarchy_tree.get_parent_scope(justify("child", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify("parent", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
    --clear_hierarchy(VOID);

    ---- initialize_hierarchy;
    ---- if C_ENABLE_HIERARCHICAL_ALERTS then -- Need this if-statement to avoid errors when hierarchical alerts not enabled.
    ---- increment_expected_alerts(ERROR);
    ---- check_value(false, ERROR, "adding to hierarchy", C_SCOPE);
    ---- check_value(global_hierarchy_tree.contains_scope(justify(C_SCOPE, C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), ERROR, "Verifying that scope was added to hierarchy", C_SCOPE);
    ---- end if;
    ---- hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    ---- global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);
    ---- -- sort_hierarchy_tree(0);
    ---- -- global_sorted_hierarchy_tree.print_hierarchical_log(REGARD);
    ---- clear_hierarchy(VOID);

    ---- if C_ENABLE_HIERARCHICAL_ALERTS then
    ----   -- To let simulation pass when hierarchical alerts not enabled
    ----   -- Problem is that the expected alerts are only incremented on top,
    ----   -- not in the individual scopes. Doing this afterwards.
    ----   -- A better solution would be to increment these instead of
    ----   -- calling the non-hierarchical increment_expected_alerts,
    ----   -- but doing this for simplicity.
    ----   increment_expected_alerts("my_scope", note, 1);
    ----   increment_expected_alerts("my_scope", error, 1);
    ----   increment_expected_alerts("TB seq", warning, 5);
    ----   increment_expected_alerts("TB seq", error, 81);
    ----   increment_expected_alerts("TB seq.", TB_WARNING, 3);
    ----   increment_expected_alerts("TB seq.", MANUAL_CHECK, 1);
    ----   increment_expected_alerts("TB seq.", error, 4);
    ----   increment_expected_alerts("TB seq.", TB_ERROR, 2);
    ----   increment_expected_alerts("bfm_common", TB_ERROR, 50);
    ---- end if;

    --log(ID_LOG_HDR, "Verifying uvvm simulation status with alert hierarchy pkg", "");
    --clear_hierarchy(VOID);
    --initialize_hierarchy;
    --add_to_alert_hierarchy("test_hier_0", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_1", "test_hier_0", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_2", "test_hier_1", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_3", "test_hier_1", C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_4", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
    --add_to_alert_hierarchy("test_hier_5", "test_hier_4", C_DEFAULT_STOP_LIMIT);

    ---- Initial expectation of simulation status
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    --set_expected_alerts("test_hier_0", WARNING, 4);
    --set_expected_alerts("test_hier_1", WARNING, 3);
    --set_expected_alerts("test_hier_2", WARNING, 1);
    --set_expected_alerts("test_hier_3", WARNING, 1);

    --hierarchical_alert(WARNING, "this is a test", "test_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_1", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_2", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --hierarchical_alert(WARNING, "this is a test", "test_hier_3", C_DEFAULT_ALERT_ATTENTION(WARNING));

    ---- regarded = expected
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");
    --global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);

    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

    ---- regarded > expected warnings
    --check_value(found_unexpected_simulation_warnings_or_worse,     1, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");
    --global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);

    ---- regarded = expected
    --increment_expected_alerts("test_hier_5", WARNING);
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, WARNING);
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    ---- regarded > expected errors
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(ERROR));
    --check_value(found_unexpected_simulation_warnings_or_worse,     1, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       1, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    ---- regarded = expected
    --increment_expected_alerts("test_hier_5", ERROR);
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    ---- regarded < expected warnings
    --increment_expected_alerts("test_hier_5", WARNING);
    --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, WARNING);
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    ---- regarded < expected errors
    --increment_expected_alerts("test_hier_5", ERROR);
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    ---- regarded < expected warnings
    --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(ERROR));
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    ---- regarded = expected
    --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
    --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
    --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
    --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
    --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

    elsif GC_TESTCASE = "setting_output_file_name" then
      log(ID_LOG_HDR, "Testing runtime setting of output file", C_SCOPE);

      log("Setting output file");
      if C_WARNING_ON_LOG_ALERT_FILE_RUNTIME_RENAME then
        increment_expected_alerts(warning, 2);
      end if;

      set_log_file_name(GC_TESTCASE & "_testLog2.txt");
      set_alert_file_name(GC_TESTCASE & "_alertLog2.txt");
      --set_log_file_name(join(output_path(runner_cfg), "testLog2.txt"));
      --set_alert_file_name(join(output_path(runner_cfg), "alertLog2.txt"));

      log("This string should be written to testLog2.txt");
      log("This string should also be written to testLog2.txt");
      increment_expected_alerts(TB_WARNING);
      alert(TB_WARNING, "This alert should be written to alertLog2.txt");

      set_log_file_name(GC_TESTCASE & "_testLog3.txt", ID_SEQUENCER);
      set_alert_file_name(GC_TESTCASE & "_alertLog3.txt", ID_SEQUENCER);
      --set_log_file_name(join(output_path(runner_cfg), "testLog3.txt"), ID_SEQUENCER);
      --set_alert_file_name(join(output_path(runner_cfg), "alertLog3.txt"), ID_SEQUENCER);

      set_log_file_name(GC_TESTCASE & "_Log.txt");
      set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    elsif GC_TESTCASE = "synchronization_methods" then
      log(ID_LOG_HDR, "Testing await_unblock_flag with KEEP_UNBLOCKED.", C_SCOPE);
      --1. Enable process p_sync_test and wait for flag to be blocked
      p_sync_test_ena <= true;
      wait for 9 ns;
      --3. Block flag A (already blocked by p_sync_test)
      block_flag("FLAG_A", "This flag should already be blocked.", warning, C_SCOPE);
      increment_expected_alerts(warning);
      --4. Unblock flag A
      unblock_flag("FLAG_A", "", global_trigger);
      --7. Wait for flag B
      await_unblock_flag("FLAG_B", 0 ns, "", KEEP_UNBLOCKED, warning, C_SCOPE);

      log(ID_LOG_HDR, "Testing await_unblock_flag with RETURN_TO_BLOCK.", C_SCOPE);
      block_flag("FLAG_A", "Block only once.", warning, C_SCOPE);
      for i in 1 to 5 loop
        wait for 10 ns;
        unblock_flag("FLAG_A", "", global_trigger);
      end loop;

      log(ID_LOG_HDR, "Testing await_unblock_flag with timeout.", C_SCOPE);
      wait for 100 ns;

      log(ID_LOG_HDR, "Registering maximum number of flags.", C_SCOPE);
      set_alert_stop_limit(TB_ERROR, 2);
      increment_expected_alerts(TB_ERROR);
      for i in 1 to C_NUM_SYNC_FLAGS - 1 loop
        block_flag("FLAG_" & to_string(i), "");
      end loop;

    elsif GC_TESTCASE = "watchdog_timer" then
      wait for 7999 ns;
      log(ID_LOG_HDR, "Testing watchdog timer A (8100 ns) - terminate command", C_SCOPE);
      terminate_watchdog(watchdog_ctrl_terminate);

      log(ID_LOG_HDR, "Testing watchdog timer B (8200 ns) - initial timeout", C_SCOPE);
      wait for 199 ns;
      log(ID_SEQUENCER, "Watchdog B still running", C_SCOPE);
      increment_expected_alerts(error);
      wait for 1 ns;

      log(ID_LOG_HDR, "Testing watchdog timer C (8300 ns) - extend command", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 100 ns);
      wait for 199 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend);
      wait for 5300 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns);
      wait for 300 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns);
      wait for 300 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend);
      wait for 5300 ns;
      reinitialize_watchdog(watchdog_ctrl_extend, 101 ns);
      wait for 100 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns);
      wait for 300 ns;
      increment_expected_alerts(error);
      wait for 1 ns;

      log(ID_LOG_HDR, "Testing watchdog timer D (100 us) - reinitialize command", C_SCOPE);
      reinitialize_watchdog(watchdog_ctrl_reinit, 100 ns);
      wait for 99 ns;
      log(ID_SEQUENCER, "Watchdog D still running", C_SCOPE);
      increment_expected_alerts(error);
      wait for 1 ns;
    elsif GC_TESTCASE = "optional_alert_level" then
      -- This GC_TESTCASE contains duplicates of the testcases for:
      --      GC_TESTCASE = check_value
      --      GC_TESTCASE = check_value_in_range 
      --      GC_TESTCASE = check_stable 
      --      GC_TESTCASE = await_change 
      --      GC_TESTCASE = await_value 
      --      GC_TESTCASE = await_stable 
      -- with all testcases called without alert_level parameter. 
      -- Update date (20/03/20). 

      --------------------------------------------------------------------------------------
      -- CHECK_VALUE(): Verifying check_value overloads without alert_level
      --------------------------------------------------------------------------------------

      log(ID_LOG_HDR, "Verifying check_value() overloads without alert_level", "C_SCOPE");
      -- Boolean
      v_b     := check_value(14 > 6, "A must be higher than B, OK", C_SCOPE);
      check_value(v_b, "check_value with return value shall return true when OK", C_SCOPE);
      -- SLV
      v_slv5a := "01111";
      v_slv5b := "01111";
      check_value(v_slv5a, v_slv5b, "My msg1, OK", C_SCOPE);
      v_slv5b := "01110";
      check_value(v_slv5a, v_slv5b, "My msg2, Fail", C_SCOPE);
      check_value(std_logic_vector'("100101"), "10010-", "My msg3a, OK", C_SCOPE);
      check_value(std_logic_vector'("100101"), "100101", "My msg3b, OK", C_SCOPE);
      v_b     := check_value(std_logic_vector'("100101"), "100100", "My msg3c, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", "My msg (none), OK", C_SCOPE);
      check_value(std_logic_vector'("10010"), "10010", "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "10010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "111010", "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("110010"), "111010", "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("110010"), "111010", "My msg BIN, Fail", C_SCOPE, BIN);
      check_value(std_logic_vector'("110010"), "10010", "My msg (none), Fail", C_SCOPE);
      check_value(std_logic_vector'("10010"), "110010", "My msg HEX, Fail", C_SCOPE, HEX);
      check_value(std_logic_vector'("10010"), "0010010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0010010"), "010010", "My msg BIN, OK", C_SCOPE, BIN);

      check_value(std_logic_vector'("0000010010"), "000010010", "My msg BIN, OK", C_SCOPE, BIN);
      check_value(std_logic_vector'("0000010010"), "000010010", "My msg HEX, OK", C_SCOPE, HEX);
      check_value(std_logic_vector'("0000010010"), "000010-10", "My msg HEX, OK", C_SCOPE, HEX);

      check_value(std_logic_vector'("0000010010"), "000010010", "My msg BIN, AS_IS, OK", C_SCOPE, BIN, AS_IS);
      check_value(std_logic_vector'("0000010010"), "000010010", "My msg HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "000010-10", "My msg HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "00--10-10", "My msg dontcare-in-extended-width HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_STD, "My msg dontcare-in-extended-width HEX, AS_IS, OK", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0000010010"), "00--10-10", MATCH_EXACT, "My msg dontcare-in-extended-width HEX, AS_IS, Fail", C_SCOPE, HEX, AS_IS);

      -- MATCH_STD_INCL_Z
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z", C_SCOPE, HEX, AS_IS);

      -- MATCH_STD_INCL_ZXUW
      check_value(std_logic_vector'("000Z0Z00Z0"), "000Z0Z00Z0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("000X0X00X0"), "000X0X00X0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("000U0U00U0"), "000U0U00U0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("000W0W00W0"), "000W0W00W0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);
      check_value(std_logic_vector'("0Z0X0U00W0"), "0Z0X0U00W0", MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE, HEX, AS_IS);

      check_value(std_logic_vector'("0000010010"), "0000010010", "My msg HEX_BIN_IF_INVALID, OK", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("0000011111"), "0000010010", "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      check_value(std_logic_vector'("00000U00U0"), "0000010010", "My msg HEX_BIN_IF_INVALID, Fail", C_SCOPE, HEX_BIN_IF_INVALID);
      increment_expected_alerts(error, 2);

      -- wide vector
      check_value(slv128, slv128, "Test wide vector, HEX, OK", C_SCOPE, HEX, AS_IS);
      check_value(slv128, slv128, "Test wide vector, DEC, OK", C_SCOPE, DEC, AS_IS);

      -- boolean
      -- As function
      v_b := check_value(true, true, "Boolean check true vs true, OK");
      check_value(v_b, "check_value should return true");
      v_b := check_value(true, false, "Boolean check true vs false, Fail");
      check_value(not v_b, "check_value should return false");
      v_b := check_value(false, true, "Boolean check false vs true, Fail");
      check_value(not v_b, "check_value should return false");
      v_b := check_value(false, false, "Boolean check false vs false, OK");
      check_value(v_b, "check_value should return true");
      increment_expected_alerts(error, 2);

      -- As procedure
      check_value(true, true, "Boolean check true vs true, OK");
      check_value(true, false, "Boolean check true vs false, Fail");
      check_value(false, true, "Boolean check false vs true, Fail");
      check_value(false, false, "Boolean check false vs false, OK");
      increment_expected_alerts(error, 2);

      -- Unsigned
      v_u5a := "01100";
      v_u5b := "11100";
      v_u6  := "101100";
      check_value(v_u5a, v_u5a, "My msg U, BIN, AS_IS, OK", C_SCOPE, BIN);
      check_value(v_u5a, v_u5b, "My msg U, BIN, AS_IS, Fail", C_SCOPE, BIN);
      v_b   := check_value(v_u5a, v_u6, "My msg U, BIN, AS_IS, Fail", C_SCOPE, BIN);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);

      -- signed
      v_s8 := "10101100";
      check_value(v_s8, v_s8, "My msg S, BIN, AS_IS, OK", C_SCOPE, BIN);
      v_b  := check_value(v_s8, "10101101", "My msg S, BIN, AS_IS, Fail", C_SCOPE, BIN);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);

      -- Integer
      v_ia := 5;
      v_ib := 23456;
      check_value(v_ia, 5, "My msg I, OK", C_SCOPE);
      check_value(v_ia, 12345, "My msg I, Fail", C_SCOPE);
      v_b  := check_value(v_ia, v_ib, "My msg I, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);

      -- Real
      v_r := 5222.01;
      check_value(v_r, 5222.01, "My msg I, OK", C_SCOPE);
      v_b := check_value(v_r, 1421.02, "My msg I, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);

      -- Std_logic
      v_b := check_value('1', '1', "My msg SL, OK", C_SCOPE);
      check_value(v_b, "check_value with return value shall return true when OK", C_SCOPE);
      v_b := check_value('1', '0', "My msg SL, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value('0', '-', "My msg SL, OK, use default match_strictness", C_SCOPE);
      check_value('1', '-', MATCH_STD, "My msg SL, OK", C_SCOPE);
      check_value('L', '0', MATCH_STD, "My msg SL, OK", C_SCOPE);
      check_value('1', 'H', MATCH_EXACT, "My msg SL, Fail", C_SCOPE);
      check_value('-', '1', MATCH_EXACT, "My msg SL, Fail", C_SCOPE);
      -- MATCH_STD_INCL_Z
      check_value('Z', 'Z', MATCH_STD_INCL_Z, "Check MATCH_STD_INCL_Z", C_SCOPE);
      -- MATCH_STD_INCL_ZXUW
      check_value('Z', 'Z', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('X', 'X', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('U', 'U', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);
      check_value('W', 'W', MATCH_STD_INCL_ZXUW, "Check MATCH_STD_INCL_ZXUW", C_SCOPE);

      -- time
      v_t := 15 ns;
      v_b := check_value(15 ns, 74 ps, "My msg I, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);
      check_value(15 ns, 14 ns, "My msg I, Fail", C_SCOPE);
      check_value(v_t, 15 ns, "My msg I, OK", C_SCOPE);
      check_value(v_t, 15.0 ns, "My msg I, OK", C_SCOPE);
      check_value(v_t, 15000 ps, "My msg I, OK", C_SCOPE);
      check_value(v_t, 74 ps, "My msg I, Fail", C_SCOPE);

      increment_expected_alerts(error, 12);
      increment_expected_alerts(error, 8);

      -- Check UVVM successful status
      check_value(found_unexpected_simulation_warnings_or_worse, 0, "Check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse correctly updated");
      check_value(found_unexpected_simulation_errors_or_worse, 0, "Check shared_uvvm_status.found_unexpected_simulation_errors_or_worse correctly updated");

      -- Check value reporting with padding of short SLV
      increment_expected_alerts(error, 3);
      check_value(std_logic_vector'("00110010"), std_logic_vector'("0010"), "Check padding of different check_value SLV lengths (actual>expected)");
      check_value(std_logic_vector'("1010"), std_logic_vector'("00110010"), "Check padding of different check_value SLV lengths (actual<expected)");
      check_value(std_logic_vector'("00001010"), std_logic_vector'("00110010"), "Check padding of different check_value SLV lengths (actual=expected)");

      -- Check value with unequal array indexes for t_slv/signed/unsigned_array
      -- Verify check_value array index conversion
      v_exp_slv_array(0)   := x"A";
      v_exp_slv_array(1)   := x"B";
      v_value_slv_array(2) := x"A";
      v_value_slv_array(3) := x"B";
      check_value(v_value_slv_array, v_exp_slv_array, "check_value with t_slv_array of different array indexes");

      v_exp_signed_array(0)   := x"C";
      v_exp_signed_array(1)   := x"D";
      v_value_signed_array(2) := x"C";
      v_value_signed_array(3) := x"D";
      check_value(v_value_signed_array, v_exp_signed_array, "check_value with t_signed_array of different array indexes");

      v_exp_unsigned_array(0)   := x"E";
      v_exp_unsigned_array(1)   := x"F";
      v_value_unsigned_array(2) := x"E";
      v_value_unsigned_array(3) := x"F";
      check_value(v_value_unsigned_array, v_exp_unsigned_array, "check_value with t_unsigned_array of different array indexes");

      -- Verify check_value with array conversion catch errors
      increment_expected_alerts(error, 3);
      v_exp_slv_array(1)      := x"C";
      v_exp_signed_array(1)   := x"A";
      v_exp_unsigned_array(1) := x"D";
      check_value(v_value_slv_array, v_exp_slv_array, "check_value with t_slv_array of different array indexes");
      check_value(v_value_signed_array, v_exp_signed_array, "check_value with t_signed_array of different array indexes");
      check_value(v_value_unsigned_array, v_exp_unsigned_array, "check_value with t_unsigned_array of different array indexes");

      -- verify warning with arrays of different directions and unequal lengths
      v_exp_slv_array        := (others => "1010");
      v_exp_slv_array_4      := (others => "1010");
      v_exp_slv_array_revers := (others => "1010");
      set_alert_stop_limit(tb_error, 2);
      increment_expected_alerts(tb_error, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_4, "check_value with different array lenghts");
      increment_expected_alerts(tb_warning, 1);
      check_value(v_exp_slv_array, v_exp_slv_array_revers, "check_value with different array directions");

      --------------------------------------------------------------------------
      -- CHECK_VALUE_IN_RANGE(): Check_value_in_range without alert_level
      --------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_value_in_range() overloads without alert_level", "C_SCOPE");

      -- check_value_in_range : integer
      v_ia := 3;
      check_value_in_range(v_ia, 3, 4, "Check_value_in_range, OK", C_SCOPE);
      v_b  := check_value_in_range(v_ia, 2, 3, "Check_value_in_range, OK", C_SCOPE);
      check_value(v_b, "check_value with return value shall return true when OK", C_SCOPE);
      v_b  := check_value_in_range(v_ia, 4, 5, "Check_value_in_range, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);

      increment_expected_alerts(error, 1);

      -- check_value_in_range : unsigned
      v_u32 := x"80000000";             -- +2^31 (2147483648)
      check_value_in_range(v_u32, x"00000001", x"80000001", "Check 2147483648 between 1 and 2147483649, OK", C_SCOPE);
      check_value_in_range(v_u32, x"00000001", x"7FFFFFFF", "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      v_b   := check_value_in_range(v_u32, x"00000001", x"7FFFFFFF", "Check 2147483648 between 1 and 2147483647, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      -- check_value_in_range : signed
      v_s32 := x"80000001";             -- -2^31 (-2147483647)
      check_value_in_range(v_s32, x"80000000", x"00000001", "Check -2147483647 between -2147483648 and 1, OK", C_SCOPE);
      check_value_in_range(v_s32, x"80000002", x"00000001", "Check -2147483647 between -2147483646 and 1, Fail", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- check_value_in_range : time
      v_t := 3 ns;
      check_value_in_range(v_t, 2 ns, 5 ns, "Check time in range, OK", C_SCOPE);
      v_b := check_value_in_range(v_t, 3 ns, 5 ns, "Check time in range, OK", C_SCOPE);
      check_value(v_b, "check_value with return value shall return true when OK", C_SCOPE);
      v_b := check_value_in_range(v_t, 4 ns, 5 ns, "Check time in range, Fail", C_SCOPE);
      check_value(not v_b, "check_value with return value shall return false when Fail", C_SCOPE);
      increment_expected_alerts(error);

      --------------------------------------------------------------------------------------
      -- CHECK_STABLE():  Verifying check_stable without alert level
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying check_stable overloads without alert level", C_SCOPE);
      bol  <= true;
      slv8 <= (others => '1');
      u8   <= (others => '1');
      s8   <= (others => '1');
      i    <= 14;
      r    <= 1337.14;
      sl   <= '1';
      wait for 10 ns;
      check_stable(bol, 9 ns, "Stable boolean OK", C_SCOPE);
      check_stable(slv8, 9 ns, "Stable slv OK", C_SCOPE);
      check_stable(u8, 9 ns, "Stable unsigned OK", C_SCOPE);
      check_stable(s8, 9 ns, "Stable signed OK", C_SCOPE);
      check_stable(i, 9 ns, "Stable integer OK", C_SCOPE);
      check_stable(r, 9 ns, "Stable real OK", C_SCOPE);
      check_stable(sl, 9 ns, "Stable std_logic OK", C_SCOPE);
      check_stable(bol, 11 ns, "Stable boolean Fail", C_SCOPE);
      check_stable(slv8, 11 ns, "Stable slv Fail", C_SCOPE);
      check_stable(u8, 11 ns, "Stable unsigned Fail", C_SCOPE);
      check_stable(s8, 11 ns, "Stable signed Fail", C_SCOPE);
      check_stable(i, 11 ns, "Stable integer Fail", C_SCOPE);
      check_stable(r, 11 ns, "Stable real Fail", C_SCOPE);
      check_stable(sl, 11 ns, "Stable std_logic Fail", C_SCOPE);

      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 20 ns, "Stable slv OK", C_SCOPE);
      slv8 <= "11001100";
      wait for 20 ns;
      check_stable(slv8, 30 ns, "Stable slv OK", C_SCOPE);
      increment_expected_alerts(error, 7);

      --------------------------------------------------------------------------------------
      -- AWAIT_CHANGE(): Verifying await_change without alert_level
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_change overloads without alert_level");
      bol <= transport false after 2 ns;
      await_change(bol, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      bol <= transport true after 3 ns;
      await_change(bol, 3 ns, 5 ns, "Change within time window 1, OK", C_SCOPE);
      bol <= transport false after 4 ns;
      await_change(bol, 3 ns, 5 ns, "Change within time window 2, OK", C_SCOPE);
      bol <= transport true after 5 ns;
      await_change(bol, 3 ns, 5 ns, "Change within time window 3, OK", C_SCOPE);
      await_change(bol, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      sl <= transport '0' after 2 ns;
      await_change(sl, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      sl <= transport '1' after 3 ns;
      await_change(sl, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '0' after 4 ns;
      await_change(sl, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 5 ns;
      await_change(sl, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_change(sl, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      slv8 <= transport "00000001" after 2 ns;
      await_change(slv8, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      slv8 <= transport "00000010" after 3 ns;
      await_change(slv8, 3 ns, 5 ns, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_change(slv8, 3 ns, 5 ns, "Change within time window 2, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_change(slv8, 3 ns, 5 ns, "Change within time window 3, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_change(slv8, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      u8 <= transport "00000001" after 2 ns;
      await_change(u8, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      u8 <= transport "00000010" after 3 ns;
      await_change(u8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000011" after 4 ns;
      await_change(u8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000100" after 5 ns;
      await_change(u8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000101" after 6 ns;
      await_change(u8, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      s8 <= transport "00000001" after 2 ns;
      await_change(s8, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      s8 <= transport "00000010" after 3 ns;
      await_change(s8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000011" after 4 ns;
      await_change(s8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000100" after 5 ns;
      await_change(s8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000101" after 6 ns;
      await_change(s8, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      i <= transport 1 after 2 ns;
      await_change(i, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      i <= transport 2 after 3 ns;
      await_change(i, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      i <= transport 3 after 4 ns;
      await_change(i, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      i <= transport 4 after 5 ns;
      await_change(i, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      i <= transport 5 after 6 ns;
      await_change(i, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      r <= transport 1.0 after 2 ns;
      await_change(r, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      r <= transport 2.0 after 3 ns;
      await_change(r, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      r <= transport 3.0 after 4 ns;
      await_change(r, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      r <= transport 4.0 after 5 ns;
      await_change(r, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      r <= transport 5.0 after 6 ns;
      await_change(r, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      increment_expected_alerts(error, 2);

      --------------------------------------------------------------------------------------
      -- AWAIT_VALUE(): Verifying await_value without alert_level
      --------------------------------------------------------------------------------------
      -- await_value : SLV
      log(ID_LOG_HDR, "Verifying await_value overloads without alert_level");
      slv8 <= "00000000";
      slv8 <= transport "00000001" after 2 ns;
      await_value(slv8, "00000001", 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00000010" after 3 ns;
      await_value(slv8, "00000010", 3 ns, 5 ns, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "000000011", 3 ns, 5 ns, "Change within time window 2, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_value(slv8, "0000100", 3 ns, 5 ns, "Change within time window 3, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_value(slv8, "00000101", 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      slv8 <= transport "00000110" after 1 ns;
      slv8 <= transport "00000111" after 2 ns;
      slv8 <= transport "00001000" after 4 ns;
      await_value(slv8, "00001000", 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      await_value(slv8, "100010011", 3 ns, 5 ns, "Different width, Fail", C_SCOPE);
      slv8 <= transport "00001001" after 0 ns;
      await_value(slv8, "00001001", 0 ns, 1 ns, "Changed immediately, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00001111" after 0 ns;
      slv8 <= transport "10000000" after 1 ns;
      await_value(slv8, "00001111", 0 ns, 0 ns, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(slv8, "00001111", 0 ns, 1 ns, "Val=exp already, No signal'event. OK. Log in HEX", C_SCOPE, HEX);
      await_value(slv8, "00001111", 0 ns, 2 ns, "Val=exp already, No signal'event. OK. Log in DECimal", C_SCOPE, DEC);
      slv8 <= "10000000";
      wait for 1 ns;
      await_value(slv8, "10000000", 0 ns, 0 ns, "Val=exp already, No signal'event. OK. ", C_SCOPE, HEX);
      await_value(slv8, "10000000", 1 ns, 2 ns, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE, HEX);

      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "00000011", MATCH_EXACT, 3 ns, 5 ns, "Change within time window 2, exact match, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "10110001" after 4 ns;
      await_value(slv8, "10--0001", MATCH_STD, 3 ns, 5 ns, "Change within time window 2, STD match, OK", C_SCOPE);

      increment_expected_alerts(error, 4);

      -- await_value : unsigned
      u8 <= "00000000";
      u8 <= transport "00000001" after 2 ns;
      await_value(u8, "00000001", 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      u8 <= transport "00000010" after 3 ns;
      await_value(u8, "00000010", 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      u8 <= transport "00000101" after 6 ns;
      await_value(u8, "00000101", 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      u8 <= transport "00001111" after 0 ns;
      u8 <= transport "10000000" after 1 ns;
      await_value(u8, "00001111", 0 ns, 0 ns, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(u8, "00001111", 0 ns, 0 ns, "Changed immediately, OK. Log in HEX", C_SCOPE, HEX);
      await_value(u8, "00001111", 0 ns, 2 ns, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);
      increment_expected_alerts(error, 2);

      -- await_value : signed
      s8 <= "00000000";
      s8 <= transport "00000001" after 2 ns;
      await_value(s8, "00000001", 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      s8 <= transport "00000010" after 3 ns;
      await_value(s8, "00000010", 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      s8 <= transport "00000101" after 6 ns;
      await_value(s8, "00000101", 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      s8 <= transport "00001111" after 0 ns;
      await_value(s8, "00001111", 0 ns, 1 ns, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);
      increment_expected_alerts(error, 2);

      -- await_value : boolean
      bol <= false;
      bol <= transport true after 2 ns;
      await_value(bol, true, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      bol <= transport false after 3 ns;
      await_value(bol, false, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      bol <= transport true after 6 ns;
      await_value(bol, true, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      bol <= transport false after 0 ns;
      await_value(bol, false, 0 ns, 1 ns, "Changed immediately, OK. ", C_SCOPE);
      bol <= true;
      wait for 0 ns;
      bol <= transport false after 1 ns;
      await_value(bol, true, 0 ns, 2 ns, "Val=exp already, No signal'event. OK. ", C_SCOPE);
      bol <= true;
      wait for 0 ns;
      await_value(bol, true, 1 ns, 2 ns, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);

      increment_expected_alerts(error, 3);

      -- await_value : std_logic
      sl <= '0';
      sl <= transport '1' after 2 ns;
      await_value(sl, '1', 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, '0', 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_value(sl, '1', 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 0 ns;
      wait for 0 ns;
      sl <= transport '1' after 1 ns;
      await_value(sl, '0', 0 ns, 2 ns, "Changed immediately, OK. ", C_SCOPE);
      sl <= '1';
      wait for 10 ns;
      await_value(sl, '1', 1 ns, 2 ns, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'L' after 3 ns;
      await_value(sl, '0', MATCH_STD, 3 ns, 5 ns, "Change within time window to weak, expecting forced, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'H', MATCH_STD, 3 ns, 5 ns, "Change within time window to forced, expecting weak, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, 'L', MATCH_EXACT, 3 ns, 5 ns, "Change within time window to forced, expecting weak, FAIL", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'H' after 3 ns;
      await_value(sl, '1', MATCH_EXACT, 3 ns, 5 ns, "Change within time window to weak, expecting forced, FAIL", C_SCOPE);
      wait for 10 ns;
      increment_expected_alerts(error, 5);

      -- await_value : integer
      i <= 0;
      i <= transport 1 after 2 ns;
      await_value(i, 1, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      i <= transport 2 after 3 ns;
      await_value(i, 2, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      i <= transport 3 after 6 ns;
      await_value(i, 3, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      i <= transport 15 after 0 ns;
      wait for 0 ns;
      i <= transport 16 after 1 ns;
      await_value(i, 15, 0 ns, 2 ns, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      i <= 17;
      wait for 0 ns;
      await_value(i, 17, 1 ns, 2 ns, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);
      increment_expected_alerts(error, 3);

      -- await_value : real
      r <= 0.0;
      r <= transport 1.0 after 2 ns;
      await_value(r, 1.0, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      r <= transport 2.0 after 3 ns;
      await_value(r, 2.0, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      r <= transport 3.0 after 6 ns;
      await_value(r, 3.0, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      r <= transport 15.0 after 0 ns;
      wait for 0 ns;
      r <= transport 16.0 after 1 ns;
      await_value(r, 15.0, 0 ns, 2 ns, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      r <= 17.0;
      wait for 0 ns;
      await_value(r, 17.0, 1 ns, 2 ns, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);
      increment_expected_alerts(error, 3);

      --------------------------------------------------------------------------------------
      -- AWAIT_STABLE(): Verifying await_value without alert_level
      --------------------------------------------------------------------------------------
      --------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_stable overloads without alert_level");
      --------------------------------------------------------------------------------------

      --
      -- await_stable(boolean)
      --

      -- FROM_NOW, FROM_NOW
      bol <= transport bol after 30 ns; -- No 'Event
      await_stable(bol, 50 ns, FROM_NOW, 51 ns, FROM_NOW, "bol: No 'event, Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      bol <= transport not bol after 30 ns;
      await_stable(bol, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "bol: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      bol <= transport not bol after 30 ns;
      await_stable(bol, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "bol: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(bol, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "bol: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(bol, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "bol: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "bol: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      bol <= not bol;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "bol: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      bol <= not bol;
      wait for 11 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "bol: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      bol <= not bol;
      wait for 10 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "bol: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      bol <= not bol;
      wait for 100 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "bol: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      bol <= not bol;
      wait for 100 ns;
      bol <= transport not bol after 10 ns;
      await_stable(bol, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "bol: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "bol: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "bol: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bol <= not bol;
      wait for 10 ns;
      await_stable(bol, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "bol: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(std_logic)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "sl: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "sl: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      await_stable(sl, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "sl: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(sl, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "sl: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(sl, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "sl: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      sl <= not sl;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      sl <= not sl;
      wait for 11 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "sl: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "sl: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "sl: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(std_logic_vector)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "slv8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "slv8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      await_stable(slv8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "slv8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(slv8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "slv8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(slv8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "slv8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      slv8 <= not slv8;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      slv8 <= not slv8;
      wait for 11 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "slv8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "slv8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "slv8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(unsigned)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(u8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "u8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      u8 <= transport not u8 after 30 ns;
      await_stable(u8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "u8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      u8 <= transport not u8 after 30 ns;
      await_stable(u8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "u8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(u8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "u8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(u8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "u8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "u8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      u8 <= not u8;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "u8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      u8 <= not u8;
      wait for 11 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "u8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      u8 <= not u8;
      wait for 10 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "u8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      u8 <= not u8;
      wait for 100 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "u8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      u8 <= not u8;
      wait for 100 ns;
      u8 <= transport not u8 after 10 ns;
      await_stable(u8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "u8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "u8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "u8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      u8 <= not u8;
      wait for 10 ns;
      await_stable(u8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "u8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(signed)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(s8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "s8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      s8 <= transport not s8 after 30 ns;
      await_stable(s8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "s8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      s8 <= transport not s8 after 30 ns;
      await_stable(s8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "s8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(s8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "s8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(s8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "s8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "s8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      s8 <= not s8;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "s8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      s8 <= not s8;
      wait for 11 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "s8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      s8 <= not s8;
      wait for 10 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "s8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      s8 <= not s8;
      wait for 100 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "s8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      s8 <= not s8;
      wait for 100 ns;
      s8 <= transport not s8 after 10 ns;
      await_stable(s8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "s8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "s8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "s8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      s8 <= not s8;
      wait for 10 ns;
      await_stable(s8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "s8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(integer)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(i, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "i: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      i <= transport i + 1 after 30 ns;
      await_stable(i, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "i: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      i <= transport i + 1 after 30 ns;
      await_stable(i, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "i: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(i, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "i: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(i, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "i: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "i: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      i <= i + 1;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "i: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      i <= i + 1;
      wait for 11 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "i: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      i <= i + 1;
      wait for 10 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "i: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      i <= i + 1;
      wait for 100 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "i: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      i <= i + 1;
      wait for 100 ns;
      i <= transport i + 1 after 10 ns;
      await_stable(i, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "i: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "i: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "i: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      i <= i + 1;
      wait for 10 ns;
      await_stable(i, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "i: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      --
      -- await_stable(real)
      --

      -- FROM_NOW, FROM_NOW
      await_stable(r, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "r: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      r <= transport r + 1.0 after 30 ns;
      await_stable(r, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "r: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      r <= transport r + 1.0 after 30 ns;
      await_stable(r, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "r: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(r, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "r: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      await_stable(r, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "r: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "r: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      r <= r + 1.0;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "r: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      r <= r + 1.0;
      wait for 11 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "r: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      r <= r + 1.0;
      wait for 10 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "r: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);
      increment_expected_alerts(error, 1);

      -- FROM_NOW, FROM_LAST_EVENT
      r <= r + 1.0;
      wait for 100 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "r: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);
      increment_expected_alerts(error, 1);

      r <= r + 1.0;
      wait for 100 ns;
      r <= transport r + 1.0 after 10 ns;
      await_stable(r, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "r: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "r: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "r: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      r <= r + 1.0;
      wait for 10 ns;
      await_stable(r, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "r: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);
      increment_expected_alerts(error, 1);
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    --report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    report_alert_counters(INTERMEDIATE);
    report_alert_counters(FINAL);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

  ---------------------------------------------------------
  -- PROCESS: p_sync_test for synchronization_methods test
  ---------------------------------------------------------
  p_sync_test : process
    constant C_SCOPE : string := "TB sync_seq";
  begin
    wait until p_sync_test_ena;
    -----------------------------------------------------
    -- Testing await_unblock_flag with KEEP_UNBLOCKED.
    -----------------------------------------------------
    --2. Wait for flag A, it will be created and blocked
    await_unblock_flag("FLAG_A", 0 ns, "Wait for an uninitialized flag, it will be created.", KEEP_UNBLOCKED, warning, C_SCOPE);
    --5. Unblock flag A (already unblocked)
    await_unblock_flag("FLAG_A", 0 ns, "Wait for an unblocked flag.", KEEP_UNBLOCKED, warning, C_SCOPE);
    --6. Block flag B
    block_flag("FLAG_B", "", warning, C_SCOPE);
    wait for 10 ns;
    --8. Unblock flag B
    unblock_flag("FLAG_B", "", global_trigger, C_SCOPE);
    -----------------------------------------------------
    -- Testing await_unblock_flag with RETURN_TO_BLOCK.
    -----------------------------------------------------
    for i in 1 to 5 loop
      await_unblock_flag("FLAG_A", 0 ns, "It will return to blocked.", RETURN_TO_BLOCK, warning, C_SCOPE);
    end loop;
    wait for 10 ns;
    -----------------------------------------------------
    -- Testing await_unblock_flag with timeout.
    -----------------------------------------------------
    await_unblock_flag("FLAG_A", 50 ns, "It will timeout.", KEEP_UNBLOCKED, warning, C_SCOPE);
    increment_expected_alerts(warning);

    wait;
  end process p_sync_test;

end func;
