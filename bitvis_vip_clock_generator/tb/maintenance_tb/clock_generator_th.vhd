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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

--=================================================================================================
entity test_harness is
  generic(
    GC_CLOCK_1_PERIOD      : time := 10 ns;
    GC_CLOCK_1_HIGH_PERIOD : time := 5 ns;
    GC_CLOCK_2_PERIOD      : time := 20 ns;
    GC_CLOCK_2_HIGH_PERIOD : time := 12 ns;
    GC_CLOCK_3_PERIOD      : time := 40 ns;
    GC_CLOCK_3_HIGH_PERIOD : time := 12 ns
  );
end entity test_harness;

--=================================================================================================
--=================================================================================================

architecture struct of test_harness is

  signal clk_1 : std_logic;
  signal clk_2 : std_logic;
  signal clk_3 : std_logic;

begin

  -----------------------------
  -- vvc/executors
  -----------------------------
  i1_clock_generator_vvc : entity work.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => 1,
      GC_CLOCK_NAME      => "Clock 1",
      GC_CLOCK_PERIOD    => GC_CLOCK_1_PERIOD,
      GC_CLOCK_HIGH_TIME => GC_CLOCK_1_HIGH_PERIOD
    )
    port map(
      clk => clk_1
    );

  i2_clock_generator_vvc : entity work.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => 2,
      GC_CLOCK_NAME      => "Clock 2",
      GC_CLOCK_PERIOD    => GC_CLOCK_2_PERIOD,
      GC_CLOCK_HIGH_TIME => GC_CLOCK_2_HIGH_PERIOD
    )
    port map(
      clk => clk_2
    );

  i3_clock_generator_vvc : entity work.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => 3,
      GC_CLOCK_NAME      => "Clock 3",
      GC_CLOCK_PERIOD    => GC_CLOCK_3_PERIOD,
      GC_CLOCK_HIGH_TIME => GC_CLOCK_3_HIGH_PERIOD
    )
    port map(
      clk => clk_3
    );

end struct;

