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

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_axistream;
context bitvis_vip_axistream.vvc_context;

--hdlregression:tb
-- Test case entity
entity axistream_width_vvc_tb is
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
architecture func of axistream_width_vvc_tb is

  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 10 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  -- VVC idx
  constant C_VVC_MASTER_32B : natural := 0;
  constant C_VVC_SLAVE_32B  : natural := 1;
  constant C_VVC_MASTER_64B : natural := 2;
  constant C_VVC_SLAVE_64B  : natural := 3;

  constant C_DUT_FIFO_DEPTH : natural := 4;

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk       : std_logic := '0';
  signal areset    : std_logic := '0';
  signal clock_ena : boolean   := false;

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

begin
  -----------------------------
  -- Instantiate Test-harness
  -----------------------------
  i_axistream_test_harness : entity bitvis_vip_axistream.test_harness(struct_width_vvc)
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
    variable axistream_bfm_config : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;

    constant C_BYTE              : natural := 8;
    constant C_MAX_BYTES         : natural := 100; -- max bytes per packet to send
    constant C_MAX_BYTES_IN_WORD : natural := 4;

    variable v_data_array_1_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(1 * C_BYTE - 1 downto 0);
    variable v_data_array_2_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(2 * C_BYTE - 1 downto 0);
    variable v_data_array_3_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(3 * C_BYTE - 1 downto 0);
    variable v_data_array_4_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(4 * C_BYTE - 1 downto 0);

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    -- override default config with settings for this testbench
    axistream_bfm_config.max_wait_cycles          := 1000;
    axistream_bfm_config.max_wait_cycles_severity := error;
    axistream_bfm_config.check_packet_length      := true;
    axistream_bfm_config.byte_endianness          := LOWER_BYTE_RIGHT; -- LOWER_BYTE_LEFT
    if GC_USE_SETUP_AND_HOLD then
      axistream_bfm_config.clock_period := C_CLK_PERIOD;
      axistream_bfm_config.setup_time   := C_CLK_PERIOD / 4;
      axistream_bfm_config.hold_time    := C_CLK_PERIOD / 4;
      axistream_bfm_config.bfm_sync     := SYNC_WITH_SETUP_AND_HOLD;
    end if;

    -- Default: use same config for both the master and slave VVC
    shared_axistream_vvc_config(C_VVC_MASTER_32B).bfm_config := axistream_bfm_config;
    shared_axistream_vvc_config(C_VVC_SLAVE_32B).bfm_config  := axistream_bfm_config;
    shared_axistream_vvc_config(C_VVC_MASTER_64B).bfm_config := axistream_bfm_config;
    shared_axistream_vvc_config(C_VVC_SLAVE_64B).bfm_config  := axistream_bfm_config;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Configure logging
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_BFM);

    disable_log_msg(AXISTREAM_VVCT, ALL_INSTANCES, ALL_MESSAGES);
    enable_log_msg(AXISTREAM_VVCT, C_VVC_MASTER_32B, ID_PACKET_INITIATE);
    enable_log_msg(AXISTREAM_VVCT, C_VVC_MASTER_64B, ID_PACKET_INITIATE);
    enable_log_msg(AXISTREAM_VVCT, C_VVC_SLAVE_32B, ID_PACKET_COMPLETE);
    enable_log_msg(AXISTREAM_VVCT, C_VVC_SLAVE_64B, ID_PACKET_COMPLETE);

    log(ID_LOG_HDR, "Start Simulation of AXI-Stream");
    ------------------------------------------------------------
    clock_ena <= true;
    gen_pulse(areset, 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");

    v_data_array_1_byte(0) := (x"AA");
    v_data_array_2_byte(0) := (x"AABB");
    v_data_array_3_byte(0) := (x"AABBCC");
    v_data_array_4_byte(0) := (x"AABBCCDD");

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: Transmit packets with different sizes using the 32-bit interface");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_1_byte(0 to 0), "1 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_1_byte(0 to 0), "1 byte expect 32b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_2_byte(0 to 0), "2 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_2_byte(0 to 0), "2 byte expect 32b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_3_byte(0 to 0), "3 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_3_byte(0 to 0), "3 byte expect 32b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_4_byte(0 to 0), "4 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_4_byte(0 to 0), "4 byte expect 32b IF");
    await_completion(AXISTREAM_VVCT, C_VVC_SLAVE_32B, 1 ms);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: Transmit packets with different sizes using the 64-bit interface");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_64B, v_data_array_1_byte(0 to 0), "1 byte transmit 64b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_64B, v_data_array_1_byte(0 to 0), "1 byte expect 64b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_64B, v_data_array_2_byte(0 to 0), "2 byte transmit 64b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_64B, v_data_array_2_byte(0 to 0), "2 byte expect 64b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_64B, v_data_array_3_byte(0 to 0), "3 byte transmit 64b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_64B, v_data_array_3_byte(0 to 0), "3 byte expect 64b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_64B, v_data_array_4_byte(0 to 0), "4 byte transmit 64b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_64B, v_data_array_4_byte(0 to 0), "4 byte expect 64b IF");
    await_completion(AXISTREAM_VVCT, C_VVC_SLAVE_64B, 1 ms);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: Transmit packets with different sizes using the 32-bit interface");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_1_byte(0 to 0), "1 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_1_byte(0 to 0), "1 byte expect 32b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_2_byte(0 to 0), "2 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_2_byte(0 to 0), "2 byte expect 32b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_3_byte(0 to 0), "3 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_3_byte(0 to 0), "3 byte expect 32b IF");
    axistream_transmit(AXISTREAM_VVCT, C_VVC_MASTER_32B, v_data_array_4_byte(0 to 0), "4 byte transmit 32b IF");
    axistream_expect(AXISTREAM_VVCT, C_VVC_SLAVE_32B, v_data_array_4_byte(0 to 0), "4 byte expect 32b IF");
    await_completion(AXISTREAM_VVCT, C_VVC_SLAVE_32B, 1 ms);

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
end architecture func;
