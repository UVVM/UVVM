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

library bitvis_vip_spec_cov;
use bitvis_vip_spec_cov.spec_cov_pkg.all;

--hdlregression:tb
-- Test bench entity
entity uart_vvc_tb is
  generic (
    GC_TESTCASE    : natural := 0;
    GC_SCRIPT_PATH : string  := ""
  );
end entity;

-- Test bench architecture
architecture func of uart_vvc_tb is

  -- Assuming that the testbench is run from the sim folder
  constant C_REQ_LIST_FILE      : string := GC_SCRIPT_PATH & "../demo/advanced_usage/req_list_advanced_demo.csv";
  constant C_PARTIAL_COV_FILE   : string := GC_SCRIPT_PATH & "../sim/partial_cov_advanced_demo_T" & to_string(GC_TESTCASE) & ".csv";

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
  i_test_harness : entity work.uart_vvc_th;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process
  begin

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_SPEC_COV_INIT);   -- Enable the Spec Cov IDs
    enable_log_msg(ID_SPEC_COV_REQS);   -- Enable the Spec Cov IDs
    enable_log_msg(ID_SPEC_COV);        -- Enable the Spec Cov IDs

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, 1, ID_BFM);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM);


    log(ID_LOG_HDR, "Starting simulation of TB for UART using VVCs", C_SCOPE);
    ------------------------------------------------------------
    log("Wait 10 clock period for reset to be turned off");
    wait for (10 * C_CLK_PERIOD); -- for reset to be turned off


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    ------------------------------------------------------------
    shared_uart_vvc_config(RX,1).bfm_config.bit_time := C_BIT_PERIOD;
    shared_uart_vvc_config(TX,1).bfm_config.bit_time := C_BIT_PERIOD;


    -- If statement to determine which testcase to run
    if (GC_TESTCASE = 0) then
      log("Starting the requirement coverage process");
      initialize_req_cov("T_UART_DEFAULTS", C_REQ_LIST_FILE, C_PARTIAL_COV_FILE);

      log(ID_LOG_HDR, "T_UART_DEFAULTS - Check register defaults", C_SCOPE);
      ------------------------------------------------------------
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default");
      await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
      -- Log the requirement FPGA_SPEC_1.a after test has completed
      tick_off_req_cov("FPGA_SPEC_1.a");

      sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default");
      await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
      -- Log the requirement FPGA_SPEC_1.b after test has completed
      tick_off_req_cov("FPGA_SPEC_1.b");

      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default");
      await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
      -- Log the requirement FPGA_SPEC_1.c after test has completed
      tick_off_req_cov("FPGA_SPEC_1.c");

      -- End the requirement coverage process
      finalize_req_cov(VOID);


    elsif (GC_TESTCASE = 1) then
      log("Starting the requirement coverage process");
      initialize_req_cov("T_UART_TX", C_REQ_LIST_FILE, C_PARTIAL_COV_FILE);

      log(ID_LOG_HDR, "T_UART_TX - Check simple transmit", C_SCOPE);
      ------------------------------------------------------------
      sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"55", "TX_DATA");
      uart_expect(UART_VVCT,1,RX,  x"55", "Expecting data on UART RX");
      await_completion(UART_VVCT,1,RX,  13 * C_BIT_PERIOD);
      -- Log the requirement FPGA_SPEC_2 after test has completed
      tick_off_req_cov("FPGA_SPEC_2");
      wait for 200 ns;  -- margin

      -- End the requirement coverage process
      finalize_req_cov(VOID);

      
    elsif (GC_TESTCASE = 2) then
      log("Starting the requirement coverage process");
      initialize_req_cov("T_UART_RX", C_REQ_LIST_FILE, C_PARTIAL_COV_FILE);

      log(ID_LOG_HDR, "T_UART_RX - Check simple receive", C_SCOPE);
      ------------------------------------------------------------
      uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
      await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
      wait for 200 ns;  -- margin
      sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
      await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
      -- Log the requirement FPGA_SPEC_3 after test has completed
      tick_off_req_cov("FPGA_SPEC_3");

      -- End the requirement coverage process
      finalize_req_cov(VOID);


    elsif (GC_TESTCASE = 3) then
      log("Starting the requirement coverage process");
      initialize_req_cov("T_UART_SIMULTANEOUS", C_REQ_LIST_FILE, C_PARTIAL_COV_FILE);

      log(ID_LOG_HDR, "T_UART_SIMULTANEOUS - Check single simultaneous transmit and receive", C_SCOPE);
      ------------------------------------------------------------
      sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"B4", "TX_DATA");
      uart_transmit(UART_VVCT,1,TX,  x"87", "UART TX");
      uart_expect(UART_VVCT,1,RX,  x"B4", "Expecting data on UART RX");
      await_completion(UART_VVCT,1,TX, 13 * C_BIT_PERIOD);
      wait for 200 ns;  -- margin
      sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"87", "RX_DATA");
      await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
      -- Log the requirement FPGA_SPEC_4 after test has completed
      tick_off_req_cov("FPGA_SPEC_4");

      -- End the requirement coverage process
      finalize_req_cov(VOID);

    end if;

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