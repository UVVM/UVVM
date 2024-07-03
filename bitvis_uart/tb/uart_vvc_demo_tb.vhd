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
use bitvis_vip_sbi.vvc_methods_pkg.all;
use bitvis_vip_sbi.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_uart;
use bitvis_vip_uart.vvc_methods_pkg.all;
use bitvis_vip_uart.td_vvc_framework_common_methods_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

-- hdlregression:tb
-- Test bench entity
entity uart_vvc_demo_tb is
end entity uart_vvc_demo_tb;

-- Test bench architecture
architecture func of uart_vvc_demo_tb is

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;

  -- Clock and bit period settings
  constant C_CLK_PERIOD : time := 10 ns;
  constant C_BIT_PERIOD : time := 16 * C_CLK_PERIOD;

  -- Time for one UART transmission to complete
  constant C_TIME_OF_ONE_UART_TX : time := 11 * C_BIT_PERIOD; -- =1760 ns;

  -- Predefined SBI addresses
  constant C_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
  constant C_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
  constant C_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
  constant C_ADDR_TX_READY      : unsigned(2 downto 0) := "011";

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.uart_vvc_demo_th;

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
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

    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    ------------------------------------------------------------

    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off

    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(RX, 1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX, 1).bfm_config.bit_time := C_BIT_PERIOD;

    log(ID_LOG_HDR, "Check register defaults ", C_SCOPE);
    ------------------------------------------------------------
    -- This test will send three sbi_check commands to the SBI VVC, and then
    -- wait for them all to complete before continuing the test sequence.
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default");
    sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default");
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default");
    await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);

    log(ID_LOG_HDR, "Check simple transmit", C_SCOPE);
    ------------------------------------------------------------
    -- This test case will instruct the SBI VVC to send the data x"55" to the DUT C_ADDR_TX_DATA address.
    -- This will cause the DUT to transmit x"55" on the UART line. In order to receive the data, the
    -- UART VVC is instructed to expect the data x"55" on the RX port. The test sequence will not continue
    -- until the UART VVC has received the data from the DUT, indicated by the await_completion method.
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"55", "TX_DATA");
    uart_expect(UART_VVCT, 1, RX, x"55", "Expecting data on UART RX");
    await_completion(UART_VVCT, 1, RX, 13 * C_BIT_PERIOD);
    wait for 200 ns;                    -- margin

    log(ID_LOG_HDR, "Check simple receive", C_SCOPE);
    ------------------------------------------------------------
    -- In this test case the UART VVC (TX channel) is instructed to send the data x"AA" to the DUT.
    -- This data should be received and stored to a RX buffer by the DUT. After the UART VVC has completed
    -- the transmission, the SBI VVC is instructed to check read and check (sbi_check) the C_ADDR_RX_DATA
    -- register, and verify that it is in fact x"AA" that the DUT received. The test sequencer will continue
    -- when the SBI VVC is done checking the C_ADDR_RX_DATA register.
    uart_transmit(UART_VVCT, 1, TX, x"AA", "UART TX");
    await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
    wait for 200 ns;                    -- margin
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"AA", "RX_DATA");
    await_completion(SBI_VVCT, 1, 13 * C_BIT_PERIOD);

    log(ID_LOG_HDR, "Check single simultaneous transmit and receive", C_SCOPE);
    ------------------------------------------------------------
    -- Since the UART consists of two individual VVCs (TX and RX), it is capable of full duplex operation.
    -- This test case will instruct the SBI VVC to write x"B4" to the C_ADDR_TX_DATA register of the DUT,
    -- which will cause the DUT to send x"B4" on its UART TX line. Simultaneously, the UART VVC is instructed
    -- to both transmit x"87" to the DUT, and expect x"B4" from the DUT. When the UART VVC is done transmitting
    -- to the DUT, the SBI VVC will be instructed to read and check the DUT C_ADDR_RX_DATA register and verify
    -- that the DUT received the correct data from the UART VVC. After this check is completed, the test sequencer
    -- can continue to the next test case.
    sbi_write(SBI_VVCT, 1, C_ADDR_TX_DATA, x"B4", "TX_DATA");
    uart_transmit(UART_VVCT, 1, TX, x"87", "UART TX");
    uart_expect(UART_VVCT, 1, RX, x"B4", "Expecting data on UART RX");
    await_completion(UART_VVCT, 1, TX, 13 * C_BIT_PERIOD);
    wait for 200 ns;                    -- margin
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"87", "RX_DATA");
    await_completion(SBI_VVCT, 1, 13 * C_BIT_PERIOD);

    log(ID_LOG_HDR, "Check multiple simultaneous receive and read", C_SCOPE);
    ------------------------------------------------------------
    -- This test case will instruct the UART VVC to transmit three messages to the DUT. These UART VVC (TX channel)
    -- will add the three "uart_transmit" commands to the command queue, and execute them sequentially when
    -- await_completion is called. After the UART VVC is done transmitting, the SBI VVC is instructed to read and
    -- verify that the three consecutive bytes from the C_ADDR_RX_DATA register of the DUT are equal to the data
    -- transmitted from the UART VVC. When the SBI VVC is done with these checks, the testbench sequencer can continue
    -- to the next test case.
    uart_transmit(UART_VVCT, 1, TX, x"A1", "UART TX");
    uart_transmit(UART_VVCT, 1, TX, x"A2", "UART TX");
    uart_transmit(UART_VVCT, 1, TX, x"A3", "UART TX");
    await_completion(UART_VVCT, 1, TX, 3 * 13 * C_BIT_PERIOD);
    wait for 200 ns;                    -- margin
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"A1", "RX_DATA");
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"A2", "RX_DATA");
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"A3", "RX_DATA");
    await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);

    log(ID_LOG_HDR, "Skew SBI read over UART receive ", C_SCOPE);
    ------------------------------------------------------------
    -- This test case will show how using VVCs in UVVM can be used for simultaneous UART and SBI operation,
    -- which enables testing of corner cases. In the UART DUT one of these corner cases often occurs when the UART DUT
    -- must handle UART RX data and SBI reads simultaneously. To test if this is handled properly in the DUT,
    -- this test case will transmit data from the UART VVC, and check the data received in the C_ADDR_RX_DATA register.
    -- The DUT RX buffer will always contain at least one received byte, and the SBI VVC will check the oldest entry in
    -- the RX buffer. The UART VVC will be set up to transmit bytes to the DUT continuously. When the SBI_VVC checks the
    -- DUT RX buffer, relative to the UART TX operation, will vary on each iteration.
    -- First, the UART VVC will transmit a complete frame to the DUT. Then, when the UART VVC is 50 clock periods from
    -- completing the transmission of the second byte, the SBI VVC checks the DUT RX buffer for the first received byte.
    -- When the UART VVC is 49 clock periods from transmitting the third byte, the SBI VVC will check the DUT RX buffer
    -- for the second byte received. This process repeats until the SBI VVC is checking the DUT RX register 50 clock periods
    -- after the UART VVC has completed its transmission. At this point there will be two complete bytes in the DUT RX buffer
    -- when the SBI VVC reads from it. After the test is completed the two final bytes in the RX buffer are checked. When this
    -- is done, the test case is complete.
    log("Setting up the UART VVC to transmit 102 samples to the DUT");
    for i in 1 to 102 loop
      uart_transmit(UART_VVCT, 1, TX, std_logic_vector(to_unsigned(16#80# + i, 8)), string'("Set up new data. Now byte # " & to_string(i)));
    end loop;

    log("Setting up the SBI VVC to read and check the DUT RX register after each completed UART TX operation");
    -- 1760 ns is measured time from start of UART receive to received data is available in the DUT C_ADDR_RX_DATA register
    -- The SBI VVC will wait until the UART VVC is 50 clock periods away from successfully transmitting the first byte.
    insert_delay(SBI_VVCT, 1, C_TIME_OF_ONE_UART_TX - 50 * C_CLK_PERIOD, "Inserting delay in SBI VVC to wait for first byte to complete");
    for i in 1 to 100 loop
      -- Wait for the time of one complete UART transmission + one clock cycle (for skew).
      -- Every read will now be 1T later relative to a new byte being valid internally
      insert_delay(SBI_VVCT, 1, C_TIME_OF_ONE_UART_TX, "Delaying for the time of one uart transmission");
      insert_delay(SBI_VVCT, 1, C_CLK_PERIOD, "Skewing the SBI read one clock cycle");
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + i, 8)), "Reading data number " & to_string(i));
    end loop;

    await_completion(UART_VVCT, 1, TX, 103 * C_TIME_OF_ONE_UART_TX);
    wait for 50 ns;                     -- to assure UART RX complete internally
    -- Check the last two bytes in the DUT RX buffer.
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 101, 8)), "Reading data number " & to_string(101));
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 102, 8)), "Reading data number " & to_string(102));
    await_completion(SBI_VVCT, 1, 10 * C_CLK_PERIOD);

    log(ID_LOG_HDR, "Skew SBI read over UART receive with inter-BFM delay functionality", C_SCOPE);
    ------------------------------------------------------------
    -- This test case will test the same as the test case above, but using the built in delay functionality in the SBI VVC
    log("Setting up the UART VVC to transmit 102 samples to the DUT");
    for i in 1 to 102 loop
      uart_transmit(UART_VVCT, 1, TX, std_logic_vector(to_unsigned(16#80# + i, 8)), string'("Set up new data. Now byte # " & to_string(i)));
    end loop;

    log("Setting up the SBI VVC to read and check the DUT RX register after each completed UART TX operation");
    -- The SBI VVC will wait until the UART VVC is 50 clock periods away from successfully transmitting the second byte.
    insert_delay(SBI_VVCT, 1, C_TIME_OF_ONE_UART_TX, "Insert delay in SBI VVC until the first UART transmission has completed");
    insert_delay(SBI_VVCT, 1, C_TIME_OF_ONE_UART_TX - 50 * C_CLK_PERIOD, "Inserting delay in SBI VVC until second UART transmission has almost completed");

    log("Setting the SBI VVC to separate each BFM access with 1760 ns");
    shared_sbi_vvc_config(1).inter_bfm_delay.delay_type    := TIME_START2START;
    shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time := C_TIME_OF_ONE_UART_TX + C_CLK_PERIOD;

    for i in 1 to 100 loop
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + i, 8)), "Reading data number " & to_string(i));
    end loop;

    await_completion(UART_VVCT, 1, TX, 103 * C_TIME_OF_ONE_UART_TX);
    await_completion(SBI_VVCT, 1, 2 * C_TIME_OF_ONE_UART_TX);

    wait for 50 ns;                     -- to assure UART RX complete internally
    -- Check the last two bytes in the DUT RX buffer.
    log("Setting the SBI VVC back to no delay between BFM accesses");
    shared_sbi_vvc_config(1).inter_bfm_delay.delay_type    := NO_DELAY;
    shared_sbi_vvc_config(1).inter_bfm_delay.delay_in_time := 0 ns;

    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 101, 8)), "Reading data number " & to_string(101));
    sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, std_logic_vector(to_unsigned(16#80# + 102, 8)), "Reading data number " & to_string(102));
    await_completion(SBI_VVCT, 1, 2 * C_TIME_OF_ONE_UART_TX);

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

end func;
