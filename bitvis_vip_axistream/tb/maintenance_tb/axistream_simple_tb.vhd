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
-- VHDL unit     : Bitvis AXISTREAM library : axistream_simple_tb
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_axistream;
use bitvis_vip_axistream.axistream_bfm_pkg.all;

-- Test case entity
entity axistream_simple_tb is
  generic (
    GC_TEST               : string  := "UVVM";
    GC_DATA_WIDTH         : natural := 32;   -- number of bits in AXI-Stream IF tdata
    GC_USER_WIDTH         : natural := 1;    -- number of bits in AXI-Stream IF tuser
    GC_ID_WIDTH           : natural := 1;    -- number of bits in AXI-Stream IF tID
    GC_DEST_WIDTH         : natural := 1;    -- number of bits in AXI-Stream IF tDEST
    GC_USE_SETUP_AND_HOLD : boolean := false -- use setup and hold times to synchronise the BFM
  );
end entity;

-- Test case architecture
architecture func of axistream_simple_tb is

  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 10 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  constant c_max_bytes : natural := 100;  -- max bytes per packet to send
  constant GC_DUT_FIFO_DEPTH : natural := 4;

  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk       : std_logic := '0';
  signal areset    : std_logic := '0';
  signal clock_ena : boolean   := false;

  -- signals
  -- The axistream interface is gathered in one record, so procedures that use the
  -- axistream interface have less arguments
  signal axistream_if_m : t_axistream_if(tdata(GC_DATA_WIDTH -1 downto 0),
                                         tkeep((GC_DATA_WIDTH/8)-1 downto 0),
                                         tuser(  GC_USER_WIDTH -1 downto 0),
                                         tstrb((GC_DATA_WIDTH/8)-1 downto 0),
                                         tid(    GC_ID_WIDTH   -1 downto 0),
                                         tdest(  GC_DEST_WIDTH -1 downto 0)
                                         );
  signal axistream_if_s : t_axistream_if(tdata( GC_DATA_WIDTH -1 downto 0),
                                         tkeep((GC_DATA_WIDTH/8)-1 downto 0),
                                         tuser(  GC_USER_WIDTH -1 downto 0),
                                         tstrb((GC_DATA_WIDTH/8)-1 downto 0),
                                         tid(    GC_ID_WIDTH   -1 downto 0),
                                         tdest(  GC_DEST_WIDTH -1 downto 0)
                                         );

