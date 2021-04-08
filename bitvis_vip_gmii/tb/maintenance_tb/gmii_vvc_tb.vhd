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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

--hdlunit:tb
-- Test case entity
entity gmii_vvc_tb is
  generic(
    GC_TESTCASE : string  := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of gmii_vvc_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 8 ns; -- 125 MHz
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  constant C_VVC_IDX    : natural := 0;

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk         : std_logic := '0';
  signal clock_ena   : boolean   := false;

  signal gmii_tx_if : t_gmii_tx_if;
  signal gmii_rx_if : t_gmii_rx_if;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "GMII CLK");

  --------------------------------------------------------------------------------
  -- Instantiate test harness
  --------------------------------------------------------------------------------
  i_gmii_test_harness : entity bitvis_vip_gmii.test_harness(struct_vvc)
    generic map (
      GC_CLK_PERIOD => C_CLK_PERIOD
    )
    port map (
      clk          => clk,
      gmii_tx_if   => gmii_tx_if,
      gmii_rx_if   => gmii_rx_if
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_data_array     : t_byte_array(0 to 99);
    variable v_rx_data_array  : t_byte_array(0 to 99);
    variable v_data_len       : natural;
    variable v_cmd_idx        : natural;
    variable v_result         : bitvis_vip_gmii.vvc_cmd_pkg.t_vvc_result;

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
    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, TX, ID_CMD_INTERPRETER);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, RX, ID_CMD_INTERPRETER);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, TX, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, RX, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, TX, ID_CMD_EXECUTOR);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, RX, ID_CMD_EXECUTOR);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, TX, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, RX, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(GMII_VVCT, C_VVC_IDX, RX, ID_IMMEDIATE_CMD_WAIT);

    -- Generate random data
    for i in v_data_array'range loop
      v_data_array(i) := random(v_data_array(0)'length);
    end loop;

    ------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of GMII");
    ------------------------------------------------------------------------------
    clock_ena <= true; -- start clock generator
    wait for 10*C_CLK_PERIOD;

    log(ID_LOG_HDR, "Testing that BFM procedures normalize data arrays");
    gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(2 to 6), "");
    gmii_expect(GMII_VVCT, C_VVC_IDX, RX, v_data_array(2 to 6), "");
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
    gmii_write(GMII_VVCT, C_VVC_IDX, TX, (x"01", x"23", x"45", x"67", x"89"), "");
    gmii_expect(GMII_VVCT, C_VVC_IDX, RX, (x"01", x"23", x"45", x"67", x"89"), "");
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing data sizes");
    for i in 0 to 30 loop
      gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to i), "");
      gmii_expect(GMII_VVCT, C_VVC_IDX, RX, v_data_array(0 to i), "");
    end loop;
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing read and fetch");
    gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array, "");
    gmii_read(GMII_VVCT, C_VVC_IDX, RX, "");
    v_cmd_idx := get_last_received_cmd_idx(GMII_VVCT, C_VVC_IDX, RX);
    await_completion(GMII_VVCT, C_VVC_IDX, RX, v_cmd_idx, 10 us);
    fetch_result(GMII_VVCT, C_VVC_IDX, RX, v_cmd_idx, v_result);
    for i in 0 to v_result.data_array_length-1 loop
      check_value(v_result.data_array(i), v_data_array(i), ERROR, "Checking fetch result: v_data_array");
    end loop;

    log(ID_LOG_HDR, "Testing error case: read() valid data timeout");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    gmii_read(GMII_VVCT, C_VVC_IDX, RX, "");
    wait for 12*C_CLK_PERIOD; -- 10 = default max_wait_cycles

    log(ID_LOG_HDR, "Testing error case: expect() wrong data");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 10), "");
    gmii_expect(GMII_VVCT, C_VVC_IDX, RX, v_data_array(10 to 20), "");
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing error case: expect() wrong size of data_array");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 10), "");
    gmii_expect(GMII_VVCT, C_VVC_IDX, RX, v_data_array(0 to 15), "");
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing setup and hold times");
    shared_gmii_vvc_config(TX, C_VVC_IDX).bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    shared_gmii_vvc_config(TX, C_VVC_IDX).bfm_config.clock_period := C_CLK_PERIOD;
    shared_gmii_vvc_config(TX, C_VVC_IDX).bfm_config.setup_time   := C_CLK_PERIOD/4;
    shared_gmii_vvc_config(TX, C_VVC_IDX).bfm_config.hold_time    := C_CLK_PERIOD/4;
    shared_gmii_vvc_config(RX, C_VVC_IDX).bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    shared_gmii_vvc_config(RX, C_VVC_IDX).bfm_config.clock_period := C_CLK_PERIOD;
    shared_gmii_vvc_config(RX, C_VVC_IDX).bfm_config.setup_time   := C_CLK_PERIOD/4;
    shared_gmii_vvc_config(RX, C_VVC_IDX).bfm_config.hold_time    := C_CLK_PERIOD/4;
    for i in 0 to 10 loop
      gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to i), "");
      gmii_expect(GMII_VVCT, C_VVC_IDX, RX, v_data_array(0 to i), "");
    end loop;
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    log(ID_LOG_HDR, "Testing scoreboard");
    gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 19), "");
    for i in 0 to 19 loop
      GMII_VVC_SB.add_expected(C_VVC_IDX, v_data_array(i));
    end loop;
    gmii_read(GMII_VVCT, C_VVC_IDX, RX, TO_SB, "Sending received data to SB");
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    gmii_write(GMII_VVCT, C_VVC_IDX, TX, v_data_array(0 to 9), "");
    for i in 0 to 9 loop
      GMII_VVC_SB.add_expected(C_VVC_IDX, v_data_array(i));
    end loop;
    gmii_read(GMII_VVCT, C_VVC_IDX, RX, 10, TO_SB, "Sending received data to SB");
    await_completion(GMII_VVCT, C_VVC_IDX, RX, 10 us);

    GMII_VVC_SB.report_counters(ALL_INSTANCES);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- Allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end func;