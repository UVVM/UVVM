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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

architecture log_arch of methods_tb is
begin

  p_main : process
    variable v_line             : line;
    variable v_alert_stop_limit : natural;

    alias found_unexpected_simulation_warnings_or_worse is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
    alias found_unexpected_simulation_errors_or_worse is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;
    alias mismatch_on_expected_simulation_warnings_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse;
    alias mismatch_on_expected_simulation_errors_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse;

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
      alert(test_alert_type, "Setting " & to_string(test_alert_type) & " alert for shared_uvvm_status test.");

      -- Check that shared_uvvm_status indicate fail
      case test_alert_type is
        when WARNING =>
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when TB_WARNING =>
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when ERROR =>
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_ERROR =>
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when FAILURE =>
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_FAILURE =>
          check_value(found_unexpected_simulation_warnings_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 1, error, C_FAIL_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when others =>
          null;
      end case;

      -- Update expected alert
      if (test_alert_type /= NO_ALERT) then
        increment_expected_alerts(test_alert_type, 1);
      end if;

      -- Check that shared_uvvm_status indicate simulation success
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);

      -- Increment expected alert
      if (test_alert_type /= NO_ALERT) then
        increment_expected_alerts(test_alert_type, 1);
      end if;

      -- Check that shared_uvvm_status indicate fail
      case test_alert_type is
        when WARNING =>
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when TB_WARNING =>
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
        when ERROR =>
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_ERROR =>
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when FAILURE =>
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when TB_FAILURE =>
          check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
          check_value(mismatch_on_expected_simulation_errors_or_worse, 1, error, C_MISMATCH_STATUS_STRING);
        when others =>
          null;
      end case;

      -- Update alert
      alert(test_alert_type, "Setting " & to_string(test_alert_type) & " alert for shared_uvvm_status simulation_successful status test.");

      -- Check that shared_uvvm_status indicate simulation success
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, C_SUCCESS_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
      check_value(mismatch_on_expected_simulation_errors_or_worse, 0, error, C_NO_MISMATCH_STATUS_STRING);
    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    wait for 1 ns;

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "basic_log_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      report_global_ctrl(VOID);
      report_msg_id_panel(VOID);
      set_alert_stop_limit(error, 0);

      -- Verifying logging and alerts
      log(ID_LOG_HDR, "Verifying logging and alerts", "");
      log(ID_LOG_HDR, "My Log header ");
      log(ID_BFM, "My short message", "My scope");
      alert(note, "my_msg dasdsa dasd as dad ad asd asd as das dasd adas dasd asda sdas das das das dsa dsa das das das das das das dasdasdasd asd", "my_scope");
      log(ID_BFM, "My long message  qqqqq w wwwww ee eee r rr r r t tt ttttttt y yyyyyyyy uuuuuuuu iii ii ii o o ooo o o ppppppp  aaaaaaaa              ssss ddddddffffff ffffff gggggg hhhhhh jjjjj" & LF & "ekstra", "My long scope............");
      log(ID_BFM, "My multiline message " & LF & "qqqqq w wwwww ee eee r rr r r t" & LF & "11 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa " & "extra" & LF & "lkkl fdafd fdsf sdfsdfsd f sdfsd f ds fsd fsdfsd f sdf sdf sdf dfsdfdsfsdf ds f dsf ds fsd fsd fsd fdsf sdf sdfsdf dsfds f sdfsdfsdf sdf dsf  BSN\nBSN \b fsd fs" & LF & "fdfdf sdfsd fsdf sd fds fsd fsd fs df sdf sdf sdf sd fsd fsdfsd fsdfsd fsd fsd f sdf sdf sd f sdf sdf d f df sdf ds fsd f sdf dsf ", "My .........");
      alert(error, "my_msg dasdas das dasdasdasd as das da sd asdas dasdasd  dasdasdsdasdas das d asd as das das das das dasdasdas das das d as das das dasd", "my_scope");
      log(ID_BFM, "Kort multiline" & LF & "ddasdadad" & LF & "daddfad ", "");
      log("Check various versions of linefeed (pre, post, only)");
      log("\n Pre, followed by blank");
      log("\nPre, followed by char");
      log("Post, preceeded by blank \n");
      log("Post, preceeded by char\n");
      log("Next is single linefeed only");
      log("\n");
      log("Linefeeds completed. Please check above");
      log("");
      log("1");
      log("Above two lines: First empty string, then single char.");

      -- Verifying shared_uvvm_status
      check_value(found_unexpected_simulation_warnings_or_worse, 1, error, "Alert check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse expected and actual mismatch");
      check_value(found_unexpected_simulation_errors_or_worse, 1, error, "Alert check shared_uvvm_status.found_unexpected_simulation_errors_or_worse expected and actual mismatch");
      increment_expected_alerts(error, 1);
      increment_expected_alerts(note, 1);
      check_value(found_unexpected_simulation_warnings_or_worse, 0, error, "Alert check shared_uvvm_status.found_unexpected_simulation_warnings_or_worse correctly updated");
      check_value(found_unexpected_simulation_errors_or_worse, 0, error, "Alert check shared_uvvm_status.found_unexpected_simulation_errors_or_worse correctly updated");

      -- Check all alert level types
      for test_alert in uvvm_util.types_pkg.t_alert_level loop
        test_uvvm_status_simulation_successful(test_alert);
      end loop;

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "enable_disable_log_msg" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying disable_log_msg and enable_log_msg", "");
      log(ID_BFM, "ID_BFM enabled", "My scope");
      check_value(is_log_msg_enabled(ID_BFM), true, error, "check ID_BFM enabled");
      disable_log_msg(ID_BFM);
      check_value(is_log_msg_enabled(ID_BFM), false, error, "check ID_BFM disabled");
      check_value(is_log_msg_enabled(ID_LOG_HDR), true, error, "check ID_LOG_HDR enabled");
      log(ID_BFM, "ID_BFM disabled. SHOULD NOT BE WRITTEN", "My scope");
      enable_log_msg(ID_BFM);
      log(ID_BFM, "ID_BFM re-enabled. Should be written", "My scope");

      log("Verifying disable_log_msg() with QUIET. Next line should be empty.");
      disable_log_msg(ID_BFM, "THIS MESSAGE SHOULD NOT BE VISIBLE", QUIET);
      log(ID_BFM, "This shall be invisible");
      log(ID_SEQUENCER, "This shall be visible");
      enable_log_msg(ID_BFM, QUIET);
      log("This log message shall be visible");

      log("Verifying that attempting to enable ID_NEVER triggers an alert.");
      increment_expected_alerts(TB_WARNING, 1);
      enable_log_msg(ID_NEVER, "This shall trigger a TB_WARNING.");

      log("Testing ID_LOG_MSG_CTRL and ALL_MESSAGES");
      disable_log_msg(ALL_MESSAGES);
      log(ID_SEQUENCER, "THIS SHOULD NOT BE VISIBLE");
      enable_log_msg(ID_SEQUENCER);
      log(ID_SEQUENCER, "This should be visible (and enabling of ID_SEQUENCER should be visible)");

      log("Testing ID_LOG_MSG_CTRL and ALL_MESSAGES with QUIET");
      disable_log_msg(ALL_MESSAGES);
      log(ID_SEQUENCER, "THIS SHOULD NOT BE VISIBLE");
      enable_log_msg(ID_SEQUENCER, QUIET);
      log(ID_SEQUENCER, "This should be visible (and enabling of ID_SEQUENCER should NOT be visible)");

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "log_text_block" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying log with text block input", "");
      -- Setting up a preformated string
      write(v_line, "TEST OF MULTILINE LOG without formatting" & LF & "First line " & LF & "Second line " & LF & "Third line" & LF & "Fourth line" & LF & "END OF LOG");
      log("Logging data without formatting");
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED);

      write(v_line, "TEST OF MULTILINE LOG with formatting" & LF & "First line " & LF & "Second line " & LF & "Third line" & LF & "Fourth line" & LF & "END OF LOG");
      log("Logging data with formatting");
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "Logging data with Bitvis formatting");

      log("Logging data with empty text block");
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "This header should be printed", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "This header should be printed, with notification", C_SCOPE, shared_msg_id_panel, NOTIFY_IF_BLOCK_EMPTY);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "THIS HEADER SHOULD NOT BE PRINTED", C_SCOPE, shared_msg_id_panel, SKIP_LOG_IF_BLOCK_EMPTY);

      log("Logging with unformatted text to specified file");
      -- Logging to file with unformatted text
      -- Logging to a specified file (primary.txt)
      write(v_line, "This block should be logged to primary.txt only (unformatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED, ".", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "primary.txt", write_mode);
      write(v_line, "This block should be logged to primary.txt and console (unformatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED, ".", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, CONSOLE_AND_LOG, "primary.txt", append_mode);

      -- Logging to another specified file (secondary.txt)
      write(v_line, "This block should be logged to secondary.txt only (unformatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, UNFORMATTED, ".", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "secondary.txt", write_mode);

      log("Logging with formatted text");
      -- Logging to file with formatted text
      -- Logging to a specified file (primary.txt)
      write(v_line, "This block should be logged to primary.txt only (formatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "primary.txt", append_mode);
      write(v_line, "This block should be logged to primary.txt and console (formatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, CONSOLE_AND_LOG, "primary.txt", append_mode);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "the content of this block is empty", C_SCOPE, shared_msg_id_panel, NOTIFY_IF_BLOCK_EMPTY, CONSOLE_AND_LOG, "primary.txt", append_mode);

      log("Logging to secondary file");
      -- Logging to another specified file (secondary.txt)
      write(v_line, "This block should be logged to secondary.txt only (formatted)" & LF & "Second line" & LF & "Third line" & LF);
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, LOG_ONLY, "secondary.txt", append_mode);

      log("Logging to console only");
      -- Logging to another specified file (secondary.txt)
      write(v_line, "LOGGING" & LF & "TO" & LF & "CONSOLE" & LF & "ONLY");
      log_text_block(ID_SEQUENCER, v_line, FORMATTED, "header", C_SCOPE, shared_msg_id_panel, WRITE_HDR_IF_BLOCK_EMPTY, CONSOLE_ONLY);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "log_to_file" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Test of log with specified destination");
      -- Test of log function with output destination specified
      log(ID_SEQUENCER, "Line to console and log", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG);
      log(ID_SEQUENCER, "Line to log only ", C_SCOPE, shared_msg_id_panel, LOG_ONLY);
      log(ID_SEQUENCER, "Line to console only", C_SCOPE, shared_msg_id_panel, CONSOLE_ONLY);
      log(ID_SEQUENCER, "Line to specified file only", C_SCOPE, shared_msg_id_panel, LOG_ONLY, GC_TESTCASE & "_file1.txt", write_mode);
      log(ID_SEQUENCER, "Line to specified file and console", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG, GC_TESTCASE & "_file2.txt", write_mode);
      log(ID_SEQUENCER, "Line to specified file and console, append", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG, GC_TESTCASE & "_file2.txt", append_mode);
      set_log_destination(CONSOLE_ONLY);
      log(ID_SEQUENCER, "Line to console only", C_SCOPE);
      set_log_destination(LOG_ONLY);
      log(ID_SEQUENCER, "Line to log only", C_SCOPE);
      set_log_destination(CONSOLE_AND_LOG, QUIET);
      log(ID_SEQUENCER, "Line to console and log", C_SCOPE);

      -- Provoking errors
      set_alert_stop_limit(TB_ERROR, 53);
      log(ID_SEQUENCER, "log with error", C_SCOPE, shared_msg_id_panel, CONSOLE_AND_LOG, "");
      log(ID_SEQUENCER, "log with error", C_SCOPE, shared_msg_id_panel, LOG_ONLY, "");
      increment_expected_alerts(TB_ERROR, 2);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "log_header_formatting" then
    ------------------------------------------------------------------------------------------------------------------------------
      -- Test of log headers
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
      log(ID_LOG_HDR, "This is a normal header (ID_LOG_HDR)");
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
      log(ID_LOG_HDR_LARGE, "This is a large header (ID_LOG_HDR_LARGE)");
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
      log(ID_LOG_HDR_XL, "This is an extra large header (ID_LOG_HDR_XL)");
      log(ID_SEQUENCER, "Normal line");
      log(ID_SEQUENCER, "Normal line");
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;                   -- to allow some time for completion
    report_alert_counters(INTERMEDIATE);
    report_alert_counters(FINAL);       -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely
  end process p_main;

end architecture log_arch;
