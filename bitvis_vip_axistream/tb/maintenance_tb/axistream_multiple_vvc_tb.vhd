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

--hdlunit:tb
-- Test case entity
entity axistream_multiple_vvc_tb is
  generic (
    GC_TESTCASE       : string := "UVVM";
    GC_DATA_WIDTH     : natural := 32;  -- number of bits in the AXI-Stream IF data vector
    GC_USER_WIDTH     : natural := 1;  -- number of bits in the AXI-Stream IF tuser vector
    GC_ID_WIDTH       : natural := 1;  -- number of bits in AXI-Stream IF tID
    GC_DEST_WIDTH     : natural := 1;  -- number of bits in AXI-Stream IF tDEST
    GC_INCLUDE_TUSER  : boolean := true -- If tuser is included in DUT's AXI interface
  );
end entity;

-- Test case architecture
architecture func of axistream_multiple_vvc_tb is

--------------------------------------------------------------------------------
-- Types and constants declarations
--------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 10 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  constant c_max_bytes : natural   := 200;  -- max bytes per packet to send
  constant GC_DUT_FIFO_DEPTH : natural := 4;
--------------------------------------------------------------------------------
-- Signal declarations
--------------------------------------------------------------------------------
  signal   clk         : std_logic := '0';
  signal   areset      : std_logic := '0';
  signal   clock_ena   : boolean   := false;

  -- signals
  -- The axistream interface is gathered in one record, so procedures that use the
  -- axistream interface have less arguments
  signal axistream_if_m : t_axistream_if(tdata(GC_DATA_WIDTH -1 downto 0),
                                        tkeep((GC_DATA_WIDTH/8)-1 downto 0),
                                        tuser(GC_USER_WIDTH -1 downto 0),
                                         tstrb((GC_DATA_WIDTH/8)-1 downto 0),
                                        tid(    GC_ID_WIDTH     -1 downto 0),
                                        tdest(  GC_DEST_WIDTH   -1 downto 0)
                                        );
  signal axistream_if_s : t_axistream_if(tdata(GC_DATA_WIDTH -1 downto 0),
                                        tkeep((GC_DATA_WIDTH/8)-1 downto 0),
                                        tuser(GC_USER_WIDTH -1 downto 0),
                                        tstrb((GC_DATA_WIDTH/8)-1 downto 0),
                                        tid(    GC_ID_WIDTH     -1 downto 0),
                                        tdest(  GC_DEST_WIDTH   -1 downto 0)
                                        );

