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

---------------------------------------------------------------------------------------------
-- Description : See library quick reference (under 'doc') and README-file(s)
---------------------------------------------------------------------------------------------

architecture alert_arch of methods_tb is
begin

  p_main : process
    constant C_SCOPE                : string := "TB seq";
    variable v_alert_stop_limit     : natural;
    variable v_alert_count          : natural;
    variable v_bool                 : boolean;
    variable v_local_hierarchy_tree : t_hierarchy_linked_list;
    variable v_dummy_hierarchy_node : t_hierarchy_node(name(1 to C_HIERARCHY_NODE_NAME_LENGTH));

    alias found_unexpected_simulation_warnings_or_worse is shared_uvvm_status.found_unexpected_simulation_warnings_or_worse;
    alias found_unexpected_simulation_errors_or_worse is shared_uvvm_status.found_unexpected_simulation_errors_or_worse;
    alias mismatch_on_expected_simulation_warnings_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_warnings_or_worse;
    alias mismatch_on_expected_simulation_errors_or_worse is shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse;
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "alert_summary_report" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing alert summary report", C_SCOPE);

      log("Testing without any major or minor alerts");
      report_alert_counters(FINAL);

      log("Testing NOTE");
      alert(NOTE, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(NOTE);

      log("Testing TB_NOTE");
      alert(TB_NOTE, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(TB_NOTE);

      log("Testing WARNING");
      alert(WARNING, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(WARNING);

      log("Testing TB_WARNING");
      alert(TB_WARNING, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(TB_WARNING);

      log("Testing MANUAL_CHECK");
      alert(MANUAL_CHECK, "This alert shall set mismatch in minor alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(MANUAL_CHECK);

      log("Testing ERROR");
      set_alert_stop_limit(ERROR, 2);
      alert(ERROR, "This alert shall set mismatch in major alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(ERROR);

      log("Testing TB_ERROR");
      set_alert_stop_limit(TB_ERROR, 2);
      alert(TB_ERROR, "This alert shall set mismatch in major alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(TB_ERROR);

      log("Testing FAILURE");
      set_alert_stop_limit(FAILURE, 2);
      alert(FAILURE, "This alert shall set mismatch in major alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(FAILURE);

      log("Testing TB_FAILURE");
      set_alert_stop_limit(TB_FAILURE, 2);
      alert(TB_FAILURE, "This alert shall set mismatch in major alerts report", C_SCOPE);
      report_alert_counters(FINAL);
      increment_expected_alerts(TB_FAILURE);

      log("Testing final summary, all OK");

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "ignored_alerts" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Testing alert_level NO_ALERT and related functions", C_SCOPE);

      alert(NO_ALERT, "This alert shall not cause simulation stop, nor be visible in the transcript", C_SCOPE);
      log("Testing set of NO_ALERT alert stop limit (should fail)");
      set_alert_stop_limit(NO_ALERT, 2);
      check_value(get_alert_stop_limit(NO_ALERT), 0, TB_ERROR, "Verifying that alert stop limit for NO_ALERT is 0 (never)", C_SCOPE);
      log("Testing set of NO_ALERT alert attention (should fail)");
      set_alert_attention(NO_ALERT, REGARD);
      check_value(get_alert_attention(NO_ALERT) = IGNORE, TB_ERROR, "Verifying that alert attention for NO_ALERT is IGNORE", C_SCOPE);
      log("Testing increment_expected_alerts for NO_ALERT (should fail)");
      increment_expected_alerts(NO_ALERT, 4);
      increment_expected_alerts(TB_WARNING, 3);

      log("Testing increment_expected_alerts_and_stop_limit");
      v_alert_stop_limit := get_alert_stop_limit(TB_FAILURE);
      v_alert_count      := get_alert_counter(TB_FAILURE);
      increment_expected_alerts_and_stop_limit(TB_FAILURE);
      check_value(get_alert_stop_limit(TB_FAILURE) = (v_alert_stop_limit + 1), TB_ERROR, "Verifying that TB_WARNING alert stop limit was incremented", C_SCOPE);
      check_value(true = false, TB_FAILURE, "Cause TB_FAILURE trigger", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "hierarchical_alerts_report" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying hierarchy linked list minor alerts report summary", C_SCOPE);

      v_local_hierarchy_tree.initialize_hierarchy(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => 0));

      v_local_hierarchy_tree.insert_in_tree((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.print_hierarchical_log;

      log("Enabling all alert levels in entire hierarchy. Minor alerts for all nodes triggered.");
      v_local_hierarchy_tree.enable_all_alert_levels("TB seq");

      log("Testing NOTE with fourth_node");
      v_local_hierarchy_tree.alert("fourth_node", NOTE);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("fourth_node", NOTE);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing TB_NOTE with third_node");
      v_local_hierarchy_tree.alert("third_node", TB_NOTE);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("third_node", TB_NOTE);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing WARNING with second_node");
      v_local_hierarchy_tree.alert("second_node", WARNING);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("second_node", WARNING);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing TB_WARNING with first_node");
      v_local_hierarchy_tree.alert("first_node", TB_WARNING);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("first_node", TB_WARNING);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

      log("Testing MANUAL_CHECK with TB seq");
      v_local_hierarchy_tree.alert("TB seq", MANUAL_CHECK);
      v_local_hierarchy_tree.print_hierarchical_log;
      v_local_hierarchy_tree.increment_expected_alerts("TB seq", MANUAL_CHECK);
      log("Expecting no major or minor alerts");
      v_local_hierarchy_tree.print_hierarchical_log;

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "hierarchical_alerts" then
    ------------------------------------------------------------------------------------------------------------------------------
      --------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying hierarchy_linked_list_pkg", C_SCOPE);
      --------------------------------------------------------------------------------
      -- Verifying:
      --  initialize_hierarchy
      --  is_empty()
      --  is_not_empty()
      --  get_size()
      --  clear()
      --  contains_scope()
      --  contains_scope_return_data()
      --
      check_value(v_local_hierarchy_tree.is_empty, error, "Verifying that local hierarchy tree is empty before first init!");
      for i in 1 to 10 loop
        -- Initialize hierarchy tree
        v_local_hierarchy_tree.initialize_hierarchy(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => 0));
        check_value(v_local_hierarchy_tree.is_not_empty, error, "Verifying that local hierarchy tree is not empty!");
        check_value(v_local_hierarchy_tree.get_size, 1, error, "Verifying size!");
        check_value(v_local_hierarchy_tree.contains_scope(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH)), error, "Verifying scope is in tree");
        v_local_hierarchy_tree.contains_scope_return_data(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), v_bool, v_dummy_hierarchy_node);
        check_value(v_bool, error, "Verifying that scope was found");
        check_value(v_dummy_hierarchy_node = (justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), error, "Verifying that node is identical with what was inserted");
        if i > 1 then
          for j in 1 to i - 1 loop
            v_local_hierarchy_tree.insert_in_tree((justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
            check_value(v_local_hierarchy_tree.get_size, j + 1, error, "Verifying size!");
            check_value(v_local_hierarchy_tree.contains_scope(justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH)), error, "Verifying scope is in tree");
            v_local_hierarchy_tree.contains_scope_return_data(justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH), v_bool, v_dummy_hierarchy_node);
            check_value(v_bool, error, "Verifying that scope was found");
            check_value(v_dummy_hierarchy_node = (justify(integer'image(j), left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), error, "Verifying that node is identical with what was inserted");
          end loop;
        end if;

        v_local_hierarchy_tree.clear;
        check_value(v_local_hierarchy_tree.is_empty, error, "Verifying that local hierarchy tree is empty after iteration!");
      end loop;

      -- Verify data structure details:
      --  insert_in_tree()
      --  get_parent_scope()
      --  change_parent()
      v_local_hierarchy_tree.initialize_hierarchy(justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), (others => 0));

      v_local_hierarchy_tree.insert_in_tree((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("second_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify(C_SCOPE, left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.insert_in_tree((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH), (others => (others => 0)), (others => 0), (others => true)), justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("fourth_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.print_hierarchical_log;

      v_local_hierarchy_tree.change_parent(justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH), justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH));
      check_value(v_local_hierarchy_tree.get_parent_scope((justify("third_node", left, C_HIERARCHY_NODE_NAME_LENGTH))) = justify("first_node", left, C_HIERARCHY_NODE_NAME_LENGTH), error, "Verifying parent scope!");

      v_local_hierarchy_tree.print_hierarchical_log;

      -- This test case is commented out because it will trigger a failure (intentionally)
      -- The test case is that we try to assign a new parent to first_node, but the new parent is a child of first_node
      --v_local_hierarchy_tree.change_parent(justify("first_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), justify("third_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT));
      --check_value(v_local_hierarchy_tree.get_parent_scope((justify("first_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT))) = justify("third_node", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope!");
      --v_local_hierarchy_tree.print_hierarchical_log;

      --  Alert related
      log("Verifying that expected alerts propagate correctly.");
      check_value(v_local_hierarchy_tree.get_expected_alerts("first_node", note) = 0, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("second_node", note) = 0, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("third_node", note) = 0, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("fourth_node", note) = 0, error, "Verifying expected alerts!");
      v_local_hierarchy_tree.set_expected_alerts("fourth_node", note, 14);
      check_value(v_local_hierarchy_tree.get_expected_alerts("fourth_node", note) = 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("third_node", note), 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("first_node", note), 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("TB seq", note), 14, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("second_node", note), 0, error, "Verifying expected alerts!");
      v_local_hierarchy_tree.increment_expected_alerts("fourth_node", note);
      check_value(v_local_hierarchy_tree.get_expected_alerts("fourth_node", note) = 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("third_node", note), 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("first_node", note), 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("TB seq", note), 15, error, "Verifying expected alerts!");
      check_value(v_local_hierarchy_tree.get_expected_alerts("second_node", note), 0, error, "Verifying expected alerts!");
      v_local_hierarchy_tree.print_hierarchical_log;

      v_local_hierarchy_tree.set_expected_alerts("fourth_node", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("third_node", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("first_node", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("TB seq", note, 0);
      v_local_hierarchy_tree.set_expected_alerts("second_node", note, 0);

      log("Verifying that alerts propagate correctly for all alert levels");
      for alert_level in note to t_alert_level'right loop
        v_local_hierarchy_tree.alert("fourth_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("third_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("second_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("first_node", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("TB seq", alert_level, REGARD, "testing with alert_level " & to_upper(to_string(alert_level)));

        v_local_hierarchy_tree.alert("fourth_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("third_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("second_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("first_node", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));
        v_local_hierarchy_tree.alert("TB seq", alert_level, IGNORE, "testing with alert_level " & to_upper(to_string(alert_level)));

        v_local_hierarchy_tree.increment_expected_alerts("fourth_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("third_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("second_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("first_node", alert_level);
        v_local_hierarchy_tree.increment_expected_alerts("first_node", alert_level); -- Two here since there are two separate branches of children that can cause alerts.
        v_local_hierarchy_tree.increment_expected_alerts("TB seq", alert_level);
      end loop;

      v_local_hierarchy_tree.print_hierarchical_log;

      log("Verifying hierarchical stop limits");

      for alert_level in note to t_alert_level'right loop
        check_value(v_local_hierarchy_tree.get_top_level_stop_limit(alert_level), 0, error, "Verifying top level stop limit default implicitly!");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 0, error, "Verifying top level stop limit default explicitly!");
        v_local_hierarchy_tree.set_top_level_stop_limit(alert_level, 400);
        check_value(v_local_hierarchy_tree.get_top_level_stop_limit(alert_level), 400, error, "Verifying top level stop limit change implicitly!");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 400, error, "Verifying top level stop limit change explicitly!");
        v_local_hierarchy_tree.set_top_level_stop_limit(alert_level, 0);
        check_value(v_local_hierarchy_tree.get_top_level_stop_limit(alert_level), 0, error, "Verifying top level stop limit back to default implicitly!");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 0, error, "Verifying top level stop limit back to default explicitly!");

        --  What test cases are required for hierarchical stop limits?
        --    1.  Set stop limit. Verify that it propagates.
        --    2.  Increment stop limit. Verify that it propagates.
        --    3.  Verify that the simulation actually stops when the limits
        --        are reached on each hierarchy level
        --        -- How to do that? Manually...
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 0, error, "Verifying that second node has 0 as stop limit before starting test");
        v_local_hierarchy_tree.set_stop_limit("fourth_node", alert_level, 1337);
        -- Shall propagate to third->first->tbseq
        check_value(v_local_hierarchy_tree.get_stop_limit("fourth_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("third_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("first_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 1337, error, "Verifying stop limit propagation");
        -- Verify that other branch was not touched
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 0, error, "Verifying that other branches did not receive new stop limit");
        -- Verify increment on second node. Shall not increase for first_node since first node has a higher value already
        v_local_hierarchy_tree.increment_stop_limit("second_node", alert_level, 14);
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 14, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("first_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("third_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("fourth_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 1337, error, "Verifying stop limit propagation");
        -- Verify increment on third node. Second and fourth node shall not change now.
        v_local_hierarchy_tree.increment_stop_limit("third_node", alert_level);
        check_value(v_local_hierarchy_tree.get_stop_limit("third_node", alert_level), 1338, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("first_node", alert_level), 1338, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("TB seq", alert_level), 1338, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("fourth_node", alert_level), 1337, error, "Verifying stop limit propagation");
        check_value(v_local_hierarchy_tree.get_stop_limit("second_node", alert_level), 14, error, "Verifying stop limit propagation");
      end loop;

      -- Verify that the simulation stops at the limits. Must be done manually.
      -- v_local_hierarchy_tree.set_top_level_stop_limit(TB_WARNING, 13);
      -- for i in 1 to 14 loop
      -- v_local_hierarchy_tree.alert("second_node", TB_WARNING);
      -- end loop;

      log("Verifying alert level printing for several nodes");
      alert(MANUAL_CHECK, "VERIFY THIS");

      -- Disable all alert levels for the top node.
      -- No alerts shall then be printed for any alert level
      log("Disabling all alert levels in entire hierarchy. No alerts between this log message and the next.");
      v_local_hierarchy_tree.disable_all_alert_levels("TB seq");
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("second_node", TB_ERROR);
      v_local_hierarchy_tree.alert("first_node", TB_ERROR);
      v_local_hierarchy_tree.alert("TB seq", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is an ERROR.");

      -- Enable all alert levels for the top node.
      -- All other nodes shall then give alerts on all alert levels since it propagates downwards.
      log("Enabling all alert levels in entire hierarchy. Some alerts between this log message and the next.");
      v_local_hierarchy_tree.enable_all_alert_levels("TB seq");
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("second_node", TB_ERROR);
      v_local_hierarchy_tree.alert("first_node", TB_ERROR);
      v_local_hierarchy_tree.alert("TB seq", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is CORRECT.");

      -- Then disable specific alert level from third_node
      -- Verify that all alerts from nodes other than third_node and fourth_node are printed
      log("Disabling TB_ERROR alert level for third_node and downwards (fourth_node). No alerts for these nodes at this alert level between this log message and the next. All others shall have alerts printed.");
      v_local_hierarchy_tree.disable_alert_level("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is an ERROR.");
      v_local_hierarchy_tree.alert("second_node", TB_ERROR);
      v_local_hierarchy_tree.alert("first_node", TB_ERROR);
      v_local_hierarchy_tree.alert("TB seq", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is CORRECT.");
      log("Enabling TB_ERROR for third_node and fourth_node again");
      v_local_hierarchy_tree.enable_alert_level("third_node", TB_ERROR);
      v_local_hierarchy_tree.alert("fourth_node", TB_ERROR);
      v_local_hierarchy_tree.alert("third_node", TB_ERROR);
      log("Are there any alert messages between this message and the previous one? If so it is CORRECT.");

      v_local_hierarchy_tree.clear;

      ----------------------------------------------------------------------------------
      --log(ID_LOG_HDR, "Verifying alert_hierarchy_pkg", C_SCOPE);
      ----------------------------------------------------------------------------------
      ---- To properly verify this you need to enable hierarchical alerts by setting the following in adaptations_pkg:
      ---- constant C_DEFAULT_STOP_LIMIT : t_alert_counters := (note to manual_check => 0,
      ----                                                      others               => 0);
      ---- constant C_ENABLE_HIERARCHICAL_ALERTS : boolean := true;

      --clear_hierarchy(VOID);
      --initialize_hierarchy;
      --add_to_alert_hierarchy("test_hier_0", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_1", "test_hier_0", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_2", "test_hier_1", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_3", "test_hier_1", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_4", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_5", "test_hier_4", C_DEFAULT_STOP_LIMIT);

      --hierarchical_alert(WARNING, "this is a test", "test_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_1", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_2", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_3", C_DEFAULT_ALERT_ATTENTION(WARNING));

      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --print_hierarchical_log(INTERMEDIATE);

      ---- Set expected alerts to 5 ERRORs, stop limit to 6 ERRORs, then give 5 ERRORs.
      --set_expected_alerts("test_hier_5", ERROR, 5);
      --set_stop_limit("test_hier_5", ERROR, 6);
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

      ---- Increment expected and stop limit. Then give another error.
      --increment_expected_alerts("test_hier_5", ERROR);
      --increment_stop_limit("test_hier_5", ERROR);
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

      ---- Trigger an alert with a non-registered scope to verify that the automatic
      ---- registration works.
      --hierarchical_alert(WARNING, "this is a test", "auto_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));

      --print_hierarchical_log(FINAL);

      --clear_hierarchy(VOID);

      ---- Verify that global and hierarchical alert counters match.
      --initialize_hierarchy;
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, NOTE);
      --hierarchical_alert(NOTE, "this is a test", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(NOTE));

      --for i in 1 to 5 loop
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, WARNING);
      --hierarchical_alert(WARNING, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(WARNING));
      --end loop;

      --for i in 1 to 3 loop
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, TB_WARNING);
      --hierarchical_alert(TB_WARNING, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(TB_WARNING));
      --end loop;

      ---- Problem here is that if one sets the limit to zero and then starts to increment,
      ---- the limit will be 1, and the test will fail.
      --set_stop_limit(C_BASE_HIERARCHY_LEVEL, ERROR, 87);

      --for i in 1 to 86 loop
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, ERROR);
      --hierarchical_alert(ERROR, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(ERROR));
      --end loop;

      --set_stop_limit(C_BASE_HIERARCHY_LEVEL, TB_ERROR, 53);
      --for i in 1 to 52 loop
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, TB_ERROR);
      --hierarchical_alert(TB_ERROR, "this is a test : " & integer'image(i), C_BASE_HIERARCHY_LEVEL, C_DEFAULT_ALERT_ATTENTION(TB_ERROR));
      --end loop;

      --print_hierarchical_log(FINAL);
      --clear_hierarchy(VOID);

      ---- Verify that sorting the hierarchy tree works.
      --initialize_hierarchy;
      --add_to_alert_hierarchy("test_hier_0", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_1", "test_hier_0", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_2", "test_hier_1", C_DEFAULT_STOP_LIMIT);
      --hierarchical_alert(WARNING, "this is a test", "auto_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --add_to_alert_hierarchy("test_hier_3", "test_hier_1", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_4", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_6", "test_hier_3", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_5", "test_hier_4", C_DEFAULT_STOP_LIMIT);

      --hierarchical_alert(WARNING, "this is a test", "test_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_1", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_2", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_3", C_DEFAULT_ALERT_ATTENTION(WARNING));

      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

      --global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);

      ---- global_sorted_hierarchy_tree.clear;
      --clear_hierarchy(VOID);

      ---- Verify that parent registration overrides child's own registration.
      --initialize_hierarchy;
      --add_to_alert_hierarchy("child", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --check_value(global_hierarchy_tree.get_parent_scope(justify("child", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify(C_BASE_HIERARCHY_LEVEL, C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
      --add_to_alert_hierarchy("parent", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --check_value(global_hierarchy_tree.get_parent_scope(justify("parent", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify(C_BASE_HIERARCHY_LEVEL, C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
      --add_to_alert_hierarchy("child", "parent", C_DEFAULT_STOP_LIMIT);
      --check_value(global_hierarchy_tree.get_parent_scope(justify("child", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify("parent", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
      --add_to_alert_hierarchy("child", "test0", C_DEFAULT_STOP_LIMIT);
      --check_value(global_hierarchy_tree.get_parent_scope(justify("child", C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), justify("parent", C_HIERARCHY_NODE_NAME_LENGTH, LEFT), ERROR, "Verifying parent scope");
      --clear_hierarchy(VOID);

      ---- initialize_hierarchy;
      ---- if C_ENABLE_HIERARCHICAL_ALERTS then -- Need this if-statement to avoid errors when hierarchical alerts not enabled.
      ---- increment_expected_alerts(ERROR);
      ---- check_value(false, ERROR, "adding to hierarchy", C_SCOPE);
      ---- check_value(global_hierarchy_tree.contains_scope(justify(C_SCOPE, C_HIERARCHY_NODE_NAME_LENGTH, LEFT)), ERROR, "Verifying that scope was added to hierarchy", C_SCOPE);
      ---- end if;
      ---- hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      ---- global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);
      ---- -- sort_hierarchy_tree(0);
      ---- -- global_sorted_hierarchy_tree.print_hierarchical_log(REGARD);
      ---- clear_hierarchy(VOID);

      ---- if C_ENABLE_HIERARCHICAL_ALERTS then
      ----   -- To let simulation pass when hierarchical alerts not enabled
      ----   -- Problem is that the expected alerts are only incremented on top,
      ----   -- not in the individual scopes. Doing this afterwards.
      ----   -- A better solution would be to increment these instead of
      ----   -- calling the non-hierarchical increment_expected_alerts,
      ----   -- but doing this for simplicity.
      ----   increment_expected_alerts("my_scope", note, 1);
      ----   increment_expected_alerts("my_scope", error, 1);
      ----   increment_expected_alerts("TB seq", warning, 5);
      ----   increment_expected_alerts("TB seq", error, 81);
      ----   increment_expected_alerts("TB seq.", TB_WARNING, 3);
      ----   increment_expected_alerts("TB seq.", MANUAL_CHECK, 1);
      ----   increment_expected_alerts("TB seq.", error, 4);
      ----   increment_expected_alerts("TB seq.", TB_ERROR, 2);
      ----   increment_expected_alerts("bfm_common", TB_ERROR, 50);
      ---- end if;

      --log(ID_LOG_HDR, "Verifying uvvm simulation status with alert hierarchy pkg", "");
      --clear_hierarchy(VOID);
      --initialize_hierarchy;
      --add_to_alert_hierarchy("test_hier_0", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_1", "test_hier_0", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_2", "test_hier_1", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_3", "test_hier_1", C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_4", C_BASE_HIERARCHY_LEVEL, C_DEFAULT_STOP_LIMIT);
      --add_to_alert_hierarchy("test_hier_5", "test_hier_4", C_DEFAULT_STOP_LIMIT);

      ---- Initial expectation of simulation status
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      --set_expected_alerts("test_hier_0", WARNING, 4);
      --set_expected_alerts("test_hier_1", WARNING, 3);
      --set_expected_alerts("test_hier_2", WARNING, 1);
      --set_expected_alerts("test_hier_3", WARNING, 1);

      --hierarchical_alert(WARNING, "this is a test", "test_hier_0", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_1", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_2", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --hierarchical_alert(WARNING, "this is a test", "test_hier_3", C_DEFAULT_ALERT_ATTENTION(WARNING));

      ---- regarded = expected
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");
      --global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);

      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));

      ---- regarded > expected warnings
      --check_value(found_unexpected_simulation_warnings_or_worse,     1, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");
      --global_hierarchy_tree.print_hierarchical_log(INTERMEDIATE);

      ---- regarded = expected
      --increment_expected_alerts("test_hier_5", WARNING);
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, WARNING);
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      ---- regarded > expected errors
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(ERROR));
      --check_value(found_unexpected_simulation_warnings_or_worse,     1, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       1, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      ---- regarded = expected
      --increment_expected_alerts("test_hier_5", ERROR);
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      ---- regarded < expected warnings
      --increment_expected_alerts("test_hier_5", WARNING);
      --increment_expected_alerts(C_BASE_HIERARCHY_LEVEL, WARNING);
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      ---- regarded < expected errors
      --increment_expected_alerts("test_hier_5", ERROR);
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      ---- regarded < expected warnings
      --hierarchical_alert(ERROR, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(ERROR));
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 1, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

      ---- regarded = expected
      --hierarchical_alert(WARNING, "this is a test", "test_hier_5", C_DEFAULT_ALERT_ATTENTION(WARNING));
      --check_value(found_unexpected_simulation_warnings_or_worse,     0, ERROR, "Verifying simulation status found_unexpected_simulation_warnings_or_worse");
      --check_value(found_unexpected_simulation_errors_or_worse,       0, ERROR, "Verifying simulation status found_unexpected_simulation_errors_or_worse");
      --check_value(mismatch_on_expected_simulation_warnings_or_worse, 0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_warnings_or_worse");
      --check_value(mismatch_on_expected_simulation_errors_or_worse,   0, ERROR, "Verifying simulation status mismatch_on_expected_simulation_errors_or_worse");

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

end architecture alert_arch;
