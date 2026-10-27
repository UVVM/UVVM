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

library bitvis_uart;
use bitvis_uart.uart_pif_pkg.all;


--hdlregression:tb
-- Test case entity
entity uart_vvc_tb is
  generic(
    GC_TESTCASE   : string                := "UVVM";
    GC_DATA_WIDTH : natural range 5 to C_UART_MAX_DATA_WIDTH := 8 -- range 5-9 bits
  );
end entity;

-- Test case architecture
architecture func of uart_vvc_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD; -- default in design and BFM

  -- start bit + GC_DATA_WIDTH data bits + parity + stop bit = N+3 bit periods.
  constant C_TIME_OF_ONE_UART_TX : time := (GC_DATA_WIDTH + 3) * C_BIT_PERIOD;

  -- await_completion timeout for one UART frame: frame time + 2 bit periods margin.
  constant C_FRAME_TIMEOUT       : time := C_TIME_OF_ONE_UART_TX + 2 * C_BIT_PERIOD;

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  constant C_ADDR_RX_DATA       : unsigned(3 downto 0) := x"0";
  constant C_ADDR_RX_DATA_VALID : unsigned(3 downto 0) := x"1";
  constant C_ADDR_TX_DATA       : unsigned(3 downto 0) := x"2";
  constant C_ADDR_TX_READY      : unsigned(3 downto 0) := x"3";
  constant C_ADDR_NUM_DATA_BITS : unsigned(3 downto 0) := x"4";

  -- Width-mask a natural to GC_DATA_WIDTH bits. For uart_transmit/expect/receive payloads.
  function uart_data(value : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(value mod (2 ** GC_DATA_WIDTH), GC_DATA_WIDTH));
  end function;

  -- Zero-extend to C_MAX_NUM_DATA_BITS. For sbi_write/check of C_ADDR_TX_DATA / C_ADDR_RX_DATA.
  function sbi_data(value : natural) return std_logic_vector is
  begin
    return std_logic_vector(resize(unsigned(uart_data(value)), C_MAX_NUM_DATA_BITS));
  end function;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uart_vvc_th;

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_received_data : bitvis_vip_uart.vvc_cmd_pkg.t_vvc_result;
    variable v_cmd_idx       : natural;
    variable v_is_ok         : boolean;
    variable v_timestamp     : time;
    variable v_timeout       : time;
    variable v_alert_config   : t_uart_unwanted_transaction;
    -- VHDL has no inline declare/begin/end for sequential statements; hoisted
    -- to process scope. Read by the runtime num_data_bits switching block.
    variable v_run_width     : natural;

    -- DUT ports towards VVC interface
    alias dut_tx is << signal i_test_harness.i_uart.tx : std_logic >>;

    -- Toggles all the signals in the VVC interface and checks that the expected alerts are generated
    procedure toggle_vvc_if (
      constant alert_config : in t_uart_unwanted_transaction
    ) is
      -- Alert counter array including NO_ALERT (ignored in checks) for easier indexing
      type t_alert_counters_arr is array(t_alert_level) of natural;
      variable v_expected_alert_counters : t_alert_counters_arr;
      variable v_rand                    : t_rand;
    begin
      -- Populate local alert counters
      for alert_level in v_expected_alert_counters'range loop
        v_expected_alert_counters(alert_level) := get_alert_counter(alert_level);
      end loop;
      -- Number of total expected alerts: 1 signal x 1 toggle
      if alert_config.uart_vvc_rx /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.uart_vvc_rx, 2);
      end if;
      -- Update expected alert counters
      v_expected_alert_counters(alert_config.uart_vvc_rx) := v_expected_alert_counters(alert_config.uart_vvc_rx) + 1;
      -- Force new value
      dut_tx <= force not dut_tx;
      wait for v_rand.rand(ONLY, (C_LOG_TIME_BASE, C_LOG_TIME_BASE * 5, C_LOG_TIME_BASE * 10)); -- Hold the value a random time
      -- Loop through all error levels (except NO_ALERT) and check with expected
      for alert_level in v_expected_alert_counters(NOTE to t_alert_level'right)'range loop
        check_value(get_alert_counter(alert_level), v_expected_alert_counters(alert_level), TB_NOTE, "Unwanted transaction alert was expected", C_SCOPE, ID_NEVER);
      end loop;
      -- Update expected alert counters
      v_expected_alert_counters(alert_config.uart_vvc_rx) := v_expected_alert_counters(alert_config.uart_vvc_rx) + 1;
      -- Set back original value
      dut_tx <= release;
      wait for 0 ns; -- Wait two delta cycles so that the alert is triggered
      wait for 0 ns;
      wait for 0 ns; -- Wait another cycle to allow signals to propagate before checking them - Needed for Riviera Pro
      -- Loop through all error levels (except NO_ALERT) and check with expected
      for alert_level in v_expected_alert_counters(NOTE to t_alert_level'right)'range loop
        check_value(get_alert_counter(alert_level), v_expected_alert_counters(alert_level), TB_NOTE, "Unwanted transaction alert was expected", C_SCOPE, ID_NEVER);
      end loop;

      -- Test ignored transitions ('U'->'X', 'U'->'Z', 'U'->'W', 'U'->'H', 'U'->'1', '1'->'H', 'H'->'1', 'X'->'0', 'X'->'1')
      wait for C_CLK_PERIOD;
      if alert_config.uart_vvc_rx /= NO_ALERT then
        increment_expected_alerts_and_stop_limit(alert_config.uart_vvc_rx, 7);
      end if;
      dut_tx <= force 'U';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'X';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'U';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'Z';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'U';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'W';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'U';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'H';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'U';
      wait for C_CLK_PERIOD;
      dut_tx <= force '1';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'H';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'X';
      wait for C_CLK_PERIOD;
      dut_tx <= force '0';
      wait for C_CLK_PERIOD;
      dut_tx <= force 'X';
      wait for C_CLK_PERIOD;
      dut_tx <= release;
      wait for C_CLK_PERIOD;
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_" & to_string(GC_DATA_WIDTH) & "bit_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_" & to_string(GC_DATA_WIDTH) & "bit_Alert.txt");

    await_uvvm_initialization(VOID);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UTIL_SETUP);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, 1, ID_BFM);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM_WAIT);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM_POLL);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM_POLL_SUMMARY);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM_WAIT);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM_POLL);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM_POLL_SUMMARY);

    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(TX, 1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(RX, 1).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Start Test of UART VIP", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off

    -- Apply GC_DATA_WIDTH to DUT (NUM_DATA_BITS register) and BFM config after
    -- reset has settled. Per-width coverage is driven by the script-side
    -- matrix (test.py).
    shared_uart_vvc_config(TX, 1).bfm_config.num_data_bits := GC_DATA_WIDTH;
    shared_uart_vvc_config(RX, 1).bfm_config.num_data_bits := GC_DATA_WIDTH;
    sbi_write(SBI_VVCT, 1, C_ADDR_NUM_DATA_BITS,
              std_logic_vector(to_unsigned(GC_DATA_WIDTH, C_UART_MAX_DATA_WIDTH)),
              "NUM_DATA_BITS = " & to_string(GC_DATA_WIDTH));
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
    ------------------------------------------------------------
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default", ERROR);
    sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default", ERROR);
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default", ERROR);
    await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);

    log(ID_LOG_HDR, "Check of uart_transmit()", C_SCOPE);
    ------------------------------------------------------------
    -- Literal x"AA" is masked to GC_DATA_WIDTH.
    -- The 9-bit SBI compare image is zero-extended to C_UART_MAX_DATA_WIDTH.
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#AA#),
                  "Testing UART TX");
    await_completion(UART_VVCT, 1, TX, C_FRAME_TIMEOUT);
    wait for 200 ns;                    -- margin
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA,
              sbi_data(16#AA#),
              "RX_DATA ", ERROR);
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);

    log(ID_LOG_HDR, "Check of uart_expect() as simple, instant check", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#55#),
              "TX_DATA");
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#55#),
                "Expecting TX data");
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    log(ID_LOG_HDR, "Check of uart_receive()", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#56#),
              "TX_DATA");
    uart_receive(UART_VVCT, 1, RX, "Receive inside VVC", ERROR);
    v_cmd_idx := get_last_received_cmd_idx(UART_VVCT, 1, RX); -- for last read
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);

    fetch_result(UART_VVCT, 1, RX, v_cmd_idx, v_received_data, v_is_ok, "Fetching receive-result");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    -- v_received_data is the VVC's 9-bit result type; the BFM places the received
    -- frame in the low GC_DATA_WIDTH bits.
    check_value(v_received_data(GC_DATA_WIDTH - 1 downto 0),
                uart_data(16#56#),
                ERROR, "Readback data via fetch_result()");
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    log(ID_LOG_HDR, "Check of uart_receive() using Scoreboard", C_SCOPE);
    ------------------------------------------------------------
    -- SB image is 9-bit (C_UART_MAX_DATA_WIDTH) and matches the DUT's
    -- zero-extension into RX_DATA. Literal x"38" is masked to GC_DATA_WIDTH.
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#38#),
              "TX_DATA");
    uart_vvc_sb.add_expected(1, sbi_data(16#38#));
    uart_receive(UART_VVCT, 1, RX, TO_SB, "Receive inside VVC's SB", ERROR);
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    uart_vvc_sb.report_counters(ALL_INSTANCES);

    log(ID_LOG_HDR, "Test of advanced uart_expect()", C_SCOPE);
    ------------------------------------------------------------
    log("Testing uart_expect with multiple occurrences");
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#42#),
                "Expecting TX data", 4, 0 ns);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#AB#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#EE#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#42#),
              "TX_DATA");
    await_completion(UART_VVCT, 1, RX, 4 * (C_FRAME_TIMEOUT));
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT));
    wait for 10 * C_BIT_PERIOD;         -- margin

    log("Testing uart_expect with delay");
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#AF#),
                "Expecting TX data", 0, 10000 ns);
    wait for 6000 ns;
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#AF#),
              "TX_DATA");
    await_completion(UART_VVCT, 1, RX, 12000 ns);
    await_completion(SBI_VVCT, 1, 12000 ns);
    wait for 10 * C_BIT_PERIOD;         -- margin

    -- Testing that the UART TX buffer works correctly.
    -- NOTE: literals 0x01..0x0F are width-masked when GC_DATA_WIDTH < 5; at
    -- GC_DATA_WIDTH >= 5 they all fit. The test validates the BFM byte-stream
    -- contract (number, ordering, occurrence counts), not specific numeric
    -- values, so the N-write structure is kept identical across widths.
    log("Testing uart_expect with more occurrences");
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#BB#),
                "Expecting TX data", 17, 0 ns);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#01#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#02#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#03#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT));
    insert_delay(SBI_VVCT, 1, 20000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#04#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#05#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#06#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT) + 20000 ns);
    insert_delay(SBI_VVCT, 1, 6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#07#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#08#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#09#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT));
    insert_delay(SBI_VVCT, 1, 6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#0A#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#0B#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#0C#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT));
    insert_delay(SBI_VVCT, 1, 6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#0D#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#0E#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#0F#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT));
    insert_delay(SBI_VVCT, 1, 6000 ns, "Giving the DUT time to transmit");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#BB#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 6000 ns + 2 * (C_FRAME_TIMEOUT));
    await_completion(UART_VVCT, 1, RX, 2 * (C_FRAME_TIMEOUT));
    wait for 10 * C_BIT_PERIOD;         -- margin

    log("Test detection of parity error");
    -- Configure VVC to expect the opposite parity
    shared_uart_vvc_config(RX, 1).bfm_config.parity := PARITY_EVEN;
    increment_expected_alerts_and_stop_limit(ERROR);

    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#56#),
              "TX_DATA");
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#56#),
                "Expecting TX data");
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    -- Cleanup after test
    shared_uart_vvc_config(RX, 1).bfm_config.parity := PARITY_ODD;

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
    increment_expected_alerts_and_stop_limit(ERROR);
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#32#),
                "Provoking failure by expecting wrong data.", 1, 0 ns, ERROR);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#31#),
              "TX_DATA");
    await_completion(UART_VVCT, 1, RX, 2 * (C_FRAME_TIMEOUT));
    await_completion(SBI_VVCT, 1, 2 * (C_FRAME_TIMEOUT));
    wait for 10 * C_BIT_PERIOD;         -- margin

    log("Testing uart_expect with too many occurrences before expected data");
    increment_expected_alerts_and_stop_limit(ERROR);
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#42#),
                "Provoking failure due to too many occurrences before expected data", 2, 0 ns, ERROR);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#AB#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#EE#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#42#),
              "TX_DATA");
    shared_uart_vvc_config(RX, 1).unwanted_transaction_checking_enabled := false; -- Unwanted transaction errors due to activity on RX after timeout
    await_completion(UART_VVCT, 1, RX, 4 * (C_FRAME_TIMEOUT));
    await_completion(SBI_VVCT, 1, 4 * (C_FRAME_TIMEOUT));
    -- Drain time for the third DUT-queued TX frame; scales with GC_DATA_WIDTH.
    wait for C_FRAME_TIMEOUT;
    shared_uart_vvc_config(RX, 1).unwanted_transaction_checking_enabled := C_UART_VVC_CONFIG_DEFAULT.unwanted_transaction_checking_enabled;

    log("Testing uart_expect with delay and timeout error");
    increment_expected_alerts_and_stop_limit(ERROR);   -- Will result in failure ERROR in uart_expect()
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#AF#),
                "Provoking failure due to timeout", 0, 4000 ns);
    wait for 6000 ns;
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#AF#),
              "TX_DATA");
    shared_uart_vvc_config(RX, 1).unwanted_transaction_checking_enabled := false; -- Unwanted transaction errors due to activity on RX after timeout
    await_completion(UART_VVCT, 1, RX, 10000 ns);
    await_completion(SBI_VVCT, 1, 10000 ns);
    wait for 10 * C_BIT_PERIOD;         -- margin
    shared_uart_vvc_config(RX, 1).unwanted_transaction_checking_enabled := C_UART_VVC_CONFIG_DEFAULT.unwanted_transaction_checking_enabled;

    log("Testing error due to timeout=0 and max_receptions=0");
    increment_expected_alerts_and_stop_limit(ERROR);
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#01#),
                "Provoking failure due to timeout", 0, 0 ns, ERROR);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#01#),
              "TX_DATA"); -- resetting
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    log(ID_LOG_HDR, "Testing Terminate function");
    ------------------------------------------------------------
    increment_expected_alerts(WARNING);
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#01#),
                "Expecting value, and then terminating", 5, 10000 ns, ERROR);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#07#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#F1#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#AA#),
              "TX_DATA");
    await_completion(SBI_VVCT, 1, 50 * C_BIT_PERIOD);
    terminate_current_command(UART_VVCT, 1, RX);
    shared_uart_vvc_config(RX, 1).unwanted_transaction_checking_enabled := false; -- Unwanted transaction errors due to activity on RX after terminate command
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    wait for 100 * C_BIT_PERIOD;        -- margin
    shared_uart_vvc_config(RX, 1).unwanted_transaction_checking_enabled := C_UART_VVC_CONFIG_DEFAULT.unwanted_transaction_checking_enabled;

    log("Check that terminate flag has been reset");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#55#),
              "TX_DATA");
    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#55#),
                "Expecting TX data");
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);
    await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
    wait for 10 * C_BIT_PERIOD;         -- margin

    log(ID_LOG_HDR, "Check that commands are distributed to the correct VVC channel");
    -- Calling an invalid channel will yield a TB_WARNING from each of the UART channels
    increment_expected_alerts(TB_WARNING, 4);
    -- We will also get another TB_WARNING from the timeout, related to having more decimals in the log time than we can display
    increment_expected_alerts(TB_WARNING, 1);
    -- Calling an invalid channel will also cause a timeout, since the target VVC does not exist. This results in an ERROR
    increment_expected_alerts_and_stop_limit(TB_ERROR, 4);
    insert_delay(UART_VVCT, 1, C_BIT_PERIOD, "Inserting delay without specifying UART channel, expecting tb warning and tb error");
    insert_delay(UART_VVCT, 1, NA, C_BIT_PERIOD, "Inserting delay on NA UART channel, expecting tb warning and tb error");
    insert_delay(UART_VVCT, 5, TX, C_BIT_PERIOD, "Inserting delay on UART 5 TX channel, expecting tb error");
    insert_delay(UART_VVCT, 42, RX, C_BIT_PERIOD, "Inserting delay on UART 42 RX channel, expecting tb error");

    wait for 10 * C_BIT_PERIOD;         -- margin

    log(ID_LOG_HDR, "Check of sending command to both channels", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#AA#),
                  "Testing UART TX");
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#AB#),
                  "Testing UART TX");
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#AC#),
                  "Testing UART TX");

    uart_expect(UART_VVCT, 1, RX,
                uart_data(16#42#),
                "Expecting TX data", 4, 0 ns);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#AB#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#EE#),
              "TX_DATA");
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
              sbi_data(16#42#),
              "TX_DATA");

    -- 40 bit periods covers 4 max-width frames in the original 8-bit form.
    -- Scale by N+3 / 11 ratio: 4 * (C_FRAME_TIMEOUT)
    -- gives the same headroom for any GC_DATA_WIDTH.
    await_completion(UART_VVCT, 1, ALL_CHANNELS, 4 * (C_FRAME_TIMEOUT));
    check_value(shared_uart_vvc_status(TX, 1).pending_cmd_cnt, 0, ERROR, "Checking that UART TX has no pending commands after await_completion", C_SCOPE, ID_SEQUENCER);
    check_value(shared_uart_vvc_status(RX, 1).pending_cmd_cnt, 0, ERROR, "Checking that UART RX has no pending commands after await_completion", C_SCOPE, ID_SEQUENCER);
    log("Both channels have now completed.");

    if GC_DATA_WIDTH = 9 then
      log(ID_LOG_HDR, "Directed 9-bit bit-8 coverage", C_SCOPE);
      ------------------------------------------------------------
      -- Values below 0x100 never toggle bit 8, so a stuck-low/dropped bit 8
      -- would escape every other test in this TB. Only run at width 9.
      --
      -- Drain the DUT RX FIFO first: the preceding "Check of sending command
      -- to both channels" block transmits 0xAA, 0xAB, 0xAC into the DUT
      -- without reading them back, so the first sbi_check below would
      -- otherwise see leftover 0xAA.
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#AA#), "RX_DATA drain leftover 0xAA", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#AB#), "RX_DATA drain leftover 0xAB", ERROR);
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#AC#), "RX_DATA drain leftover 0xAC", ERROR);
      await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
      for v in 0 to 4 loop
        -- 0x100, 0x101, 0x155, 0x1AA, 0x1FF -- bit 8 = '1' in each.
        case v is
          when 0 => uart_transmit(UART_VVCT, 1, TX, uart_data(16#100#), "Bit-8 directed 0x100");
          when 1 => uart_transmit(UART_VVCT, 1, TX, uart_data(16#101#), "Bit-8 directed 0x101");
          when 2 => uart_transmit(UART_VVCT, 1, TX, uart_data(16#155#), "Bit-8 directed 0x155");
          when 3 => uart_transmit(UART_VVCT, 1, TX, uart_data(16#1AA#), "Bit-8 directed 0x1AA");
          when 4 => uart_transmit(UART_VVCT, 1, TX, uart_data(16#1FF#), "Bit-8 directed 0x1FF");
        end case;
        await_completion(UART_VVCT, 1, TX, C_FRAME_TIMEOUT);
        wait for 200 ns;                  -- margin
        case v is
          when 0 => sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#100#), "RX_DATA bit-8 directed 0x100", ERROR);
          when 1 => sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#101#), "RX_DATA bit-8 directed 0x101", ERROR);
          when 2 => sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#155#), "RX_DATA bit-8 directed 0x155", ERROR);
          when 3 => sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#1AA#), "RX_DATA bit-8 directed 0x1AA", ERROR);
          when 4 => sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, sbi_data(16#1FF#), "RX_DATA bit-8 directed 0x1FF", ERROR);
        end case;
        await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
      end loop;
    end if;

    if GC_DATA_WIDTH = 9 then
      log(ID_LOG_HDR, "Runtime NUM_DATA_BITS switching coverage", C_SCOPE);
      ------------------------------------------------------------
      -- The script-side matrix runs each width from a fresh init, so the
      -- reconfigure-mid-sim path (8 -> 9 -> 5 -> 9) is only covered here.
      -- Restricted to GC_DATA_WIDTH=9 so the executor's static arrays are
      -- sized to the max reachable runtime width.
      for w in 0 to 3 loop
        case w is
          when 0 => v_run_width := 8;
          when 1 => v_run_width := 9;
          when 2 => v_run_width := 5;
          when 3 => v_run_width := 9;
        end case;
        log(ID_SEQUENCER, "Switching num_data_bits to " & to_string(v_run_width), C_SCOPE);
        shared_uart_vvc_config(TX, 1).bfm_config.num_data_bits := v_run_width;
        shared_uart_vvc_config(RX, 1).bfm_config.num_data_bits := v_run_width;
        sbi_write(SBI_VVCT, 1, C_ADDR_NUM_DATA_BITS,
                  std_logic_vector(to_unsigned(v_run_width, C_UART_MAX_DATA_WIDTH)),
                  "NUM_DATA_BITS = " & to_string(v_run_width));
        await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
        uart_transmit(UART_VVCT, 1, TX,
                      std_logic_vector(to_unsigned(16#55# mod (2 ** v_run_width), v_run_width)),
                      "Runtime-switch TX at width " & to_string(v_run_width));
        await_completion(UART_VVCT, 1, TX, (v_run_width + 5) * C_BIT_PERIOD);
        wait for 200 ns;                  -- margin
        sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA,
                  std_logic_vector(resize(to_unsigned(16#55# mod (2 ** v_run_width), v_run_width), C_UART_MAX_DATA_WIDTH)),
                  "RX_DATA at width " & to_string(v_run_width), ERROR);
        await_completion(SBI_VVCT, 1, (v_run_width + 5) * C_BIT_PERIOD);
      end loop;
      -- Restore to GC_DATA_WIDTH for the remaining tests.
      shared_uart_vvc_config(TX, 1).bfm_config.num_data_bits := GC_DATA_WIDTH;
      shared_uart_vvc_config(RX, 1).bfm_config.num_data_bits := GC_DATA_WIDTH;
      sbi_write(SBI_VVCT, 1, C_ADDR_NUM_DATA_BITS,
                std_logic_vector(to_unsigned(GC_DATA_WIDTH, C_UART_MAX_DATA_WIDTH)),
                "NUM_DATA_BITS restored = " & to_string(GC_DATA_WIDTH));
      await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
    end if;

    log(ID_LOG_HDR, "Testing inter-bfm delay");

    log("\rChecking TIME_START2START");
    wait for C_BIT_PERIOD * 51;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_type    := TIME_START2START;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_in_time := C_BIT_PERIOD * 50;
    v_timestamp                                                 := now;
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#AA#),
                  "First transmit with UART TX");
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#BB#),
                  "Second transmit with UART TX");
    -- Inter-bfm delay = 50 bit periods (start-to-start). Second frame must
    -- complete within delay + one frame time + one clock period.
    await_completion(UART_VVCT, 1, TX, (50 * C_BIT_PERIOD) + C_TIME_OF_ONE_UART_TX + C_CLK_PERIOD);
    check_value(((now - v_timestamp) = ((50 * C_BIT_PERIOD) + C_TIME_OF_ONE_UART_TX)), ERROR, "Checking that inter-bfm delay was upheld");

    --log("\rChecking that insert_delay does not affect inter-BFM delay");
    log("\rChecking that insert_delay is added to inter-BFM delay");
    wait for C_BIT_PERIOD * 51;
    v_timestamp := now;
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#CC#),
                  "Third transmit with UART TX");
    insert_delay(UART_VVCT, 1, TX, C_BIT_PERIOD);
    insert_delay(UART_VVCT, 1, TX, C_BIT_PERIOD);
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#DD#),
                  "Fourth transmit with UART TX");
    -- Timeout: 50 bit-periods inter-bfm + 2 frames + 2-bit insert delay + 1 clock period.
    await_completion(UART_VVCT, 1, TX, (50 * C_BIT_PERIOD) + 2 * (C_TIME_OF_ONE_UART_TX + C_BIT_PERIOD) + (2 * C_BIT_PERIOD) + C_CLK_PERIOD);
    check_value(((now - v_timestamp) = ((50 * C_BIT_PERIOD) + C_TIME_OF_ONE_UART_TX + (2 * C_BIT_PERIOD))), ERROR, "Checking that inter-bfm delay and insert_delay was added");

    log("\rChecking TIME_FINISH2START");
    wait for C_BIT_PERIOD * 101;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_type    := TIME_FINISH2START;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_in_time := C_BIT_PERIOD * 100;
    v_timestamp                                                 := now;
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#EE#),
                  "First transmit with UART TX");
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#FF#),
                  "Second transmit with UART TX");
    await_completion(UART_VVCT, 1, TX, (100 * C_BIT_PERIOD) + 2 * (C_TIME_OF_ONE_UART_TX + C_BIT_PERIOD) + C_CLK_PERIOD);
    check_value(((now - v_timestamp) >= ((100 * C_BIT_PERIOD) + C_TIME_OF_ONE_UART_TX)), ERROR, "Checking that inter-bfm delay was upheld");

    log("\rChecking TIME_START2START and provoking inter-bfm delay violation");
    wait for C_CLK_PERIOD * 10;
    increment_expected_alerts(TB_WARNING, 2);
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.inter_bfm_delay_violation_severity := TB_WARNING;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_type                         := TIME_START2START;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_in_time                      := C_BIT_PERIOD * 2;
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#EE#),
                  "First transmit with UART TX");
    uart_transmit(UART_VVCT, 1, TX,
                  uart_data(16#FF#),
                  "Second transmit with UART TX");
    await_completion(UART_VVCT, 1, TX, (100 * C_BIT_PERIOD) + 2 * (C_TIME_OF_ONE_UART_TX + C_BIT_PERIOD) + C_CLK_PERIOD);

    log("Setting delay back to initial value");
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.inter_bfm_delay_violation_severity := WARNING;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_type                         := NO_DELAY;
    shared_uart_vvc_config(TX, 1).inter_bfm_delay.delay_in_time                      := 0 ns;

    log(ID_LOG_HDR, "Provoke TB_ERROR with timeout shorter than or equal length of transfer time.");
    -- Generate timeout 1 ns shorter than transfer time
    v_timeout                                        := (shared_uart_vvc_config(RX, 1).bfm_config.num_data_bits + 2) * shared_uart_vvc_config(RX, 1).bfm_config.bit_time;
    if shared_uart_vvc_config(RX, 1).bfm_config.parity = PARITY_ODD or shared_uart_vvc_config(RX, 1).bfm_config.parity = PARITY_EVEN then
      v_timeout := v_timeout + shared_uart_vvc_config(RX, 1).bfm_config.bit_time;
    end if;
    if shared_uart_vvc_config(RX, 1).bfm_config.num_stop_bits = STOP_BITS_ONE_AND_HALF then
      v_timeout := v_timeout + shared_uart_vvc_config(RX, 1).bfm_config.bit_time / 2;
    elsif shared_uart_vvc_config(RX, 1).bfm_config.num_stop_bits = STOP_BITS_TWO then
      v_timeout := v_timeout + shared_uart_vvc_config(RX, 1).bfm_config.bit_time;
    end if;
    v_timeout                                        := v_timeout;
    log("Setting config.timeout to transfer time (" & to_string(v_timeout) & "). Expecting TB_ERROR from BFM and ERROR from VVC.");
    shared_uart_vvc_config(RX, 1).bfm_config.timeout := v_timeout;
    increment_expected_alerts_and_stop_limit(TB_ERROR);
    increment_expected_alerts_and_stop_limit(ERROR);
    uart_receive(UART_VVCT, 1, RX, "Receive inside VVC", ERROR);
    await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);

    -- Cleanup after test
    shared_uart_vvc_config(RX, 1).bfm_config.timeout := 0 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR, "Testing Unwanted Transaction Detection in VVC", C_SCOPE);
    ------------------------------------------------------------------------------------------------------------------------------
    for i in 0 to 3 loop
      -- Test different alert severity configurations
      if i = 0 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to default");
        v_alert_config := C_UART_VVC_CONFIG_DEFAULT.unwanted_transaction_severity;
      elsif i = 1 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to ERROR");
        v_alert_config := (others => ERROR);
      elsif i = 2 then
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to FAILURE");
        v_alert_config := (others => FAILURE);
      else
        log(ID_SEQUENCER, "Setting unwanted_transaction_severity to NO_ALERT");
        v_alert_config := (others => NO_ALERT);
      end if;
      shared_uart_vvc_config(RX, 1).unwanted_transaction_severity := v_alert_config;

      log(ID_SEQUENCER, "Testing normal data transmission", C_SCOPE);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
                sbi_data(16#55#),
                "Transmit data");
      uart_expect(UART_VVCT, 1, RX,
                  uart_data(16#55#),
                  "Expect data");
      await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);

      -- Test with and without a time gap between await_completion and unexpected data transmission
      if i = 0 then
        log(ID_SEQUENCER, "Wait 100 ns", C_SCOPE);
        wait for 100 ns;
      end if;

      log(ID_SEQUENCER, "Testing unexpected data transmission", C_SCOPE);
      toggle_vvc_if(v_alert_config);
    end loop;

    if GC_DATA_WIDTH = C_UART_MAX_DATA_WIDTH then
      ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing unwanted transaction detection for a 9-bit frame", C_SCOPE);
      ------------------------------------------------------------------------------------------------------------------------------
      for i in 0 to 2 loop
        -- Test different alert severity configurations
        if i = 0 then
          log(ID_SEQUENCER, "Setting unwanted_transaction_severity to default");
          v_alert_config := C_UART_VVC_CONFIG_DEFAULT.unwanted_transaction_severity;
          increment_expected_alerts_and_stop_limit(ERROR, 12);
        elsif i = 1 then
          log(ID_SEQUENCER, "Setting unwanted_transaction_severity to FAILURE");
          v_alert_config := (others => FAILURE);
          increment_expected_alerts_and_stop_limit(FAILURE, 12);
        else
          log(ID_SEQUENCER, "Setting unwanted_transaction_severity to NO_ALERT");
          v_alert_config := (others => NO_ALERT);
        end if;
        shared_uart_vvc_config(RX, 1).unwanted_transaction_severity := v_alert_config;

        log(ID_SEQUENCER, "Testing normal 9-bit data transmission", C_SCOPE);
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
                  sbi_data(16#155#),
                  "Transmit 9-bit data");
        uart_expect(UART_VVCT, 1, RX,
                    uart_data(16#155#),
                    "Expect 9-bit data");
        await_completion(UART_VVCT, 1, RX, C_FRAME_TIMEOUT);

        log(ID_SEQUENCER, "Testing unexpected 9-bit data transmission", C_SCOPE);
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA,
                  sbi_data(16#155#),
                  "Transmit 9-bit data");
        await_completion(SBI_VVCT, 1, C_FRAME_TIMEOUT);
        wait for C_FRAME_TIMEOUT;
      end loop;
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(1000 ns, print_alert_counters => REPORT_ALERT_COUNTERS_FINAL, scope => C_SCOPE);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
