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
use IEEE.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_axistream;
context bitvis_vip_axistream.vvc_context;

--hdlregression:tb
-- Test case entity
entity axistream_vvc_tb is
  generic(
    GC_TESTCASE           : string  := "UVVM";
    GC_DATA_WIDTH         : natural := 32; -- number of bits in the AXI-Stream IF data vector
    GC_USER_WIDTH         : natural := 1; -- number of bits in the AXI-Stream IF tuser vector
    GC_ID_WIDTH           : natural := 1; -- number of bits in AXI-Stream IF tID
    GC_DEST_WIDTH         : natural := 1; -- number of bits in AXI-Stream IF tDEST
    GC_INCLUDE_TUSER      : boolean := true; -- If tuser, tstrb, tid, tdest is included in DUT's AXI interface
    GC_USE_SETUP_AND_HOLD : boolean := false -- use setup and hold times to synchronise the BFM
  );
end entity;

-- Test case architecture
architecture func of axistream_vvc_tb is

  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 10 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  -- VVC idx
  constant C_FIFO2VVC_MASTER : natural := 0;
  constant C_FIFO2VVC_SLAVE  : natural := 1;
  constant C_VVC2VVC_MASTER  : natural := 2;
  constant C_VVC2VVC_SLAVE   : natural := 3;

  constant c_max_bytes       : natural   := 100; -- max bytes per packet to send
  constant C_DUT_FIFO_DEPTH  : natural   := 4;
  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk                 : std_logic := '0';
  signal areset              : std_logic := '0';
  signal clock_ena           : boolean   := false;

  -- The axistream interface is gathered in one record
  signal axistream_if_m : t_axistream_if(tdata(GC_DATA_WIDTH - 1 downto 0),
                                         tkeep((GC_DATA_WIDTH / 8) - 1 downto 0),
                                         tuser(GC_USER_WIDTH - 1 downto 0),
                                         tstrb((GC_DATA_WIDTH / 8) - 1 downto 0),
                                         tid(GC_ID_WIDTH - 1 downto 0),
                                         tdest(GC_DEST_WIDTH - 1 downto 0)
                                        );
  signal axistream_if_s : t_axistream_if(tdata(GC_DATA_WIDTH - 1 downto 0),
                                         tkeep((GC_DATA_WIDTH / 8) - 1 downto 0),
                                         tuser(GC_USER_WIDTH - 1 downto 0),
                                         tstrb((GC_DATA_WIDTH / 8) - 1 downto 0),
                                         tid(GC_ID_WIDTH - 1 downto 0),
                                         tdest(GC_DEST_WIDTH - 1 downto 0)
                                        );

  --------------------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
