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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

--hdlregression:tb
-- Test case entity
entity clock_generator_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of clock_generator_tb is

  constant C_SCOPE             : string := "CLOCK_GENERATOR_VVC_TB";
  constant C_CLK_1_PERIOD      : time   := 10 ns;
  constant C_CLK_2_PERIOD      : time   := 20 ns;
  constant C_CLK_3_PERIOD      : time   := 40 ns;
  constant C_CLK_1_HIGH_PERIOD : time   := 5 ns;
  constant C_CLK_2_HIGH_PERIOD : time   := 12 ns;
  constant C_CLK_3_HIGH_PERIOD : time   := 12 ns;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.test_harness
    generic map(
      GC_CLOCK_1_PERIOD      => C_CLK_1_PERIOD,
      GC_CLOCK_1_HIGH_PERIOD => C_CLK_1_HIGH_PERIOD,
      GC_CLOCK_2_PERIOD      => C_CLK_2_PERIOD,
      GC_CLOCK_2_HIGH_PERIOD => C_CLK_2_HIGH_PERIOD,
      GC_CLOCK_3_PERIOD      => C_CLK_3_PERIOD,
      GC_CLOCK_3_HIGH_PERIOD => C_CLK_3_HIGH_PERIOD
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_is_ok              : boolean := false;
    variable v_timestamp          : time;
    variable v_alert_num_mismatch : boolean := false;

    alias clk_1 is << signal i_test_harness.clk_1 : std_logic >>;
    alias clk_2 is << signal i_test_harness.clk_2 : std_logic >>;
    alias clk_3 is << signal i_test_harness.clk_3 : std_logic >>;

    -- Check clock periods in clock_generator
    procedure check_clock_period_and_high_time(
      signal   clock           : std_logic;
      constant clk_period    : time;
      constant clk_high_time : time;
      constant num_of_cycles : positive
    ) is
      variable v_timestamp : time;
    begin
      -- Align with clock
      await_value(clock, '0', 0 ns, 20 * clk_period, error, "Clock check, await falling edge", C_SCOPE, ID_NEVER);
      await_value(clock, '1', 0 ns, 20 * clk_period, error, "Clock check, await rising edge", C_SCOPE, ID_NEVER);
      -- Check clock period (high and low duration)
      for i in 0 to num_of_cycles - 1 loop
        v_timestamp := now;
        wait for clk_high_time;
        check_stable(clock, now - v_timestamp, error, "Clock check, check stable high time", C_SCOPE, ID_NEVER);
        await_value(clock, '0', 0 ns, clk_period, error, "Clock check, await falling edge", C_SCOPE, ID_NEVER);
        check_value(now - v_timestamp, clk_high_time, error, "Clock check, check clock high time", C_SCOPE, ID_NEVER);
        wait for clk_period - clk_high_time;
        check_stable(clock, clk_period - clk_high_time, error, "Clock check, check stable low time", C_SCOPE, ID_NEVER);
        await_value(clock, '1', 0 ns, clk_period, error, "Clock check, await rising edge", C_SCOPE, ID_NEVER);
        check_value(now - v_timestamp, clk_period, error, "Clock check, check clock period", C_SCOPE, ID_NEVER);
      end loop;
      log(ID_SEQUENCER, "Check of clock period and clock high time PASSED.", C_SCOPE);
    end procedure;

    procedure check_clock_not_running(
      signal   clock      : std_logic;
      constant clk_period : time
    ) is
      variable v_timestamp : time;
    begin
      v_timestamp := now;
      check_value(clock, '0', error, "Clock not runnig check, check that clock line is low", C_SCOPE, ID_NEVER);
      wait for clk_period * 10;
      check_stable(clock, now - v_timestamp, error, "Clock not runnig check, check that clock line is not active", C_SCOPE, ID_NEVER);
      log(ID_SEQUENCER, "Check of clock of clock not running PASSED.", C_SCOPE);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    set_alert_stop_limit(TB_ERROR, 4);

    --disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);

    --disable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ID_BFM);
    enable_log_msg(VVC_BROADCAST, ID_BFM_POLL);

    --disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT, 1, ID_BFM);
    --enable_log_msg(SBI_VVCT, 1, ID_BFM_POLL);
    --
    --disable_log_msg(SBI_VVCT, 2, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT, 2, ID_BFM);
    --enable_log_msg(SBI_VVCT, 2, ID_BFM_POLL);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    log(ID_LOG_HDR_LARGE, "Sequencer starting", C_SCOPE);

    log(ID_LOG_HDR, "Check that clk_1, clk_2 and clk_3 is not running", C_SCOPE);
    check_value(clk_1, '0', error, "Check that clock 1 line is low");
    check_value(clk_2, '0', error, "Check that clock 2 line is low");
    check_value(clk_3, '0', error, "Check that clock 3 line is low");
    check_clock_not_running(clk_1, C_CLK_1_PERIOD);
    check_clock_not_running(clk_2, C_CLK_2_PERIOD);
    check_clock_not_running(clk_3, C_CLK_3_PERIOD);

    log(ID_LOG_HDR, "Activate clock 1", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock 1");
    wait for C_CLK_1_PERIOD;
    check_clock_period_and_high_time(clk_1, C_CLK_1_PERIOD, C_CLK_1_HIGH_PERIOD, 5);

    log(ID_LOG_HDR, "Deactivate clock 1", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 1, "Stop clock 1");
    wait for C_CLK_1_PERIOD;
    check_clock_not_running(clk_1, C_CLK_1_PERIOD);

    log(ID_LOG_HDR, "Change clock period and clock high time of clock 1", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 1, 50 ns, "Change clock period to 50 ns");
    wait for 50 ns;
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 1, 35 ns, "Change clock high time to 35 ns");
    wait for 50 ns;

    log(ID_LOG_HDR, "Activate clock 1", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock 1");
    wait for 50 ns;
    check_clock_period_and_high_time(clk_1, 50 ns, 35 ns, 5);

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    wait for C_CLK_2_PERIOD;
    check_clock_period_and_high_time(clk_2, C_CLK_2_PERIOD, C_CLK_2_HIGH_PERIOD, 5);

    log(ID_LOG_HDR, "Deactivate clock 2", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");
    wait for C_CLK_2_PERIOD;
    check_clock_not_running(clk_2, C_CLK_2_PERIOD);

    log(ID_LOG_HDR, "Change clock period and clock high time of clock 2", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 2, 100 ns, "Set clock period to 100 ns");
    wait for 100 ns;
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 50 ns, "Set clock high time to 50 ns");
    wait for 100 ns;

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    wait for 100 ns;
    check_clock_period_and_high_time(clk_2, 100 ns, 50 ns, 5);

    log(ID_LOG_HDR, "Deactivate clock 2", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");
    wait for 100 ns;
    check_clock_not_running(clk_2, 100 ns);

    log(ID_LOG_HDR, "Change clock high time of clock 2", C_SCOPE);
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 1 ns, "Set clock high time to 1 ns");
    wait for 100 ns;

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    wait for 100 ns;
    check_clock_period_and_high_time(clk_2, 100 ns, 1 ns, 5);

    log(ID_LOG_HDR, "Change clock high time of clock 2", C_SCOPE);
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 99 ns, "Set clock high time to 99 ns");
    wait for 100 ns;
    check_clock_period_and_high_time(clk_2, 100 ns, 99 ns, 5);

    log(ID_LOG_HDR, "Change clock period of clock 2", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 2, 40 ns, "Set clock period to 40 ns");
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 39.6 ns, "Set clock high time to 39.6 ns");
    wait for 40 ns;
    check_clock_period_and_high_time(clk_2, 40 ns, 39.6 ns, 5);

    log(ID_LOG_HDR, "Deactivate clock 2", C_SCOPE);
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");
    wait for 40 ns;
    check_clock_not_running(clk_2, 100 ns);

    log(ID_LOG_HDR, "Change clock period of clock 2", C_SCOPE);
    set_clock_period(CLOCK_GENERATOR_VVCT, 2, 40 ns, "Set clock period to 40 ns");
    wait for 40 ns;

    log(ID_LOG_HDR, "Activate clock 2", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start clock 2");
    wait for 40 ns;
    check_clock_period_and_high_time(clk_2, 40 ns, 39.6 ns, 5);

    log(ID_LOG_HDR, "Set clock 2 high time to same as clock period, expect tb_error", C_SCOPE);
    increment_expected_alerts(tb_error, 1);
    set_clock_high_time(CLOCK_GENERATOR_VVCT, 2, 40 ns, "Set clock high time to 40 ns");
    wait for 40 ns;
    stop_clock(CLOCK_GENERATOR_VVCT, 2, "Stop clock 2");

    log(ID_LOG_HDR, "Activate clock 3", C_SCOPE);
    start_clock(CLOCK_GENERATOR_VVCT, 3, "Start clock 3");
    wait for C_CLK_3_PERIOD;
    check_clock_period_and_high_time(clk_3, C_CLK_3_PERIOD, C_CLK_3_HIGH_PERIOD, 5);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
