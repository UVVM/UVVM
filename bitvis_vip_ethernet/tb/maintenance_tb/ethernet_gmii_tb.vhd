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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.vvc_context;

--hdlregression:tb
-- Test case entity
entity ethernet_gmii_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity ethernet_gmii_tb;

-- Test case architecture
architecture func of ethernet_gmii_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 8 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  alias clk is << signal .ethernet_gmii_tb.i_test_harness.clk : std_logic >>;
  alias i1_gmii_tx_if is << signal .ethernet_gmii_tb.i_test_harness.i1_gmii_tx_if : t_gmii_tx_if >>;
begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.ethernet_th(struct_gmii)
    generic map(
      GC_CLK_PERIOD => C_CLK_PERIOD
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_payload_len    : integer := 0;
    variable v_payload_data   : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH - 1);
    variable v_cmd_idx        : natural;
    variable v_receive_data   : bitvis_vip_ethernet.vvc_cmd_pkg.t_vvc_result;
    variable v_expected_frame : t_ethernet_frame;
    variable v_time_stamp     : time;

    impure function make_ethernet_frame(
      constant mac_destination : in unsigned(47 downto 0);
      constant mac_source      : in unsigned(47 downto 0);
      constant payload         : in t_byte_array
    ) return t_ethernet_frame is
      variable v_frame          : t_ethernet_frame                           := C_ETHERNET_FRAME_DEFAULT;
      variable v_packet         : t_byte_array(0 to C_MAX_PACKET_LENGTH - 1) := (others => (others => '0'));
      variable v_payload_length : positive                                   := payload'length;
    begin
      -- MAC destination
      v_frame.mac_destination                    := mac_destination;
      v_packet(0 to 5)                           := convert_slv_to_byte_array(std_logic_vector(v_frame.mac_destination), LOWER_BYTE_LEFT);
      -- MAC source
      v_frame.mac_source                         := mac_source;
      v_packet(6 to 11)                          := convert_slv_to_byte_array(std_logic_vector(v_frame.mac_source), LOWER_BYTE_LEFT);
      -- Payload length
      v_frame.payload_length                     := v_payload_length;
      v_packet(12 to 13)                         := convert_slv_to_byte_array(std_logic_vector(to_unsigned(v_frame.payload_length, 16)), LOWER_BYTE_LEFT);
      -- Payload
      v_frame.payload(0 to v_payload_length - 1) := payload;
      v_packet(14 to 14 + v_payload_length - 1)  := payload;
      -- Add padding if needed
      if v_payload_length < C_MIN_PAYLOAD_LENGTH then
        v_payload_length := C_MIN_PAYLOAD_LENGTH;
      end if;
      -- FCS
      v_frame.fcs                                := not generate_crc_32(v_packet(0 to 14 + v_payload_length - 1));

      return v_frame;
    end function make_ethernet_frame;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Verbosity control
    disable_log_msg(ID_UVVM_CMD_ACK);

    -- Set Ethernet VVC config for this testbench
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination := x"00_00_00_00_00_02";
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source      := x"00_00_00_00_00_01";
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_destination := x"00_00_00_00_00_02";
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_source      := x"00_00_00_00_00_01";
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination := x"00_00_00_00_00_01";
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source      := x"00_00_00_00_00_02";
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_destination := x"00_00_00_00_00_01";
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_source      := x"00_00_00_00_00_02";

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "START SIMULATION OF ETHERNET VVC");
    ---------------------------------------------------------------------------
    for length in 1 to 10 loop
      v_payload_len := length;
      for i in 0 to v_payload_len - 1 loop
        v_payload_data(i) := random(8);
      end loop;
      log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from i1 to i2 (need padding)");
      ethernet_transmit(ETHERNET_VVCT, 1, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 1.");
      ethernet_expect(ETHERNET_VVCT, 2, RX, v_payload_data(0 to v_payload_len - 1), "Expect a frame at instance 2.");
      await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
      await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");
    end loop;

    v_payload_len := C_MIN_PAYLOAD_LENGTH;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from i1 to i2 (minimum size)");
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, v_payload_data(0 to v_payload_len - 1), "Expect a frame at instance 2.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    v_payload_len := C_MAX_PAYLOAD_LENGTH;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from i1 to i2 (maximum size)");
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, v_payload_data(0 to v_payload_len - 1), "Expect a frame at instance 2.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    v_payload_len := 50;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from i2 to i1");
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 2.");
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Receive a frame at instance 1.");
    v_cmd_idx     := get_last_received_cmd_idx(ETHERNET_VVCT, 1, RX);
    await_completion(ETHERNET_VVCT, 2, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for receive to finish.");
    log(ID_LOG_HDR, "Fetch data from i1 and check");
    fetch_result(ETHERNET_VVCT, 1, RX, v_cmd_idx, v_receive_data, "Fetching received data.");
    check_value(v_receive_data.ethernet_frame.mac_destination = x"00_00_00_00_00_01", ERROR, "Verify MAC destination.");
    check_value(v_receive_data.ethernet_frame.mac_source = x"00_00_00_00_00_02", ERROR, "Verify MAC source.");
    check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
    for i in 0 to v_payload_len - 1 loop
      check_value(v_receive_data.ethernet_frame.payload(i), v_payload_data(i), ERROR, "Verify payload, byte " & to_string(i) & ".");
    end loop;

    for payload in 44 to 48 loop
      v_payload_len    := payload;
      for i in 0 to v_payload_len - 1 loop
        v_payload_data(i) := random(8);
      end loop;
      log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from i2 to i1 (use scoreboard)");
      ethernet_transmit(ETHERNET_VVCT, 2, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 2.");
      v_expected_frame := make_ethernet_frame(x"00_00_00_00_00_01", x"00_00_00_00_00_02", v_payload_data(0 to v_payload_len - 1));
      ETHERNET_VVC_SB.add_expected(1, v_expected_frame);
      ethernet_receive(ETHERNET_VVCT, 1, RX, TO_SB, "Receive a frame at instance 1 and put it in the Scoreboard.");
      await_completion(ETHERNET_VVCT, 2, TX, 1 ms, "Wait for transmit to finish.");
      await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for receive to finish.");
    end loop;

    log(ID_LOG_HDR, "Verify insert_delay");
    shared_gmii_vvc_config(RX, 2).bfm_config.max_wait_cycles := 1000; -- avoid timeout from inserted delay
    await_change(clk, 0 ns, 6 ns, ERROR, "Sync to clock.");
    await_value(clk, '1', 0 ns, 6 ns, ERROR, "Sync to clock.");
    insert_delay(ETHERNET_VVCT, 1, TX, 1 us, "Insert delay in instance 1.");
    v_time_stamp                                             := now;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_payload_data(0 to 46), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, v_payload_data(0 to 46), "Expect a frame at instance 2.");
    await_value(i1_gmii_tx_if.txen, '1', 0 ns, 1.1 us, ERROR, "Await ethernet transfer.");
    check_value_in_range(now - v_time_stamp, 1 us, 1.01 us, ERROR, "Verify inserted delay.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    v_payload_len := C_MIN_PAYLOAD_LENGTH;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit a frame with the wrong MAC destination address");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    ethernet_transmit(ETHERNET_VVCT, 1, TX, x"00_00_00_00_00_02", x"00_00_00_00_00_01", v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, x"00_00_00_00_00_F2", x"00_00_00_00_00_01", v_payload_data(0 to v_payload_len - 1), "Expect a frame at instance 2.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    log(ID_LOG_HDR, "Transmit a frame with the wrong MAC source address");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    ethernet_transmit(ETHERNET_VVCT, 1, TX, x"00_00_00_00_00_02", x"00_00_00_00_00_01", v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, x"00_00_00_00_00_02", x"00_00_00_00_00_F1", v_payload_data(0 to v_payload_len - 1), "Expect a frame at instance 2.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    log(ID_LOG_HDR, "Transmit a frame with the wrong payload length");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, v_payload_data(0 to v_payload_len), "Expect a frame at instance 2.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    log(ID_LOG_HDR, "Transmit a frame with the wrong payload");
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_payload_data(0 to 0), "Transmit a frame from instance 1.");
    ethernet_expect(ETHERNET_VVCT, 2, RX, v_payload_data(1 to 1), "Expect a frame at instance 2.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for expect to finish.");

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- Allow some time for completion
    ETHERNET_VVC_SB.report_counters(ALL_INSTANCES);
    report_alert_counters(FINAL);       -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end architecture func;
