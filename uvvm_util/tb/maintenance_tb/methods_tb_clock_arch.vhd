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

architecture clock_arch of methods_tb is
  constant C_CLK10M_PERIOD      : time := 100 ns;
  constant C_CLK50M_PERIOD      : time := 20 ns;
  constant C_CLK100M_PERIOD     : time := 10 ns;
  constant C_ADJ_CLK100M_PERIOD : time := 10 ns;
  constant C_CLK200M_PERIOD     : time := 5 ns;
  constant C_CLK500M_PERIOD     : time := 2 ns;

  -- Clock signals
  signal clk50M      : std_logic;
  signal clk100M     : std_logic;
  signal clk100M_en  : boolean := true;
  signal clk200M     : std_logic;
  signal clk200M_en  : boolean := true;
  signal clk500M     : std_logic;
  signal clk500M_cnt : natural;

  -- Clock signals with duty cycles
  signal clk10M_en                : boolean := true;
  -- Name: clk<frequency>_percentage_<high_percentage>_<low_percentage>
  signal clk10M_percentage_99_1   : std_logic;
  signal clk10M_percentage_1_99   : std_logic;
  signal clk100M_percentage_60_40 : std_logic;
  signal clk100M_percentage_10_90 : std_logic;
  signal clk100M_percentage_90_10 : std_logic;
  -- Name: clk<frequency>_time_<high_time in ns>_<low_time in ns>
  signal clk10M_time_99_1         : std_logic;
  signal clk10M_time_1_99         : std_logic;
  signal clk100M_time_4_6         : std_logic;
  signal clk100M_time_1_9         : std_logic;
  signal clk100M_time_9_1         : std_logic;

  -- Adjustable clock signals
  -- Name: adj_clk<frequency>_percentage_<high_percentage>_<low_percentage>
  signal adj_clk100M                 : std_logic;
  signal adj_clk100M_high_percentage : natural range 0 to 100 := 50;
  signal adj_clk100M_en              : boolean                := false;

  signal p_clk_cnt_en : boolean                      := true;
  signal sl           : std_logic                    := '0';
  signal slv8         : std_logic_vector(7 downto 0) := (others => '0');
  signal slv8_to      : std_logic_vector(0 to 7)     := (others => '0');
