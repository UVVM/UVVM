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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_rgmii;
context bitvis_vip_rgmii.vvc_context;

--hdlregression:tb
-- Test case entity
entity rgmii_vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of rgmii_vvc_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 8 ns; -- 125 MHz
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  constant C_VVC_IDX : natural := 0;

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk       : std_logic := '0';
  signal clock_ena : boolean   := false;

  signal rgmii_tx_if : t_rgmii_tx_if;
  signal rgmii_rx_if : t_rgmii_rx_if;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "RGMII CLK");

  --------------------------------------------------------------------------------
  -- Instantiate test harness
  --------------------------------------------------------------------------------
  i_test_harness : entity work.rgmii_th(struct_vvc)
    generic map(
      GC_CLK_PERIOD => C_CLK_PERIOD
    )
    port map(
      clk         => clk,
      rgmii_tx_if => rgmii_tx_if,
      rgmii_rx_if => rgmii_rx_if
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_data_array    : t_byte_array(0 to 99);
    variable v_cmd_idx       : natural;
    variable v_result        : bitvis_vip_rgmii.vvc_cmd_pkg.t_vvc_result;
    variable v_alert_level   : t_alert_level;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 2;
    alias dut_txd    is << signal i_test_harness.dut_txd    : std_logic_vector >>;
    alias dut_tx_ctl is << signal i_test_harness.dut_tx_ctl : std_logic >>;

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
          when 0 => dut_txd    <= force not dut_txd;
                    dut_tx_ctl <= force not dut_tx_ctl;
          when 1 => dut_txd    <= force not dut_txd;
          when 2 => dut_tx_ctl <= force not dut_tx_ctl;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_txd    <= release;
                    dut_tx_ctl <= release;
          when 1 => dut_txd    <= release;
          when 2 => dut_tx_ctl <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;
        wait for 0 ns; -- Wait an extra delta cycle so that the value is propagated from the non-record to the record signals
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(RGMII_VVCT, C_VVC_IDX, ALL_CHANNELS, ID_CMD_INTERPRETER);
    disable_log_msg(RGMII_VVCT, C_VVC_IDX, ALL_CHANNELS, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(RGMII_VVCT, C_VVC_IDX, ALL_CHANNELS, ID_CMD_EXECUTOR);
    disable_log_msg(RGMII_VVCT, C_VVC_IDX, ALL_CHANNELS, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(RGMII_VVCT, C_VVC_IDX, ALL_CHANNELS, ID_IMMEDIATE_CMD_WAIT);

    -- Override default config with settings for this testbench
    shared_rgmii_vvc_config(TX, C_VVC_IDX).bfm_config.clock_period  := C_CLK_PERIOD;
    shared_rgmii_vvc_config(RX, C_VVC_IDX).bfm_config.clock_period  := C_CLK_PERIOD;
    shared_rgmii_vvc_config(RX, C_VVC_IDX).bfm_config.rx_clock_skew := C_CLK_PERIOD / 4;

    -- Generate random data
    for i in v_data_array'range loop
      v_data_array(i) := random(v_data_array(0)'length);
    end loop;

    ------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of RGMII");
    ------------------------------------------------------------------------------
    clock_ena <= true;                  -- start clock generator
    wait for 10 * C_CLK_PERIOD;

    log(ID_LOG_HDR, "Testing that BFM procedures normalize data arrays");
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(2 to 6), "");
    rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, v_data_array(2 to 6), "");
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, (x"01", x"23", x"45", x"67", x"89"), "");
    rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, (x"01", x"23", x"45", x"67", x"89"), "");
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing data sizes");
    for i in 0 to 30 loop
      rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to i), "");
      rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, v_data_array(0 to i), "");
    end loop;
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing a multiple byte transfer in a single transaction");
    for i in 0 to 30 loop
      if i < 30 then
        rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to i), HOLD_LINE_AFTER_TRANSFER, "");
      else
        rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to i), RELEASE_LINE_AFTER_TRANSFER, "");
      end if;
    end loop;
    for i in 0 to 30 loop
      rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, v_data_array(0 to i), "");
    end loop;
    wait for 497 * C_CLK_PERIOD;
    check_stable(rgmii_tx_if.tx_ctl, 496 * C_CLK_PERIOD, ERROR, "Checking that TX_CTL was held high during the complete transfer", C_SCOPE);
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing read and fetch");
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array, "");
    rgmii_read(RGMII_VVCT, C_VVC_IDX, RX, "");
    v_cmd_idx := get_last_received_cmd_idx(RGMII_VVCT, C_VVC_IDX, RX);
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, v_cmd_idx, 10 us);
    fetch_result(RGMII_VVCT, C_VVC_IDX, RX, v_cmd_idx, v_result);
    for i in 0 to v_result.data_array_length - 1 loop
      check_value(v_result.data_array(i), v_data_array(i), ERROR, "Checking fetch result: v_data_array");
    end loop;

    log(ID_LOG_HDR, "Testing error case: write() txc timeout");
    clock_ena <= false;
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 10), "");
    wait for 10 * C_CLK_PERIOD;         -- 10 = default max_wait_cycles
    wait for 0 ns;

    log(ID_LOG_HDR, "Testing error case: read() rxc timeout");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_read(RGMII_VVCT, C_VVC_IDX, RX, "");
    wait for 10 * C_CLK_PERIOD;         -- 10 = default max_wait_cycles
    wait for 0 ns;
    clock_ena <= true;

    log(ID_LOG_HDR, "Testing error case: read() rx_ctl timeout");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_read(RGMII_VVCT, C_VVC_IDX, RX, "");
    wait for 12 * C_CLK_PERIOD;         -- 10 = default max_wait_cycles
    wait for 0 ns;

    log(ID_LOG_HDR, "Testing error case: expect() wrong data");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 10), "");
    rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, v_data_array(10 to 20), "");
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing error case: expect() wrong size of data_array");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 10), "");
    rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, v_data_array(0 to 15), "");
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing scoreboard");
    rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 19), "");
    for i in 0 to 19 loop
      RGMII_VVC_SB.add_expected(C_VVC_IDX, v_data_array(i));
    end loop;
    rgmii_read(RGMII_VVCT, C_VVC_IDX, RX, TO_SB, "Sending received data to SB");
    await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

    RGMII_VVC_SB.report_counters(ALL_INSTANCES);

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    for i in 0 to 2 loop
      -- Test different alert severity configurations
      if i = 0 then
        v_alert_level := C_RGMII_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
      elsif i = 1 then
        v_alert_level := FAILURE;
      else
        v_alert_level := NO_ALERT;
      end if;
      log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
      shared_rgmii_vvc_config(RX, C_VVC_IDX).unwanted_activity_severity := v_alert_level;

      log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
      rgmii_write(RGMII_VVCT, C_VVC_IDX, TX, v_data_array(2 to 6), "Write data");
      rgmii_expect(RGMII_VVCT, C_VVC_IDX, RX, v_data_array(2 to 6), "Expect data");
      await_completion(RGMII_VVCT, C_VVC_IDX, RX, 10 us);

      -- Test with and without a time gap between await_completion and unexpected data transmission
      if i = 0 then
        log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
        wait for 100 ns;
      end if;

      log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
      toggle_vvc_if(v_alert_level);
    end loop;


    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- Allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
