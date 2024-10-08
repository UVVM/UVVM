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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library vip_test_1;
context vip_test_1.vvc_context;

library vip_test_2;
context vip_test_2.vvc_context;

library vip_test_3;
context vip_test_3.vvc_context;

library vip_test_4;
context vip_test_4.vvc_context;

library vip_test_5;
context vip_test_5.vvc_context;

library vip_test_6;
context vip_test_6.vvc_context;

library vip_test_7;
context vip_test_7.vvc_context;

library vip_test_8;
context vip_test_8.vvc_context;

library vip_test_9;
context vip_test_9.vvc_context;

library vip_test_10;
context vip_test_10.vvc_context;

library vip_test_11;
context vip_test_11.vvc_context;

library vip_test_12;
context vip_test_12.vvc_context;

library vip_test_13;
context vip_test_13.vvc_context;

library vip_test_14;
context vip_test_14.vvc_context;

--HDLRegression:TB
entity vvc_generator_tb is
end entity;

architecture func of vvc_generator_tb is

  signal clk : std_logic := '0';

begin

  p_clock : clock_generator(clk, 250 ns);

  ----------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  ----------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  --------------------------------------------------------------------------------
  -- VVCs
  --------------------------------------------------------------------------------
  i_test_1_vvc : entity vip_test_1.test_1_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_2_vvc : entity vip_test_2.test_2_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_3_vvc : entity vip_test_3.test_3_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_4_vvc : entity vip_test_4.test_4_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_5_vvc : entity vip_test_5.test_5_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_6_vvc : entity vip_test_6.test_6_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_7_vvc : entity vip_test_7.test_7_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_8_vvc : entity vip_test_8.test_8_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_9_vvc : entity vip_test_9.test_9_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_10_vvc : entity vip_test_10.test_10_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_11_vvc : entity vip_test_11.test_11_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_12_vvc : entity vip_test_12.test_12_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_13_vvc : entity vip_test_13.test_13_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  i_test_14_vvc : entity vip_test_14.test_14_vvc
    generic map(
      GC_INSTANCE_IDX => 0
    )
    port map(
      clk => clk
    );

  --------------------------------------------------------------------------------
  -- PROCESS: p_main
  --------------------------------------------------------------------------------
  p_main : process
  begin

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -------------------------------------------------------------------------------------------
    log(ID_LOG_HDR_LARGE, "Test generated VVCs don't have runtime errors");
    -------------------------------------------------------------------------------------------
    wait for 1 us;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    wait for 1000 ns;             -- Allow some time for completion
    report_alert_counters(FINAL); -- Report final counters and print conclusion (Success/Fail)
    log(ID_LOG_HDR, "SIMULATION COMPLETED");
    -- Finish the simulation
    std.env.stop;
    wait;  -- to stop completely

  end process p_main;

end architecture func;