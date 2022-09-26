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

use work.ethernet_gmii_mac_master_pkg.all;

library mac_master;
use mac_master.ethernet_types.all;

--hdlregression:tb
-- Test case entity
entity ethernet_gmii_mac_master_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity ethernet_gmii_mac_master_tb;

-- Test case architecture
architecture func of ethernet_gmii_mac_master_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 8 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  constant C_VVC_MAC_ADDR    : unsigned(47 downto 0) := x"00_00_00_00_00_01";
  constant C_MASTER_MAC_ADDR : unsigned(47 downto 0) := x"00_00_00_00_00_02";

  signal if_in  : t_if_in;
  signal if_out : t_if_out;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.ethernet_gmii_mac_master_th
    generic map(
      GC_CLK_PERIOD  => C_CLK_PERIOD,
      GC_MAC_ADDRESS => C_MASTER_MAC_ADDR
    )
    port map(
      if_in  => if_in,
      if_out => if_out
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_random_num : positive;

    --------------------------------------------------------------
    -- Send data from the Ethernet MAC master to the VVC
    --------------------------------------------------------------
    procedure receive_from_mac_master(
      constant num_bytes_in_payload : in positive
    ) is
      variable v_packet : t_byte_array(0 to C_MAX_PACKET_LENGTH - 1) := (others => (others => '0'));
    begin
      log(ID_SEQUENCER, "Start sending " & to_string(num_bytes_in_payload) & " bytes of data from MAC Master to VVC");

      -- First two bytes indicates to Ethernet MAC master how many bytes there are in the Ethernet packet.
      v_packet(0 to 1)   := convert_slv_to_byte_array(std_logic_vector(to_unsigned(14 + num_bytes_in_payload, 16)), LOWER_BYTE_LEFT);
      -- MAC destination
      v_packet(2 to 7)   := convert_slv_to_byte_array(std_logic_vector(C_VVC_MAC_ADDR), LOWER_BYTE_LEFT);
      -- MAC source
      v_packet(8 to 13)  := convert_slv_to_byte_array(std_logic_vector(C_MASTER_MAC_ADDR), LOWER_BYTE_LEFT);
      -- Payload length
      v_packet(14 to 15) := convert_slv_to_byte_array(std_logic_vector(to_unsigned(num_bytes_in_payload, 16)), LOWER_BYTE_LEFT);
      -- Payload
      for i in 0 to num_bytes_in_payload - 1 loop
        v_packet(16 + i) := random(8);
      end loop;

      -- Send the data from Ethernet MAC master
      if if_out.tx_reset_o = '1' then
        wait until if_out.tx_reset_o = '0';
      end if;
      for i in 0 to 16 + num_bytes_in_payload - 1 loop
        wait until rising_edge(if_out.clk);
        while if_out.tx_full_o = '1' loop
          if_in.tx_wr_en_i <= '0';
          wait until rising_edge(if_out.clk);
        end loop;
        if_in.tx_data_i  <= t_ethernet_data(v_packet(i));
        if_in.tx_wr_en_i <= '1';
        wait until falling_edge(if_out.clk);
      end loop;

      ethernet_expect(ETHERNET_VVCT, 1, RX, v_packet(16 to 16 + num_bytes_in_payload - 1), "Expect " & to_string(num_bytes_in_payload) & " bytes of random data from Ethernet MAC Master");

      wait until rising_edge(if_out.clk);
      if_in.tx_wr_en_i <= '0';

      log(ID_SEQUENCER, "Sending data from MAC Master finished");
      await_completion(ETHERNET_VVCT, 1, RX, num_bytes_in_payload * 10 ns + 10 us, "Wait for expect to finish.");
    end procedure receive_from_mac_master;

    --------------------------------------------------------------
    -- Send data from the VVC to the Ethernet MAC master
    --------------------------------------------------------------
    procedure send_to_mac_master(
      constant num_bytes_in_payload : in positive
    ) is
      variable v_packet        : t_byte_array(0 to C_MAX_PACKET_LENGTH - 1);
      variable v_send_frame    : t_ethernet_frame;
      variable v_receive_frame : t_ethernet_frame;
    begin
      log(ID_SEQUENCER, "Start sending " & to_string(num_bytes_in_payload) & " bytes of data from VVC to MAC Master");
      if_in.rx_rd_en_i <= '0';

      -- MAC destination
      v_send_frame.mac_destination := C_MASTER_MAC_ADDR;
      v_packet(0 to 5)             := convert_slv_to_byte_array(std_logic_vector(v_send_frame.mac_destination), LOWER_BYTE_LEFT);
      -- MAC source
      v_send_frame.mac_source      := C_VVC_MAC_ADDR;
      v_packet(6 to 11)            := convert_slv_to_byte_array(std_logic_vector(v_send_frame.mac_source), LOWER_BYTE_LEFT);
      -- Payload length
      v_send_frame.payload_length  := num_bytes_in_payload;
      v_packet(12 to 13)           := convert_slv_to_byte_array(std_logic_vector(to_unsigned(v_send_frame.payload_length, 16)), LOWER_BYTE_LEFT);
      -- Payload
      for i in 0 to num_bytes_in_payload - 1 loop
        v_send_frame.payload(i) := random(8);
        v_packet(14 + i)        := v_send_frame.payload(i);
      end loop;
      -- FCS
      v_send_frame.fcs             := not generate_crc_32(v_packet(0 to 14 + num_bytes_in_payload - 1));

      ethernet_transmit(ETHERNET_VVCT, 1, TX, v_packet(14 to 14 + num_bytes_in_payload - 1), "Send a frame from instance 1.");

      log(ID_SEQUENCER, "Fetch data from MAC Master");
      for i in 0 to 16 + num_bytes_in_payload - 1 loop
        if if_out.rx_empty_o = '1' then
          wait until if_out.rx_empty_o = '0';
        end if;
        wait until falling_edge(if_out.clk);
        if_in.rx_rd_en_i <= '1';
        wait until rising_edge(if_out.clk);
        v_packet(i)      := if_out.rx_data_o;
      end loop;

      log(ID_SEQUENCER, "Fetch data from MAC Master finished");
      v_receive_frame.mac_destination                        := unsigned(convert_byte_array_to_slv(v_packet(2 to 7), LOWER_BYTE_LEFT));
      v_receive_frame.mac_source                             := unsigned(convert_byte_array_to_slv(v_packet(8 to 13), LOWER_BYTE_LEFT));
      v_receive_frame.payload_length                         := to_integer(unsigned(convert_byte_array_to_slv(v_packet(14 to 15), LOWER_BYTE_LEFT)));
      v_receive_frame.payload(0 to num_bytes_in_payload - 1) := v_packet(16 to 16 + num_bytes_in_payload - 1);
      v_receive_frame.fcs                                    := v_send_frame.fcs;

      compare_ethernet_frames(v_receive_frame, v_send_frame, ERROR, ID_SEQUENCER, "Comparing received and expected frames", C_SCOPE, shared_msg_id_panel);
    end procedure send_to_mac_master;

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
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination := C_MASTER_MAC_ADDR;
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source      := C_VVC_MAC_ADDR;
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_destination := C_MASTER_MAC_ADDR;
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_source      := C_VVC_MAC_ADDR;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "START SIMULATION OF ETHERNET VVC");
    ---------------------------------------------------------------------------
    if_in.rx_rd_en_i <= '0';
    wait for 10 us;

    log(ID_LOG_HDR_LARGE, "Send minimum amount of bytes in payload, payload = 46, total = 64.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(46);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(46);

    log(ID_LOG_HDR_LARGE, "Send minimum amount of bytes -1 in payload, payload = 45, total = 63.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(45);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(45);

    log(ID_LOG_HDR_LARGE, "Send minimum amount of bytes +1 in payload, payload = 47, total = 65.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(47);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(47);

    log(ID_LOG_HDR_LARGE, "Send maximum amount of bytes in payload, payload = 1500, total = 1518.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(1500);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(1500);

    log(ID_LOG_HDR_LARGE, "Send 10 sequences of data with random number of bytes between 1 and 100 in payload.");
    for i in 1 to 10 loop
      v_random_num := random(1, 100);
      log(ID_LOG_HDR, "MAC Master --> VVC");
      receive_from_mac_master(v_random_num);
      log(ID_LOG_HDR, "VVC --> MAC Master");
      send_to_mac_master(v_random_num);
    end loop;

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

end architecture func;
