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

use work.uart_transaction_sb_pkg.all;
use work.monitor_cmd_pkg.all;

--hdlregression:tb
-- Test case entity
entity uart_monitor_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of uart_monitor_tb is

  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD; -- default in design and BFM

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  constant C_ADDR_RX_DATA       : unsigned(3 downto 0) := x"0";
  constant C_ADDR_RX_DATA_VALID : unsigned(3 downto 0) := x"1";
  constant C_ADDR_TX_DATA       : unsigned(3 downto 0) := x"2";
  constant C_ADDR_TX_READY      : unsigned(3 downto 0) := x"3";

  shared variable tx_uart_monitor_sb : work.uart_transaction_sb_pkg.t_generic_sb;
  shared variable rx_uart_monitor_sb : work.uart_transaction_sb_pkg.t_generic_sb;

  procedure check_transaction(
    constant transaction      : in t_uart_transaction;
    constant operation        : in t_uart_operation;
    constant data             : in std_logic_vector;
    constant parity_bit_error : in boolean;
    constant stop_bit_error   : in boolean;
    constant scope            : in string
  ) is
    variable check_ok : boolean_vector(0 to 3);
  begin
    check_ok(0) := check_value(transaction.operation = operation, ERROR, "Check operation");
    check_ok(1) := check_value(transaction.data, data, ERROR, "Check data");
    check_ok(2) := check_value(transaction.error_info.parity_bit_error, parity_bit_error, ERROR, "Check parity_bit_error");
    check_ok(3) := check_value(transaction.error_info.stop_bit_error, stop_bit_error, ERROR, "Check stop_bit_error");

    if and(check_ok) then
      log(ID_SEQUENCER_SUB, "Monitor transaction read: OK", scope);
    else
      log(ID_SEQUENCER_SUB, "Monitor transaction read: ERROR", scope);
    end if;
  end procedure check_transaction;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uart_monitor_th;

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- Helper variables
    variable v_received_data    : bitvis_vip_uart.vvc_cmd_pkg.t_vvc_result;
    variable v_cmd_idx          : natural;
    variable v_is_ok            : boolean;
    variable v_timestamp        : time;
    variable v_timeout          : time;
    variable v_data_tx          : std_logic_vector(7 downto 0);
    variable v_data_rx          : std_logic_vector(7 downto 0);
    variable v_uart_transaction : t_uart_transaction;

    variable v_alert_num_mismatch : boolean := false;

    function get_uart_transaction_info(
      constant operation        : in t_uart_operation;
      constant data             : in std_logic_vector(7 downto 0);
      constant parity_bit_error : in boolean := false;
      constant stop_bit_error   : in boolean := false
    ) return t_uart_transaction is
      variable v_uart_transaction : t_uart_transaction := C_UART_TRANSACTION_INFO_SET_DEFAULT;
    begin
      v_uart_transaction.operation  := operation;
      v_uart_transaction.data       := data;
      v_uart_transaction.error_info := (parity_bit_error => parity_bit_error,
                                        stop_bit_error   => stop_bit_error);
      return v_uart_transaction;
    end function get_uart_transaction_info;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    await_uvvm_initialization(VOID);

    --set_alert_stop_limit(ERROR,1);
    --set_alert_stop_limit(TB_ERROR,6);
    --set_alert_stop_limit(FAILURE,2);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_SEQUENCER_SUB);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT,1,  ID_BFM);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    --enable_log_msg(UART_VVCT,1,RX,  ID_BFM);
    --enable_log_msg(UART_VVCT,1,RX,  ID_BFM_WAIT);
    --enable_log_msg(UART_VVCT,1,RX,  ID_BFM_POLL);
    --enable_log_msg(UART_VVCT,1,RX,  ID_BFM_POLL_SUMMARY);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM);
    --enable_log_msg(UART_VVCT,1,TX,  ID_BFM_WAIT);
    --enable_log_msg(UART_VVCT,1,TX,  ID_BFM_POLL);
    --enable_log_msg(UART_VVCT,1,TX,  ID_BFM_POLL_SUMMARY);

    -- Enable SBs
    tx_uart_monitor_sb.enable(VOID);
    tx_uart_monitor_sb.set_scope("UART TX SB");
    rx_uart_monitor_sb.enable(VOID);
    rx_uart_monitor_sb.set_scope("UART RX SB");

    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(TX, 1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(RX, 1).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Start Test of UART VIP", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off

    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
    ------------------------------------------------------------
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default", ERROR);
    sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default", ERROR);
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default", ERROR);
    await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);

    log(ID_LOG_HDR, "Sending on TX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_tx          := std_logic_vector(to_unsigned(i, 4)) & std_logic_vector(to_unsigned(i, 4));
      v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx);
      tx_uart_monitor_sb.add_expected(v_uart_transaction);
      uart_transmit(UART_VVCT, 1, TX, v_data_tx, "Sending " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      wait for 200 ns;                  -- margin
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, v_data_tx, "check " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX), ERROR);
      await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);
    end loop;

    log(ID_LOG_HDR, "Sending on RX", C_SCOPE);
    ------------------------------------------------------------
    for i in 15 downto 0 loop
      v_data_rx          := std_logic_vector(to_unsigned(i, 4)) & std_logic_vector(to_unsigned(i, 4));
      v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx);
      rx_uart_monitor_sb.add_expected(v_uart_transaction);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data_rx, "Sending " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_expect(UART_VVCT, 1, RX, v_data_rx, "Expecting " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
    end loop;
    wait for 200 ns;                    -- margin

    log(ID_LOG_HDR, "Disable all IDs in monitors msg_id_panel", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_monitor_config(TX, 1).msg_id_panel := (others => DISABLED);
    shared_uart_monitor_config(RX, 1).msg_id_panel := (others => DISABLED);

    log(ID_LOG_HDR, "Sending on both TX and RX simultaneously", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_tx          := std_logic_vector(to_unsigned(i, 4)) & std_logic_vector(to_unsigned(15 - i, 4));
      v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx);
      tx_uart_monitor_sb.add_expected(v_uart_transaction);
      v_data_rx          := std_logic_vector(to_unsigned(15 - i, 4)) & std_logic_vector(to_unsigned(i, 4));
      v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx);
      rx_uart_monitor_sb.add_expected(v_uart_transaction);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data_rx, "Sending " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_expect(UART_VVCT, 1, RX, v_data_rx, "Expecting " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_transmit(UART_VVCT, 1, TX, v_data_tx, "Sending " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
      wait for 200 ns;                  -- margin
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, v_data_tx, "check " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX), ERROR);
      await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);
    end loop;
    wait for 200 ns;                    -- margin

    log(ID_LOG_HDR, "Enable ID_MONITOR and ID_FRAME_INITIATE in monitors", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_monitor_config(TX, 1).msg_id_panel := (ID_FRAME_INITIATE => ENABLED,
                                                       ID_MONITOR        => ENABLED,
                                                       others            => DISABLED);
    shared_uart_monitor_config(RX, 1).msg_id_panel := (ID_FRAME_INITIATE => ENABLED,
                                                       ID_MONITOR        => ENABLED,
                                                       others            => DISABLED);

    log(ID_LOG_HDR, "Change parity for monitors, now expecting active parity error flag in monitors", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_monitor_config(TX, 1).interface_config.parity := PARITY_EVEN;
    shared_uart_monitor_config(RX, 1).interface_config.parity := PARITY_EVEN;

    log(ID_LOG_HDR, "Sending on both TX and RX simultaneously", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_rx          := std_logic_vector(to_unsigned(15 - i, 4)) & std_logic_vector(to_unsigned(i, 4));
      v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx, true, false);
      rx_uart_monitor_sb.add_expected(v_uart_transaction);
      v_data_tx          := std_logic_vector(to_unsigned(i, 4)) & std_logic_vector(to_unsigned(15 - i, 4));
      v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx, true, false);
      tx_uart_monitor_sb.add_expected(v_uart_transaction);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data_rx, "Sending " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_expect(UART_VVCT, 1, RX, v_data_rx, "Expecting " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_transmit(UART_VVCT, 1, TX, v_data_tx, "Sending " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
      wait for 200 ns;                  -- margin
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, v_data_tx, "check " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX), ERROR);
      await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);
    end loop;
    wait for 200 ns;                    -- margin

    log(ID_LOG_HDR, "Change parity back to correct and stop bit to two for monitors, now expecting active stop bit error flag in monitors", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_monitor_config(TX, 1).interface_config.parity        := PARITY_ODD;
    shared_uart_monitor_config(RX, 1).interface_config.parity        := PARITY_ODD;
    shared_uart_monitor_config(TX, 1).interface_config.num_stop_bits := STOP_BITS_TWO;
    shared_uart_monitor_config(RX, 1).interface_config.num_stop_bits := STOP_BITS_TWO;

    log(ID_LOG_HDR, "Sending on TX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_tx := random(8);
      if i < 15 then
        v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx, false, true);
      else
        -- Expect no stop bit error on last transaction due to no transaction starting directly after
        v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx);
      end if;
      tx_uart_monitor_sb.add_expected(v_uart_transaction);
      uart_transmit(UART_VVCT, 1, TX, v_data_tx, "Sending " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      insert_delay(SBI_VVCT, 1, 200 ns);
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, v_data_tx, to_string(i) & ": check " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX), ERROR);
    end loop;

    wait for 500 ns;                    -- margin

    log(ID_LOG_HDR, "Sending on RX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_rx := random(8);
      if i < 15 then
        v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx, false, true);
      else
        -- Expect no stop bit error on last transaction due to no transaction starting directly after
        v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx);
      end if;
      rx_uart_monitor_sb.add_expected(v_uart_transaction);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data_rx, "Sending " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_expect(UART_VVCT, 1, RX, v_data_rx, "Expecting " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
    end loop;
    wait for 1 us;                      -- margin

    log(ID_LOG_HDR, "Change stop bit to one and a half for monitors, expecting active stop bit error flag in monitors", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_monitor_config(TX, 1).interface_config.num_stop_bits := STOP_BITS_ONE_AND_HALF;
    shared_uart_monitor_config(RX, 1).interface_config.num_stop_bits := STOP_BITS_ONE_AND_HALF;

    log(ID_LOG_HDR, "Sending on TX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_tx := random(8);
      if i < 15 then
        v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx, false, true);
      else
        -- Expect no stop bit error on last transaction due to no transaction starting directly after
        v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx);
      end if;
      tx_uart_monitor_sb.add_expected(v_uart_transaction);
      uart_transmit(UART_VVCT, 1, TX, v_data_tx, "Sending " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      insert_delay(SBI_VVCT, 1, 200 ns);
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, v_data_tx, to_string(i) & ": check " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX), ERROR);
    end loop;

    wait for 500 ns;                    -- margin

    log(ID_LOG_HDR, "Sending on RX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_rx := random(8);
      if i < 15 then
        v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx, false, true);
      else
        -- Expect no stop bit error on last transaction due to no transaction starting directly after
        v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx);
      end if;
      rx_uart_monitor_sb.add_expected(v_uart_transaction);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data_rx, "Sending " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_expect(UART_VVCT, 1, RX, v_data_rx, "Expecting " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
    end loop;
    wait for 200 ns;                    -- margin

    log(ID_LOG_HDR, "Change stop bit to one for monitors, expecting no error flags in monitors", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_monitor_config(TX, 1).interface_config.num_stop_bits := STOP_BITS_ONE;
    shared_uart_monitor_config(RX, 1).interface_config.num_stop_bits := STOP_BITS_ONE;

    log(ID_LOG_HDR, "Sending on TX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_tx          := random(8);
      v_uart_transaction := get_uart_transaction_info(TRANSMIT, v_data_tx);
      tx_uart_monitor_sb.add_expected(v_uart_transaction);
      uart_transmit(UART_VVCT, 1, TX, v_data_tx, "Sending " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      insert_delay(SBI_VVCT, 1, 200 ns);
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, v_data_tx, "check " & to_string(v_data_tx, HEX, AS_IS, INCL_RADIX), ERROR);
    end loop;

    wait for 500 ns;                    -- margin

    log(ID_LOG_HDR, "Sending on RX", C_SCOPE);
    ------------------------------------------------------------
    for i in 0 to 15 loop
      v_data_rx          := random(8);
      v_uart_transaction := get_uart_transaction_info(RECEIVE, v_data_rx);
      rx_uart_monitor_sb.add_expected(v_uart_transaction);
      sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data_rx, "Sending " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      uart_expect(UART_VVCT, 1, RX, v_data_rx, "Expecting " & to_string(v_data_rx, HEX, AS_IS, INCL_RADIX));
      await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
    end loop;
    wait for 200 ns;                    -- margin

    tx_uart_monitor_sb.report_counters(VOID);
    rx_uart_monitor_sb.report_counters(VOID);

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

  --==================================================================================================
  -- Process for handeling tx monitor data
  --==================================================================================================
  p_monitor_tx : process
    variable v_transaction : t_uart_transaction;
  begin
    wait until global_uart_monitor_transaction_trigger(TX, 1) = '1';
    v_transaction := shared_uart_monitor_transaction_info(TX, 1).bt;

    if (v_transaction.transaction_status = SUCCEEDED) or (v_transaction.transaction_status = FAILED) then
      tx_uart_monitor_sb.check_received(v_transaction);
    end if;

  end process p_monitor_tx;

  --==================================================================================================
  -- Process for handeling rx monitor data
  --==================================================================================================
  p_monitor_rx : process
    variable v_transaction : t_uart_transaction;
  begin
    wait until global_uart_monitor_transaction_trigger(RX, 1) = '1';
    v_transaction := shared_uart_monitor_transaction_info(RX, 1).bt;

    if (v_transaction.transaction_status = SUCCEEDED) or (v_transaction.transaction_status = FAILED) then
      rx_uart_monitor_sb.check_received(v_transaction);
    end if;

  end process p_monitor_rx;

end func;