begin
  -----------------------------
  -- Instantiate Testharness
  -----------------------------
  i_test_harness : entity work.axistream_th(struct_vvc)
    generic map(
      GC_DATA_WIDTH     => GC_DATA_WIDTH,
      GC_USER_WIDTH     => GC_USER_WIDTH,
      GC_ID_WIDTH       => GC_ID_WIDTH,
      GC_DEST_WIDTH     => GC_DEST_WIDTH,
      GC_DUT_FIFO_DEPTH => C_DUT_FIFO_DEPTH,
      GC_INCLUDE_TUSER  => GC_INCLUDE_TUSER
    )
    port map(
      clk                     => clk,
      areset                  => areset,
      axistream_if_m_VVC2FIFO => axistream_if_m,
      axistream_if_s_FIFO2VVC => axistream_if_s
    );

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -- Set up clock generator
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "axistream CLK");

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- BFM config
    variable v_axistream_bfm_config : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    variable v_cnt                  : integer                          := 0;
    variable v_idx                  : integer                          := 0;
    variable v_numBytes             : integer                          := 0;
    variable v_numWords             : integer                          := 0;
    variable v_data_array           : t_byte_array(0 to c_max_bytes - 1);
    variable v_user_array           : t_user_array(v_data_array'range) := (others => (others => '0'));
    variable v_strb_array           : t_strb_array(v_data_array'range) := (others => (others => '0'));
    variable v_id_array             : t_id_array(v_data_array'range)   := (others => (others => '0'));
    variable v_dest_array           : t_dest_array(v_data_array'range) := (others => (others => '0'));
    variable v_cmd_idx              : natural;
    variable v_result_from_fetch    : bitvis_vip_axistream.vvc_cmd_pkg.t_vvc_result;
    variable v_alert_level          : t_alert_level;

    -- DUT ports towards VVC interface
    constant C_NUM_VVC_SIGNALS : natural := 8;
    alias dut_m_tdata  is << signal i_test_harness.i_axis_fifo.m_axis_tdata  : std_logic_vector >>;
    alias dut_m_tkeep  is << signal i_test_harness.i_axis_fifo.m_axis_tkeep  : std_logic_vector >>;
    alias dut_m_tuser  is << signal i_test_harness.i_axis_fifo.m_axis_tuser  : std_logic_vector >>;
    alias dut_m_tvalid is << signal i_test_harness.i_axis_fifo.m_axis_tvalid : std_logic >>;
    alias dut_m_tlast  is << signal i_test_harness.i_axis_fifo.m_axis_tlast  : std_logic >>;
    alias dut_m_tstrb  is << signal i_test_harness.dut_m_axis_tstrb          : std_logic_vector >>;
    alias dut_m_tid    is << signal i_test_harness.dut_m_axis_tid            : std_logic_vector >>;
    alias dut_m_tdest  is << signal i_test_harness.dut_m_axis_tdest          : std_logic_vector >>;

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
          when 0 => dut_m_tdata  <= force not dut_m_tdata;
                    dut_m_tkeep  <= force not dut_m_tkeep;
                    dut_m_tuser  <= force not dut_m_tuser;
                    dut_m_tvalid <= force not dut_m_tvalid;
                    dut_m_tlast  <= force not dut_m_tlast;
                    dut_m_tstrb  <= force not dut_m_tstrb;
                    dut_m_tid    <= force not dut_m_tid;
                    dut_m_tdest  <= force not dut_m_tdest;
          when 1 => dut_m_tdata  <= force not dut_m_tdata;
          when 2 => dut_m_tkeep  <= force not dut_m_tkeep;
          when 3 => dut_m_tuser  <= force not dut_m_tuser;
          when 4 => dut_m_tvalid <= force not dut_m_tvalid;
          when 5 => dut_m_tlast  <= force not dut_m_tlast;
          when 6 => dut_m_tstrb  <= force not dut_m_tstrb;
          when 7 => dut_m_tid    <= force not dut_m_tid;
          when 8 => dut_m_tdest  <= force not dut_m_tdest;
        end case;
        wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
        v_num_expected_alerts := 0 when alert_level = NO_ALERT else
                                 v_num_expected_alerts + C_NUM_VVC_SIGNALS when i = 0 else
                                 v_num_expected_alerts + 1;
        check_value(get_alert_counter(alert_level), v_num_expected_alerts, TB_NOTE, "Unwanted activity alert was expected", C_SCOPE, ID_NEVER);
        -- Set back original value
        v_num_expected_alerts := get_alert_counter(alert_level);
        case i is
          when 0 => dut_m_tdata  <= release;
                    dut_m_tkeep  <= release;
                    dut_m_tuser  <= release;
                    dut_m_tvalid <= release;
                    dut_m_tlast  <= release;
                    dut_m_tstrb  <= release;
                    dut_m_tid    <= release;
                    dut_m_tdest  <= release;
          when 1 => dut_m_tdata  <= release;
          when 2 => dut_m_tkeep  <= release;
          when 3 => dut_m_tuser  <= release;
          when 4 => dut_m_tvalid <= release;
          when 5 => dut_m_tlast  <= release;
          when 6 => dut_m_tstrb  <= release;
          when 7 => dut_m_tid    <= release;
          when 8 => dut_m_tdest  <= release;
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
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    -- override default config with settings for this testbench
    v_axistream_bfm_config.max_wait_cycles          := 1000;
    v_axistream_bfm_config.max_wait_cycles_severity := error;
    v_axistream_bfm_config.check_packet_length      := true;
    if GC_USE_SETUP_AND_HOLD then
      v_axistream_bfm_config.clock_period := C_CLK_PERIOD;
      v_axistream_bfm_config.setup_time   := C_CLK_PERIOD / 4;
      v_axistream_bfm_config.hold_time    := C_CLK_PERIOD / 4;
      v_axistream_bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    end if;

    -- Default: use same config for both the master and slave VVC
    shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config := v_axistream_bfm_config;
    shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config  := v_axistream_bfm_config;
    shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config  := v_axistream_bfm_config;
    shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config   := v_axistream_bfm_config;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);

    disable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ALL_MESSAGES);
    disable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ALL_MESSAGES);
    disable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_MASTER, ALL_MESSAGES);
    disable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, ALL_MESSAGES);
    --enable_log_msg(AXISTREAM_VVCT, 0, ID_BFM);
    --enable_log_msg(AXISTREAM_VVCT, 1, ID_BFM);
    enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ID_PACKET_INITIATE);
    enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ID_PACKET_INITIATE);
    enable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_MASTER, ID_PACKET_INITIATE);
    enable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, ID_PACKET_INITIATE);
    --enable_log_msg(AXISTREAM_VVCT, 0, ID_PACKET_DATA);
    --enable_log_msg(AXISTREAM_VVCT, 1, ID_PACKET_DATA);
    enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ID_PACKET_COMPLETE);
    enable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, ID_PACKET_COMPLETE);
    --enable_log_msg(AXISTREAM_VVCT, 0, ID_IMMEDIATE_CMD);
    --enable_log_msg(AXISTREAM_VVCT, 1, ID_IMMEDIATE_CMD);

    log(ID_LOG_HDR, "Start Simulation of AXI-Stream");
    ------------------------------------------------------------
    clock_ena <= true;              -- the axistream_reset routine assumes the clock is running
    gen_pulse(areset, 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream VVC Master (VVC_IDX=2) transmits directly to VVC Slave (VVC_IDX=3)");
    ------------------------------------------------------------

    for i in 1 to 10 loop
      v_numBytes := 96;           --random(1, c_max_bytes);
      v_numWords := integer(ceil(real(v_numBytes) / (real(GC_DATA_WIDTH) / 8.0)));
      for byte in 0 to v_numBytes - 1 loop
        v_data_array(byte) := random(v_data_array(0)'length);
      end loop;
      for word in 0 to v_numWords - 1 loop
        v_user_array(word) := random(v_user_array(0)'length); -- Note that only (GC_USER_WIDTH-1 downto 0) will be used
        v_strb_array(word) := random(v_strb_array(0)'length);
        v_id_array(word)   := random(v_id_array(0)'length);
        v_dest_array(word) := random(v_dest_array(0)'length);
      end loop;

      -- Make sure ready signal is toggled in various ways
      shared_axistream_vvc_config(3).bfm_config.ready_low_at_word_num := random(0, v_numWords - 1);
      shared_axistream_vvc_config(3).bfm_config.ready_low_duration    := random(0, 5);
      shared_axistream_vvc_config(3).bfm_config.ready_default_value   := random(VOId);
      --

      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1), "transmit VVC2VVC. Default tuser etc, i=" & to_string(i));
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1), "expect  VVC2VVC. Default tuser etc, i=" & to_string(i));

      log("include tuser test. VVC Master (VVC_IDX=2) transmits directly to VVC Slave (VVC_IDX=3)");
      ------------------------------------------------------------
      -- tuser = something. tstrb etc = default
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit VVC2VVC, tuser set, but default tstrb etc");
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect VVC2VVC,   tuser set, but default tstrb etc");
      -----------------------------------------------------------
      -- tuser tstrb etc is set (no defaults)
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1),
                               v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                               "transmit VVC2VVC, tuser tstrb etc are set");
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1), "expect VVC2VVC,   tuser set, but default tstrb etc");
      -----------------------------------------------------------

      -- test _receive, Check that tuser is fetched correctly
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit before receive, Check that tuser is fetched correctly,i=" & to_string(i));
      axistream_receive(AXISTREAM_VVCT, 3, "test axistream_receive / fetch_result (with tuser) ");
      v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 3);

      await_completion(AXISTREAM_VVCT, 2, 1 ms);
      await_completion(AXISTREAM_VVCT, 3, 1 ms);
      fetch_result(AXISTREAM_VVCT, 3, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
      check_value(v_result_from_fetch.data_array(0 to v_numBytes - 1) = v_data_array(0 to v_numBytes - 1), error, "Verifying that fetched data is as expected", C_TB_SCOPE_DEFAULT);
      check_value(v_result_from_fetch.data_length, v_numBytes, error, "Verifying that fetched data_length is as expected", C_TB_SCOPE_DEFAULT);
      for i in 0 to v_numWords - 1 loop
        check_value(v_result_from_fetch.user_array(i)(GC_USER_WIDTH - 1 downto 0) = v_user_array(i)(GC_USER_WIDTH - 1 downto 0), error, "Verifying that fetched tuser_array(" & to_string(i) & ") is as expected", C_TB_SCOPE_DEFAULT);
      end loop;

      -- verify alert if the data is not as expected
      increment_expected_alerts(warning, 1);
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit, data wrong ,i=" & to_string(i));
      v_idx               := random(0, v_numBytes - 1);
      v_data_array(v_idx) := not v_data_array(v_idx);
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect,   data wrong ,i=" & to_string(i), warning);

      -- verify alert if the tuser is not what is expected
      increment_expected_alerts(warning, 1);
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1),
                               v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                               "transmit, tuser wrong ,i=" & to_string(i));

      v_idx               := random(0, v_numWords - 1);
      v_user_array(v_idx) := not v_user_array(v_idx); -- Provoke alert in axistream_expect()
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1),
                             v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                             "expect,   tuser wrong ,i=" & to_string(i), warning);

      -- verify alert if the tstrb is not what is expected
      increment_expected_alerts(warning, 1);
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1),
                               v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                               "transmit, tstrb wrong ,i=" & to_string(i));
      v_idx               := random(0, v_numWords - 1);
      v_strb_array(v_idx) := not v_strb_array(v_idx); -- Provoke alert in axistream_expect()
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1),
                             v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                             "expect,   tstrb wrong ,i=" & to_string(i), warning);

      -- verify alert if the tid is not what is expected
      increment_expected_alerts(warning, 1);
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1),
                               v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                               "transmit, tid wrong ,i=" & to_string(i));
      v_idx             := random(0, v_numWords - 1);
      v_id_array(v_idx) := not v_id_array(v_idx); -- Provoke alert in axistream_expect()
      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1),
                             v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                             "expect,   tid wrong ,i=" & to_string(i), warning);

      -- verify alert if the tdest is not what is expected
      increment_expected_alerts(warning, 1);
      axistream_transmit_bytes(AXISTREAM_VVCT, 2, v_data_array(0 to v_numBytes - 1),
                               v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                               "transmit, tdest wrong ,i=" & to_string(i));
      v_idx               := random(0, v_numWords - 1);
      v_dest_array(v_idx) := not v_dest_array(v_idx); -- Provoke alert in axistream_expect()

      v_id_array := (others => (others => '-')); -- also test the use of don't care

      axistream_expect_bytes(AXISTREAM_VVCT, 3, v_data_array(0 to v_numBytes - 1),
                             v_user_array(0 to v_numWords - 1), v_strb_array(0 to v_numWords - 1), v_id_array(0 to v_numWords - 1), v_dest_array(0 to v_numWords - 1),
                             "expect,   tdest wrong ,i=" & to_string(i), warning);

      await_completion(AXISTREAM_VVCT, 3, 1 ms, "Wait for receive to finish");
    end loop;                       -- i

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream_receive and fetch_result ");
    ------------------------------------------------------------
    v_numBytes := random(1, c_max_bytes);
    v_numWords := integer(ceil(real(v_numBytes) / (real(GC_DATA_WIDTH) / 8.0)));
    for byte in 0 to v_numBytes - 1 loop
      v_data_array(byte) := random(v_data_array(0)'length);
    end loop;

    for word in 0 to v_numWords - 1 loop
      v_user_array(word) := random(v_user_array(0)'length);
      v_strb_array(word) := random(v_strb_array(0)'length);
      v_id_array(word)   := random(v_id_array(0)'length);
      v_dest_array(word) := random(v_dest_array(0)'length);
    end loop;

    axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), "transmit");
    axistream_receive(AXISTREAM_VVCT, 1, "test axistream_receive / fetch_result (without tuser) ");
    v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 1);

    await_completion(AXISTREAM_VVCT, 1, 1 ms, "Wait for receive to finish");
    fetch_result(AXISTREAM_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
    check_value(v_result_from_fetch.data_array(0 to v_numBytes - 1) = v_data_array(0 to v_numBytes - 1), error, "Verifying that fetched data is as expected", C_TB_SCOPE_DEFAULT, ID_SEQUENCER);
    check_value(v_result_from_fetch.data_length, v_numBytes, error, "Verifying that fetched data_length is as expected", C_TB_SCOPE_DEFAULT, ID_SEQUENCER);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream transmit when tready=0 from DUT at start of transfer  ");
    ------------------------------------------------------------
    shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).unwanted_activity_severity := NO_ALERT; -- Unwanted activity errors due to transmit with inactive slave
    -- Fill DUT FIFO to provoke tready=0
    v_numBytes := 1;
    for i in 0 to C_DUT_FIFO_DEPTH - 1 loop
      v_data_array(0) := std_logic_vector(to_unsigned(i, v_data_array(0)'length));
      axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), "transmit to fill DUT,i=" & to_string(i));
    end loop;
    await_completion(AXISTREAM_VVCT, 0, 1 ms);
    wait for 100 ns;
    shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).unwanted_activity_severity := C_AXISTREAM_VVC_CONFIG_DEFAULT.unwanted_activity_severity;

    -- DUT FIFO is now full. Schedule the transmit which will wait for tready until DUT is read from later
    v_data_array(0) := x"D0";
    axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), "start transmit while tready=0");

    -- Make DUT not full anymore. Check data from DUT equals transmitted data
    for i in 0 to C_DUT_FIFO_DEPTH - 1 loop
      v_data_array(0) := std_logic_vector(to_unsigned(i, v_data_array(0)'length));
      axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), "expect ");
    end loop;

    v_data_array(0) := x"D0";
    axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), "expect ");

    wait for 100 ns;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream transmits: ");
    ------------------------------------------------------------
    shared_axistream_vvc_config(0).inter_bfm_delay.delay_type := TIME_FINISH2START;
    for i in 0 to 2 loop
      -- Various delay between each transmit
      shared_axistream_vvc_config(0).inter_bfm_delay.delay_in_time := i * c_Clk_Period;

      for i in 1 to 20 loop
        v_numBytes := random(1, c_max_bytes);
        v_numWords := integer(ceil(real(v_numBytes) / (real(GC_DATA_WIDTH) / 8.0)));
        -- Generate packet data
        v_cnt      := i;
        for byte in 0 to v_numBytes - 1 loop
          v_data_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array(0)'length));
          v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
          v_strb_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_strb_array(0)'length));
          v_id_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_id_array(0)'length));
          v_dest_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_dest_array(0)'length));
          v_cnt              := v_cnt + 1;
        end loop;

        -- VVC call
        -- tuser, tstrb etc = default
        axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), "transmit,i=" & to_string(i));
        axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), "expect,  i=" & to_string(i));

        if GC_INCLUDE_TUSER then
          -- tuser = something. tstrb etc = default
          axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit, tuser set,i=" & to_string(i));
          axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect,   tuser set,i=" & to_string(i));

          -- test _receive, Check that tuser is fetched correctly
          axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit before receive, Check that tuser is fetched correctly,i=" & to_string(i));
          axistream_receive(AXISTREAM_VVCT, 1, "test axistream_receive / fetch_result (with tuser) ");
          v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 1);

          await_completion(AXISTREAM_VVCT, 0, 1 ms);
          await_completion(AXISTREAM_VVCT, 1, 1 ms);
          fetch_result(AXISTREAM_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
          check_value(v_result_from_fetch.data_array(0 to v_numBytes - 1) = v_data_array(0 to v_numBytes - 1), error, "Verifying that fetched data is as expected", C_TB_SCOPE_DEFAULT);
          check_value(v_result_from_fetch.data_length, v_numBytes, error, "Verifying that fetched data_length is as expected", C_TB_SCOPE_DEFAULT);
          for i in 0 to v_numWords - 1 loop
            check_value(v_result_from_fetch.user_array(i)(GC_USER_WIDTH - 1 downto 0) = v_user_array(i)(GC_USER_WIDTH - 1 downto 0), error, "Verifying that fetched tuser_array(" & to_string(i) & ") is as expected", C_TB_SCOPE_DEFAULT);
          end loop;

          -- verify alert if the data is not what is expected
          increment_expected_alerts(warning, 1);
          axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit, data wrong ,i=" & to_string(i));
          v_idx               := random(0, v_numBytes - 1);
          v_data_array(v_idx) := not v_data_array(v_idx);
          axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect,   data wrong ,i=" & to_string(i), warning);

          -- verify alert if the tuser is not what is expected
          increment_expected_alerts(warning, 1);
          axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit, tuser wrong ,i=" & to_string(i));
          v_idx               := random(0, v_numWords - 1);
          v_user_array(v_idx) := not v_user_array(v_idx);
          axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect,   tuser wrong ,i=" & to_string(i), warning);
        end if;

      end loop;

      -- Await completion on both VVCs
      await_completion(AXISTREAM_VVCT, 0, 1 ms);
      await_completion(AXISTREAM_VVCT, 1, 1 ms);
      report_alert_counters(INTERMEDIATE); -- Report final counters and print conclusion for simulation (Success/Fail)
    end loop;

    -- verify alert if the 'tlast' is not where expected
    for i in 1 to 1 loop
      if GC_INCLUDE_TUSER then
        v_numBytes := (GC_DATA_WIDTH / 8) + 1; -- So that v_numBytes - 1 makes the tlast in previous clock cycle
        v_numWords := integer(ceil(real(v_numBytes) / (real(GC_DATA_WIDTH) / 8.0)));

        await_completion(AXISTREAM_VVCT, 1, 1 ms);
        axistream_transmit_bytes(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "transmit, tlast wrong ,i=" & to_string(i));
        increment_expected_alerts(warning, 1);
        shared_axistream_vvc_config(1).bfm_config.protocol_error_severity := warning;
        v_numBytes                                                        := v_numBytes - 1;

        axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect,   tlast wrong ,i=" & to_string(i), NO_ALERT);

        -- due to the premature tlast, make an extra call to read the remaining (corrupt) packet
        axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes - 1), v_user_array(0 to v_numWords - 1), "expect,   tlast wrong ,i=" & to_string(i), NO_ALERT);

        await_completion(AXISTREAM_VVCT, 1, 1 ms);
        -- Cleanup after test case
        shared_axistream_vvc_config(1).bfm_config.protocol_error_severity := error;
      end if;
    end loop;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: check axistream VVC Master only transmits and VVC Slave only receives");
    ------------------------------------------------------------
    increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
    axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array, "transmit from VVC slave");
    increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
    axistream_receive(AXISTREAM_VVCT, C_VVC2VVC_MASTER, "receive on VVC master");
    increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
    axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array, "expect on VVC master");

    axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array, "transmit");
    axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array, "expect ");
    await_completion(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, 1 ms);

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "TC: Test different configurations of ready default value with ready low");
    -------------------------------------------------------------------------------------------
    for i in 0 to 3 loop
      shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_default_value   := '0' when i < 2 else '1';
      shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_default_value    := '0' when i < 2 else '1';
      wait for C_CLK_PERIOD;
      shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_at_word_num := 0 when (i mod 2 = 0) else 2;
      shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_at_word_num  := 0 when (i mod 2 = 0) else 2;
      shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_duration    := 1;
      shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_duration     := 1;

      axistream_transmit_bytes(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, v_data_array(0 to 0), "transmit 1 byte");
      axistream_transmit_bytes(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, v_data_array(0 to 0), "transmit 1 byte");
      axistream_transmit_bytes(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, v_data_array(0 to 3), "transmit 4 bytes");
      axistream_transmit_bytes(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, v_data_array(0 to 3), "transmit 4 bytes");
      axistream_expect_bytes(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, v_data_array(0 to 0), "expect 1 byte");
      axistream_expect_bytes(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, v_data_array(0 to 0), "expect 1 byte");
      axistream_expect_bytes(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, v_data_array(0 to 3), "expect 4 bytes");
      axistream_expect_bytes(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, v_data_array(0 to 3), "expect 4 bytes");
      await_completion(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, 1 ms);

      axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array(0 to 0), "transmit 1 byte");
      axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array(0 to 0), "transmit 1 byte");
      axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array(0 to 3), "transmit 4 bytes");
      axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array(0 to 3), "transmit 4 bytes");
      axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array(0 to 0), "expect 1 byte");
      axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array(0 to 0), "expect 1 byte");
      axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array(0 to 3), "expect 4 bytes");
      axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array(0 to 3), "expect 4 bytes");
      await_completion(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, 1 ms);
    end loop;

    --------------------------------------------------------------------------
    log(ID_LOG_HDR, "TC: Test random configurations of valid and ready low");
    --------------------------------------------------------------------------
    for i in 0 to 59 loop
      if i < 20 then
        shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_at_word_num := random(0, 5);
        shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_duration    := random(0, 5);
        shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_at_word_num  := random(0, 5);
        shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_duration     := random(0, 5);
        shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_at_word_num  := random(0, 5);
        shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_duration     := random(0, 5);
        shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_at_word_num   := random(0, 5);
        shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_duration      := random(0, 5);
      else
        shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_at_word_num := C_MULTIPLE_RANDOM;
        shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_duration    := C_RANDOM;
        shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_at_word_num  := C_MULTIPLE_RANDOM;
        shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_duration     := C_RANDOM;
        shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_at_word_num  := C_MULTIPLE_RANDOM;
        shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_duration     := C_RANDOM;
        shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_at_word_num   := C_MULTIPLE_RANDOM;
        shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_duration      := C_RANDOM;
        if i < 30 then
          -- Probability of multiple random is zero
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 0.0;
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 20;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob  := 0.0;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration   := 20;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 0.0;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 20;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob   := 0.0;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration    := 20;
        elsif i < 40 then
          -- Probability of multiple random is low and max random duration is high
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 0.1;
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 20;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob  := 0.1;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration   := 20;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 0.1;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 20;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob   := 0.1;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration    := 20;
        elsif i < 50 then
          -- Probability of multiple random is 50/50 and max random duration is low
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 0.5;
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 5;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob  := 0.5;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration   := 5;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 0.5;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 5;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob   := 0.5;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration    := 5;
        else
          -- Probability of multiple random is 100% (every cycle) and max random duration is 1
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_multiple_random_prob := 1.0;
          shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config.valid_low_max_random_duration  := 1;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_multiple_random_prob  := 1.0;
          shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config.valid_low_max_random_duration   := 1;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob  := 1.0;
          shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config.ready_low_max_random_duration   := 1;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_multiple_random_prob   := 1.0;
          shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config.ready_low_max_random_duration    := 1;
        end if;
      end if;
      axistream_transmit_bytes(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, v_data_array(0 to 15), "transmit 16 bytes");
      axistream_expect_bytes(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, v_data_array(0 to 15), "expect 16 bytes");
      await_completion(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, 1 ms);
      axistream_transmit_bytes(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array(0 to 15), "transmit 16 bytes");
      axistream_expect_bytes(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array(0 to 15), "expect 16 bytes");
      await_completion(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, 1 ms);
    end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing Unwanted Activity Detection in VVC", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    for i in 0 to 2 loop
      -- Test different alert severity configurations
      if i = 0 then
        v_alert_level := C_AXISTREAM_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
      elsif i = 1 then
        v_alert_level := FAILURE;
      else
        v_alert_level := NO_ALERT;
      end if;
      log(ID_SEQUENCER, "Setting unwanted_activity_severity to " & to_upper(to_string(v_alert_level)), C_SCOPE);
      shared_axistream_vvc_config(C_FIFO2VVC_MASTER).unwanted_activity_severity := v_alert_level;
      shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).unwanted_activity_severity  := v_alert_level;

      log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
      for byte in 0 to 7 loop
        v_data_array(byte) := random(v_data_array(0)'length);
      end loop;
      axistream_transmit_bytes(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, v_data_array(0 to 7), "Transmit data");
      axistream_expect_bytes(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, v_data_array(0 to 7), "Expect data");
      await_completion(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, 1 ms);

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
    wait for 1000 ns;               -- to allow some time for completion
    report_alert_counters(FINAL);   -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                           -- to stop completely

  end process p_main;
end func;
