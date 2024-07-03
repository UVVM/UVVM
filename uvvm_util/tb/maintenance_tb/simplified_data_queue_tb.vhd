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
use IEEE.math_real.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;
use uvvm_util.data_queue_pkg.all;
use uvvm_util.data_fifo_pkg.all;
use uvvm_util.data_stack_pkg.all;

--hdlregression:tb
-- Test case entity
entity simplified_data_queue_tb is
  generic(
    GC_TESTCASE : string := "UVVM"
  );
end entity;

-- Test case architecture
architecture func of simplified_data_queue_tb is

  shared variable queue_under_test : t_data_queue;

  constant C_SCOPE          : string  := "test_bench";
  constant C_BUFFER_INDEX_1 : natural := 1;
  constant C_BUFFER_INDEX_2 : natural := 4;
  constant C_BUFFER_INDEX_3 : natural := 3;
  constant C_BUFFER_SIZE_1  : natural := 64;
  constant C_BUFFER_SIZE_2  : natural := 32;
  constant C_BUFFER_SIZE_3  : natural := 1024;
  constant C_BUFFER_SIZE_4  : natural := 33;
  constant C_BUFFER_SIZE_5  : natural := 192;
  constant C_ENTRY_SIZE_1   : natural := 8;
  constant C_ENTRY_SIZE_2   : natural := 8;
  constant C_ENTRY_SIZE_3   : natural := 1024;
  constant C_ENTRY_SIZE_4   : natural := 8;

  signal slv_1 : std_logic_vector(0 downto 0);

