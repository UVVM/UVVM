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

library bitvis_vip_rgmii;
use bitvis_vip_rgmii.rgmii_bfm_pkg.all;

--hdlregression:tb
-- Test case entity
entity rgmii_bfm_tb is
  generic(
    GC_TESTCASE : string  := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of rgmii_bfm_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time := 8 ns; -- 125 MHz

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk         : std_logic := '0';
  signal clock_ena   : boolean   := false;

  signal rgmii_tx_if : t_rgmii_tx_if;
  signal rgmii_rx_if : t_rgmii_rx_if;

  signal data_array  : t_byte_array(0 to 99);

begin

  --------------------------------------------------------------------------------
  -- Clock Generator
  --------------------------------------------------------------------------------
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "RGMII CLK");

  --------------------------------------------------------------------------------
  -- Instantiate test harness
  --------------------------------------------------------------------------------
  i_rgmii_test_harness : entity bitvis_vip_rgmii.test_harness(struct_bfm)
    generic map (
      GC_CLK_PERIOD => C_CLK_PERIOD
    )
    port map (
      clk           => clk,
      rgmii_tx_if   => rgmii_tx_if,
      rgmii_rx_if   => rgmii_rx_if
    );

  --------------------------------------------------------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------------------------------------------------------
  p_main : process
    constant c_scope            : string := "Main seq.";
    variable v_rgmii_bfm_config : t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;

    --------------------------------------------
    -- Overloads for this testbench
    --------------------------------------------
    procedure rgmii_write (
      data_array : in t_byte_array) is
    begin
      rgmii_write(data_array, "", rgmii_tx_if, c_scope, shared_msg_id_panel, v_rgmii_bfm_config);
    end procedure;

  begin

    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    enable_log_msg(ALL_MESSAGES);

    -- Generate random data
    for i in data_array'range loop
      data_array(i) <= random(data_array(0)'length);
    end loop;

    -- Override default config with settings for this testbench
    v_rgmii_bfm_config.clock_period  := C_CLK_PERIOD;

    ------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of RGMII");
    ------------------------------------------------------------------------------
    clock_ena <= true; -- start clock generator
    wait for 10*C_CLK_PERIOD;

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing that BFM procedures normalize data arrays");
    rgmii_write(data_array(2 to 6));
    rgmii_write(data_array(3 to 9));

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
    rgmii_write((x"01", x"23", x"45", x"67", x"89"));

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing data sizes");
    for i in 0 to 30 loop
      rgmii_write(data_array(0 to i));
    end loop;

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing error case: write() txc timeout");
    clock_ena <= false;
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_write(data_array(0 to 10));

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing error case: read() rxc timeout");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    wait for 10*C_CLK_PERIOD; -- 10 = default max_wait_cycles
    clock_ena <= true;

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing error case: read() rx_ctl timeout");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    wait for 10*C_CLK_PERIOD; -- 10 = default max_wait_cycles

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing error case: expect() wrong data");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_write(data_array(0 to 10));

    await_barrier(global_barrier, 1 us, "Synchronizing TX", error, c_scope);
    log(ID_LOG_HDR, "Testing error case: expect() wrong size of data_array");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    rgmii_write(data_array(0 to 10));

    ------------------------------------------------------------------------------
    -- Ending the simulation
    ------------------------------------------------------------------------------
    wait for 1000 ns;             -- Allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", c_scope);
    -- Finish the simulation
    std.env.stop;
    wait; -- to stop completely

  end process p_main;


  --------------------------------------------------------------------------------------------------------------------------------
  -- PROCESS: p_slave
  --------------------------------------------------------------------------------------------------------------------------------
  p_slave : process
    constant c_scope            : string := "Slave seq.";
    variable v_rgmii_bfm_config : t_rgmii_bfm_config := C_RGMII_BFM_CONFIG_DEFAULT;
    variable v_rx_data_array    : t_byte_array(0 to 99);
    variable v_data_len         : natural;

    --------------------------------------------
    -- Overloads for this testbench
    --------------------------------------------
    procedure rgmii_read (
      data_array : out t_byte_array;
      data_len   : out natural) is
    begin
      rgmii_read(data_array, data_len, "", rgmii_rx_if, c_scope, shared_msg_id_panel, v_rgmii_bfm_config);
    end procedure;

    procedure rgmii_expect (
      data_exp : in t_byte_array) is
    begin
      rgmii_expect(data_exp, "", rgmii_rx_if, error, c_scope, shared_msg_id_panel, v_rgmii_bfm_config);
    end procedure;

  begin

    -- Override default config with settings for this testbench
    v_rgmii_bfm_config.clock_period  := C_CLK_PERIOD;
    v_rgmii_bfm_config.rx_clock_skew := C_CLK_PERIOD/4;

    -- Testing that BFM procedures normalize data arrays
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    rgmii_read(v_rx_data_array(2 to 6), v_data_len);
    rgmii_expect(data_array(3 to 9));

    -- Testing explicit std_logic_vector values
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    rgmii_expect((x"01", x"23", x"45", x"67", x"89"));

    -- Testing data sizes
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    for i in 0 to 30 loop
      rgmii_expect(data_array(0 to i));
    end loop;

    -- Testing error case: write() txc timeout
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    wait for 10*C_CLK_PERIOD; -- 10 = default max_wait_cycles

    -- Testing error case: read() rxc timeout
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    rgmii_read(v_rx_data_array, v_data_len);

    -- Testing error case: read() rx_ctl timeout
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    rgmii_read(v_rx_data_array, v_data_len);

    -- Testing error case: expect() wrong data
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    rgmii_expect(data_array(10 to 20));

    -- Testing error case: expect() wrong size of data_array
    await_barrier(global_barrier, 1 us, "Synchronizing RX", error, c_scope);
    rgmii_expect(data_array(0 to 15));

    wait;  -- to stop completely

  end process p_slave;

end func;