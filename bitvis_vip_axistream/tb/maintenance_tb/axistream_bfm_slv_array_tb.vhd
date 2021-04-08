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

library bitvis_vip_axistream;
use bitvis_vip_axistream.axistream_bfm_pkg.all;

--hdlunit:tb
-- Test case entity
entity axistream_bfm_slv_array_tb is
  generic (
    GC_TESTCASE           : string  := "UVVM";
    GC_DATA_WIDTH         : natural := 32;   -- number of bits in AXI-Stream IF tdata
    GC_USER_WIDTH         : natural := 1;    -- number of bits in AXI-Stream IF tuser
    GC_ID_WIDTH           : natural := 1;    -- number of bits in AXI-Stream IF tID
    GC_DEST_WIDTH         : natural := 1;    -- number of bits in AXI-Stream IF tDEST
    GC_USE_SETUP_AND_HOLD : boolean := false -- use setup and hold times to synchronise the BFM
  );
end entity;

-- Test case architecture
architecture func of axistream_bfm_slv_array_tb is

  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD 		    : time   	:= 10 ns;
  constant C_SCOPE      		    : string 	:= C_TB_SCOPE_DEFAULT;
  constant GC_DUT_FIFO_DEPTH 	  : natural := 4;
  constant C_BYTE 				      : natural := 8;
  constant C_MAX_BYTES          : natural := 100;  -- max bytes per packet to send
  constant C_MAX_BYTES_IN_WORD  : natural := 4;    -- max numb bytes in a word

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
    -- test variables
    variable v_cnt                : integer := 0;
    variable v_numBytes           : integer  := 0;
    variable v_numWords           : integer  := 0;
    variable v_data_array_as_slv  : std_logic_vector(C_MAX_BYTES_IN_WORD*C_BYTE-1 downto 0);
    variable v_data_array         : t_slv_array(0 to C_MAX_BYTES-1)(C_MAX_BYTES_IN_WORD*C_BYTE-1 downto 0);
    variable v_data_array_1_byte  : t_slv_array(0 to C_MAX_BYTES-1)(1*C_BYTE-1 downto 0);
    variable v_data_array_2_byte  : t_slv_array(0 to C_MAX_BYTES-1)(2*C_BYTE-1 downto 0);
    variable v_data_array_3_byte  : t_slv_array(0 to C_MAX_BYTES-1)(3*C_BYTE-1 downto 0);
    variable v_data_array_4_byte  : t_slv_array(0 to C_MAX_BYTES-1)(4*C_BYTE-1 downto 0);
    variable v_user_array         : t_user_array( 0 to C_MAX_BYTES-1) := (others => (others => '0'));

    ------------------------------------------------------
    -- returns a t_slv_array of given size
    ------------------------------------------------------
    function get_slv_array(num_bytes : integer; bytes_in_word : integer) return t_slv_array is
      variable v_return_array : t_slv_array(0 to num_bytes-1)((bytes_in_word*C_BYTE)-1 downto 0);
    begin
      for byte in 0 to num_bytes-1 loop
        v_return_array(byte) := std_logic_vector(to_unsigned(byte, bytes_in_word*C_BYTE));
      end loop;
      return v_return_array;
    end function;

    ------------------------------------------------------
    -- transmit data_array words of illegal and legal sizes
    ------------------------------------------------------
    procedure BFM_transmit_wrong_size(num_bytes : integer; num_bytes_in_word : integer; user_array : t_user_array) is
      variable v_short_byte_array     : t_slv_array(0 to num_bytes-1)((num_bytes_in_word*C_BYTE)-2 downto 0); -- size byte-1
      variable v_long_byte_array      : t_slv_array(0 to num_bytes-1)((num_bytes_in_word*C_BYTE) downto 0);   -- size byte+1
      variable v_normal_byte_array    : t_slv_array(0 to num_bytes-1)((num_bytes_in_word*C_BYTE)-1 downto 0); -- size byte
      variable v_tb_alert_stop_limit  : integer;
      variable v_cnt                  : integer := 0;
    begin
      v_cnt := 0;
      for byte in 0 to num_bytes-1 loop
        v_short_byte_array(byte)  := std_logic_vector(to_unsigned(v_cnt, v_short_byte_array(0)'length));
        v_cnt := v_cnt + 1;
        v_long_byte_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_long_byte_array(0)'length));
        v_cnt := v_cnt + 1;
        v_normal_byte_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_normal_byte_array(0)'length));
        v_cnt := v_cnt + 1;
      end loop;
      v_tb_alert_stop_limit := get_alert_stop_limit(TB_ERROR);
      set_alert_stop_limit(TB_ERROR, v_tb_alert_stop_limit + 4); -- master and slave

      -- transmit data_array with short byte
      increment_expected_alerts(TB_ERROR, 2); -- update expected error trom master and slave
      axistream_transmit(v_short_byte_array, user_array, "Directly assign args, error short byte transmit", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config); -- expect TB_ERROR
      -- transmit data_array with long byte
      increment_expected_alerts(TB_ERROR, 2); -- update expected error trom master and slave
      axistream_transmit(v_long_byte_array, user_array, "Directly assign args, error long byte transmit", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config); -- expect TB_ERROR
      -- transmit data_array of bytes
      axistream_transmit(v_normal_byte_array, user_array, "Directly assign args, no error transmit", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config); -- expect no TB_ERROR
    end procedure;


  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

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
    disable_log_msg(ID_UTIL_SETUP);
    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_BFM);
    disable_log_msg(ID_PACKET_DATA);

    log(ID_LOG_HDR, "Start Simulation of TB for AXISTREAM 1", C_SCOPE);
    ------------------------------------------------------------
    clock_ena <= true;  -- the axistream_reset routine assumes the clock is running


    ---------------------------------------------------------------
    --
    -- Directly assign arguments in BFM procedure using slv
    --
    ---------------------------------------------------------------
    log(ID_LOG_HDR, "TC: BFM axistream transmits short slv packet: ");
    v_data_array_as_slv(31 downto 0) := x"AABBCCDD"; -- 4 bytes
    -- transmit 0xAA
    axistream_transmit(v_data_array_as_slv(31 downto 24), "Directly assign args, transmitting " & to_string(v_data_array_as_slv(31 downto 24), HEX), clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    -- transmit 0xAABB
    axistream_transmit(v_data_array_as_slv(31 downto 16), "Directly assign args, transmitting " & to_string(v_data_array_as_slv(31 downto 16), HEX), clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    -- transmit 0xAABBCC
    axistream_transmit(v_data_array_as_slv(31 downto 8), "Directly assign args, transmitting " & to_string(v_data_array_as_slv(31 downto 8), HEX), clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    -- transmit 0xAABBCCDD
    axistream_transmit(v_data_array_as_slv(31 downto 0), "Directly assign args, transmitting " & to_string(v_data_array_as_slv(31 downto 0), HEX), clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);


    ---------------------------------------------------------------
    --
    -- Directly assign arguments in BFM procedure usint t_slv_array
    --
    ---------------------------------------------------------------
    log(ID_LOG_HDR, "TC: BFM axistream transmits short packet: ");

    -- TC: Directly assigning args
    v_cnt := 0;
    for byte in 0 to 3 loop
      v_data_array_1_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_1_byte(0)'length));
      v_data_array_2_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_2_byte(0)'length));
      v_data_array_3_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_3_byte(0)'length));
      v_data_array_4_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_4_byte(0)'length));
      v_cnt := v_cnt + 1;
    end loop;
    axistream_transmit(v_data_array_1_byte(0 to 3), "Directly assign args", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_transmit(v_data_array_2_byte(0 to 3), "Directly assign args", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_transmit(v_data_array_3_byte(0 to 3), "Directly assign args", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_transmit(v_data_array_4_byte(0 to 3), "Directly assign args", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);

    if GC_USER_WIDTH = 1 then
      -- When calling axistream_expect later, setting tuser for second word to dont care to support cases where number of words are only 1 (depends on GC_DATA_WIDTH)
      v_user_array(0 to 1) := (x"01", x"00");
      axistream_transmit( v_data_array_1_byte(0 to 1), v_user_array(0 to 1), "Directly assign args including tuser", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      v_user_array(0 to 1) := (x"02", x"10");
      axistream_transmit( v_data_array_2_byte(0 to 1), v_user_array(0 to 1), "Directly assign args including tuser", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      v_user_array(0 to 1) := (x"03", x"20");
      axistream_transmit( v_data_array_3_byte(0 to 1), v_user_array(0 to 1), "Directly assign args including tuser", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      v_user_array(0 to 1) := (x"04", x"30");
      axistream_transmit( v_data_array_4_byte(0 to 1), v_user_array(0 to 1), "Directly assign args including tuser", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    end if;

    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := 8;
      v_numWords := integer(ceil(real(v_numBytes*bytes_in_word)/(real(GC_DATA_WIDTH)/8.0)));
      -- Generate packet data
      v_cnt := bytes_in_word;
      for byte in 0 to v_numWords-1 loop
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_cnt := v_cnt + 1;
      end loop;

      -- BFM calls.
      if bytes_in_word = 1 then
        -- use a default tuser
        axistream_transmit(get_slv_array(v_numBytes, bytes_in_word), "transmit, default tuser, tstrb etc", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      else
        -- tstrb, tid, tdest are tested in axistream_vvc_simple_tb.
        axistream_transmit(get_slv_array(v_numBytes, bytes_in_word), v_user_array(0 to v_numWords-1), "transmit, setting tuser. Default tstrb etc", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      end if;

      -- Sometimes insert gap between packets
      if random(0, 1) = 1 then
        wait for 100 ns;
      end if;
    end loop;


    log(ID_LOG_HDR, "TC: BFM transmit verify alert if data_array don't consist of N*bytes: ");
    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := 8;
      v_numWords := integer(ceil(real(v_numBytes*bytes_in_word)/(real(GC_DATA_WIDTH)/8.0)));
      -- Generate packet data
      v_cnt := bytes_in_word;
      for byte in 0 to v_numWords-1 loop
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_cnt := v_cnt + 1;
      end loop;

      BFM_transmit_wrong_size(v_numBytes, bytes_in_word, v_user_array(0 to v_numWords-1));
    end loop;


    log(ID_LOG_HDR, "TC: Testing BFM receive and expect check the correct number of bytes in the last word: ");
    if GC_DATA_WIDTH > 8 then
      axistream_transmit(v_data_array_1_byte(0 to 3), "transmit 4 bytes", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      axistream_transmit(v_data_array_1_byte(0 to 3), "transmit 4 bytes", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    end if;


    log(ID_LOG_HDR, "TC: Testing BFM transmit, receive and expect with non-normalized slv_array: ");
    v_data_array_1_byte(1 to 4) := (x"00",x"01",x"02",x"03");
    axistream_transmit(v_data_array_1_byte(1 to 4), "transmit bytes 1 to 4", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_transmit(v_data_array_1_byte(1 to 4), "transmit bytes 1 to 4", clk, axistream_if_m, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);


    await_barrier(global_barrier, 1 us, "Synchronizing master");
    log(ID_LOG_HDR, "TC: Testing BFM receive() timeouts at max_wait_cycles: ");
    wait for (axistream_bfm_config.max_wait_cycles)*C_CLK_PERIOD;
    wait for (axistream_bfm_config.max_wait_cycles)*C_CLK_PERIOD;

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
    -- BFM config
    variable axistream_bfm_config 	: t_axistream_bfm_config := C_AXIStream_BFM_CONFIG_DEFAULT;
    -- test variables
    variable v_cnt                : integer := 0;
    variable v_data_array         : t_slv_array(0 to C_MAX_BYTES-1)(C_MAX_BYTES_IN_WORD*C_BYTE-1 downto 0);
    variable v_numBytes           : integer  := 0;
    variable v_numWords           : integer  := 0;
    variable v_data_array_1_byte  : t_slv_array(0 to C_MAX_BYTES-1)(1*C_BYTE-1 downto 0);
    variable v_data_array_2_byte  : t_slv_array(0 to C_MAX_BYTES-1)(2*C_BYTE-1 downto 0);
    variable v_data_array_3_byte  : t_slv_array(0 to C_MAX_BYTES-1)(3*C_BYTE-1 downto 0);
    variable v_data_array_4_byte  : t_slv_array(0 to C_MAX_BYTES-1)(4*C_BYTE-1 downto 0);

    variable v_user_array         : t_user_array( 0 to C_MAX_BYTES-1) := (others => (others => '0'));
    variable v_strb_array         : t_strb_array( 0 to C_MAX_BYTES-1) := (others => (others => '0'));
    variable v_id_array           : t_id_array( 0 to C_MAX_BYTES-1)   := (others => (others => '0'));
    variable v_dest_array         : t_dest_array( 0 to C_MAX_BYTES-1) := (others => (others => '0'));

    ------------------------------------------------------
    -- returns a t_slv_array of given size
    ------------------------------------------------------
    function get_slv_array(num_bytes : integer; bytes_in_word : integer) return t_slv_array is
      variable v_return_array : t_slv_array(0 to num_bytes-1)((bytes_in_word*C_BYTE)-1 downto 0);
    begin
      for byte in 0 to num_bytes-1 loop
        v_return_array(byte) := std_logic_vector(to_unsigned(byte, bytes_in_word*C_BYTE));
      end loop;
      return v_return_array;
    end function;

    ------------------------------------------------------
    -- expect data_array words of illegal and legal sizes
    ------------------------------------------------------
    procedure BFM_expect_wrong_size(num_bytes : integer; num_bytes_in_word : integer; user_array : t_user_array) is
      variable v_short_byte_array     : t_slv_array(0 to num_bytes-1)((num_bytes_in_word*C_BYTE)-2 downto 0); -- size byte-1
      variable v_long_byte_array      : t_slv_array(0 to num_bytes-1)((num_bytes_in_word*C_BYTE) downto 0);   -- size byte+1
      variable v_normal_byte_array    : t_slv_array(0 to num_bytes-1)((num_bytes_in_word*C_BYTE)-1 downto 0); -- size byte
      variable v_cnt                  : integer := 0;
    begin
      v_cnt := 0;
      for byte in 0 to num_bytes-1 loop
        v_short_byte_array(byte)  := std_logic_vector(to_unsigned(v_cnt, v_short_byte_array(0)'length));
        v_cnt := v_cnt + 1;
        v_long_byte_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_long_byte_array(0)'length));
        v_cnt := v_cnt + 1;
        v_normal_byte_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_normal_byte_array(0)'length));
        v_cnt := v_cnt + 1;
      end loop;
      -- tb_error report handling is carried out in p_main process

      -- transmit data_array with short byte, update error for transmit and expect
      axistream_expect(v_short_byte_array, user_array, "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      -- transmit data_array with long byte, update error for transmit and expect
      axistream_expect(v_long_byte_array, user_array, "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      -- transmit data_array of bytes
      axistream_expect(v_normal_byte_array, user_array, "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    end procedure;


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

    -- TC: Simple std_logic_vector test
    v_data_array_1_byte(0) := (x"AA");
    v_data_array_2_byte(0) := (x"AABB");
    v_data_array_3_byte(0) := (x"AABBCC");
    v_data_array_4_byte(0) := (x"AABBCCDD");
    -- expect 0xAA
    axistream_expect (v_data_array_1_byte(0), "Directly assigned args, expecting " & to_string(v_data_array_1_byte(0), HEX), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    -- expect 0xAABB
    axistream_expect (v_data_array_2_byte(0), "Directly assigned args, expecting " & to_string(v_data_array_2_byte(0), HEX), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    -- expect 0xAABBCC
    axistream_expect (v_data_array_3_byte(0), "Directly assigned args, expecting " & to_string(v_data_array_3_byte(0), HEX), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    -- expect 0xAABBCCDD
    axistream_expect (v_data_array_4_byte(0), "Directly assigned args, expecting " & to_string(v_data_array_4_byte(0), HEX), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);


    -- TC: Directly assigning args
    v_cnt := 0;
    for byte in 0 to 3 loop
      v_data_array_1_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_1_byte(0)'length));
      v_data_array_2_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_2_byte(0)'length));
      v_data_array_3_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_3_byte(0)'length));
      v_data_array_4_byte(byte) := std_logic_vector(to_unsigned(v_cnt, v_data_array_4_byte(0)'length));
      v_cnt := v_cnt + 1;
    end loop;
    axistream_expect(v_data_array_1_byte(0 to 3), "Directly assigned args.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_expect(v_data_array_2_byte(0 to 3), "Directly assigned args.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_expect(v_data_array_3_byte(0 to 3), "Directly assigned args.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_expect(v_data_array_4_byte(0 to 3), "Directly assigned args.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);

    if GC_USER_WIDTH = 1 then
      -- setting tuser for second word to dont care to support cases where number of words are only 1 (depends on GC_DATA_WIDTH)
      v_user_array(0 to 1) := (x"01", "--------");
      axistream_expect(v_data_array_1_byte(0 to 1), v_user_array(0 to 1), "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      v_user_array(0 to 1) := (x"02", "--------");
      axistream_expect(v_data_array_2_byte(0 to 1), v_user_array(0 to 1), "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      v_user_array(0 to 1) := (x"03", "--------");
      axistream_expect(v_data_array_3_byte(0 to 1), v_user_array(0 to 1), "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      v_user_array(0 to 1) := (x"04", "--------");
      axistream_expect(v_data_array_4_byte(0 to 1), v_user_array(0 to 1), "Directly assigned args, including tuser.", clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    end if;


    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := 8;
      v_numWords := integer(ceil(real(v_numBytes*bytes_in_word)/(real(GC_DATA_WIDTH)/8.0)));
      -- Generate packet data
      v_cnt := bytes_in_word;
      for byte in 0 to v_numWords-1 loop
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_cnt := v_cnt + 1;
      end loop;

      -- Configure the sink BFM for this packet.
      axistream_bfm_config.ready_low_at_word_num  := random(0, v_numWords-1);
      axistream_bfm_config.ready_low_duration     := random(0, 4);
      if random(0, 1) = 1 then
        axistream_bfm_config.ready_default_value := not axistream_bfm_config.ready_default_value;
      end if;

      -- BFM call
      if bytes_in_word = 1 then
        -- Test the overload without exp_user_array, exp_strb_array etc
        axistream_expect(get_slv_array(v_numBytes, bytes_in_word),
                          "ready_low_at_word_num=" & to_string(axistream_bfm_config.ready_low_at_word_num) &
                          ", ready_low_duration=" & to_string(axistream_bfm_config.ready_low_duration) &
                          ", ready_default_value=" & to_string(axistream_bfm_config.ready_default_value) &
                          ", bytes_in_word="&to_string(bytes_in_word), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);  --
      else
        -- Test the overload without exp_strb_array, exp_id_array, exp_dest_array
        -- More tstrb, tid, tdest tests in axistream_vvc_simple_tb.
        axistream_expect(get_slv_array(v_numBytes, bytes_in_word), v_user_array(0 to v_numWords-1),
                          "ready_low_at_word_num=" & to_string(axistream_bfm_config.ready_low_at_word_num) &
                          ", ready_low_duration=" & to_string(axistream_bfm_config.ready_low_duration) &
                          ", ready_default_value=" & to_string(axistream_bfm_config.ready_default_value) &
                          ", bytes_in_word="&to_string(bytes_in_word), clk, axistream_if_s, error, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);  --
      end if;
    end loop;


    -- test sanity checks
    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := 8;
      v_numWords := integer(ceil(real(v_numBytes*bytes_in_word)/(real(GC_DATA_WIDTH)/8.0)));
      -- Generate packet data
      v_cnt := bytes_in_word;
      for byte in 0 to v_numWords-1 loop
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_cnt := v_cnt + 1;
      end loop;

      BFM_expect_wrong_size(v_numBytes, bytes_in_word, v_user_array(0 to v_numWords-1));
    end loop;


    -- TC: Testing BFM receive and expect check the correct number of bytes in the last word
    if GC_DATA_WIDTH > 8 then
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      axistream_receive(v_data_array_1_byte(0 to 1), v_numBytes, v_user_array, v_strb_array, v_id_array, v_dest_array, "receiving 2 bytes", clk, axistream_if_s, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
      increment_expected_alerts_and_stop_limit(ERROR, 1);
      axistream_expect(v_data_array_1_byte(0 to 1), "expecting 2 bytes", clk, axistream_if_s, TB_ERROR, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    end if;


    -- TC: Testing BFM transmit, receive and expect with non-normalized slv_array
    v_data_array_1_byte(1 to 4) := (x"00",x"01",x"02",x"03");
    axistream_receive(v_data_array_1_byte(1 to 4), v_numBytes, v_user_array, v_strb_array, v_id_array, v_dest_array, "receiving bytes 1 to 4", clk, axistream_if_s, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_expect(v_data_array_1_byte(1 to 4), "expecting bytes 1 to 4", clk, axistream_if_s, TB_ERROR, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);


    await_barrier(global_barrier, 1 us, "Synchronizing slave");
    -- TC: Testing BFM receive() timeouts at max_wait_cycles
    axistream_bfm_config.ready_low_at_word_num := 0;
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    axistream_receive(v_data_array, v_numBytes, v_user_array, v_strb_array, v_id_array, v_dest_array, "invalid receive", clk, axistream_if_s, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);
    axistream_bfm_config.ready_low_at_word_num := 1;
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    axistream_receive(v_data_array, v_numBytes, v_user_array, v_strb_array, v_id_array, v_dest_array, "invalid receive", clk, axistream_if_s, C_SCOPE, shared_msg_id_panel, axistream_bfm_config);

    wait;
  end process p_slave;


end architecture;