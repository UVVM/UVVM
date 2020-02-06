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

library bitvis_vip_spec_cov;
use bitvis_vip_spec_cov.spec_cov_pkg.all;
use bitvis_vip_spec_cov.local_adaptations_pkg.all;


entity spec_cov_tb is
  generic (
    GC_TEST : string := "UVVM"
    );
end entity spec_cov_tb;


architecture func of spec_cov_tb is

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE            : string  := "UVVM TB";
    constant C_DEFAULT_TESTCASE : string  := "T_DEFAULT";


    -- helper procedures
    procedure provoke_uvvm_status_error(alert_level : t_alert_level) is
    begin
      log(ID_SEQUENCER, "Incrementing stop limit and setting an alert.", C_SCOPE);
      check_value(true = false, alert_level, "triggering alert");
    end procedure;


  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TEST & "_Log.txt");
    set_alert_file_name(GC_TEST & "_Alert.txt");

    shared_spec_cov_config := C_SPEC_COV_CONFIG_DEFAULT;
    set_alert_stop_limit(TB_ERROR, 2);


    if GC_TEST = "test_init_with_no_requirement_file" then
      log(ID_LOG_HDR, "Testing initialize_req_cov() with not requirement file.", C_SCOPE);
      initialize_req_cov("T_SPEC_COV_1", "test_requirement_1.csv");
      log_req_cov("SPEC_COV_REQ_1");
      finalize_req_cov(VOID);

    elsif GC_TEST = "test_init_with_requirement_file" then
      log(ID_LOG_HDR, "Testing initialize_req_cov() with a requirement file.", C_SCOPE);
      initialize_req_cov("T_SPEC_COV_2", "../internal_tb/simple_req_file.csv", "test_requirement_2.csv");
      log_req_cov("SPEC_COV_REQ_2");
      finalize_req_cov(VOID);

    elsif GC_TEST = "test_log_default_testcase_and_not_listed" then
      log(ID_LOG_HDR, "Testing log_req_cov() with default testcase, unknown testcase and unknown requirement label.", C_SCOPE);
      initialize_req_cov("T_SPEC_COV_3", "../internal_tb/simple_req_file.csv", "test_requirement_3.csv");
      log_req_cov("SPEC_COV_REQ_3");
      log_req_cov("SPEC_COV_REQ_3", "T_SPEC_COV_50");
      log_req_cov("SPEC_COV_REQ_10", "T_SPEC_COV_1");
      finalize_req_cov(VOID);
      
    elsif GC_TEST = "test_log_testcase_pass_and_fail" then
      log(ID_LOG_HDR, "Testing log_req_cov() with no test_status (i.e. PASS) and test_status=FAIL.", C_SCOPE);
      initialize_req_cov("T_SPEC_COV_4", "../internal_tb/simple_req_file.csv", "test_requirement_4.csv");
      log_req_cov("SPEC_COV_REQ_4", "T_SPEC_COV_4_FAIL", FAIL);
      log_req_cov("SPEC_COV_REQ_4", "T_SPEC_COV_4");
      finalize_req_cov(VOID);

    elsif GC_TEST = "test_uvvm_status_error_before_log" then
      log(ID_LOG_HDR, "Testing log_req_cov() with UVVM status error triggered prior to initialize_req_cov().", C_SCOPE);

      -- Provoking tb_error and incrementing alert stop limit
      provoke_uvvm_status_error(TB_ERROR);

      -- Run testcase
      initialize_req_cov("T_SPEC_COV_5", "../internal_tb/simple_req_file.csv", "test_requirement_5.csv");   
      log_req_cov("SPEC_COV_REQ_5", PASS);  
      finalize_req_cov(VOID);

      -- Increment expected alerts so test will pass
      increment_expected_alerts(TB_ERROR, 1);

        
    elsif GC_TEST = "test_uvvm_status_error_after_log" then
      log(ID_LOG_HDR, "Testing log_req_cov() with UVVM status error triggered after log_req_cov() and prior to finalize_req_cov().", C_SCOPE);

      -- Run testcase
      initialize_req_cov("T_SPEC_COV_6", "../internal_tb/simple_req_file.csv", "test_requirement_6.csv");   
      log_req_cov("SPEC_COV_REQ_6", PASS);
      -- Provoking tb_error and incrementing alert stop limit
      provoke_uvvm_status_error(TB_ERROR);
      -- End testcase
      finalize_req_cov(VOID);
      -- Increment expected alerts so test will pass
      increment_expected_alerts(TB_ERROR, 1);

    elsif GC_TEST = "test_open_no_existing_req_file" then
      log(ID_LOG_HDR, "Testing initialize_req_cov() with non-existing requirement file.", C_SCOPE);

      increment_expected_alerts(TB_ERROR, 1);
      -- Run testcase
      initialize_req_cov("T_SPEC_COV_7", "../internal_tb/non_existing_req_file.csv", "test_requirement_7.csv");   
      -- End testcase
      finalize_req_cov(VOID);          



