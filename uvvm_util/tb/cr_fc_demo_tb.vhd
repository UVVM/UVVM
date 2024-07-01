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

library bitvis_uart;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;

--HDLRegression:TB
entity cr_fc_demo_tb is
end entity;

architecture func of cr_fc_demo_tb is

  -- VVC instance indexes
  constant C_SBI_VVC_IDX  : natural := 0;
  constant C_UART_VVC_IDX : natural := 1;

  -- Configuration
  constant C_CLK_PERIOD   : time    := 10 ns;
  constant C_BIT_PERIOD   : time    := 16 * C_CLK_PERIOD;
  constant C_UART_TX_TIME : time    := 11 * C_BIT_PERIOD + C_CLK_PERIOD; -- 1 start bit + 8 data bits + 1 parity bit + 1 stop bit + margin
  constant C_SBI_RX_TIME  : time    := 2 * C_CLK_PERIOD;
  constant C_DATA_WIDTH   : natural := 8;
  constant C_ADDR_WIDTH   : natural := 3;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(C_ADDR_WIDTH - 1 downto 0) := to_unsigned(bitvis_uart.uart_pif_pkg.C_ADDR_RX_DATA, C_ADDR_WIDTH);
  constant C_ADDR_RX_DATA_VALID : unsigned(C_ADDR_WIDTH - 1 downto 0) := to_unsigned(bitvis_uart.uart_pif_pkg.C_ADDR_RX_DATA_VALID, C_ADDR_WIDTH);
  constant C_ADDR_TX_DATA       : unsigned(C_ADDR_WIDTH - 1 downto 0) := to_unsigned(bitvis_uart.uart_pif_pkg.C_ADDR_TX_DATA, C_ADDR_WIDTH);
  constant C_ADDR_TX_READY      : unsigned(C_ADDR_WIDTH - 1 downto 0) := to_unsigned(bitvis_uart.uart_pif_pkg.C_ADDR_TX_READY, C_ADDR_WIDTH);

  -- Clock and reset signals
  signal clk         : std_logic := '0';
  signal clk_ena     : boolean   := false;
  signal arst        : std_logic := '1';
  -- SBI VVC signals
  signal cs          : std_logic;
  signal addr        : unsigned(2 downto 0);
  signal wr          : std_logic;
  signal rd          : std_logic;
  signal wdata       : std_logic_vector(7 downto 0);
  signal rdata       : std_logic_vector(7 downto 0);
  signal ready       : std_logic;
  -- UART VVC signals
  signal uart_vvc_rx : std_logic := '1';
  signal uart_vvc_tx : std_logic := '1';

  shared variable shared_covpt : t_coverpoint;

