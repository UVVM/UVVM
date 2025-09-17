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

---------------------------------------------------------------------------------------------
-- Description : A demo testbench for running UVVM Assertions in multiple ways, for demonstration purposes.
--               As the recommended usage is to place the assertions in the test-harness, this testbench serves as
--               simple control for some of the assertions (using the ena signals).
---------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_assertions;
use uvvm_assertions.uvvm_assertions_pkg.all;

--hdlregression:tb
entity uvvm_assertions_demo_tb is
end entity uvvm_assertions_demo_tb;

architecture func of uvvm_assertions_demo_tb is
  constant C_CLK_PERIOD            : time      := 10 ns;  -- Clock period for the testbench
  -- For demonstration purposes, we will turn these on and off in the sequencer. they can be kept on if wanted (or handled by rst if desired)
  signal assert_value_ena          : std_logic := '0';
  signal assert_value_in_range_ena : std_logic := '0';
  signal assert_one_hot_ena        : std_logic := '0';
begin

  -- demo test-harness containing all assertions and some DUTs
  i_test_harness : entity work.uvvm_assertions_demo_th
    generic map (
      GC_CLK_PERIOD => C_CLK_PERIOD  -- Clock period for the test harness
    )
    port map (
      clock_ena                 => '1',  -- Enable clock for the test harness
      assert_value_ena          => assert_value_ena,
      assert_value_in_range_ena => assert_value_in_range_ena,
      assert_one_hot_ena        => assert_one_hot_ena
    );

  -- Main test process
  p_main : process
  begin
    log(ID_LOG_HDR, "STARTING SIMULATION", C_SCOPE);
    assert_value_ena <= '0';
    wait for 200*C_CLK_PERIOD;

    -- wait for the time it will take for the (7 downto 0) counter to loop once: -- 256 clock cycles
    -- therefore ensuring we will reach 13 (once) and cause an error
    log(ID_LOG_HDR, "TESTING ASSERTION assert_value (expecting error)", C_SCOPE);
    increment_expected_alerts_and_stop_limit(ERROR, 1);
    assert_value_ena <= '1', '0' after 256*C_CLK_PERIOD;  -- Enable assertion checking for 256 clock cycles
    wait for 1000*C_CLK_PERIOD;

    log(ID_LOG_HDR, "TESTING ASSERTION assert_one_hot & assert_value_in_range (expecting no error)", C_SCOPE);
    assert_one_hot_ena        <= '1', '0' after 256*C_CLK_PERIOD;  -- Enable assertion checking for 256 clock cycles (which is far more than needed)
    assert_value_in_range_ena <= '1', '0' after 256*C_CLK_PERIOD;
    wait for 1000*C_CLK_PERIOD;

    log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
    report_alert_counters(FINAL);
    std.env.stop;
    wait;
  end process;
end architecture func;