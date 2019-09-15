--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
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

library bitvis_vip_sbi;
use bitvis_vip_sbi.vvc_methods_pkg.all;
use bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_uart;
use bitvis_vip_uart.vvc_methods_pkg.all;
use bitvis_vip_uart.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;



-- Test bench entity
entity uvvm_demo_tb is
end entity;

-- Test bench architecture
architecture func of uvvm_demo_tb is

  constant C_SCOPE              : string  := C_TB_SCOPE_DEFAULT;

  -- Clock and bit period settings
  constant C_CLK_PERIOD         : time := 10 ns;
  constant C_BIT_PERIOD         : time := 16 * C_CLK_PERIOD;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";



  begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uvvm_demo_th generic map(
    GC_CLK_PERIOD         => C_CLK_PERIOD,
    GC_BIT_PERIOD         => C_BIT_PERIOD,
    GC_ADDR_RX_DATA       => C_ADDR_RX_DATA,
    GC_ADDR_RX_DATA_VALID => C_ADDR_RX_DATA_VALID,
    GC_ADDR_TX_DATA       => C_ADDR_TX_DATA,
    GC_ADDR_TX_READY      => C_ADDR_TX_READY
  );


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
    variable v_data       : std_logic_vector(7 downto 0);


    procedure test_error_injection(void : t_void) is
      variable v_prob : real;
    begin
      log(ID_LOG_HDR_XL, "Test error injection.", C_SCOPE);
      -- Note:
      -- SBI Read is requested by Model.
      -- Results are checked in Scoreboard.
      shared_uart_vvc_config(TX,1).error_injection_config.parity_bit_error_prob := 0.0;
      shared_uart_vvc_config(TX,1).error_injection_config.stop_bit_error_prob   := 0.0;


      log(ID_LOG_HDR, "Performing 10x SBI Write and UART Reveive with random parity bit error injection", C_SCOPE);
      for idx in 1 to 10 loop
        v_data := std_logic_vector(to_unsigned(idx, v_data'length));
        v_prob := real(idx) / real(10);

        log(ID_SEQUENCER, "\nSetting parity error probability to " & to_string(v_prob) & "%", C_SCOPE);
        shared_uart_vvc_config(TX,1).error_injection_config.parity_bit_error_prob := v_prob;

        uart_transmit(UART_VVCT,1,TX,  v_data, "UART TX");
        await_completion(UART_VVCT,1,TX,  16 * C_BIT_PERIOD);
        wait for 200 ns;  -- margin
        -- Add delay for DUT to prepare for next transaction
        insert_delay(UART_VVCT, 1, TX, C_BIT_PERIOD, "Insert 20 clock periods delay before next UART TX");
      end loop;

      log(ID_SEQUENCER, "\nSetting parity error probability to 0%", C_SCOPE);
      shared_uart_vvc_config(TX,1).error_injection_config.parity_bit_error_prob    := 0.0;


      log(ID_LOG_HDR, "Performing 10x SBI Write and UART Reveive with random stop bit error injection", C_SCOPE);
      for idx in 1 to 10 loop
        v_data := std_logic_vector(to_unsigned(idx, v_data'length));
        v_prob := real(idx) / real(10);
        log(ID_SEQUENCER, "\nSetting stop error probability to " & to_string(v_prob) & "%", C_SCOPE);
        shared_uart_vvc_config(TX,1).error_injection_config.stop_bit_error_prob := v_prob;

        uart_transmit(UART_VVCT,1,TX,  v_data, "UART TX");
        await_completion(UART_VVCT,1,TX,  16 * C_BIT_PERIOD);
        wait for 200 ns;  -- margin
        -- Add delay for DUT to prepare for next transaction
        insert_delay(UART_VVCT, 1, TX, C_BIT_PERIOD, "Insert 20 clock periods delay before next UART TX");
      end loop;


      log(ID_SEQUENCER, "\nSetting stop error probability to 0%", C_SCOPE);
      shared_uart_vvc_config(TX,1).error_injection_config.stop_bit_error_prob    := 0.0;

      -- Print report of Scoreboard counters
      shared_uart_sb.report_counters(VOID);
      shared_sbi_sb.report_counters(VOID);

      -- Empty SBI SB for next test
      shared_uart_sb.flush("Empty SB for next test");
      shared_sbi_sb.flush("Empty SB for next test");
      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_error_injection;



    procedure test_randomise(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test randomise.", C_SCOPE);
      -- Note:
      -- SBI Read is requested by Model.
      -- Results are checked in Scoreboard.

      log(ID_LOG_HDR, "Check 1 byte random transmit", C_SCOPE);
      -- This test will request the UART VVC using the TX
      -- channel to send a random byte to the DUT.
      uart_transmit(UART_VVCT, 1, TX, 1, RANDOM, "UART TX RANDOM");
      await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
      -- Add a delay for DUT to prepare for next transaction
      insert_delay(UART_VVCT, 1, TX, 20*C_CLK_PERIOD, "Insert 20 clock periods delay before next UART TX");


      log(ID_LOG_HDR, "Check 3 byte random transmit", C_SCOPE);
      -- This test will request the UART VVC using the TX
      -- channel to send 3 random bytes to the DUT.
      uart_transmit(UART_VVCT, 1, TX, 3, RANDOM, "UART TX RANDOM");
      await_completion(UART_VVCT,1,TX,  3 * 13 * C_BIT_PERIOD);


      -- Wait for final SBI READ to finish and update SB
      await_completion(SBI_VVCT, 1, 13 * C_BIT_PERIOD);

      -- Print report of Scoreboard counters
      shared_sbi_sb.report_counters(VOID);
      -- Empty SBI SB for next test
      shared_sbi_sb.flush("Empty SB for next test");
      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_randomise;


    procedure test_functional_coverage(void : t_void) is
      constant C_NUM_BYTES  : natural := 100;
      constant C_TIMEOUT    : time := C_NUM_BYTES * 16 * C_BIT_PERIOD;
    begin
      log(ID_LOG_HDR_XL, "Test functional coverage", C_SCOPE);
      -- Note:
      -- Results are checked in Scoreboard.

      log(ID_LOG_HDR, "UART Receive full coverage from 0x0 to 0x7", C_SCOPE);
      uart_receive(UART_VVCT, 1, RX, COVERAGE_FULL, TO_SB, "UART RX");

      -- SBI Write random data to DUT
      for idx in 1 to C_NUM_BYTES loop
        v_data := std_logic_vector(to_unsigned(random(0, 16), v_data'length));
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data, "UART Write 0x" & to_string(v_data, HEX));
        -- Add time for UART to finish
        insert_delay(SBI_VVCT, 1, 13*C_BIT_PERIOD, "Insert 20 clock periods delay before next UART TX");
      end loop;

      -- Wait for UART RX VVC to finish data readout
      await_completion(UART_VVCT, 1, RX, C_TIMEOUT, "Waiting for UART RX coverage.");

      -- Terminate remaining SBI VVC commands
      flush_command_queue(SBI_VVCT, 1);

      -- Print coverage results
      log(ID_SEQUENCER, "Coverage results", C_SCOPE);
      shared_uart_byte_coverage.writebin;

      -- Print report of Scoreboard counters
      shared_uart_sb.report_counters(VOID);
      -- Empty SB for next test
      shared_uart_sb.flush("Empty SB for next test");
      shared_sbi_sb.flush("Empty SB for next test");
      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_functional_coverage;


    procedure test_protocol_checker(void : t_void) is
    begin
      log(ID_LOG_HDR_XL, "Test protocol checker: bit rate checker", C_SCOPE);
      -- Note:
      -- Results are checked in Scoreboard.

      log(ID_SEQUENCER, "\nIncrease number of expected alerts with 3.", C_SCOPE);
      increment_expected_alerts(WARNING, 3);

      log(ID_SEQUENCER, "\nEnable and configure bit rate checker.");
      shared_uart_vvc_config(RX, 1).bit_rate_checker.enable     := true;
      shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := C_BIT_PERIOD;


      for idx in 1 to 6 loop

        -- Adjust bit rate period
        case idx is
          when 3 =>
            log(ID_SEQUENCER, "\nSetting bit rate 5% below bit period.\n", C_SCOPE);
            shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := (0.95 * C_BIT_PERIOD);
          when 4 =>
            log(ID_SEQUENCER, "\nSetting bit rate 5% above bit period.\n", C_SCOPE);
            shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := (1.05 * C_BIT_PERIOD);
          when 5 =>
            log(ID_SEQUENCER, "\nDisabling bit rate checker.\n", C_SCOPE);
            shared_uart_vvc_config(RX, 1).bit_rate_checker.enable     := false;
          when others =>
            shared_uart_vvc_config(RX, 1).bit_rate_checker.min_period := C_BIT_PERIOD;
        end case;

        -- SBI send data to DUT
        v_data := std_logic_vector(to_unsigned(random(0, 16), v_data'length));
        sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, v_data, "UART Write 0x" & to_string(v_data, HEX));
        -- Add time for UART to finish
        insert_delay(SBI_VVCT, 1, 13*C_BIT_PERIOD, "Insert 20 clock periods delay before next UART TX");

        -- UART receive data from DUT
        uart_receive(UART_VVCT, 1, RX, TO_SB, "UART RX");
        await_completion(UART_VVCT, 1, RX, 16*C_BIT_PERIOD, "Waiting for UART RX to finish.");
      end loop;

      -- Print report of Scoreboard counters
      shared_uart_sb.report_counters(VOID);
      -- Empty SB for next test
      shared_uart_sb.flush("Empty SB for next test");
      shared_sbi_sb.flush("Empty SB for next test");

      -- Add small delay before next test
      wait for 3 * C_BIT_PERIOD;
    end procedure test_protocol_checker;


  begin

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_LOG_HDR_XL);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_SEQUENCER_SUB);
    enable_log_msg(ID_UVVM_SEND_CMD);
    --enable_log_msg(ID_BFM);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    --enable_log_msg(SBI_VVCT, 1, ID_BFM);
    enable_log_msg(SBI_VVCT, 1, ID_FINISH_OR_STOP);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    --enable_log_msg(UART_VVCT, 1, RX, ID_BFM);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    --enable_log_msg(UART_VVCT, 1, TX, ID_BFM);



    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    --============================================================================================================
    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    --============================================================================================================
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX,1).bfm_config.bit_time := C_BIT_PERIOD;



    test_error_injection(VOID);
    test_randomise(VOID);
    test_functional_coverage(VOID);
    test_protocol_checker(VOID);

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