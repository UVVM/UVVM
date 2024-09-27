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
use bitvis_vip_uart.monitor_cmd_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

--hdlregression:tb
-- Test bench entity
entity uvvm_demo_tb is
end entity uvvm_demo_tb;

-- Test bench architecture
architecture func of uvvm_demo_tb is

  constant C_SCOPE         : string := C_TB_SCOPE_DEFAULT;
  constant C_MONITOR_SCOPE : string := "UART Monitor";

  -- Clock and bit period settings
  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";

  -- Activity watchdog VVC inactivity timeout
  constant C_ACTIVITY_WATCHDOG_TIMEOUT : time := 50 * C_BIT_PERIOD;

  -- Watchdog timer control signal
  constant C_GENERAL_WATCHDOG_TIMEOUT : time            := 1 sec; -- never timeout during DEMO TB
  signal watchdog_ctrl_terminate      : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_init           : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_extend         : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_reinit         : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;

begin

  ------------------------------------------------
  -- Process: general watchdog timer
  ------------------------------------------------
  -- Note: these timers should have a minimum timeout that
  -- covers all the tests in this testbench or else it will fail.
  watchdog_timer(watchdog_ctrl_terminate, C_GENERAL_WATCHDOG_TIMEOUT, ERROR, "Watchdog A");
  watchdog_timer(watchdog_ctrl_init, C_GENERAL_WATCHDOG_TIMEOUT, ERROR, "Watchdog B");
  watchdog_timer(watchdog_ctrl_extend, C_GENERAL_WATCHDOG_TIMEOUT, ERROR, "Watchdog C");
  watchdog_timer(watchdog_ctrl_reinit, C_GENERAL_WATCHDOG_TIMEOUT, ERROR, "Watchdog D");

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  --
  --   Map timing constants and DUT addresses for VIPs and Model
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uvvm_demo_th
    generic map(
      GC_CLK_PERIOD                => C_CLK_PERIOD,
      GC_BIT_PERIOD                => C_BIT_PERIOD,
      GC_ADDR_RX_DATA              => C_ADDR_RX_DATA,
      GC_ADDR_RX_DATA_VALID        => C_ADDR_RX_DATA_VALID,
      GC_ADDR_TX_DATA              => C_ADDR_TX_DATA,
      GC_ADDR_TX_READY             => C_ADDR_TX_READY,
      GC_ACTIVITY_WATCHDOG_TIMEOUT => C_ACTIVITY_WATCHDOG_TIMEOUT
    );

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    variable v_data : std_logic_vector(7 downto 0);

    -- Description:
    --
    --    1. UART TX VVC is configured with parity and stop bit error
    --       probability from 0-100%, and transmits data to the DUT.
    --    2. Model will put expected data on SBI Scoreboard.
    --    3. Model will issue a SBI VVC read request.
    --    4. SBI VVC will put actual data on SBI Scoreboard.
    --    5. UART Monitor (and DUT) will alert when any illegal transaction
    --       is detected.
    --    6. Sequencer present SBI Scoreboard statistics.
    --
    procedure test_error_injection(void : t_void) is
      variable v_prob : real;
    begin
      log(ID_LOG_HDR_XL, "Test error injection.\n\n" & "UART TX VVC is used to randomly send error injected data to DUT.\n" & "The UART Monitor will report any transfer errors detected.", C_SCOPE);

      -- Print info
      log(ID_SEQUENCER, "Note: SBI_READ() is requested by Model.\nResults are checked in Scoreboard.\n", C_SCOPE);

      -- Set UART TX VVC error injection probability to 0%.
      -- Note that error injection is set to C_VVC_ERROR_INJECTION_INACTIVE in vvc_methods_pkg
      -- when the VVCs are initialized.
      shared_uart_vvc_config(TX, 1).error_injection.parity_bit_error_prob := 0.0;
      shared_uart_vvc_config(TX, 1).error_injection.stop_bit_error_prob   := 0.0;

      log(ID_LOG_HDR, "Performing 10x SBI Write and UART Reveive with random parity bit error injection", C_SCOPE);
      -- This test will use UART TX VVC to write data to DUT, with randomly inserted parity bit error injection.
      --   The probability of an error injection will increase with 10% for each write access.
      --   Note that DUT will alert parity bit error, and Monitor will report illegal transaction.
      for idx in 1 to 10 loop
        -- Get write data and error injection probability
        v_data := std_logic_vector(to_unsigned(idx, v_data'length));
        v_prob := real(idx) / real(10);

        -- Configure the parity bit error injection probability
        log(ID_SEQUENCER, "\nSetting parity error probability to " & to_string(v_prob) & "%", C_SCOPE);
        shared_uart_vvc_config(TX, 1).error_injection.parity_bit_error_prob := v_prob;

        -- Request UART TX VVC write
        uart_transmit(UART_VVCT, 1, TX, v_data, "UART TX");
        await_completion(UART_VVCT, 1, TX, 16 * C_BIT_PERIOD);
        wait for 200 ns;                -- margin
        -- Add delay for DUT to prepare for next transaction
        insert_delay(UART_VVCT, 1, TX, C_BIT_PERIOD, "Insert delay before next UART TX");
      end loop;

      -- Set UART TX VVC parity bit error injection probability to 0%, i.e. off.
      log(ID_SEQUENCER, "\nSetting parity error probability to 0%", C_SCOPE);
      shared_uart_vvc_config(TX, 1).error_injection.parity_bit_error_prob := 0.0;

      log(ID_LOG_HDR, "Performing 10x SBI Write and UART Reveive with random stop bit error injection", C_SCOPE);
      -- This test will use UART TX VVC to write data to DUT, with randomly inserted stop bit error injection.
      --   The probability of an error injection will increase with 10% for each write access.
      --   Note that DUT will alert stop bit error, and Monitor will report illegal transaction.
      for idx in 1 to 10 loop
        -- Get write data and error injection probability
        v_data := std_logic_vector(to_unsigned(idx, v_data'length));
        v_prob := real(idx) / real(10);

        -- Configure the parity bit error injection probability
        log(ID_SEQUENCER, "\nSetting stop error probability to " & to_string(v_prob) & "%", C_SCOPE);
        shared_uart_vvc_config(TX, 1).error_injection.stop_bit_error_prob := v_prob;

        -- Request UART TX VVC write
        uart_transmit(UART_VVCT, 1, TX, v_data, "UART TX");
        await_completion(UART_VVCT, 1, TX, 16 * C_BIT_PERIOD);
        wait for 200 ns;                -- margin
        -- Add delay for DUT to prepare for next transaction
        insert_delay(UART_VVCT, 1, TX, C_BIT_PERIOD, "Insert delay before next UART TX");
      end loop;

      -- Set UART TX VVC stop bit error injection probability to 0%, i.e. off.
      log(ID_SEQUENCER, "\nSetting stop error probability to 0%", C_SCOPE);
      shared_uart_vvc_config(TX, 1).error_injection.stop_bit_error_prob := 0.0;

      -- Print report of Scoreboard counters
      SBI_VVC_SB.report_counters(VOID);

      -- Empty SB for next test
      SBI_VVC_SB.reset("Empty SB for next test");

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_error_injection;

    -- Description:
    --
    --    1. UART TX VVC is instructed to send 1 and 3 randomised
    --       data to DUT.
    --    2. Model will put expected data on SBI Scoreboard.
    --    3. Model will issue a SBI VVC read request.
    --    4. SBI VVC will put actual data on SBI Scoreboard.
    --    5. Sequencer present SBI Scoreboard statistics.
    --
    procedure test_randomise(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test randomise data.\n\n" & "UART TX VVC is used to send randomised data to DUT.", C_SCOPE);

      -- Print info
      log(ID_SEQUENCER, "Note: SBI_READ() is requested by Model.\nResults are checked in Scoreboard.\n", C_SCOPE);

      log(ID_LOG_HDR, "Check 1 byte random transmit", C_SCOPE);
      -- This test will request the UART TX VVC to send a random byte to the DUT.
      -- SBI_READ() is requested by Model and the randomised data is checked in SB.

      uart_transmit(UART_VVCT, 1, TX, 1, RANDOM, "UART TX RANDOM");
      await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
      -- Add a delay for DUT to prepare for next transaction
      insert_delay(UART_VVCT, 1, TX, 20 * C_CLK_PERIOD, "Insert delay before next UART TX");

      log(ID_LOG_HDR, "Check 3 byte random transmit", C_SCOPE);
      -- This test will request the UART TX VVC to send 3 random bytes to the DUT.
      -- SBI_READ() is requested by Model and the randomised data is checked in SB.

      uart_transmit(UART_VVCT, 1, TX, 3, RANDOM, "UART TX RANDOM");
      await_completion(UART_VVCT, 1, TX, 3 * 13 * C_BIT_PERIOD);

      -- Wait for final SBI READ to finish and update SB
      await_completion(SBI_VVCT, 1, 13 * C_BIT_PERIOD);

      -- Print report of Scoreboard counters
      SBI_VVC_SB.report_counters(VOID);

      -- Empty SBI SB for next test
      SBI_VVC_SB.reset("Empty SB for next test");

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_randomise;

    -- Description:
    --
    --  1. UART RX VVC is configured with control of a protocol checker (bit rate).
    --  2. 6 bytes are transmitted using SBI VVC.
    --  3. Protocol checker is reconfigured during the transfer of the 6 bytes,
    --     and will alert when bit rate is not within specs.
    --  4. Model puts expected data on UART Scoreboard.
    --  5. UART RX VVC receives data and puts actual data on UART Scoreboard.
    --  6. Sequencer present UART Scoreboard statistics.
    --
    procedure test_protocol_checker(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test protocol checker.\n\n" & "UART RX VVC is configured to control the bit rate checker,\n" & "which is will monitor the bit periods.", C_SCOPE);

      -- Print info
      log(ID_SEQUENCER, "Note: results are checked in Scoreboard.\n", C_SCOPE);

      -- Allow for some time to pass for bit rate checker calculations (a short stable period of the UART line).
      wait for C_BIT_PERIOD;

      -- Bit rate checker will alert when bit rate is not as expected.
      log(ID_SEQUENCER, "\nIncrease number of expected alerts with 5.", C_SCOPE);
      increment_expected_alerts(WARNING, 5);

      -- Enable and configure bit rate checker.
      -- Note that protocol checker (bit rate checker) is set to C_BIT_RATE_CHECKER_DEFAULT in vvc_methods_pkg
      -- when the VVCs are initilized.
      log(ID_SEQUENCER, "\nEnable and configure bit rate checker.");
      shared_uart_vvc_config(RX, 1).bit_rate_checker.enable     := true; -- enable checker
      shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := C_BIT_PERIOD; -- set minimum alowed period

      -- Use SBI VVC to transmit 6 random bytes.
      -- The bit rate checker settings are changed during the 6 bytes to test various settings.
      log(ID_SEQUENCER, "\nSBI Write 6 bytes to DUT, UART Receive bytes from DUT. Changing protocol checker min_period during sequence.\n", C_SCOPE);
      for idx in 1 to 6 loop
        v_data := std_logic_vector(to_unsigned(idx + 16#50#, 8)); -- + x50 to get more edges

        if idx = 3 then
          log(ID_SEQUENCER, "\nSetting bit rate checker min_period=" & to_string(C_BIT_PERIOD * 0.95) & " (bit period=" & to_string(C_BIT_PERIOD) & ").", C_SCOPE);
          shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := C_BIT_PERIOD * 0.95;
        elsif idx = 4 then
          log(ID_SEQUENCER, "\nSetting bit rate checker min_period=" & to_string(C_BIT_PERIOD * 1.05) & " (bit period=" & to_string(C_BIT_PERIOD) & ").", C_SCOPE);
          shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := C_BIT_PERIOD * 1.05;
        elsif idx = 5 then
          log(ID_SEQUENCER, "\nDisable bit rate checker.", C_SCOPE);
          shared_uart_vvc_config(RX, 1).bit_rate_checker.enable := false;
        end if;

        -- Request SBI Write and UART Receive
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data, "SBI WRITE");
        uart_receive(UART_VVCT, 1, RX, TO_SB, "UART TX");
        await_completion(UART_VVCT, 1, RX, 20 * C_BIT_PERIOD);
      end loop;

      -- Print report of Scoreboard counters
      UART_VVC_SB.report_counters(VOID);

      -- Empty SB for next test
      UART_VVC_SB.reset("Empty SB for next test");

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_protocol_checker;

    -- Description:
    --
    --   1. SBI VVC will send 3 bytes to the DUT.
    --   2. Model will put expected data on UART Scoreboard.
    --   3. UART RX VVC will read data from the DUT and put actual
    --      data on the UART Scoreboard.
    --   4. All activity is stalled and Activity Watchdog will start
    --      timeout calculations.
    --   5. Timeout is reached and Activity Watchdog alerts.
    --   6. Step 1 to 3 is repeated.
    --   7. Sequencer present UART Scoreboard statistics.
    --
    procedure test_activity_watchdog(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test activity watchdog.\n\n" & "SBI VVC will transmit 3 bytes and UART RX VVC will receive 3 bytes,\n" & "before a pause of TB sequencer will make the activity watchdog\n" & "timeout and alert. Then a new 3 bytes transmit and receive sequence is performed.", C_SCOPE);

      -- Print info
      log(ID_SEQUENCER, "Note: results are checked in Scoreboard.\n", C_SCOPE);

      -- Activity Watchdog will alert when VVC inactivity cause timeout
      log(ID_SEQUENCER, "\nIncrease number of expected alerts for activity watchdog testing.", C_SCOPE);
      -- The activity watchdog timeout is tested, expect the number of alerts to increase.
      increment_expected_alerts(TB_ERROR, 1);
      -- To prevent activity watchdog from stopping the TB, increase the stop limit.
      set_alert_stop_limit(TB_ERROR, 2);

      log(ID_SEQUENCER, "\nSBI Write 3 bytes to DUT, UART Receive 5 bytes from DUT. No activity watchdog timeout.\n", C_SCOPE);
      -- Activate VVCs with write and receive activity.
      for idx in 1 to 3 loop
        v_data := std_logic_vector(to_unsigned(idx + 16#50#, 8)); -- + x50 to get more edges

        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data, "DUT TX DATA");
        uart_receive(UART_VVCT, 1, RX, TO_SB, "UART TX");
        await_completion(UART_VVCT, 1, RX, 20 * C_BIT_PERIOD);
      end loop;

      log(ID_SEQUENCER, "\nStalling TB to trigger inactivity watchdog timeout.\n", C_SCOPE);
      -- Stall all VVC activity for the Activity Watchdog timeout period + 1 ns,
      -- this will make the watchdog alert.
      wait for C_ACTIVITY_WATCHDOG_TIMEOUT + 1 ns;

      log(ID_SEQUENCER, "\nSBI Write 3 bytes to DUT, UART Receive 5 bytes from DUT. No activity watchdog timeout.\n", C_SCOPE);
      -- Activate VVCs with write and receive activity.
      for idx in 1 to 3 loop
        v_data := std_logic_vector(to_unsigned(idx + 16#50#, 8)); -- + x50 to get more edges

        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data, "DUT TX DATA");
        uart_receive(UART_VVCT, 1, RX, TO_SB, "UART TX");
        await_completion(UART_VVCT, 1, RX, 20 * C_BIT_PERIOD);
      end loop;

      -- Print report of Scoreboard counters
      UART_VVC_SB.report_counters(VOID);

      -- Empty SB for next test
      UART_VVC_SB.reset("Empty SB for next test");

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_activity_watchdog;

    -- Description:
    --
    --   1. Watchdog A-D is reconfigured with a smaller timeout value.
    --   2. Terminating of watchdog A is tested.
    --   3. Timeout of watchdog B is tested.
    --   4. Extending watchdog C timeout is tested, and timeout is tested.
    --   5. Reinitialization of watchdog D is tested, and timeout is tested.
    --
    procedure test_general_watchdog(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test general watchdog.\n\n" & "This test demonstrates configuration and usage of the general watchdog.", C_SCOPE);

      log(ID_SEQUENCER, "Incrementing UVVM stop limit\n", C_SCOPE);
      -- To prevent the 4 general watchdogs from stopping the TB, increase the stop limit.
      set_alert_stop_limit(ERROR, 6);   -- Note: stop limit was set to 2 in test_activity_watchdog()

      log(ID_SEQUENCER, "Reconfigure general watchdogs for test\n", C_SCOPE);
      -- Reinitialize the watchdogs with short timeout
      reinitialize_watchdog(watchdog_ctrl_terminate, 110 ns); -- wd A
      reinitialize_watchdog(watchdog_ctrl_init, 120 ns); -- wd B
      reinitialize_watchdog(watchdog_ctrl_extend, 130 ns); -- wd C
      reinitialize_watchdog(watchdog_ctrl_reinit, 2000 ns); -- wd D

      -- Wait until watchdog A almost has timeout, then terminate it.
      wait for 100 ns;
      log(ID_LOG_HDR, "Testing general watchdog timer A (110 ns) - terminate command", C_SCOPE);
      terminate_watchdog(watchdog_ctrl_terminate); -- terminate general watchdog A

      -- Wait until watchdog B has a timeout, and let it timeout with alert.
      log(ID_LOG_HDR, "Testing general watchdog timer B (120 ns) - initial timeout", C_SCOPE);
      wait for 19 ns;
      log(ID_SEQUENCER, "General watchdog B still running - waiting for timeout", C_SCOPE);
      increment_expected_alerts(ERROR);
      wait for 1 ns;                    -- general watchdog B has timeout

      -- Extend watchdog C timeout with 100 ns, new timeout will be 230 ns.
      log(ID_LOG_HDR, "Testing general watchdog timer C (130 ns) - extend command with input value", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 100 ns); -- 120 ns
      wait for 100 ns;
      -- 10 ns util watchdog C has a timeout, exted with previous timeout
      log(ID_SEQUENCER, "General watchdog C still running - extend command with previous input value (100 ns)", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend); -- 220
      wait for 130 ns;
      log(ID_SEQUENCER, "General watchdog C still running - extend command with input value 300 ns", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns); -- 350
      wait for 300 ns;
      log(ID_SEQUENCER, "General watchdog C still running - extend command with input value 300 ns", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns); -- 650
      wait for 300 ns;
      log(ID_SEQUENCER, "General watchdog C still running - extend command with previous input value (300 ns)", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend); -- 950
      wait for 130 ns;
      log(ID_SEQUENCER, "General watchdog C still running - reinitialize command with input value 101 ns", C_SCOPE);
      reinitialize_watchdog(watchdog_ctrl_extend, 101 ns); -- 1080
      wait for 100 ns;
      log(ID_SEQUENCER, "General watchdog C still running - extend command with input value 300 ns", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns); -- 1180
      wait for 300 ns;
      log(ID_SEQUENCER, "General watchdog C still running - waiting for timeout", C_SCOPE);
      increment_expected_alerts(ERROR); -- 1480
      wait for 1 ns;                    -- general wathdog C has timeout

      log(ID_LOG_HDR, "Testing general watchdog timer D (5000 ns) - reinitialize command (100 ns)", C_SCOPE);
      reinitialize_watchdog(watchdog_ctrl_reinit, 100 ns);
      wait for 99 ns;
      log(ID_SEQUENCER, "General watchdog D still running - waiting for timeout", C_SCOPE);
      increment_expected_alerts(ERROR);
      wait for 1 ns;                    -- genral watchdog D has timeout

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_general_watchdog;

    -- Description:
    --
    --   1. UART RX VVC is configured with an alert of severity.
    --   2. SBI VVC will send 1 byte to the DUT and UART RX VVC will expect the same data.
    --   3. Unwanted activity detection will not be triggered (normal data transmission).
    --   4. SBI VVC will send 1 byte to the DUT and UART RX VVC will not expect any data.
    --   5. Unwanted activity detection will be triggered (unexpected data transmission).
    --   6. Step 1 to 5 is repeated for different alerts of severity.
    --
    procedure test_unwanted_activity_detection(void : t_void) is
      variable v_alert_level         : t_alert_level;
    begin
      log(ID_LOG_HDR_XL, "Test unwanted activity detection.\n\n" & "This test demonstrates configuration and usage of the unwanted activity detection.", C_SCOPE);

      -- This will test the unwanted activity detection with different alerts of severity.
      -- Normal data transmission and unexpected data transmission are tested in each alert configuration.
      for i in 0 to 2 loop
        -- Configure the alert of severity for unwanted activity detection
        if i = 0 then
          v_alert_level := C_UART_VVC_CONFIG_DEFAULT.unwanted_activity_severity;
        elsif i = 1 then
          v_alert_level := FAILURE;
        else
          v_alert_level := NO_ALERT;
        end if;

        log(ID_SEQUENCER, "Configure unwanted activity severity to " & to_upper(to_string(v_alert_level)) & ".", C_SCOPE);
        shared_uart_vvc_config(RX, 1).unwanted_activity_severity := v_alert_level;

        -- Normal data transmission
        --   Use SBI VVC to write 1 byte data and use UART RX VVC to expect the data
        --   Data is expected on UART RX VVC and alerts are not triggered
        log(ID_LOG_HDR, "Testing normal data transmission.", C_SCOPE);
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"55", "Transmit data");
        uart_expect(UART_VVCT, 1, RX, x"55", "Expect data");
        await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);

        -- Increment expected alerts
        if v_alert_level /= NO_ALERT then
          increment_expected_alerts_and_stop_limit(v_alert_level, 10); -- Note: number of expected alerts = number of toggles for transmitted data
        end if;

        -- Unexpected data transmission
        --   Use SBI VVC to write 1 byte and not expecting any data
        --   Data is not expected on UART RX VVC and alerts are triggered
        log(ID_LOG_HDR, "Testing unexpected data transmission.", C_SCOPE);
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"55", "Transmit data");
        await_completion(SBI_VVCT, 1, 13 * C_BIT_PERIOD);
        wait for 10 * C_BIT_PERIOD;
      end loop;

      -- Empty SB for next test
      UART_VVC_SB.reset("Empty SB for next test");

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_unwanted_activity_detection;

  begin
    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");

    -- Set verbosity level
    --============================================================================================================
    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_LOG_HDR_XL);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_SEQUENCER_SUB);
    enable_log_msg(ID_UVVM_SEND_CMD);
    enable_log_msg(ID_AWAIT_UVVM_COMPLETION);
    --enable_log_msg(ID_BFM);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT, 1, ID_BFM);
    --enable_log_msg(SBI_VVCT, 1, ID_FINISH_OR_STOP);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    --enable_log_msg(UART_VVCT, 1, RX, ID_BFM);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    --enable_log_msg(UART_VVCT, 1, TX, ID_BFM);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    log(ID_LOG_HDR, "Configure UART Monitor", C_SCOPE);
    --============================================================================================================
    -- UART Monitor is initialized with C_UART_MONITOR_CONFIG_DEFAULT in vvc_methods_pkg, setting scope.
    shared_uart_monitor_config(TX, 1).scope_name(1 to C_MONITOR_SCOPE'length) := C_MONITOR_SCOPE;
    shared_uart_monitor_config(RX, 1).scope_name(1 to C_MONITOR_SCOPE'length) := C_MONITOR_SCOPE;

    log(ID_LOG_HDR, "Starting simulation of UVVM DEMO TB using SBI and UART VVCs", C_SCOPE);
    --============================================================================================================
    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);

    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    --============================================================================================================
    shared_uart_vvc_config(RX, 1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, 1).bfm_config.bit_time := C_BIT_PERIOD;

    shared_uart_vvc_config(RX, 1).bfm_config.num_stop_bits := STOP_BITS_ONE;
    shared_uart_vvc_config(TX, 1).bfm_config.num_stop_bits := STOP_BITS_ONE;

    shared_uart_vvc_config(RX, 1).bfm_config.parity := PARITY_ODD;
    shared_uart_vvc_config(TX, 1).bfm_config.parity := PARITY_ODD;

    -----------------------------------------------------------------------------
    -- Tests
    --   Comment out tests below to run a selection of tests.
    -----------------------------------------------------------------------------
    test_error_injection(VOID);
    test_randomise(VOID);
    test_protocol_checker(VOID);
    test_activity_watchdog(VOID);
    test_general_watchdog(VOID);
    test_unwanted_activity_detection(VOID);

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(1000 ns, ERROR, 1 ns, REPORT_ALERT_COUNTERS_FINAL, REPORT_SCOREBOARDS, REPORT_VVCS, C_SCOPE);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
