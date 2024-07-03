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

library bitvis_vip_avalon_st;
use bitvis_vip_avalon_st.avalon_st_bfm_pkg.all;

--hdlregression:tb
-- Test case entity
entity avalon_st_bfm_tb is
  generic(
    GC_TESTCASE      : string  := "UVVM";
    GC_DATA_WIDTH    : natural := 32;
    GC_CHANNEL_WIDTH : natural := 8;
    GC_ERROR_WIDTH   : natural := 1
  );
end entity;

-- Test case architecture
architecture func of avalon_st_bfm_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD   : time    := 10 ns;
  constant C_SCOPE        : string  := C_TB_SCOPE_DEFAULT;
  constant C_SYMBOL_WIDTH : natural := 8;
  constant C_EMPTY_WIDTH  : natural := maximum(log2(GC_DATA_WIDTH / C_SYMBOL_WIDTH), 1);
  constant C_MAX_CHANNEL  : natural := 64;

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

begin

  -----------------------------------------------------------------------------
  -- Clock Generator
  -----------------------------------------------------------------------------
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "Avalon-ST CLK");

  --------------------------------------------------------------------------------
  -- Instantiate test harness
  --------------------------------------------------------------------------------
  i_test_harness : entity work.avalon_st_th(struct_bfm)
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

    procedure new_random_data(
      data_array : inout t_slv_array) is
    begin
      for i in data_array'range loop
        data_array(i) := random(data_array(0)'length);
      end loop;
    end procedure;

    --------------------------------------------
    -- Overloads for this testbench
    --------------------------------------------
    procedure avalon_st_transmit(
      data_array : in t_slv_array;
      channel    : in natural) is
    begin
      avalon_st_transmit(std_logic_vector(to_unsigned(channel, GC_CHANNEL_WIDTH)), data_array, "", clk, avalon_st_master_if, C_SCOPE,
                         shared_msg_id_panel, v_avl_st_bfm_config);
    end procedure;

    procedure avalon_st_transmit(
      data_array : in t_slv_array) is
    begin
      avalon_st_transmit(data_array, "", clk, avalon_st_master_if, C_SCOPE, shared_msg_id_panel, v_avl_st_bfm_config);
    end procedure;

    procedure avalon_st_receive(
      data_array : out t_slv_array;
      channel    : out natural) is
      variable v_channel : std_logic_vector(GC_CHANNEL_WIDTH - 1 downto 0);
    begin
      avalon_st_receive(v_channel, data_array, "", clk, avalon_st_slave_if, C_SCOPE, shared_msg_id_panel, v_avl_st_bfm_config);
      channel := to_integer(unsigned(v_channel));
    end procedure;

    procedure avalon_st_receive(
      data_array : out t_slv_array) is
    begin
      avalon_st_receive(data_array, "", clk, avalon_st_slave_if, C_SCOPE, shared_msg_id_panel, v_avl_st_bfm_config);
    end procedure;

    procedure avalon_st_expect(
      exp_array : in t_slv_array;
      channel   : in natural) is
    begin
      avalon_st_expect(std_logic_vector(to_unsigned(channel, GC_CHANNEL_WIDTH)), exp_array, "", clk, avalon_st_slave_if, error, C_SCOPE,
                       shared_msg_id_panel, v_avl_st_bfm_config);
    end procedure;

    procedure avalon_st_expect(
      exp_array : in t_slv_array) is
    begin
      avalon_st_expect(exp_array, "", clk, avalon_st_slave_if, error, C_SCOPE, shared_msg_id_panel, v_avl_st_bfm_config);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Override default config with settings for this testbench
    v_avl_st_bfm_config.symbol_width := C_SYMBOL_WIDTH;
    v_avl_st_bfm_config.max_channel  := C_MAX_CHANNEL;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Verbosity control
    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_PACKET_DATA);

    --------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Start Simulation of Avalon-ST");
    --------------------------------------------------------------------------------
    clock_ena <= true;                  -- start clock generator
    gen_pulse(areset, 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");
    wait for 10 * C_CLK_PERIOD;

    if GC_TESTCASE = "test_packet_data" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Simulating packet-based data");
      ----------------------------------------------------------------------------------------------------------------------------
      v_avl_st_bfm_config.use_packet_transfer := true;
      new_random_data(v_data_packet);   -- Generate random data

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in high order bits");
      v_avl_st_bfm_config.first_symbol_in_msb := true;
      avalon_st_transmit(v_data_packet(0 to 8));
      avalon_st_expect(v_data_packet(0 to 8));

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in low order bits");
      v_avl_st_bfm_config.first_symbol_in_msb := false;
      avalon_st_transmit(v_data_packet(0 to 8));
      avalon_st_expect(v_data_packet(0 to 8));

      log(ID_LOG_HDR, "Testing that BFM procedures normalize data arrays");
      avalon_st_transmit(v_data_packet(2 to 6));
      avalon_st_receive(v_data_packet(2 to 6));
      avalon_st_transmit(v_data_packet(3 to 9));
      avalon_st_expect(v_data_packet(3 to 9));

      if C_SYMBOL_WIDTH = 8 then
        log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
        avalon_st_transmit((x"01", x"23", x"45", x"67", x"89"));
        avalon_st_expect((x"01", x"23", x"45", x"67", x"89"));
      end if;

      log(ID_LOG_HDR, "Testing shortest packets possible");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(v_data_packet(0 to 0));
        end loop;
        for j in 0 to i loop
          avalon_st_expect(v_data_packet(0 to 0));
        end loop;
      end loop;

      log(ID_LOG_HDR, "Testing different packet sizes and channels");
      for i in 0 to 30 loop
        avalon_st_transmit(v_data_packet(0 to i), i);
      end loop;
      for i in 0 to 30 loop
        avalon_st_expect(v_data_packet(0 to i), i);
      end loop;
      avalon_st_transmit(v_data_packet, C_MAX_CHANNEL);
      avalon_st_expect(v_data_packet, C_MAX_CHANNEL);

      -- Note: Error cases based on forcing master_sop_o or master_eop_o will not work in Modelsim 2020.1 because of a simulator bug in which values forced on port signals fail to propagate.
      log(ID_LOG_HDR, "Testing error case: receive() with missing start of packet");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= force '0';
      avalon_st_transmit(v_data_packet);
      avalon_st_receive(v_data_packet);
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= release;
      wait for 0 ns;                    -- Riviera Pro needs a delta cycle to use the force command again on the same signal

      log(ID_LOG_HDR, "Testing error case: receive() with start of packet in wrong position");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= force '1';
      avalon_st_transmit(v_data_packet(0 to 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1));
      avalon_st_receive(v_data_packet(0 to 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1));
      << signal i_test_harness.i_avalon_st_fifo.master_sop_o : std_logic >> <= release;

      log(ID_LOG_HDR, "Testing error case: receive() with missing end of packet");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      << signal i_test_harness.i_avalon_st_fifo.master_eop_o : std_logic >> <= force '0';
      avalon_st_transmit(v_data_packet);
      avalon_st_receive(v_data_packet);
      << signal i_test_harness.i_avalon_st_fifo.master_eop_o : std_logic >> <= release;

      log(ID_LOG_HDR, "Testing error case: receive() with end of packet in wrong position");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(v_data_packet(0 to 1 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1));
      avalon_st_receive(v_data_packet(0 to 2 * GC_DATA_WIDTH / C_SYMBOL_WIDTH - 1));
      new_random_data(v_data_packet);   -- Overwrite invalid data array after receive error

      if GC_DATA_WIDTH > C_SYMBOL_WIDTH then
        log(ID_LOG_HDR, "Testing error case: receive() with missing empty symbols");
        increment_expected_alerts_and_stop_limit(ERROR, 1);
        << signal i_test_harness.i_avalon_st_fifo.master_empty_o : std_logic_vector(C_EMPTY_WIDTH - 1 downto 0) >> <= force (others => '0');
        avalon_st_transmit(v_data_packet(0 to 10));
        avalon_st_receive(v_data_packet(0 to 10));
        << signal i_test_harness.i_avalon_st_fifo.master_empty_o : std_logic_vector(C_EMPTY_WIDTH - 1 downto 0) >> <= release;
      end if;

      log(ID_LOG_HDR, "Testing error case: receive() timeout - no valid data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_receive(v_data_packet);
      new_random_data(v_data_packet);   -- Overwrite invalid data array after receive error

      log(ID_LOG_HDR, "Testing error case: expect() wrong data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(v_data_packet(0 to 10));
      avalon_st_expect(v_data_packet(10 to 20));

      log(ID_LOG_HDR, "Testing error case: expect() wrong channel");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(v_data_packet, 1);
      avalon_st_expect(v_data_packet, 5);

    elsif GC_TESTCASE = "test_stream_data" then
      ----------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR_LARGE, "Simulating data stream (non-packet)");
      ----------------------------------------------------------------------------------------------------------------------------
      v_avl_st_bfm_config.use_packet_transfer := false;
      new_random_data(v_data_stream);   -- Generate random data

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in high order bits");
      v_avl_st_bfm_config.first_symbol_in_msb := true;
      avalon_st_transmit(v_data_stream(0 to 8));
      avalon_st_expect(v_data_stream(0 to 8));

      log(ID_LOG_HDR, "Testing symbol ordering: first symbol in low order bits");
      v_avl_st_bfm_config.first_symbol_in_msb := false;
      avalon_st_transmit(v_data_stream(0 to 8));
      avalon_st_expect(v_data_stream(0 to 8));

      log(ID_LOG_HDR, "Testing that BFM procedures normalize data arrays");
      avalon_st_transmit(v_data_stream(2 to 6));
      avalon_st_receive(v_data_stream(2 to 6));
      avalon_st_transmit(v_data_stream(3 to 9));
      avalon_st_expect(v_data_stream(3 to 9));

      if GC_DATA_WIDTH = 32 then
        log(ID_LOG_HDR, "Testing explicit std_logic_vector values");
        avalon_st_transmit((x"01234567", x"89AABBCC", x"DDEEFF00", x"11223344", x"55667788"));
        avalon_st_expect((x"01234567", x"89AABBCC", x"DDEEFF00", x"11223344", x"55667788"));
      end if;

      log(ID_LOG_HDR, "Testing shortest streams possible");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(v_data_stream(0 to 0));
        end loop;
        for j in 0 to i loop
          avalon_st_expect(v_data_stream(0 to 0));
        end loop;
      end loop;

      log(ID_LOG_HDR, "Testing different stream sizes and channels");
      for i in 0 to 15 loop
        avalon_st_transmit(v_data_stream(0 to i), i);
      end loop;
      for i in 0 to 15 loop
        avalon_st_expect(v_data_stream(0 to i), i);
      end loop;
      avalon_st_transmit(v_data_stream, C_MAX_CHANNEL);
      avalon_st_expect(v_data_stream, C_MAX_CHANNEL);

      log(ID_LOG_HDR, "Testing error case: receive() timeout - no valid data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_receive(v_data_stream);
      new_random_data(v_data_stream);   -- Overwrite invalid data array after error

      log(ID_LOG_HDR, "Testing error case: receive() timeout - not enough data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(v_data_stream(0 to 1));
      avalon_st_receive(v_data_stream);
      new_random_data(v_data_stream);   -- Overwrite invalid data array after error

      log(ID_LOG_HDR, "Testing error case: expect() wrong data");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(v_data_stream(0 to 10));
      avalon_st_expect(v_data_stream(10 to 20));

      log(ID_LOG_HDR, "Testing error case: expect() wrong channel");
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      avalon_st_transmit(v_data_stream, 1);
      avalon_st_expect(v_data_stream, 5);

    elsif GC_TESTCASE = "test_setup_and_hold_times" then
      v_avl_st_bfm_config.clock_period        := C_CLK_PERIOD;
      v_avl_st_bfm_config.setup_time          := C_CLK_PERIOD / 4;
      v_avl_st_bfm_config.hold_time           := C_CLK_PERIOD / 4;
      v_avl_st_bfm_config.bfm_sync            := SYNC_WITH_SETUP_AND_HOLD;
      v_avl_st_bfm_config.use_packet_transfer := true;
      new_random_data(v_data_packet);   -- Generate random data

      log(ID_LOG_HDR, "Testing setup and hold times");
      for i in 0 to 3 loop
        for j in 0 to i loop
          avalon_st_transmit(v_data_packet(0 to 0));
        end loop;
        for j in 0 to i loop
          avalon_st_expect(v_data_packet(0 to 0));
        end loop;
      end loop;
      for i in 0 to 10 loop
        avalon_st_transmit(v_data_packet(0 to i), i);
      end loop;
      for i in 0 to 10 loop
        avalon_st_expect(v_data_packet(0 to i), i);
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
