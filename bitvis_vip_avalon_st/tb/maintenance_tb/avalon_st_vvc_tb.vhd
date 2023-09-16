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
  i_avalon_st_test_harness : entity bitvis_vip_avalon_st.test_harness(struct_vvc)
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

    procedure new_random_data(
      data_array : inout t_slv_array) is
    begin
      for i in data_array'range loop
        data_array(i) := random(data_array(0)'length);
      end loop;
    end procedure;

    constant c_debug : t_vvc_result := (
      channel_value        => (others => '0'),
      data_array           => (others => (others => '0')),
      data_array_length    => C_VVC_CMD_DATA_MAX_WORDS,
      data_array_word_size => C_VVC_CMD_WORD_MAX_LENGTH);

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
    enable_log_msg(ALL_MESSAGES);
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
      << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= force '0';
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet, "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet'length, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= release;
      wait for 0 ns;                    -- Riviera Pro needs a delta cycle to use the force command again on the same signal

      log(ID_LOG_HDR, "Testing error case: receive() with start of packet in wrong position");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= force '1';
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= release;

      log(ID_LOG_HDR, "Testing error case: receive() with missing end of packet");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_eop_o : std_logic >> <= force '0';
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet, "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, v_data_packet'length, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
      << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_eop_o : std_logic >> <= release;

      log(ID_LOG_HDR, "Testing error case: receive() with end of packet in wrong position");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 1 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1), "");
      avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH, v_data_packet(0)'length, "");
      await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);

      if GC_DATA_WIDTH > C_SYMBOL_WIDTH then
        log(ID_LOG_HDR, "Testing error case: receive() with missing empty symbols");
        increment_expected_alerts_and_stop_limit(ERROR, 1);
        << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_empty_o : std_logic_vector(C_EMPTY_WIDTH - 1 downto 0) >> <= force (others => '0');
        avalon_st_transmit(AVALON_ST_VVCT, C_VVC_MASTER, v_data_packet(0 to 10), "");
        avalon_st_receive(AVALON_ST_VVCT, C_VVC_SLAVE, 11, v_data_packet(0)'length, "");
        await_completion(AVALON_ST_VVCT, C_VVC_SLAVE, 10 us);
        << signal i_avalon_st_test_harness.i_avalon_st_fifo.master_empty_o : std_logic_vector(C_EMPTY_WIDTH - 1 downto 0) >> <= release;
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