--    elsif GC_TEST = "initialize_req_cov_with_tc" then
--      initialize_req_cov("../internal_tb/req_to_test_map_example_2.csv");
--      finalize_req_cov(VOID);
--
--    elsif GC_TEST = "reset_of_req_cov_matrix" then
--      initialize_req_cov("../internal_tb/req_to_test_map_example_2.csv");
--      finalize_req_cov(VOID);
--      log("Resetting the data objects");
--      initialize_req_cov("../internal_tb/req_to_test_map_example_2.csv");
--      finalize_req_cov(VOID);
--
--    elsif GC_TEST = "requirement_exists" then
--      initialize_req_cov("../internal_tb/req_to_test_map_example_1.csv");
--      check_value(requirement_exists("FPGA_SPEC_1"), error, "Checking existing requirement 1");
--      check_value(requirement_exists("FPGA_SPEC_2"), error, "Checking existing requirement 2");
--      check_value(requirement_exists("FPGA_SPEC_3"), error, "Checking existing requirement 3");
--      check_value(requirement_exists("FPGA_SPEC_4"), error, "Checking existing requirement 4");
--      check_value(requirement_exists(" FPGA_SPEC_1"), false, error, "Checking non-existing requirement 1");
--      check_value(requirement_exists("FPGA_SPEC_5"), false, error, "Checking non-existing requirement 2");
--      check_value(requirement_exists("FPGA_SPEC_1 "), false, error, "Checking non-existing requirement 3");
--      check_value(requirement_exists("not a valid requirement"), false, error, "Checking non-existing requirement 4");
--      finalize_req_cov(VOID);
--
--    elsif GC_TEST = "requirement_and_tc_exists" then
--      initialize_req_cov("../internal_tb/req_to_test_map_example_2.csv");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_1", "TC_TOP_01"), error, "Checking existing requirement and tc 1");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_2", "TC_UART_1"), error, "Checking existing requirement and tc 2");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_2"), error, "Checking existing requirement and tc 3");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_3"), error, "Checking existing requirement and tc 4");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_4"), error, "Checking existing requirement and tc 5");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_4", "TC_UART_5"), error, "Checking existing requirement and tc 6");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_1", "TC_UART_2"), false, error, "Checking existing requirement, misplaced tc");
--      check_value(requirement_and_tc_exists("non_ext", "TC_UART_2"), false, error, "Checking non-existing requirement, existing tc");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "non ext"), false, error, "Checking existing requirement, non-existing tc");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_3 "), false, error, "Checking existing requirement, non-existing tc");
--      check_value(requirement_and_tc_exists("FPGA_SPEC_3", " TC_UART_3"), false, error, "Checking existing requirement, non-existing tc");
--      finalize_req_cov(VOID);
--
--    elsif GC_TEST = "log_req_cov_normal" then
--      initialize_req_cov("../internal_tb/req_to_test_map_example_2.csv", "../sim/log_req_cov_normal.csv");
--      log_req_cov("FPGA_SPEC_1", "tc_TOP_01");
--      log_req_cov("FPGA_SPEC_2", "TC_UART_1", false);
--      log_req_cov("FPGA_SPEC_3", "TC_UART_4");
--      log_req_cov("FPGA_SPEC_4", "TC_UART_5");
--      finalize_req_cov(VOID);
--
--    elsif GC_TEST = "log_req_cov_with_error" then
--      initialize_req_cov("../internal_tb/req_to_test_map_example_2.csv", "../sim/log_req_cov_with_error.csv");
--      log_req_cov("FPGA_SPEC_1", "TC_TOP_01");
--      log_req_cov("FPGA_SPEC_2", "TC_UART_1");
--
--      -- Increment error stop limit for this test
--      set_alert_stop_limit(error, 2);
--      error("Verifying that a test is failed when an error occurs. Expecting the following requirements in this test run to fail");
--
--      log_req_cov("FPGA_SPEC_3", "TC_UART_4");
--      log_req_cov("FPGA_SPEC_4", "TC_UART_5");
--      increment_expected_alerts(error, 1, "Incrementing expected errors after the log_req_cov function has been run");
--      finalize_req_cov(VOID);

    else
      alert(tb_error, "Unsupported test");
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
