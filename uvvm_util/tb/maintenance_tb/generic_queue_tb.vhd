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

library uvvm_util;
context uvvm_util.uvvm_util_context;

package queue_pkg is new work.generic_queue_pkg
  generic map (
        t_generic_element => integer,
        GC_QUEUE_COUNT_MAX => 1000,
        GC_QUEUE_COUNT_THRESHOLD => 0);

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

--hdlregression:tb
-- Test case entity
entity generic_queue_tb is
  generic (
    GC_TESTCASE : string := "UVVM"
    );
end entity;

-- Test case architecture
architecture func of generic_queue_tb is

  use work.queue_pkg.all;
  shared variable queue_under_test : t_generic_queue;

  constant C_SCOPE        : string  := "test_bench";
  constant C_QUEUE_SCOPE  : string  := "queue_scope";

  begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main: process


    --------------------------------------------------------------------------------------
    -- String compare with error logging
    --------------------------------------------------------------------------------------
    procedure string_compare (
      constant received   : string;
      constant expected   : string;
      constant msg        : string
    ) is
    begin
      if (received = expected) then
        log(msg & " is OK => received " & received);
      else
        alert(ERROR, msg & " failed. Expected " & expected & ", but received " & received & ". ",C_SCOPE);
      end if;
    end procedure;


    --------------------------------------------------------------------------------------
    -- Setup of queue, and test of scope and size functions
    --------------------------------------------------------------------------------------
    procedure setup_and_initial_check_of_queue(
      constant dummy    : t_void
    ) is
    begin
      log(ID_LOG_HDR, "Setting up generic queue and verifying scope and size", C_SCOPE);

      queue_under_test.set_scope(C_QUEUE_SCOPE);
      log("Queue instantiated with depth " & to_string(queue_under_test.get_queue_count_max(VOID)));
      string_compare(queue_under_test.get_scope(VOID), C_QUEUE_SCOPE, "Checking queue scope");

      check_value(queue_under_test.is_empty(VOID), ERROR, "Checking if queue is initially empty", C_SCOPE);
      check_value(queue_under_test.get_count(VOID), 0, ERROR, "Checking if queue is initially empty", C_SCOPE);
      check_value(queue_under_test.get_queue_count_max(VOID), 1000, ERROR, "Checking size of queue", C_SCOPE); -- NOTE: Update the value when queue size is changed.
      check_value(queue_under_test.get_queue_count_threshold(VOID), 0, ERROR, "Checking queue count alert level", C_SCOPE);
    end procedure;


    --------------------------------------------------------------------------------------
    -- Test of read and write within size limit
    --------------------------------------------------------------------------------------
    procedure test_of_add_fetch_empty_and_not_empty(
      constant dummy    : t_void
    ) is
      variable v_fetch_value : integer;
    begin
      log(ID_LOG_HDR, "Testing fetch and add functions within queue size limit", C_SCOPE);
      queue_under_test.flush(VOID);
      check_value(queue_under_test.is_empty(VOID), ERROR, "Checking if queue is initially empty", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(queue_under_test.get_queue_count_max(VOID)-1));
      for i in 0 to queue_under_test.get_queue_count_max(VOID)-1 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      check_value(not queue_under_test.is_empty(VOID), ERROR, "Checking if queue is not empty after add", C_SCOPE);
      increment_expected_alerts(TB_WARNING, 1); -- Expect TB_WARNING at threshold

      log("Checking that queue content is consistent with add values");
      for i in 0 to queue_under_test.get_queue_count_max(VOID)-1 loop
        v_fetch_value := queue_under_test.fetch(VOID);
        log(ID_SEQUENCER_SUB, "Got integer " & to_string(v_fetch_value), C_SCOPE);
        check_value(v_fetch_value, i, ERROR, "Checking that retrieved value is equal to written value");
      end loop;
      check_value(queue_under_test.is_empty(VOID), ERROR, "Checking if queue is empty after fetch", C_SCOPE);

    end procedure;



    --------------------------------------------------------------------------------------
    -- Test of flush function
    --------------------------------------------------------------------------------------
    procedure test_of_flush(
      constant dummy    : t_void
    ) is
    begin
      log(ID_LOG_HDR, "Testing of flush command", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(queue_under_test.get_queue_count_max(VOID)-1));
      for i in 0 to queue_under_test.get_queue_count_max(VOID)-1 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      increment_expected_alerts(TB_WARNING, 1); -- Expect TB_WARNING at threshold

      log("Checking flush of queue");
      check_value(not queue_under_test.is_empty(VOID), ERROR, "Checking if queue is not empty after add", C_SCOPE);
      queue_under_test.flush(void);
      check_value(queue_under_test.is_empty(VOID), ERROR, "Checking if queue is empty after flush", C_SCOPE);
    end procedure;


    --------------------------------------------------------------------------------------
    -- Test of insert(POSITION
    -- and insert(ENTRY_NUM.
    -- Also test find_* and exists()
    --------------------------------------------------------------------------------------
    procedure test_of_insert(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 10; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position        : natural := 3;
      variable v_entry_num       : natural := 0;
    begin
      queue_under_test.reset(void); -- to start with entry_num = 0
      log(ID_LOG_HDR, "Test of insert TEST", C_SCOPE);

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 1 to " & to_string(v_num_entries) );

      for i in 1 to v_num_entries loop
        log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
        -- Checks
        check_value(queue_under_test.find_position(i), i, ERROR, "Check that element = integer = " & to_string(i) & " is at POSITION " & to_string(i), C_SCOPE);
        check_value(queue_under_test.find_entry_num(i), i, ERROR, "Check that element = integer = " & to_string(i) & " has entry_num=" & to_string(i), C_SCOPE);
      end loop;

      -- Pre insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre insert test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(not queue_under_test.exists(v_element_integer), ERROR, "Pre insert test: Check that Element doens't exists yet", C_SCOPE);
      check_value(queue_under_test.find_position(v_element_integer), C_NO_MATCH, ERROR, "Pre insert test: Check that element = integer = " & to_string(v_element_integer) & " is not found yet" , C_SCOPE);
      queue_under_test.print_queue(1);

      -----------------------------
      -- Insert after POSTITION
      -----------------------------
      log(ID_SEQUENCER_SUB, "Insert element = integer = " & to_string(v_element_integer) & " in POSITION " & to_string(v_position) , C_SCOPE);
      queue_under_test.insert(POSITION, v_position, v_element_integer );
      v_num_entries := v_num_entries + 1;

      -- Post Insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Post insert test: Checking that queue has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(queue_under_test.exists(v_element_integer), ERROR, "Check that inserted Element exists", C_SCOPE);
      -- Check if v_element_integer is in position v_position+1 (i.e. AFTER v_position)
      check_value(queue_under_test.find_position(v_element_integer), v_position, ERROR, "Check if element = integer = " & to_string(v_element_integer) & " is at POSITION " & to_string(v_position), C_SCOPE);
      queue_under_test.print_queue(1);

      -----------------------------
      -- Insert another into the same position, this time integer = 1001
      -----------------------------
      v_element_integer := 1001;
      log(ID_SEQUENCER_SUB, "Insert element = integer = " & to_string(v_element_integer) & " in POSITION " & to_string(v_position) , C_SCOPE);
      queue_under_test.insert(POSITION, v_position, v_element_integer );
      v_num_entries := v_num_entries + 1;

      -- Post Insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Post insert test: Checking that queue has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(queue_under_test.exists(v_element_integer), ERROR, "Check that inserted Element exists", C_SCOPE);
      -- Check if v_element_integer is in position v_position+1 (i.e. AFTER v_position)
      check_value(queue_under_test.find_position(v_element_integer), v_position, ERROR, "Check if element = integer = " & to_string(v_element_integer) & " is at POSITION " & to_string(v_position), C_SCOPE);
      queue_under_test.print_queue(1);

      -----------------------------
      -- Insert another in the first position
      -----------------------------
      v_position := 1;
      v_element_integer := 1002;
      log(ID_SEQUENCER_SUB, "First Position: Insert element = integer = " & to_string(v_element_integer) & " in POSITION " & to_string(v_position) , C_SCOPE);
      queue_under_test.insert(POSITION, v_position, v_element_integer );
      v_num_entries := v_num_entries + 1;

      -- Post Insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Post insert test: Checking that queue has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(queue_under_test.exists(v_element_integer), ERROR, "Check that inserted Element exists", C_SCOPE);
      -- Check if v_element_integer is in position v_position+1 (i.e. AFTER v_position)
      check_value(queue_under_test.find_position(v_element_integer), v_position, ERROR, "Check if element = integer = " & to_string(v_element_integer) & " is at POSITION " & to_string(v_position), C_SCOPE);

      -- Check that v_element_integer has entry_num = v_num_entries. (entry_num counts from 1)
      v_exp_entry_num := v_num_entries;
      check_value(queue_under_test.find_entry_num(v_element_integer), v_exp_entry_num, ERROR, "Check that v_element_integer has entry_num = v_num_entries-1. ", C_SCOPE);
      queue_under_test.print_queue(1);
      --------------------------------------

      -----------------------------
      -- Insert after ENTRY_NUM = v_num_entries, which is now postition 3
      -----------------------------
      v_entry_num       := v_num_entries; -- entry_num counts from 1
      v_element_integer := 1003;
      log(ID_SEQUENCER_SUB, "Insert element = integer = " & to_string(v_element_integer) & " after ENTRY_NUM " & to_string(v_entry_num) & "(after position 1) " , C_SCOPE);
      queue_under_test.insert(ENTRY_NUM, v_entry_num, v_element_integer );
      v_num_entries := v_num_entries + 1;
      queue_under_test.print_queue(1);

      -- Post Insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Post insert test: Checking that queue has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(queue_under_test.exists(v_element_integer), ERROR, "Check that inserted Element exists", C_SCOPE);

      -- Check that we insterted into position 2 as expected
      check_value(queue_under_test.find_position(v_element_integer), 2, ERROR, "Check that inserted element = " & to_string(v_element_integer) & " is at POSITION 2", C_SCOPE);

      -- Post Insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Post insert test: Checking that queue has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(queue_under_test.exists(v_element_integer), ERROR, "Check that inserted Element exists", C_SCOPE);
      -- Check if v_element_integer is in position v_position+1 (i.e. AFTER v_position)
      check_value(queue_under_test.find_position(v_element_integer), v_position+1, ERROR, "Check if element = integer = " & to_string(v_element_integer) & " is at POSITION " & to_string(v_position+1), C_SCOPE);

      -----------------------------
      -- Test wrong use of insert: no match
      -----------------------------
      queue_under_test.insert(POSITION, 123456, v_element_integer );
      increment_expected_alerts(TB_ERROR, 1);-- supposed to result in a TB_ERROR.

      queue_under_test.insert(ENTRY_NUM, 123456, v_element_integer );
      increment_expected_alerts(TB_ERROR, 1);-- supposed to result in a TB_ERROR.

      -- Test wrong use of find_*: no match
      v_element_integer := 123456;
      check_value(queue_under_test.find_position(v_element_integer), C_NO_MATCH, ERROR, "Check C_NO_MATCH from find_position", C_SCOPE);
      check_value(queue_under_test.find_entry_num(v_element_integer), C_NO_MATCH, ERROR, "Check C_NO_MATCH from find_entry_num", C_SCOPE);

      -----------------------------
      -- Test insert with POSITION
      -----------------------------
      queue_under_test.reset(void); -- to start with entry_num = 0

      log(ID_LOG_HDR, "Testing insert with POSITION and identifier = 1 and identifier /=1");

      v_element_integer := 654321;

      log("\nInsert at position 2 to an empty queue - expecting a TB_ERROR");
      increment_expected_alerts(TB_ERROR, 1);-- supposed to result in a TB_ERROR.
      queue_under_test.insert(POSITION, 2, v_element_integer);

      log("\nInsert at position 1 to an empty queue - expecting add() OK");
      queue_under_test.insert(POSITION, 1, v_element_integer);

      log("\nPrinting queue");
      queue_under_test.print_queue(VOID);

      log("\nVerify queue content");
      check_value(queue_under_test.find_position(v_element_integer), 1, ERROR, "Check that element = " & to_string(v_element_integer) & " is at POSITION 1", C_SCOPE);
      check_value(queue_under_test.find_entry_num(v_element_integer), 1, ERROR, "Check that element = " & to_string(v_element_integer) & " has entry_num=1", C_SCOPE);


      -----------------------------
      -- Reset the queue by calling flush.
      queue_under_test.flush(VOID);
      queue_under_test.set_queue_count_threshold(0);
    end procedure;

    procedure test_of_delete_by_position_random(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 30; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position_min    : natural ;
      variable v_position_max    : natural ;
      variable v_value           : integer;
      variable v_entry_num_min  : integer;
      variable v_entry_num_max  : integer;
      variable v_entry_num       : natural := 0;
    begin
      log(ID_LOG_HDR, "Test of delete position_random", C_SCOPE);
      queue_under_test.reset(VOID); -- Make Entry_num predictable

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(v_num_entries-1) );

      for i in 0 to v_num_entries-1 loop
        log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
      end loop;

      -- pre test checks
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);

      -- delete specifying position_min and max . "delete positions in back of queue"
      v_position_min := random(1, v_num_entries);
      v_position_max := random(v_position_min, v_num_entries);
      log("v_position_min = " & to_string(v_position_min) &
          "v_position_max = " & to_string(v_position_max) );

      queue_under_test.delete(POSITION, v_position_min, v_position_max);

      for position in v_position_min to v_position_max loop
        v_value := position - 1;
        check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);
      end loop;

    end procedure;

    procedure test_of_delete_by_position(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 30; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position_min    : natural ;
      variable v_position_max    : natural ;
      variable v_value           : integer;
      variable v_entry_num_min  : integer;
      variable v_entry_num_max  : integer;
      variable v_entry_num       : natural := 0;
    begin
      log(ID_LOG_HDR, "Test of delete position", C_SCOPE);
      queue_under_test.reset(VOID); -- Make Entry_num predictable

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(v_num_entries-1) );

      for i in 0 to v_num_entries-1 loop
        log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
        -- Checks
        check_value(queue_under_test.find_position(i), i+1, ERROR, "Check that element = integer = " & to_string(i) & " is at POSITION " & to_string(i+1), C_SCOPE);
      end loop;

      -- For debug
      -- queue_under_test.print_queue(1);

      -- pre test checks
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);

      -- delete specifying position_min and max . "delete positions in back of queue"
      v_position_min := v_num_entries-2;
      v_position_max := v_num_entries;

      for position in v_position_min to v_position_max loop
        v_value := position - 1;
        check_value(queue_under_test.exists(v_value), ERROR, "pre delete test: Check that Element exists ", C_SCOPE);
      end loop;

      queue_under_test.delete(POSITION, v_position_min, v_position_max);

      for position in v_position_min to v_position_max loop
        v_value := position - 1;
        check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);
      end loop;


      -- delete Single positon
      v_position_min := 6;
      v_position_max := v_position_min;
      v_value := v_position_min - 1;
      check_value(queue_under_test.exists(v_value), ERROR, "pre delete test: Check that Element exists ", C_SCOPE);
      queue_under_test.delete(POSITION, v_position_min, v_position_max);
      check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);


      -- delete specifying position_min and max . "delete positions in front of queue"
      v_position_min := 1;
      v_position_max := 2;

      for position in v_position_min to v_position_max loop
        v_value := position - 1;
        check_value(queue_under_test.exists(v_value), ERROR, "pre delete test: Check that Element exists ", C_SCOPE);
      end loop;

      queue_under_test.delete(POSITION, v_position_min, v_position_max);

      for position in v_position_min to v_position_max loop
        v_value := position - 1;
        check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);
      end loop;

    end procedure;

    procedure test_of_delete_by_element(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 30; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position_min    : natural ;
      variable v_position_max    : natural ;
      variable v_value           : integer;
      variable v_entry_num_min  : integer;
      variable v_entry_num_max  : integer;
      variable v_entry_num       : natural := 0;
    begin
      log(ID_LOG_HDR, "Test of delete by element", C_SCOPE);
      queue_under_test.reset(VOID); -- Make Entry_num predictable

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(v_num_entries-1) );

      for i in 0 to v_num_entries-1 loop
        -- log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
      end loop;

      -- pre test checks
      queue_under_test.print_queue(void) ;
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);

      for i in 0 to v_num_entries-1 loop
        v_value := i;
        log("deleting element v_value=" & to_string(v_value) );
        queue_under_test.delete(v_value);
        v_num_entries := v_num_entries-1;
        queue_under_test.print_queue(void) ;

        check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);
        check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "post delete test: Checking that queue now has only " & to_string(v_num_entries) & " entries", C_SCOPE);
      end loop;

    end procedure;

    procedure test_of_delete_by_entry_num(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 30; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position_min    : natural ;
      variable v_position_max    : natural ;
      variable v_value           : integer;
      variable v_entry_num_min  : integer;
      variable v_entry_num_max  : integer;
      variable v_entry_num       : natural := 0;
    begin
      log(ID_LOG_HDR, "Test of delete entry_num", C_SCOPE);
      queue_under_test.reset(VOID); -- Make Entry_num predictable

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(v_num_entries-1) );

      for i in 0 to v_num_entries-1 loop
        -- log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
      end loop;

      -- For debug
      -- queue_under_test.print_queue(1);

      -- pre test checks
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);

      -- delete specifying ENTRY_NUM min and max . "delete positions in front of queue"
      v_entry_num_min := 1;
      v_entry_num_max := v_num_entries;
      log("v_entry_num_min = " & to_string(v_entry_num_min) &
          "v_entry_num_max = " & to_string(v_entry_num_max) );

      for entry_num in v_entry_num_min to v_entry_num_max loop
        v_value := entry_num - 1;
        check_value(queue_under_test.exists(v_value), ERROR, "pre delete test: Check that Element to be deleted exists ", C_SCOPE);
      end loop;

      queue_under_test.delete(ENTRY_NUM, v_entry_num_min, v_entry_num_max);
      -- For Debug
      -- queue_under_test.print_queue(void) ;

      for entry_num in v_entry_num_min to v_entry_num_max loop
        v_value := entry_num - 1;
        check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);
      end loop;

      if v_entry_num_min > 1 then
        v_value := (v_entry_num_min - 1)-1;
        check_value(queue_under_test.exists(v_value), ERROR, "post delete test: -- Check that v_entry_num_min-1 = " &to_string(v_entry_num_min-1)&" is still there", C_SCOPE);
      end if;

      if v_entry_num_max < v_num_entries then
        v_value := (v_entry_num_max + 1)-1;
        check_value(queue_under_test.exists(v_value), ERROR, "post delete test: -- Check that v_entry_num_max-1 = " &to_string(v_entry_num_max-1)&" is still there", C_SCOPE);
      end if;
    end procedure;


    procedure test_of_delete_by_entry_num_random(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 30; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position_min    : natural ;
      variable v_position_max    : natural ;
      variable v_value           : integer;
      variable v_entry_num_min  : integer;
      variable v_entry_num_max  : integer;
      variable v_entry_num       : natural := 0;
    begin
      log(ID_LOG_HDR, "Test of delete entry_num", C_SCOPE);
      queue_under_test.reset(VOID); -- Make Entry_num predictable

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(v_num_entries-1) );

      for i in 0 to v_num_entries-1 loop
        -- log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
      end loop;

      -- For debug
      -- queue_under_test.print_queue(1);

      -- pre test checks
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);

      -- delete specifying ENTRY_NUM min and max . "delete positions in front of queue"
      v_entry_num_min := random(1, v_num_entries);
      v_entry_num_max := random(v_entry_num_min, v_num_entries);
      log("v_entry_num_min = " & to_string(v_entry_num_min) &
          "v_entry_num_max = " & to_string(v_entry_num_max) );

      for entry_num in v_entry_num_min to v_entry_num_max loop
        v_value := entry_num - 1;
        check_value(queue_under_test.exists(v_value), ERROR, "pre delete test: Check that Element to be deleted exists ", C_SCOPE);
      end loop;

      queue_under_test.delete(ENTRY_NUM, v_entry_num_min, v_entry_num_max);
      -- For Debug
      -- queue_under_test.print_queue(void) ;

      for entry_num in v_entry_num_min to v_entry_num_max loop
        v_value := entry_num - 1;
        check_value(not queue_under_test.exists(v_value), ERROR, "post delete test: Check that Element doens't exists ", C_SCOPE);
      end loop;

      if v_entry_num_min > 1 then
        v_value := (v_entry_num_min - 1)-1;
        check_value(queue_under_test.exists(v_value), ERROR, "post delete test: -- Check that v_entry_num_min-1 = " &to_string(v_entry_num_min-1)&" is still there", C_SCOPE);
      end if;

      if v_entry_num_max < v_num_entries then
        v_value := (v_entry_num_max + 1)-1;
        check_value(queue_under_test.exists(v_value), ERROR, "post delete test: -- Check that v_entry_num_max-1 = " &to_string(v_entry_num_max-1)&" is still there", C_SCOPE);
      end if;
    end procedure;


    procedure test_of_fetch(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 10; -- Originally add v_num_entries to the queue.
      variable v_exp_entry_num   : natural;

      -- Regarding element to be inserted
      variable v_element_integer : natural := 1000;
      variable v_position        : natural := 2;
      variable v_value           : integer;
      variable v_entry_num       : natural := 0;
    begin
      log(ID_LOG_HDR, "Test of fetch", C_SCOPE);

      queue_under_test.flush(VOID);
      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with integers from 0 to " & to_string(v_num_entries-1) );

      for i in 0 to v_num_entries-1 loop
        log(ID_SEQUENCER_SUB, "add element = integer = " & to_string(i) , C_SCOPE);
        queue_under_test.add(i);
        -- Checks
        check_value(queue_under_test.find_position(i), i+1, ERROR, "Check that element = integer = " & to_string(i) & " is at POSITION " & to_string(i+1), C_SCOPE);
      end loop;
      -- queue_under_test.print_queue(1);

      -- pre fetch tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre peek test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);

      for i in 1 to v_num_entries loop
        v_position := i;
        v_value    := v_position-1;
        check_value(queue_under_test.peek(POSITION, v_position), v_value, ERROR, "Check peek of position " & to_string(v_position), C_SCOPE);
      end loop;

      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "post peek test: Checking if queue still has " & to_string(v_num_entries) & " entries", C_SCOPE);

      -- peek first entry by not specifying position
      v_value    := 0;
      check_value(queue_under_test.peek(1), v_value, ERROR, "Check peek first element (without position)" , C_SCOPE);

      -- peek from last(highest) position.
      v_position := v_num_entries;
      v_value    := v_position-1;
      check_value(queue_under_test.peek(POSITION, v_position), v_value, ERROR, "Check fetching of POSITION " & to_string(v_position), C_SCOPE);

      -- peek from entry_num.
      -- First we must find entry_num
      v_position := 6;
      v_value    := v_position-1;
      v_entry_num := queue_under_test.find_entry_num(v_value);
      check_value(queue_under_test.peek(ENTRY_NUM, v_entry_num), v_value, ERROR, "Check fetching of entry_num " & to_string(v_entry_num), C_SCOPE);

      -- Fetch from entry_num.
      -- First we must find entry_num
      v_position := 6;
      v_value    := v_position-1;
      v_entry_num := queue_under_test.find_entry_num(v_value);
      check_value(queue_under_test.fetch(ENTRY_NUM, v_entry_num), v_value, ERROR, "Check fetching of entry_num " & to_string(v_entry_num), C_SCOPE);
      v_num_entries := v_num_entries - 1;

      -- Fetch from position
      v_position := 4;
      v_value    := v_position-1;
      check_value(queue_under_test.fetch(POSITION, v_position), v_value, ERROR, "Check fetching of position " & to_string(v_position), C_SCOPE);
      v_num_entries := v_num_entries - 1;

      -- Fetch first entry by not specifying position
      v_value    := 0;
      check_value(queue_under_test.fetch(VOID), v_value, ERROR, "Check fetching first element (without position)" , C_SCOPE);
      v_num_entries := v_num_entries - 1;

      v_value    := 1;
      check_value(queue_under_test.fetch(VOID), v_value, ERROR, "Check fetching first element (without position)" , C_SCOPE);
      v_num_entries := v_num_entries - 1;

      -- Test peek with no match
      v_position := 123456;
      v_value := queue_under_test.peek(POSITION, v_position);
      increment_expected_alerts(TB_ERROR, 1);

      -- Test fetch with no match
      v_position := 123456;
      v_value := queue_under_test.fetch(POSITION, v_position);
      increment_expected_alerts(TB_ERROR, 1);

      -- For Debug
      -- queue_under_test.print_queue(void) ;

    end procedure;


    --------------------------------------------------------------------------------------
    -- Test of add when queue is full
    --------------------------------------------------------------------------------------
    procedure test_of_add_to_full_queue(
      constant dummy    : t_void
    ) is
    begin
      log(ID_LOG_HDR, "Test of add when queue is full", C_SCOPE);

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);
      log("Filling up the queue with integers from 0 to " & to_string(queue_under_test.get_queue_count_max(VOID)));
      for i in 0 to queue_under_test.get_queue_count_max(VOID)-1 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      increment_expected_alerts(TB_WARNING, 1);

      -- Adding an item when the queue is full is supposed to result in a TB_ERROR.
      -- To counter this the expected alerts counter is increased by one.
      increment_expected_alerts(TB_ERROR, 1);
      queue_under_test.add(0);
      -- Reset the queue by calling flush.
      queue_under_test.flush(VOID);
      queue_under_test.set_queue_count_threshold(0);
    end procedure;


    --------------------------------------------------------------------------------------
    -- Test of fetch when queue is empty
    --------------------------------------------------------------------------------------
    procedure test_of_fetch_from_empty_queue(
      constant dummy    : t_void
    ) is
      variable v_fetch_value : integer;
    begin
      log(ID_LOG_HDR, "Test of fetch when queue is empty", C_SCOPE);

      check_value(queue_under_test.is_empty(VOID), ERROR, "Verifying that queue is empty", C_SCOPE);
      -- Reading (and hence removing) an item when the queue is empty is supposed to result in a TB_ERROR.
      -- To counter this the expected alerts counter is increased by one.
      increment_expected_alerts(TB_ERROR, 1);
      v_fetch_value := queue_under_test.fetch(VOID);
    end procedure;

    --------------------------------------------------------------------------------------
    -- Test of fetching the last element
    --------------------------------------------------------------------------------------
    procedure test_of_fetch_last_element(
      constant dummy    : t_void
    ) is
      variable v_value : integer;
    begin
      log(ID_LOG_HDR, "Test of fetching the last element", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Adding two elements to the queue", C_SCOPE);
      queue_under_test.add(0);
      queue_under_test.add(1);
      log(ID_SEQUENCER_SUB, "Fetching the last element from the queue", C_SCOPE);
      v_value := queue_under_test.fetch(POSITION, 2);
      log(ID_SEQUENCER_SUB, "Adding another element to the queue", C_SCOPE);
      queue_under_test.add(2);
      v_value := 0;
      check_value(queue_under_test.fetch(VOID), v_value, ERROR, "Check fetching first element (without position)" , C_SCOPE);
      v_value := 2;
      check_value(queue_under_test.fetch(VOID), v_value, ERROR, "Check fetching the last element (without position)" , C_SCOPE);
    end procedure;

    --------------------------------------------------------------------------------------
    -- Test of deleting the last element
    --------------------------------------------------------------------------------------
    procedure test_of_delete_last_element(
      constant dummy    : t_void
    ) is
    begin
      log(ID_LOG_HDR, "Test of deleting the last element", C_SCOPE);

      log(ID_SEQUENCER_SUB, "Adding two elements to the queue", C_SCOPE);
      queue_under_test.add(0);
      queue_under_test.add(1);
      log(ID_SEQUENCER_SUB, "Deleting the last element from the queue", C_SCOPE);
      queue_under_test.delete(POSITION, 2, SINGLE);
      log(ID_SEQUENCER_SUB, "Adding another element to the queue", C_SCOPE);
      queue_under_test.add(2);
      check_value(queue_under_test.peek(POSITION, 1), 0, ERROR, "Checking the first element" , C_SCOPE);
      check_value(queue_under_test.peek(POSITION, 2), 2, ERROR, "Checking the last element" , C_SCOPE);
      log("Flushing the queue");
      queue_under_test.flush(VOID);
    end procedure test_of_delete_last_element;

    --------------------------------------------------------------------------------------
    -- Test of memory leakage in queue.
    --    This test will run until stopped manually. Verify that RAM usage of simulator
    --    is consistent over time when running this test.
    --------------------------------------------------------------------------------------
    procedure test_memory_leakage(
      constant dummy  : t_void
    ) is
      variable v_fetch_value : integer;
    begin
      log(ID_LOG_HDR, "Running memory leakage stimuli. Verify consistent RAM usage and stop the simulation.", C_SCOPE);

      while true loop
        queue_under_test.add(1);
        v_fetch_value := queue_under_test.fetch(VOID);
      end loop;

    end procedure;


    --------------------------------------------------------------------------------------
    -- Test of queue max count manipulation
    --------------------------------------------------------------------------------------
    procedure test_of_queue_max_count_manipulation(
      constant dummy    : t_void
    ) is
      variable v_fetch_value : integer;
    begin
      log(ID_LOG_HDR, "Test of queue max count manipulation", C_SCOPE);

      check_value(queue_under_test.is_empty(VOID), ERROR, "Verifying that queue is empty", C_SCOPE);

      -- Test the queue with the new size
      log("Setting queue max count to 10");
      queue_under_test.set_queue_count_max(10);
      check_value(queue_under_test.get_queue_count_max(VOID),10, ERROR, "Checking if queue max count was set correctly", C_SCOPE);
      log("Filling up the queue with integers from 0 to 9");
      for i in 0 to 9 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      check_value(not queue_under_test.is_empty(VOID), ERROR, "Checking if queue is not empty after add", C_SCOPE);

      log("Checking that queue content is consistent with add values");
      for i in 0 to 9 loop
        v_fetch_value := queue_under_test.fetch(VOID);
        log(ID_SEQUENCER_SUB, "Got integer " & to_string(v_fetch_value), C_SCOPE);
        check_value(v_fetch_value, i, ERROR, "Checking that retrieved value is equal to written value");
      end loop;
      check_value(queue_under_test.is_empty(VOID), ERROR, "Checking if queue is empty after fetch", C_SCOPE);


      -- Increase the queue size and fill it up
      log("Setting queue max count to 20");
      queue_under_test.set_queue_count_max(20);
      check_value(queue_under_test.get_queue_count_max(VOID),20, ERROR, "Checking if queue max count was set correctly", C_SCOPE);
      log("Filling up the queue with integers from 0 to 19");
      for i in 0 to 19 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      check_value(not queue_under_test.is_empty(VOID), ERROR, "Checking if queue is not empty after add", C_SCOPE);

      -- Set new, lower queue size and expect alert
      log("Setting queue max count lower than current count");
      increment_expected_alerts(TB_ERROR, 1);
      queue_under_test.set_queue_count_max(5);
      check_value(queue_under_test.get_queue_count_max(VOID),5, ERROR, "Checking if queue max count was set correctly", C_SCOPE);

      -- Reset the queue
      log("Flushing the queue and setting the max count back to 1000");
      queue_under_test.flush(VOID);
      queue_under_test.set_queue_count_max(1000);

    end procedure;


    --------------------------------------------------------------------------------------
    -- Test of queue fill level and alerts
    --------------------------------------------------------------------------------------
    procedure test_of_queue_fill_level_and_alerts(
      constant dummy    : t_void
    ) is
      variable v_fetch_value : integer;
    begin
      log(ID_LOG_HDR, "Test of queue fill level and alerts", C_SCOPE);

      check_value(queue_under_test.is_empty(VOID), ERROR, "Verifying that queue is empty", C_SCOPE);

      -- Test the queue with the new size
      log("Setting queue max count to 100");
      queue_under_test.set_queue_count_max(100);
      check_value(queue_under_test.get_queue_count_max(VOID),100, ERROR, "Checking if queue max count was set correctly", C_SCOPE);

      log("Setting queue fill level alert to be triggered at 70%, with severity TB_WARNING");
      queue_under_test.set_queue_count_threshold(70);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);
      check_value(queue_under_test.get_queue_count_threshold_severity(VOID)=TB_WARNING, ERROR, "Checking that alert level was set correctly", C_SCOPE);
      check_value(queue_under_test.get_queue_count_threshold(VOID)=70, ERROR, "Checking that fill level was set correctly", C_SCOPE);

      log("Filling the queue up to 80% and expecting TB_WARNING");
      for i in 0 to 79 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      increment_expected_alerts(TB_WARNING, 1);
      -- Flush queue
      queue_under_test.flush(VOID);

      log("Setting queue fill level alert to be triggered at 85%, with severity TB_WARNING");
      queue_under_test.set_queue_count_threshold(85);
      queue_under_test.set_queue_count_threshold_severity(TB_ERROR);
      check_value(queue_under_test.get_queue_count_threshold_severity(VOID)=TB_ERROR, ERROR, "Checking that alert level was set correctly", C_SCOPE);
      check_value(queue_under_test.get_queue_count_threshold(VOID)=85, ERROR, "Checking that fill level was set correctly", C_SCOPE);

      log("Filling the queue up to 80% and not expecting alert");
      for i in 0 to 79 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;

      log("Filling the queue up from 80% to 90% and expecting TB_ERROR");
      for i in 0 to 9 loop
        log(ID_SEQUENCER_SUB, "Putting integer " & to_string(i), C_SCOPE);
        queue_under_test.add(i);
      end loop;
      increment_expected_alerts(TB_ERROR, 1);
      -- Flush queue
      queue_under_test.flush(VOID);

      -- Reset the queue
      log("Flushing and resetting the queue");
      queue_under_test.flush(VOID);
      queue_under_test.set_queue_count_max(1000);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);
      queue_under_test.set_queue_count_threshold(950);

    end procedure;

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);
    set_alert_stop_limit(TB_ERROR, 0);    -- 0 = Never stop

    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR, "Start Simulation of generic queue package", C_SCOPE);
    ------------------------------------------------------------

    setup_and_initial_check_of_queue(VOID);
    test_of_insert(VOID);
    test_of_delete_by_position(VOID);

    test_of_delete_by_element(VOID);

    for i in 0 to 10 loop
      log(ID_LOG_HDR, "Start of test_of_delete_by_position_random tests, i="&to_string(i), C_SCOPE);
      test_of_delete_by_position_random(VOID);
    end loop;

    test_of_delete_by_entry_num(VOID);

    for i in 0 to 10 loop
      log(ID_LOG_HDR, "Start of test_of_delete_by_entry_num_random tests, i="&to_string(i), C_SCOPE);
      test_of_delete_by_entry_num_random(VOID);
    end loop;


    test_of_fetch(VOID);

    test_of_add_fetch_empty_and_not_empty(VOID);
    test_of_flush(VOID);
    test_of_add_to_full_queue(VOID);

    test_of_fetch_from_empty_queue(VOID);
    test_of_fetch_last_element(VOID);
    test_of_delete_last_element(VOID);
    test_of_queue_max_count_manipulation(VOID);
    test_of_queue_fill_level_and_alerts(VOID);

    -- test_memory_leakage(VOID); -- NB: Will run infinitely until stopped.

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
