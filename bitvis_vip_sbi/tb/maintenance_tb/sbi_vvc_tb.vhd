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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;
use bitvis_vip_sbi.vvc_sb_support_pkg.all;

--hdlregression:tb
-- Test case entity
entity sbi_vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of sbi_vvc_tb is

  constant C_CLK_PERIOD : time   := 10 ns; -- **** Trenger metode for setting av clk period
  constant C_SCOPE      : string := "SBI_VVC_TB";

  -- FIFO Register map :
  constant C_ADDR_FIFO_PUT       : unsigned                     := "000";
  constant C_ADDR_FIFO_GET       : unsigned                     := "001";
  constant C_ADDR_FIFO_COUNT     : unsigned                     := "010";
  constant C_ADDR_FIFO_PEEK      : unsigned                     := "011";
  constant C_ADDR_FIFO_FLUSH     : unsigned                     := "100";
  constant C_ADDR_FIFO_MAX_COUNT : unsigned                     := "101";
  constant C_DATA_DONTCARE       : std_logic_vector(7 downto 0) := x"00";

  --------------------------------
  -- SBI config
  --------------------------------
  constant C_ADDR_WIDTH_1 : integer := 8;
  constant C_DATA_WIDTH_1 : integer := 8;
  constant C_ADDR_WIDTH_2 : integer := 8;
  constant C_DATA_WIDTH_2 : integer := 8;

  signal sbi1_if : t_sbi_if(addr(C_ADDR_WIDTH_1 - 1 downto 0), wdata(C_DATA_WIDTH_1 - 1 downto 0), rdata(C_DATA_WIDTH_1 - 1 downto 0));
  signal sbi2_if : t_sbi_if(addr(C_ADDR_WIDTH_2 - 1 downto 0), wdata(C_DATA_WIDTH_2 - 1 downto 0), rdata(C_DATA_WIDTH_2 - 1 downto 0));
  signal clk     : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.sbi_th
    generic map(GC_CLK_PERIOD   => C_CLK_PERIOD,
                GC_ADDR_WIDTH_1 => C_ADDR_WIDTH_1,
                GC_DATA_WIDTH_1 => C_DATA_WIDTH_1,
                GC_ADDR_WIDTH_2 => C_ADDR_WIDTH_2,
                GC_DATA_WIDTH_2 => C_DATA_WIDTH_2
               )
    port map(sbi_if_1 => sbi1_if,
             sbi_if_2 => sbi2_if,
             clk      => clk
            );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- BFM config
    variable v_sbi_bfm_config : t_sbi_bfm_config := C_SBI_BFM_CONFIG_DEFAULT;
    variable v_cmd_idx        : integer;
    variable v_data           : work.vvc_cmd_pkg.t_vvc_result;
    variable v_is_ok          : boolean := false;
    variable v_timestamp      : time;
    variable v_alert_level    : t_alert_level;

    -- DUT ports towards VVC interface
    alias dut_rdata is << signal i_test_harness.dut_rdata : std_logic_vector >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_level : in t_alert_level
    ) is
      variable v_num_expected_alerts : natural;
      variable v_rand                : t_rand;
    begin
      -- Number of total expected alerts: 1 signal x 1 toggle
      if alert_level /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_level, 2);
      end if;
      -- Force new value
      v_num_expected_alerts := get_alert_counter(alert_level);
      dut_rdata <= force not dut_rdata;
      wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
      v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                               v_num_expected_alerts + 1;
      check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      -- Set back original value
      v_num_expected_alerts := get_alert_counter(alert_level);
      dut_rdata <= release;
      wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
      wait for 0 ns;
      wait for 0 ns; -- Wait an extra delta cycle so that the value is propagated from the non-record to the record signals
      v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                               v_num_expected_alerts + 1;
      wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
      check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);

    disable_log_msg(VVC_BROADCAST, ALL_MESSAGES);
    enable_log_msg(VVC_BROADCAST, ID_BFM);
    enable_log_msg(VVC_BROADCAST, ID_BFM_POLL);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    shared_sbi_vvc_config(1).bfm_config.use_ready_signal := false; -- Set that ready signal is not in use
    shared_sbi_vvc_config(2).bfm_config.use_ready_signal := false; -- Set that ready signal is not in use

    wait for 3 * C_CLK_PERIOD;          -- Wait for reset being released in test harness

    --------------------------------------------------------------------------------------
    -- Verifying
    --------------------------------------------------------------------------------------
    if GC_TESTCASE = "simple_write_and_check" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test of simple write and check", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      log("Write with both interfaces");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"AA", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"FF", "Write PUT on FIFO 2");
      await_completion(SBI_VVCT, 1, 16 ns, "Await execution");

      log("Read and check with both interfaces");
      sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_GET, x"FF", "Check GET data on FIFO 2", ERROR);
      sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_GET, x"AA", "Check GET data on FIFO 1", ERROR);
      await_completion(SBI_VVCT, 1, 16 ns, "Await execution");

    elsif GC_TESTCASE = "simple_write_and_read" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test of simple write and read", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Write to FIFO
      log("Write with both interfaces");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"12", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"53", "Write PUT on FIFO 2");
      await_completion(SBI_VVCT, 1, 16 ns, "Await execution");

      -- Read, fetch and check on FIFO 2
      log("Read and check FIFO 2 using SBI IF 1");
      sbi_read(SBI_VVCT, 1, C_ADDR_FIFO_GET, "Read from FIFO 2 and store result in VVC");
      v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 1); -- for last read
      await_completion(SBI_VVCT, 1, v_cmd_idx, 100 ns, "Wait for sbi_read to finish");
      fetch_result(SBI_VVCT, 1, v_cmd_idx, v_data, v_is_ok, "Fetching read-result");
      check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
      check_value(v_data(7 downto 0), x"53", ERROR, "Readback data via fetch_result()");

      -- Read, fetch and check on FIFO 1
      log("Read and check FIFO 1 using SBI IF 2");
      sbi_read(SBI_VVCT, 2, C_ADDR_FIFO_GET, "Read from FIFO 1 and store result in VVC");
      v_cmd_idx := get_last_received_cmd_idx(SBI_VVCT, 2); -- for last read
      await_completion(SBI_VVCT, 2, v_cmd_idx, 100 ns, "Wait for sbi_read to finish");
      fetch_result(SBI_VVCT, 2, v_cmd_idx, v_data, v_is_ok, "Fetching read-result");
      check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
      check_value(v_data(7 downto 0), x"12", ERROR, "Readback data via fetch_result()");

      await_completion(SBI_VVCT, 2, 100 ns, "Await execution");

    elsif GC_TESTCASE = "scoreboard_test" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Scoreboard test", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      log("Write with both interfaces");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"85", "Write on FIFO 1");
      SBI_VVC_SB.add_expected(2, pad_sbi_sb(x"85"));
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"EC", "Write on FIFO 2");
      SBI_VVC_SB.add_expected(1, pad_sbi_sb(x"EC"));
      await_completion(SBI_VVCT, 2, 16 ns, "Await execution");

      log("Read and check FIFO 1 using SBI IF 2");
      sbi_read(SBI_VVCT, 2, C_ADDR_FIFO_GET, TO_SB, "Read from FIFO 1 and store result in VVC's SB");
      await_completion(SBI_VVCT, 2, 100 ns, "Wait for sbi_read to finish");

      log("Read and check FIFO 2 using SBI IF 1");
      sbi_read(SBI_VVCT, 1, C_ADDR_FIFO_GET, TO_SB, "Read from FIFO 2 and store result in VVC's SB");
      await_completion(SBI_VVCT, 1, 100 ns, "Wait for sbi_read to finish");

      SBI_VVC_SB.report_counters(ALL_INSTANCES);

    elsif GC_TESTCASE = "test_of_poll_until" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test of poll until", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      -- Fill FIFO 1
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"01", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"56", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"a3", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"4d", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"00", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"42", "Write PUT on FIFO 1");
      await_completion(SBI_VVCT, 1, 1000 ns, "Await execution");

      -- Fill FIFO 2
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"01", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"56", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"a3", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"4d", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"00", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"42", "Write PUT on FIFO 2");
      await_completion(SBI_VVCT, 2, 1000 ns, "Await execution");

      -- Poll from FIFO 2
      sbi_poll_until(SBI_VVCT, 1, C_ADDR_FIFO_GET, x"42", "Test of POLL_UNTIL within 100 ns", 0, 100 ns, ERROR);

      -- Poll from FIFO 1
      sbi_poll_until(SBI_VVCT, 2, C_ADDR_FIFO_GET, x"42", "Test of POLL_UNTIL within 10 occurrences", 10, 0 ns, ERROR);

      await_completion(SBI_VVCT, 1, 1000 ns, "Await execution");
      await_completion(SBI_VVCT, 2, 1000 ns, "Await execution");

    elsif GC_TESTCASE = "extended_write_and_read" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test of write and read from other addresses on both VVCs", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_FLUSH, C_DATA_DONTCARE, "Flush FIFO 1");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_FLUSH, C_DATA_DONTCARE, "Flush FIFO 2");

      sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_COUNT, x"00", "Check that FIFO 1 is empty", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_COUNT, x"00", "Check that FIFO 2 is empty", ERROR);

      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"11", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"12", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"13", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"11", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"12", "Write PUT on FIFO 2");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"13", "Write PUT on FIFO 2");

      sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_COUNT, x"18", "Check that FIFO 1 has three elements (3*8bit = 24 = x'18')", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_COUNT, x"18", "Check that FIFO 2 has three elements (3*8bit = 24 = x'18')", ERROR);

      sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_PEEK, x"11", "Peek on FIFO 1", ERROR);
      sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_PEEK, x"11", "Peek on FIFO 1 again", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_PEEK, x"11", "Peek on FIFO 2", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_PEEK, x"11", "Peek on FIFO 2 again", ERROR);

      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_FLUSH, C_DATA_DONTCARE, "Flush FIFO 1");
      sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_FLUSH, C_DATA_DONTCARE, "Flush FIFO 2");

      sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_COUNT, x"00", "Check that FIFO 1 is empty", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_COUNT, x"00", "Check that FIFO 2 is empty", ERROR);

      await_completion(SBI_VVCT, 1, 1000 ns, "Await execution");
      await_completion(SBI_VVCT, 2, 1000 ns, "Await execution");

    elsif GC_TESTCASE = "read_of_previous_value" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test read of a previous value");
      ----------------------------------------------------------------------------------------------------------------------------
      -- Configure BFM clock_period for insert_delay() command in this test
      shared_sbi_vvc_config(1).bfm_config.clock_period := C_CLK_PERIOD;
      shared_sbi_vvc_config(2).bfm_config.clock_period := C_CLK_PERIOD;

      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"A0", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"B1", "Write PUT on FIFO 1");
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"C2", "Write PUT on FIFO 1");
      await_completion(SBI_VVCT, 1, 100 ns);

      log("\rNow starting readback with 100T delay between 1st and 2nd read");
      sbi_read(SBI_VVCT, 2, C_ADDR_FIFO_GET, "Readback inside VVC");
      v_cmd_idx   := get_last_received_cmd_idx(SBI_VVCT, 2); -- for last read
      insert_delay(SBI_VVCT, 2, 100, "100T delay");
      sbi_read(SBI_VVCT, 2, C_ADDR_FIFO_GET, "Readback inside VVC");
      sbi_read(SBI_VVCT, 2, C_ADDR_FIFO_GET, "Readback inside VVC");
      v_timestamp := now;

      log("\rFetch the 1st result");
      await_completion(SBI_VVCT, 2, v_cmd_idx, 100 ns, "first read should be executed immediately");
      fetch_result(SBI_VVCT, 2, v_cmd_idx, v_data, v_is_ok, "Fetching available read-result");
      check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
      check_value(v_data(7 downto 0), x"A0", ERROR, "Readback data via fetch_result()");

      log("\rFetch the 2nd result");
      await_completion(SBI_VVCT, 2, v_cmd_idx + 2, 110 * C_CLK_PERIOD, "2nd read should be executed 100 cycles after the first");
      fetch_result(SBI_VVCT, 2, v_cmd_idx + 2, v_data, v_is_ok, "Fetching 2nd read-result");
      check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
      check_value(v_data(7 downto 0), x"B1", ERROR, "Readback data via fetch_result()");
      check_value_in_range((now - v_timestamp), 100 * C_CLK_PERIOD, 102 * C_CLK_PERIOD, ERROR, "2nd read should be executed 100 cycles after the first");

      log("\rFetch the 3rd result");
      await_completion(SBI_VVCT, 2, v_cmd_idx + 3, 2 * C_CLK_PERIOD, "3rd read should be executed 1 cycle after the 2nd");
      fetch_result(SBI_VVCT, 2, v_cmd_idx + 3, v_data, v_is_ok, "Fetching 3rd read-result");
      check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
      check_value(v_data(7 downto 0), x"C2", ERROR, "Readback data via fetch_result()");

      await_completion(SBI_VVCT, 2, 1000 ns);

      -- Reset BFM clock_period 
      shared_sbi_vvc_config(1).bfm_config.clock_period := -1 ns;
      shared_sbi_vvc_config(2).bfm_config.clock_period := -1 ns;

    elsif GC_TESTCASE = "read_of_executor_status_and_inter_bfm_delay" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test of reading executor status");
      ----------------------------------------------------------------------------------------------------------------------------
      log("current_cmd_idx: " & to_string(shared_sbi_vvc_status(1).current_cmd_idx));
      log("previous_cmd_idx: " & to_string(shared_sbi_vvc_status(1).previous_cmd_idx));
      log("pending_cmd_cnt: " & to_string(shared_sbi_vvc_status(1).pending_cmd_cnt));
      check_value(shared_sbi_vvc_status(1).pending_cmd_cnt, 0, ERROR, "Checking that no commands are pending");
      sbi_write(SBI_VVCT, 1, x"00", x"A0", "Write SBI1");
      sbi_write(SBI_VVCT, 1, x"00", x"A0", "Write SBI1");
      sbi_write(SBI_VVCT, 1, x"00", x"A0", "Write SBI1");
      log("current_cmd_idx: " & to_string(shared_sbi_vvc_status(1).current_cmd_idx));
      log("previous_cmd_idx: " & to_string(shared_sbi_vvc_status(1).previous_cmd_idx));
      check_value(shared_sbi_vvc_status(1).pending_cmd_cnt, 2, ERROR, "Checking pending commands");
      await_completion(SBI_VVCT, 1, 100 ns);
      log("current_cmd_idx: " & to_string(shared_sbi_vvc_status(1).current_cmd_idx));
      log("previous_cmd_idx: " & to_string(shared_sbi_vvc_status(1).previous_cmd_idx));
      check_value(shared_sbi_vvc_status(1).pending_cmd_cnt, 0, ERROR, "Checking that no commands are pending after completion");
      -- Cleanup
      sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_FLUSH, C_DATA_DONTCARE, "Flush FIFO 1");
      await_completion(SBI_VVCT, 1, 100 ns);

      log(ID_LOG_HDR, "Testing inter-bfm delay");

      log("\rChecking TIME_START2START");
      wait for C_CLK_PERIOD * 51;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time := C_CLK_PERIOD * 50;
      v_timestamp                                            := now;
      sbi_write(SBI_VVCT, 1, x"00", x"A0", "First write to SBI1");
      sbi_write(SBI_VVCT, 1, x"00", x"03", "Second write to SBI1");
      await_completion(SBI_VVCT, 1, 52 * C_CLK_PERIOD);
      check_value(((now - v_timestamp) = C_CLK_PERIOD * 51), ERROR, "Checking that inter-bfm delay was upheld");

      log("\rChecking that insert_delay does not affect inter-BFM delay");
      wait for C_CLK_PERIOD * 51;
      v_timestamp := now;
      sbi_write(SBI_VVCT, 1, x"00", x"AB", "First Write SBI1");
      insert_delay(SBI_VVCT, 1, C_CLK_PERIOD);
      insert_delay(SBI_VVCT, 1, C_CLK_PERIOD);
      insert_delay(SBI_VVCT, 1, C_CLK_PERIOD);
      insert_delay(SBI_VVCT, 1, C_CLK_PERIOD);
      sbi_write(SBI_VVCT, 1, x"00", x"FF", "Second Write SBI1");
      await_completion(SBI_VVCT, 1, 52 * C_CLK_PERIOD + (4 * C_CLK_PERIOD));
      check_value(((now - v_timestamp) = C_CLK_PERIOD * 51 + (4 * C_CLK_PERIOD)), ERROR, "Checking that inter-bfm delay was upheld");

      log("\rChecking TIME_FINISH2START");
      wait for C_CLK_PERIOD * 101;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_type    := TIME_FINISH2START;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time := C_CLK_PERIOD * 100;
      v_timestamp                                            := now;
      sbi_write(SBI_VVCT, 1, x"00", x"A0", "Write SBI1");
      sbi_write(SBI_VVCT, 1, x"00", x"CC", "Write SBI1");
      await_completion(SBI_VVCT, 1, 103 * C_CLK_PERIOD);
      check_value(((now - v_timestamp) = C_CLK_PERIOD * 102), ERROR, "Checking that inter-bfm delay was upheld");

      log("\rChecking TIME_START2START and provoking inter-bfm delay violation");
      wait for C_CLK_PERIOD * 10;
      increment_expected_alerts(TB_WARNING, 2);
      shared_sbi_vvc_config(1).inter_bfm_delay.inter_bfm_delay_violation_severity := TB_WARNING;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_type                         := TIME_START2START;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time                      := 1 ns;
      sbi_write(SBI_VVCT, 1, x"00", x"A0", "First write to SBI1");
      sbi_write(SBI_VVCT, 1, x"00", x"03", "Second write to SBI1");
      await_completion(SBI_VVCT, 1, 3 * C_CLK_PERIOD);

      log("Setting delay back to initial value");
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_type                         := NO_DELAY;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time                      := 0 ns;
      shared_sbi_vvc_config(1).inter_bfm_delay.inter_bfm_delay_violation_severity := WARNING;

    elsif GC_TESTCASE = "distribution_of_vvc_commands" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Check that commands are distributed to the correct VVC channel");
      ----------------------------------------------------------------------------------------------------------------------------
      -- Calling an invalid channel will yield a TB_WARNING from each of the UART channels
      -- We will also get another TB_WARNING from the timeout, related to having more decimals in the log time than we can display
      increment_expected_alerts(TB_WARNING, 3);
      -- Calling an invalid channel will also cause a timeout, since the target VVC does not exist. This results in an ERROR
      increment_expected_alerts_and_stop_limit(TB_ERROR, 3);
      insert_delay(SBI_VVCT, 1, TX, C_CLK_PERIOD, "Inserting delay on SBI TX channel, expecting tb warning and tb error");
      insert_delay(SBI_VVCT, 1, RX, C_CLK_PERIOD, "Inserting delay on SBI RX channel, expecting tb warning and tb error");
      insert_delay(SBI_VVCT, 42, C_CLK_PERIOD, "Inserting delay on SBI VVC 42, expecting tb error");
      log("Logging a message to provoke the tb warning due to truncated timestamp");

    elsif GC_TESTCASE = "vvc_broadcast_test" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Check that commands are distributed to the correct VVC channel");
      ----------------------------------------------------------------------------------------------------------------------------
      enable_log_msg(VVC_BROADCAST, ALL_MESSAGES);

      -- Fill FIFO 1
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"01", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"56", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"a3", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"4d", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"00", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"42", "Write PUT on both FIFOs");
      await_completion(SBI_VVCT, ALL_INSTANCES, 1000 ns, "Await execution for both VVCs");

      -- Poll from FIFO 1
      sbi_poll_until(SBI_VVCT, 1, C_ADDR_FIFO_GET, x"42", "Test of POLL_UNTIL within 100 ns", 0, 100 ns, ERROR);

      -- Poll from FIFO 2
      sbi_poll_until(SBI_VVCT, 2, C_ADDR_FIFO_GET, x"42", "Test of POLL_UNTIL within 10 occurrences", 10, 0 ns, ERROR);

      await_completion(SBI_VVCT, ALL_INSTANCES, 1000 ns, "Await execution");

      log(ID_LOG_HDR, "Checking broadcast of flush_command_queue");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"4d", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"00", "Write PUT on both FIFOs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, C_ADDR_FIFO_PUT, x"42", "Write PUT on both FIFOs");
      flush_command_queue(VVC_BROADCAST, "Flushing all commands");
      await_completion(SBI_VVCT, ALL_INSTANCES, 2 * C_CLK_PERIOD, "Await flush completion");

      log(ID_LOG_HDR, "Checking broadcast of insert_delay (time)");

      log("Setting no initial inter-bfm delay");
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_type                         := NO_DELAY;
      shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time                      := 0 ns;
      shared_sbi_vvc_config(1).inter_bfm_delay.inter_bfm_delay_violation_severity := WARNING;

      v_timestamp := now;
      sbi_write(SBI_VVCT, ALL_INSTANCES, x"00", x"AB", "First Write SBI1");
      insert_delay(VVC_BROADCAST, C_CLK_PERIOD, "Inserting delay in all VVCs");
      insert_delay(VVC_BROADCAST, C_CLK_PERIOD, "Inserting delay in all VVCs");
      insert_delay(VVC_BROADCAST, C_CLK_PERIOD, "Inserting delay in all VVCs");
      insert_delay(VVC_BROADCAST, C_CLK_PERIOD, "Inserting delay in all VVCs");
      sbi_write(SBI_VVCT, ALL_INSTANCES, x"00", x"FF", "Second Write SBI1");
      await_completion(SBI_VVCT, 1, 7 * C_CLK_PERIOD);
      check_value(((now - v_timestamp) = C_CLK_PERIOD * 6), ERROR, "Checking that inter-bfm delay was upheld");

      await_completion(SBI_VVCT, 2, 1000 ns, "Await execution");

    elsif GC_TESTCASE = "vvc_setup_and_hold_time_test" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Checking setup and hold time");
      ----------------------------------------------------------------------------------------------------------------------------
      -- Set setup and hold times
      log("Setup time: 2 ns, hold time: 1 ns");
      shared_sbi_vvc_config(1).bfm_config.setup_time   := 2 ns;
      shared_sbi_vvc_config(1).bfm_config.hold_time    := 1 ns;
      shared_sbi_vvc_config(1).bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
      shared_sbi_vvc_config(1).bfm_config.clock_period := C_CLK_PERIOD;

      -- Check for sbi_write
      sbi_write(SBI_VVCT, 1, x"00", x"AA", "Write SBI1");
      await_value(sbi1_if.wena, '1', 0 ns, 100 ns, ERROR, "Waiting on wena from SBI1");
      await_value(clk, '1', 2 ns, 2.01 ns, ERROR, "Waiting on positive clk edge, shall occour 2 ns after wdata");
      check_value(sbi1_if.wena'last_event, 2 ns, ERROR, "Check setup time", C_SCOPE, ID_SEQUENCER);
      await_value(sbi1_if.wena, '0', 1 ns, 1.01 ns, ERROR, "Waiting on wena to go inactive, should occuer after 1 ns");
      check_value(clk'last_event, 1 ns, ERROR, "Check hold time", C_SCOPE, ID_SEQUENCER);

      -- Check for sbi_read
      sbi_read(SBI_VVCT, 1, C_ADDR_FIFO_COUNT, "Readback inside VVC");
      await_value(sbi1_if.rena, '1', 0 ns, 100 ns, ERROR, "Waiting on rena from SBI1");
      await_value(clk, '1', 2 ns, 2.01 ns, ERROR, "Waiting on positive clk edge, shall occour 2 ns after wdata");
      check_value(sbi1_if.rena'last_event, 2 ns, ERROR, "Check setup time", C_SCOPE, ID_SEQUENCER);
      await_value(sbi1_if.rena, '0', 1 ns, 1.01 ns, ERROR, "Waiting on rena to go inactive, should occuer after 1 ns");
      check_value(clk'last_event, 1 ns, ERROR, "Check hold time", C_SCOPE, ID_SEQUENCER);

      -- New values
      -- Set setup and hold times
      log("\nSetup time: 1 ns, hold time: 3 ns");
      shared_sbi_vvc_config(1).bfm_config.setup_time := 1 ns;
      shared_sbi_vvc_config(1).bfm_config.hold_time  := 3 ns;

      -- Check for sbi_write
      sbi_write(SBI_VVCT, 1, x"00", x"AB", "Write SBI1");
      await_value(sbi1_if.wena, '1', 0 ns, 100 ns, ERROR, "Waiting on wena from SBI1");
      await_value(clk, '1', 1 ns, 1.01 ns, ERROR, "Waiting on positive clk edge, shall occour 1 ns after wdata");
      check_value(sbi1_if.wena'last_event, 1 ns, ERROR, "Check setup time", C_SCOPE, ID_SEQUENCER);
      await_value(sbi1_if.wena, '0', 3 ns, 3.01 ns, ERROR, "Waiting on wena to go inactive, should occuer after 3 ns");
      check_value(clk'last_event, 3 ns, ERROR, "Check hold time", C_SCOPE, ID_SEQUENCER);

      -- Check for sbi_read
      sbi_read(SBI_VVCT, 1, C_ADDR_FIFO_COUNT, "Readback inside VVC");
      await_value(sbi1_if.rena, '1', 0 ns, 100 ns, ERROR, "Waiting on rena from SBI1");
      await_value(clk, '1', 1 ns, 1.01 ns, ERROR, "Waiting on positive clk edge, shall occour 2 ns after wdata");
      check_value(sbi1_if.rena'last_event, 1 ns, ERROR, "Check setup time", C_SCOPE, ID_SEQUENCER);
      await_value(sbi1_if.rena, '0', 3 ns, 3.01 ns, ERROR, "Waiting on rena to go inactive, should occuer after 1 ns");
      check_value(clk'last_event, 3 ns, ERROR, "Check hold time", C_SCOPE, ID_SEQUENCER);

      shared_sbi_vvc_config(1).bfm_config.bfm_sync := SYNC_ON_CLOCK_ONLY;

    elsif GC_TESTCASE = "test_unwanted_activity" then
      ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
      ------------------------------------------------------------------------------------------------------------------------------
      for i in 0 to 2 loop
        -- Test different alert severity configurations
        if i = 0 then
          v_alert_level := C_SBI_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
        elsif i = 1 then
          v_alert_level := FAILURE;
        else
          v_alert_level := NO_ALERT;
        end if;
        log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
        shared_sbi_vvc_config(1).unwanted_activity_severity := v_alert_level;

        log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
        sbi_write(SBI_VVCT, 1, C_ADDR_FIFO_PUT, x"AA", "Write PUT on FIFO 1");
        sbi_write(SBI_VVCT, 2, C_ADDR_FIFO_PUT, x"FF", "Write PUT on FIFO 2");
        await_completion(SBI_VVCT, 1, 16 ns);
        sbi_check(SBI_VVCT, 1, C_ADDR_FIFO_GET, x"FF", "Check GET data on FIFO 2");
        sbi_check(SBI_VVCT, 2, C_ADDR_FIFO_GET, x"AA", "Check GET data on FIFO 1");
        await_completion(SBI_VVCT, 1, 16 ns);

        -- Test with and without a time gap between await_completion and unexpected data transmission
        if i = 0 then
          log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
          wait for 100 ns;
        end if;

        log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
        toggle_vvc_if(v_alert_level);
      end loop;

    end if;

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
