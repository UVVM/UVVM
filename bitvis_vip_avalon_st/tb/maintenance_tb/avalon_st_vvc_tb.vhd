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

library bitvis_vip_avalon_st;
context bitvis_vip_avalon_st.vvc_context;

--hdlregression:tb
-- Test case entity
entity avalon_st_vvc_tb is
  generic(
    GC_TESTCASE      : string  := "UVVM";
    GC_DATA_WIDTH    : natural := 32;
    GC_CHANNEL_WIDTH : natural := 8;
    GC_ERROR_WIDTH   : natural := 1
  );
end entity;

-- Test case architecture
architecture func of avalon_st_vvc_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD   : time    := 10 ns;
  constant C_SCOPE        : string  := C_TB_SCOPE_DEFAULT;
  constant C_SYMBOL_WIDTH : natural := 8;
  constant C_EMPTY_WIDTH  : natural := maximum(log2(GC_DATA_WIDTH / C_SYMBOL_WIDTH), 1);
  constant C_MAX_CHANNEL  : natural := 64;

  constant C_VVC_MASTER     : natural := 0;
  constant C_VVC_SLAVE      : natural := 1;
  constant C_VVC2VVC_MASTER : natural := 2;
  constant C_VVC2VVC_SLAVE  : natural := 3;

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk       : std_logic := '0';
  signal areset    : std_logic := '0';
  signal clock_ena : boolean   := false;

  signal avalon_st_master_if : t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                              data(GC_DATA_WIDTH - 1 downto 0),
                                              data_error(GC_ERROR_WIDTH - 1 downto 0),
                                              empty(C_EMPTY_WIDTH - 1 downto 0));
  signal avalon_st_slave_if  : t_avalon_st_if(channel(GC_CHANNEL_WIDTH - 1 downto 0),
                                              data(GC_DATA_WIDTH - 1 downto 0),
                                              data_error(GC_ERROR_WIDTH - 1 downto 0),
                                              empty(C_EMPTY_WIDTH - 1 downto 0));

  alias t_vvc_result is work.vvc_cmd_pkg.t_vvc_result;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "Avalon-ST CLK");

  --------------------------------------------------------------------------------
  -- Instantiate test harness
  --------------------------------------------------------------------------------
  i_test_harness : entity work.avalon_st_th(struct_vvc)
    generic map(
      GC_DATA_WIDTH    => GC_DATA_WIDTH,
      GC_CHANNEL_WIDTH => GC_CHANNEL_WIDTH,
      GC_ERROR_WIDTH   => GC_ERROR_WIDTH,
      GC_SYMBOL_WIDTH  => C_SYMBOL_WIDTH,
      GC_EMPTY_WIDTH   => C_EMPTY_WIDTH
    )
    port map(
      clk                 => clk,
      areset              => areset,
      avalon_st_master_if => avalon_st_master_if,
      avalon_st_slave_if  => avalon_st_slave_if
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
    variable v_avl_st_bfm_config : t_avalon_st_bfm_config := C_AVALON_ST_BFM_CONFIG_DEFAULT;
    variable v_data_packet       : t_slv_array(0 to 99)(C_SYMBOL_WIDTH - 1 downto 0);
    variable v_data_stream       : t_slv_array(0 to 99)(GC_DATA_WIDTH - 1 downto 0);
    variable v_cmd_idx           : natural;
    variable v_result            : bitvis_vip_avalon_st.vvc_cmd_pkg.t_vvc_result;
    variable v_alert_level       : t_alert_level;

    procedure new_random_data(
      data_array : inout t_slv_array) is
    begin
      for i in data_array'range loop
        data_array(i) := random(data_array(0)'length);
      end loop;
    end procedure;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 7;
    alias dut_m_channel is << signal i_test_harness.i_avalon_st_fifo.master_channel_o : std_logic_vector >>;
    alias dut_m_data    is << signal i_test_harness.i_avalon_st_fifo.master_data_o    : std_logic_vector >>;
    alias dut_m_error   is << signal i_test_harness.i_avalon_st_fifo.master_error_o   : std_logic_vector >>;
    alias dut_m_valid   is << signal i_test_harness.i_avalon_st_fifo.master_valid_o   : std_logic >>;
    alias dut_m_empty   is << signal i_test_harness.i_avalon_st_fifo.master_empty_o   : std_logic_vector >>;
    alias dut_m_eop     is << signal i_test_harness.i_avalon_st_fifo.master_eop_o     : std_logic >>;
    alias dut_m_sop     is << signal i_test_harness.i_avalon_st_fifo.master_sop_o     : std_logic >>;

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
          when 0 => dut_m_channel <= force not dut_m_channel;
                    dut_m_data    <= force not dut_m_data;
                    dut_m_error   <= force not dut_m_error;
                    dut_m_valid   <= force not dut_m_valid;
                    dut_m_empty   <= force not dut_m_empty;
                    dut_m_eop     <= force not dut_m_eop;
                    dut_m_sop     <= force not dut_m_sop;
          when 1 => dut_m_channel <= force not dut_m_channel;
          when 2 => dut_m_data    <= force not dut_m_data;
          when 3 => dut_m_error   <= force not dut_m_error;
          when 4 => dut_m_valid   <= force not dut_m_valid;
          when 5 => dut_m_empty   <= force not dut_m_empty;
          when 6 => dut_m_eop     <= force not dut_m_eop;
          when 7 => dut_m_sop     <= force not dut_m_sop;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_m_channel <= release;
                    dut_m_data    <= release;
                    dut_m_error   <= release;
                    dut_m_valid   <= release;
                    dut_m_empty   <= release;
                    dut_m_eop     <= release;
                    dut_m_sop     <= release;
          when 1 => dut_m_channel <= release;
          when 2 => dut_m_data    <= release;
          when 3 => dut_m_error   <= release;
          when 4 => dut_m_valid   <= release;
          when 5 => dut_m_empty   <= release;
          when 6 => dut_m_eop     <= release;
          when 7 => dut_m_sop     <= release;
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
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Override default config with settings for this testbench
    v_avl_st_bfm_config.symbol_width := C_SYMBOL_WIDTH;
    v_avl_st_bfm_config.max_channel  := C_MAX_CHANNEL;

    shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config     := v_avl_st_bfm_config;
    shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config      := v_avl_st_bfm_config;
    shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config := v_avl_st_bfm_config;
    shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config  := v_avl_st_bfm_config;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    disable_log_msg(ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(AVALON_ST_VVCT, ALL_INSTANCES, ID_CMD_INTERPRETER);
    disable_log_msg(AVALON_ST_VVCT, ALL_INSTANCES, ID_CMD_INTERPRETER_WAIT);
    disable_log_msg(AVALON_ST_VVCT, ALL_INSTANCES, ID_CMD_EXECUTOR);
    disable_log_msg(AVALON_ST_VVCT, ALL_INSTANCES, ID_CMD_EXECUTOR_WAIT);
    disable_log_msg(AVALON_ST_VVCT, ALL_INSTANCES, ID_IMMEDIATE_CMD_WAIT);
    disable_log_msg(AVALON_ST_VVCT, ALL_INSTANCES, ID_PACKET_DATA);

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Avalon-ST");
    --------------------------------------------------------------------------------
    clock_ena <= true;                  -- start clock generator
    gen_pulse(areset, 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");
    wait for 10 * C_CLK_PERIOD;

    if GC_TESTCASE = "test_packet_data" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Simulating packet-based data: VVC->DUT->VVC");
      ----------------------------------------------------------------------------------------------------------------------------
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.use_packet_transfer := true;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.use_packet_transfer  := true;
      new_random_data(v_data_packet);   -- Generate random data

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in high order bits");
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.first_symbol_in_msb := true;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.first_symbol_in_msb  := true;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 8), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(0 to 8), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in low order bits");
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.first_symbol_in_msb := false;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.first_symbol_in_msb  := false;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 8), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(0 to 8), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing that VVC procedures normalize data arrays");
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(3 to 9), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(3 to 9), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      if C_SYMBOL_WIDTH = 8 then
        log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, (x"01", x"23", x"45", x"67", x"89"), "");
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, (x"01", x"23", x"45", x"67", x"89"), "");
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      end if;

      log(ID_LOG_HDR, "Testing shortest packets possible");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 0), "");
        end loop;
        for j in 0 to i loop
          avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(0 to 0), "");
        end loop;
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      end loop;

      log(ID_LOG_HDR, "Testing different packet sizes and channels");
      for i in 0 to 30 loop
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      for i in 0 to 30 loop
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_packet, "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_packet, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing receive and fetch");
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(10, GC_CHANNEL_WIDTH)), v_data_packet(0 to 4), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 5, v_data_packet(0)'length, "");
      v_cmd_idx := get_last_received_cmd_idx(AVALON_ST_VVCT, C_VVC_SLAVE);
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, v_cmd_idx, 10 us);
      fetch_result(AVALON_ST_VVCT, C_VVC_SLAVE, v_cmd_idx, v_result);
      check_value(v_result.channel_value, std_logic_vector(to_unsigned(10, GC_CHANNEL_WIDTH)), ERROR, "Checking fetch result: channel");
      for i in 0 to v_result.data_array_length - 1 loop
        check_value(v_result.data_array(i)(v_result.data_array_word_size - 1 downto 0), v_data_packet(i), ERROR, "Checking fetch result: data_array");
      end loop;

      -- Note: Error cases based on forcing master_sop_o or master_eop_o will not work in Modelsim 2020.1 because of a simulator bug in which values forced on port signals fail to propagate.
      log(ID_LOG_HDR, "Testing error case: receive() with missing start of packet");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= force '0';
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet, "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet'length, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= release;
      wait for 0 ns; -- Riviera Pro needs a delta cycle to use the force command again on the same signal

      log(ID_LOG_HDR, "Testing error case: receive() with start of packet in wrong position");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      increment_expected_alerts_and_stop_limit(ERROR, 2); -- Unwanted activity errors: forcing and releasing SOP
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= force '1';
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= release;
      wait for 0 ns; -- Delta cycle so that the error message is printed before the next test

      log(ID_LOG_HDR, "Testing error case: receive() with missing end of packet");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_test_harness.i_avalon_st_fifo.master_eop_o : std_logic >> <= force '0';
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet, "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet'length, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      << signal i_test_harness.i_avalon_st_fifo.master_eop_o : std_logic >> <= release;

      log(ID_LOG_HDR, "Testing error case: receive() with end of packet in wrong position");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 1 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      if GC_DATA_WIDTH > C_SYMBOL_WIDTH then
        log(ID_LOG_HDR, "Testing error case: receive() with missing empty symbols");
        increment_expected_alerts_and_stop_limit(ERROR, 1);
        << signal i_test_harness.i_avalon_st_fifo.master_empty_o : std_logic_vector(C_EMPTY_WIDTH - 1 downto 0) >> <= force (others => '0');
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 10), "");
        avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 11, v_data_packet(0)'length, "");
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
        << signal i_test_harness.i_avalon_st_fifo.master_empty_o : std_logic_vector(C_EMPTY_WIDTH - 1 downto 0) >> <= release;
      end if;

      log(ID_LOG_HDR, "Testing error case: receive() timeout - no valid data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet'length, v_data_packet(0)'length, "");
      wait for (v_avl_st_bfm_config.max_wait_cycles + 1) * C_CLK_PERIOD;

      log(ID_LOG_HDR, "Testing error case: expect() wrong data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 10), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(10 to 20), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing error case: expect() wrong channel");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(1, GC_CHANNEL_WIDTH)), v_data_packet, "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(5, GC_CHANNEL_WIDTH)), v_data_packet, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Simulating packet-based data: VVC->VVC");
      ----------------------------------------------------------------------------------------------------------------------------
      shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.use_packet_transfer := true;
      shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.use_packet_transfer  := true;
      new_random_data(v_data_packet);   -- Generate random data

      log(ID_LOG_HDR, "Testing shortest packets possible");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, v_data_packet(0 to 0), "");
        end loop;
        for j in 0 to i loop
          avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, v_data_packet(0 to 0), "");
        end loop;
        await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 10 us);
      end loop;

      log(ID_LOG_HDR, "Testing different packet sizes and channels");
      for i in 0 to 30 loop
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      for i in 0 to 30 loop
        avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_packet, "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_packet, "");
      await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing error case: transmit() timeout - slave not ready");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      increment_expected_alerts_and_stop_limit(ERROR, 3); -- Unwanted activity errors: data, valid and SOP change in inactive slave
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, v_data_packet, "");
      wait for (v_avl_st_bfm_config.max_wait_cycles + 1) * C_CLK_PERIOD;

    elsif GC_TESTCASE = "test_stream_data" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Simulating data stream (non-packet): VVC->DUT->VVC");
      ----------------------------------------------------------------------------------------------------------------------------
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.use_packet_transfer := false;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.use_packet_transfer  := false;
      new_random_data(v_data_stream);   -- Generate random data

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in high order bits");
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.first_symbol_in_msb := true;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.first_symbol_in_msb  := true;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream(0 to 8), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream(0 to 8), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in low order bits");
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.first_symbol_in_msb := false;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.first_symbol_in_msb  := false;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream(0 to 8), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream(0 to 8), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing that BFM procedures normalize data arrays");
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream(3 to 9), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream(3 to 9), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      if GC_DATA_WIDTH = 32 then
        log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, (x"01234567", x"89AABBCC", x"DDEEFF00", x"11223344", x"55667788"), "");
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, (x"01234567", x"89AABBCC", x"DDEEFF00", x"11223344", x"55667788"), "");
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      end if;

      log(ID_LOG_HDR, "Testing shortest streams possible");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream(0 to 0), "");
        end loop;
        for j in 0 to i loop
          avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream(0 to 0), "");
        end loop;
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      end loop;

      log(ID_LOG_HDR, "Testing different stream sizes and channels");
      for i in 0 to 15 loop
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_stream(0 to i), "");
      end loop;
      for i in 0 to 15 loop
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_stream(0 to i), "");
      end loop;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_stream, "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_stream, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing receive and fetch");
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(10, GC_CHANNEL_WIDTH)), v_data_stream(0 to 4), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 5, v_data_stream(0)'length, "");
      v_cmd_idx := get_last_received_cmd_idx(AVALON_ST_VVCT, C_VVC_SLAVE);
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, v_cmd_idx, 10 us);
      fetch_result(AVALON_ST_VVCT, C_VVC_SLAVE, v_cmd_idx, v_result);
      check_value(v_result.channel_value, std_logic_vector(to_unsigned(10, GC_CHANNEL_WIDTH)), ERROR, "Checking fetch result: channel");
      for i in 0 to v_result.data_array_length - 1 loop
        check_value(v_result.data_array(i)(v_result.data_array_word_size - 1 downto 0), v_data_stream(i), ERROR, "Checking fetch result: data_array");
      end loop;

      log(ID_LOG_HDR, "Testing error case: receive() timeout - no valid data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream'length, v_data_stream(0)'length, "");
      wait for (v_avl_st_bfm_config.max_wait_cycles + 1) * C_CLK_PERIOD;

      log(ID_LOG_HDR, "Testing error case: receive() timeout - not enough data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream(0 to 1), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream'length, v_data_stream(0)'length, "");
      wait for (v_avl_st_bfm_config.max_wait_cycles + 100) * C_CLK_PERIOD;

      log(ID_LOG_HDR, "Testing error case: expect() wrong data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream(0 to 10), "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream(10 to 20), "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing error case: expect() wrong channel");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(1, GC_CHANNEL_WIDTH)), v_data_stream, "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(5, GC_CHANNEL_WIDTH)), v_data_stream, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing error case: transmit() from slave");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_stream, "");
      wait for C_CLK_PERIOD;

      log(ID_LOG_HDR, "Testing error case: receive() from master");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream'length, v_data_stream(0)'length, "");
      wait for C_CLK_PERIOD;

      log(ID_LOG_HDR, "Testing error case: expect() from master");
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      avalon_st_expect(AVALON_ST_VVCT, C_VVC_MASTER, v_data_stream, "");
      wait for C_CLK_PERIOD;

      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Simulating data stream (non-packet): VVC->VVC");
      ----------------------------------------------------------------------------------------------------------------------------
      shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.use_packet_transfer := false;
      shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.use_packet_transfer  := false;
      new_random_data(v_data_stream);   -- Generate random data

      log(ID_LOG_HDR, "Testing shortest streams possible");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, v_data_stream(0 to 0), "");
        end loop;
        for j in 0 to i loop
          avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, v_data_stream(0 to 0), "");
        end loop;
        await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 10 us);
      end loop;

      log(ID_LOG_HDR, "Testing different stream sizes and channels");
      for i in 0 to 15 loop
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_stream(0 to i), "");
      end loop;
      for i in 0 to 15 loop
        avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_stream(0 to i), "");
      end loop;
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_stream, "");
      avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, std_logic_vector(to_unsigned(C_MAX_CHANNEL, GC_CHANNEL_WIDTH)), v_data_stream, "");
      await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing error case: transmit() timeout - slave not ready");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      increment_expected_alerts_and_stop_limit(ERROR, 2); -- Unwanted activity errors: data and valid change in inactive slave
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, v_data_stream, "");
      wait for (v_avl_st_bfm_config.max_wait_cycles + 1) * C_CLK_PERIOD;

    elsif GC_TESTCASE = "test_setup_and_hold_times" then
      v_avl_st_bfm_config.clock_period                         := C_CLK_PERIOD;
      v_avl_st_bfm_config.setup_time                           := C_CLK_PERIOD / 4;
      v_avl_st_bfm_config.hold_time                            := C_CLK_PERIOD / 4;
      v_avl_st_bfm_config.bfm_sync                             := SYNC_WITH_SETUP_AND_HOLD;
      v_avl_st_bfm_config.use_packet_transfer                  := true;
      shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config     := v_avl_st_bfm_config;
      shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config      := v_avl_st_bfm_config;
      shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config := v_avl_st_bfm_config;
      shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config  := v_avl_st_bfm_config;
      new_random_data(v_data_packet);   -- Generate random data

      log(ID_LOG_HDR, "Testing setup and hold times: VVC->DUT->VVC");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 0), "");
        end loop;
        for j in 0 to i loop
          avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(0 to 0), "");
        end loop;
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      end loop;
      for i in 0 to 10 loop
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      for i in 0 to 10 loop
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      log(ID_LOG_HDR, "Testing setup and hold times: VVC->VVC");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, v_data_packet(0 to 0), "");
        end loop;
        for j in 0 to i loop
          avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, v_data_packet(0 to 0), "");
        end loop;
        await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 10 us);
      end loop;
      for i in 0 to 10 loop
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      for i in 0 to 10 loop
        avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, std_logic_vector(to_unsigned(i, GC_CHANNEL_WIDTH)), v_data_packet(0 to i), "");
      end loop;
      await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 10 us);

    elsif GC_TESTCASE = "test_random_configuration" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing random configurations of valid and ready low");
      ----------------------------------------------------------------------------------------------------------------------------
      new_random_data(v_data_packet);   -- Generate random data
      for i in 0 to 59 loop
        if i < 20 then
          shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_at_word_idx     := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_duration        := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_at_word_idx := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_duration    := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_at_word_idx      := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_duration         := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_at_word_idx  := random(0, 5);
          shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_duration     := random(0, 5);
        else
          shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_at_word_idx     := C_MULTIPLE_RANDOM;
          shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_duration        := C_RANDOM;
          shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_at_word_idx := C_MULTIPLE_RANDOM;
          shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_duration    := C_RANDOM;
          shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_at_word_idx      := C_MULTIPLE_RANDOM;
          shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_duration         := C_RANDOM;
          shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_at_word_idx  := C_MULTIPLE_RANDOM;
          shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_duration     := C_RANDOM;
          if i < 30 then
            -- Probability of multiple random is zero
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_multiple_random_prob     := 0.0;
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_max_random_duration      := 20;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 0.0;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 20;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_multiple_random_prob      := 0.0;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_max_random_duration       := 20;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 0.0;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 20;
          elsif i < 40 then
            -- Probability of multiple random is low and max random duration is high
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_multiple_random_prob     := 0.1;
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_max_random_duration      := 20;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 0.1;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 20;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_multiple_random_prob      := 0.1;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_max_random_duration       := 20;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 0.1;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 20;
          elsif i < 50 then
            -- Probability of multiple random is 50/50 and max random duration is low
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_multiple_random_prob     := 0.5;
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_max_random_duration      := 5;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 0.5;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 5;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_multiple_random_prob      := 0.5;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_max_random_duration       := 5;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 0.5;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 5;
          else
            -- Probability of multiple random is 100% (every cycle) and max random duration is 1
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_multiple_random_prob     := 1.0;
            shared_avalon_st_vvc_config(C_VVC_MASTER).bfm_config.valid_low_max_random_duration      := 1;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 1.0;
            shared_avalon_st_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 1;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_multiple_random_prob      := 1.0;
            shared_avalon_st_vvc_config(C_VVC_SLAVE).bfm_config.ready_low_max_random_duration       := 1;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 1.0;
            shared_avalon_st_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 1;
          end if;
        end if;
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 15), "transmit 16 symbols");
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(0 to 15), "expect 16 symbols");
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 1 ms);
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC2VVC_MASTER, v_data_packet(0 to 15), "transmit 16 symbols");
        avalon_st_expect(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, v_data_packet(0 to 15), "expect 16 symbols");
        await_completion(AVALON_ST_VVCT, C_VVC2VVC_SLAVE, 1 ms);
      end loop;

    elsif GC_TESTCASE = "test_unwanted_activity" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
      ----------------------------------------------------------------------------------------------------------------------------
      for i in 0 to 2 loop
        -- Test different alert severity configurations
        if i = 0 then
          v_alert_level := C_AVALON_ST_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
        elsif i = 1 then
          v_alert_level := FAILURE;
        else
          v_alert_level := NO_ALERT;
        end if;
        log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
        shared_avalon_st_vvc_config(C_VVC_MASTER).unwanted_activity_severity := v_alert_level;
        shared_avalon_st_vvc_config(C_VVC_SLAVE).unwanted_activity_severity  := v_alert_level;

        log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
        new_random_data(v_data_packet);
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 3), "Transmit data");
        avalon_st_expect(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet(0 to 3), "Expect data");
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

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
    wait for 1000 ns;                   -- Allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
