--========================================================================================================================
-- Copyright (c) 2018 by Bitvis AS.  All rights reserved.
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

library bitvis_vip_spec_vs_verif;
use bitvis_vip_spec_vs_verif.spec_vs_verif_methods.all;


-- Test bench entity
entity uart_vvc_tb is
  generic (GC_TESTCASE : natural := 0);
end entity;

-- Test bench architecture
architecture func of uart_vvc_tb is

  -- Assuming that the testbench is run from the sim folder
  constant C_REQ_TO_TC_MAP_FILE : string := "../demo/advanced_usage/req_to_test_map.csv";
  constant C_REQ_OUTPUT_FILE    : string := "../sim/advanced_demo_req_output_file_TC" & to_string(GC_TESTCASE) & ".csv";

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

    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_FILE_PARSER);     -- Enable the Spec Vs Verif IDs
    enable_log_msg(ID_SPEC_VS_VERIF);   -- Enable the Spec Vs Verif IDs

    disable_log_msg(SBI_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(SBI_VVCT, 1, ID_BFM);

    disable_log_msg(UART_VVCT, 1, RX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, RX, ID_BFM);

    disable_log_msg(UART_VVCT, 1, TX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, 1, TX, ID_BFM);

    log("Setting strict testcase checking");
    shared_req_vs_cov_strict_testcase_checking := true;

    -- Start the requirement coverage process
    log("Starting the requirement coverage process");
    start_req_cov(C_REQ_TO_TC_MAP_FILE, C_REQ_OUTPUT_FILE);


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
      log(ID_LOG_HDR, "TC_DUT_DEFAULTS - Check register defaults", C_SCOPE);
      ------------------------------------------------------------
      -- First testcase - TC_DUT_DEFAULTS
      -- This testcase will read the DUT default values
      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA, x"00", "RX_DATA default");
      await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
      -- log result after checking requirement FPGA_SPEC_1.a
      log_req_cov("FPGA_SPEC_1.a", "TC_DUT_DEFAULTS_0");

      sbi_check(SBI_VVCT, 1, C_ADDR_TX_READY, x"01", "TX_READY default");
      await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
      -- log result after checking requirement FPGA_SPEC_1.b
      log_req_cov("FPGA_SPEC_1.b", "TC_DUT_DEFAULTS_1");

      sbi_check(SBI_VVCT, 1, C_ADDR_RX_DATA_VALID, x"00", "RX_DATA_VALID default");
      await_completion(SBI_VVCT,1,  10 * C_CLK_PERIOD);
      -- log result after checking requirement FPGA_SPEC_1.c
      log_req_cov("FPGA_SPEC_1.c", "TC_DUT_DEFAULTS_2");
    

    elsif (GC_TESTCASE = 1) then
      log(ID_LOG_HDR, "TC_UART_TX - Check simple transmit", C_SCOPE);
      ------------------------------------------------------------
      -- Second testcase - TC_UART_TX
      -- This testcase will check a UART TX operation
      sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"55", "TX_DATA");
      uart_expect(UART_VVCT,1,RX,  x"55", "Expecting data on UART RX");
      await_completion(UART_VVCT,1,RX,  13 * C_BIT_PERIOD);
      -- Log the requirement FPGA_SPEC_2 after testcase TC_UART_TX has completed
      log_req_cov("FPGA_SPEC_2", "TC_UART_TX");
      wait for 200 ns;  -- margin
      
      
    elsif (GC_TESTCASE = 2) then
      log(ID_LOG_HDR, "TC_UART_RX - Check simple receive", C_SCOPE);
      ------------------------------------------------------------
      -- Third testcase - TC_UART_RX
      -- This testcase will check a UART RX operation
      uart_transmit(UART_VVCT,1,TX,  x"AA", "UART TX");
      await_completion(UART_VVCT,1,TX,  13 * C_BIT_PERIOD);
      wait for 200 ns;  -- margin
      sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"AA", "RX_DATA");
      await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
      -- Log the requirement FPGA_SPEC_3 after testcase TC_UART_RX has completed
      log_req_cov("FPGA_SPEC_3", "TC_UART_RX");


    elsif (GC_TESTCASE = 3) then
      log(ID_LOG_HDR, "TC_UART_SIMULTANEOUS - Check single simultaneous transmit and receive", C_SCOPE);
      ------------------------------------------------------------
      -- Fourth testcase - TC_UART_SIMULTANEOUS
      -- This testcase will check simultaneous RX and TX operation
      sbi_write(SBI_VVCT,1,  C_ADDR_TX_DATA, x"B4", "TX_DATA");
      uart_transmit(UART_VVCT,1,TX,  x"87", "UART TX");
      uart_expect(UART_VVCT,1,RX,  x"B4", "Expecting data on UART RX");
      await_completion(UART_VVCT,1,TX, 13 * C_BIT_PERIOD);
      wait for 200 ns;  -- margin
      sbi_check(SBI_VVCT,1,  C_ADDR_RX_DATA, x"87", "RX_DATA");
      await_completion(SBI_VVCT,1,  13 * C_BIT_PERIOD);
      -- Log the requirement FPGA_SPEC_4 after testcase TC_UART_SIMULTANEOUS has completed
      log_req_cov("FPGA_SPEC_4", "TC_UART_SIMULTANEOUS");
    end if;

    -- End the requirement coverage process
    end_req_cov(VOID);
    
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
