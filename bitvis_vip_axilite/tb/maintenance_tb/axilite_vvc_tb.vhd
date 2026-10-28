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

library bitvis_vip_axilite;
context bitvis_vip_axilite.vvc_context;
use bitvis_vip_axilite.vvc_sb_support_pkg.all;

--hdlregression:tb
-- Test case entity
entity axilite_vvc_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of axilite_vvc_tb is

  constant C_CLK_PERIOD   : time    := 10 ns;
  constant C_ADDR_WIDTH_1 : natural := 32;
  constant C_DATA_WIDTH_1 : natural := 32;
  constant C_ADDR_WIDTH_2 : natural := 32;
  constant C_DATA_WIDTH_2 : natural := 64;

  signal clk       : std_logic := '0';
  signal areset    : std_logic := '0';
  signal clock_ena : boolean   := false;
  signal transaction_info_trigger_seen : boolean := false;

  -- signals
  -- The axilite interface is gathered in one record, so procedures that use the
  -- axilite interface have less arguments
  signal axilite_if_1 : t_axilite_if(write_address_channel(awaddr(C_ADDR_WIDTH_1 - 1 downto 0)),
                                     write_data_channel(wdata(C_DATA_WIDTH_1 - 1 downto 0),
                                                        wstrb((C_DATA_WIDTH_1 / 8) - 1 downto 0)),
                                     read_address_channel(araddr(C_ADDR_WIDTH_1 - 1 downto 0)),
                                     read_data_channel(rdata(C_DATA_WIDTH_1 - 1 downto 0)));

  signal axilite_if_2 : t_axilite_if(write_address_channel(awaddr(C_ADDR_WIDTH_2 - 1 downto 0)),
                                     write_data_channel(wdata(C_DATA_WIDTH_2 - 1 downto 0),
                                                        wstrb((C_DATA_WIDTH_2 / 8) - 1 downto 0)),
                                     read_address_channel(araddr(C_ADDR_WIDTH_2 - 1 downto 0)),
                                     read_data_channel(rdata(C_DATA_WIDTH_2 - 1 downto 0)));

