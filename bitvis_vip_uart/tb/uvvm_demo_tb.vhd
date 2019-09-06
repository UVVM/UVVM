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

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;
use bitvis_vip_scoreboard.slv_sb_pkg.all;



-- Test bench entity
entity uvvm_demo_tb is
end entity;

-- Test bench architecture
architecture func of uvvm_demo_tb is

  constant C_SCOPE              : string  := C_TB_SCOPE_DEFAULT;

  -- Clock and bit period settings
  constant C_CLK_PERIOD         : time := 10 ns;
  constant C_BIT_PERIOD         : time := 16 * C_CLK_PERIOD;

  -- Time for one UART transmission to complete
  constant C_TIME_OF_ONE_UART_TX : time := 11*C_BIT_PERIOD; -- =1760 ns;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";

  -- SB for the UART side of the DUT
  shared variable v_uart_sb : t_generic_sb;


  begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uvvm_demo_th;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
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
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_UVVM_SEND_CMD);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, 1, ID_BFM);
    enable_log_msg(SBI_VVCT, 1, ID_FINISH_OR_STOP);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM);

    -- Setup Scoreboard
    v_uart_sb.set_scope("UART_SB");

    ------------------------------------------------------------

    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD); -- for reset to be turned off


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX,1).bfm_config.bit_time := C_BIT_PERIOD;


    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
    ------------------------------------------------------------
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default");
    sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default");
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default");
    await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);


    log(ID_LOG_HDR, "UART Transmit - no error injection", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);


    log(ID_LOG_HDR, "UART Transmit - parity bit error injection", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(TX,1).error_injection.parity_bit_prob := 1.0;

    uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);

    shared_uart_vvc_config(TX,1).error_injection.parity_bit_prob := 0.0;



    log(ID_LOG_HDR, "UART Transmit - stop bit error injection", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(TX,1).error_injection.stop_bit_prob := 1.0;

    uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);

    shared_uart_vvc_config(TX,1).error_injection.stop_bit_prob := 0.0;


--    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE);
--    ------------------------------------------------------------
--    sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"55", "TX_DATA");
--    uart_expect(UART_VVCT,1,RX,  x"55", "Expecting data on UART RX");
--    await_completion(UART_VVCT,1,RX,  13 * C_BIT_PERIOD);
--    wait for 200 ns;  -- margin
--
--
--
--    log(ID_LOG_HDR, "Check simple receive", C_SCOPE);
--    ------------------------------------------------------------
--    uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
--    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
--    wait for 200 ns;  -- margin
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
--    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
--
--
--
--    log(ID_LOG_HDR, "Check single simultaneous transmit and receive", C_SCOPE);
--    ------------------------------------------------------------
--    sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"B4", "TX_DATA");
--    uart_transmit(UART_VVCT,1,TX,  x"87", "UART TX");
--    uart_expect(UART_VVCT,1,RX,  x"B4", "Expecting data on UART RX");
--    await_completion(UART_VVCT,1,TX, 13 * C_BIT_PERIOD);
--    wait for 200 ns;  -- margin
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"87", "RX_DATA");
--    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
--
--
--
--    log(ID_LOG_HDR, "Check multiple simultaneous receive and read", C_SCOPE);
--    ------------------------------------------------------------
--    uart_transmit(UART_VVCT,1,TX,  x"A1", "UART TX");
--    uart_transmit(UART_VVCT,1,TX,  x"A2", "UART TX");
--    uart_transmit(UART_VVCT,1,TX,  x"A3", "UART TX");
--    await_completion(UART_VVCT,1,TX,  3 * 13 * C_BIT_PERIOD);
--    wait for 200 ns;  -- margin
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"A1", "RX_DATA");
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"A2", "RX_DATA");
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"A3", "RX_DATA");
--    await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
--
--
--
--    log(ID_LOG_HDR, "Skew SBI read over UART receive ", C_SCOPE);
--    ------------------------------------------------------------
--    log("Setting up the UART VVC to transmit 102 samples to the DUT");
--    for i in 1 to 102 loop
--      uart_transmit(UART_VVCT,1,TX,  std_logic_vector(to_unsigned(16#80# + i, 8)), string'("Set up new data. Now byte # " & to_string(i)));
--    end loop;
--
--    log("Setting up the SBI VVC to read and check the DUT RX register after each completed UART TX operation");
--    insert_delay(SBI_VVCT,1, C_TIME_OF_ONE_UART_TX - 50 * C_CLK_PERIOD, "Inserting delay in SBI VVC to wait for first byte to complete");
--    for i in 1 to 100 loop
--      insert_delay(SBI_VVCT,1, C_TIME_OF_ONE_UART_TX, "Delaying for the time of one uart transmission");
--      insert_delay(SBI_VVCT,1, C_CLK_PERIOD, "Skewing the SBI read one clock cycle");
--      sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + i, 8)), "Reading data number " & to_string(i));
--    end loop;
--
--    await_completion(UART_VVCT,1,TX,  103 * C_TIME_OF_ONE_UART_TX);
--    wait for 50 ns; -- to assure UART RX complete internally
--    -- Check the last two bytes in the DUT RX buffer.
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 101, 8)), "Reading data number " & to_string(101));
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 102, 8)), "Reading data number " & to_string(102));
--    await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
--
--
--
--    log(ID_LOG_HDR, "Skew SBI read over UART receive with inter-BFM delay functionality", C_SCOPE);
--    ------------------------------------------------------------
--    -- This test case will test the same as the test case above, but using the built in delay functionality in the SBI VVC
--    log("Setting up the UART VVC to transmit 102 samples to the DUT");
--    for i in 1 to 102 loop
--      uart_transmit(UART_VVCT,1,TX,  std_logic_vector(to_unsigned(16#80# + i, 8)), string'("Set up new data. Now byte # " & to_string(i)));
--    end loop;
--
--    log("Setting up the SBI VVC to read and check the DUT RX register after each completed UART TX operation");
--    -- The SBI VVC will wait until the UART VVC is 50 clock periods away from successfully transmitting the second byte.
--    insert_delay(SBI_VVCT,1, C_TIME_OF_ONE_UART_TX, "Insert delay in SBI VVC until the first UART transmission has completed");
--    insert_delay(SBI_VVCT,1, C_TIME_OF_ONE_UART_TX - 50 * C_CLK_PERIOD, "Inserting delay in SBI VVC until second UART transmission has almost completed");
--
--    log("Setting the SBI VVC to separate each BFM access with 1760 ns");
--    shared_sbi_vvc_config(1).inter_bfm_delay.delay_type := TIME_START2START;
--    shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time := C_TIME_OF_ONE_UART_TX+C_CLK_PERIOD;
--
--    for i in 1 to 100 loop
--      sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + i, 8)), "Reading data number " & to_string(i));
--    end loop;
--
--    await_completion(UART_VVCT,1,TX,  103 * C_TIME_OF_ONE_UART_TX);
--    await_completion(SBI_VVCT,1, 2 * C_TIME_OF_ONE_UART_TX);
--
--    wait for 50 ns; -- to assure UART RX complete internally
--    -- Check the last two bytes in the DUT RX buffer.
--    log("Setting the SBI VVC back to no delay between BFM accesses");
--    shared_sbi_vvc_config(1).inter_bfm_delay.delay_type := NO_DELAY;
--    shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time := 0 ns;
--
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 101, 8)), "Reading data number " & to_string(101));
--    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 102, 8)), "Reading data number " & to_string(102));
--    await_completion(SBI_VVCT,1,  2*C_TIME_OF_ONE_UART_TX);


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
