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

library bitvis_vip_spec_cov;
use bitvis_vip_spec_cov.spec_cov_pkg.all;

--hdlregression:tb
entity spec_cov_tb is
  generic(
    GC_TESTCASE         : string := "UVVM";
    GC_TB_REQ_FILE      : string := "";     -- "../tb/maintenance_tb/tb_tests_req_file.csv";
    GC_REQ_FILE_EMPTY   : string := "";     -- "../tb/maintenance_tb/req_file_empty.csv"
    GC_MIX_REQ_FILE     : string := "";     -- "../tb/maintenance_tb/mix_req_file.csv";
    GC_MIX_MAP_FILE     : string := "";     -- "../tb/maintenance_tb/mix_map_file.csv";
    GC_GENERAL_REQ_FILE : string := "";
    GC_GENERAL_MAP_FILE : string := ""
  );
end entity spec_cov_tb;

architecture func of spec_cov_tb is

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    constant C_SCOPE            : string := "UVVM TB";
    constant C_DEFAULT_TESTCASE : string := "T_DEFAULT";

    -- helper procedures
    procedure provoke_uvvm_status_error(alert_level : t_alert_level) is
    begin
      check_value(true = false, alert_level, "triggering alert");
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    shared_spec_cov_config := C_SPEC_COV_CONFIG_DEFAULT;

    if GC_TESTCASE = "test_init_with_no_requirement_file" then
      --
      -- This test will test initialize_req_cov() without a 
      -- requirement input file
      --
      log(ID_LOG_HDR, "Testing initialize_req_cov() with no requirement file.", C_SCOPE);
      -- Run testcase
      initialize_req_cov("TC_NO_REQ_FILE", "pc_no_req_file.csv");
      tick_off_req_cov("REQ_1");
      -- End testcase
      finalize_req_cov(VOID);

    elsif GC_TESTCASE = "general_tests" then
      --
      -- This test will test a series of different requirement types and scenarios based on
      -- general_req_file.csv and general_map_file.csv
      --
      log(ID_LOG_HDR, "Testing various scenarios.", C_SCOPE);

      if GC_GENERAL_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        --------------
        -- Run TC_1
        --------------
        initialize_req_cov("TC_1", GC_GENERAL_REQ_FILE, "pc_tc_1.csv", GC_GENERAL_MAP_FILE);
        tick_off_req_cov("REQ_NO_TCS");
        tick_off_req_cov("REQ_ANDOR_COMPLIANT");
        tick_off_req_cov("REQ_ANDOR_NONCOMPLIANT");
        tick_off_req_cov("REQ_EXTRA_TICKOFFS");
        tick_off_req_cov("REQ_WRONG_TC");
        tick_off_req_cov("REQ_SUB_1");
        tick_off_req_cov("REQ_SUB_ANDOR");

        -- Tick off with explicit fail
        tick_off_req_cov("REQ_TICKOFF_FAIL", FAIL);

        -- Tick off compound requirement. Expect warning
        increment_expected_alerts(TB_WARNING, 1);
        tick_off_req_cov("REQ_COMPOUND_TICKOFF");

        -- Tick off unlisted requirement. Expect warning
        increment_expected_alerts(TB_WARNING, 1);
        tick_off_req_cov("REQ_UNLISTED_PASS", NA, "Tick off unlisted requirement");

        -- Tick off requirements with same name as existing req +/- one character
        increment_expected_alerts(TB_WARNING, 2);
        log(ID_SEQUENCER, "Tick of requirement name part of non-existing requirement name, expecting raised alert.", C_SCOPE);
        tick_off_req_cov("REQ_BASIC2");
        log(ID_SEQUENCER, "Tick of with only part of requirement name, expecting raised alert.", C_SCOPE);
        tick_off_req_cov("REQ_BASI");
        log(ID_SEQUENCER, "Tick of with correct requirement name.", C_SCOPE);
        tick_off_req_cov("REQ_BASIC", PASS);

        -- End testcase
        finalize_req_cov(VOID);

        --------------
        -- Run TC_2
        --------------
        initialize_req_cov("TC_2", GC_GENERAL_REQ_FILE, "pc_tc_2.csv", GC_GENERAL_MAP_FILE);
        tick_off_req_cov("REQ_ANDOR_COMPLIANT");
        tick_off_req_cov("REQ_ANDOR_MISSING_TC");
        tick_off_req_cov("REQ_ANDOR_NONCOMPLIANT");
        tick_off_req_cov("REQ_EXTRA_TICKOFFS");
        tick_off_req_cov("REQ_SUB_2");
        tick_off_req_cov("REQ_SUB_ANDOR");
        finalize_req_cov(VOID);

        --------------
        -- Run TC_3
        --------------

        initialize_req_cov("TC_3", GC_GENERAL_REQ_FILE, "pc_tc_3.csv", GC_GENERAL_MAP_FILE);
        tick_off_req_cov("REQ_ANDOR_COMPLIANT");
        tick_off_req_cov("REQ_EXTRA_TICKOFFS");
        tick_off_req_cov("REQ_SUB_ANDOR");
        finalize_req_cov(VOID);

        --------------
        -- Run TC_FAIL
        --------------

        initialize_req_cov("TC_FAIL", GC_GENERAL_REQ_FILE, "pc_tc_fail.csv", GC_GENERAL_MAP_FILE);
        tick_off_req_cov("REQ_ANDOR_NONCOMPLIANT");
        tick_off_req_cov("REQ_NONCOMPLIANT");

        increment_expected_alerts(TB_WARNING, 1);
        tick_off_req_cov("REQ_UNLISTED_FAIL", NA, "Tick of unlisted requirement");


        log(ID_SEQUENCER, "\nProvoking a TB_ERROR to stop simulations.");
        -- Provoking tb_error to make testcase fail and simulation abort
        provoke_uvvm_status_error(TB_ERROR);

        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_uvvm_status_error_before_log" then
      --
      -- This test will test Spec Cov with an UVVM status error set prior to testcase.
      --
      log(ID_LOG_HDR, "Testing tick_off_req_cov() with UVVM status error triggered prior to initialize_req_cov().", C_SCOPE);
      if GC_TB_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Provoking tb_error and incrementing alert stop limit
        set_alert_stop_limit(TB_ERROR, 2);
        provoke_uvvm_status_error(TB_ERROR);
        -- Run testcase
        initialize_req_cov("TC_ERROR_BEFORE_TC", GC_TB_REQ_FILE, "pc_error_before_tc.csv");
        tick_off_req_cov("REQ_ERROR_BEFORE_TC");
        -- End testcase
        finalize_req_cov(VOID);
        -- Increment expected alerts so test will pass with provoked UVVM TB_ERROR
        increment_expected_alerts(TB_ERROR, 1);
      end if;

    elsif GC_TESTCASE = "test_uvvm_status_error_after_log" then
      --
      -- This test will test Spec Cov with an UVVM status error set during testcase.
      --
      log(ID_LOG_HDR, "Testing tick_off_req_cov() with UVVM status error triggered after tick_off_req_cov() and prior to finalize_req_cov().", C_SCOPE);
      if GC_TB_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_ERROR_DURING_TC", GC_TB_REQ_FILE, "pc_error_during_tc.csv");
        tick_off_req_cov("REQ_ERROR_DURING_TC", PASS);
        -- Provoking tb_error and incrementing alert stop limit
        set_alert_stop_limit(TB_ERROR, 2);
        provoke_uvvm_status_error(TB_ERROR);
        -- End testcase
        finalize_req_cov(VOID);
        -- Increment expected alerts so test will pass with provoked UVVM TB_ERROR
        increment_expected_alerts(TB_ERROR, 1);
      end if;

    elsif GC_TESTCASE = "test_open_no_existing_req_file" then
      --
      -- This test will test Spec Cov with an non-existing requirement file.
      --
      log(ID_LOG_HDR, "Testing initialize_req_cov() with non-existing requirement file.", C_SCOPE);
      increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
      -- Run testcase
      initialize_req_cov("TC_NONEXISTING_REQ_FILE", "../tb/maintenance_tb/non_existing_req_file.csv", "pc_nonexisting_req_file.csv");
      -- End testcase
      finalize_req_cov(VOID);

    elsif GC_TESTCASE = "test_list_single_tick_off" then
      --
      -- This test create Partial coverage file with the LIST_SINGLE_TICKOFF parameter
      --
      log(ID_LOG_HDR, "Testing single tick off.", C_SCOPE);
      if GC_TB_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_LIST_SINGLE_TICKOFF", GC_TB_REQ_FILE, "pc_list_single_tickoff.csv");

        for tick_off_idx in 1 to 5 loop
          tick_off_req_cov("REQ_LIST_SINGLE_TICKOFF", PASS, "tick_off_req_cov() run #" & to_string(tick_off_idx) & ".", LIST_SINGLE_TICKOFF, C_SCOPE);
        end loop;

        -- Tick off with LIST_SINGLE_TICKOFF, pass then fail
        for tick_off_idx in 1 to 5 loop
            tick_off_req_cov("REQ_LIST_SINGLE_TICKOFF_PF", PASS, "tick_off_req_cov() run #" & to_string(tick_off_idx) & ".", LIST_SINGLE_TICKOFF, C_SCOPE);
        end loop;

        tick_off_req_cov("REQ_LIST_SINGLE_TICKOFF_PF", FAIL, "tick_off_req_cov() TC failed.", LIST_SINGLE_TICKOFF, C_SCOPE);

        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_cond_tick_off" then
      --
      -- This test ........
      --
      log(ID_LOG_HDR, "Testing disabled and enabled cond_tick_off().", C_SCOPE);
      if GC_TB_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_COND_TICKOFF", GC_TB_REQ_FILE, "pc_cond_tickoff.csv");

        log(ID_SEQUENCER, "Call disable_cond_tick_off_req_cov(REQ_COND_TICKOFF) and expect warning for second call.", C_SCOPE);
        increment_expected_alerts(TB_WARNING, 1);
        disable_cond_tick_off_req_cov("REQ_COND_TICKOFF");
        disable_cond_tick_off_req_cov("REQ_COND_TICKOFF"); -- expect tb_warning for this call

        log(ID_SEQUENCER, "Call cond_tick_off_req_cov(REQ_COND_TICKOFF) expecting no tick off.", C_SCOPE);
        for tick_off_idx in 1 to 5 loop
          -- expecting no tick off
          cond_tick_off_req_cov("REQ_COND_TICKOFF", PASS, "cond_tick_off_req_cov() run #" & to_string(tick_off_idx) & ", with conditional disabled REQ_COND_TICKOFF tick off.", LIST_EVERY_TICKOFF, C_SCOPE);
        end loop;

        log(ID_SEQUENCER, "Call tick_off_req_cov(REQ_COND_TICKOFF) expecting tick off.", C_SCOPE);
        -- expecting tick off
        tick_off_req_cov("REQ_COND_TICKOFF", PASS, "tick_off_req_cov(), with conditional disabled REQ_TICKOFF tick off.", LIST_EVERY_TICKOFF, C_SCOPE);

        log(ID_SEQUENCER, "Call cond_tick_off_req_cov(REQ_ALWAYS_TICKOFF) expecting tick off.", C_SCOPE);
        -- expecting tick off
        cond_tick_off_req_cov("REQ_ALWAYS_TICKOFF", PASS, "cond_tick_off_req_cov(), with no conditional disabled REQ_ALWAYS_TICKOFF tick off.", LIST_EVERY_TICKOFF, C_SCOPE);

        log(ID_SEQUENCER, "Call enable_cond_tick_off_req_cov(REQ_COND_TICKOFF).", C_SCOPE);
        enable_cond_tick_off_req_cov("REQ_COND_TICKOFF");

        log(ID_SEQUENCER, "Call cond_tick_off_req_cov(REQ_COND_TICKOFF) expecting tick off.", C_SCOPE);
        -- expecting tick off
        cond_tick_off_req_cov("REQ_COND_TICKOFF", PASS, "tick_off_req_cov(), with conditional disabled REQ_COND_TICKOFF tick off.", LIST_EVERY_TICKOFF, C_SCOPE);

        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_open_empty_requirement_file" then
      --
      -- This test will test Spec Cov with an empty requirement file.
      --
      log(ID_LOG_HDR, "Testing initialize_req_cov() with an empty requirement file.", C_SCOPE);

      if GC_REQ_FILE_EMPTY = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        -- Run testcase
        initialize_req_cov("TC_EMPTY_REQ_FILE", GC_REQ_FILE_EMPTY, "pc_empty_req_file.csv");
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_no_existing_partial_cov_dir" then
      --
      -- This test will test Spec Cov with a non-existing partial coverage directory.
      --
      log(ID_LOG_HDR, "Testing initialize_req_cov() with non-existing partial coverage directory.", C_SCOPE);

      if GC_TB_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        -- Run testcase
        initialize_req_cov("TC_NONEXISTING_PC_DIR", GC_TB_REQ_FILE, "/missing_dir/pc_missing_dir.csv");
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    ---==========================================================================
    --
    -- The following tests are intended for verifying the run_spec_cov.py post 
    -- processing script, and will not explicitly test the spec_cov_pkg.
    --
    ---==========================================================================

    elsif GC_TESTCASE = "test_mix_listed_input_reqs" then
        --
        -- This test will use req/map-files with a mix between the old and the new requirement listing formats.
        --
        log(ID_LOG_HDR, "Testing input with mixed requirement listing formats.", C_SCOPE);
        if GC_MIX_REQ_FILE = "" then
            alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
        elsif GC_MIX_MAP_FILE = "" then
            alert(TB_NOTE, "Missing map file for testcase " & GC_TESTCASE);
        else
            -- Run testcase
            initialize_req_cov("TC_1", GC_MIX_REQ_FILE, "pc_mixed_format_a.csv", GC_MIX_MAP_FILE);
            -- Expecting 1 TB_WARNING for compound requirement tickoff
            increment_expected_alerts(TB_WARNING, 1);    
            tick_off_req_cov("REQ_1"); -- Compound requirement tickoff. Expect alert. 
            tick_off_req_cov("REQ_1A");
            tick_off_req_cov("REQ_1B"); -- Wrong TC
            tick_off_req_cov("REQ_2A");
            tick_off_req_cov("REQ_2B");
            tick_off_req_cov("REQ_3"); -- Wrong TC
            tick_off_req_cov("REQ_4A");
            tick_off_req_cov("REQ_4B");
            tick_off_req_cov("REQ_5A", FAIL); -- Fail 5A
            
            -- End testcase
            finalize_req_cov(VOID);

            -- Run different testcase
            initialize_req_cov("TC_2", GC_MIX_REQ_FILE, "pc_mixed_format_b.csv", GC_MIX_MAP_FILE);
            tick_off_req_cov("REQ_2A");
            tick_off_req_cov("REQ_2B");

            -- End testcase
            finalize_req_cov(VOID);
        end if;
    end if;

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