begin
  -----------------------------
  -- Instantiate Testharness
  -----------------------------
  i_test_harness : entity work.axilite_th(struct_vvc)
    generic map(
      C_DATA_WIDTH_1 => C_DATA_WIDTH_1,
      C_ADDR_WIDTH_1 => C_ADDR_WIDTH_1,
      C_DATA_WIDTH_2 => C_DATA_WIDTH_2,
      C_ADDR_WIDTH_2 => C_ADDR_WIDTH_2
    )
    port map(
      clk          => clk,
      areset       => areset,
      axilite_if_1 => axilite_if_1,
      axilite_if_2 => axilite_if_2
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  p_transaction_info_trigger : process
  begin
    wait until global_axilite_vvc_transaction_trigger(1) = '1';
    transaction_info_trigger_seen <= true;
    wait;
  end process p_transaction_info_trigger;

  -- Set up clock generator
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "Axilite CLK");

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE         : string := C_TB_SCOPE_DEFAULT;
    variable v_timestamp     : time;
    variable v_measured_time : time;
    variable v_cmd_idx       : natural;
    variable v_is_ok         : boolean;
    variable v_data          : work.vvc_cmd_pkg.t_vvc_result;
    variable v_alert_config  : t_axilite_unwanted_transaction;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 5;
    alias dut_bresp  is << signal i_test_harness.i_axilite_slave_1.S_AXI_BRESP  : std_logic_vector >>;
    alias dut_bvalid is << signal i_test_harness.i_axilite_slave_1.S_AXI_BVALID : std_logic >>;
    alias dut_rdata  is << signal i_test_harness.i_axilite_slave_1.S_AXI_RDATA  : std_logic_vector >>;
    alias dut_rresp  is << signal i_test_harness.i_axilite_slave_1.S_AXI_RRESP  : std_logic_vector >>;
    alias dut_rvalid is << signal i_test_harness.i_axilite_slave_1.S_AXI_RVALID : std_logic >>;
    -- Used to make the VVC time out
    alias dut_awready is << signal i_test_harness.i_axilite_slave_1.S_AXI_AWREADY : std_logic >>;
    alias dut_wready  is << signal i_test_harness.i_axilite_slave_1.S_AXI_WREADY  : std_logic >>;
    alias dut_arready is << signal i_test_harness.i_axilite_slave_1.S_AXI_ARREADY : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_config : in t_axilite_unwanted_transaction
    ) is
      -- Alert counter array including NO_ALERT (ignored in checks) for easier indexing
      type t_alert_counters_arr is array(t_alert_level) of natural;
      variable v_expected_alert_counters : t_alert_counters_arr;
      variable v_rand                    : t_rand;
    begin
      -- Populate local alert counters
      for alert_level in v_expected_alert_counters'range loop
        v_expected_alert_counters(alert_level) := get_alert_counter(alert_level);
      end loop;
      -- Each pass toggles one signal, except pass 0 which toggles all five at once. That gives
      -- (5 individually + 5 together) alerts per toggle direction, so two per pass except pass 0.
      if alert_config.bresp /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.bresp, 4);
      end if;
      if alert_config.bvalid /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.bvalid, 4);
      end if;
      if alert_config.rdata /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.rdata, 4);
      end if;
      if alert_config.rresp /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.rresp, 4);
      end if;
      if alert_config.rvalid /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.rvalid, 4);
      end if;
      -- Pass 0 forces all five signals at once; passes 1-5 force one signal each. Both must
      -- raise unwanted transaction alerts, because the VVC is not driving a transaction here.
      for i in 0 to C_NUM_VVC_SIGNALS loop
        -- Update expected alert counters
        case i is
          when 0 => v_expected_alert_counters(alert_config.bresp)  := v_expected_alert_counters(alert_config.bresp)  + 1;
                    v_expected_alert_counters(alert_config.bvalid) := v_expected_alert_counters(alert_config.bvalid) + 1;
                    v_expected_alert_counters(alert_config.rdata)  := v_expected_alert_counters(alert_config.rdata) + 1;
                    v_expected_alert_counters(alert_config.rresp)  := v_expected_alert_counters(alert_config.rresp)  + 1;
                    v_expected_alert_counters(alert_config.rvalid) := v_expected_alert_counters(alert_config.rvalid) + 1;
          when 1 => v_expected_alert_counters(alert_config.bresp)  := v_expected_alert_counters(alert_config.bresp) + 1;
          when 2 => v_expected_alert_counters(alert_config.bvalid) := v_expected_alert_counters(alert_config.bvalid) + 1;
          when 3 => v_expected_alert_counters(alert_config.rdata)  := v_expected_alert_counters(alert_config.rdata) + 1;
          when 4 => v_expected_alert_counters(alert_config.rresp)  := v_expected_alert_counters(alert_config.rresp) + 1;
          when 5 => v_expected_alert_counters(alert_config.rvalid) := v_expected_alert_counters(alert_config.rvalid) + 1;
        end case;
        -- Force new value
        case i is
          when 0 => dut_bresp  <= force not dut_bresp;
                    dut_bvalid <= force not dut_bvalid;
                    dut_rdata  <= force not dut_rdata;
                    dut_rresp  <= force not dut_rresp;
                    dut_rvalid <= force not dut_rvalid;
          when 1 => dut_bresp  <= force not dut_bresp;
          when 2 => dut_bvalid <= force not dut_bvalid;
          when 3 => dut_rdata  <= force not dut_rdata;
          when 4 => dut_rresp  <= force not dut_rresp;
          when 5 => dut_rvalid <= force not dut_rvalid;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        -- Loop through all error levels (except NO_ALERT) and check with expected
        for alert_level in v_expected_alert_counters(NOTE to t_alert_level'right)'range loop
          check_value(get_alert_counter(alert_level), v_expected_alert_counters(alert_level), TB_NOTE, "Unwanted transaction alert was expected", C_SCOPE, ID_NEVER);
        end loop;
        -- Release the force and check the alert count again, to catch a spurious extra alert
        -- from the release itself.
        -- Update expected alert counters
        case i is
          when 0 => v_expected_alert_counters(alert_config.bresp)  := v_expected_alert_counters(alert_config.bresp)  + 1;
                    v_expected_alert_counters(alert_config.bvalid) := v_expected_alert_counters(alert_config.bvalid) + 1;
                    v_expected_alert_counters(alert_config.rdata)  := v_expected_alert_counters(alert_config.rdata) + 1;
                    v_expected_alert_counters(alert_config.rresp)  := v_expected_alert_counters(alert_config.rresp)  + 1;
                    v_expected_alert_counters(alert_config.rvalid) := v_expected_alert_counters(alert_config.rvalid) + 1;
          when 1 => v_expected_alert_counters(alert_config.bresp)  := v_expected_alert_counters(alert_config.bresp) + 1;
          when 2 => v_expected_alert_counters(alert_config.bvalid) := v_expected_alert_counters(alert_config.bvalid) + 1;
          when 3 => v_expected_alert_counters(alert_config.rdata)  := v_expected_alert_counters(alert_config.rdata) + 1;
          when 4 => v_expected_alert_counters(alert_config.rresp)  := v_expected_alert_counters(alert_config.rresp) + 1;
          when 5 => v_expected_alert_counters(alert_config.rvalid) := v_expected_alert_counters(alert_config.rvalid) + 1;
        end case;
        -- Set back original value
        case i is
          when 0 => dut_bresp  <= release;
                    dut_bvalid <= release;
                    dut_rdata  <= release;
                    dut_rresp  <= release;
                    dut_rvalid <= release;
          when 1 => dut_bresp  <= release;
          when 2 => dut_bvalid <= release;
          when 3 => dut_rdata  <= release;
          when 4 => dut_rresp  <= release;
          when 5 => dut_rvalid <= release;
        end case;
        wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
        wait for 0 ns;
        wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
        -- Loop through all error levels (except NO_ALERT) and check with expected
        for alert_level in v_expected_alert_counters(NOTE to t_alert_level'right)'range loop
          check_value(get_alert_counter(alert_level), v_expected_alert_counters(alert_level), TB_NOTE, "Unwanted transaction alert was expected", C_SCOPE, ID_NEVER);
        end loop;
      end loop;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);

    disable_log_msg(AXILITE_VVCT, 1, ALL_MESSAGES);
    disable_log_msg(AXILITE_VVCT, 2, ALL_MESSAGES);
    enable_log_msg(AXILITE_VVCT, 1, ID_BFM);
    enable_log_msg(AXILITE_VVCT, 2, ID_BFM);
    enable_log_msg(AXILITE_VVCT, 1, ID_IMMEDIATE_CMD);
    enable_log_msg(AXILITE_VVCT, 2, ID_IMMEDIATE_CMD);

    shared_axilite_vvc_config(1).bfm_config.clock_period := C_CLK_PERIOD;
    shared_axilite_vvc_config(2).bfm_config.clock_period := C_CLK_PERIOD;

    log(ID_LOG_HDR, "Start Simulation of AXI-Lite", C_SCOPE);
    ------------------------------------------------------------
    clock_ena <= true;                  -- the axilite_reset routine assumes the clock is running
    gen_pulse(areset, 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");

    log("Do some axilite writes", C_SCOPE);
    -- write some data; the current axislave isn't very implemented - doesn't
    -- have FIFO, and just has one RW slave register at addr_valueess 0x6000

    -- Write to VVC 1
    axilite_write(AXILITE_VVCT, 1, x"0000", x"5555", "Test of axilite write");
    axilite_write(AXILITE_VVCT, 1, x"1000", x"befbeef", "Write"); -- op0
    axilite_write(AXILITE_VVCT, 1, x"2000", x"efbeef", "Write"); -- op1
    axilite_write(AXILITE_VVCT, 1, x"3000", x"beef", "Write"); -- op2
    axilite_write(AXILITE_VVCT, 1, x"6000", x"54321", "Write"); -- rw reg
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    check_value(transaction_info_trigger_seen, ERROR, "AXI-Lite transaction information trigger was not asserted", C_SCOPE, ID_NEVER);

    -- Read from VVC 1
    axilite_read(AXILITE_VVCT, 1, x"3000", ""); -- just do a read
    axilite_read(AXILITE_VVCT, 1, x"6000", ""); -- do another read - should see this data

    -- verify read data on interface 1
    v_cmd_idx := get_last_received_cmd_idx(AXILITE_VVCT, 1);
    await_completion(AXILITE_VVCT, 1, 1 us, "waiting for axilite_read() to finish");
    fetch_result(AXILITE_VVCT, 1, v_cmd_idx, v_data, v_is_ok, "Fetching read-result.");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    check_value(v_data(C_DATA_WIDTH_1 - 1 downto 0), x"54321", error, "verifying read data on interface 1.");

    -- Write to VVC 2
    axilite_write(AXILITE_VVCT, 2, x"0000", x"5555", "Test of axilite write");
    axilite_write(AXILITE_VVCT, 2, x"0010", x"befbeef", "Write"); -- op0
    axilite_write(AXILITE_VVCT, 2, x"0020", x"efbeef", "Write"); -- op1
    axilite_write(AXILITE_VVCT, 2, x"0030", x"beef", "Write"); -- op2
    axilite_write(AXILITE_VVCT, 2, x"0040", x"54321", "Write"); -- op3
    axilite_write(AXILITE_VVCT, 2, x"0060", x"f00b0", "Write"); -- rw reg
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    -- Read from VVC 2
    axilite_read(AXILITE_VVCT, 2, x"0040", ""); -- just do a read
    axilite_read(AXILITE_VVCT, 2, x"0040", ""); -- do another read
    axilite_read(AXILITE_VVCT, 2, x"0060", ""); -- do another read - should see this data

    -- verify read data on interface 2
    v_cmd_idx := get_last_received_cmd_idx(AXILITE_VVCT, 2);
    await_completion(AXILITE_VVCT, 2, 1 us, "waiting for axilite_read() to finish");
    fetch_result(AXILITE_VVCT, 2, v_cmd_idx, v_data, v_is_ok, "Fetching read-result.");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    check_value(v_data(C_DATA_WIDTH_2 - 1 downto 0), x"f00b0", error, "verifying read data on interface 2.");

    -- check that is was correctly written on VVC 1
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"54321", "Check");
    axilite_write(AXILITE_VVCT, 1, x"0006000", x"abba1972", "Write");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"abba1972", "Check");

    -- check that is was correctly written on VVC 2
    axilite_check(AXILITE_VVCT, 2, x"0000", x"5555", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0010", x"befbeef", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0020", x"efbeef", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0030", x"beef", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0040", x"54321", "Check");
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    axilite_write(AXILITE_VVCT, 2, x"0000040", x"abba1972", "Write");
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    axilite_check(AXILITE_VVCT, 2, x"0000040", x"abba1972", "Check");

    -- Await completion on both VVCs
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    log(ID_LOG_HDR, "Test scoreboard", C_SCOPE);
    -- Write to VVC 1
    axilite_write(AXILITE_VVCT, 1, x"0000", x"5555", "Test of axilite write");
    axilite_write(AXILITE_VVCT, 1, x"1000", x"befbeef", "Write"); -- op0
    axilite_write(AXILITE_VVCT, 1, x"2000", x"efbeef", "Write"); -- op1
    axilite_write(AXILITE_VVCT, 1, x"3000", x"beef", "Write"); -- op2
    axilite_write(AXILITE_VVCT, 1, x"6000", x"54321", "Write"); -- rw reg
    axilite_vvc_sb.add_expected(1, pad_axilite_sb(x"54321"));
    await_completion(AXILITE_VVCT, 1, 1000 ns);

    -- Read from VVC 1
    axilite_read(AXILITE_VVCT, 1, x"3000", ""); -- just do a read
    axilite_read(AXILITE_VVCT, 1, x"6000", TO_SB, "Read data and send to SB"); -- do another read - should see this data
    await_completion(AXILITE_VVCT, 1, 1000 ns);

    -- Write to VVC 2
    axilite_write(AXILITE_VVCT, 2, x"0000", x"5555", "Test of axilite write");
    axilite_write(AXILITE_VVCT, 2, x"0010", x"befbeef", "Write"); -- op0
    axilite_write(AXILITE_VVCT, 2, x"0020", x"efbeef", "Write"); -- op1
    axilite_write(AXILITE_VVCT, 2, x"0030", x"beef", "Write"); -- op2
    axilite_write(AXILITE_VVCT, 2, x"0040", x"54321", "Write"); -- op3
    axilite_write(AXILITE_VVCT, 2, x"0060", x"f00b0", "Write"); -- rw reg
    axilite_vvc_sb.add_expected(2, pad_axilite_sb(x"f00b0"));

    -- Read from VVC 2
    axilite_read(AXILITE_VVCT, 2, x"0040", ""); -- just do a read
    axilite_read(AXILITE_VVCT, 2, x"0040", ""); -- do another read
    axilite_read(AXILITE_VVCT, 2, x"0060", TO_SB, "Read data and send to SB"); -- do another read - should see this data
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    axilite_vvc_sb.report_counters(ALL_INSTANCES);

    log(ID_LOG_HDR, "Test of timeout of check", C_SCOPE);

    -- verify that a warning arises if the data is not what is expected
    increment_expected_alerts(WARNING, 1);
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"00000000", "Write", WARNING);
    await_completion(AXILITE_VVCT, 1, 1000 ns);

    -- verify that a warning arises if the data is not what is expected
    increment_expected_alerts(WARNING, 1);
    axilite_check(AXILITE_VVCT, 2, x"0000040", x"00000000", "Check", WARNING);
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    log(ID_LOG_HDR, "Test with byte enable", C_SCOPE);

    axilite_write(AXILITE_VVCT, 1, x"0006000", x"0", "Clearing register");
    axilite_write(AXILITE_VVCT, 1, x"0006000", x"dada1960", std_logic_vector'("0011"), "Write to only byte 0 and 1");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"00001960", "Checking that only byte 0 and 1 were set");
    axilite_write(AXILITE_VVCT, 1, x"0006000", x"0", "Clearing register");
    axilite_write(AXILITE_VVCT, 1, x"0006000", x"dada1960", std_logic_vector'("1100"), "Write to only byte 2 and 3");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"dada0000", "Checking that only byte 2 and 3 were set");

    axilite_write(AXILITE_VVCT, 2, x"0000040", x"0", "Clearing register");
    axilite_write(AXILITE_VVCT, 2, x"0000040", x"abba1972", std_logic_vector'("00000011"), "Write to only byte 0 and 1");
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    axilite_check(AXILITE_VVCT, 2, x"0000040", x"00001972", "Checking that only byte 0 and 1 were set");
    axilite_write(AXILITE_VVCT, 2, x"0000040", x"0", "Clearing register");
    axilite_write(AXILITE_VVCT, 2, x"0000040", x"abba1972", std_logic_vector'("00001100"), "Write to only byte 2 and 3");
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    axilite_check(AXILITE_VVCT, 2, x"0000040", x"abba0000", "Checking that only byte 2 and 3 were set");

    -- Await completion on both VVCs
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    log(ID_LOG_HDR, "Testing inter-bfm delay", C_SCOPE);

    log("\rChecking TIME_START2START", C_SCOPE);
    wait for C_CLK_PERIOD * 51;
    wait until rising_edge(clk);
    shared_axilite_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
    shared_axilite_vvc_config(1).inter_bfm_delay.delay_in_time := C_CLK_PERIOD * 50;
    axilite_write(AXILITE_VVCT, 1, x"0000", x"1111", "First inter-bfm delay axilite write");
    await_completion(AXILITE_VVCT, 1, (56 * C_CLK_PERIOD));
    v_timestamp                                                := now;
    axilite_write(AXILITE_VVCT, 1, x"0000", x"a1a1", "Second inter-bfm delay axilite write");
    await_completion(AXILITE_VVCT, 1, (56 * C_CLK_PERIOD));
    check_value(now - v_timestamp, C_CLK_PERIOD * 50, ERROR, "Checking that inter-bfm delay was upheld");

    log("\rChecking that insert_delay does not affect inter-BFM delay", C_SCOPE);
    wait for C_CLK_PERIOD * 51;
    wait until rising_edge(clk);
    axilite_write(AXILITE_VVCT, 1, x"0000", x"ffff", "Third inter-bfm delay axilite write");
    await_completion(AXILITE_VVCT, 1, (56 * C_CLK_PERIOD));
    v_timestamp := now;
    insert_delay(AXILITE_VVCT, 1, C_CLK_PERIOD);
    insert_delay(AXILITE_VVCT, 1, C_CLK_PERIOD);
    insert_delay(AXILITE_VVCT, 1, C_CLK_PERIOD);
    insert_delay(AXILITE_VVCT, 1, C_CLK_PERIOD);
    axilite_write(AXILITE_VVCT, 1, x"0000", x"abcd", "Fourth inter-bfm delay axilite write");
    await_completion(AXILITE_VVCT, 1, (56 * C_CLK_PERIOD));
    check_value(now - v_timestamp, C_CLK_PERIOD * 54, ERROR, "Checking that inter-bfm delay was upheld");

    log("\rChecking TIME_START2START and provoking inter-bfm delay violation", C_SCOPE);
    wait for C_CLK_PERIOD * 10;
    shared_axilite_vvc_config(1).inter_bfm_delay.inter_bfm_delay_violation_severity := TB_WARNING;
    shared_axilite_vvc_config(1).inter_bfm_delay.delay_type                         := TIME_START2START;
    shared_axilite_vvc_config(1).inter_bfm_delay.delay_in_time                      := C_CLK_PERIOD;
    axilite_write(AXILITE_VVCT, 1, x"0000", x"0001", "First inter-bfm delay axilite write");
    axilite_write(AXILITE_VVCT, 1, x"0000", x"1000", "Second inter-bfm delay axilite write");
    await_completion(AXILITE_VVCT, 1, 111 * C_CLK_PERIOD);

    log("Setting delay back to initial value", C_SCOPE);
    shared_axilite_vvc_config(1).inter_bfm_delay.delay_type    := NO_DELAY;
    shared_axilite_vvc_config(1).inter_bfm_delay.delay_in_time := 0 ns;

    log(ID_LOG_HDR, "Simulation of AXI-Lite with bfm_sync = SYNC_WITH_SETUP_AND_HOLD, setup_time = 2 ns and hold_time = 3 ns", C_SCOPE);
    ------------------------------------------------------------
    shared_axilite_vvc_config(1).bfm_config.bfm_sync   := SYNC_WITH_SETUP_AND_HOLD;
    shared_axilite_vvc_config(2).bfm_config.bfm_sync   := SYNC_WITH_SETUP_AND_HOLD;
    shared_axilite_vvc_config(1).bfm_config.setup_time := 2 ns;
    shared_axilite_vvc_config(2).bfm_config.setup_time := 2 ns;
    shared_axilite_vvc_config(1).bfm_config.hold_time  := 3 ns;
    shared_axilite_vvc_config(2).bfm_config.hold_time  := 3 ns;
    -- Write to VVC 1
    axilite_write(AXILITE_VVCT, 1, x"0000", x"5555", "Test of axilite write");
    axilite_write(AXILITE_VVCT, 1, x"1000", x"befbeef", "Write"); -- op0
    axilite_write(AXILITE_VVCT, 1, x"2000", x"efbeef", "Write"); -- op1
    axilite_write(AXILITE_VVCT, 1, x"3000", x"beef", "Write"); -- op2
    axilite_write(AXILITE_VVCT, 1, x"6000", x"54321", "Write"); -- rw reg
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    -- Read from VVC 1
    axilite_read(AXILITE_VVCT, 1, x"3000", ""); -- just do a read
    axilite_read(AXILITE_VVCT, 1, x"6000", ""); -- do another read - should see this data
    -- verify read data on interface 1
    v_cmd_idx := get_last_received_cmd_idx(AXILITE_VVCT, 1);
    await_completion(AXILITE_VVCT, 1, 1 us, "waiting for axilite_read() to finish");
    fetch_result(AXILITE_VVCT, 1, v_cmd_idx, v_data, v_is_ok, "Fetching read-result.");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    check_value(v_data(C_DATA_WIDTH_1 - 1 downto 0), x"54321", error, "verifying read data on interface 1.");

    -- Write to VVC 2
    axilite_write(AXILITE_VVCT, 2, x"0000", x"5555", "Test of axilite write");
    axilite_write(AXILITE_VVCT, 2, x"0010", x"befbeef", "Write"); -- op0
    axilite_write(AXILITE_VVCT, 2, x"0020", x"efbeef", "Write"); -- op1
    axilite_write(AXILITE_VVCT, 2, x"0030", x"beef", "Write"); -- op2
    axilite_write(AXILITE_VVCT, 2, x"0040", x"54321", "Write"); -- op3
    axilite_write(AXILITE_VVCT, 2, x"0060", x"f00b0", "Write"); -- rw reg
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    -- Read from VVC 2
    axilite_read(AXILITE_VVCT, 2, x"0040", ""); -- just do a read
    axilite_read(AXILITE_VVCT, 2, x"0040", ""); -- do another read
    axilite_read(AXILITE_VVCT, 2, x"0060", ""); -- do another read - should see this data
    -- verify read data on interface 2
    v_cmd_idx := get_last_received_cmd_idx(AXILITE_VVCT, 2);
    await_completion(AXILITE_VVCT, 2, 1 us, "waiting for axilite_read() to finish");
    fetch_result(AXILITE_VVCT, 2, v_cmd_idx, v_data, v_is_ok, "Fetching read-result.");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    check_value(v_data(C_DATA_WIDTH_2 - 1 downto 0), x"f00b0", error, "verifying read data on interface 2.");

    -- check that is was correctly written on VVC 1
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"54321", "Check");
    axilite_write(AXILITE_VVCT, 1, x"0006000", x"abba1972", "Write");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"abba1972", "Check");

    -- check that is was correctly written on VVC 2
    axilite_check(AXILITE_VVCT, 2, x"0000", x"5555", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0010", x"befbeef", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0020", x"efbeef", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0030", x"beef", "Check");
    axilite_check(AXILITE_VVCT, 2, x"0040", x"54321", "Check");
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    axilite_write(AXILITE_VVCT, 2, x"0000040", x"abba1972", "Write");
    await_completion(AXILITE_VVCT, 2, 1000 ns);
    axilite_check(AXILITE_VVCT, 2, x"0000040", x"abba1972", "Check");

    -- Await completion on both VVCs
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    log(ID_LOG_HDR, "Test of timeout of check", C_SCOPE);
    -- verify that a warning arises if the data is not what is expected
    increment_expected_alerts(WARNING, 1);
    axilite_check(AXILITE_VVCT, 1, x"0006000", x"00000000", "Write", WARNING);
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    -- verify that a warning arises if the data is not what is expected
    increment_expected_alerts(WARNING, 1);
    axilite_check(AXILITE_VVCT, 2, x"0000040", x"00000000", "Check", WARNING);
    await_completion(AXILITE_VVCT, 2, 1000 ns);

    --------------------------------------------------------------------------------------------------------------------
    -- Testing to force single pending transactions
    --------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing to force single pending transactions");
    -- First we measure the time it takes to perform a read and write simultaneously
    v_timestamp                                                   := now;
    axilite_write(AXILITE_VVCT, 2, x"0000", x"5555", "Test of axilite write");
    axilite_read(AXILITE_VVCT, 2, x"0040", "Test of axilite read");
    await_completion(AXILITE_VVCT, 2, 100 us, "Waiting for commands to finish");
    v_measured_time                                               := now - v_timestamp;
    -- Then, we turn on the force_single_penging_transaction setting, and see that it takes about twice as long
    shared_axilite_vvc_config(2).force_single_pending_transaction := true;
    v_timestamp                                                   := now;
    axilite_write(AXILITE_VVCT, 2, x"0000", x"5555", "Test of axilite write");
    axilite_read(AXILITE_VVCT, 2, x"0040", "Test of axilite read");
    await_completion(AXILITE_VVCT, 2, 100 us, "Waiting for commands to finish");
    -- Checking that it takes twice as long (+- 20 %)
    check_value_in_range(now - v_timestamp, v_measured_time * 1.8, v_measured_time * 2.2, ERROR, "Checking that it takes longer time to force a single pending transaction");

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing that the channels are released after a timeout", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    shared_axilite_vvc_config(1).bfm_config.max_wait_cycles          := 10;
    shared_axilite_vvc_config(1).bfm_config.max_wait_cycles_severity := ERROR;
    -- Forcing the slave signals and resetting the slave would trigger unwanted transaction alerts
    shared_axilite_vvc_config(1).unwanted_transaction_severity       := (others => NO_ALERT);

    log(ID_SEQUENCER, "Timeout waiting for AWREADY", C_SCOPE);
    increment_expected_alerts_and_stop_limit(ERROR, 1, "Expecting timeout waiting for AWREADY", C_SCOPE);
    dut_awready <= force '0';
    axilite_write(AXILITE_VVCT, 1, x"6000", x"11111111", "Write with AWREADY held low");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    dut_awready <= release;
    wait until rising_edge(clk);
    check_value(axilite_if_1.write_address_channel.awvalid, '0', ERROR, "Checking that AWVALID is released", C_SCOPE);
    gen_pulse(areset, C_CLK_PERIOD, "Resetting the slave to clear the transfers it accepted while the signal was forced");

    log(ID_SEQUENCER, "Timeout waiting for WREADY", C_SCOPE);
    increment_expected_alerts_and_stop_limit(ERROR, 1, "Expecting timeout waiting for WREADY", C_SCOPE);
    dut_wready <= force '0';
    axilite_write(AXILITE_VVCT, 1, x"6000", x"11111111", "Write with WREADY held low");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    dut_wready <= release;
    wait until rising_edge(clk);
    check_value(axilite_if_1.write_data_channel.wvalid, '0', ERROR, "Checking that WVALID is released", C_SCOPE);
    gen_pulse(areset, C_CLK_PERIOD, "Resetting the slave to clear the transfers it accepted while the signal was forced");

    log(ID_SEQUENCER, "Timeout waiting for BVALID", C_SCOPE);
    increment_expected_alerts_and_stop_limit(ERROR, 1, "Expecting timeout waiting for BVALID", C_SCOPE);
    dut_bvalid <= force '0';
    axilite_write(AXILITE_VVCT, 1, x"6000", x"11111111", "Write with BVALID held low");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    dut_bvalid <= release;
    wait until rising_edge(clk);
    check_value(axilite_if_1.write_response_channel.bready, '0', ERROR, "Checking that BREADY is released", C_SCOPE);
    gen_pulse(areset, C_CLK_PERIOD, "Resetting the slave to clear the transfers it accepted while the signal was forced");

    log(ID_SEQUENCER, "Timeout waiting for ARREADY", C_SCOPE);
    increment_expected_alerts_and_stop_limit(ERROR, 1, "Expecting timeout waiting for ARREADY", C_SCOPE);
    dut_arready <= force '0';
    axilite_read(AXILITE_VVCT, 1, x"6000", "Read with ARREADY held low");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    dut_arready <= release;
    wait until rising_edge(clk);
    check_value(axilite_if_1.read_address_channel.arvalid, '0', ERROR, "Checking that ARVALID is released", C_SCOPE);
    gen_pulse(areset, C_CLK_PERIOD, "Resetting the slave to clear the transfers it accepted while the signal was forced");

    log(ID_SEQUENCER, "Timeout waiting for RVALID", C_SCOPE);
    increment_expected_alerts_and_stop_limit(ERROR, 1, "Expecting timeout waiting for RVALID", C_SCOPE);
    dut_rvalid <= force '0';
    axilite_read(AXILITE_VVCT, 1, x"6000", "Read with RVALID held low");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    dut_rvalid <= release;
    wait until rising_edge(clk);
    check_value(axilite_if_1.read_data_channel.rready, '0', ERROR, "Checking that RREADY is released", C_SCOPE);
    gen_pulse(areset, C_CLK_PERIOD, "Resetting the slave to clear the transfers it accepted while the signal was forced");

    log(ID_SEQUENCER, "Checking that the bus works after the timeouts", C_SCOPE);
    axilite_write(AXILITE_VVCT, 1, x"6000", x"22222222", "Write after the timeouts");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    axilite_check(AXILITE_VVCT, 1, x"6000", x"22222222", "Check after the timeouts");
    await_completion(AXILITE_VVCT, 1, 1000 ns);
    shared_axilite_vvc_config(1).bfm_config.max_wait_cycles          := C_AXILITE_BFM_CONFIG_DEFAULT.max_wait_cycles;
    shared_axilite_vvc_config(1).bfm_config.max_wait_cycles_severity := C_AXILITE_BFM_CONFIG_DEFAULT.max_wait_cycles_severity;
    shared_axilite_vvc_config(1).unwanted_transaction_severity       := C_AXILITE_VVC_CONFIG_DEFAULT.unwanted_transaction_severity;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing Unwanted Transaction Detection in VVC", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    for i in 0 to 4 loop
      -- Test different alert severity configurations
      if i = 0 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to default");
        v_alert_config := C_AXILITE_VVC_CONFIG_DEFAULT.unwanted_transaction_severity;
      elsif i = 1 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to ERROR");
        v_alert_config := (others => ERROR);
      elsif i = 2 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to FAILURE");
        v_alert_config := (others => FAILURE);
      elsif i = 3 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to NO_ALERT");
        v_alert_config := (others => NO_ALERT);
      else
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to different values");
        v_alert_config := (FAILURE, others => ERROR);
      end if;
      shared_axilite_vvc_config(1).unwanted_transaction_severity := v_alert_config;

      log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
      axilite_write(AXILITE_VVCT, 1, x"6000", x"54321", "Write");
      await_completion(AXILITE_VVCT, 1, 1000 ns);
      axilite_check(AXILITE_VVCT, 1, x"0006000", x"54321", "Check");
      await_completion(AXILITE_VVCT, 1, 1000 ns);

      -- Test with and without a time gap between await_completion and unexpected data transmission
      if i = 0 then
        log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
        wait for 100 ns;
      end if;

      log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
      toggle_vvc_if(v_alert_config);
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
end func;
