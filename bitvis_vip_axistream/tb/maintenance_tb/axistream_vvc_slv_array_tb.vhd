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

--hdlregression:tb
-- Test case entity
entity axistream_vvc_slv_array_tb is
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
architecture func of axistream_vvc_slv_array_tb is

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

  constant C_MAX_BYTES         : natural   := 100; -- max bytes per packet to send
  constant C_MAX_BYTES_IN_WORD : natural   := 4;
  constant GC_DUT_FIFO_DEPTH   : natural   := 4;
  --------------------------------------------------------------------------------
  -- Signal declarations
  --------------------------------------------------------------------------------
  signal clk                   : std_logic := '0';
  signal areset                : std_logic := '0';
  signal clock_ena             : boolean   := false;

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
  i_axistream_test_harness : entity bitvis_vip_axistream.test_harness(struct_vvc)
    generic map(
      GC_DATA_WIDTH     => GC_DATA_WIDTH,
      GC_USER_WIDTH     => GC_USER_WIDTH,
      GC_ID_WIDTH       => GC_ID_WIDTH,
      GC_DEST_WIDTH     => GC_DEST_WIDTH,
      GC_DUT_FIFO_DEPTH => GC_DUT_FIFO_DEPTH,
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
    variable axistream_bfm_config : t_axistream_bfm_config := C_AXISTREAM_BFM_CONFIG_DEFAULT;

    constant C_BYTE       : natural                            := 8;
    variable v_cnt        : integer                            := 0;
    variable v_idx        : integer                            := 0;
    variable v_numBytes   : integer                            := 0;
    variable v_numWords   : integer                            := 0;
    variable v_user_array : t_user_array(0 to C_MAX_BYTES - 1) := (others => (others => '0'));
    variable v_strb_array : t_strb_array(0 to C_MAX_BYTES - 1) := (others => (others => '0'));
    variable v_id_array   : t_id_array(0 to C_MAX_BYTES - 1)   := (others => (others => '0'));
    variable v_dest_array : t_dest_array(0 to C_MAX_BYTES - 1) := (others => (others => '0'));

    variable v_data_array_1_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(1 * C_BYTE - 1 downto 0);
    variable v_data_array_2_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(2 * C_BYTE - 1 downto 0);
    variable v_data_array_3_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(3 * C_BYTE - 1 downto 0);
    variable v_data_array_4_byte  : t_slv_array(0 to C_MAX_BYTES - 1)(4 * C_BYTE - 1 downto 0);
    variable v_data_array         : t_slv_array(0 to C_MAX_BYTES - 1)(C_MAX_BYTES_IN_WORD * C_BYTE - 1 downto 0);
    variable v_data_array_as_byte : t_byte_array(0 to C_MAX_BYTES - 1);
    variable v_data_array_as_slv  : std_logic_vector(C_MAX_BYTES_IN_WORD * C_BYTE - 1 downto 0);

    variable v_cmd_idx           : natural;
    variable v_fetch_is_accepted : boolean;
    variable v_result_from_fetch : bitvis_vip_axistream.vvc_cmd_pkg.t_vvc_result;

    ------------------------------------------------------
    -- overloading procedure
    ------------------------------------------------------
    procedure check_value(received            : t_byte_array;
                          expected            : t_slv_array;
                          numb_bytes_received : natural;
                          msg                 : string) is
      constant c_byte_endianness   : t_byte_endianness := axistream_bfm_config.byte_endianness;
      constant c_bytes_in_word     : integer           := (expected(0)'length / 8);
      constant c_byte_array_length : integer           := (expected'length * c_bytes_in_word);
      variable v_expected          : t_byte_array(0 to c_byte_array_length - 1);
    begin
      v_expected := convert_slv_array_to_byte_array(expected, c_byte_endianness);
      for byte_idx in 0 to numb_bytes_received - 1 loop
        check_value(received(byte_idx) = v_expected(byte_idx), error, msg, C_TB_SCOPE_DEFAULT);
      end loop;
    end procedure check_value;

    ------------------------------------------------------
    -- return a t_slv_array of given size with random data
    ------------------------------------------------------
    impure function get_slv_array(num_bytes : integer; bytes_in_word : integer) return t_slv_array is
      variable v_return_array : t_slv_array(0 to num_bytes - 1)((bytes_in_word * 8) - 1 downto 0);
    begin
      for byte in 0 to num_bytes - 1 loop
        v_return_array(byte) := random(v_return_array(byte)'length);
      end loop;
      return v_return_array;
    end function;

    ------------------------------------------------------
    -- transmit tuser = something. tstrb etc = default
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_include_tuser(data_array : t_slv_array;
                                                    user_array : t_user_array) is
    begin
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, "transmit VVC2VVC, tuser set, but default tstrb etc");
      axistream_expect(AXISTREAM_VVCT, 3, data_array, user_array, "expect VVC2VVC, tuser set, but default tstrb etc");
    end procedure;

    ------------------------------------------------------
    -- transmit tuser tstrb etc is set (no defaults)
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_no_defaults(data_array : t_slv_array;
                                                  user_array : t_user_array;
                                                  strb_array : t_strb_array;
                                                  id_array   : t_id_array;
                                                  dest_array : t_dest_array) is
    begin
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, strb_array, id_array, dest_array, "transmit VVC2VVC, tuser tstrb etc are set");
      axistream_expect(AXISTREAM_VVCT, 3, data_array, user_array, strb_array, id_array, dest_array, "expect VVC2VVC, tuser tstrb etc are set");
    end procedure;

    ------------------------------------------------------
    -- transmit and receive with check
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_with_check(data_array : t_slv_array;
                                                 user_array : t_user_array) is
      variable v_num_bytes_sent      : integer := data_array'length * (data_array(0)'length / 8);
      variable v_numb_bytes_received : integer;
    begin
      -- transmit and receive
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, "transmit before receive, Check that tuser is fetched correctly");
      axistream_receive(AXISTREAM_VVCT, 3, "test axistream_receive / fetch_result (with tuser) ");

      v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 3);
      await_completion(AXISTREAM_VVCT, 2, 1 ms);
      await_completion(AXISTREAM_VVCT, 3, 1 ms);

      -- check result
      fetch_result(AXISTREAM_VVCT, 3, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
      v_numb_bytes_received := v_result_from_fetch.data_length;
      check_value(v_result_from_fetch.data_array, data_array, v_numb_bytes_received, "Verifying that fetched data is as expected");

      check_value(v_result_from_fetch.data_length, v_num_bytes_sent, error, "Verifying that fetched data_length is as expected", C_TB_SCOPE_DEFAULT);
      for i in 0 to v_numWords - 1 loop
        check_value(v_result_from_fetch.user_array(i)(GC_USER_WIDTH - 1 downto 0) = user_array(i)(GC_USER_WIDTH - 1 downto 0), error, "Verifying that fetched tuser_array(" & to_string(i) & ") is as expected", C_TB_SCOPE_DEFAULT);
      end loop;

    end procedure;

    ------------------------------------------------------
    -- transmit and check that expect detects errors
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_with_data_error(data_array : t_slv_array;
                                                      user_array : t_user_array) is
      variable v_idx        : integer;
      variable v_byte       : integer;
      variable v_data_array : t_slv_array(0 to data_array'length - 1)(data_array(0)'length - 1 downto 0) := data_array;
      variable v_byte_word  : std_logic_vector(7 downto 0);
    begin
      increment_expected_alerts(warning, 1);
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, "transmit, data wrong. bytes in word=" & to_string(data_array(0)'length / 8));
      v_idx                                                         := random(0, data_array'length - 1); -- pick index
      v_byte                                                        := random(1, data_array(0)'length / 8); -- pick byte
      v_data_array(v_idx)((v_byte * 8) - 1 downto (v_byte * 8) - 8) := not v_data_array(v_idx)((v_byte * 8) - 1 downto (v_byte * 8) - 8); -- invert byte
      axistream_expect(AXISTREAM_VVCT, 3, v_data_array, user_array, "expect, data wrong. bytes in word=" & to_string(data_array(0)'length / 8), warning);
    end procedure;

    ------------------------------------------------------
    -- verify alert if the tuser is not what is expected
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_tuser_error_check(data_array : t_slv_array;
                                                        user_array : t_user_array;
                                                        strb_array : t_strb_array;
                                                        id_array   : t_id_array;
                                                        dest_array : t_dest_array) is
      variable v_idx        : integer;
      variable v_user_array : t_user_array(0 to user_array'length - 1) := user_array;
    begin
      increment_expected_alerts(warning, 1);
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, v_user_array, strb_array, id_array, dest_array, "transmit, tuser wrong.");
      v_idx               := random(0, v_user_array'length - 1);
      v_user_array(v_idx) := not user_array(v_idx); -- Provoke alert in axistream_expect()
      axistream_expect(AXISTREAM_VVCT, 3, data_array, v_user_array, strb_array, id_array, dest_array, "expect, tuser wrong.", warning);
    end procedure;

    ------------------------------------------------------
    -- verify alert if the tstrb is not what is expected
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_tstrb_error_check(data_array : t_slv_array;
                                                        user_array : t_user_array;
                                                        strb_array : t_strb_array;
                                                        id_array   : t_id_array;
                                                        dest_array : t_dest_array) is
      variable v_idx        : integer;
      variable v_strb_array : t_strb_array(0 to user_array'length - 1) := strb_array;
    begin
      increment_expected_alerts(warning, 1);
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, v_strb_array, id_array, dest_array, "transmit, tstrb wrong.");
      v_idx               := random(0, v_strb_array'length - 1);
      v_strb_array(v_idx) := not v_strb_array(v_idx); -- Provoke alert in axistream_expect()
      axistream_expect(AXISTREAM_VVCT, 3, data_array, user_array, v_strb_array, id_array, dest_array, "expect, tstrb wrong.", warning);
    end procedure;

    ------------------------------------------------------
    -- verify alert if the tid is not what is expected
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_tid_error_check(data_array : t_slv_array;
                                                      user_array : t_user_array;
                                                      strb_array : t_strb_array;
                                                      id_array   : t_id_array;
                                                      dest_array : t_dest_array) is
      variable v_idx      : integer;
      variable v_id_array : t_id_array(0 to user_array'length - 1) := id_array;
    begin
      increment_expected_alerts(warning, 1);
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, strb_array, v_id_array, dest_array, "transmit, tid wrong.");
      v_idx             := random(0, v_id_array'length - 1);
      v_id_array(v_idx) := not v_id_array(v_idx); -- Provoke alert in axistream_expect()
      axistream_expect(AXISTREAM_VVCT, 3, data_array, user_array, strb_array, v_id_array, dest_array, "expect, tid wrong.", warning);
    end procedure;

    ------------------------------------------------------
    -- verify alert if the tdest is not what is expected
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_tdest_error_check(data_array : t_slv_array;
                                                        user_array : t_user_array;
                                                        strb_array : t_strb_array;
                                                        id_array   : t_id_array;
                                                        dest_array : t_dest_array) is
      variable v_idx        : integer;
      variable v_dest_array : t_dest_array(0 to user_array'length - 1) := dest_array;
      variable v_id_array   : t_id_array(0 to user_array'length - 1)   := id_array;
    begin
      increment_expected_alerts(warning, 1);
      axistream_transmit(AXISTREAM_VVCT, 2, data_array, user_array, strb_array, id_array, dest_array, "transmit, tdest wrong.");
      v_idx               := random(0, v_dest_array'length - 1);
      v_dest_array(v_idx) := not v_dest_array(v_idx); -- Provoke alert in axistream_expect()
      v_id_array          := (others => (others => '-')); -- also test the use of don't care
      axistream_expect(AXISTREAM_VVCT, 3, data_array, user_array, strb_array, v_id_array, v_dest_array, "expect, tdest wrong.", warning);
    end procedure;

    ------------------------------------------------------
    -- test receive/fetch result
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_receive_and_check(data_array : t_slv_array) is
      variable v_numBytes : integer := data_array'length * (data_array(0)'length / 8);
    begin
      axistream_transmit(AXISTREAM_VVCT, 0, data_array, "transmit");
      axistream_receive(AXISTREAM_VVCT, 1, "test axistream_receive / fetch_result (without tuser) ");
      v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 1);

      await_completion(AXISTREAM_VVCT, 1, 1 ms, "Wait for receive to finish");

      fetch_result(AXISTREAM_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
      check_value(v_result_from_fetch.data_array, data_array, v_numBytes, "Verifying that fetched data is as expected");
      check_value(v_result_from_fetch.data_length, v_numBytes, error, "Verifying that fetched data_length is as expected", C_TB_SCOPE_DEFAULT, ID_SEQUENCER);
    end procedure;

    ------------------------------------------------------
    -- test transmit
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_transmit_and_check(data_array : t_slv_array;
                                                         user_array : t_user_array;
                                                         strb_array : t_strb_array;
                                                         id_array   : t_id_array;
                                                         dest_array : t_dest_array;
                                                         i          : integer) is
      variable v_numBytes           : integer                                      := data_array'length * (data_array(0)'length / 8);
      variable v_data_array_as_byte : t_byte_array(0 to v_numBytes - 1);
      variable v_numWords           : integer                                      := user_array'length;
      variable v_user_array         : t_user_array(user_array'length - 1 downto 0) := user_array;
      variable v_byte_endianness    : t_byte_endianness                            := axistream_bfm_config.byte_endianness;
    begin
      -- VVC call
      -- tuser, tstrb etc = default
      axistream_transmit(AXISTREAM_VVCT, 0, data_array, "transmit,i=" & to_string(i));
      axistream_expect_bytes(AXISTREAM_VVCT, 1, convert_slv_array_to_byte_array(data_array, v_byte_endianness), "expect,  i=" & to_string(i));

      if GC_INCLUDE_TUSER then
        -- tuser = something. tstrb etc = default
        axistream_transmit(AXISTREAM_VVCT, 0, data_array, user_array, "transmit, tuser set,i=" & to_string(i));
        axistream_expect_bytes(AXISTREAM_VVCT, 1, convert_slv_array_to_byte_array(data_array, v_byte_endianness), user_array, "expect,   tuser set,i=" & to_string(i));

        -- test _receive, Check that tuser is fetched correctly
        axistream_transmit(AXISTREAM_VVCT, 0, data_array, user_array, "transmit before receive, Check that tuser is fetched correctly,i=" & to_string(i));
        axistream_receive(AXISTREAM_VVCT, 1, "test axistream_receive / fetch_result (with tuser) ");
        v_cmd_idx := get_last_received_cmd_idx(AXISTREAM_VVCT, 1);
        await_completion(AXISTREAM_VVCT, 0, 1 ms);
        await_completion(AXISTREAM_VVCT, 1, 1 ms);

        fetch_result(AXISTREAM_VVCT, 1, NA, v_cmd_idx, v_result_from_fetch, "Fetch result using the simple fetch_result overload");
        check_value(v_result_from_fetch.data_array, data_array, v_numBytes, "Verifying that fetched data is as expected");
        check_value(v_result_from_fetch.data_length, v_numBytes, error, "Verifying that fetched data_length is as expected", C_TB_SCOPE_DEFAULT);

        for i in 0 to v_numWords - 1 loop
          check_value(v_result_from_fetch.user_array(i)(GC_USER_WIDTH - 1 downto 0) = user_array(i)(GC_USER_WIDTH - 1 downto 0), error, "Verifying that fetched tuser_array(" & to_string(i) & ") is as expected", C_TB_SCOPE_DEFAULT);
        end loop;

        -- verify alert if the data is not what is expected
        increment_expected_alerts(warning, 1);
        axistream_transmit(AXISTREAM_VVCT, 0, data_array, v_user_array, "transmit, data wrong ,i=" & to_string(i));
        v_idx                       := random(0, v_numBytes - 1);
        v_data_array_as_byte        := convert_slv_array_to_byte_array(data_array, v_byte_endianness);
        v_data_array_as_byte(v_idx) := not v_data_array_as_byte(v_idx);
        axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array_as_byte, v_user_array, "expect, data wrong ,i=" & to_string(i), warning);

        -- verify alert if the tuser is not what is expected
        increment_expected_alerts(warning, 1);
        axistream_transmit(AXISTREAM_VVCT, 0, data_array, v_user_array, "transmit, tuser wrong ,i=" & to_string(i));
        v_idx               := random(0, v_numWords - 1);
        v_user_array(v_idx) := not v_user_array(v_idx);
        axistream_expect_bytes(AXISTREAM_VVCT, 1, convert_slv_array_to_byte_array(data_array, v_byte_endianness), v_user_array, "expect, tuser wrong ,i=" & to_string(i), warning);
      end if;
    end procedure;

    ------------------------------------------------------
    -- verify alert if the 'tlast' is not where expected
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_tlast_error_check(data_array : t_slv_array;
                                                        user_array : t_user_array;
                                                        strb_array : t_strb_array;
                                                        id_array   : t_id_array;
                                                        dest_array : t_dest_array;
                                                        numBytes   : integer;
                                                        i          : integer) is
      variable v_numBytes : integer := numBytes;
    begin
      await_completion(AXISTREAM_VVCT, 1, 1 ms);
      axistream_transmit(AXISTREAM_VVCT, 0, data_array, user_array, "transmit, tlast wrong,i=" & to_string(i));
      increment_expected_alerts(warning, 1);
      shared_axistream_vvc_config(1).bfm_config.protocol_error_severity := warning;

      v_numBytes := v_numBytes - 1;
      axistream_expect(AXISTREAM_VVCT, 1, data_array(0 to v_numBytes - 1), user_array, "expect, tlast wrong ,i=" & to_string(i), NO_ALERT);
      -- due to the premature tlast, make an extra call to read the remaining (corrupt) packet
      axistream_expect(AXISTREAM_VVCT, 1, data_array(0 to v_numBytes - 1), user_array, "expect, remaining data ,i=" & to_string(i), NO_ALERT);
      await_completion(AXISTREAM_VVCT, 1, 1 ms);

      -- Cleanup after test case
      shared_axistream_vvc_config(1).bfm_config.protocol_error_severity := error;
    end procedure;

    ------------------------------------------------------
    -- verify alert if data_array don't consist of N*bytes
    ------------------------------------------------------
    procedure VVC_master_to_VVC_slave_wrong_size(num_bytes : integer; num_bytes_in_word : integer; user_array : t_user_array) is
      variable v_short_byte_array    : t_slv_array(0 to num_bytes - 1)((num_bytes_in_word * C_BYTE) - 2 downto 0); -- size byte-1
      variable v_long_byte_array     : t_slv_array(0 to num_bytes - 1)((num_bytes_in_word * C_BYTE) downto 0); -- size byte+1
      variable v_normal_byte_array   : t_slv_array(0 to num_bytes - 1)((num_bytes_in_word * C_BYTE) - 1 downto 0); -- size byte
      variable v_tb_alert_stop_limit : integer;
    begin
      for byte in 0 to num_bytes - 1 loop
        v_short_byte_array(byte)  := random(v_short_byte_array(0)'length);
        v_long_byte_array(byte)   := random(v_long_byte_array(0)'length);
        v_normal_byte_array(byte) := random(v_normal_byte_array(0)'length);
      end loop;
      v_tb_alert_stop_limit := get_alert_stop_limit(TB_ERROR);
      set_alert_stop_limit(TB_ERROR, v_tb_alert_stop_limit + 2);
      -- transmit data_array with short byte
      increment_expected_alerts(TB_ERROR, 1);
      axistream_transmit(AXISTREAM_VVCT, 0, v_short_byte_array, user_array, "transmit, short byte"); -- expect TB_ERROR
      -- transmit data_array with long byte
      increment_expected_alerts(TB_ERROR, 1);
      axistream_transmit(AXISTREAM_VVCT, 0, v_long_byte_array, user_array, "transmit, long byte"); -- expect TB_ERROR
      -- transmit data_array of bytes
      axistream_transmit(AXISTREAM_VVCT, 0, v_normal_byte_array, user_array, "transmit, normal byte"); -- expect no TB_ERROR
    end procedure;

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
    shared_axistream_vvc_config(C_FIFO2VVC_MASTER).bfm_config := axistream_bfm_config; -- vvc_methods_pkg
    shared_axistream_vvc_config(C_FIFO2VVC_SLAVE).bfm_config  := axistream_bfm_config; -- vvc_methods_pkg
    shared_axistream_vvc_config(C_VVC2VVC_MASTER).bfm_config  := axistream_bfm_config; -- vvc_methods_pkg
    shared_axistream_vvc_config(C_VVC2VVC_SLAVE).bfm_config   := axistream_bfm_config; -- vvc_methods_pkg

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    -- Configure logging
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_BFM);

    disable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ALL_MESSAGES);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ID_BFM);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ID_PACKET_INITIATE);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ID_PACKET_COMPLETE);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_MASTER, ID_IMMEDIATE_CMD);

    disable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ALL_MESSAGES);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ID_BFM);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ID_PACKET_INITIATE);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ID_PACKET_COMPLETE);
    --enable_log_msg(AXISTREAM_VVCT, C_FIFO2VVC_SLAVE, ID_IMMEDIATE_CMD);

    disable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_MASTER, ID_PACKET_DATA);
    disable_log_msg(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, ID_PACKET_DATA);

    log(ID_LOG_HDR, "Start Simulation of AXI-Stream");
    ------------------------------------------------------------
    clock_ena <= true;                  -- the axistream_reset routine assumes the clock is running
    gen_pulse(areset, 10 * C_CLK_PERIOD, "Pulsing reset for 10 clock periods");

    -- Short packet test - transmit, receive and check test
    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream VVC Master (VVC_IDX=2) transmits short packet directly to VVC Slave (VVC_IDX=3)");
    ------------------------------------------------------------
    v_data_array_1_byte(0) := (x"AA");
    v_data_array_2_byte(0) := (x"AABB");
    v_data_array_3_byte(0) := (x"AABBCC");
    v_data_array_4_byte(0) := (x"AABBCCDD");
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_1_byte(0 to 0), "1 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_1_byte(0 to 0), "1 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_2_byte(0 to 0), "2 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_2_byte(0 to 0), "2 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_3_byte(0 to 0), "3 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_3_byte(0 to 0), "3 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_4_byte(0 to 0), "4 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_4_byte(0 to 0), "4 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));

    -- Short packet test wih SLV
    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream VVC Master (VVC_IDX=2) transmits short SLV packet directly to VVC Slave (VVC_IDX=3)");
    ------------------------------------------------------------
    v_data_array_as_slv(31 downto 0) := x"AABBCCDD"; -- 4 bytes
    -- transmit and receive 0xAA
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_as_slv(31 downto 24), "1 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_1_byte(0), "1 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));
    -- transmit and receive 0xAABB
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_as_slv(31 downto 16), "1 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_2_byte(0), "1 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));
    -- transmit and receive 0xAABBCC
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_as_slv(31 downto 8), "1 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_3_byte(0), "1 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));
    -- transmit and receive 0xAABBCCDD
    axistream_transmit(AXISTREAM_VVCT, C_VVC2VVC_MASTER, v_data_array_as_slv(31 downto 0), "1 byte transmit VVC2VVC. Default tuser etc, i=" & to_string(0));
    axistream_expect(AXISTREAM_VVCT, C_VVC2VVC_SLAVE, v_data_array_4_byte(0), "1 byte expect  VVC2VVC. Default tuser etc, i=" & to_string(0));

    -- Long packet test - transmit, receive and check test
    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream VVC Master (VVC_IDX=2) transmits long packet directly to VVC Slave (VVC_IDX=3)");
    ------------------------------------------------------------
    for i in 1 to 5 loop
      v_numBytes := random(1, C_MAX_BYTES);
      v_numWords := integer(ceil(real(v_numBytes) / (real(GC_DATA_WIDTH) / 8.0)));

      for byte in 0 to v_numBytes - 1 loop
        v_data_array_1_byte(byte) := random(v_data_array_1_byte(0)'length);
        v_data_array_2_byte(byte) := random(v_data_array_2_byte(0)'length);
        v_data_array_3_byte(byte) := random(v_data_array_3_byte(0)'length);
        v_data_array_4_byte(byte) := random(v_data_array_4_byte(0)'length);
      end loop;
      -- Make sure ready signal is toggled in various ways
      shared_axistream_vvc_config(3).bfm_config.ready_low_at_word_num := random(0, v_numWords - 1);
      shared_axistream_vvc_config(3).bfm_config.ready_low_duration    := random(0, 5);
      shared_axistream_vvc_config(3).bfm_config.ready_default_value   := random(VOId);
      -- transmit 1 byte byte array data and check data
      axistream_transmit(AXISTREAM_VVCT, 2, v_data_array_1_byte(0 to v_numBytes - 1), "transmit VVC2VVC. Default tuser etc, i=" & to_string(i));
      axistream_expect(AXISTREAM_VVCT, 3, v_data_array_1_byte(0 to v_numBytes - 1), "expect  VVC2VVC. Default tuser etc, i=" & to_string(i));
      -- transmit 2 byte byte array data and check data
      axistream_transmit(AXISTREAM_VVCT, 2, v_data_array_2_byte(0 to v_numBytes - 1), "transmit VVC2VVC. Default tuser etc, i=" & to_string(i));
      axistream_expect(AXISTREAM_VVCT, 3, v_data_array_2_byte(0 to v_numBytes - 1), "expect  VVC2VVC. Default tuser etc, i=" & to_string(i));
      -- transmit 3 byte byte array data and check data
      axistream_transmit(AXISTREAM_VVCT, 2, v_data_array_3_byte(0 to v_numBytes - 1), "transmit VVC2VVC. Default tuser etc, i=" & to_string(i));
      axistream_expect(AXISTREAM_VVCT, 3, v_data_array_3_byte(0 to v_numBytes - 1), "expect  VVC2VVC. Default tuser etc, i=" & to_string(i));
      -- transmit 4 byte byte array data and check data
      axistream_transmit(AXISTREAM_VVCT, 2, v_data_array_4_byte(0 to v_numBytes - 1), "transmit VVC2VVC. Default tuser etc, i=" & to_string(i));
      axistream_expect(AXISTREAM_VVCT, 3, v_data_array_4_byte(0 to v_numBytes - 1), "expect  VVC2VVC. Default tuser etc, i=" & to_string(i));
    end loop;

    -- Test transmit, receive and check with various parameters
    ------------------------------------------------------------
    log(ID_LOG_HDR, "include tuser test. VVC Master (VVC_IDX=2) transmits directly to VVC Slave (VVC_IDX=3)");
    ------------------------------------------------------------
    -- run test with word size from 1 to 4 bytes
    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := random(1, C_MAX_BYTES / bytes_in_word);
      v_numWords := integer(ceil(real(v_numBytes * bytes_in_word) / (real(GC_DATA_WIDTH) / 8.0)));

      for byte in 0 to v_numWords - 1 loop
        v_user_array(byte) := random(v_user_array(0)'length);
        v_strb_array(byte) := random(v_strb_array(0)'length);
        v_id_array(byte)   := random(v_id_array(0)'length);
        v_dest_array(byte) := random(v_dest_array(0)'length);
      end loop;

      -- test: transmit and expect with tuser = something. tstrb etc = default
      VVC_master_to_VVC_slave_include_tuser(get_slv_array(v_numBytes, bytes_in_word),
                                            v_user_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: transmit and expect with tuser, tstrb etc is set (no defaults)
      VVC_master_to_VVC_slave_no_defaults(get_slv_array(v_numBytes, bytes_in_word),
                                          v_user_array(0 to v_numWords - 1),
                                          v_strb_array(0 to v_numWords - 1),
                                          v_id_array(0 to v_numWords - 1),
                                          v_dest_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: _receive, Check that tuser is fetched correctly
      VVC_master_to_VVC_slave_with_check(get_slv_array(v_numBytes, bytes_in_word),
                                         v_user_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: transmit and check that expect detects errors
      VVC_master_to_VVC_slave_with_data_error(get_slv_array(v_numBytes, bytes_in_word),
                                              v_user_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: verify alert if the tuser is not what is expected
      VVC_master_to_VVC_slave_tuser_error_check(get_slv_array(v_numBytes, bytes_in_word),
                                                v_user_array(0 to v_numWords - 1),
                                                v_strb_array(0 to v_numWords - 1),
                                                v_id_array(0 to v_numWords - 1),
                                                v_dest_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: verify alert if the tstrb is not what is expected
      VVC_master_to_VVC_slave_tstrb_error_check(get_slv_array(v_numBytes, bytes_in_word),
                                                v_user_array(0 to v_numWords - 1),
                                                v_strb_array(0 to v_numWords - 1),
                                                v_id_array(0 to v_numWords - 1),
                                                v_dest_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: verify alert if the tid is not what is expected
      VVC_master_to_VVC_slave_tid_error_check(get_slv_array(v_numBytes, bytes_in_word),
                                              v_user_array(0 to v_numWords - 1),
                                              v_strb_array(0 to v_numWords - 1),
                                              v_id_array(0 to v_numWords - 1),
                                              v_dest_array(0 to v_numWords - 1));
      -----------------------------------------------------------
      -- test: verify alert if the tdest is not what is expected
      VVC_master_to_VVC_slave_tdest_error_check(get_slv_array(v_numBytes, bytes_in_word),
                                                v_user_array(0 to v_numWords - 1),
                                                v_strb_array(0 to v_numWords - 1),
                                                v_id_array(0 to v_numWords - 1),
                                                v_dest_array(0 to v_numWords - 1));

      await_completion(AXISTREAM_VVCT, 3, 1 ms, "Wait for receive to finish");
    end loop;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream_receive and fetch_result ");
    ------------------------------------------------------------
    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := random(1, C_MAX_BYTES / bytes_in_word);
      v_numWords := integer(ceil(real(v_numBytes * bytes_in_word) / (real(GC_DATA_WIDTH) / 8.0)));

      VVC_master_to_VVC_slave_receive_and_check(get_slv_array(v_numBytes, bytes_in_word));
    end loop;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream transmit when tready=0 from DUT at start of transfer  ");
    ------------------------------------------------------------
    -- Fill DUT FIFO to provoke tready=0
    v_numBytes := 1;
    for i in 0 to GC_DUT_FIFO_DEPTH - 1 loop
      v_data_array_1_byte(0) := std_logic_vector(to_unsigned(i, v_data_array_1_byte(0)'length));
      axistream_transmit(AXISTREAM_VVCT, 0, v_data_array_1_byte(0 to v_numBytes - 1), "transmit to fill DUT,i=" & to_string(i));
    end loop;
    await_completion(AXISTREAM_VVCT, 0, 1 ms);
    wait for 100 ns;

    -- DUT FIFO is now full. Schedule the transmit which will wait for tready until DUT is read from later
    v_data_array_1_byte(0) := x"D0";
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array_1_byte(0 to v_numBytes - 1), "start transmit while tready=0");

    -- Make DUT not full anymore. Check data from DUT equals transmitted data
    for i in 0 to GC_DUT_FIFO_DEPTH - 1 loop
      v_data_array_as_byte(0) := std_logic_vector(to_unsigned(i, v_data_array_as_byte(0)'length));
      axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array_as_byte(0 to v_numBytes - 1), "expect ");
    end loop;

    v_data_array_as_byte(0) := x"D0";
    axistream_expect_bytes(AXISTREAM_VVCT, 1, v_data_array_as_byte(0 to v_numBytes - 1), "expect ");
    wait for 100 ns;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: axistream transmits: ");
    ------------------------------------------------------------
    shared_axistream_vvc_config(0).inter_bfm_delay.delay_type := TIME_FINISH2START;
    for i in 0 to 2 loop

      for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
        -- Various delay between each transmit
        shared_axistream_vvc_config(0).inter_bfm_delay.delay_in_time := i * C_CLK_PERIOD;

        for i in 1 to 20 loop
          v_numBytes := random(1, C_MAX_BYTES / bytes_in_word);
          v_numWords := integer(ceil(real(v_numBytes * bytes_in_word) / (real(GC_DATA_WIDTH) / 8.0)));
          -- Generate packet data
          v_cnt      := i;
          for byte in 0 to v_numWords - 1 loop
            v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
            v_strb_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_strb_array(0)'length));
            v_id_array(byte)   := std_logic_vector(to_unsigned(v_cnt, v_id_array(0)'length));
            v_dest_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_dest_array(0)'length));
            v_cnt              := v_cnt + 1;
          end loop;

          VVC_master_to_VVC_slave_transmit_and_check(get_slv_array(v_numBytes, bytes_in_word),
                                                     v_user_array(0 to v_numWords - 1),
                                                     v_strb_array(0 to v_numWords - 1),
                                                     v_id_array(0 to v_numWords - 1),
                                                     v_dest_array(0 to v_numWords - 1),
                                                     i);
        end loop;

        -- Await completion on both VVCs
        await_completion(AXISTREAM_VVCT, 0, 1 ms);
        await_completion(AXISTREAM_VVCT, 1, 1 ms);
        report_alert_counters(INTERMEDIATE); -- Report final counters and print conclusion for simulation (Success/Fail)

        -- verify alert if the 'tlast' is not where expected
        for i in 1 to 1 loop
          if GC_INCLUDE_TUSER then
            v_numBytes := (GC_DATA_WIDTH / (8 * bytes_in_word)) + 1; -- So that v_numBytes - 1 makes the tlast in previous clock cycle
            v_numWords := integer(ceil(real(v_numBytes * bytes_in_word) / (real(GC_DATA_WIDTH) / 8.0)));
            VVC_master_to_VVC_slave_tlast_error_check(get_slv_array(v_numBytes, bytes_in_word),
                                                      v_user_array(0 to v_numWords - 1),
                                                      v_strb_array(0 to v_numWords - 1),
                                                      v_id_array(0 to v_numWords - 1),
                                                      v_dest_array(0 to v_numWords - 1),
                                                      v_numBytes, i);
          end if;
        end loop;
      end loop;
    end loop;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: Testing VVC transmit and expect with non-normalized slv_array");
    ------------------------------------------------------------
    v_data_array_1_byte(1 to 4) := (x"00", x"01", x"02", x"03");
    axistream_transmit(AXISTREAM_VVCT, 0, v_data_array_1_byte(1 to 4), "transmit bytes 1 to 4");
    axistream_expect(AXISTREAM_VVCT, 1, v_data_array_1_byte(1 to 4), "expecting bytes 1 to 4");
    await_completion(AXISTREAM_VVCT, 1, 1 ms);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "TC: sanity check ");
    ------------------------------------------------------------
    for bytes_in_word in 1 to C_MAX_BYTES_IN_WORD loop
      v_numBytes := random(1, C_MAX_BYTES / bytes_in_word);
      v_numWords := integer(ceil(real(v_numBytes * bytes_in_word) / (real(GC_DATA_WIDTH) / 8.0)));

      for byte in 0 to v_numWords - 1 loop
        v_user_array(byte) := std_logic_vector(to_unsigned(v_cnt, v_user_array(0)'length));
        v_cnt              := v_cnt + 1;
      end loop;

      VVC_master_to_VVC_slave_wrong_size(v_numBytes, bytes_in_word, v_user_array);
    end loop;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;
end func;
