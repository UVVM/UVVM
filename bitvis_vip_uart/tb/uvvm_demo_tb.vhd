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

  -- Time for one UART transmission to complete
  constant C_TIME_OF_ONE_UART_TX : time := 11*C_BIT_PERIOD; -- =1760 ns;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";



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
    enable_log_msg(ID_BFM);

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, 1, ID_BFM);
    enable_log_msg(SBI_VVCT, 1, ID_FINISH_OR_STOP);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM);


    ------------------------------------------------------------

    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD); -- for reset to be turned off


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX,1).bfm_config.bit_time := C_BIT_PERIOD;


--    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
--    ------------------------------------------------------------
--    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default");
--    sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default");
--    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default");
--    await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);


    log(ID_LOG_HDR, "UART Transmit - no error injection", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);

    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);


    log(ID_LOG_HDR, "UART Transmit - parity bit error injection", C_SCOPE);
    ------------------------------------------------------------
    log(ID_SEQUENCER, "Configure parity bit error injection", C_SCOPE);
    shared_uart_vvc_config(TX,1).error_injection.parity_bit_prob  := 1.0;
    shared_uart_vvc_config(TX,1).error_injection.stop_bit_prob    := 0.0;

    uart_transmit(UART_VVCT,1,TX,  x"55", "UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
    log(ID_SEQUENCER, "Disabling parity bit error", C_SCOPE);

    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"55", "RX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);




    log(ID_LOG_HDR, "UART Transmit - stop bit error injection", C_SCOPE);
    ------------------------------------------------------------
    log(ID_SEQUENCER, "Configure stop bit error injection", C_SCOPE);
    shared_uart_vvc_config(TX,1).error_injection.stop_bit_prob    := 1.0;
    shared_uart_vvc_config(TX,1).error_injection.parity_bit_prob  := 0.0;

    uart_transmit(UART_VVCT,1,TX,  x"55", "UART TX");
    await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
    log(ID_SEQUENCER, "Disabling stop bit error", C_SCOPE);
    shared_uart_vvc_config(TX,1).error_injection.stop_bit_prob := 0.0;

    wait for 200 ns;  -- margin
    sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"55", "RX_DATA");
    await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);



    log(ID_LOG_HDR, "SBI Write", C_SCOPE);
    ------------------------------------------------------------
    log(ID_SEQUENCER, "Status: " & to_string(shared_uart_vvc_config(TX,1).error_injection.stop_bit_prob), C_SCOPE);
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"55", "Write 0xAB to UART");
    await_completion(SBI_VVCT, 1, 13 * C_BIT_PERIOD);

    wait for 200 ns;
    uart_receive(UART_VVCT, 1, RX, TO_SB, "UART receive");
    await_completion(UART_VVCT, 1, RX, 13*C_BIT_PERIOD);


    -- print report of counters
    --v_uart_sb.report_counters(VOID);


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