--------------------------------------------------------------------------------
-- Component declarations
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
begin
  -----------------------------
  -- Instantiate Testharness
  -----------------------------
  i_axistream_test_harness : entity bitvis_vip_axistream.test_harness(struct_multiple_vvc)
    generic map(
      GC_DATA_WIDTH => GC_DATA_WIDTH,
      GC_USER_WIDTH => GC_USER_WIDTH,
      GC_ID_WIDTH   => GC_ID_WIDTH,
      GC_DEST_WIDTH => GC_DEST_WIDTH,
      GC_DUT_FIFO_DEPTH => GC_DUT_FIFO_DEPTH,
      GC_INCLUDE_TUSER => GC_INCLUDE_TUSER
      )
    port map(
      clk            => clk,
      areset         => areset,
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
    variable axistream_bfm_config : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;
    constant C_NUM_VVCS : natural := 8;

    variable v_start_time, v_end_time  : time;
    variable v_elapsed_time : time;
    variable v_elapsed_clk_cycles : natural;
    variable v_cnt        : integer                          := 0;
    variable v_idx        : integer                          := 0;
    variable v_numBytes   : integer                          := 0;
    variable v_numWords   : integer                          := 0;
    variable v_data_array : t_slv_array(0 to c_max_bytes-1)(7 downto 0);
    variable v_user_array : t_user_array(v_data_array'range) := (others => (others => '0'));
    variable v_strb_array : t_strb_array(v_data_array'range) := (others => (others => '0'));
    variable v_id_array   : t_id_array(v_data_array'range)   := (others => (others => '0'));
    variable v_dest_array : t_dest_array(v_data_array'range) := (others => (others => '0'));

    variable v_cmd_idx : natural;
    variable v_fetch_is_accepted : boolean;
    variable v_result_from_fetch : bitvis_vip_axistream.vvc_cmd_pkg.t_vvc_result;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");


    set_alert_stop_limit(TB_ERROR, 3); -- Don't stop at Timeout tests

    await_uvvm_initialization(VOID);

    -- override default config with settings for this testbench
    axistream_bfm_config.clock_period             := C_CLK_PERIOD;
    axistream_bfm_config.max_wait_cycles          := 1000;
    axistream_bfm_config.max_wait_cycles_severity := error;
    axistream_bfm_config.check_packet_length      := true;

    -- Default: use same config for both the master and slave VVC
    for i in 0 to c_num_vvcs-1 loop
      shared_axistream_vvc_config(i).bfm_config := axistream_bfm_config;  -- vvc_methods_pkg
    end loop;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);

    for i in 0 to c_num_vvcs-1 loop
      disable_log_msg(AXISTREAM_VVCT, i, ALL_MESSAGES);
      enable_log_msg(AXISTREAM_VVCT, i, ID_SEQUENCER);
    end loop;

--    enable_log_msg(AXISTREAM_VVCT, 0, ID_BFM);
--    enable_log_msg(AXISTREAM_VVCT, 1, ID_BFM);
    enable_log_msg(AXISTREAM_VVCT, 0, ID_SEQUENCER);
    enable_log_msg(AXISTREAM_VVCT, 1, ID_SEQUENCER);
    enable_log_msg(AXISTREAM_VVCT, 2, ID_SEQUENCER);
    enable_log_msg(AXISTREAM_VVCT, 3, ID_SEQUENCER);

--    enable_log_msg(AXISTREAM_VVCT, 0, ID_PACKET_INITIATE);
--    enable_log_msg(AXISTREAM_VVCT, 1, ID_PACKET_INITIATE);
--    enable_log_msg(AXISTREAM_VVCT, 0, ID_PACKET_DATA);
--    enable_log_msg(AXISTREAM_VVCT, 1, ID_PACKET_DATA);
--    enable_log_msg(AXISTREAM_VVCT, 0, ID_PACKET_COMPLETE);
--    enable_log_msg(AXISTREAM_VVCT, 1, ID_PACKET_COMPLETE);
    enable_log_msg(AXISTREAM_VVCT, 0, ID_IMMEDIATE_CMD);
    enable_log_msg(AXISTREAM_VVCT, 1, ID_IMMEDIATE_CMD);
    enable_log_msg(AXISTREAM_VVCT, 2, ID_IMMEDIATE_CMD);
    enable_log_msg(AXISTREAM_VVCT, 3, ID_IMMEDIATE_CMD);


    log(ID_LOG_HDR, "Start Simulation of AXI-Stream");
    ------------------------------------------------------------
    clock_ena <= true;  -- the axistream_reset routine assumes the clock is running
    gen_pulse(areset, 10*C_CLK_PERIOD, "Pulsing reset for 10 clock periods");


    ------------------------------------------------------------
    -- Generate some packets for later
    ------------------------------------------------------------
    v_numBytes := 40;
    v_numWords := integer(ceil(real(v_numBytes)/(real(GC_DATA_WIDTH)/8.0)));
    v_cnt      := 0;
    for byte in 0 to v_data_array'high loop
      v_data_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array(0)'length));
      v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
      v_strb_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_strb_array(0)'length));
      v_id_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_id_array(0)'length));
      v_dest_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_dest_array(0)'length));
      v_cnt              := v_cnt + 1;
    end loop;
    ------------------------------------------------------------

    ------------------------------------------------------------
    log("TC: insert_delay : time ");
    ------------------------------------------------------------
    v_start_time := now;
    log("start.");

    insert_delay(AXISTREAM_VVCT, 0, 100 ns, "insert_delay (time)");

    log("command sent.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    log("await is done .");
    check_value((now - v_start_time), 100 ns, ERROR, "check insert_delay '", C_SCOPE, ID_SEQUENCER);
    ------------------------------------------------------------
    log("TC: insert_delay : integer ");
    ------------------------------------------------------------
    v_start_time := now;
    log("start.");

    insert_delay(AXISTREAM_VVCT, 0, 100, "insert_delay (integer)");

    log("command sent.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    log("await is done .");
    check_value((now - v_start_time), 100 * C_CLK_PERIOD, ERROR, "check insert_delay '", C_SCOPE, ID_SEQUENCER);


    ------------------------------------------------------------
    log("TC: await_any_completion: 2 VVCs");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to v_numBytes), "transmit short packte");
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to 2*v_numBytes), "transmit long packet");

    v_start_time := now;
    await_any_completion(AXISTREAM_VVCT, 0, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 1, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 1 + v_numWords, ERROR, "2 vvcs: checking that we waited long enough for the quickest VVC to finish", C_SCOPE, ID_SEQUENCER);

    -- Cleanup
    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;
    ------------------------------------------------------------
    log("TC: await_any_completion: 3 VVCs");
    ------------------------------------------------------------

    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 2*v_numBytes), "transmit long packte");
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit short packet");
    axistream_transmit(AXISTREAM_VVCT, 2, v_data_array(0 to 3*v_numBytes), "transmit long packet");

    v_start_time := now;
    await_any_completion(AXISTREAM_VVCT, 0, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 1, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 2, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 1 + v_numWords, ERROR, "3 vvcs: checking that we waited long enough for the quickest VVC to finish", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion: 3 VVCs, one of the NOT_LAST is already complete");
    ------------------------------------------------------------

    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit packet");
    axistream_transmit(AXISTREAM_VVCT, 2, v_data_array(0 to 3*v_numBytes), "transmit long packet");

    v_start_time := now;
    await_any_completion(AXISTREAM_VVCT, 0, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 1, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 2, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 0, ERROR, "3 vvcs: checking that we waited 0 time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion: 2 VVCs, the LAST is already complete");
    ------------------------------------------------------------

    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit packet");

    v_start_time := now;
    await_any_completion(AXISTREAM_VVCT, 1, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 0, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 0, ERROR, "2 vvcs: checking that we waited 0 time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;
    ------------------------------------------------------------
    log("TC: await_any_completion: 3 VVCs, the LAST is already complete");
    ------------------------------------------------------------

    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit packet");
    axistream_transmit(AXISTREAM_VVCT, 2, v_data_array(0 to 3*v_numBytes), "transmit long packet");

    v_start_time := now;
    await_any_completion(AXISTREAM_VVCT, 1, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 2, NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 0, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 0, ERROR, "3 vvcs: checking that we waited 0 time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;
    ------------------------------------------------------------
    log("TC: await_any_completion: all VVCs, one of the NOT_LAST is already complete");
    ------------------------------------------------------------

    -- All but one VVC :
    for i in 1 to C_NUM_VVCS-1 loop
      axistream_transmit(AXISTREAM_VVCT, i, v_data_array(0 to 2*v_numBytes), "transmit long packte");
    end loop;

    v_start_time := now;

    -- All but one VVC :
    for i in 0 to C_NUM_VVCS-2 loop
      await_any_completion(AXISTREAM_VVCT, i, NOT_LAST, 1 ms);
    end loop;
    -- Last VVC :
    await_any_completion(AXISTREAM_VVCT, C_NUM_VVCs-1, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 0, ERROR, "all vvcs: checking that we waited 0 time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion: all VVCs, all are already complete");
    ------------------------------------------------------------

    v_start_time := now;

    -- All but one VVC :
    for i in 0 to C_NUM_VVCS-2 loop
      await_any_completion(AXISTREAM_VVCT, i, NOT_LAST, 1 ms);
    end loop;
    -- Last VVC :
    await_any_completion(AXISTREAM_VVCT, C_NUM_VVCs-1, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 0, ERROR, "all vvcs: checking that we waited 0 time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion: all VVCs, multiple VVCs complete simultaneously ");
    ------------------------------------------------------------

    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 2*v_numBytes), "transmit long packet");
    for i in 1 to C_NUM_VVCS-1 loop
      axistream_transmit(AXISTREAM_VVCT, i, v_data_array(0 to v_numBytes), "transmit short packte");
    end loop;

    v_start_time := now;

    -- All but one VVC :
    for i in 0 to C_NUM_VVCS-2 loop
      await_any_completion(AXISTREAM_VVCT, i, NOT_LAST, 1 ms);
    end loop;
    -- Last VVC :
    await_any_completion(AXISTREAM_VVCT, C_NUM_VVCs-1, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 1 + v_numWords, ERROR, "all vvcs: checking that we waited shortest time", C_SCOPE, ID_SEQUENCER);

    ------------------------------------------------------------
    log("TC: await_any_completion: all VVCs, all VVCs complete simultaneously ");
    ------------------------------------------------------------

    for i in 0 to C_NUM_VVCS-1 loop
      axistream_transmit(AXISTREAM_VVCT, i, v_data_array(0 to v_numBytes), "transmit short packte");
    end loop;

    v_start_time := now;

    -- All but one VVC :
    for i in 1 to C_NUM_VVCS-1 loop
      await_any_completion(AXISTREAM_VVCT, i, NOT_LAST, 1 ms);
    end loop;
    -- Last VVC :
    await_any_completion(AXISTREAM_VVCT, 0, LAST, 1 ms);

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 1 + v_numWords, ERROR, "all vvcs: checking that we waited shortest time", C_SCOPE, ID_SEQUENCER);


    ------------------------------------------------------------
    log("TC: await_any_completion while VVCs are still busy from previous test, just to see what happens");
    ------------------------------------------------------------
    for i in 1 to C_NUM_VVCS-1 loop
      axistream_transmit(AXISTREAM_VVCT, i, v_data_array(0 to 2*v_numBytes), "transmit long packte");
    end loop;

    v_start_time := now;
    for i in 0 to C_NUM_VVCS-2 loop
      await_any_completion(AXISTREAM_VVCT, i, NOT_LAST, 1 ms);
    end loop;
    await_any_completion(AXISTREAM_VVCT, C_NUM_VVCs-1, LAST, 1 ms);



    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion(cmd_idx): 2 VVCs. Wait for 1st packet only, in the LAST VVC");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 2*v_numBytes), "transmit long packet");
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit short packet that shall be waited for");
    v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 1);
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to 2*v_numBytes), "transmit another packet not to be waited for");

    v_start_time := now;

    await_any_completion(AXISTREAM_VVCT, 0,           NOT_LAST, 1 ms);
    await_any_completion(AXISTREAM_VVCT, 1, v_cmd_idx, LAST, 1 ms,  "v_cmd_idx = " & to_string(v_cmd_idx));

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 1 + v_numWords, ERROR, "all vvcs: checking that we waited shortest time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion(cmd_idx): 2 VVCs. Wait for 1st packet only, in the NOT_LAST VVC");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 2*v_numBytes), "transmit long packet");
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit short packet that shall be waited for");
    v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 1);
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to 2*v_numBytes), "transmit another packet not to be waited for");

    v_start_time := now;

    await_any_completion(AXISTREAM_VVCT, 1, v_cmd_idx, NOT_LAST, 1 ms, "v_cmd_idx = " & to_string(v_cmd_idx) );
    await_any_completion(AXISTREAM_VVCT, 0,            LAST, 1 ms,     "no cmd_idx" );

    v_elapsed_clk_cycles := (now - v_start_time) / (C_CLK_PERIOD);

    check_value(v_elapsed_clk_cycles, 1 + v_numWords, ERROR, "all vvcs: checking that we waited shortest time", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;

    ------------------------------------------------------------
    log("TC: await_any_completion timeout in NOT_LAST, expect tb_ERROR ");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 2*v_numBytes), "transmit long packet");
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit short packet that shall be waited for");

    v_start_time := now;

    await_any_completion(AXISTREAM_VVCT, 1, NOT_LAST, 1 ns, "timeout after 1 ns= ");
    await_any_completion(AXISTREAM_VVCT, 0, LAST, 1 ms,     "no cmd_idx" );

    increment_expected_alerts(TB_ERROR,1);
    check_value((now - v_start_time), 1 ns, ERROR, "all vvcs: checking that we waited for 'timeout'", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;


    ------------------------------------------------------------
    log("TC: await_any_completion timeout in LAST, expect tb_ERROR ");
    ------------------------------------------------------------
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array(0 to 2*v_numBytes), "transmit long packet");
    axistream_transmit(AXISTREAM_VVCT, 1, v_data_array(0 to v_numBytes), "transmit short packet that shall be waited for");

    v_start_time := now;

    await_any_completion(AXISTREAM_VVCT, 1, NOT_LAST, 1 ms, " ");
    await_any_completion(AXISTREAM_VVCT, 0, LAST, 1 ns,     "timeout after 1 ns" );

    increment_expected_alerts(TB_ERROR,1);
    check_value((now - v_start_time), 1 ns, ERROR, "all vvcs: checking that we waited for 'timeout'", C_SCOPE, ID_SEQUENCER);

    log("Done.");
    for i in 0 to C_NUM_VVCS-1 loop
      await_completion(AXISTREAM_VVCT, i, 1 ms);
    end loop;




    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;
end func;
