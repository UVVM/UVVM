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

architecture await_arch of methods_tb is
  signal bool   : boolean                      := false;
  signal slv8   : std_logic_vector(7 downto 0) := (others => '0');
  signal uns8   : unsigned(7 downto 0)         := (others => '0');
  signal sig8   : signed(7 downto 0)           := (others => '0');
  signal int    : integer                      := 0;
  signal real_a : real                         := 0.0;
  signal sl     : std_logic                    := '0';
begin

  p_main : process
  begin
    -- To avoid that log files from different test cases (run in separate
    -- simulations) overwrite each other.
    set_log_file_name(GC_TESTCASE & "_Log.txt");
    set_alert_file_name(GC_TESTCASE & "_Alert.txt");

    ------------------------------------------------------------------------------------------------------------------------------
    if GC_TESTCASE = "await_stable" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_stable", C_SCOPE);
      -------------------------------------
      -- await_stable(boolean)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      bool <= transport bool after 30 ns; -- No 'Event
      await_stable(bool, 50 ns, FROM_NOW, 51 ns, FROM_NOW, error, "bool: No 'event, Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      bool <= transport not bool after 30 ns;
      await_stable(bool, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "bool: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      bool <= transport not bool after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "bool: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "bool: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(bool, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "bool: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      bool <= not bool;
      wait for 10 ns;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "bool: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      bool <= not bool;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "bool: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      bool <= not bool;
      wait for 11 ns;
      bool <= transport not bool after 10 ns;
      await_stable(bool, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "bool: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      bool <= not bool;
      wait for 10 ns;
      bool <= transport not bool after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "bool: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      bool <= not bool;
      wait for 100 ns;
      bool <= transport not bool after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "bool: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      bool <= not bool;
      wait for 100 ns;
      bool <= transport not bool after 10 ns;
      await_stable(bool, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "bool: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      bool <= not bool;
      wait for 10 ns;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "bool: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bool <= not bool;
      wait for 10 ns;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "bool: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bool <= not bool;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "bool: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(std_logic)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "sl: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "sl: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "sl: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "sl: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(sl, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "sl: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      sl <= not sl;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      sl <= not sl;
      wait for 11 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      sl <= transport not sl after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "sl: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "sl: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "sl: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(std_logic_vector)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "slv8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "slv8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "slv8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "slv8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(slv8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "slv8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      slv8 <= not slv8;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      slv8 <= not slv8;
      wait for 11 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      slv8 <= transport not slv8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "slv8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "slv8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "slv8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(unsigned)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(uns8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "uns8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      uns8 <= transport not uns8 after 30 ns;
      await_stable(uns8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "uns8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      uns8 <= transport not uns8 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "uns8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "uns8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(uns8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "uns8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      uns8 <= not uns8;
      wait for 10 ns;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "uns8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      uns8 <= not uns8;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "uns8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      uns8 <= not uns8;
      wait for 11 ns;
      uns8 <= transport not uns8 after 10 ns;
      await_stable(uns8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "uns8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      uns8 <= not uns8;
      wait for 10 ns;
      uns8 <= transport not uns8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "uns8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      uns8 <= not uns8;
      wait for 100 ns;
      uns8 <= transport not uns8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "uns8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      uns8 <= not uns8;
      wait for 100 ns;
      uns8 <= transport not uns8 after 10 ns;
      await_stable(uns8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "uns8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      uns8 <= not uns8;
      wait for 10 ns;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "uns8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      uns8 <= not uns8;
      wait for 10 ns;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "uns8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      uns8 <= not uns8;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "uns8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(signed)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(sig8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "sig8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      sig8 <= transport not sig8 after 30 ns;
      await_stable(sig8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "sig8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      sig8 <= transport not sig8 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "sig8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "sig8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(sig8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "sig8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      sig8 <= not sig8;
      wait for 10 ns;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "sig8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      sig8 <= not sig8;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "sig8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      sig8 <= not sig8;
      wait for 11 ns;
      sig8 <= transport not sig8 after 10 ns;
      await_stable(sig8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "sig8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      sig8 <= not sig8;
      wait for 10 ns;
      sig8 <= transport not sig8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "sig8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      sig8 <= not sig8;
      wait for 100 ns;
      sig8 <= transport not sig8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "sig8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      sig8 <= not sig8;
      wait for 100 ns;
      sig8 <= transport not sig8 after 10 ns;
      await_stable(sig8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "sig8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      sig8 <= not sig8;
      wait for 10 ns;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "sig8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sig8 <= not sig8;
      wait for 10 ns;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "sig8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sig8 <= not sig8;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "sig8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(integer)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(int, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "int: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      int <= transport int + 1 after 30 ns;
      await_stable(int, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "int: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      int <= transport int + 1 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "int: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "int: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(int, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "int: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      int <= int + 1;
      wait for 10 ns;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "int: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      int <= int + 1;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "int: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      int <= int + 1;
      wait for 11 ns;
      int <= transport int + 1 after 10 ns;
      await_stable(int, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "int: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      int <= int + 1;
      wait for 10 ns;
      int <= transport int + 1 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "int: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      int <= int + 1;
      wait for 100 ns;
      int <= transport int + 1 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "int: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      int <= int + 1;
      wait for 100 ns;
      int <= transport int + 1 after 10 ns;
      await_stable(int, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "int: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      int <= int + 1;
      wait for 10 ns;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "int: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      int <= int + 1;
      wait for 10 ns;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "int: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      int <= int + 1;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "int: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(real)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(real_a, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "real_a: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      real_a <= transport real_a + 1.0 after 30 ns;
      await_stable(real_a, 50 ns, FROM_NOW, 100 ns, FROM_NOW, error, "real_a: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      real_a <= transport real_a + 1.0 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 50 ns, FROM_NOW, 60 ns, FROM_NOW, error, "real_a: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 50 ns, FROM_NOW, 1 ns, FROM_NOW, error, "real_a: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(real_a, 0 ns, FROM_NOW, 0 ns, FROM_NOW, error, "real_a: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      real_a <= real_a + 1.0;
      wait for 10 ns;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "real_a: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      real_a <= real_a + 1.0;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, error, "real_a: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 11 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      await_stable(real_a, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, error, "real_a: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 10 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, error, "real_a: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      real_a <= real_a + 1.0;
      wait for 100 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, error, "real_a: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 100 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      await_stable(real_a, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, error, "real_a: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      real_a <= real_a + 1.0;
      wait for 10 ns;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, error, "real_a: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 10 ns;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, error, "real_a: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, error, "real_a: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "await_stable_default_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_stable with default alert level", C_SCOPE);
      -------------------------------------
      -- await_stable(boolean)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      bool <= transport bool after 30 ns; -- No 'Event
      await_stable(bool, 50 ns, FROM_NOW, 51 ns, FROM_NOW, "bool: No 'event, Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      bool <= transport not bool after 30 ns;
      await_stable(bool, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "bool: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      bool <= transport not bool after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "bool: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "bool: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(bool, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "bool: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      bool <= not bool;
      wait for 10 ns;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "bool: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      bool <= not bool;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "bool: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      bool <= not bool;
      wait for 11 ns;
      bool <= transport not bool after 10 ns;
      await_stable(bool, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "bool: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      bool <= not bool;
      wait for 10 ns;
      bool <= transport not bool after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "bool: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      bool <= not bool;
      wait for 100 ns;
      bool <= transport not bool after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "bool: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      bool <= not bool;
      wait for 100 ns;
      bool <= transport not bool after 10 ns;
      await_stable(bool, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "bool: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      bool <= not bool;
      wait for 10 ns;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "bool: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bool <= not bool;
      wait for 10 ns;
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "bool: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      bool <= not bool;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(bool, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "bool: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(std_logic)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "sl: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      await_stable(sl, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "sl: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      sl <= transport not sl after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "sl: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "sl: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(sl, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "sl: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      sl <= not sl;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      sl <= not sl;
      wait for 11 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "sl: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      sl <= transport not sl after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "sl: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "sl: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      sl <= not sl;
      wait for 100 ns;
      sl <= transport not sl after 10 ns;
      await_stable(sl, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "sl: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sl <= not sl;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sl, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "sl: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(std_logic_vector)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "slv8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      await_stable(slv8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "slv8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      slv8 <= transport not slv8 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "slv8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "slv8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(slv8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "slv8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      slv8 <= not slv8;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      slv8 <= not slv8;
      wait for 11 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "slv8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      slv8 <= transport not slv8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "slv8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "slv8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      slv8 <= not slv8;
      wait for 100 ns;
      slv8 <= transport not slv8 after 10 ns;
      await_stable(slv8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "slv8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      slv8 <= not slv8;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(slv8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "slv8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(unsigned)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(uns8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "uns8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      uns8 <= transport not uns8 after 30 ns;
      await_stable(uns8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "uns8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      uns8 <= transport not uns8 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "uns8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "uns8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(uns8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "uns8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      uns8 <= not uns8;
      wait for 10 ns;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "uns8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      uns8 <= not uns8;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "uns8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      uns8 <= not uns8;
      wait for 11 ns;
      uns8 <= transport not uns8 after 10 ns;
      await_stable(uns8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "uns8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      uns8 <= not uns8;
      wait for 10 ns;
      uns8 <= transport not uns8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "uns8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      uns8 <= not uns8;
      wait for 100 ns;
      uns8 <= transport not uns8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "uns8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      uns8 <= not uns8;
      wait for 100 ns;
      uns8 <= transport not uns8 after 10 ns;
      await_stable(uns8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "uns8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      uns8 <= not uns8;
      wait for 10 ns;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "uns8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      uns8 <= not uns8;
      wait for 10 ns;
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "uns8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      uns8 <= not uns8;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(uns8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "uns8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(signed)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(sig8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "sig8: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      sig8 <= transport not sig8 after 30 ns;
      await_stable(sig8, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "sig8: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      sig8 <= transport not sig8 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "sig8: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "sig8: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(sig8, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "sig8: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      sig8 <= not sig8;
      wait for 10 ns;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "sig8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      sig8 <= not sig8;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "sig8: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      sig8 <= not sig8;
      wait for 11 ns;
      sig8 <= transport not sig8 after 10 ns;
      await_stable(sig8, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "sig8: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      sig8 <= not sig8;
      wait for 10 ns;
      sig8 <= transport not sig8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "sig8: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      sig8 <= not sig8;
      wait for 100 ns;
      sig8 <= transport not sig8 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "sig8: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      sig8 <= not sig8;
      wait for 100 ns;
      sig8 <= transport not sig8 after 10 ns;
      await_stable(sig8, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "sig8: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      sig8 <= not sig8;
      wait for 10 ns;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "sig8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sig8 <= not sig8;
      wait for 10 ns;
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "sig8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      sig8 <= not sig8;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(sig8, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "sig8: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(integer)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(int, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "int: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      int <= transport int + 1 after 30 ns;
      await_stable(int, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "int: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      int <= transport int + 1 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "int: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "int: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(int, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "int: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      int <= int + 1;
      wait for 10 ns;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "int: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      int <= int + 1;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "int: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      int <= int + 1;
      wait for 11 ns;
      int <= transport int + 1 after 10 ns;
      await_stable(int, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "int: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      int <= int + 1;
      wait for 10 ns;
      int <= transport int + 1 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "int: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      int <= int + 1;
      wait for 100 ns;
      int <= transport int + 1 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "int: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      int <= int + 1;
      wait for 100 ns;
      int <= transport int + 1 after 10 ns;
      await_stable(int, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "int: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      int <= int + 1;
      wait for 10 ns;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "int: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      int <= int + 1;
      wait for 10 ns;
      await_stable(int, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "int: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      int <= int + 1;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(int, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "int: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

      -------------------------------------
      -- await_stable(real)
      -------------------------------------
      -- FROM_NOW, FROM_NOW
      await_stable(real_a, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "real_a: Stable FROM_NOW, FROM_NOW, OK after 50 ns", C_SCOPE);

      real_a <= transport real_a + 1.0 after 30 ns;
      await_stable(real_a, 50 ns, FROM_NOW, 100 ns, FROM_NOW, "real_a: Stable FROM_NOW, FROM_NOW, OK after 80 ns", C_SCOPE);

      real_a <= transport real_a + 1.0 after 30 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 50 ns, FROM_NOW, 60 ns, FROM_NOW, "real_a: Not stable FROM_NOW, FROM_NOW, Fail after 30 ns", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 50 ns, FROM_NOW, 1 ns, FROM_NOW, "real_a: Timeout before stable_req, FROM_NOW, FROM_NOW, Fail immediately", C_SCOPE);

      await_stable(real_a, 0 ns, FROM_NOW, 0 ns, FROM_NOW, "real_a: stable for 0 ns, FROM_NOW, FROM_NOW, OK after 0 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_NOW
      real_a <= real_a + 1.0;
      wait for 10 ns;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "real_a: Stable FROM_LAST_EVENT, FROM_NOW, OK after 40 ns", C_SCOPE);

      wait for 50 ns;
      real_a <= real_a + 1.0;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_NOW, "real_a: Stable FROM_LAST_EVENT, FROM_NOW, OK immediately (even though an event occurrs the next delta cycle)", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 11 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      await_stable(real_a, 20 ns, FROM_LAST_EVENT, 11 ns, FROM_NOW, "real_a: Stable FROM_LAST_EVENT, FROM_NOW, OK after 9 ns", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 10 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 21 ns, FROM_LAST_EVENT, 20 ns, FROM_NOW, "real_a: Not stable FROM_LAST_EVENT, FROM_NOW, Fail after 10 ns", C_SCOPE);

      -- FROM_NOW, FROM_LAST_EVENT
      real_a <= real_a + 1.0;
      wait for 100 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 40 ns, FROM_NOW, 100 ns, FROM_LAST_EVENT, "real_a: FROM_NOW, FROM_LAST_EVENT, Fail immediately", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 100 ns;
      real_a <= transport real_a + 1.0 after 10 ns;
      await_stable(real_a, 40 ns, FROM_NOW, 150 ns, FROM_LAST_EVENT, "real_a: FROM_NOW, FROM_LAST_EVENT, OK after 50 ns", C_SCOPE);

      -- FROM_LAST_EVENT, FROM_LAST_EVENT
      real_a <= real_a + 1.0;
      wait for 10 ns;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 100 ns, FROM_LAST_EVENT, "real_a: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 10 ns;
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 50 ns, FROM_LAST_EVENT, "real_a: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, OK after 40 ns", C_SCOPE);

      real_a <= real_a + 1.0;
      wait for 10 ns;
      increment_expected_alerts_and_stop_limit(error, 1);
      await_stable(real_a, 50 ns, FROM_LAST_EVENT, 49 ns, FROM_LAST_EVENT, "real_a: Stable FROM_LAST_EVENT, FROM_LAST_EVENT, FAIL after 39 ns", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "await_change" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_change", C_SCOPE);
      increment_expected_alerts_and_stop_limit(error, 2);
      bool <= transport false after 2 ns;
      await_change(bool, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      bool <= transport true after 3 ns;
      await_change(bool, 3 ns, 5 ns, error, "Change within time window 1, OK", C_SCOPE);
      bool <= transport false after 4 ns;
      await_change(bool, 3 ns, 5 ns, error, "Change within time window 2, OK", C_SCOPE);
      bool <= transport true after 5 ns;
      await_change(bool, 3 ns, 5 ns, error, "Change within time window 3, OK", C_SCOPE);
      await_change(bool, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      sl <= transport '0' after 2 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      sl <= transport '1' after 3 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '0' after 4 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 5 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_change(sl, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      slv8 <= transport "00000001" after 2 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      slv8 <= transport "00000010" after 3 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change within time window 2, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change within time window 3, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_change(slv8, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      uns8 <= transport "00000001" after 2 ns;
      await_change(uns8, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      uns8 <= transport "00000010" after 3 ns;
      await_change(uns8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000011" after 4 ns;
      await_change(uns8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000100" after 5 ns;
      await_change(uns8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000101" after 6 ns;
      await_change(uns8, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      sig8 <= transport "00000001" after 2 ns;
      await_change(sig8, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      sig8 <= transport "00000010" after 3 ns;
      await_change(sig8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000011" after 4 ns;
      await_change(sig8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000100" after 5 ns;
      await_change(sig8, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000101" after 6 ns;
      await_change(sig8, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      int <= transport 1 after 2 ns;
      await_change(int, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      int <= transport 2 after 3 ns;
      await_change(int, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      int <= transport 3 after 4 ns;
      await_change(int, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      int <= transport 4 after 5 ns;
      await_change(int, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      int <= transport 5 after 6 ns;
      await_change(int, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      real_a <= transport 1.0 after 2 ns;
      await_change(real_a, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      real_a <= transport 2.0 after 3 ns;
      await_change(real_a, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      real_a <= transport 3.0 after 4 ns;
      await_change(real_a, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      real_a <= transport 4.0 after 5 ns;
      await_change(real_a, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      real_a <= transport 5.0 after 6 ns;
      await_change(real_a, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "await_change_default_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_change with default alert level", C_SCOPE);
      increment_expected_alerts_and_stop_limit(error, 2);
      bool <= transport false after 2 ns;
      await_change(bool, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      bool <= transport true after 3 ns;
      await_change(bool, 3 ns, 5 ns, "Change within time window 1, OK", C_SCOPE);
      bool <= transport false after 4 ns;
      await_change(bool, 3 ns, 5 ns, "Change within time window 2, OK", C_SCOPE);
      bool <= transport true after 5 ns;
      await_change(bool, 3 ns, 5 ns, "Change within time window 3, OK", C_SCOPE);
      await_change(bool, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      sl <= transport '0' after 2 ns;
      await_change(sl, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      sl <= transport '1' after 3 ns;
      await_change(sl, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '0' after 4 ns;
      await_change(sl, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 5 ns;
      await_change(sl, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_change(sl, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      slv8 <= transport "00000001" after 2 ns;
      await_change(slv8, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      slv8 <= transport "00000010" after 3 ns;
      await_change(slv8, 3 ns, 5 ns, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_change(slv8, 3 ns, 5 ns, "Change within time window 2, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_change(slv8, 3 ns, 5 ns, "Change within time window 3, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_change(slv8, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      uns8 <= transport "00000001" after 2 ns;
      await_change(uns8, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      uns8 <= transport "00000010" after 3 ns;
      await_change(uns8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000011" after 4 ns;
      await_change(uns8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000100" after 5 ns;
      await_change(uns8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000101" after 6 ns;
      await_change(uns8, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      sig8 <= transport "00000001" after 2 ns;
      await_change(sig8, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      sig8 <= transport "00000010" after 3 ns;
      await_change(sig8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000011" after 4 ns;
      await_change(sig8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000100" after 5 ns;
      await_change(sig8, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000101" after 6 ns;
      await_change(sig8, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      int <= transport 1 after 2 ns;
      await_change(int, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      int <= transport 2 after 3 ns;
      await_change(int, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      int <= transport 3 after 4 ns;
      await_change(int, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      int <= transport 4 after 5 ns;
      await_change(int, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      int <= transport 5 after 6 ns;
      await_change(int, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 2);
      real_a <= transport 1.0 after 2 ns;
      await_change(real_a, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      real_a <= transport 2.0 after 3 ns;
      await_change(real_a, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      real_a <= transport 3.0 after 4 ns;
      await_change(real_a, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      real_a <= transport 4.0 after 5 ns;
      await_change(real_a, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      real_a <= transport 5.0 after 6 ns;
      await_change(real_a, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "await_value" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_value", C_SCOPE);
      -------------------------------------
      -- await_value : SLV
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 4);
      slv8 <= "00000000";
      slv8 <= transport "00000001" after 2 ns;
      await_value(slv8, "00000001", 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00000010" after 3 ns;
      await_value(slv8, "00000010", 3 ns, 5 ns, error, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "000000011", 3 ns, 5 ns, error, "Change within time window 2, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_value(slv8, "0000100", 3 ns, 5 ns, error, "Change within time window 3, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_value(slv8, "00000101", 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      slv8 <= transport "00000110" after 1 ns;
      slv8 <= transport "00000111" after 2 ns;
      slv8 <= transport "00001000" after 4 ns;
      await_value(slv8, "00001000", 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      await_value(slv8, "100010011", 3 ns, 5 ns, error, "Different width, Fail", C_SCOPE);
      slv8 <= transport "00001001" after 0 ns;
      await_value(slv8, "00001001", 0 ns, 1 ns, error, "Changed immediately, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00001111" after 0 ns;
      slv8 <= transport "10000000" after 1 ns;
      await_value(slv8, "00001111", 0 ns, 0 ns, error, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(slv8, "00001111", 0 ns, 1 ns, error, "Val=exp already, No signal'event. OK. Log in HEX", C_SCOPE, HEX);
      await_value(slv8, "00001111", 0 ns, 2 ns, error, "Val=exp already, No signal'event. OK. Log in DECimal", C_SCOPE, DEC);
      slv8 <= "10000000";
      wait for 1 ns;
      await_value(slv8, "10000000", 0 ns, 0 ns, error, "Val=exp already, No signal'event. OK. ", C_SCOPE, HEX);
      await_value(slv8, "10000000", 1 ns, 2 ns, error, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE, HEX);

      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "00000011", MATCH_EXACT, 3 ns, 5 ns, error, "Change within time window 2, exact match, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "10110001" after 4 ns;
      await_value(slv8, "10--0001", MATCH_STD, 3 ns, 5 ns, error, "Change within time window 2, STD match, OK", C_SCOPE);

      -- MATCH_STD_INCL_Z
      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 10 ns;
      slv8 <= transport "1011000Z" after 4 ns;
      await_value(slv8, "1011000Z", MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Change within time window 3, STD match including Z, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "Z011000Z" after 4 ns;
      await_value(slv8, "1011000Z", MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Different values, STD match including Z, Fail", C_SCOPE);

      -- MATCH_STD_INCL_ZXUW
      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 10 ns;
      slv8 <= transport "1W1U0X0Z" after 4 ns;
      await_value(slv8, "1W1U0X0Z", MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window 3, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "1W110X0Z" after 4 ns;
      await_value(slv8, "1W1U1X0Z", MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 1", C_SCOPE);

      -------------------------------------
      -- await_value : unsigned
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 2);
      uns8 <= "00000000";
      uns8 <= transport "00000001" after 2 ns;
      await_value(uns8, "00000001", 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      uns8 <= transport "00000010" after 3 ns;
      await_value(uns8, "00000010", 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000101" after 6 ns;
      await_value(uns8, "00000101", 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      uns8 <= transport "00001111" after 0 ns;
      uns8 <= transport "10000000" after 1 ns;
      await_value(uns8, "00001111", 0 ns, 0 ns, error, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(uns8, "00001111", 0 ns, 0 ns, error, "Changed immediately, OK. Log in HEX", C_SCOPE, HEX);
      await_value(uns8, "00001111", 0 ns, 2 ns, error, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);

      -------------------------------------
      -- await_value : signed
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 2);
      sig8 <= "00000000";
      sig8 <= transport "00000001" after 2 ns;
      await_value(sig8, "00000001", 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      sig8 <= transport "00000010" after 3 ns;
      await_value(sig8, "00000010", 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000101" after 6 ns;
      await_value(sig8, "00000101", 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      sig8 <= transport "00001111" after 0 ns;
      await_value(sig8, "00001111", 0 ns, 1 ns, error, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);

      -------------------------------------
      -- await_value : boolean
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 3);
      bool <= false;
      bool <= transport true after 2 ns;
      await_value(bool, true, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      bool <= transport false after 3 ns;
      await_value(bool, false, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      bool <= transport true after 6 ns;
      await_value(bool, true, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      bool <= transport false after 0 ns;
      await_value(bool, false, 0 ns, 1 ns, error, "Changed immediately, OK. ", C_SCOPE);
      bool <= true;
      wait for 0 ns;
      bool <= transport false after 1 ns;
      await_value(bool, true, 0 ns, 2 ns, error, "Val=exp already, No signal'event. OK. ", C_SCOPE);
      bool <= true;
      wait for 0 ns;
      await_value(bool, true, 1 ns, 2 ns, error, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);

      -------------------------------------
      -- await_value : std_logic
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 5);
      sl <= '0';
      sl <= transport '1' after 2 ns;
      await_value(sl, '1', 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, '0', 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_value(sl, '1', 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 0 ns;
      wait for 0 ns;
      sl <= transport '1' after 1 ns;
      await_value(sl, '0', 0 ns, 2 ns, error, "Changed immediately, OK. ", C_SCOPE);
      sl <= '1';
      wait for 10 ns;
      await_value(sl, '1', 1 ns, 2 ns, error, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'L' after 3 ns;
      await_value(sl, '0', MATCH_STD, 3 ns, 5 ns, error, "Change within time window to weak, expecting forced, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'H', MATCH_STD, 3 ns, 5 ns, error, "Change within time window to forced, expecting weak, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, 'L', MATCH_EXACT, 3 ns, 5 ns, error, "Change within time window to forced, expecting weak, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'H' after 3 ns;
      await_value(sl, '1', MATCH_EXACT, 3 ns, 5 ns, error, "Change within time window to weak, expecting forced, Fail", C_SCOPE);
      wait for 10 ns;

      -- MATCH_STD_INCL_Z
      increment_expected_alerts_and_stop_limit(error, 1);
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'Z' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Change within time window, STD match including Z, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_Z, 3 ns, 5 ns, error, "Different values, STD match including Z, Fail", C_SCOPE);

      -- MATCH_STD_INCL_ZXUW
      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'Z' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 2", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'X' after 3 ns;
      await_value(sl, 'X', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'X', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 3", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'U' after 3 ns;
      await_value(sl, 'U', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'U', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 4", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'W' after 3 ns;
      await_value(sl, 'W', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'W', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, error, "Different values, STD match including ZXUW, Fail 5", C_SCOPE);

      -------------------------------------
      -- await_value : integer
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 3);
      int <= 0;
      int <= transport 1 after 2 ns;
      await_value(int, 1, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      int <= transport 2 after 3 ns;
      await_value(int, 2, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      int <= transport 3 after 6 ns;
      await_value(int, 3, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      int <= transport 15 after 0 ns;
      wait for 0 ns;
      int <= transport 16 after 1 ns;
      await_value(int, 15, 0 ns, 2 ns, error, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      int <= 17;
      wait for 0 ns;
      await_value(int, 17, 1 ns, 2 ns, error, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);

      -------------------------------------
      -- await_value : real
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 3);
      real_a <= 0.0;
      real_a <= transport 1.0 after 2 ns;
      await_value(real_a, 1.0, 3 ns, 5 ns, error, "Change too soon, Fail", C_SCOPE);
      real_a <= transport 2.0 after 3 ns;
      await_value(real_a, 2.0, 3 ns, 5 ns, error, "Change within time window, OK", C_SCOPE);
      real_a <= transport 3.0 after 6 ns;
      await_value(real_a, 3.0, 3 ns, 5 ns, error, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      real_a <= transport 15.0 after 0 ns;
      wait for 0 ns;
      real_a <= transport 16.0 after 1 ns;
      await_value(real_a, 15.0, 0 ns, 2 ns, error, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      real_a <= 17.0;
      wait for 0 ns;
      await_value(real_a, 17.0, 1 ns, 2 ns, error, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);

    ------------------------------------------------------------------------------------------------------------------------------
    elsif GC_TESTCASE = "await_value_default_alert" then
    ------------------------------------------------------------------------------------------------------------------------------
      log(ID_LOG_HDR, "Verifying await_value with default alert level", C_SCOPE);
      -------------------------------------
      -- await_value : SLV
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 4);
      slv8 <= "00000000";
      slv8 <= transport "00000001" after 2 ns;
      await_value(slv8, "00000001", 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00000010" after 3 ns;
      await_value(slv8, "00000010", 3 ns, 5 ns, "Change within time window 1, OK", C_SCOPE);
      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "000000011", 3 ns, 5 ns, "Change within time window 2, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000100" after 5 ns;
      await_value(slv8, "0000100", 3 ns, 5 ns, "Change within time window 3, leading zero, OK", C_SCOPE);
      slv8 <= transport "00000101" after 6 ns;
      await_value(slv8, "00000101", 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      slv8 <= transport "00000110" after 1 ns;
      slv8 <= transport "00000111" after 2 ns;
      slv8 <= transport "00001000" after 4 ns;
      await_value(slv8, "00001000", 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      await_value(slv8, "100010011", 3 ns, 5 ns, "Different width, Fail", C_SCOPE);
      slv8 <= transport "00001001" after 0 ns;
      await_value(slv8, "00001001", 0 ns, 1 ns, "Changed immediately, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "00001111" after 0 ns;
      slv8 <= transport "10000000" after 1 ns;
      await_value(slv8, "00001111", 0 ns, 0 ns, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(slv8, "00001111", 0 ns, 1 ns, "Val=exp already, No signal'event. OK. Log in HEX", C_SCOPE, HEX);
      await_value(slv8, "00001111", 0 ns, 2 ns, "Val=exp already, No signal'event. OK. Log in DECimal", C_SCOPE, DEC);
      slv8 <= "10000000";
      wait for 1 ns;
      await_value(slv8, "10000000", 0 ns, 0 ns, "Val=exp already, No signal'event. OK. ", C_SCOPE, HEX);
      await_value(slv8, "10000000", 1 ns, 2 ns, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE, HEX);

      slv8 <= transport "00000011" after 4 ns;
      await_value(slv8, "00000011", MATCH_EXACT, 3 ns, 5 ns, "Change within time window 2, exact match, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "10110001" after 4 ns;
      await_value(slv8, "10--0001", MATCH_STD, 3 ns, 5 ns, "Change within time window 2, STD match, OK", C_SCOPE);

      -- MATCH_STD_INCL_Z
      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 10 ns;
      slv8 <= transport "1011000Z" after 4 ns;
      await_value(slv8, "1011000Z", MATCH_STD_INCL_Z, 3 ns, 5 ns, "Change within time window 3, STD match including Z, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "Z011000Z" after 4 ns;
      await_value(slv8, "1011000Z", MATCH_STD_INCL_Z, 3 ns, 5 ns, "Different values, STD match including Z, Fail", C_SCOPE);

      -- MATCH_STD_INCL_ZXUW
      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 10 ns;
      slv8 <= transport "1W1U0X0Z" after 4 ns;
      await_value(slv8, "1W1U0X0Z", MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Change within time window 3, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      slv8 <= transport "1W110X0Z" after 4 ns;
      await_value(slv8, "1W1U1X0Z", MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Different values, STD match including ZXUW, Fail 1", C_SCOPE);

      -------------------------------------
      -- await_value : unsigned
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 2);
      uns8 <= "00000000";
      uns8 <= transport "00000001" after 2 ns;
      await_value(uns8, "00000001", 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      uns8 <= transport "00000010" after 3 ns;
      await_value(uns8, "00000010", 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      uns8 <= transport "00000101" after 6 ns;
      await_value(uns8, "00000101", 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      uns8 <= transport "00001111" after 0 ns;
      uns8 <= transport "10000000" after 1 ns;
      await_value(uns8, "00001111", 0 ns, 0 ns, "Changed immediately, OK. Log in BIN", C_SCOPE, BIN);
      await_value(uns8, "00001111", 0 ns, 0 ns, "Changed immediately, OK. Log in HEX", C_SCOPE, HEX);
      await_value(uns8, "00001111", 0 ns, 2 ns, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);

      -------------------------------------
      -- await_value : signed
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 2);
      sig8 <= "00000000";
      sig8 <= transport "00000001" after 2 ns;
      await_value(sig8, "00000001", 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      sig8 <= transport "00000010" after 3 ns;
      await_value(sig8, "00000010", 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sig8 <= transport "00000101" after 6 ns;
      await_value(sig8, "00000101", 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      sig8 <= transport "00001111" after 0 ns;
      await_value(sig8, "00001111", 0 ns, 1 ns, "Changed immediately, OK. Log in DECimal", C_SCOPE, DEC);

      -------------------------------------
      -- await_value : boolean
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 3);
      bool <= false;
      bool <= transport true after 2 ns;
      await_value(bool, true, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      bool <= transport false after 3 ns;
      await_value(bool, false, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      bool <= transport true after 6 ns;
      await_value(bool, true, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      bool <= transport false after 0 ns;
      await_value(bool, false, 0 ns, 1 ns, "Changed immediately, OK. ", C_SCOPE);
      bool <= true;
      wait for 0 ns;
      bool <= transport false after 1 ns;
      await_value(bool, true, 0 ns, 2 ns, "Val=exp already, No signal'event. OK. ", C_SCOPE);
      bool <= true;
      wait for 0 ns;
      await_value(bool, true, 1 ns, 2 ns, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);

      -------------------------------------
      -- await_value : std_logic
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 5);
      sl <= '0';
      sl <= transport '1' after 2 ns;
      await_value(sl, '1', 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, '0', 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      sl <= transport '1' after 6 ns;
      await_value(sl, '1', 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 0 ns;
      wait for 0 ns;
      sl <= transport '1' after 1 ns;
      await_value(sl, '0', 0 ns, 2 ns, "Changed immediately, OK. ", C_SCOPE);
      sl <= '1';
      wait for 10 ns;
      await_value(sl, '1', 1 ns, 2 ns, "Val=exp already, min_time>0ns, Fail. ", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'L' after 3 ns;
      await_value(sl, '0', MATCH_STD, 3 ns, 5 ns, "Change within time window to weak, expecting forced, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'H', MATCH_STD, 3 ns, 5 ns, "Change within time window to forced, expecting weak, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '0' after 3 ns;
      await_value(sl, 'L', MATCH_EXACT, 3 ns, 5 ns, "Change within time window to forced, expecting weak, Fail", C_SCOPE);
      wait for 10 ns;
      sl <= transport 'H' after 3 ns;
      await_value(sl, '1', MATCH_EXACT, 3 ns, 5 ns, "Change within time window to weak, expecting forced, Fail", C_SCOPE);
      wait for 10 ns;

      -- MATCH_STD_INCL_Z
      increment_expected_alerts_and_stop_limit(error, 1);
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'Z' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_Z, 3 ns, 5 ns, "Change within time window, STD match including Z, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_Z, 3 ns, 5 ns, "Different values, STD match including Z, Fail", C_SCOPE);

      -- MATCH_STD_INCL_ZXUW
      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'Z' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'Z', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Different values, STD match including ZXUW, Fail 2", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'X' after 3 ns;
      await_value(sl, 'X', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'X', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Different values, STD match including ZXUW, Fail 3", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'U' after 3 ns;
      await_value(sl, 'U', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'U', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Different values, STD match including ZXUW, Fail 4", C_SCOPE);

      increment_expected_alerts_and_stop_limit(error, 1);
      wait for 1 ns;
      sl <= '1';
      wait for 1 ns;
      sl <= transport 'W' after 3 ns;
      await_value(sl, 'W', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Change within time window, STD match including ZXUW, OK", C_SCOPE);
      wait for 10 ns;
      sl <= transport '1' after 3 ns;
      await_value(sl, 'W', MATCH_STD_INCL_ZXUW, 3 ns, 5 ns, "Different values, STD match including ZXUW, Fail 5", C_SCOPE);

      -------------------------------------
      -- await_value : integer
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 3);
      int <= 0;
      int <= transport 1 after 2 ns;
      await_value(int, 1, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      int <= transport 2 after 3 ns;
      await_value(int, 2, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      int <= transport 3 after 6 ns;
      await_value(int, 3, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      int <= transport 15 after 0 ns;
      wait for 0 ns;
      int <= transport 16 after 1 ns;
      await_value(int, 15, 0 ns, 2 ns, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      int <= 17;
      wait for 0 ns;
      await_value(int, 17, 1 ns, 2 ns, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);

      -------------------------------------
      -- await_value : real
      -------------------------------------
      increment_expected_alerts_and_stop_limit(error, 3);
      real_a <= 0.0;
      real_a <= transport 1.0 after 2 ns;
      await_value(real_a, 1.0, 3 ns, 5 ns, "Change too soon, Fail", C_SCOPE);
      real_a <= transport 2.0 after 3 ns;
      await_value(real_a, 2.0, 3 ns, 5 ns, "Change within time window, OK", C_SCOPE);
      real_a <= transport 3.0 after 6 ns;
      await_value(real_a, 3.0, 3 ns, 5 ns, "Change too late, Fail", C_SCOPE);
      wait for 10 ns;
      real_a <= transport 15.0 after 0 ns;
      wait for 0 ns;
      real_a <= transport 16.0 after 1 ns;
      await_value(real_a, 15.0, 0 ns, 2 ns, "Val=exp already, no signal'event, OK. ", C_SCOPE);
      wait for 10 ns;
      real_a <= 17.0;
      wait for 0 ns;
      await_value(real_a, 17.0, 1 ns, 2 ns, "Val=exp already, Min_time>0ns, Fail. ", C_SCOPE);
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

end architecture await_arch;
