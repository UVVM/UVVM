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

architecture sync_arch of methods_tb is
  signal p_sync_test_enable : boolean := false;
begin

  ------------------------------------------
  -- Main process
  ------------------------------------------
  p_main : process
    constant C_SCOPE : string := "TB seq";
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    if GC_TESTCASE = "synchronization_methods" then
      log(ID_LOG_HDR, "Testing await_unblock_flag with KEEP_UNBLOCKED.", C_SCOPE);
      --1. Enable process p_sync_test and wait for flag to be blocked
      p_sync_test_enable <= true;
      wait for 10 ns;
      --3. Block flag A (already blocked by p_sync_test)
      block_flag("FLAG_A", "This flag should already be blocked.", warning, C_SCOPE);
      increment_expected_alerts(warning);
      --4. Unblock flag A
      unblock_flag("FLAG_A", "", global_trigger);
      --7. Wait for flag B
      await_unblock_flag("FLAG_B", 0 ns, "", KEEP_UNBLOCKED, warning, C_SCOPE);

      log(ID_LOG_HDR, "Testing await_unblock_flag with RETURN_TO_BLOCK.", C_SCOPE);
      block_flag("FLAG_A", "Block only once.", warning, C_SCOPE);
      for i in 1 to 5 loop
        wait for 10 ns;
        unblock_flag("FLAG_A", "", global_trigger);
      end loop;

      log(ID_LOG_HDR, "Testing await_unblock_flag with timeout.", C_SCOPE);
      wait for 100 ns;

      log(ID_LOG_HDR, "Registering maximum number of flags.", C_SCOPE);
      set_alert_stop_limit(TB_ERROR, 2);
      increment_expected_alerts(TB_ERROR);
      for i in 1 to C_NUM_SYNC_FLAGS - 1 loop
        block_flag("FLAG_" & to_string(i), "");
      end loop;
    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;              -- to allow some time for completion
    report_alert_counters(FINAL);  -- Report final counters and print conclusion for simulation (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);

    -- Finish the simulation
    std.env.stop;
    wait;                          -- to stop completely
  end process p_main;

  ------------------------------------------
  -- Secondary process
  ------------------------------------------
  p_sync_test : process
    constant C_SCOPE : string := "TB sync_seq";
  begin
    wait until p_sync_test_enable;

    -----------------------------------------------------
    -- Testing await_unblock_flag with KEEP_UNBLOCKED.
    -----------------------------------------------------
    --2. Wait for flag A, it will be created and blocked
    await_unblock_flag("FLAG_A", 0 ns, "Wait for an uninitialized flag, it will be created.", KEEP_UNBLOCKED, warning, C_SCOPE);
    --5. Unblock flag A (already unblocked)
    await_unblock_flag("FLAG_A", 0 ns, "Wait for an unblocked flag.", KEEP_UNBLOCKED, warning, C_SCOPE);
    --6. Block flag B
    block_flag("FLAG_B", "", warning, C_SCOPE);
    wait for 10 ns;
    --8. Unblock flag B
    unblock_flag("FLAG_B", "", global_trigger, C_SCOPE);

    -----------------------------------------------------
    -- Testing await_unblock_flag with RETURN_TO_BLOCK.
    -----------------------------------------------------
    for i in 1 to 5 loop
      await_unblock_flag("FLAG_A", 0 ns, "It will return to blocked.", RETURN_TO_BLOCK, warning, C_SCOPE);
    end loop;
    wait for 10 ns;

    -----------------------------------------------------
    -- Testing await_unblock_flag with timeout.
    -----------------------------------------------------
    await_unblock_flag("FLAG_A", 50 ns, "It will timeout.", KEEP_UNBLOCKED, warning, C_SCOPE);
    increment_expected_alerts(warning);

    wait;
  end process p_sync_test;

end architecture sync_arch;
