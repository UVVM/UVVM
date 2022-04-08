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


package record_queue_pkg is new work.generic_queue_pkg
  generic map (
        t_generic_element => t_sync_flag_record,
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
entity generic_queue_record_tb is
  generic (
    GC_TESTCASE : string := "UVVM"
    );
end entity;

-- Test case architecture
architecture func of generic_queue_record_tb is

  use work.record_queue_pkg.all;
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
    -- Test of insert
    --------------------------------------------------------------------------------------
    procedure test_of_insert(
      constant dummy    : t_void
    ) is
      variable v_num_entries     : natural := 10; -- Originally add v_num_entries to the queue.

      -- Regarding element to be inserted
      variable v_element : t_sync_flag_record := C_SYNC_FLAG_DEFAULT;
      variable v_position        : natural := 2;
    begin
      log(ID_LOG_HDR, "Test of insert", C_SCOPE);

      queue_under_test.set_queue_count_threshold(950);
      queue_under_test.set_queue_count_threshold_severity(TB_WARNING);

      check_value (v_num_entries <= queue_under_test.get_queue_count_max(VOID), ERROR, "Check if the queue is big enough for the planned test", C_SCOPE);

      log("Filling up the queue with " & to_string(v_num_entries-1) & " entries = C_SYNC_FLAG_DEFAULT. "  );

      for i in 0 to v_num_entries-1 loop
        queue_under_test.put(C_SYNC_FLAG_DEFAULT);
      end loop;

      -- Pre insert tests
      -- Make v_element different from C_SYNC_FLAG_DEFAULT,
      -- v_element.is_active := false;
      v_element.flag_name(1) := 'A';
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Pre insert test: Checking if queue initially has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(not queue_under_test.exists(v_element), ERROR, "Pre insert test: Check that Element doens't exists yet", C_SCOPE);
      check_value(queue_under_test.find_position(v_element), -1, ERROR, "Pre insert test: Check that element = " & to_string(0) & " is not found yet" , C_SCOPE);

      -----------------------------
      -- Insert
      -----------------------------
      log(ID_SEQUENCER_SUB, "Insert element = integer = " & to_string(0) & " after POSITION " & to_string(v_position) , C_SCOPE);
      queue_under_test.insert(POSITION, v_position, v_element);
      v_num_entries := v_num_entries + 1;

      -- Post Insert tests
      check_value(queue_under_test.get_count(VOID), v_num_entries, ERROR, "Post insert test: Checking that queue has " & to_string(v_num_entries) & " entries", C_SCOPE);
      check_value(queue_under_test.exists(v_element), ERROR, "Check that inserted Element exists", C_SCOPE);
      -- Check if v_elementis in position v_position+1 (i.e. AT v_position)
      check_value(queue_under_test.find_position(v_element), v_position, ERROR, "Check that the new element =  TRUE  is at POSITION " & to_string(v_position), C_SCOPE);



      -----------------------------
      -- Reset the queue by calling flush.
      queue_under_test.flush(VOID);
      queue_under_test.set_queue_count_threshold(0);
    end procedure;



    --------------------------------------------------------------------------------------
    -- Test of read and write within size limit
    --------------------------------------------------------------------------------------


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
    -- disable_log_msg(ID_POS_ACK);
    --disable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR, "Start Simulation of generic queue package", C_SCOPE);
    ------------------------------------------------------------

    setup_and_initial_check_of_queue(VOID);
    test_of_insert(VOID);

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
