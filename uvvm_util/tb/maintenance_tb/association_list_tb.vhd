--================================================================================================================================
-- Copyright 2025 UVVM
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
-- Description   : Generic accosiation list testbench.
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--hdlregression:tb

entity association_list_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

architecture func of association_list_tb is

  package string_association_list_pkg is new uvvm_util.association_list_pkg
    generic map(
      GC_SCOPE => "string_association_list_pkg",
      GC_KEY_TYPE => string,
      GC_VALUE_TYPE => natural
    );

  constant C_SCOPE       : string := "test_bench";

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process

    ------------------------------------------
    -- check_value
    ------------------------------------------
    procedure check_value (
      constant value        : t_association_list_status;
      constant expected     : t_association_list_status;
      constant alert_level  : t_alert_level;
      constant msg          : string;
      constant scope        : string         := C_TB_SCOPE_DEFAULT;
      constant msg_id       : t_msg_id       := ID_POS_ACK;
      constant msg_id_panel : t_msg_id_panel := shared_msg_id_panel;
      constant caller_name  : string         := "check_value()"
    ) is
      constant value_int : integer := t_association_list_status'pos(value);
      constant exp_int   : integer := t_association_list_status'pos(expected);
    begin
      check_value(value_int, exp_int, alert_level, msg, scope, msg_id, msg_id_panel, caller_name);
    end procedure check_value;

    ------------------------------------------
    -- verify_initial_list
    ------------------------------------------
    procedure verify_initial_list (
      constant dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
    begin
      log(ID_LOG_HDR, "Verify initial length of the list.", C_SCOPE);
      check_value(v_association_list.length(VOID), 0, ERROR, "Checking if the association_list is initially empty", C_SCOPE);
    end procedure verify_initial_list;

    ------------------------------------------
    -- verify_set_get
    ------------------------------------------
    procedure verify_set_get (
      constant dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
      variable v_status           : t_association_list_status;
    begin

      log(ID_LOG_HDR, "Verify the get() and the set() functions.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Append 10 nodes to the list.", C_SCOPE);
      for i in 0 to 9 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
      end loop;

      log(ID_SEQUENCER_SUB, "Set new values to all key-value pairs.", C_SCOPE);
      for i in 0 to 9 loop
        v_status := v_association_list.set(key => "KEY-" & to_string(i), value => 9-i);
      end loop;

      log(ID_SEQUENCER_SUB, "Verify the new values set.", C_SCOPE);
      for i in 0 to 9 loop
        check_value(v_association_list.get("KEY-" & to_string(i)), 9-i, ERROR, "Checking the new values set.", C_SCOPE);
      end loop;

      v_status := v_association_list.clear(VOID);
    end procedure verify_set_get;

    ------------------------------------------
    -- verify_clear
    ------------------------------------------
    procedure verify_clear (
      constant dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
      variable v_status           : t_association_list_status;
      variable v_num_nodes        : natural;
    begin
      log(ID_LOG_HDR, "Verify the clear() function.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Append a random number of nodes to the list.", C_SCOPE);
      v_num_nodes := random(1, 100);
      for i in 0 to v_num_nodes - 1 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
      end loop;

      check_value(v_association_list.length(VOID), v_num_nodes, ERROR, "Checking the list length after appending nodes.", C_SCOPE);
      v_status := v_association_list.clear(VOID);
      check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying clear() return value.", C_SCOPE);
      check_value(v_association_list.length(VOID), 0, ERROR, "Checking the list length after calling clear().", C_SCOPE);
      
    end procedure verify_clear;

    ------------------------------------------
    -- verify_length
    ------------------------------------------
    procedure verify_length (
      constant dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
      variable v_status           : t_association_list_status;
      variable v_num_nodes        : natural := 0;
    begin
      log(ID_LOG_HDR, "Verify the length().", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Append nodes to the list and check the list length.", C_SCOPE);
      v_num_nodes := random(1, 100);
      for i in 0 to v_num_nodes - 1 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
        check_value(v_association_list.length(VOID), i+1, ERROR, "Checking the list length after appending nodes.", C_SCOPE);
      end loop;

      log(ID_SEQUENCER_SUB, "Delete from list and check length", C_SCOPE);
      for i in v_num_nodes - 1 downto 0 loop
        v_status := v_association_list.delete(key => "KEY-" & to_string(i));
        check_value(v_association_list.length(VOID), i, ERROR, "Checking the list length after deleting nodes.", C_SCOPE);
      end loop;

      v_status := v_association_list.clear(VOID);
    end procedure verify_length;

    ------------------------------------------
    -- random_delete
    ------------------------------------------
    procedure random_delete (
      constant dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
      variable v_status           : t_association_list_status;
      variable v_num_nodes        : natural := 0;
      variable v_exclude_list     : t_natural_array(0 to 9);
      variable v_node_to_delete   : natural := 0;

      impure function node_in_exclusion_list (
        constant node_idx : natural
      ) return boolean is
      begin
        for i in 0 to 9 loop
          if node_idx = v_exclude_list(i) then
            return true;
          end if;
        end loop;

        return false;
      end function node_in_exclusion_list;
    begin
      log(ID_LOG_HDR, "Delete randomly from the list and check key and length.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Append a random number (10 <= num_nodes <= 100) of nodes to the list.", C_SCOPE);
      v_num_nodes := random(10, 100);
      for i in 0 to v_num_nodes - 1 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
      end loop;

      log(ID_SEQUENCER_SUB, "Delete 10 nodes at random from the " & to_string(v_num_nodes) & " appended.", C_SCOPE);

      for i in 0 to 9 loop
        v_node_to_delete := random(0, v_num_nodes - 1);

        while node_in_exclusion_list(v_node_to_delete) loop
          v_node_to_delete := random(0, v_num_nodes - 1);
        end loop;

        v_exclude_list(i) := v_node_to_delete;

        v_status := v_association_list.delete(key => "KEY-" & to_string(v_node_to_delete));
        check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying delete return value.", C_SCOPE);
        check_value(v_association_list.key_in_list("KEY-" & to_string(v_node_to_delete)), false, ERROR, "Checking that the key deleted is not in the list.", C_SCOPE);
      end loop;

      check_value(v_association_list.length(VOID), v_num_nodes - 10, ERROR, "Checking the association_list length after random deleting of nodes.", C_SCOPE);

      v_status := v_association_list.clear(VOID);
    end procedure random_delete;

    ------------------------------------------
    -- verify_append
    ------------------------------------------
    procedure verify_append (
      constant dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
      variable v_status           : t_association_list_status;
      variable v_num_nodes        : natural := 0;
    begin
      log(ID_LOG_HDR, "Verify the append() function.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Append a random number (50 <= num_nodes <= 100) of nodes to the list and verify the list length.", C_SCOPE);
      v_num_nodes := random(50, 100);
      for i in 0 to v_num_nodes - 1 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
        check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying append() return value.", C_SCOPE);
      end loop;

      check_value(v_association_list.length(VOID), v_num_nodes, ERROR, "Verifying the list length after appending " & to_string(v_num_nodes) & " nodes.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Lookup all keys and verify their value.", C_SCOPE);
      for i in 0 to v_num_nodes - 1 loop
        check_value(v_association_list.get(key => "KEY-" & to_string(i)), i, ERROR, "Verifying all values stored in the list.", C_SCOPE);
      end loop;

      v_status := v_association_list.clear(VOID);

      log(ID_SEQUENCER_SUB, "Verify the return value when append() is called with the same key twice.", C_SCOPE);
      v_status := v_association_list.append(key => "KEY-10", value => 10);
      check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying append() return value.", C_SCOPE);

      v_status := v_association_list.append(key => "KEY-10", value => 1);
      check_value(v_status, ASSOCIATION_LIST_FAILURE, ERROR, "Verifying append() return value.", C_SCOPE);

      v_status := v_association_list.clear(VOID);
    end procedure verify_append;

    ------------------------------------------
    -- verify_delete
    ------------------------------------------
    procedure verify_delete (
      dummy : t_void
    ) is
      variable v_association_list : string_association_list_pkg.t_association_list;
      variable v_status           : t_association_list_status;
    begin

      log(ID_LOG_HDR, "Verify the delete() function.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Append 10 nodes to the list.", C_SCOPE);
      for i in 0 to 9 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
      end loop;

      log(ID_SEQUENCER_SUB, "Delete all nodes starting from the head of the list", C_SCOPE);
      for i in 0 to 9 loop
        v_status := v_association_list.delete(key => "KEY-" & to_string(i));
        check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying delete() return value", C_SCOPE);
      end loop;

      log(ID_SEQUENCER_SUB, "Append 10 nodes to the list.", C_SCOPE);
      for i in 0 to 9 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
      end loop;

      log(ID_SEQUENCER_SUB, "Delete all nodes starting from the tail of the list", C_SCOPE);
      for i in 9 downto 0 loop
        v_status := v_association_list.delete(key => "KEY-" & to_string(i));
        check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying delete() return value", C_SCOPE);
      end loop;

      log(ID_SEQUENCER_SUB, "Append 10 nodes to the list.", C_SCOPE);
      for i in 0 to 9 loop
        v_status := v_association_list.append(key => "KEY-" & to_string(i), value => i);
      end loop;

      log(ID_SEQUENCER_SUB, "Delete a node from the middle of the list", C_SCOPE);
      v_status := v_association_list.delete(key => "KEY-4");
      check_value(v_status, ASSOCIATION_LIST_SUCCESS, ERROR, "Verifying delete() return value", C_SCOPE);
      check_value(v_association_list.length(VOID), 9, ERROR, "Verifying length after delete()", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Verifying that the list is not broken after deleting a node from the middle of the list.", C_SCOPE);
      check_value(v_association_list.key_in_list("KEY-5"), true, ERROR, "Checking that the node after the one deleted is found in the list.", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Try to delete a node that is not in the list.", C_SCOPE);
      v_status := v_association_list.delete(key => "KEY-" & to_string(100));
      check_value(v_status, ASSOCIATION_LIST_FAILURE, ERROR, "Verifying delete() return value", C_SCOPE);

      v_status := v_association_list.clear(VOID);
    end procedure verify_delete;

  begin
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    set_alert_stop_limit(TB_ERROR, 10);

    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_POS_ACK);

    log(ID_LOG_HDR_LARGE, "Start Simulation of Association List Package - " & GC_TESTCASE);

    verify_initial_list(VOID);
    verify_append(VOID);
    verify_length(VOID);
    verify_delete(VOID);
    random_delete(VOID);
    verify_clear(VOID);
    verify_set_get(VOID);

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
end architecture func;
