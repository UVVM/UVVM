--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- A free license is hereby granted, free of charge, to any person obtaining
-- a copy of this VHDL code and associated documentation files (for 'UVVM Utility Library'),
-- to use, copy, modify, merge, publish and/or distribute - subject to the following conditions:
--  - This copyright notice shall be included as is in all copies or substantial portions of the code and documentation
--  - The files included in UVVM Utility Library may only be used as a part of this library as a whole
--  - The License file may not be modified
--  - The calls in the code to the license file ('show_license') may not be removed or modified.
--  - No other conditions whatsoever may be added to those of this License

-- BITVIS UTILITY LIBRARY AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH BITVIS UTILITY LIBRARY.
--========================================================================================================================

------------------------------------------------------------------------------------------
-- VHDL unit     : UVVM Utility Library : methods_sync_tb
--
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library STD;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_run_context;

-- Import library with context. VHDL 2008 only!
library uvvm_util;
context uvvm_util.uvvm_util_context;


entity methods_sync_tb is
  generic (
    -- This generic is used to configure the testbench from run.py, e.g. what
    -- test case to run. The default value is used when not running from script
    -- and in that case all test cases are run.
    runner_cfg : runner_cfg_t := runner_cfg_default);
end entity;


architecture func of methods_sync_tb is
  -- For enableing another sequencer to block/unblock flags for synchronization methods.
  signal p_sync_test_ena : boolean := false;

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process

    constant C_SCOPE                : string   := "TB seq";
    variable v_alert_num_mismatch   : boolean  := false;
    variable v_alert_stop_limit     : natural;

    --alias uvvm_status is shared_uvvm_status.simulation_successful;
    alias found_unexpected_simulation_warnings_or_worse     is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
    alias found_unexpected_simulation_errors_or_worse       is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;
    alias mismatch_on_expected_simulation_warnings_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse;
    alias mismatch_on_expected_simulation_errors_or_worse   is shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse;

    -- Check the simulation_success update behavior
    procedure test_uvvm_status_simulation_successful(
      constant test_alert_type : t_alert_level
      ) is
      constant C_FAIL_STATUS_STRING        : string := "Expected that shared_uvvm_status indicate fail.";
      constant C_SUCCESS_STATUS_STRING     : string := "Expected that shared_uvvm_status indicate success.";
      constant C_MISMATCH_STATUS_STRING    : string := "Expected that shared_uvvm_status indicate mismatch.";
      constant C_NO_MISMATCH_STATUS_STRING : string := "Expected that shared_uvvm_status indicate no mismatch.";
    begin
      -- Update TB alert stop limit
      if (test_alert_type = TB_ERROR) or (test_alert_type = failure) or (test_alert_type = TB_FAILURE) then
        v_alert_stop_limit := get_alert_stop_limit(test_alert_type);
        set_alert_stop_limit(test_alert_type, v_alert_stop_limit + 2);
      end if;

      -- Set alert
      alert(test_alert_type, "Setting " & to_string(test_alert_type) & " alert for shared_uvvm_status simulation_successful status test.");

      -- Check that uvvm_status.simulation_successful indicate fail
      case test_alert_type is
        when warning =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   0, error, C_NO_MISMATCH_STATUS_STRING);
        when TB_WARNING =>
          ---check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   0, error, C_NO_MISMATCH_STATUS_STRING);
        when error =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when TB_ERROR =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when failure =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when TB_FAILURE =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when others =>
          null;
      end case;

      -- Update expected alert
      if (test_alert_type /= NO_ALERT) then
        increment_expected_alerts(test_alert_type, 1);
      end if;

      -- Check that uvvm_status indicate simulation success
      --check_value(uvvm_status, 1, ERROR, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_errors_or_worse,   0, error, C_NO_MISMATCH_STATUS_STRING);

      -- Increment expected alert
      if (test_alert_type /= NO_ALERT) then
        increment_expected_alerts(test_alert_type, 1);
      end if;

      -- Check that uvvm_status.simulation_successful indicate fail
      case test_alert_type is
        when warning =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   0, error, C_NO_MISMATCH_STATUS_STRING);
        when TB_WARNING =>
          ---check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   0, error, C_NO_MISMATCH_STATUS_STRING);
        when error =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when TB_ERROR =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when failure =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when TB_FAILURE =>
          --check_value(uvvm_status, 0, ERROR, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse,   1, error, C_MISMATCH_STATUS_STRING);
        when others =>
          null;
      end case;

      -- Update alert
      alert(test_alert_type, "Setting " & to_string(test_alert_type) & " alert for shared_uvvm_status simulation_successful status test.");

      -- Check that uvvm_status indicate simulation success
      --check_value(uvvm_status, 1, ERROR, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_warnings_or_worse,     0, error, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_errors_or_worse,       0, error, C_SUCCESS_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_errors_or_worse,   0, error, C_NO_MISMATCH_STATUS_STRING);
    end procedure;


  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other run.py provides separate test case
    -- directories through the runner_cfg generic (<root>/vunit_out/tests/<test case
    -- name>). When not using run.py the default path is the current directory
    -- (<root>/vunit_out/<simulator>). These directories are used by VUnit
    -- itself and these lines make sure that BVUL do to.
    set_log_file_name(join(output_path(runner_cfg), "testlog.txt"));
    set_alert_file_name(join(output_path(runner_cfg), "alertlog.txt"));

    -- Setup the VUnit runner with the input configuration.
    test_runner_setup(runner, runner_cfg);

    -- The default behavior for VUnit is to stop the simulation on a failing
    -- check when running from script but keep on running when running without
    -- script. The rationale for this and how you can change that behavior is
    -- described at the bottom of this file (see Stopping the Simulation on
    -- Failing Checks). The following if statement causes BVUL checks to behave
    -- in the same way.
    if not active_python_runner(runner_cfg) then
      set_alert_stop_limit(error, 0);
    end if;

    randomise(12, 14);
    randomize(14, 12);
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    set_alert_stop_limit(warning, 0);
    set_alert_stop_limit(error, 0);     -- 0 = Never stop
    wait for 1 ns;

    while test_suite loop

      if run("synchronization_methods") then
        --------------------------------------------------------------------------------------
        -- Verifying synchronnisation methods
        --------------------------------------------------------------------------------------
        log(ID_LOG_HDR, "Verifying synchronization methods");
        -- Enables process p_sync_test 
        p_sync_test_ena <= true;
        wait for 0 ns;

        log(ID_LOG_HDR, "Adding 10 blocked flags.", C_SCOPE);
        ------------------------------------------------------------
        increment_expected_alerts(WARNING); -- red_flag_3 will be added by p_sync_test
        for i in 1 to 10 loop
            block_flag("red_flag_" & to_string(i), "Block my flag nr: " & to_string(i));
        end loop;

        log(ID_LOG_HDR, "Unblocking 5 of the blocked flags.", C_SCOPE);
        ------------------------------------------------------------
        for i in 1 to 5 loop
            unblock_flag("red_flag_" & to_string(i), "unblock red_flag nr. " & to_string(i), global_trigger);
        end loop;
        -- Releasing flag p_sync_sec is waiting for
        unblock_flag("red_flag_6", " red 6 unblocked.", global_trigger);


        log(ID_LOG_HDR, "Await for flag to be unblocked.", C_SCOPE);
        ------------------------------------------------------------
        increment_expected_alerts(WARNING); -- Flag will not be unblocked. Will time out.
        await_unblock_flag("time_out_flag", 200 ns, "Never unblocked, Fail.", RETURN_TO_BLOCK, WARNING);

        await_unblock_flag("red_flag_1", 200 ns, "waiting for flag_for_await to be unblocked. Will timeout after 200 ns.", RETURN_TO_BLOCK, WARNING);

        unblock_flag("red_flag_7", "unblock red_flag nr. 7", global_trigger);

        await_unblock_flag("blue_flag_3", 0 ns, "wait for flag to be unblocked by other process.", RETURN_TO_BLOCK, WARNING, C_SCOPE);

        block_flag("last_flag", "this is the last flag.");

      end if;
    end loop;

    --==================================================================================================
    -- Ending the simulation
    --------------------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(INTERMEDIATE);
    report_alert_counters(FINAL);
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Check for mismatch in all alert levels except MANUAL_CHECK
    for alert_level in note to t_alert_level'right loop
      if alert_level /= MANUAL_CHECK and get_alert_counter(alert_level, REGARD) /= get_alert_counter(alert_level, EXPECT) then
        v_alert_num_mismatch := true;
      end if;
    end loop;

    test_runner_cleanup(runner, v_alert_num_mismatch);
    wait;

  end process p_main;

  ------------------------------------------------
  -- PROCESS: p_sync_test
  ------------------------------------------------
  p_sync_test : process
    constant C_SCOPE                : string   := "TB sync_seq";
  begin
    if not (p_sync_test_ena) then
      wait until p_sync_test_ena = true;
    end if;

    if (p_sync_test_ena) then
      await_unblock_flag("red_flag_6", 0 ns, "wait for flag to be unblocked by main sequencer.", RETURN_TO_BLOCK, WARNING, C_SCOPE);

      log(ID_LOG_HDR, "Adding 5 blocked and 5 unblocked flags.", C_SCOPE);
      ------------------------------------------------------------
      for i in 1 to 5 loop
          block_flag("blue_flag_" & to_string(i), "block blue_flag nr. " & to_string(i), WARNING, C_SCOPE);
      end loop;
      for i in 6 to 10 loop
          unblock_flag("blue_flag_" & to_string(i), "unblock blue_flag nr. " & to_string(i), global_trigger, C_SCOPE);
      end loop;

      await_unblock_flag("red_flag_7", 0 ns, "wait for flag to be unblocked by main sequencer.", RETURN_TO_BLOCK, WARNING, C_SCOPE);

      increment_expected_alerts(WARNING); -- blue_flag_3 is already blocked by p_main
      block_flag("blue_flag_3", "block blue_flag nr. 3", WARNING, C_SCOPE);
      unblock_flag("blue_flag_3", "unblock blue_flag nr. 3", global_trigger, C_SCOPE);



      wait;
    end if;
    --wait;
  end process p_sync_test;


end func;
