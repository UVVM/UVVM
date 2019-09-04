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
entity dtt_demo_tb is
end entity;

-- Test bench architecture
architecture func of dtt_demo_tb is

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  constant C_SBI_VVC_IDX  : integer := 1;
  constant C_UART_VVC_IDX : integer := 1;
  constant C_CLOCK_VVC_IDX : integer := 1;

  -- Clock and bit period settings
  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD;

  -- Time for one UART transmission to complete
  constant C_TIME_OF_ONE_UART_TX : time := 11*C_BIT_PERIOD;  -- =1760 ns;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";


begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.dtt_demo_th
    generic map(
      GC_SBI_VVC_IDX => C_SBI_VVC_IDX,
      GC_UART_VVC_IDX => C_UART_VVC_IDX
    );


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
  begin

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    start_clock(CLOCK_GENERATOR_VVCT, C_CLOCK_VVC_IDX, "Start clock generator");

    -- Print the configuration to the log
    --report_global_ctrl(VOID);
    --report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    --enable_log_msg(ID_SEQUENCER_SUB);

    disable_log_msg(SBI_VVCT, C_SBI_VVC_IDX, ALL_MESSAGES);
    disable_log_msg(UART_VVCT, C_UART_VVC_IDX, RX, ALL_MESSAGES);
    disable_log_msg(UART_VVCT, C_UART_VVC_IDX, TX, ALL_MESSAGES);

    enable_log_msg(UART_VVCT, C_UART_VVC_IDX, TX, ID_BFM);
    enable_log_msg(UART_VVCT, C_UART_VVC_IDX, RX, ID_BFM);

    enable_log_msg(SBI_VVCT, C_SBI_VVC_IDX, ID_BFM);


    log(ID_LOG_HDR, "Starting simulation of Demo TB for DTT using UART and SBI VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(RX, C_UART_VVC_IDX).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, C_UART_VVC_IDX).bfm_config.bit_time := C_BIT_PERIOD;


    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
    ------------------------------------------------------------
    sbi_check(SBI_VVCT, C_SBI_VVC_IDX, C_ADDR_RX_DATA, x"00", "RX_DATA default");
    sbi_check(SBI_VVCT, C_SBI_VVC_IDX, C_ADDR_TX_READY, x"01", "TX_READY default");
    sbi_check(SBI_VVCT, C_SBI_VVC_IDX, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default");
    await_completion(SBI_VVCT, C_SBI_VVC_IDX, 10 * C_CLK_PERIOD);


    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT, C_SBI_VVC_IDX, C_ADDR_TX_DATA, x"55", "TX_DATA");

    wait for 200 ns;                    -- margin



    log(ID_LOG_HDR, "Check simple receive", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, x"AA", "UART TX");

    await_completion(UART_VVCT, C_UART_VVC_IDX, TX, 13 * C_BIT_PERIOD);
    wait for 200 ns;                    -- margin



    log(ID_LOG_HDR, "Check single simultaneous transmit and receive", C_SCOPE);
    ------------------------------------------------------------
    sbi_write(SBI_VVCT, C_SBI_VVC_IDX, C_ADDR_TX_DATA, x"B4", "TX_DATA");
    uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, x"87", "UART TX");

    await_completion(UART_VVCT, C_UART_VVC_IDX, TX, 13 * C_BIT_PERIOD);
    wait for 200 ns;                    -- margin
    --await_completion(SBI_VVCT, C_SBI_VVC_IDX,  10 * C_CLK_PERIOD);



    log(ID_LOG_HDR, "Check multiple simultaneous receive and read", C_SCOPE);
    ------------------------------------------------------------
    uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, x"A1", "UART TX");
    uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, x"A2", "UART TX");
    uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, x"A3", "UART TX");

    await_completion(UART_VVCT, C_UART_VVC_IDX, TX, 3 * 13 * C_BIT_PERIOD);

    wait for 200 ns;                    -- margin


