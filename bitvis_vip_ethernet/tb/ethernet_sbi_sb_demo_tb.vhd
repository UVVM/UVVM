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
use bitvis_vip_ethernet.ethernet_sbi_pkg.all;

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

-- Test case entity
entity ethernet_sbi_sb_demo_tb is
end entity ethernet_sbi_sb_demo_tb;

-- Test case architecture
architecture func of ethernet_sbi_sb_demo_tb is

  constant C_CLK_PERIOD   : time := 10 ns;
  constant C_SCOPE        : string := "ETHERNET over SBI SB TB";

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.sbi_test_harness generic map(GC_CLK_PERIOD => C_CLK_PERIOD);

  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_send_data      : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH-1);
    variable v_ethernet_frame : t_ethernet_frame;

    impure function make_ethernet_frame(
      constant mac_destination : in unsigned(47 downto 0);
      constant mac_source      : in unsigned(47 downto 0);
      constant payload         : in t_byte_array
    ) return t_ethernet_frame is
      variable v_data_raw       : t_byte_array(0 to C_MAX_FRAME_LENGTH-1) := (others => (others => '0'));
      variable v_ethernet_frame : t_ethernet_frame := C_ETHERNET_FRAME_DEFAULT;
      variable v_payload_length : positive := C_MIN_PAYLOAD_LENGTH;
      variable v_length         : positive := payload'length;
    begin
      -- MAC destination
      v_ethernet_frame.mac_destination := mac_destination;
      v_data_raw(0 to 5) := convert_slv_to_byte_array(std_logic_vector(v_ethernet_frame.mac_destination), LOWER_BYTE_LEFT);

      -- MAC source
      v_ethernet_frame.mac_source := mac_source;
      v_data_raw(6 to 11) := convert_slv_to_byte_array(std_logic_vector(v_ethernet_frame.mac_source), LOWER_BYTE_LEFT);

      -- Payload length
      v_ethernet_frame.payload_length := v_length;
      v_data_raw(12 to 13) := convert_slv_to_byte_array(std_logic_vector(to_unsigned(v_ethernet_frame.payload_length, 16)), LOWER_BYTE_LEFT);

      -- Padding if needed
      if v_length > C_MIN_PAYLOAD_LENGTH then
       v_payload_length := v_length;
      end if;

      -- Payload
      v_ethernet_frame.payload(0 to v_length-1) := payload(0 to v_length-1);
      v_data_raw(14 to 14+v_length-1) := payload(0 to v_length-1);

      -- FCS
      v_ethernet_frame.fcs := not generate_crc_32(v_data_raw(0 to 14+v_payload_length-1));

      return v_ethernet_frame;
    end function make_ethernet_frame;

  begin

    await_uvvm_initialization(VOID);

    disable_log_msg(ID_UVVM_DATA_QUEUE);
    disable_log_msg(ID_UVVM_CMD_ACK);
    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_GEN_PULSE);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    disable_log_msg(SBI_VVCT, 2, ALL_MESSAGES);

    -- Configuration of Ethernet and SBI SBs is done in their corresponding VVC executors

    log(ID_LOG_HDR_LARGE, "START SIMULATION OF ETHERNET VVC");

    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"02");

    log(ID_LOG_HDR_LARGE, "i1 --> i2");

    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " bytes of data from i1 to i2");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send random data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1));
    ETHERNET_SB.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for send to finish.");

    log(ID_LOG_HDR, "Send data on SBI level, i1 --> i2");
    for i in 0 to 9 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write byte " & to_string(i) & " to FIFO");
      SBI_SB.add_expected(2, v_send_data(0));
      sbi_read(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_GET, 8), "Read byte " & to_string(i) & " from FIFO", TO_SB);
    end loop;
    SBI_SB.report_counters(ALL_ENABLED_INSTANCES);
    await_completion(SBI_VVCT, 2, 1 ms, "Wait for read to finish");

    log(ID_LOG_HDR, "Send 46 byte of data (min payload size) from i1, check with expect in i2");
    for i in 0 to 45 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to 45), "Send data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to 45));
    ETHERNET_SB.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Receive data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for send to finish.");

    log(ID_LOG_HDR, "Send data on SBI level, i1 <-- i2");
    for i in 0 to 9 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write data to FIFO");
      SBI_SB.add_expected(1, v_send_data(0));
      sbi_read(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_GET, 8), "Read data from FIFO", TO_SB);
      await_completion(SBI_VVCT, 1, 2 us, "Wait for read to finish");
    end loop;

  -------------------------------------------------------------------------------------------------------------------------------

    log(ID_LOG_HDR_LARGE, "i1 <-- i2");

    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " bytes of data from i2 to i1");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send random data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1));
    ETHERNET_SB.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Read random data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");
    await_completion(ETHERNET_VVCT, 2, TX, 1 ms, "Wait for send to finish.");

    log(ID_LOG_HDR, "Send data on SBI level, i1 --> i2");
    for i in 0 to 9 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write data to FIFO");
      SBI_SB.add_expected(2, v_send_data(0));
      sbi_read(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_GET, 8), "Read data from FIFO", TO_SB);
      await_completion(SBI_VVCT, 2, 1 us, "Wait for read to finish");
    end loop;

    log(ID_LOG_HDR, "Send 46 byte of data (min payload size) from i2, check with expect in i1");
    for i in 0 to 45 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 45), "Send data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to 45));
    ETHERNET_SB.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Receive data from instance 2.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");
    await_completion(ETHERNET_VVCT, 2, TX, 1 ms, "Wait for send to finish.");

    log(ID_LOG_HDR, "Send data on SBI level, i1 <-- i2");
    for i in 0 to 9 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write data to FIFO");
      SBI_SB.add_expected(1, v_send_data(0));
      sbi_read(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_GET, 8), "Read data from FIFO", TO_SB);
      await_completion(SBI_VVCT, 1, 1 us, "Wait for read to finish");
    end loop;

    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;  -- to allow some time for completion
    SBI_SB.report_counters(ALL_ENABLED_INSTANCES);
    ETHERNET_SB.report_counters(ALL_ENABLED_INSTANCES);
    report_alert_counters(VOID);
    log(ID_LOG_HDR, "SIMULATION COMPLETED");

    std.env.stop;

  end process p_main;

end architecture func;