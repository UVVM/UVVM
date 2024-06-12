--================================================================================================================================
-- Copyright 2020 Bitvis
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
    GC_TESTCASE       : string := "UVVM";
    GC_REQ_FILE       : string := "";     -- "../tb/maintenance_tb/req_file.csv";
    GC_REQ_FILE_EMPTY : string := "";     -- "../tb/maintenance_tb/req_file_empty.csv"
    GC_SUB_REQ_FILE   : string := "";     -- "../tb/maintenance_tb/sub_req_file.csv";
    GC_UART_REQ_FILE  : string := "";     -- "../tb/maintenance_tb/uart_req_file.csv";
    GC_REQ_OMIT_MAP   : string := ""      -- "../tb/maintenance_tb/uart_omit_map_file.csv"
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
      initialize_req_cov("TC_1", "pc_1.csv");
      tick_off_req_cov("REQ_1");
      -- End testcase
      finalize_req_cov(VOID);

    elsif GC_TESTCASE = "test_init_with_requirement_file" then
      --
      -- This test will test initialize_req_cov() with a requirement input file
      --
      log(ID_LOG_HDR, "Testing initialize_req_cov() with a requirement file.", C_SCOPE);

      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_2", GC_REQ_FILE, "pc_2.csv");
        tick_off_req_cov("REQ_2");
        -- End testcase      
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_log_listed_and_not_listed_requirements" then
      --
      -- This test will test tick_off_req_cov() with listed and not listed requirements.
      --
      log(ID_LOG_HDR, "Testing tick_off_req_cov() with default testcase, unknown testcase and unknown requirement label.", C_SCOPE);

      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_3", GC_REQ_FILE, "pc_3.csv");
        -- 1: testing default testcase
        tick_off_req_cov("REQ_3");
        -- 2: testing unknown requirement
        -- Increment expected alerts so test will pass with missing requirement
        increment_expected_alerts(TB_WARNING, 1);
        tick_off_req_cov("REQ_99", NA, "logging unknown requirement."); --, C_SCOPE);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_log_testcase_pass_and_fail" then
      --
      -- This test will test tick_off_req_cov() with default (NA, i.e. PASS) and explicit FAIL.
      --
      log(ID_LOG_HDR, "Testing tick_off_req_cov() with no test_status (i.e. PASS) and test_status=FAIL.", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_4", GC_REQ_FILE, "pc_4.csv");
        tick_off_req_cov("REQ_4", FAIL);
        tick_off_req_cov("REQ_4", PASS);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_uvvm_status_error_before_log" then
      --
      -- This test will test Spec Cov with an UVVM status error set prior to testcase.
      --
      log(ID_LOG_HDR, "Testing tick_off_req_cov() with UVVM status error triggered prior to initialize_req_cov().", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Provoking tb_error and incrementing alert stop limit
        set_alert_stop_limit(TB_ERROR, 2);
        provoke_uvvm_status_error(TB_ERROR);
        -- Run testcase
        initialize_req_cov("TC_5", GC_REQ_FILE, "pc_5.csv");
        tick_off_req_cov("REQ_5");
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
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_6", GC_REQ_FILE, "pc_6.csv");
        tick_off_req_cov("REQ_6", PASS);
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
      initialize_req_cov("TC_7", "../tb/maintenance_tb/non_existing_req_file.csv", "pc_7.csv");
      -- End testcase
      finalize_req_cov(VOID);

    elsif GC_TESTCASE = "test_requirement_name_match" then
      --
      -- This test check if partial requirement names, and that don't exist, will trigger an alert.
      --
      log(ID_LOG_HDR, "Testing requirement name matching.", C_SCOPE);

      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        increment_expected_alerts(TB_WARNING, 2);
        -- Run testcase
        initialize_req_cov("TC_8", GC_REQ_FILE, "pc_12.csv");

        log(ID_SEQUENCER, "Tick of with only part of requirement name, expecting raised alert.", C_SCOPE);
        tick_off_req_cov("REQ_8");

        log(ID_SEQUENCER, "Tick of requirement name part of non-existing requirement name, expecting raised alert.", C_SCOPE);
        tick_off_req_cov("REQ_888");

        log(ID_SEQUENCER, "Tick of with correct requirement name.", C_SCOPE);
        tick_off_req_cov("REQ_88");

        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_list_single_tick_off" then
      --
      -- This test create Partial coverage file with the LIST_SINGLE_TICKOFF parameter
      --
      log(ID_LOG_HDR, "Testing single tick off.", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_9", GC_REQ_FILE, "pc_13.csv");

        for tick_off_idx in 1 to 5 loop
          tick_off_req_cov("REQ_9", PASS, "tick_off_req_cov() run #" & to_string(tick_off_idx) & ".", LIST_SINGLE_TICKOFF, C_SCOPE);
        end loop;

        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_list_single_tick_off_pass_then_fail" then
      --
      -- This test create Partial coverage file with the LIST_SINGLE_TICKOFF parameter as PASS,
      -- followed by LIST_SINGLE_TICK_OFF parameter as FAIL.
      --
      log(ID_LOG_HDR, "Testing single tick off.", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_10", GC_REQ_FILE, "pc_14.csv");

        for tick_off_idx in 1 to 5 loop
          tick_off_req_cov("REQ_10", PASS, "tick_off_req_cov() run #" & to_string(tick_off_idx) & ".", LIST_SINGLE_TICKOFF, C_SCOPE);
        end loop;

        tick_off_req_cov("REQ_10", FAIL, "tick_off_req_cov() TC failed.", LIST_SINGLE_TICKOFF, C_SCOPE);

        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_list_tick_off_disable" then
      --
      -- This test ........
      --
      log(ID_LOG_HDR, "Testing disabled and enabled tick_off().", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_10", GC_REQ_FILE, "pc_15.csv");

        log(ID_SEQUENCER, "Call disable_cond_tick_off_req_cov(REQ_10) and expect warning for second call.", C_SCOPE);
        increment_expected_alerts(TB_WARNING, 1);
        disable_cond_tick_off_req_cov("REQ_10");
        disable_cond_tick_off_req_cov("REQ_10"); -- expect tb_warning for this call

        log(ID_SEQUENCER, "Call cond_tick_off_req_cov(REQ_10) expecting no tick off.", C_SCOPE);
        for tick_off_idx in 1 to 5 loop
          -- expecting no tick off
          cond_tick_off_req_cov("REQ_10", PASS, "cond_tick_off_req_cov() run #" & to_string(tick_off_idx) & ", with conditional disabled REQ_10 tick off.", LIST_EVERY_TICKOFF, C_SCOPE);
        end loop;

        log(ID_SEQUENCER, "Call tick_off_req_cov(REQ_10) expecting tick off.", C_SCOPE);
        -- expecting tick off
        tick_off_req_cov("REQ_10", PASS, "tick_off_req_cov(), with conditional disabled REQ_10 tick off.", LIST_EVERY_TICKOFF, C_SCOPE);

        log(ID_SEQUENCER, "Call cond_tick_off_req_cov(REQ_9) expecting tick off.", C_SCOPE);
        -- expecting tick off
        cond_tick_off_req_cov("REQ_9", PASS, "cond_tick_off_req_cov(), with no conditional disabled REQ_9 tick off.", LIST_EVERY_TICKOFF, C_SCOPE);

        log(ID_SEQUENCER, "Call enable_cond_tick_off_req_cov(REQ_10).", C_SCOPE);
        enable_cond_tick_off_req_cov("REQ_10");

        log(ID_SEQUENCER, "Call cond_tick_off_req_cov(REQ_10) expecting tick off.", C_SCOPE);
        -- expecting tick off
        cond_tick_off_req_cov("REQ_10", PASS, "tick_off_req_cov(), with conditional disabled REQ_10 tick off.", LIST_EVERY_TICKOFF, C_SCOPE);

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
        initialize_req_cov("TC_11", GC_REQ_FILE_EMPTY, "pc_20.csv");
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_no_existing_partial_cov_dir" then
      --
      -- This test will test Spec Cov with a non-existing partial coverage directory.
      --
      log(ID_LOG_HDR, "Testing initialize_req_cov() with non-existing partial coverage directory.", C_SCOPE);

      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        increment_expected_alerts_and_stop_limit(TB_ERROR, 1);
        -- Run testcase
        initialize_req_cov("TC_12", GC_REQ_FILE, "/missing_dir/pc_21.csv");
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    ---==========================================================================
    --
    -- The following tests are intended for verifying the run_spec_cov.py post 
    -- processing script, and will not explicitly test the spec_cov_pkg.
    --
    ---==========================================================================
    elsif GC_TESTCASE = "test_sub_requirement_pass" then
      --
      -- This test will run requirements for testing sub-requirement processing with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing passing sub-requirement with test_status=NA, msg and SCOPE.", C_SCOPE);
      if GC_UART_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_1", GC_SUB_REQ_FILE, "pc_8.csv");
        tick_off_req_cov("REQ_1A", NA);
        tick_off_req_cov("REQ_1B", NA, "testing REQ_1B without scope");
        tick_off_req_cov("REQ_2A", PASS, "testing REQ_2A with scope", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("REQ_2B", PASS, "testing REQ_2B with scope", LIST_EVERY_TICKOFF, C_SCOPE);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_sub_requirement_fail" then
      --
      -- This test will run requirements for testing sub-requirement processing with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing failing sub-requirement with test_status=NA, msg and SCOPE.", C_SCOPE);
      if GC_UART_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_1", GC_SUB_REQ_FILE, "pc_9.csv");
        tick_off_req_cov("REQ_1A", NA);
        tick_off_req_cov("REQ_1B", NA, "testing REQ_1B without scope");
        tick_off_req_cov("REQ_2A", FAIL, "testing REQ_2A with scope", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("REQ_2B", PASS, "testing REQ_2B with scope", LIST_EVERY_TICKOFF, C_SCOPE);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_sub_requirement_incomplete" then
      --
      -- This test will run requirements for testing sub-requirement processing with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing incomplete sub-requirement tick off.", C_SCOPE);
      if GC_UART_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_SUB_REQ", GC_UART_REQ_FILE, "pc_19.csv");
        tick_off_req_cov("UART_REQ_BR_A", PASS, "testing UART_REQ_BR_A with scope", LIST_EVERY_TICKOFF, C_SCOPE);

        log(ID_SEQUENCER, "Not ticking off UART_REQ_BR_B.", C_SCOPE);
        --tick_off_req_cov("UART_REQ_BR_B", PASS, "testing UART_REQ_BR_B with scope", LIST_EVERY_TICKOFF, C_SCOPE);

        tick_off_req_cov("UART_REQ_ODD", PASS, "testing UART_REQ_ODD with scope", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_EVEN", PASS, "testing UART_REQ_EVEN with scope", LIST_EVERY_TICKOFF, C_SCOPE);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_sub_requirement_omitted" then
      --
      -- This test will run requirements for testing sub-requirement processing with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing omitted sub-requirement: UART_REQ_OMIT.", C_SCOPE);
      if GC_UART_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_SUB_REQ_OMIT", GC_UART_REQ_FILE, "pc_16.csv");
        tick_off_req_cov("UART_REQ_BR_A", PASS, "ticking off UART_REQ_BR_A", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_BR_B", PASS, "ticking off UART_REQ_BR_B", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_ODD", PASS, "ticking off UART_REQ_ODD", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_EVEN", PASS, "ticking off UART_REQ_EVEN", LIST_EVERY_TICKOFF, C_SCOPE);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_sub_requirement_omitted_check_pass" then
      --
      -- This test will run requirements for testing sub-requirement processing with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing omitted sub-requirement checked: UART_REQ_OMIT.", C_SCOPE);
      if GC_UART_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_SUB_REQ_OMIT", GC_UART_REQ_FILE, "pc_17.csv");
        tick_off_req_cov("UART_REQ_BR_A", PASS, "ticking off UART_REQ_BR_A", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_BR_B", PASS, "ticking off UART_REQ_BR_B", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_ODD", PASS, "ticking off UART_REQ_ODD", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_EVEN", PASS, "ticking off UART_REQ_EVEN", LIST_EVERY_TICKOFF, C_SCOPE);

        -- Expecting 1 TB_WARNING for omitted requirement UART_REQ_OMIT in this testcase
        increment_expected_alerts(TB_WARNING, 1);
        tick_off_req_cov("UART_REQ_OMIT", PASS, "ticking off UART_REQ_OMIT", LIST_EVERY_TICKOFF, C_SCOPE);
        
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_sub_requirement_omitted_check_fail" then
      --
      -- This test will run requirements for testing sub-requirement processing with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing omitted sub-requirement checked: UART_REQ_OMIT.", C_SCOPE);
      if GC_UART_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_SUB_REQ_OMIT", GC_UART_REQ_FILE, "pc_18.csv");
        tick_off_req_cov("UART_REQ_BR_A", PASS, "ticking off UART_REQ_BR_A", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_BR_B", PASS, "ticking off UART_REQ_BR_B", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_ODD", PASS, "ticking off UART_REQ_ODD", LIST_EVERY_TICKOFF, C_SCOPE);
        tick_off_req_cov("UART_REQ_EVEN", PASS, "ticking off UART_REQ_EVEN", LIST_EVERY_TICKOFF, C_SCOPE);
        
        -- Expecting 1 TB_WARNING for omitted requirement UART_REQ_OMIT in this testcase
        increment_expected_alerts(TB_WARNING, 1);        
        tick_off_req_cov("UART_REQ_OMIT", FAIL, "ticking off UART_REQ_OMIT", LIST_EVERY_TICKOFF, C_SCOPE);
        
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_incomplete_testcase" then
      --
      -- This test will run requirements for testing incomplete testcase with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing failing simulations with incomplete testcase.", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_1", GC_REQ_FILE, "pc_10.csv");
        tick_off_req_cov("REQ_1");
        log(ID_SEQUENCER, "\nProvoking a TB_ERROR to stop simulations.", C_SCOPE);
        -- Provoking tb_error to make testcase fail and simulation abort
        provoke_uvvm_status_error(TB_ERROR);
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_testcase_with_multiple_reqs" then
      --
      -- This test will run requirements for testing incomplete testcase with run_spec_cov.py
      --
      log(ID_LOG_HDR, "Testing logging multiple requirements with one testcase.", C_SCOPE);
      if GC_REQ_FILE = "" then
        alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
      else
        -- Run testcase
        initialize_req_cov("TC_1", GC_REQ_FILE, "pc_11.csv");
        tick_off_req_cov("REQ_1");
        tick_off_req_cov("REQ_2");
        tick_off_req_cov("REQ_3");
        tick_off_req_cov("REQ_4");
        -- End testcase
        finalize_req_cov(VOID);
      end if;

    elsif GC_TESTCASE = "test_combined_and_or_listed_testcases" then
        --
        -- This test will test requirements listed with a combination AND-listed and OR-listed testcases
        --
        log(ID_LOG_HDR, "Testing combination of AND- and OR- listed testcases.", C_SCOPE);
        if GC_REQ_FILE = "" then
          alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
        else
          -- Run testcase
          initialize_req_cov("TC_1", GC_REQ_FILE, "pc_combi.csv");
          tick_off_req_cov("REQ_1");
          tick_off_req_cov("REQ_2");
          tick_off_req_cov("REQ_3");
          tick_off_req_cov("REQ_4");
          -- End testcase
          finalize_req_cov(VOID);
        end if;

    elsif GC_TESTCASE = "test_strictness" then
        --
        -- This test will tick of requirements specified with the same TC, different TC and no TC
        -- For post-processing with various strictness levels
        --
        log(ID_LOG_HDR, "Testing tickoff in various TCs, for strictness testing.", C_SCOPE);
        if GC_UART_REQ_FILE = "" then
            alert(TB_NOTE, "Missing requirement file for testcase " & GC_TESTCASE);
        else
            -- Run testcase
            initialize_req_cov("TC_1", GC_REQ_FILE, "pc_20a.csv");
            tick_off_req_cov("REQ_1");  -- TC_1 specified -> Correct TC
            tick_off_req_cov("REQ_2");  -- TC_2 specified -> Wrong TC
            tick_off_req_cov("REQ_3");  -- TC_3 specified -> Wrong TC
            -- End testcase
            finalize_req_cov(VOID);

            -- Run different testcase
            initialize_req_cov("TC_2", GC_REQ_FILE, "pc_20b.csv");
            tick_off_req_cov("REQ_2"); -- TC_2 specified -> Correct TC
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
