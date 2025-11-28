--================================================================================================================================
-- Copyright 2025 UVVM
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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_wishbone;
context bitvis_vip_wishbone.vvc_context;
use bitvis_vip_wishbone.vvc_sb_support_pkg.all;

--hdlregression:tb
entity wishbone_vvc_tb is
  generic(
    GC_DATA_WIDTH : integer;
    GC_TESTCASE   : string := "UVVM"
  );
end entity;

architecture tb of wishbone_vvc_tb is

  constant C_CLK_PERIOD : time := 10 ns;

  -- FIFO register map:
  constant C_ADDR_FIFO    : unsigned(1 downto 0) := "00";
  constant C_ADDR_STATUS  : unsigned(1 downto 0) := "01";
  constant C_ADDR_VERSION : unsigned(1 downto 0) := "10";

begin

  ------------------------------------------------
  -- Instantiate test harness
  ------------------------------------------------
  i_test_harness : entity work.wishbone_th
    generic map(
      GC_CLK_PERIOD => C_CLK_PERIOD,
      GC_DATA_WIDTH => GC_DATA_WIDTH
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_data        : std_logic_vector(GC_DATA_WIDTH - 1 downto 0);
    variable v_cmd_idx     : natural;
    variable v_result      : work.vvc_cmd_pkg.t_vvc_result;
    variable v_alert_level : t_alert_level;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 2;
    alias dut_dat_o is << signal i_test_harness.i_dut.dat_o : std_logic_vector >>;
    alias dut_ack_o is << signal i_test_harness.i_dut.ack_o : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_level : in t_alert_level
    ) is
      variable v_num_expected_alerts : natural;
      variable v_rand                : t_rand;
    begin
      -- Number of total expected alerts: (number of signals tested individually + number of signals tested together) x 1 toggle
      if alert_level /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_level, (C_NUM_VVC_SIGNALS + C_NUM_VVC_SIGNALS) * 2);
      end if;
      for i in 0 to C_NUM_VVC_SIGNALS loop
        -- Force new value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_dat_o <= force not dut_dat_o;
                    dut_ack_o <= force not dut_ack_o;
          when 1 => dut_dat_o <= force not dut_dat_o;
          when 2 => dut_ack_o <= force not dut_ack_o;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_dat_o <= release;
                    dut_ack_o <= release;
          when 1 => dut_dat_o <= release;
          when 2 => dut_ack_o <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Verbosity control
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(ID_UVVM_CMD_RESULT);
    disable_log_msg(ID_AWAIT_COMPLETION);
    disable_log_msg(ID_AWAIT_COMPLETION_LIST);
    disable_log_msg(ID_AWAIT_COMPLETION_WAIT);
    disable_log_msg(WISHBONE_VVCT, 0, ALL_MESSAGES);
    enable_log_msg(WISHBONE_VVCT, 0, ID_BFM);
    WISHBONE_VVC_SB.disable_log_msg(0, ID_DATA);

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Wishbone");
    ------------------------------------------------------------------------------------------------------------------------------
    wait for 3 * C_CLK_PERIOD; -- Wait for reset being released in test harness

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of simple write and check", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_SEQUENCER, "Send continuous write commands", C_SCOPE);
    for i in 0 to 7 loop
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH)), "Writing to FIFO");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

    log(ID_SEQUENCER, "Send continuous check commands", C_SCOPE);
    for i in 0 to 7 loop
      wishbone_check(WISHBONE_VVCT, 0, C_ADDR_FIFO, std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH)), "Checking data from FIFO");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

    log(ID_SEQUENCER, "Send interleaved write and check commands", C_SCOPE);
    for i in 0 to 7 loop
      v_data := std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH));
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Writing to FIFO");
      wishbone_check(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Checking data from FIFO");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
    wait for 100 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of simple write and read + fetch_result", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_SEQUENCER, "Send write and read commands", C_SCOPE);
    for i in 0 to 7 loop
      v_data := std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH));
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Writing to FIFO");
      wishbone_read(WISHBONE_VVCT, 0, C_ADDR_FIFO, "Reading data from FIFO");
      v_cmd_idx := get_last_received_cmd_idx(WISHBONE_VVCT, 0);
      await_completion(WISHBONE_VVCT, 0, v_cmd_idx, 100 ns, "Waiting for read to finish");
      fetch_result(WISHBONE_VVCT, 0, v_cmd_idx, v_result, "Fetching read-result");
      check_value(v_result(GC_DATA_WIDTH - 1 downto 0), v_data, ERROR, "Checking fetched data");
    end loop;
    wait for 100 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of different addresses", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_SEQUENCER, "Check the FIFO version", C_SCOPE);
    wishbone_check(WISHBONE_VVCT, 0, C_ADDR_VERSION, std_logic_vector(to_unsigned(1, GC_DATA_WIDTH)), "Checking C_ADDR_VERSION");
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
    log(ID_SEQUENCER, "Write 3 words to the FIFO", C_SCOPE);
    wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, random(GC_DATA_WIDTH), "Writing to FIFO");
    wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, random(GC_DATA_WIDTH), "Writing to FIFO");
    wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, random(GC_DATA_WIDTH), "Writing to FIFO");
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
    log(ID_SEQUENCER, "Check the FIFO status", C_SCOPE);
    wishbone_check(WISHBONE_VVCT, 0, C_ADDR_STATUS, std_logic_vector(to_unsigned(3, GC_DATA_WIDTH)), "Checking C_ADDR_STATUS");
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
    log(ID_SEQUENCER, "Read 3 words from the FIFO", C_SCOPE);
    wishbone_read(WISHBONE_VVCT, 0, C_ADDR_FIFO, "Reading data from FIFO");
    wishbone_read(WISHBONE_VVCT, 0, C_ADDR_FIFO, "Reading data from FIFO");
    wishbone_read(WISHBONE_VVCT, 0, C_ADDR_FIFO, "Reading data from FIFO");
    log(ID_SEQUENCER, "Check the FIFO status", C_SCOPE);
    wishbone_check(WISHBONE_VVCT, 0, C_ADDR_STATUS, std_logic_vector(to_unsigned(0, GC_DATA_WIDTH)), "Checking C_ADDR_STATUS");
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
    wait for 100 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of bfm_sync = SYNC_WITH_SETUP_AND_HOLD", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    shared_wishbone_vvc_config(0).bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    shared_wishbone_vvc_config(0).bfm_config.clock_period := C_CLK_PERIOD;
    shared_wishbone_vvc_config(0).bfm_config.setup_time   := C_CLK_PERIOD / 4;
    shared_wishbone_vvc_config(0).bfm_config.hold_time    := C_CLK_PERIOD / 4;

    log(ID_SEQUENCER, "Send continuous write commands", C_SCOPE);
    for i in 0 to 7 loop
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH)), "Writing to FIFO");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

    log(ID_SEQUENCER, "Send continuous check commands", C_SCOPE);
    for i in 0 to 7 loop
      wishbone_check(WISHBONE_VVCT, 0, C_ADDR_FIFO, std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH)), "Checking data from FIFO");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

    log(ID_SEQUENCER, "Send interleaved write and check commands", C_SCOPE);
    for i in 0 to 7 loop
      v_data := std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH));
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Writing to FIFO");
      wishbone_check(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Checking data from FIFO");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
    wait for 100 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Test of scoreboard", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_SEQUENCER, "Send write commands and add expected values to Scoreboard", C_SCOPE);
    for i in 0 to 7 loop
      v_data := std_logic_vector(to_unsigned(i + 1, GC_DATA_WIDTH));
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Writing to FIFO");
      WISHBONE_VVC_SB.add_expected(0, pad_wishbone_sb(v_data));
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

    log(ID_SEQUENCER, "Send read commands and compare data in the Scoreboard", C_SCOPE);
    for i in 0 to 7 loop
      wishbone_read(WISHBONE_VVCT, 0, C_ADDR_FIFO, TO_SB, "Reading data from FIFO and storing it in the Scoreboard");
    end loop;
    await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

    WISHBONE_VVC_SB.report_counters(ALL_INSTANCES);
    wait for 100 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    for i in 0 to 2 loop
      -- Test different alert severity configurations
      if i = 0 then
        v_alert_level := C_WISHBONE_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
      elsif i = 1 then
        v_alert_level := FAILURE;
      else
        v_alert_level := NO_ALERT;
      end if;
      log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
      shared_wishbone_vvc_config(0).unwanted_activity_severity := v_alert_level;

      log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
      v_data := random(GC_DATA_WIDTH);
      wishbone_write(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Writing to FIFO");
      await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");
      wishbone_check(WISHBONE_VVCT, 0, C_ADDR_FIFO, v_data, "Checking data from FIFO");
      await_completion(WISHBONE_VVCT, 0, 1 us, "Awaiting execution");

      -- Test with and without a time gap between await_completion and unexpected data transmission
      if i = 0 then
        log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
        wait for 100 ns;
      else
        log(ID_SEQUENCER, "Wait 1 clock period", C_SCOPE); -- Avoid skipping the checking in the p_unwanted_activity
        wait for C_CLK_PERIOD;
      end if;

      log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
      toggle_vvc_if(v_alert_level);
    end loop;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(1000 ns, print_alert_counters => REPORT_ALERT_COUNTERS_FINAL, scope => C_SCOPE);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;

end architecture tb;