--------------------------------------------------------------------------------
-- Component declarations
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
begin
  -----------------------------
  -- Instantiate Testharness
  -----------------------------
  i_axistream_test_harness : entity bitvis_vip_axistream.test_harness(struct_simple)
    generic map(
      GC_DATA_WIDTH => GC_DATA_WIDTH,
      GC_USER_WIDTH => GC_USER_WIDTH,
      GC_ID_WIDTH   => GC_ID_WIDTH,
      GC_DEST_WIDTH => GC_DEST_WIDTH,
      GC_DUT_FIFO_DEPTH => GC_DUT_FIFO_DEPTH
      )
    port map(
      clk            => clk,
      areset         => areset,
      axistream_if_m_VVC2FIFO => axistream_if_m,
      axistream_if_s_FIFO2VVC => axistream_if_s
      );


  -- Set up clock generator
  p_clock : clock_generator(clk, clock_ena, C_CLK_PERIOD, "axistream CLK");

  ------------------------------------------------
  -- PROCESS: p_main
  -- Process for transmitting packets and stopping the test bench.
  ------------------------------------------------
  p_main : process
    -- BFM config
    variable axistream_bfm_config : t_axistream_bfm_config := C_AXIStream_BFM_CONFIG_DEFAULT;

    variable v_cnt                    : integer  := 0;
    variable v_numBytes               : integer  := 0;
    variable v_numWords               : integer  := 0;
    variable v_data_array         : t_byte_array(0 to c_max_bytes-1);
    variable v_user_array         : t_user_array(v_data_array'range) := (others => (others => '0'));
    variable v_strb_array         : t_strb_array(v_data_array'range) := (others => (others => '0'));
    variable v_id_array           : t_id_array(v_data_array'range) := (others => (others => '0'));
    variable v_dest_array         : t_dest_array(v_data_array'range) := (others => (others => '0'));

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");


    -- override default config with settings for this testbench
    axistream_bfm_config.max_wait_cycles          := 1000;
    axistream_bfm_config.max_wait_cycles_severity := error;
    axistream_bfm_config.check_packet_length      := true;
    if GC_USE_SETUP_AND_HOLD then
      axistream_bfm_config.clock_period           := C_CLK_PERIOD;
      axistream_bfm_config.setup_time             := C_CLK_PERIOD/4;
      axistream_bfm_config.hold_time              := C_CLK_PERIOD/4;
      axistream_bfm_config.bfm_sync               := SYNC_WITH_SETUP_AND_HOLD;
    end if;

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    enable_log_msg(ALL_MESSAGES);
    --disable_log_msg(ALL_MESSAGES);
    --enable_log_msg(ID_LOG_HDR);

    log(ID_LOG_HDR, "Start Simulation of TB for AXISTREAM 1", C_SCOPE);
    ------------------------------------------------------------
    clock_ena <= true;  -- the axistream_reset routine assumes the clock is running



    log("TC: axistream transmits: ");

    -- Directly assigning args
    v_data_array(0 to 2) := (x"a0" , x"a1" , x"a2");
    axistream_transmit_bytes(v_data_array(0 to 2), "Directly assign args", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    if GC_USER_WIDTH = 1 then
      -- When calling axistream_expect later, setting tuser for second word to dont care to support cases where number of words are only 1 (depends on GC_DATA_WIDTH)
      v_data_array(0 to 1) := (x"D0", x"D1");
      v_user_array(0 to 1) := (x"01", x"00");
      axistream_transmit_bytes( v_data_array(0 to 1), v_user_array(0 to 1), "Directly assign args including tuser", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    end if;

    for i in 1 to v_data_array'high loop
      v_numBytes := i;
      v_numWords := integer(ceil(real(v_numBytes)/(real(GC_DATA_WIDTH)/8.0)));
      -- Generate packet data
      v_cnt      := i;
      for byte in 0 to v_numBytes-1 loop
        v_data_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array(0)'length));
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_strb_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_strb_array(0)'length));
        v_id_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_id_array(0)'length));
        v_dest_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_dest_array(0)'length));
        v_cnt              := v_cnt + 1;
      end loop;

      -- BFM calls.
      if i = 0 then
        -- use a default tuser
        axistream_transmit_bytes(v_data_array(0 to v_numBytes-1), "transmit, default tuser, tstrb etc", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      else
        -- tstrb, tid, tdest are tested in axistream_vvc_simple_tb.
        axistream_transmit_bytes(v_data_array(0 to v_numBytes-1), v_user_array(0 to v_numWords-1), "transmit, setting tuser. Default tstrb etc", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      end if;

      -- Sometimes insert gap between packets
      if random(0, 1) = 1 then
        wait for 100 ns;
      end if;
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





  -- Process for receiving packets
  p_slave : process
    variable v_cnt          : integer := 0;
    variable v_numBytes     : integer := 0;
    variable v_numWords     : integer := 0;

    variable v_data_array   : t_byte_array(0 to c_max_bytes-1);
    variable v_user_array   : t_user_array(v_data_array'range) := (others => (others => '0'));
    variable v_strb_array   : t_strb_array(v_data_array'range) := (others => (others => '0'));
    variable v_id_array     : t_id_array(v_data_array'range) := (others => (others => '0'));
    variable v_dest_array   : t_dest_array(v_data_array'range) := (others => (others => '0'));

    -- BFM config
    variable axistream_bfm_config : t_axistream_bfm_config := C_AXIStream_BFM_CONFIG_DEFAULT;
  begin

    -- override default config with settings for this testbench
    axistream_bfm_config.max_wait_cycles          := 1000;
    axistream_bfm_config.max_wait_cycles_severity := error;
    axistream_bfm_config.check_packet_length      := true;
    if GC_USE_SETUP_AND_HOLD then
      axistream_bfm_config.clock_period           := C_CLK_PERIOD;
      axistream_bfm_config.setup_time             := C_CLK_PERIOD/4;
      axistream_bfm_config.hold_time              := C_CLK_PERIOD/4;
      axistream_bfm_config.bfm_sync               := SYNC_WITH_SETUP_AND_HOLD;
    end if;

    v_data_array(0 to 2) := (x"a0" , x"a1" , x"a2");
    axistream_expect_bytes(v_data_array(0 to 2),
                      "Directly assigned args, " &
                      ".", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);  --

    if GC_USER_WIDTH = 1 then
      -- setting tuser for second word to dont care to support cases where number of words are only 1 (depends on GC_DATA_WIDTH)
      v_data_array(0 to 1) := (x"D0" , x"D1");
      v_user_array(0 to 1) := (x"01", "--------");
      axistream_expect_bytes(v_data_array(0 to 1), v_user_array(0 to 1),
                        "Directly assigned args, including tuser " &
                        ".", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);  --
    end if;


    for i in 1 to v_data_array'high loop
      v_numBytes := i;
      v_numWords := integer(ceil(real(v_numBytes)/(real(GC_DATA_WIDTH)/8.0)));

      -- Generate expected packet. Must match the formula in p_main
      v_cnt := i;
      for byte in 0 to v_numBytes-1 loop
        v_data_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array(0)'length));
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_strb_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_strb_array(0)'length));
        v_id_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_id_array(0)'length));
        v_dest_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_dest_array(0)'length));
        v_cnt              := v_cnt + 1;
      end loop;

      -- Configure the sink BFM for this packet.
      axistream_bfm_config.ready_low_at_word_num := random(0, v_numWords-1);
      axistream_bfm_config.ready_low_duration  := random(0, 4);
      if random(0, 1) = 1 then
        axistream_bfm_config.ready_default_value := not axistream_bfm_config.ready_default_value;
      end if;

      -- BFM call
      if i = 0 then
        -- Test the overload without exp_user_array, exp_strb_array etc
        axistream_expect_bytes(v_data_array(0 to v_numBytes-1),
                          "ready_low_at_word_num = " & to_string(axistream_bfm_config.ready_low_at_word_num) &
                          "ready_low_duration = " & to_string(axistream_bfm_config.ready_low_duration) &
                          "ready_default_value = " & to_string(axistream_bfm_config.ready_default_value) &
                          "i="&to_string(i), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);  --
      else
        -- Test the overload without exp_strb_array, exp_id_array, exp_dest_array
        -- More tstrb, tid, tdest tests in axistream_vvc_simple_tb.
        axistream_expect_bytes(v_data_array(0 to v_numBytes-1), v_user_array(0 to v_numWords-1),
                          "ready_low_at_word_num = " & to_string(axistream_bfm_config.ready_low_at_word_num) &
                          "ready_low_duration = " & to_string(axistream_bfm_config.ready_low_duration) &
                          "ready_default_value = " & to_string(axistream_bfm_config.ready_default_value) &
                          "i="&to_string(i), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);  --
      end if;
    end loop;
    wait;
  end process p_slave;

end func;
