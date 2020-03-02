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

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.vvc_context;
use bitvis_vip_ethernet.ethernet_gmii_mac_master_pkg.all;

library mac_master;
use mac_master.ethernet_types.all;

-- Test case entity
entity ethernet_gmii_mac_master_tb is
  generic (
    GC_TEST : string := "UVVM"
  );
end entity ethernet_gmii_mac_master_tb;

-- Test case architecture
architecture func of ethernet_gmii_mac_master_tb is

  constant C_CLK_PERIOD   : time := 8 ns;    -- **** Trenger metode for setting av clk period
  constant C_SCOPE        : string := "ETHERNET VVC - MAC MASTER TB";

  signal if_in  : t_if_in;
  signal if_out : t_if_out;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.gmii_mac_master_test_harness
    generic map(
      GC_CLK_PERIOD  => C_CLK_PERIOD,
      GC_MAC_ADDRESS => x"00_00_00_00_00_02"
    )
    port map(
      if_in  => if_in,
      if_out => if_out
    );

  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_cmd_idx            : natural;
    variable v_receive_data_raw   : t_byte_array(0 to 99);
    variable v_crc                : std_logic_vector(31 downto 0);
    variable v_reversed_crc       : std_logic_vector(31 downto 0);
    variable v_destination_addr   : unsigned(47 downto 0);
    variable v_source_addr        : unsigned(47 downto 0);
    variable v_random_num         : positive;

    procedure receive_from_mac_master(
      constant num_bytes_in_payload : in positive
    ) is
      variable v_send_data_raw      : t_byte_array(0 to num_bytes_in_payload+16-1);
    begin
      log(ID_SEQUENCER, "Start sending " & to_string(num_bytes_in_payload) & " bytes of data from Ethernet MAC Master to VVC");

      -- First two bytes indicates to Ethernet MAC master how many bytes there are in the Ethernet packet.
      v_send_data_raw(0 to 1) := to_byte_array(std_logic_vector(to_unsigned(num_bytes_in_payload+14, 16)));


      -- MAC destination
      v_send_data_raw(2 to 7) := to_byte_array(x"00_00_00_00_00_01");

      -- MAC source
      v_send_data_raw(8 to 13) := to_byte_array(x"00_00_00_00_00_02");

      -- length
      v_send_data_raw(14 to 15) := to_byte_array(std_logic_vector(to_unsigned(num_bytes_in_payload, 16)));

      -- payload
      for i in 0 to num_bytes_in_payload-1 loop
        v_send_data_raw(16+i) := random(8);
      end loop;

      if if_out.tx_reset_o = '1' then
        wait until if_out.tx_reset_o = '0';
      end if;

      for i in v_send_data_raw'range loop
        wait until rising_edge(if_out.clk);

        while if_out.tx_full_o = '1' loop
          if_in.tx_wr_en_i <= '0';
          wait until rising_edge(if_out.clk);
        end loop;
        if_in.tx_data_i  <= t_ethernet_data(v_send_data_raw(i));
        if_in.tx_wr_en_i <= '1';
        wait until falling_edge(if_out.clk);

      end loop;

      ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data_raw(16 to 16+num_bytes_in_payload-1), "Read " & to_string(num_bytes_in_payload) & " bytes of random data from Ethernet MAC Master");

      wait until rising_edge(if_out.clk);
      if_in.tx_wr_en_i <= '0';

      log(ID_LOG_HDR, "Sending data to MAC Master finished");

      await_completion(ETHERNET_VVCT, 1, RX, num_bytes_in_payload*10 ns + 10 us, "Wait for read to finish.");
    end procedure receive_from_mac_master;

    procedure send_to_mac_master(
      constant num_bytes_in_payload : in positive
    ) is
      variable v_data_raw           : t_byte_array(0 to 16+num_bytes_in_payload-1);
      variable v_send_data_frame    : t_ethernet_frame;
      variable v_receive_data_frame : t_ethernet_frame;
    begin
      log(ID_SEQUENCER, "Start sending " & to_string(num_bytes_in_payload) & " bytes of data from VVC to MAC Master");

      if_in.rx_rd_en_i <= '0';

      -- MAC destination
      v_send_data_frame.mac_destination := x"00_00_00_00_00_02";
      v_data_raw(0 to 5) := to_byte_array(std_logic_vector(v_send_data_frame.mac_destination));

      -- MAC source
      v_send_data_frame.mac_source := x"00_00_00_00_00_01";
      v_data_raw(6 to 11)     := to_byte_array(std_logic_vector(v_send_data_frame.mac_source));

      -- length
      v_send_data_frame.length  := num_bytes_in_payload;
      v_data_raw(12 to 13) := to_byte_array(std_logic_vector(to_unsigned(v_send_data_frame.length, 16)));

      -- payload
      for i in 0 to num_bytes_in_payload-1 loop
        v_send_data_frame.payload(i) := random(8);
        v_data_raw(14+i)        := v_send_data_frame.payload(i);
      end loop;
      -- FCS
      v_send_data_frame.fcs := not generate_crc_32(reverse_vectors_in_array(v_data_raw(0 to 14+num_bytes_in_payload-1)));

      ethernet_transmit(ETHERNET_VVCT, 1, TX, v_data_raw(14 to 14+num_bytes_in_payload-1), "Send random data from instance 1.");

      log(ID_LOG_HDR, "Fetch data from MAC Master");

      for i in 0 to 16+num_bytes_in_payload-1 loop
        if if_out.rx_empty_o = '1' then
          wait until if_out.rx_empty_o = '0';
        end if;
        wait until falling_edge(if_out.clk);
        if_in.rx_rd_en_i <= '1';
        wait until rising_edge(if_out.clk);
        v_data_raw(i) := if_out.rx_data_o;
      end loop;

      log(ID_LOG_HDR, "Fetch data from MAC Master finished");

      v_receive_data_frame.mac_destination                      :=            unsigned(to_slv(v_data_raw(    2 to  7)));
      v_receive_data_frame.mac_source                           :=            unsigned(to_slv(v_data_raw(    8 to 13)));
      v_receive_data_frame.length                               := to_integer(unsigned(to_slv(v_data_raw(   14 to 15))));
      v_receive_data_frame.payload(0 to num_bytes_in_payload-1) :=                            v_data_raw(   16 to 16+num_bytes_in_payload-1);
      v_receive_data_frame.fcs                                  := v_send_data_frame.fcs;

      compare_ethernet_frames(v_receive_data_frame, v_send_data_frame, ERROR, "Comparing received and expected frames", C_SCOPE, shared_msg_id_panel, "Compare Ethernet frames:");
    end procedure send_to_mac_master;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    await_uvvm_initialization(VOID);

    if_in.rx_rd_en_i <= '0';


    log(ID_LOG_HDR_XL, "START SIMULATION OF ETHERNET VVC - ETHERNET MAC MASTER");

    wait for 10 us;

    shared_msg_id_panel(ID_PACKET_DATA) := DISABLED;
    shared_msg_id_panel(ID_PACKET_HDR)  := DISABLED;

    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination := x"00_00_00_00_00_02";
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source      := x"00_00_00_00_00_01";
    shared_ethernet_vvc_config(   RX, 1).bfm_config.mac_destination := x"00_00_00_00_00_02";
    shared_ethernet_vvc_config(   RX, 1).bfm_config.mac_source      := x"00_00_00_00_00_01";

    log(ID_LOG_HDR_LARGE, "Send minimum amount of bytes in payload, payload = 46, total = 64.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(46);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(46);

    -----------------------------------------------------------------------------------------------

    log(ID_LOG_HDR_LARGE, "Send minimum amount of bytes -1 in payload, payload = 45, total = 63.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(45);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(45);

    -----------------------------------------------------------------------------------------------

    log(ID_LOG_HDR_LARGE, "Send minimum amount of bytes +1 in payload, payload = 47, total = 65.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(47);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(47);

    -----------------------------------------------------------------------------------------------

    log(ID_LOG_HDR_LARGE, "Send maximum amount of bytes in payload, payload = 1500, total = 1518.");
    log(ID_LOG_HDR, "MAC Master --> VVC");
    receive_from_mac_master(1500);
    log(ID_LOG_HDR, "VVC --> MAC Master");
    send_to_mac_master(1500);

    -----------------------------------------------------------------------------------------------

    log(ID_LOG_HDR_LARGE, "Send 100 sequences of data with random number of bytes between 47 and 1499 in payload.");
    for i in 1 to 100 loop
      v_random_num := random(47, 1499);
      log(ID_LOG_HDR, "MAC Master --> VVC");
      receive_from_mac_master(v_random_num);
      log(ID_LOG_HDR, "VVC --> MAC Master");
      send_to_mac_master(v_random_num);
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

end architecture func;