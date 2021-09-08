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

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;

--hdlunit:tb
-- Test case entity
entity uart_vvc_new_tb is
  generic (
    GC_TESTCASE : string := "UVVM"
    );
end entity;

-- Test case architecture
architecture func of uart_vvc_new_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD; -- default in design and BFM

  constant C_SCOPE     : string  := C_TB_SCOPE_DEFAULT;

  constant C_ADDR_RX_DATA    : unsigned(3 downto 0) := x"0";
  constant C_ADDR_RX_DATA_VALID : unsigned(3 downto 0) := x"1";
  constant C_ADDR_TX_DATA    : unsigned(3 downto 0) := x"2";
  constant C_ADDR_TX_READY   : unsigned(3 downto 0) := x"3";

  begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.test_harness;

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    -- Helper variables
    variable v_received_data : bitvis_vip_uart.vvc_cmd_pkg.t_vvc_result;
    variable i : natural;
    variable v_cmd_idx   : natural;
    variable v_is_ok     : boolean;
    variable v_timestamp : time;
    variable v_timeout   : time;

    variable v_alert_num_mismatch : boolean := false;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    set_alert_stop_limit(ERROR,0);
    set_alert_stop_limit(TB_ERROR,6);
    set_alert_stop_limit(FAILURE,2);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);

    disable_log_msg(SBI_VVCT,1,  ALL_MESSAGES);
    enable_log_msg(SBI_VVCT,1,  ID_BFM);

    disable_log_msg(UART_VVCT,1,RX,  ALL_MESSAGES);
    enable_log_msg(UART_VVCT,1,RX,  ID_BFM);
    enable_log_msg(UART_VVCT,1,RX,  ID_BFM_WAIT);
    enable_log_msg(UART_VVCT,1,RX,  ID_BFM_POLL);
    enable_log_msg(UART_VVCT,1,RX,  ID_BFM_POLL_SUMMARY);

    disable_log_msg(UART_VVCT,1,TX,  ALL_MESSAGES);
    enable_log_msg(UART_VVCT,1,TX,  ID_BFM);
    enable_log_msg(UART_VVCT,1,TX,  ID_BFM_WAIT);
    enable_log_msg(UART_VVCT,1,TX,  ID_BFM_POLL);
    enable_log_msg(UART_VVCT,1,TX,  ID_BFM_POLL_SUMMARY);

    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(TX,1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Start Test of UART VIP", C_SCOPE);
    ------------------------------------------------------------


    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD); -- for reset to be turned off

    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
    ------------------------------------------------------------
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default", ERROR);
    sbi_check(SBI_VVCT,1,  C_ADDR_TX_READY, x"01", "TX_READY default", ERROR);
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default", ERROR);
    await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);


    log(ID_LOG_HDR, "Check of uart_transmit()", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT,1,TX,  x"AA", "Testing UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA ", ERROR);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);


    log(ID_LOG_HDR, "Check of uart_expect() as simple, instant check", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"55", "TX_DATA");
    uart_expect(UART_VVCT, 1, RX,  x"55", "Expecting TX data");
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
    wait for 10*C_BIT_PERIOD;  -- margin


    log(ID_LOG_HDR, "Check of uart_receive()", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"56", "TX_DATA");
    uart_receive(UART_VVCT, 1, RX, "Receive inside VVC", ERROR);
    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 1, RX); -- for last read
    await_completion(UART_VVCT,1,RX,  13 * C_BIT_PERIOD);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);

    fetch_result(UART_VVCT,1, RX, v_cmd_idx, v_received_data, v_is_ok, "Fetching receive-result");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    check_value(v_received_data(7 downto 0), x"56", ERROR, "Readback data via fetch_result()");
    await_completion(UART_VVCT,1,RX,  13 * C_BIT_PERIOD);
    wait for 10*C_BIT_PERIOD;  -- margin


    log(ID_LOG_HDR, "Check of uart_receive() using Scoreboard", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"38", "TX_DATA");
    UART_VVC_SB.add_expected(1, x"38");
    uart_receive(UART_VVCT, 1, RX, TO_SB, "Receive inside VVC's SB", ERROR);
    await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
    wait for 10*C_BIT_PERIOD;  -- margin

    UART_VVC_SB.report_counters(ALL_INSTANCES);


    log(ID_LOG_HDR, "Test of advanced uart_expect()", C_SCOPE);
    ------------------------------------------------------------
    log("Testing uart_expect with multiple occurrences");
    uart_expect(UART_VVCT, 1, RX,  x"42", "Expecting TX data", 4, 0 ns);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"ab", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"ee", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"42", "TX_DATA");
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD*4);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4);
    wait for 10*C_BIT_PERIOD;  -- margin

    log("Testing uart_expect with delay");
    uart_expect(UART_VVCT, 1, RX,  x"af", "Expecting TX data", 0, 10000 ns);
    wait for 6000 ns;
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"af", "TX_DATA");
    await_completion(UART_VVCT, 1, RX,  12000 ns);
    await_completion(SBI_VVCT,1,  12000 ns);
    wait for 10*C_BIT_PERIOD;  -- margin

    -- Testing that the UART TX buffer works correctly
    log("Testing uart_expect with more occurrences");
    uart_expect(UART_VVCT, 1, RX,  x"bb", "Expecting TX data", 17, 0 ns);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"01", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"02", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"03", "TX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4);
    insert_delay(SBI_VVCT,1,20000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"04", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"05", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"06", "TX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4 + 20000 ns);
    insert_delay(SBI_VVCT,1,6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"07", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"08", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"09", "TX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4);
    insert_delay(SBI_VVCT,1,6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"0A", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"0B", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"0C", "TX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4);
    insert_delay(SBI_VVCT,1,6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"0D", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"0E", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"0F", "TX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4);
    insert_delay(SBI_VVCT,1,6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"bb", "TX_DATA");
    await_completion(SBI_VVCT,1,  6000 ns + 13 * C_BIT_PERIOD*2);
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD*2);
    wait for 10*C_BIT_PERIOD;  -- margin

    log("Test detection of parity error");
    -- Configure VVC to expect the opposite parity
    shared_uart_vvc_config(RX,1).bfm_config.parity := PARITY_EVEN;
    increment_expected_alerts(ERROR);

    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"56", "TX_DATA");
    uart_expect(UART_VVCT, 1, RX,  x"56", "Expecting TX data");
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
    wait for 10*C_BIT_PERIOD;  -- margin

    -- Cleanup after test
    shared_uart_vvc_config(RX,1).bfm_config.parity := PARITY_ODD;



    log(ID_LOG_HDR, "Test of reading executor status");
    ------------------------------------------------------------

    log("current_cmd_idx: " & to_string(shared_uart_vvc_status(RX, 1).current_cmd_idx));
    log("previous_cmd_idx: " & to_string(shared_uart_vvc_status(RX, 1).previous_cmd_idx));
    log("pending_cmd_cnt: " & to_string(shared_uart_vvc_status(RX, 1).pending_cmd_cnt));

    log("current_cmd_idx: " & to_string(shared_uart_vvc_status(TX, 1).current_cmd_idx));
    log("previous_cmd_idx: " & to_string(shared_uart_vvc_status(TX, 1).previous_cmd_idx));
    log("pending_cmd_cnt: " & to_string(shared_uart_vvc_status(TX, 1).pending_cmd_cnt));


    log(ID_LOG_HDR, "Test of advanced uart_expect() with expected errors", C_SCOPE);
    ------------------------------------------------------------

    log("Testing uart_expect with wrong data and one occurence. The wrong data received shall be printed in error message when only expecting one occurance.");
    increment_expected_alerts(ERROR);
    uart_expect(UART_VVCT, 1, RX,  x"32", "Provoking failure by expecting wrong data.", 1, 0 ns, ERROR);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"31", "TX_DATA");
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD*2);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*2);
    wait for 10*C_BIT_PERIOD;  -- margin

    log("Testing uart_expect with too many occurrences before expected data");
    increment_expected_alerts(ERROR);
    uart_expect(UART_VVCT, 1, RX,  x"42", "Provoking failure due to too many occurrences before expected data", 2, 0 ns, ERROR);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"ab", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"ee", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"42", "TX_DATA");
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD*4);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD*4);
    wait for 10*C_BIT_PERIOD;  -- margin

    log("Testing uart_expect with delay and timeout error");
    increment_expected_alerts(ERROR);  -- Will result in failure ERROR in uart_expect()
    uart_expect(UART_VVCT, 1, RX,  x"af", "Provoking failure due to timeout", 0, 4000 ns);
    wait for 6000 ns;
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"af", "TX_DATA");
    await_completion(UART_VVCT, 1, RX,  10000 ns);
    await_completion(SBI_VVCT,1,  10000 ns);
    wait for 10*C_BIT_PERIOD;  -- margin

    log("Testing error due to timeout=0 and max_receptions=0");
    increment_expected_alerts(ERROR);
    uart_expect(UART_VVCT, 1, RX,  x"01", "Provoking failure due to timeout", 0, 0 ns, ERROR);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"01", "TX_DATA"); -- resetting
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
    wait for 10*C_BIT_PERIOD;  -- margin


    log(ID_LOG_HDR, "Testing Terminate function");
    ------------------------------------------------------------
    increment_expected_alerts(WARNING);
    uart_expect(UART_VVCT, 1, RX,  x"01", "Expecting value, and then terminating", 5, 10000 ns, ERROR);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"07", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"f1", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"aa", "TX_DATA");
    await_completion(SBI_VVCT,1,  50 * C_BIT_PERIOD);
    terminate_current_command(UART_VVCT,1,RX);
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD);
    wait for 100*C_BIT_PERIOD;  -- margin

    log("Check that terminate flag has been reset");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"55", "TX_DATA");
    uart_expect(UART_VVCT, 1, RX,  x"55", "Expecting TX data");
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD);
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
    wait for 10*C_BIT_PERIOD;  -- margin

    log(ID_LOG_HDR, "Check that commands are distributed to the correct VVC channel");
    -- Calling an invalid channel will yield a TB_WARNING from each of the UART channels
    -- We will also get another TB_WARNING from the timeout, related to having more decimals in the log time than we can display
    increment_expected_alerts(TB_WARNING,5);
    -- Calling an invalid channel will also cause a timeout, since the target VVC does not exist. This results in an ERROR
    increment_expected_alerts(TB_ERROR,4);
    insert_delay(UART_VVCT, 1, C_BIT_PERIOD, "Inserting delay without specifying UART channel, expecting tb warning and tb error");
    insert_delay(UART_VVCT, 1, NA, C_BIT_PERIOD, "Inserting delay on NA UART channel, expecting tb warning and tb error");
    insert_delay(UART_VVCT, 5, TX, C_BIT_PERIOD, "Inserting delay on UART 5 TX channel, expecting tb error");
    insert_delay(UART_VVCT, 42, RX, C_BIT_PERIOD, "Inserting delay on UART 42 RX channel, expecting tb error");

    wait for 10*C_BIT_PERIOD;  -- margin


    log(ID_LOG_HDR, "Check of sending command to both channels", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT,1,TX, x"AA", "Testing UART TX");
    uart_transmit(UART_VVCT,1,TX, x"AB", "Testing UART TX");
    uart_transmit(UART_VVCT,1,TX, x"AC", "Testing UART TX");

    uart_expect(UART_VVCT, 1, RX,  x"42", "Expecting TX data", 4, 0 ns);
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"ab", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"ee", "TX_DATA");
    sbi_write(SBI_VVCT,1, C_ADDR_TX_DATA, x"42", "TX_DATA");

    await_completion(UART_VVCT,1,ALL_CHANNELS, 40 * C_BIT_PERIOD);
    check_value(shared_uart_vvc_status(TX,1).pending_cmd_cnt, 0, ERROR, "Checking that UART TX has no pending commands after await_completion", C_SCOPE, ID_SEQUENCER);
    check_value(shared_uart_vvc_status(RX,1).pending_cmd_cnt, 0, ERROR, "Checking that UART RX has no pending commands after await_completion", C_SCOPE, ID_SEQUENCER);
    log("Both channels have now completed.");


    log(ID_LOG_HDR, "Testing inter-bfm delay");

    log("\rChecking TIME_START2START");
    wait for C_BIT_PERIOD * 51;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_type := TIME_START2START;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_in_time := C_BIT_PERIOD * 50;
    v_timestamp := now;
    uart_transmit(UART_VVCT,1,TX,  x"AA", "First transmit with UART TX");
    uart_transmit(UART_VVCT,1,TX,  x"BB", "Second transmit with UART TX");
    await_completion(UART_VVCT, 1, TX, (50 * C_BIT_PERIOD)+(11* C_BIT_PERIOD) + (C_CLK_PERIOD));
    check_value(((now - v_timestamp) = ((50 * C_BIT_PERIOD)+(11* C_BIT_PERIOD))), ERROR, "Checking that inter-bfm delay was upheld");

    --log("\rChecking that insert_delay does not affect inter-BFM delay");
    log("\rChecking that insert_delay is added to inter-BFM delay");
    wait for C_BIT_PERIOD * 51;
    v_timestamp := now;
    uart_transmit(UART_VVCT,1,TX,  x"CC", "Third transmit with UART TX");
    insert_delay(UART_VVCT,1, TX, C_BIT_PERIOD);
    insert_delay(UART_VVCT,1, TX, C_BIT_PERIOD);
    uart_transmit(UART_VVCT,1,TX,  x"DD", "Fourth transmit with UART TX");
    await_completion(UART_VVCT, 1, TX, (50 * C_BIT_PERIOD)+(12* C_BIT_PERIOD*2) + (C_CLK_PERIOD) + (2*C_BIT_PERIOD));
    check_value(((now - v_timestamp) = ((50 * C_BIT_PERIOD)+(11* C_BIT_PERIOD) + (2*C_BIT_PERIOD))), ERROR, "Checking that inter-bfm delay and insert_delay was added");


    log("\rChecking TIME_FINISH2START");
    wait for C_BIT_PERIOD * 101;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_type := TIME_FINISH2START;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_in_time := C_BIT_PERIOD * 100;
    v_timestamp := now;
    uart_transmit(UART_VVCT,1,TX,  x"EE", "First transmit with UART TX");
    uart_transmit(UART_VVCT,1,TX,  x"FF", "Second transmit with UART TX");
    await_completion(UART_VVCT, 1, TX, (100 * C_BIT_PERIOD)+(12* C_BIT_PERIOD*2) + (C_CLK_PERIOD));
    check_value(((now - v_timestamp) >= ((100 * C_BIT_PERIOD)+(11* C_BIT_PERIOD))), ERROR, "Checking that inter-bfm delay was upheld");


    log("\rChecking TIME_START2START and provoking inter-bfm delay violation");
    wait for C_CLK_PERIOD * 10;
    increment_expected_alerts(TB_WARNING,2);
    shared_uart_vvc_config(TX,1).inter_bfm_delay.inter_bfm_delay_violation_severity := TB_WARNING;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_type := TIME_START2START;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_in_time := C_BIT_PERIOD*2;
    uart_transmit(UART_VVCT,1,TX,  x"EE", "First transmit with UART TX");
    uart_transmit(UART_VVCT,1,TX,  x"FF", "Second transmit with UART TX");
    await_completion(UART_VVCT, 1, TX, (100 * C_BIT_PERIOD)+(12* C_BIT_PERIOD*2) + (C_CLK_PERIOD));


    log("Setting delay back to initial value");
    shared_uart_vvc_config(TX,1).inter_bfm_delay.inter_bfm_delay_violation_severity := WARNING;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_type := NO_DELAY;
    shared_uart_vvc_config(TX,1).inter_bfm_delay.delay_in_time := 0 ns;

    log(ID_LOG_HDR, "Provoke TB_ERROR with timeout shorter than or equal length of transfer time.");
    -- Generate timeout 1 ns shorter than transfer time
    v_timeout := (shared_uart_vvc_config(RX,1).bfm_config.num_data_bits + 2) * shared_uart_vvc_config(RX,1).bfm_config.bit_time;
    if shared_uart_vvc_config(RX,1).bfm_config.parity = PARITY_ODD or shared_uart_vvc_config(RX,1).bfm_config.parity = PARITY_EVEN then
      v_timeout := v_timeout + shared_uart_vvc_config(RX,1).bfm_config.bit_time;
    end if;
    if shared_uart_vvc_config(RX,1).bfm_config.num_stop_bits = STOP_BITS_ONE_AND_HALF then
      v_timeout := v_timeout + shared_uart_vvc_config(RX,1).bfm_config.bit_time/2;
    elsif shared_uart_vvc_config(RX,1).bfm_config.num_stop_bits = STOP_BITS_TWO then
      v_timeout := v_timeout + shared_uart_vvc_config(RX,1).bfm_config.bit_time;
    end if;
    v_timeout := v_timeout;
    log("Setting config.timeout to transfer time (" & to_string(v_timeout) & "). Expecting TB_ERROR from BFM and ERROR from VVC.");
    shared_uart_vvc_config(RX,1).bfm_config.timeout := v_timeout;
    increment_expected_alerts(TB_ERROR);
    increment_expected_alerts(ERROR);
    uart_receive(UART_VVCT, 1, RX, "Receive inside VVC", ERROR);
    await_completion(UART_VVCT, 1, RX,  13 * C_BIT_PERIOD);

    -- Cleanup after test
    shared_uart_vvc_config(RX,1).bfm_config.timeout := 0 ns;


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

end func;
