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
entity ethernet_sbi_sb_tb is
  generic (
    GC_TEST       : string    := "UVVM";
    GC_DATA_WIDTH : positive  := 8);
end entity ethernet_sbi_sb_tb;

-- Test case architecture
architecture func of ethernet_sbi_sb_tb is

  constant C_CLK_PERIOD : time     := 10 ns;    -- **** Trenger metode for setting av clk period
  constant C_SCOPE      : string   := "ETHERNET_SBI_VVC_TB";
  constant C_ADDR_WIDTH : positive := 8;

  alias i2_sbi_if is << signal .ethernet_sbi_sb_tb.i_test_harness.i2_sbi_if : t_sbi_if(addr(C_ADDR_WIDTH-1 downto 0), wdata(GC_DATA_WIDTH-1 downto 0), rdata(GC_DATA_WIDTH-1 downto 0)) >>;
  alias clk       is << signal .ethernet_sbi_sb_tb.i_test_harness.clk : std_logic >>;
begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.sbi_test_harness
    generic map(
      GC_CLK_PERIOD => C_CLK_PERIOD,
      GC_ADDR_WIDTH => C_ADDR_WIDTH,
      GC_DATA_WIDTH => GC_DATA_WIDTH);

  i_ti_uvvm_engine  : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_cmd_idx            : natural;
    variable v_send_data          : t_byte_array(0 to C_MAX_PAYLOAD_LENGTH-1);
    variable v_receive_data       : bitvis_vip_ethernet.vvc_cmd_pkg.t_vvc_result;
    variable v_time_stamp         : time;
    variable v_ethernet_frame     : t_ethernet_frame;

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
      v_data_raw(0 to 5) := to_byte_array(std_logic_vector(v_ethernet_frame.mac_destination));

      -- MAC source
      v_ethernet_frame.mac_source := mac_source;
      v_data_raw(6 to 11) := to_byte_array(std_logic_vector(v_ethernet_frame.mac_source));

      -- length
      v_ethernet_frame.length  := v_length;
      v_data_raw(12 to 13) := to_byte_array(std_logic_vector(to_unsigned(v_ethernet_frame.length, 16)));

      -- Padding if needed
      if v_length > C_MIN_PAYLOAD_LENGTH then
       v_payload_length := v_length;
      end if;

      -- payload
      v_ethernet_frame.payload(0 to v_length-1) := payload(0 to v_length-1);
      v_data_raw(14 to 14+v_length-1) := payload(0 to v_length-1);

      -- FCS
      v_ethernet_frame.fcs := not generate_crc_32_complete(reverse_vectors_in_array(v_data_raw(0 to 14+v_payload_length-1)));

      return v_ethernet_frame;
    end  function make_ethernet_frame;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    await_uvvm_initialization(VOID);

    disable_log_msg(ID_UVVM_DATA_QUEUE);
    -- disable_log_msg(ALL_MESSAGES);
    -- enable_log_msg(ID_SEQUENCER);
    -- enable_log_msg(ID_LOG_HDR);
    disable_log_msg(ID_UVVM_CMD_ACK);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    disable_log_msg(SBI_VVCT, 2, ALL_MESSAGES);

    shared_ethernet_sb.set_scope("ETHERNET VVC");
    shared_ethernet_sb.config(1, C_SB_CONFIG_DEFAULT);
    shared_ethernet_sb.enable(1);
    shared_ethernet_sb.config(2, C_SB_CONFIG_DEFAULT);
    shared_ethernet_sb.enable(2);


    shared_sbi_sb.set_scope("SBI VVC");
    shared_sbi_sb.config(1, C_SB_CONFIG_DEFAULT);
    shared_sbi_sb.enable(1);
    shared_sbi_sb.config(2, C_SB_CONFIG_DEFAULT);
    shared_sbi_sb.enable(2);

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

    log(ID_LOG_HDR, "Send 10 bytes of data from i1 to i2");
    for i in 0 to 9 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to 9), "Send random data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to 9));
    shared_ethernet_sb.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 2 us, "Wait for read to finish.");

    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " bytes of data from i1 to i2");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send random data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1));
    shared_ethernet_sb.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

    for i in 0 to 19 loop
      log(ID_LOG_HDR, "Send 1 byte of data from i1 to i2: byte " & to_string(i));
      v_send_data(0) := random(8);
      ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to 0), "Send random data from instance 1.");
      v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to 0));
      shared_ethernet_sb.add_expected(2, v_ethernet_frame);
      ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.", TO_SB);
      await_completion(ETHERNET_VVCT, 2, RX, 2 ms, "Wait for read to finish.");
      await_completion(ETHERNET_VVCT, 1, TX, 2 ms, "Wait for send to finish.");
    end loop;

    log(ID_LOG_HDR, "Send data on SBI level, i1 --> i2");
    for i in 1 to 100 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write byte " & to_string(i) & " to FIFO");
      --shared_sbi_sb.add_expected(2, to_sb_result(v_send_data(0)));
      shared_sbi_sb.add_expected(2, v_send_data(0));
      sbi_read(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_GET, 8), "Read byte " & to_string(i) & " from FIFO", TO_SB);
    end loop;
    shared_sbi_sb.report_counters(ALL_ENABLED_INSTANCES);
    await_completion(SBI_VVCT, 2, 1 ms, "Wait for read to finish");

    log(ID_LOG_HDR, "Send 45 byte of data (min payload size -1) from i1 to i2");
    for i in 0 to 44 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to 44), "Send data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to 44));
    shared_ethernet_sb.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Receive data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");
    await_completion(ETHERNET_VVCT, 1, TX, 1 ms, "Wait for send to finish.");

    log(ID_LOG_HDR, "Send 46 byte of data (min payload size) from i1, check with expect in i2");
    for i in 0 to 45 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to 45), "Send data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to 45));
    shared_ethernet_sb.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Receive data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Send data on SBI level, i1 <-- i2");
    for i in 0 to 99 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write data to FIFO");
      --shared_sbi_sb.add_expected(1, to_sb_result(v_send_data(0)));
      shared_sbi_sb.add_expected(1, v_send_data(0));
      sbi_read(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_GET, 8), "Read data from FIFO", TO_SB);
      await_completion(SBI_VVCT, 1, 2 us, "Wait for read to finish");
    end loop;

    log(ID_LOG_HDR, "Send 47 byte of data (min payload size +1) from i1, check with expect in i2");
    for i in 0 to 46 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 1, TX, v_send_data(0 to 46), "Send data from instance 1.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source, v_send_data(0 to 46));
    shared_ethernet_sb.add_expected(2, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Receive data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

  -------------------------------------------------------------------------------------------------------------------------------

    log(ID_LOG_HDR_LARGE, "i1 <-- i2");

    log(ID_LOG_HDR, "Send 10 bytes of data from i2 to i1");
    for i in 0 to 9 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 9), "Send random data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to 9));
    shared_ethernet_sb.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Read random data from instance 2.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 2 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " bytes of data from i2 to i1");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send random data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1));
    shared_ethernet_sb.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Read random data from instance 1.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");

    for i in 0 to 19 loop
      log(ID_LOG_HDR, "Send 1 byte of data from i2 to i1: byte " & to_string(i));
      v_send_data(0) := random(8);
      ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 0), "Send random data from instance 2.");
      v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to 0));
      shared_ethernet_sb.add_expected(1, v_ethernet_frame);
      ethernet_receive(ETHERNET_VVCT, 1, RX, "Read random data from instance 2.", TO_SB);
      await_completion(ETHERNET_VVCT, 1, RX, 2 ms, "Wait for read to finish.");
    end loop;

    log(ID_LOG_HDR, "Send data on SBI level, i1 --> i2");
    for i in 0 to 99 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write data to FIFO");
      --shared_sbi_sb.add_expected(2, to_sb_result(v_send_data(0)));
      shared_sbi_sb.add_expected(2, v_send_data(0));
      sbi_read(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_GET, 8), "Read data from FIFO", TO_SB);
      await_completion(SBI_VVCT, 2, 1 us, "Wait for read to finish");
    end loop;

    log(ID_LOG_HDR, "Send 45 byte of data (min payload size -1) from i2 to i1");
    for i in 0 to 44 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 44), "Send data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to 44));
    shared_ethernet_sb.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Receive data from instance 2.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Send 46 byte of data (min payload size) from i2, check with expect in i1");
    for i in 0 to 45 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 45), "Send data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to 45));
    shared_ethernet_sb.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Receive data from instance 2.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Send 47 byte of data (min payload size +1) from i2, check with expect in i1");
    for i in 0 to 46 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 46), "Send data from instance 2.");
    v_ethernet_frame := make_ethernet_frame(shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination, shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source, v_send_data(0 to 46));
    shared_ethernet_sb.add_expected(1, v_ethernet_frame);
    ethernet_receive(ETHERNET_VVCT, 1, RX, "Receive data from instance 2.", TO_SB);
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Send data on SBI level, i1 <-- i2");
    for i in 0 to 99 loop
      v_send_data(0) := random(8);
      sbi_write(SBI_VVCT, 2, to_unsigned(C_ADDR_FIFO_PUT, 8), v_send_data(0), "Write data to FIFO");
      --shared_sbi_sb.add_expected(1, to_sb_result(v_send_data(0)));
      shared_sbi_sb.add_expected(1, v_send_data(0));
      sbi_read(SBI_VVCT, 1, to_unsigned(C_ADDR_FIFO_GET, 8), "Read data from FIFO", TO_SB);
      await_completion(SBI_VVCT, 1, 1 us, "Wait for read to finish");
    end loop;

    log(ID_LOG_HDR, "Verify insert_delay");
    await_change(clk, 0 ns, 6 ns, ERROR, "Sync to clock.");
    await_value(clk, '1', 0 ns, 6 ns, ERROR, "Sync to clock.");
    insert_delay(ETHERNET_VVCT, 2, TX, 1 us, "Insert delay in instance 2.");
    v_time_stamp := now;
    ethernet_transmit(ETHERNET_VVCT, 2, TX, v_send_data(0 to 46), "Send data from instance 2.");
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to 46), "Expect data from instance 2.");
    await_value(i2_sbi_if.wena, '1', 0 ns, 1.1 us, ERROR, "Await ethernet transfer.");
    check_value_in_range(now-v_time_stamp, 1 us, 1.01 us, ERROR, "Verify inserted delay.");
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");




        -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    shared_sbi_sb.report_counters(ALL_ENABLED_INSTANCES);
    shared_ethernet_sb.report_counters(ALL_ENABLED_INSTANCES);
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end architecture func;