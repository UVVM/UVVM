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

architecture watchdog_arch of methods_tb is
  -- Watchdog timer control signals
  signal watchdog_ctrl_terminate : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_init      : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_extend    : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
  signal watchdog_ctrl_reinit    : t_watchdog_ctrl := C_WATCHDOG_CTRL_DEFAULT;
begin

  -- These timers should have a minimum timeout that covers all the
  -- tests in this testbench or else it will fail.
  watchdog_timer(watchdog_ctrl_terminate, 8100 ns, error, "Watchdog A");
  watchdog_timer(watchdog_ctrl_init, 8200 ns, error, "Watchdog B");
  watchdog_timer(watchdog_ctrl_extend, 8300 ns, error, "Watchdog C");
  watchdog_timer(watchdog_ctrl_reinit, 100 us, error, "Watchdog D");

  p_main : process
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "watchdog_timer" then
    ------------------------------------------------------------------------------------------------------------------------------
      wait for 8000 ns;
      log(ID_LOG_HDR, "Testing watchdog timer A (8100 ns) - terminate command", C_SCOPE);
      terminate_watchdog(watchdog_ctrl_terminate);

      log(ID_LOG_HDR, "Testing watchdog timer B (8200 ns) - initial timeout", C_SCOPE);
      wait for 199 ns;
      log(ID_SEQUENCER, "Watchdog B still running", C_SCOPE);
      increment_expected_alerts_and_stop_limit(error);
      wait for 1 ns;

      log(ID_LOG_HDR, "Testing watchdog timer C (8300 ns) - extend command", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 100 ns);
      wait for 199 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend);
      wait for 5300 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns);
      wait for 300 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns);
      wait for 300 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend);
      wait for 5300 ns;
      reinitialize_watchdog(watchdog_ctrl_extend, 101 ns);
      wait for 100 ns;
      log(ID_SEQUENCER, "Watchdog C still running", C_SCOPE);
      extend_watchdog(watchdog_ctrl_extend, 300 ns);
      wait for 300 ns;
      increment_expected_alerts_and_stop_limit(error);
      wait for 1 ns;

      log(ID_LOG_HDR, "Testing watchdog timer D (100 us) - reinitialize command", C_SCOPE);
      reinitialize_watchdog(watchdog_ctrl_reinit, 100 ns);
      wait for 99 ns;
      log(ID_SEQUENCER, "Watchdog D still running", C_SCOPE);
      increment_expected_alerts_and_stop_limit(error);
      wait for 1 ns;
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

end architecture watchdog_arch;