begin

  clock_generator(clk50M, C_CLK50M_PERIOD); -- Always enabled
  clock_generator(clk500M, clk500M_cnt, C_CLK500M_PERIOD);

  -- Overloaded version with enable signal as argument
  clock_generator(clk100M, clk100M_en, C_CLK100M_PERIOD, "Clk100M");
  clock_generator(clk200M, clk200M_en, C_CLK200M_PERIOD, "Clk200M");

  -- Overloaded versions with duty cycles
  -- percentage
  clock_generator(clk100M_percentage_60_40, clk100M_en, C_CLK100M_PERIOD, "Clk100M_60p_duty", 60);
  clock_generator(clk100M_percentage_10_90, clk100M_en, C_CLK100M_PERIOD, "Clk100M_10p_duty", 10);
  clock_generator(clk100M_percentage_90_10, clk100M_en, C_CLK100M_PERIOD, "Clk100M_90p_duty", 90);
  clock_generator(clk10M_percentage_99_1, clk10M_en, C_CLK10M_PERIOD, "Clk10M_99p_duty", 99);
  clock_generator(clk10M_percentage_1_99, clk10M_en, C_CLK10M_PERIOD, "Clk10M_1p_duty", 1);
  clock_generator(clk10M_percentage_1_99, clk10M_en, C_CLK10M_PERIOD, "Clk10M_1p_duty", 1);
  -- time
  clock_generator(clk100M_time_4_6, clk100M_en, C_CLK100M_PERIOD, "Clk100M_4t_duty", 4 ns);
  clock_generator(clk100M_time_1_9, clk100M_en, C_CLK100M_PERIOD, "Clk100M_1t_duty", 1 ns);
  clock_generator(clk100M_time_9_1, clk100M_en, C_CLK100M_PERIOD, "Clk100M_9t_duty", 9 ns);
  clock_generator(clk10M_time_99_1, clk10M_en, C_CLK10M_PERIOD, "Clk10M_99t_duty", 99 ns);
  clock_generator(clk10M_time_1_99, clk10M_en, C_CLK10M_PERIOD, "Clk10M_1t_duty", 1 ns);

  -- Adjustable clock
  adjustable_clock_generator(adj_clk100M, adj_clk100M_en, C_ADJ_CLK100M_PERIOD, "adj_clk100M", adj_clk100M_high_percentage);

  p_clk_cnt : process
    variable v_clk_cnt : natural;
  begin
    if not p_clk_cnt_en then
      wait until p_clk_cnt_en;
    end if;
    v_clk_cnt := clk500M_cnt;

    loop
      wait until clk500M = '0';
      if p_clk_cnt_en then
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
  end process p_clk_cnt;

  p_main : process
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

    -- Check the clock enable and clock period in clock_generator
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

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "clock_generators" then
    ------------------------------------------------------------------------------------------------------------------------------
      --
      -- Test clock_generators
      --
      set_alert_stop_limit(TB_ERROR, 2);

      log(ID_LOG_HDR, "Verify CLK100M");
      test_clock_enable_and_period(clk100M, clk100M_en, C_CLK100M_PERIOD);
      log(ID_LOG_HDR, "Verify CLK200M");
      test_clock_enable_and_period(clk200M, clk200M_en, C_CLK200M_PERIOD);

      log(ID_LOG_HDR, "Verify CLK50M");
      -- Wait until clock transitions, then verify periods
      await_value(clk50M, '1', 0 ns, 1 ns + C_CLK50M_PERIOD / 2, error, "Wait until Clk50M goes high", C_SCOPE);
      await_value(clk50M, '0', 0 ns, 1 ns + C_CLK50M_PERIOD / 2, error, "Wait until Clk50M goes low", C_SCOPE);
      wait for C_CLK50M_PERIOD / 2;     -- Wait until Clk50M goes high
      test_clock_period(clk50M, C_CLK50M_PERIOD);

      log(ID_LOG_HDR, "Verify Duty Cycles");
      clk100M_en <= true;
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
      test_adjustable_clock_enable_and_period(adj_clk100M, adj_clk100M_high_percentage, adj_clk100M_en, C_ADJ_CLK100M_PERIOD);
      wait for 100 ns;

      log(ID_LOG_HDR, "Verify Adjustable_CLK100M alert handling");
      set_alert_stop_limit(TB_ERROR, get_alert_stop_limit(TB_ERROR) + 2);
      increment_expected_alerts(TB_ERROR, 2);
      test_adjustable_clock_error_handling(adj_clk100M, adj_clk100M_high_percentage, adj_clk100M_en, C_ADJ_CLK100M_PERIOD);

      clk10M_en <= false;              -- Must synchronize clk10M
      wait for 10 * C_CLK10M_PERIOD;
      clk10M_en <= true;
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
      clk100M_en <= true;               -- Clock must be running
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
      wait until clk500M = '1';
      p_clk_cnt_en <= false;
      clk500M_cnt   <= force (natural'right-8);  -- Force output from clock_generator to a value that is almost natural'right
      wait until clk500M = '0';
      wait until clk500M = '1';
      clk500M_cnt   <= release;
      wait until clk500M_cnt = natural'right;
      wait for C_CLK500M_PERIOD + 1 ns;
      check_value(clk500M_cnt, 0, error, "Verifying cnt wrap");
      wait for C_CLK500M_PERIOD + 1 ns;
      check_value(clk500M_cnt, 1, error, "Verifying increment after wrap");
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

end architecture clock_arch;
