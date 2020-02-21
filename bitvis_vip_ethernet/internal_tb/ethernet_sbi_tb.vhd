--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

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

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

-- Test case entity
entity ethernet_sbi_tb is
  generic (
    GC_TEST         : string    := "UVVM";
    GC_DATA_WIDTH   : positive  := 8);
end entity ethernet_sbi_tb;

-- Test case architecture
architecture func of ethernet_sbi_tb is

  constant C_CLK_PERIOD : time     := 10 ns;    -- **** Trenger metode for setting av clk period
  constant C_SCOPE      : string   := "ETHERNET_SBI_VVC_TB";
  constant C_ADDR_WIDTH : positive := 8;

  alias i2_sbi_if is << signal .ethernet_sbi_tb.i_test_harness.i2_sbi_if : t_sbi_if(addr(C_ADDR_WIDTH-1 downto 0), wdata(GC_DATA_WIDTH-1 downto 0), rdata(GC_DATA_WIDTH-1 downto 0)) >>;
  alias clk       is << signal .ethernet_sbi_tb.i_test_harness.clk : std_logic >>;
begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity bitvis_vip_ethernet.sbi_test_harness generic map(
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
  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    await_uvvm_initialization(VOID);

    disable_log_msg(ID_UVVM_DATA_QUEUE);
    --disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);

    -- bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    -- bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.disable_log_msg(SBI_VVCT, 2, ALL_MESSAGES);

    log(ID_LOG_HDR_LARGE, "START SIMULATION OF ETHERNET VVC");

    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(TX, 1).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(RX, 1).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(TX, 2).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"02");
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_destination := (x"00", x"00", x"00", x"00", x"00", x"01");
    shared_ethernet_vvc_config(RX, 2).bfm_config.mac_source      := (x"00", x"00", x"00", x"00", x"00", x"02");


    log(ID_LOG_HDR, "Send 10 bytes of data from i1 to i2");
    for i in 0 to 9 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to 9), "Send random data from instance 1.");
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
    v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
    check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
    check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
    for i in 0 to 9 loop
      check_value(v_receive_data.ethernet_frame.payload(i), v_send_data(i), ERROR, "Verify received payload, byte " & to_string(i) & ".");
    end loop;


    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " bytes of data from i1 to i2");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send random data from instance 1.");
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
    v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
    check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
    check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");

    log(ID_LOG_HDR, "Verify received payload");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      check_value(v_receive_data.ethernet_frame.payload(i), v_send_data(i), ERROR, "Verify received payload, byte " & to_string(i) & ".", C_SCOPE, HEX_BIN_IF_INVALID, KEEP_LEADING_0, ID_NEVER);
    end loop;



    for i in 0 to 19 loop
      log(ID_LOG_HDR, "Send 1 byte of data from i1 to i2: byte " & to_string(i));
      v_send_data(0) := random(8);
      ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to 0), "Send random data from instance 1.");
      ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
      v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
      await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

      log(ID_LOG_HDR, "Fetch data from i2");
      fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

      check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
      check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
      check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
      check_value(v_receive_data.ethernet_frame.payload(0), v_send_data(0), ERROR, "Verify received payload.", C_SCOPE, HEX, KEEP_LEADING_0, ID_NEVER);
    end loop;



    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " byte of data from i1 to i2");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 1, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send random data from instance 1.");
    ethernet_receive(ETHERNET_VVCT, 2, RX, "Read random data from instance 1.");
    v_cmd_idx := get_last_received_cmd_idx(ETHERNET_VVCT, 2, RX);
    await_completion(ETHERNET_VVCT, 2, RX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Fetch data from i2");
    fetch_result(ETHERNET_VVCT, 2, RX, v_cmd_idx, v_receive_data, "Fetching received data.");

    check_value(v_receive_data.ethernet_frame.mac_destination = (x"00", x"00", x"00", x"00", x"00", x"02"), ERROR, "Verify MAC destination.");
    check_value(v_receive_data.ethernet_frame.mac_source      = (x"00", x"00", x"00", x"00", x"00", x"01"), ERROR, "Verify MAC source.");
    check_value(v_receive_data.ethernet_frame_status.fcs_error, false, ERROR, "Verify FCS.");
    check_value(v_receive_data.ethernet_frame.payload, v_send_data, ERROR, "Verify received payload.");



    log(ID_LOG_HDR, "Send " & to_string(C_MAX_PAYLOAD_LENGTH) & " byte of data from i2, check with expect in i1");
    for i in 0 to C_MAX_PAYLOAD_LENGTH-1 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 2, TX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Send data from instance 2.");
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to C_MAX_PAYLOAD_LENGTH-1), "Expect data from instance 2.");
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");



    log(ID_LOG_HDR, "Send 45 byte of data (min payload size -1) from i2, check with expect in i1");
    for i in 0 to 44 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 2, TX, v_send_data(0 to 44), "Send data from instance 2.");
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to 44), "Expect data from instance 2.");
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");



    log(ID_LOG_HDR, "Send 46 byte of data (min payload size) from i2, check with expect in i1");
    for i in 0 to 45 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 2, TX, v_send_data(0 to 45), "Send data from instance 2.");
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to 45), "Expect data from instance 2.");
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");



    log(ID_LOG_HDR, "Send 47 byte of data (min payload size +1) from i2, check with expect in i1");
    for i in 0 to 46 loop
      v_send_data(i) := random(8);
    end loop;
    ethernet_send(ETHERNET_VVCT, 2, TX, v_send_data(0 to 46), "Send data from instance 2.");
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to 46), "Expect data from instance 2.");
    await_completion(ETHERNET_VVCT, 2, TX, 1 ms, "Wait for read to finish.");

    log(ID_LOG_HDR, "Verify insert_delay");
    await_change(clk, 0 ns, 6 ns, ERROR, "Sync to clock.");
    await_value(clk, '1', 0 ns, 6 ns, ERROR, "Sync to clock.");
    insert_delay(ETHERNET_VVCT, 2, TX, 1 us, "Insert delay in instance 2.");
    v_time_stamp := now;
    ethernet_send(ETHERNET_VVCT, 2, TX, v_send_data(0 to 46), "Send data from instance 2.");
    ethernet_expect(ETHERNET_VVCT, 1, RX, v_send_data(0 to 46), "Expect data from instance 2.");
    --await_value(i2_sbi_if.wena, '0', 0 ns, 1.1 us, ERROR, "Await ethernet transfer.");
    await_value(i2_sbi_if.wena, '1', 0 ns, 1.1 us, ERROR, "Await ethernet transfer.");
    check_value_in_range(now-v_time_stamp, 1 us, 1.01 us, ERROR, "Verify inserted delay.");
    await_completion(ETHERNET_VVCT, 1, RX, 1 ms, "Wait for read to finish.");


    
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