--    log(ID_LOG_HDR, "Skew SBI read over UART receive ", C_SCOPE);
--    ------------------------------------------------------------
--    log("Setting up the UART VVC to transmit 102 samples to the DUT");
--    for i in 1 to 102 loop
--      uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, std_logic_vector(to_unsigned(16#80# + i, 8)), string'("Set up new data. Now byte # " & to_string(i)));
--    end loop;

--    log("Setting up the SBI VVC to read and check the DUT RX register after each completed UART TX operation");
--    -- 1760 ns is measured time from start of UART receive to received data is available in the DUT C_ADDR_RX_DATA register
--    -- The SBI VVC will wait until the UART VVC is 50 clock periods away from successfully transmitting the first byte.
--    insert_delay(SBI_VVCT, C_SBI_VVC_IDX, C_TIME_OF_ONE_UART_TX - 50 * C_CLK_PERIOD, "Inserting delay in SBI VVC to wait for first byte to complete");
--    for i in 1 to 100 loop
--      -- Wait for the time of one complete UART transmission + one clock cycle (for skew).
--      -- Every read will now be 1T later relative to a new byte being valid internally
--      insert_delay(SBI_VVCT, C_SBI_VVC_IDX, C_TIME_OF_ONE_UART_TX, "Delaying for the time of one uart transmission");
--      insert_delay(SBI_VVCT, C_SBI_VVC_IDX, C_CLK_PERIOD, "Skewing the SBI read one clock cycle");
--    end loop;

--    await_completion(UART_VVCT, C_UART_VVC_IDX, TX, 103 * C_TIME_OF_ONE_UART_TX);
--    wait for 50 ns;  -- to assure UART RX complete internally
--
--
--
--    log(ID_LOG_HDR, "Skew SBI read over UART receive with inter-BFM delay functionality", C_SCOPE);
--    ------------------------------------------------------------
--    -- This test case will test the same as the test case above, but using the built in delay functionality in the SBI VVC
--    log("Setting up the UART VVC to transmit 102 samples to the DUT");
--    for i in 1 to 102 loop
--      uart_transmit(UART_VVCT, C_UART_VVC_IDX, TX, std_logic_vector(to_unsigned(16#80# + i, 8)), string'("Set up new data. Now byte # " & to_string(i)));
--    end loop;
--
--    log("Setting up the SBI VVC to read and check the DUT RX register after each completed UART TX operation");
--    -- The SBI VVC will wait until the UART VVC is 50 clock periods away from successfully transmitting the second byte.
--    insert_delay(SBI_VVCT, C_SBI_VVC_IDX, C_TIME_OF_ONE_UART_TX, "Insert delay in SBI VVC until the first UART transmission has completed");
--    insert_delay(SBI_VVCT, C_SBI_VVC_IDX, C_TIME_OF_ONE_UART_TX - 50 * C_CLK_PERIOD, "Inserting delay in SBI VVC until second UART transmission has almost completed");
--
--    log("Setting the SBI VVC to separate each BFM access with 1760 ns");
--    shared_sbi_vvc_config(C_SBI_VVC_IDX).inter_bfm_delay.delay_type    := TIME_START2START;
--    shared_sbi_vvc_config(C_SBI_VVC_IDX).inter_bfm_delay.delay_in_time := C_TIME_OF_ONE_UART_TX+C_CLK_PERIOD;
--
--    await_completion(UART_VVCT, C_UART_VVC_IDX, TX, 103 * C_TIME_OF_ONE_UART_TX);
--
--    wait for 50 ns;  -- to assure UART RX complete internally
--    -- Check the last two bytes in the DUT RX buffer.
--    log("Setting the SBI VVC back to no delay between BFM accesses");
--    shared_sbi_vvc_config(C_SBI_VVC_IDX).inter_bfm_delay.delay_type    := NO_DELAY;
--    shared_sbi_vvc_config(C_SBI_VVC_IDX).inter_bfm_delay.delay_in_time := 0 ns;


    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;

end func;
