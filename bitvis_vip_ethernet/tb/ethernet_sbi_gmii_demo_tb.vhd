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
-- Description : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

library bitvis_vip_gmii;
context bitvis_vip_gmii.vvc_context;

library bitvis_vip_ethernet;
context bitvis_vip_ethernet.vvc_context;

use work.ethernet_mac_pkg.all;

--hdlregression:tb
-- Test case entity
entity ethernet_sbi_gmii_demo_tb is
end entity ethernet_sbi_gmii_demo_tb;

-- Test case architecture
architecture func of ethernet_sbi_gmii_demo_tb is
  --------------------------------------------------------------------------------
  -- Types and constants declarations
  --------------------------------------------------------------------------------
  constant C_CLK_PERIOD : time   := 8 ns;
  constant C_SCOPE      : string := C_TB_SCOPE_DEFAULT;

  constant C_VVC_ETH_SBI  : natural := 1;
  constant C_VVC_SBI      : natural := 1;
  constant C_VVC_ETH_GMII : natural := 2;
  constant C_VVC_GMII     : natural := 2;

  constant C_ETH_SBI_MAC_ADDR  : unsigned(47 downto 0) := x"00_00_00_00_00_01";
  constant C_ETH_GMII_MAC_ADDR : unsigned(47 downto 0) := x"00_00_00_00_00_02";

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and VVCs
  -----------------------------------------------------------------------------
  i_test_harness : entity work.ethernet_sbi_gmii_demo_th
    generic map(
      GC_CLK_PERIOD => C_CLK_PERIOD
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_payload_len    : integer := 0;
    variable v_payload_data   : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH - 1);
    variable v_expected_frame : t_ethernet_frame;

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
    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Verbosity control
    disable_log_msg(ID_UVVM_CMD_ACK);

    -- Set Ethernet VVC config for this testbench
    shared_ethernet_vvc_config(TX, C_VVC_ETH_SBI).bfm_config.mac_destination  := C_ETH_GMII_MAC_ADDR;
    shared_ethernet_vvc_config(TX, C_VVC_ETH_SBI).bfm_config.mac_source       := C_ETH_SBI_MAC_ADDR;
    shared_ethernet_vvc_config(RX, C_VVC_ETH_GMII).bfm_config.mac_destination := C_ETH_SBI_MAC_ADDR;
    shared_ethernet_vvc_config(RX, C_VVC_ETH_GMII).bfm_config.mac_source      := C_ETH_GMII_MAC_ADDR;

    -- Set the receiving VVC timeout long enough to handle a packet going through the DUT
    shared_gmii_vvc_config(RX, C_VVC_GMII).bfm_config.max_wait_cycles := C_MAX_PACKET_LENGTH;

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "START SIMULATION OF ETHERNET VVC");
    ---------------------------------------------------------------------------
    v_payload_len    := 10;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from CPU to Ethernet MAC (need padding)");
    ethernet_transmit(ETHERNET_VVCT, C_VVC_ETH_SBI, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from the CPU.");
    v_expected_frame := make_ethernet_frame(C_ETH_GMII_MAC_ADDR, C_ETH_SBI_MAC_ADDR, v_payload_data(0 to v_payload_len - 1));
    ETHERNET_VVC_SB.add_expected(C_VVC_ETH_GMII, v_expected_frame);
    ethernet_receive(ETHERNET_VVCT, C_VVC_ETH_GMII, RX, TO_SB, "Receive a frame in the PHY and put it in the Scoreboard.");
    await_completion(ETHERNET_VVCT, C_VVC_ETH_SBI, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, C_VVC_ETH_GMII, RX, 1 ms, "Wait for receive to finish.");

    v_payload_len    := 46;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from CPU to Ethernet MAC (minimum size)");
    ethernet_transmit(ETHERNET_VVCT, C_VVC_ETH_SBI, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from the CPU.");
    v_expected_frame := make_ethernet_frame(C_ETH_GMII_MAC_ADDR, C_ETH_SBI_MAC_ADDR, v_payload_data(0 to v_payload_len - 1));
    ETHERNET_VVC_SB.add_expected(C_VVC_ETH_GMII, v_expected_frame);
    ethernet_receive(ETHERNET_VVCT, C_VVC_ETH_GMII, RX, TO_SB, "Receive a frame in the PHY and put it in the Scoreboard.");
    await_completion(ETHERNET_VVCT, C_VVC_ETH_SBI, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, C_VVC_ETH_GMII, RX, 1 ms, "Wait for receive to finish.");

    v_payload_len    := C_MAX_PAYLOAD_LENGTH;
    for i in 0 to v_payload_len - 1 loop
      v_payload_data(i) := random(8);
    end loop;
    log(ID_LOG_HDR, "Transmit " & to_string(v_payload_len) & " bytes of data from CPU to Ethernet MAC (maximum size)");
    ethernet_transmit(ETHERNET_VVCT, C_VVC_ETH_SBI, TX, v_payload_data(0 to v_payload_len - 1), "Transmit a frame from the CPU.");
    v_expected_frame := make_ethernet_frame(C_ETH_GMII_MAC_ADDR, C_ETH_SBI_MAC_ADDR, v_payload_data(0 to v_payload_len - 1));
    ETHERNET_VVC_SB.add_expected(C_VVC_ETH_GMII, v_expected_frame);
    ethernet_receive(ETHERNET_VVCT, C_VVC_ETH_GMII, RX, TO_SB, "Receive a frame in the PHY and put it in the Scoreboard.");
    await_completion(ETHERNET_VVCT, C_VVC_ETH_SBI, TX, 1 ms, "Wait for transmit to finish.");
    await_completion(ETHERNET_VVCT, C_VVC_ETH_GMII, RX, 1 ms, "Wait for receive to finish.");
    wait for 1 us; -- Wait so that interface goes idle before the next test

    ---------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "TEST DIRECT ACCESS TO INTERFACE VVCs");
    ---------------------------------------------------------------------------
    log(ID_LOG_HDR, "Write and read data on SBI level");
    for i in 0 to 9 loop
      v_payload_data(0) := random(8);
      sbi_write(SBI_VVCT, C_VVC_SBI, C_ETH_ADDR_DUMMY, v_payload_data(0), "Write byte " & to_string(i) & " to dummy register");
      sbi_check(SBI_VVCT, C_VVC_SBI, C_ETH_ADDR_DUMMY, v_payload_data(0), "Check byte " & to_string(i) & " from dummy register");
    end loop;
    await_completion(SBI_VVCT, C_VVC_SBI, 1 ms, "Wait for check to finish");

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