begin

  ----------------------------------------------------------------------
  -- DUT
  ----------------------------------------------------------------------
  i_dut : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => cs,
      addr  => addr,
      wr    => wr,
      rd    => rd,
      wdata => wdata,
      rdata => rdata,
      -- UART signals
      rx_a  => uart_vvc_tx,
      tx    => uart_vvc_rx
    );

  ----------------------------------------------------------------------
  -- Clock Generator
  ----------------------------------------------------------------------
  clock_generator(clk, clk_ena, C_CLK_PERIOD, "Core clock");

  ----------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  ----------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ----------------------------------------------------------------------
  -- SBI VVC
  ----------------------------------------------------------------------
  i_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH,
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => C_SBI_VVC_IDX)
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => cs,
      sbi_vvc_master_if.rena  => rd,
      sbi_vvc_master_if.wena  => wr,
      sbi_vvc_master_if.addr  => addr,
      sbi_vvc_master_if.wdata => wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => rdata
    );

  -- Static '1' ready signal for the SBI VVC
  ready <= '1';

  ----------------------------------------------------------------------
  -- UART VVC
  ----------------------------------------------------------------------
  i_uart_vvc : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => C_UART_VVC_IDX)
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => uart_vvc_tx
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_data           : integer;
    variable v_data_and_state : integer_vector(0 to 1);
    variable v_rand           : t_rand;
    variable v_cross          : t_coverpoint;

    procedure uart_transmit_and_sbi_check(
      constant data : in integer) is
      constant C_SLV_DATA : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(data, 8));
    begin
      uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, C_SLV_DATA, "UART TX");
      await_completion(UART_VVCT, C_UART_VVC_IDX, TX, C_UART_TX_TIME);
      wait for 200 ns;                  -- margin
      sbi_check(SBI_VVCT, C_SBI_VVC_IDX, C_ADDR_RX_DATA, C_SLV_DATA, "SBI RX");
      await_completion(SBI_VVCT, C_SBI_VVC_IDX, C_SBI_RX_TIME);
    end procedure;

    ------------------------------------------------------------
    -- Enhanced Randomization
    ------------------------------------------------------------
    procedure test_randomization(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test Enhanced Randomization", C_SCOPE);

      -- Configure random generator
      v_rand.set_rand_seeds(v_rand'instance_name);
      v_rand.set_name("Random generator");
      v_rand.set_scope(C_SCOPE);

      log(ID_LOG_HDR, "Transmit 65 random bytes", C_SCOPE);
      for i in 0 to 64 loop
        -- Generate a value in the range [96:160], except for 128, and including 0 and 255, using cyclic randomization.
        v_data := v_rand.rand(96, 160, EXCL, (128), ADD, (0, 255), CYCLIC);
        uart_transmit_and_sbi_check(v_data);
      end loop;

      -- Report random generator config
      v_rand.report_config(VOID);
    end procedure test_randomization;

    ------------------------------------------------------------
    -- Functional Coverage and Enhanced Randomization
    ------------------------------------------------------------
    procedure test_func_cov_coverpoint(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test functional coverage", C_SCOPE);

      -- Configure coverpoint and random generator
      shared_covpt.set_name("DATA_COVPT");
      shared_covpt.set_scope(C_SCOPE);
      shared_covpt.set_bins_coverage_goal(90);
      v_rand.set_rand_seeds(C_RAND_INIT_SEED_1, C_RAND_INIT_SEED_2);
      v_rand.set_name("Random generator");
      v_rand.set_scope(C_SCOPE);

      -- Add bins with their optional min_hits and name
      shared_covpt.add_bins(bin(0) & bin(1), 10, "bin_min");
      shared_covpt.add_bins(bin_range(2, 253, 4), "bin_middle");
      shared_covpt.add_bins(bin(254) & bin(255), 10, "bin_max");
      shared_covpt.add_bins(bin_transition((0, 1, 254, 255)), "bin_sequence");
      shared_covpt.add_bins(bin((50, 100, 150, 200)));

      -- Configure random generator constraints with weighted distribution
      v_rand.add_val_weight(0, 5);
      v_rand.add_val_weight(1, 5);
      v_rand.add_range(2, 253);
      v_rand.add_val_weight(254, 5);
      v_rand.add_val_weight(255, 5);

      log(ID_LOG_HDR, "Transmit random bytes until coverage is completed", C_SCOPE);
      unblock_flag("FLAG_REPORT", "Enable the coverage holes report", global_trigger);
      while not (shared_covpt.coverage_completed(BINS)) loop
        v_data := v_rand.randm(VOID);
        uart_transmit_and_sbi_check(v_data);
        shared_covpt.sample_coverage(v_data);
      end loop;

      -- Report coverage
      shared_covpt.report_coverage(VERBOSE);

      -- Report coverpoint and random generator config
      shared_covpt.report_config(VOID);
      v_rand.report_config(VOID);

      v_rand.clear_constraints(VOID);
    end procedure test_func_cov_coverpoint;

    ------------------------------------------------------------
    -- Functional Coverage and Optimized Randomization
    ------------------------------------------------------------
    procedure test_func_cov_cross(void : t_void) is
      constant C_BIN_IDLE  : t_new_bin_array(0 to 0) := bin(1024);
      constant C_BIN_RUN   : t_new_bin_array(0 to 0) := bin(2048);
      constant C_BIN_ERROR : t_new_bin_array(0 to 0) := illegal_bin(4096);
    begin
      log(ID_LOG_HDR_XL, "Test functional coverage", C_SCOPE);

      -- Configure coverpoint
      v_cross.set_name("DATA_STATE_CROSS");
      v_cross.set_scope(C_SCOPE);
      v_cross.set_hits_coverage_goal(120);
      v_cross.set_overall_coverage_weight(3);

      -- Add bins with their optional min_hits and name
      v_cross.add_cross(bin_vector(wdata, 2), C_BIN_IDLE, 10, "bin_data_idle");
      v_cross.add_cross(ignore_bin_range(192, 255), C_BIN_IDLE, "bin_data_ignore");
      v_cross.add_cross(bin_vector(wdata, 4), C_BIN_RUN, 10, "bin_data_run");
      v_cross.add_cross(bin_vector(wdata, 1), C_BIN_ERROR, 10, "bin_data_error");

      log(ID_LOG_HDR, "Transmit random bytes until coverage is completed", C_SCOPE);
      while not (v_cross.coverage_completed(BINS_AND_HITS)) loop
        v_data_and_state := v_cross.rand(NO_SAMPLE_COV);
        uart_transmit_and_sbi_check(v_data_and_state(0));
        -- Assume v_data_and_state(1) goes to the DUT as well
        v_cross.sample_coverage(v_data_and_state);
      end loop;

      -- Report coverage
      v_cross.report_coverage(VERBOSE);

      -- Report coverpoint config
      v_cross.report_config(VOID);
    end procedure test_func_cov_cross;

  begin
    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Verbosity control
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR_XL);
    enable_log_msg(ID_LOG_HDR_LARGE);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UVVM_SEND_CMD);
    enable_log_msg(ID_RAND_GEN);
    enable_log_msg(ID_RAND_CONF);
    enable_log_msg(ID_FUNC_COV_BINS);
    enable_log_msg(ID_FUNC_COV_BINS_INFO);
    enable_log_msg(ID_FUNC_COV_RAND);
    enable_log_msg(ID_FUNC_COV_SAMPLE);
    enable_log_msg(ID_FUNC_COV_CONFIG);
    disable_log_msg(UART_VVCT, ALL_INSTANCES, ALL_CHANNELS, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, ALL_INSTANCES, ALL_CHANNELS, ID_BFM);
    disable_log_msg(SBI_VVCT, ALL_INSTANCES, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, ALL_INSTANCES, ID_BFM);

    log(ID_LOG_HDR, "Configure UART VVC", C_SCOPE);
    shared_uart_vvc_config(RX, C_UART_VVC_IDX).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, C_UART_VVC_IDX).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Start clock and deassert reset", C_SCOPE);
    clk_ena <= true;
    wait for 5 * C_CLK_PERIOD;
    arst    <= '0';

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of UVVM Demo - Randomization and Functional Coverage");
    -------------------------------------------------------------------------------------------
    test_randomization(VOID);

    test_func_cov_coverpoint(VOID);

    test_func_cov_cross(VOID);

    fc_report_overall_coverage(VERBOSE);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- Allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED");
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

  p_intermediate_report : process
    constant C_SCOPE     : string  := "p_intermediate_report";
    constant C_FREQUENCY : natural := 5; -- Number of UART transmissions
  begin
    await_unblock_flag("FLAG_REPORT", 0 ns, "", RETURN_TO_BLOCK, WARNING, C_SCOPE);
    while not (shared_covpt.coverage_completed(BINS)) loop
      shared_covpt.report_coverage(HOLES_ONLY);
      wait for C_FREQUENCY * C_UART_TX_TIME;
    end loop;
  end process p_intermediate_report;

end architecture func;