begin

  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- Helper variables
    variable v_buffer_entry_1 : std_logic_vector(C_ENTRY_SIZE_1 - 1 downto 0);
    variable v_buffer_entry_2 : std_logic_vector(C_ENTRY_SIZE_2 - 1 downto 0);
    variable v_buffer_entry_3 : std_logic_vector(C_ENTRY_SIZE_3 - 1 downto 0) := (others => '1');
    variable v_buffer_entry_4 : std_logic_vector(C_ENTRY_SIZE_4 - 1 downto 0);

    variable v_buffer_idx_4 : natural;
    variable v_buffer_idx_5 : natural;

    variable v_buffer_idx_5_expected_data : std_logic_vector(C_BUFFER_SIZE_5 - 1 downto 0);

    variable v_slv_1   : std_logic_vector(0 downto 0);
    variable v_slv_max : std_logic_vector(C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1 downto 0);

  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    -- Print the configuration to the log
    report_global_ctrl(VOID);
    set_alert_stop_limit(TB_ERROR, 0);  -- 0 = Never stop

    enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ID_POS_ACK);
    disable_log_msg(ID_SEQUENCER_SUB);

    log(ID_LOG_HDR_LARGE, "Test of Data Queue", C_SCOPE);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of init then push_back until overflow", C_SCOPE);
    ------------------------------------------------------------
    queue_under_test.init_queue(C_BUFFER_INDEX_1, C_BUFFER_SIZE_1, C_SCOPE);
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 0, TB_ERROR, "Verifying that queue is empty.", C_SCOPE, ID_SEQUENCER);
    v_buffer_entry_1 := x"55";
    for i in 0 to 8 loop
      for j in 0 to i loop
        queue_under_test.push_back(C_BUFFER_INDEX_1, v_buffer_entry_1);
        check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 8 * (j + 1), TB_ERROR, "Verifying that queue contains " & to_string(integer'(j + 1)) & "elements after push_back.", C_SCOPE, ID_SEQUENCER);
      end loop;
      for k in 0 to i loop
        check_value(queue_under_test.pop_front(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1), v_buffer_entry_1, TB_ERROR, "pop_front should be " & to_string(v_buffer_entry_1, HEX) & ".", C_SCOPE);
      end loop;
    end loop;

    increment_expected_alerts(TB_ERROR, 1);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of queue flush", C_SCOPE);
    ------------------------------------------------------------
    queue_under_test.init_queue(C_BUFFER_INDEX_3, C_BUFFER_SIZE_3, C_SCOPE);
    queue_under_test.push_back(C_BUFFER_INDEX_3, v_buffer_entry_3);
    queue_under_test.flush(C_BUFFER_INDEX_3);
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_3), 0, TB_ERROR, "Verifying that queue is empty.", C_SCOPE, ID_SEQUENCER);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of peek_front and peek_back", C_SCOPE);
    ------------------------------------------------------------
    log("Peeking empty back: " & to_string(queue_under_test.peek_back(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1)));
    log("Peeking empty front: " & to_string(queue_under_test.peek_front(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1)));
    increment_expected_alerts(TB_WARNING, 2);

    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 0, TB_ERROR, "Verifying that queue is empty.", C_SCOPE, ID_SEQUENCER);

    v_buffer_entry_1 := x"ee";
    queue_under_test.push_back(C_BUFFER_INDEX_1, v_buffer_entry_1);
    check_value(queue_under_test.peek_front(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = v_buffer_entry_1, TB_ERROR, "peek_front should be 0xee", C_SCOPE, ID_SEQUENCER);
    check_value(queue_under_test.peek_back(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = v_buffer_entry_1, TB_ERROR, "peek_back should be 0xee", C_SCOPE, ID_SEQUENCER);
    v_buffer_entry_1 := x"00";
    queue_under_test.push_back(C_BUFFER_INDEX_1, v_buffer_entry_1);
    v_buffer_entry_1 := x"11";
    queue_under_test.push_back(C_BUFFER_INDEX_1, v_buffer_entry_1);
    check_value(queue_under_test.peek_back(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = v_buffer_entry_1, TB_ERROR, "peek_back should be 0x11", C_SCOPE, ID_SEQUENCER);
    queue_under_test.flush(C_BUFFER_INDEX_1);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of get_queue_count_max, get_count, pop_back and pop_front", C_SCOPE);
    ------------------------------------------------------------
    check_value(queue_under_test.get_queue_count_max(C_BUFFER_INDEX_1), C_BUFFER_SIZE_1, TB_ERROR, "Verifying that queue is correct size", C_SCOPE, ID_SEQUENCER);
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 0, TB_ERROR, "Verifying fill grade", C_SCOPE, ID_SEQUENCER);
    -- Test of pop_front()
    for i in 0 to 7 loop
      queue_under_test.push_back(C_BUFFER_INDEX_1, std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)));
      check_value(queue_under_test.peek_back(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), TB_ERROR, "peek_back should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    end loop;
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 8 * C_ENTRY_SIZE_1, TB_ERROR, "Verifying that queue is filled properly", C_SCOPE, ID_SEQUENCER);

    log("Testing pop_front()...");
    for i in 0 to 7 loop
      check_value(queue_under_test.pop_front(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), TB_ERROR, "pop_front should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    end loop;
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 0, TB_ERROR, "Verifying that queue is empty", C_SCOPE, ID_SEQUENCER);

    for i in 0 to 7 loop
      queue_under_test.push_back(C_BUFFER_INDEX_1, std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)));
      check_value(queue_under_test.peek_back(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), TB_ERROR, "peek_back should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    end loop;
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 8 * C_ENTRY_SIZE_1, TB_ERROR, "Verifying that queue is filled properly", C_SCOPE, ID_SEQUENCER);

    log("Testing pop_back()...");
    for i in 7 downto 0 loop
      check_value(queue_under_test.pop_back(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), TB_ERROR, "pop_back should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    end loop;
    check_value(queue_under_test.get_count(C_BUFFER_INDEX_1), 0, TB_ERROR, "Verifying that queue is empty", C_SCOPE, ID_SEQUENCER);

    log(ID_LOG_HDR_LARGE, "Test of Data FIFO package", C_SCOPE);

    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of FIFO put and get methods", C_SCOPE);
    ------------------------------------------------------------
    uvvm_fifo_init(C_BUFFER_INDEX_1, C_BUFFER_SIZE_1);
    for i in 0 to (C_BUFFER_SIZE_1 / C_ENTRY_SIZE_1) - 1 loop
      uvvm_fifo_put(C_BUFFER_INDEX_1, std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)));
    end loop;
    for i in 0 to (C_BUFFER_SIZE_1 / C_ENTRY_SIZE_1) - 1 loop
      check_value(uvvm_fifo_get(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), TB_ERROR, "uvvm_fifo_get should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    end loop;

    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of FIFO deallocate procedure", C_SCOPE);
    ------------------------------------------------------------
    uvvm_fifo_deallocate(VOID);
    increment_expected_alerts(TB_ERROR, 1);
    uvvm_fifo_put(C_BUFFER_INDEX_1, std_logic_vector(to_unsigned(1, C_ENTRY_SIZE_1)));
    -- Re-initialize the fifo since it's used in another test
    uvvm_fifo_init(C_BUFFER_INDEX_1, C_BUFFER_SIZE_1);

    log(ID_LOG_HDR_LARGE, "Test of Data Stack package", C_SCOPE);
    ------------------------------------------------------------
    log(ID_LOG_HDR, "Test of stack push and pop methods", C_SCOPE);
    ------------------------------------------------------------
    uvvm_stack_init(C_BUFFER_INDEX_2, C_BUFFER_SIZE_2);
    for i in 0 to (C_BUFFER_SIZE_2 / C_ENTRY_SIZE_2) - 1 loop
      uvvm_stack_push(C_BUFFER_INDEX_2, std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_2)));
    end loop;
    for i in (C_BUFFER_SIZE_2 / C_ENTRY_SIZE_2) - 1 downto 0 loop
      check_value(uvvm_stack_pop(C_BUFFER_INDEX_2, C_ENTRY_SIZE_2) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_2)), TB_ERROR, "uvvm_stack_pop should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_2)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    end loop;

    ---------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test of FIFO that has an odd size compared to data size", C_SCOPE);
    ---------------------------------------------------------------------------------------------
    wait for 10 ns;
    v_buffer_idx_4 := uvvm_fifo_init(C_BUFFER_SIZE_4); -- c_buffer_size=33 c_entry_size=8
    wait for 10 ns;
    for i in 0 to 4 loop                -- Loop 5 times. Will wrap around.
      uvvm_fifo_put(v_buffer_idx_4, std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_4)));
      wait for 10 ns;
    end loop;

    for i in 0 to 4 loop
      check_value(uvvm_fifo_get(v_buffer_idx_4, C_ENTRY_SIZE_4),
                  std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_4)),
                  TB_ERROR,
                  "uvvm_fifo_get should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_4)), HEX) & ".",
                  C_SCOPE);
    end loop;
    increment_expected_alerts(TB_ERROR, 2);

    --------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test of FIFO that has data inserted with different widths in and out", C_SCOPE);
    --------------------------------------------------------------------------------------------------------
    v_buffer_idx_5 := uvvm_fifo_init(C_BUFFER_SIZE_5); -- size 192
    for i in 0 to 23 loop
      -- input width: 8
      uvvm_fifo_put(v_buffer_idx_5, std_logic_vector(to_unsigned(i, 8)));
      v_buffer_idx_5_expected_data(8 * (i + 1) - 1 downto 8 * i) := std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_4));
    end loop;

    for i in 0 to 7 loop
      -- Output width: 24
      check_value(uvvm_fifo_get(v_buffer_idx_5, 24),
                  v_buffer_idx_5_expected_data(24 * (i + 1) - 1 downto 24 * i),
                  TB_ERROR,
                  "uvvm_fifo_get should be " & to_string(v_buffer_idx_5_expected_data(24 * (i + 1) - 1 downto 24 * i), HEX) & ".",
                  C_SCOPE);
    end loop;

    check_value(uvvm_fifo_get_count(v_buffer_idx_5), 0, TB_ERROR, "Verifying that queue is empty", C_SCOPE, ID_SEQUENCER);

    --------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Testing that queues don't overlap", C_SCOPE);
    --------------------------------------------------------------------------------------------------------
    wait for 10 us;
    queue_under_test.deallocate_buffer(VOID);
    queue_under_test.init_queue(0, 10);
    queue_under_test.init_queue(1, 16);
    queue_under_test.init_queue(2, 10);
    wait for 10 ns;
    queue_under_test.push_back(1, x"F55F");
    check_value(queue_under_test.get_count(1), 16, TB_ERROR, "Verifying that queue is full", C_SCOPE, ID_NEVER);

    for i in 0 to 18 loop
      queue_under_test.push_back(0, "0");
      queue_under_test.push_back(2, "0");
    end loop;

    for i in 0 to 5 loop
      slv_1 <= queue_under_test.pop_front(0, 1);
      slv_1 <= queue_under_test.pop_back(2, 1);
    end loop;

    check_value(queue_under_test.peek_front(1, 16), x"F55F", TB_ERROR, "Verifying that queue has correct value", C_SCOPE, HEX, AS_IS, ID_SEQUENCER);

    for i in 0 to 18 loop
      queue_under_test.push_back(0, "0");
      queue_under_test.push_back(2, "0");
    end loop;

    for i in 0 to 5 loop
      slv_1 <= queue_under_test.pop_back(0, 1);
      slv_1 <= queue_under_test.pop_front(2, 1);
    end loop;

    check_value(queue_under_test.peek_front(1, 16), x"F55F", TB_ERROR, "Verifying that queue has correct value", C_SCOPE, HEX, AS_IS, ID_SEQUENCER);

    --------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Testing fifo is full method", C_SCOPE);
    --------------------------------------------------------------------------------------------------------
    queue_under_test.flush(C_BUFFER_INDEX_1);
    check_value(uvvm_fifo_get_count(C_BUFFER_INDEX_1), 0, TB_ERROR, "Verifying that queue is empty", C_SCOPE, ID_SEQUENCER);
    check_value(uvvm_fifo_is_full(C_BUFFER_INDEX_1), false, TB_ERROR, "uvvm_fifo_is_full should return false.", C_SCOPE, ID_SEQUENCER);
    for i in 0 to (C_BUFFER_SIZE_1 / C_ENTRY_SIZE_1) - 1 loop
      uvvm_fifo_put(C_BUFFER_INDEX_1, std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)));
    end loop;
    check_value(uvvm_fifo_is_full(C_BUFFER_INDEX_1), true, TB_ERROR, "uvvm_fifo_is_full should return true.", C_SCOPE, ID_SEQUENCER);
    check_value(uvvm_fifo_get(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(0, C_ENTRY_SIZE_1)), TB_ERROR, "uvvm_fifo_get should be " & to_string(std_logic_vector(to_unsigned(0, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
    check_value(uvvm_fifo_is_full(C_BUFFER_INDEX_1), false, TB_ERROR, "uvvm_fifo_is_full should return false.", C_SCOPE, ID_SEQUENCER);
    uvvm_fifo_put(C_BUFFER_INDEX_1, std_logic_vector(to_unsigned(C_BUFFER_SIZE_1 / C_ENTRY_SIZE_1, C_ENTRY_SIZE_1)));
    check_value(uvvm_fifo_is_full(C_BUFFER_INDEX_1), true, TB_ERROR, "uvvm_fifo_is_full should return true.", C_SCOPE, ID_SEQUENCER);
    for i in 1 to (C_BUFFER_SIZE_1 / C_ENTRY_SIZE_1) loop
      check_value(uvvm_fifo_get(C_BUFFER_INDEX_1, C_ENTRY_SIZE_1) = std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), TB_ERROR, "uvvm_fifo_get should be " & to_string(std_logic_vector(to_unsigned(i, C_ENTRY_SIZE_1)), HEX) & ".", C_SCOPE, ID_SEQUENCER);
      check_value(uvvm_fifo_is_full(C_BUFFER_INDEX_1), false, TB_ERROR, "uvvm_fifo_is_full should return false.", C_SCOPE, ID_SEQUENCER);
    end loop;

    --------------------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Testing various corner cases", C_SCOPE);
    --------------------------------------------------------------------------------------------------------

    -- Which other corner cases must be tested?
    -- 1. Attempting to instantiate another queue when max (10) has been instantiated.
    -- 2. Creating max queues, and filling the entire buffer. Then pushing and pulling to the edges.
    -- 3. Creating a single one bit large queue and perform operations
    -- 4. Creating a single C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER large queue and perform operations.
    -- 5.

    -- 1. Instantiating more than max number of allowed queues:
    wait for 10 us;
    queue_under_test.deallocate_buffer(VOID);
    increment_expected_alerts(TB_ERROR, 1);
    for i in 0 to 10 loop
      v_buffer_idx_5 := queue_under_test.init_queue(2);
    end loop;

    -- 2. Max queues, filling entire buffer. Pushing and pulling to edges
    wait for 10 us;
    queue_under_test.deallocate_buffer(VOID);
    queue_under_test.init_queue(0, 4);
    for i in 1 to 9 loop
      queue_under_test.init_queue(i, integer(2 ** (i + 1)));
      wait for 10 ns;
    end loop;

    -- 3. Creating a single one bit large queue and perform operations
    wait for 10 us;
    queue_under_test.deallocate_buffer(VOID);
    queue_under_test.init_queue(0, 1);
    queue_under_test.push_back(0, "0");
    check_value(queue_under_test.get_count(0), 1, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    check_value(queue_under_test.peek_front(0, 1), "0", TB_ERROR, "Verifying that queue has correct value", C_SCOPE, HEX, AS_IS, ID_SEQUENCER);
    check_value(queue_under_test.get_count(0), 1, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    v_slv_1 := queue_under_test.pop_front(0, 1);
    check_value(queue_under_test.get_count(0), 0, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    check_value(v_slv_1, "0", TB_ERROR, "Verifying that pop_front returns correct value", C_SCOPE, HEX, AS_IS, ID_NEVER);
    wait for 10 us;
    queue_under_test.push_back(0, "1");
    check_value(queue_under_test.get_count(0), 1, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    check_value(queue_under_test.peek_back(0, 1), "1", TB_ERROR, "Peek_back: Verifying that queue has correct value", C_SCOPE, HEX, AS_IS, ID_SEQUENCER);
    check_value(queue_under_test.get_count(0), 1, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    v_slv_1 := queue_under_test.pop_back(0, 1);
    check_value(v_slv_1, "1", TB_ERROR, "Verifying that pop_back returns correct value", C_SCOPE, HEX, AS_IS, ID_NEVER);
    check_value(queue_under_test.get_count(0), 0, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    wait for 10 us;
    -- Test two consecutive writes, then read value
    queue_under_test.push_back(0, "1");
    queue_under_test.push_back(0, "0");
    v_slv_1 := queue_under_test.pop_back(0, 1);
    check_value(v_slv_1, "0", TB_ERROR, "Verifying that pop_back returns correct value", C_SCOPE, HEX, AS_IS, ID_NEVER);
    check_value(queue_under_test.get_count(0), 1, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER); -- shall be once here since we wrote twice

    -- 4. Creating a single C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER large queue and perform operations.
    queue_under_test.deallocate_buffer(VOID);
    queue_under_test.init_queue(0, C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER);
    queue_under_test.push_back(0, random(C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER));
    check_value(queue_under_test.get_count(0), C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    v_slv_max := queue_under_test.peek_front(0, C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER);
    check_value(queue_under_test.get_count(0), C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    v_slv_max := queue_under_test.pop_back(0, C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER);
    check_value(queue_under_test.get_count(0), 0, TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    queue_under_test.push_back(0, random(C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER));
    for i in 0 to C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - 1 loop
      v_slv_1 := queue_under_test.pop_front(0, 1);
      check_value(queue_under_test.get_count(0), C_TOTAL_NUMBER_OF_BITS_IN_DATA_BUFFER - (i + 1), TB_ERROR, "Verifying number of elements in queue", C_SCOPE, ID_NEVER);
    end loop;

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
