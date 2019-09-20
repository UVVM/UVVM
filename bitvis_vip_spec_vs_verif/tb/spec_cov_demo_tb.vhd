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

library bitvis_vip_spec_vs_verif;
use bitvis_vip_spec_vs_verif.spec_vs_verif_methods.all;


entity spec_cov_demo_tb is
end entity;


architecture func of spec_cov_demo_tb is

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process

    constant C_SCOPE                : string   := "UVVM TB";
    variable v_alert_num_mismatch   : boolean  := false;


    procedure test_start_req_cov(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test requirement coverage", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_1.csv");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

    procedure test_start_req_cov_with_tc(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test requirement coverage with testcase", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_2.csv");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

    procedure test_reset_of_req_cov_matrix(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test reset of requirement matrix", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_2.csv");
      end_req_cov(VOID);
      log("Resetting the data objects");
      start_req_cov("../tb/req_to_test_map_example_2.csv");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

    procedure test_requirement_exists(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test requirement exists", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_1.csv");
      check_value(requirement_exists("FPGA_SPEC_1"), error, "Checking existing requirement 1");
      check_value(requirement_exists("FPGA_SPEC_2"), error, "Checking existing requirement 2");
      check_value(requirement_exists("FPGA_SPEC_3"), error, "Checking existing requirement 3");
      check_value(requirement_exists("FPGA_SPEC_4"), error, "Checking existing requirement 4");
      check_value(requirement_exists(" FPGA_SPEC_1"), false, error, "Checking non-existing requirement 1");
      check_value(requirement_exists("FPGA_SPEC_5"), false, error, "Checking non-existing requirement 2");
      check_value(requirement_exists("FPGA_SPEC_1 "), false, error, "Checking non-existing requirement 3");
      check_value(requirement_exists("not a valid requirement"), false, error, "Checking non-existing requirement 4");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

    procedure test_requirement_and_tc_exists(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test requirement and testcase exists", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_2.csv");
      check_value(requirement_and_tc_exists("FPGA_SPEC_1", "TC_TOP_01"), error, "Checking existing requirement and tc 1");
      check_value(requirement_and_tc_exists("FPGA_SPEC_2", "TC_UART_1"), error, "Checking existing requirement and tc 2");
      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_2"), error, "Checking existing requirement and tc 3");
      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_3"), error, "Checking existing requirement and tc 4");
      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_4"), error, "Checking existing requirement and tc 5");
      check_value(requirement_and_tc_exists("FPGA_SPEC_4", "TC_UART_5"), error, "Checking existing requirement and tc 6");
      check_value(requirement_and_tc_exists("FPGA_SPEC_1", "TC_UART_2"), false, error, "Checking existing requirement, misplaced tc");
      check_value(requirement_and_tc_exists("non_ext", "TC_UART_2"), false, error, "Checking non-existing requirement, existing tc");
      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "non ext"), false, error, "Checking existing requirement, non-existing tc");
      check_value(requirement_and_tc_exists("FPGA_SPEC_3", "TC_UART_3 "), false, error, "Checking existing requirement, non-existing tc");
      check_value(requirement_and_tc_exists("FPGA_SPEC_3", " TC_UART_3"), false, error, "Checking existing requirement, non-existing tc");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

    procedure test_log_req_cov_normal(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test requirement coverage normal run", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_2.csv", "../sim/log_req_cov_normal.csv");
      log_req_cov("FPGA_SPEC_1", "TC_TOP_01");
      log_req_cov("FPGA_SPEC_2", "TC_UART_1", false);
      log_req_cov("FPGA_SPEC_3", "TC_UART_4");
      log_req_cov("FPGA_SPEC_4", "TC_UART_5");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

    procedure test_log_req_cov_with_error(void : t_void) is
    begin
      log(ID_LOG_HDR, "Starting test requirement coverage with error run", C_SCOPE);

      start_req_cov("../tb/req_to_test_map_example_2.csv", "../sim/log_req_cov_with_error.csv");
      log_req_cov("FPGA_SPEC_1", "TC_TOP_01");
      log_req_cov("FPGA_SPEC_2", "TC_UART_1");

      -- Increment error stop limit for this test
      set_alert_stop_limit(error, 2);
      error("Verifying that a test is failed when an error occurs. Expecting the following requirements in this test run to fail");

      log_req_cov("FPGA_SPEC_3", "TC_UART_4");
      log_req_cov("FPGA_SPEC_4", "TC_UART_5");
      increment_expected_alerts(error, 1, "Incrementing expected errors after the log_req_cov function has been run");
      end_req_cov(VOID);
      wait for 100 ns; -- add small delay between tests
    end procedure;

  begin

    log(ID_LOG_HDR_XL, "Starting Specification Coverage tests.", C_SCOPE);
    wait for 10 ns;


    test_start_req_cov(VOID);
    test_start_req_cov_with_tc(VOID);
    test_reset_of_req_cov_matrix(VOID);
    test_requirement_exists(VOID);
    test_requirement_and_tc_exists(VOID);
    test_log_req_cov_normal(VOID);
    test_log_req_cov_with_error(VOID);



    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;             -- to allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely
  end process p_main;

end func;
