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
-- Description : A demo test-harness for running UVVM Assertions in multiple ways, for demonstration purposes
---------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_assertions;
use uvvm_assertions.uvvm_assertions_pkg.all;

entity uvvm_assertions_demo_th is
  generic (
    GC_CLK_PERIOD : time := 10 ns
  );
  port (
    clock_ena                 : in  std_logic := '0';
    assert_value_ena          : in  std_logic := '0';
    assert_value_in_range_ena : in  std_logic := '0';
    assert_one_hot_ena        : in  std_logic := '0'
  );
end entity uvvm_assertions_demo_th;

architecture func of uvvm_assertions_demo_th is
  signal clk            : std_logic := '0';
  signal rst            : std_logic := '1';
  signal always_high    : std_logic := '1';

  -- DUT 1 - dummy_counter
  signal count          : std_logic_vector(7 downto 0);
  signal count_vld      : std_logic := '0';
  signal count_is_13    : boolean;

  -- DUT 2 - one_hot_in_range_generator
  signal one_hot        : unsigned(31 downto 0);
  signal one_hot_slv    : std_logic_vector(one_hot'range);
begin
  -- Simple clock generator (to not be reliant on library bitvis_vip_clock_generator)
  clk <= not clk after GC_CLK_PERIOD / 2 when clock_ena = '1' else clk;

  -- Simple reset
  rst <= '0' after 5*GC_CLK_PERIOD when clock_ena = '1' else '0';

  -- Instantiate DUT-1
  i_dut_1 : entity work.dummy_counter
    port map(
      clk       => clk,
      rst       => rst,
      count     => count,
      count_vld => count_vld
    );

  -- UVVM assertion: count should never be 13
  count_is_13 <= (count = std_logic_vector(to_unsigned(13, 8)));
  assert_value(clk, assert_value_ena, count_is_13, false, "count should never be 13");

  -- Instantiate DUT-2
  i_dut_2 : entity work.one_hot_in_range_generator
    generic map (
      GC_ONE_HOT_LOWER_LIMIT => 1,
      GC_ONE_HOT_UPPER_LIMIT => 17
    )
    port map (
      clk     => clk,
      rst     => rst,
      one_hot => one_hot
    );

  -- UVVM assertions for checking if a value is within a range
  assert_value_in_range(clk, assert_value_in_range_ena, one_hot, to_unsigned(1, one_hot'length), to_unsigned(17, one_hot'length), "DUT 2 signal should be in range 1 to 17");
  one_hot_slv <= std_logic_vector(one_hot); -- UVVM assert_one_hot only takes in slv, so convert unsigned to std_logic_vector
  -- UVVM assertion for checking if a signal is one-hot (ALL_ZERO_NOT_ALLOWED being default and not specified)
  assert_one_hot(clk, assert_one_hot_ena, one_hot_slv, "DUT 2 signal should always be one-hot");

end architecture func;