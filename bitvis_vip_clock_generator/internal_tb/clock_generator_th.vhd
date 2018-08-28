--========================================================================================================================
-- Copyright (c) 2017 by Bitvis AS.  All rights reserved.
-- You should have received a copy of the license file containing the MIT License (see LICENSE.TXT), if not,
-- contact Bitvis AS <support@bitvis.no>.
--
-- UVVM AND ANY PART THEREOF ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH UVVM OR THE USE OR OTHER DEALINGS IN UVVM.
--========================================================================================================================

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
      GC_CLOCK_PERIOD    => 10 ns,
      GC_CLOCK_HIGH_TIME => 5 ns
      )
    port map(
      clk => clk_1
      );

  i2_clock_generator_vvc : entity work.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => 2,
      GC_CLOCK_NAME      => "Clock 2",
      GC_CLOCK_PERIOD    => 20 ns,
      GC_CLOCK_HIGH_TIME => 12 ns
      )
    port map(
      clk => clk_2
      );

  i3_clock_generator_vvc : entity work.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => 3,
      GC_CLOCK_NAME      => "Clock 3",
      GC_CLOCK_PERIOD    => 40 ns,
      GC_CLOCK_HIGH_TIME => 12 ns
      )
    port map(
      clk => clk_3
      );

end struct;


