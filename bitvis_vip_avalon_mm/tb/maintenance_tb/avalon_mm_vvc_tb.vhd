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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_avalon_mm;
context bitvis_vip_avalon_mm.vvc_context;

--hdlunit:tb
-- Test case entity
entity avalon_mm_vvc_tb is
  generic (
    GC_TESTCASE : string := "UVVM"
    );
end entity;

-- Test case architecture
architecture func of avalon_mm_vvc_tb is
  constant C_SCOPE      : string := "AVALON_MM_VVC_TB";
  constant C_CLK_PERIOD : time := 10 ns;

begin

  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.test_harness generic map(GC_CLK_PERIOD => C_CLK_PERIOD);

  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;


  ------------------------------------------------
  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
    -- Sequencer constants and variables
    constant C_SCOPE      : string             := C_TB_SCOPE_DEFAULT;
    variable v_cmd_idx    : natural;
    variable v_data       : std_logic_vector(C_VVC_CMD_DATA_MAX_LENGTH-1 downto 0);
    variable v_data_8     : std_logic_vector(7 downto 0) := (others => '0');
    variable v_is_ok      : boolean;
    variable v_timestamp  : time;

    variable v_alert_num_mismatch : boolean := false;

  begin

    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");


    await_uvvm_initialization(VOID);

    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_BFM);
    enable_log_msg(ID_BFM_POLL);

    disable_log_msg(AVALON_MM_VVCT, 1, ALL_MESSAGES);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_BFM);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_BFM_POLL);
    enable_log_msg(AVALON_MM_VVCT, 1, ID_CMD_EXECUTOR);

    disable_log_msg(AVALON_MM_VVCT, 2, ALL_MESSAGES);
    enable_log_msg(AVALON_MM_VVCT, 2, ID_BFM);
    enable_log_msg(AVALON_MM_VVCT, 2, ID_BFM_POLL);
    enable_log_msg(AVALON_MM_VVCT, 2, ID_CMD_EXECUTOR);

   -- Print the configuration to the log
    report_global_ctrl(VOID);
    report_msg_id_panel(VOID);

    shared_avalon_mm_vvc_config(1).bfm_config.clock_period := C_CLK_PERIOD;
    shared_avalon_mm_vvc_config(2).bfm_config.clock_period := C_CLK_PERIOD;

    log("Start Simulation of TB for AVALON_MM");
    ------------------------------------------------------------
    -- Reset the Avalon bus
    avalon_mm_reset(AVALON_MM_VVCT, 1, 5, "Resetting Avalon MM Interface 1");
    avalon_mm_reset(AVALON_MM_VVCT, 2, 5, "Resetting Avalon MM Interface 1");

    -- Allow some time before testing starts
    insert_delay(AVALON_MM_VVCT, 1, 50, "Giving the DUT some time to initialize");
    insert_delay(AVALON_MM_VVCT, 2, 50, "Giving the DUT some time to initialize");

    log(ID_LOG_HDR, "Testing basic read, write and check", C_SCOPE);
    ----------------------------------------------------------------------
    -- Write to the DUT
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"abba1111", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"abba5959", "Writing to the DUT");

    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for the first write to complete");
    await_completion(AVALON_MM_VVCT,2, 1000 ns, "Waiting for the first write to complete");

    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"aaaaaaaa", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"98765432", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"01234567", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"98765432", "Writing to the DUT");

    -- Read from the DUT
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", x"abba1111", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", x"aaaaaaaa", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", x"98765432", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", x"abba5959", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", x"01234567", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", x"98765432", "Checking the DUT", ERROR);

    await_completion(AVALON_MM_VVCT,1, 100 ns, "Waiting for checks to complete");
    await_completion(AVALON_MM_VVCT,2, 100 ns, "Waiting for checks to complete");


    log("Write, read back and check data with Scoreboard on one VVC");
    v_data_8 := x"10";

    avalon_mm_write(AVALON_MM_VVCT, 1, "0", v_data_8, "Write to Avalon MM 1");
    AVALON_MM_VVC_SB.add_expected(1, pad_avalon_mm_sb(v_data_8));
    avalon_mm_read(AVALON_MM_VVCT, 1, "0", TO_SB, "Reading without expected timeout using SB");   
    await_completion(AVALON_MM_VVCT,1, 10000 ns, "Wait for avalon_mm_read to finish");

    avalon_mm_write(AVALON_MM_VVCT, 2, "0", v_data_8, "Write to Avalon MM 2");
    AVALON_MM_VVC_SB.add_expected(2, pad_avalon_mm_sb(v_data_8));
    avalon_mm_read(AVALON_MM_VVCT, 2, "0", TO_SB, "Reading without expected timeout using SB");   
    await_completion(AVALON_MM_VVCT,2, 10000 ns, "Wait for avalon_mm_read to finish");

    AVALON_MM_VVC_SB.report_counters(ALL_INSTANCES);


    log("Write, read back and check data with avalon_mm_read on one VVC");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"10", "Write to Avalon MM 1");
    avalon_mm_read(AVALON_MM_VVCT, 1, "0", "Reading without expected timeout");
    v_cmd_idx := get_last_received_cmd_idx(AVALON_MM_VVCT, 1); -- for last read
    await_completion(AVALON_MM_VVCT,1, v_cmd_idx, 100 ns, "Wait for sbi_read to finish");
    fetch_result(AVALON_MM_VVCT,1 , v_cmd_idx, v_data, v_is_ok, "Fetching read-result");
    check_value(v_is_ok, ERROR, "Readback OK via fetch_result()");
    check_value(v_data(31 downto 0), x"10", ERROR, "Readback data via fetch_result()");

    log("Do another read - should timeout");
    shared_avalon_mm_vvc_config(1).bfm_config.max_wait_cycles_severity := WARNING;

    increment_expected_alerts(WARNING, 1);
    avalon_mm_read(AVALON_MM_VVCT, 1, "0", "read() with expected timeout");
    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for read() to timeout");

    shared_avalon_mm_vvc_config(1).use_read_pipeline := false;
    log("Do a check where the BFM procedure *check() calls *read_request() - should timeout");
    increment_expected_alerts(WARNING, 1);
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", "------------", "Check() with expected timeout", NO_ALERT);
    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for check() to timeout");

    shared_avalon_mm_vvc_config(1).use_read_pipeline := true;
    log("Do a check where the VVC calls *read_request() directly due to pipelining - should timeout");
    increment_expected_alerts(WARNING, 1);
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", "------------", "Check() with expected timeout", NO_ALERT);
    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for check() to timeout");

    shared_avalon_mm_vvc_config(1).bfm_config.max_wait_cycles_severity := TB_FAILURE;


    log(ID_LOG_HDR, "Testing FIFO Capacity", C_SCOPE);
    ----------------------------------------------------------------------

    log("Fill the FIFO with VVC 1 and 2 simultaneously");
    for i in 0 to 15 loop
      avalon_mm_write(AVALON_MM_VVCT, 1, "0", random(32), "Filling FIFO with random data");
      avalon_mm_write(AVALON_MM_VVCT, 2, "0", random(32), "Filling FIFO with random data");
    end loop;
    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for FIFO to be filled");
    await_completion(AVALON_MM_VVCT,2, 1000 ns, "Waiting for FIFO to be filled");

    log("Do another write - should timeout");
    shared_avalon_mm_vvc_config(1).bfm_config.max_wait_cycles_severity := WARNING;
    increment_expected_alerts(WARNING, 1);
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"deadbeef", "Writing to Avalon VVC 2");
    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for write timeout");
    shared_avalon_mm_vvc_config(1).bfm_config.max_wait_cycles_severity := TB_FAILURE;

    shared_avalon_mm_vvc_config(2).bfm_config.max_wait_cycles_severity := WARNING;
    increment_expected_alerts(WARNING, 1);
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"deadbeef", "Writing to Avalon VVC 2");
    await_completion(AVALON_MM_VVCT,2, 1000 ns, "Waiting for write timeout");
    shared_avalon_mm_vvc_config(2).bfm_config.max_wait_cycles_severity := TB_FAILURE;

    log("Empty the FIFO with VVC 2");
    for i in 0 to 15 loop
      avalon_mm_read(AVALON_MM_VVCT, 1, "0", "Reading the FIFO until empty");
      avalon_mm_read(AVALON_MM_VVCT, 2, "0", "Reading the FIFO until empty");
    end loop;
    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for FIFO to be emptied");
    await_completion(AVALON_MM_VVCT,2, 1000 ns, "Waiting for FIFO to be emptied");


    log(ID_LOG_HDR, "Testing Random FIFO Read and Write", C_SCOPE);
    ----------------------------------------------------------------------
    log("Data write and read-back with check");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", std_logic_vector(to_unsigned(100,32)), "Writing to Avalon MM 2");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", std_logic_vector(to_unsigned(100,32)), "Writing to Avalon MM 2");
    await_completion(AVALON_MM_VVCT,2, 100 ns, "Awaiting first sample ready in FIFO");
    for i in 100 to 200 loop
      avalon_mm_check(AVALON_MM_VVCT, 1, "0", std_logic_vector(to_unsigned(i,32)), "Checking Avalon MM 1");
      avalon_mm_check(AVALON_MM_VVCT, 2, "0", std_logic_vector(to_unsigned(i,32)), "Checking Avalon MM 2");
      avalon_mm_write(AVALON_MM_VVCT, 2, "0", std_logic_vector(to_unsigned(i+1,32)), "Writing to Avalon MM 2");
      avalon_mm_write(AVALON_MM_VVCT, 1, "0", std_logic_vector(to_unsigned(i+1,32)), "Writing to Avalon MM 1");
    end loop;
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", std_logic_vector(to_unsigned(201,32)), "Checking Avalon MM 1");
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", std_logic_vector(to_unsigned(201,32)), "Checking Avalon MM 2");

    insert_delay(AVALON_MM_VVCT, 1, 100, "Giving the DUT some time before shutting down");
    insert_delay(AVALON_MM_VVCT, 2, 100, "Giving the DUT some time before shutting down");

    await_completion(AVALON_MM_VVCT,1, 10000 ns, "Waiting for tests to complete");
    await_completion(AVALON_MM_VVCT,2, 10000 ns, "Waiting for tests to complete");


    log(ID_LOG_HDR, "Testing inter-bfm delay");

    log("\rChecking TIME_START2START");
    wait for C_CLK_PERIOD * 51;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_type := TIME_START2START;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_in_time := C_CLK_PERIOD * 50;
    v_timestamp := now;
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"abba1111", "First write to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"00101011", "Second write to the DUT");
    await_completion(AVALON_MM_VVCT, 1, 52 * C_CLK_PERIOD);
    check_value(((now - v_timestamp) = C_CLK_PERIOD*51+C_CLK_PERIOD/4), ERROR, "Checking that inter-bfm delay was upheld");

    log("\rChecking that insert_delay does not affect inter-BFM delay");
    wait for C_CLK_PERIOD * 51;
    v_timestamp := now;
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"aabbcccc", "Third write to the DUT");
    insert_delay(AVALON_MM_VVCT,1, C_CLK_PERIOD);
    insert_delay(AVALON_MM_VVCT,1, C_CLK_PERIOD);
    insert_delay(AVALON_MM_VVCT,1, C_CLK_PERIOD);
    insert_delay(AVALON_MM_VVCT,1, C_CLK_PERIOD);
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"beefbeef", "Fourth write to the DUT");
    await_completion(AVALON_MM_VVCT, 1, 52 * C_CLK_PERIOD + (4*C_CLK_PERIOD));
    check_value(((now - v_timestamp) = C_CLK_PERIOD*51 + (4*C_CLK_PERIOD)), ERROR, "Checking that inter-bfm delay was upheld");


    log("\rChecking TIME_FINISH2START");
    wait for C_CLK_PERIOD * 101;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_type := TIME_FINISH2START;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_in_time := C_CLK_PERIOD * 100;
    v_timestamp := now;
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"feedfeed", "First write to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"deedbeef", "Second write to the DUT");
    await_completion(AVALON_MM_VVCT, 1, 103 * C_CLK_PERIOD);
    check_value(((now - v_timestamp) = C_CLK_PERIOD*102), ERROR, "Checking that inter-bfm delay was upheld");

    log("\rChecking TIME_START2START and provoking inter-bfm delay violation");
    wait for C_CLK_PERIOD * 101;
    increment_expected_alerts(TB_WARNING,2);
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.inter_bfm_delay_violation_severity := TB_WARNING;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_type := TIME_START2START;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_in_time := 1 ns;
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"feedfeed", "First write to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"deedbeef", "Second write to the DUT");
    await_completion(AVALON_MM_VVCT, 1, 103 * C_CLK_PERIOD);

    log("Setting delay back to initial value");
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.inter_bfm_delay_violation_severity := WARNING;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_type := NO_DELAY;
    shared_avalon_mm_vvc_config(1).inter_bfm_delay.delay_in_time := 0 ns;

    wait for C_CLK_PERIOD * 5;

    log(ID_LOG_HDR, "Testing basic read, write and check with setup_time = 2 ns and hold_time = 2 ns", C_SCOPE);
    -- Reset the Avalon bus
    avalon_mm_reset(AVALON_MM_VVCT, 1, 5, "Resetting Avalon MM Interface 1");
    avalon_mm_reset(AVALON_MM_VVCT, 2, 5, "Resetting Avalon MM Interface 1");

    -- Allow some time before testing starts
    insert_delay(AVALON_MM_VVCT, 1, 50, "Giving the DUT some time to initialize");
    insert_delay(AVALON_MM_VVCT, 2, 50, "Giving the DUT some time to initialize");

    ----------------------------------------------------------------------
    shared_avalon_mm_vvc_config(1).bfm_config.bfm_sync := SYNC_WITH_SETUP_AND_HOLD;
    shared_avalon_mm_vvc_config(2).bfm_config.bfm_sync := SYNC_WITH_SETUP_AND_HOLD;
    shared_avalon_mm_vvc_config(1).bfm_config.setup_time := 2 ns;
    shared_avalon_mm_vvc_config(2).bfm_config.setup_time := 2 ns;
    shared_avalon_mm_vvc_config(1).bfm_config.hold_time := 2 ns;
    shared_avalon_mm_vvc_config(2).bfm_config.hold_time := 2 ns;

    -- Write to the DUT
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"abba1111", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"abba5959", "Writing to the DUT");

    await_completion(AVALON_MM_VVCT,1, 1000 ns, "Waiting for the first write to complete");
    await_completion(AVALON_MM_VVCT,2, 1000 ns, "Waiting for the first write to complete");

    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"aaaaaaaa", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 1, "0", x"98765432", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"01234567", "Writing to the DUT");
    avalon_mm_write(AVALON_MM_VVCT, 2, "0", x"98765432", "Writing to the DUT");

    -- Read from the DUT
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", x"abba1111", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", x"aaaaaaaa", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 1, "0", x"98765432", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", x"abba5959", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", x"01234567", "Checking the DUT", ERROR);
    avalon_mm_check(AVALON_MM_VVCT, 2, "0", x"98765432", "Checking the DUT", ERROR);

    await_completion(AVALON_MM_VVCT,1, 100 ns, "Waiting for checks to complete");
    await_completion(AVALON_MM_VVCT,2, 100 ns, "Waiting for checks to complete");

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
