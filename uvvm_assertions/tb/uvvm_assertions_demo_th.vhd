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
    assert_one_hot_ena        : in  std_logic := '0';
    assert_window_1_ena       : in  std_logic := '0';
    assert_window_2_ena       : in  std_logic := '0'
  );
end entity uvvm_assertions_demo_th;

architecture func of uvvm_assertions_demo_th is
  signal clk            : std_logic := '0';
  signal rst            : std_logic := '1';

  -- DUT 1 - dummy_counter
  signal count          : std_logic_vector(7 downto 0);
  signal count_vld      : std_logic := '0';
  signal count_is_13    : boolean;

  -- DUT 2 - one_hot_in_range_generator
  signal one_hot        : unsigned(31 downto 0);
  signal one_hot_slv    : std_logic_vector(one_hot'range);

  -- DUT 3 - dummy_data_bus
  signal data_out_dut3       : std_logic_vector(7 downto 0);
  signal data_vld_dut3       : std_logic := '0';
  signal packet_start_dut3   : std_logic := '0';
  signal packet_end_dut3     : std_logic := '0';
  signal bus_end_dut3        : std_logic := '0';

  signal assert_data_bus_one_hot_ena : std_logic := '1';

  -- DUT 4 - dummy_data_bus
  signal data_out_dut4       : std_logic_vector(7 downto 0);
  signal data_vld_dut4       : std_logic := '0';
  signal packet_start_dut4   : std_logic := '0';
  signal packet_end_dut4     : std_logic := '0';
  signal bus_end_dut4        : std_logic := '0';


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

  i_dut_3 : entity work.dummy_data_bus
  generic map (
      GC_DATA_WIDTH    => 8,
      GC_PACKET_LENGTH => 10,
      GC_NUM_PACKETS   => 100
  )
  port map (
      clk                  => clk,
      rst                  => rst,
      packet_read_ena      => '1', -- this will cause the DUT to start a new packet when previous packet is done (with 3 clk cycles delay)
      data_out             => data_out_dut3,
      data_vld             => data_vld_dut3,
      packet_start         => packet_start_dut3,
      packet_end           => packet_end_dut3,
      bus_end              => bus_end_dut3
  );

  -- UVVM assertion for checking if a signal is one-hot
  assert_data_bus_one_hot_ena <= assert_window_1_ena and data_vld_dut3;
  -- This assertion pos ack is set using "ID_POS_ACK" so it will not display (among the IDs which is disabled) unless it fails
  assert_one_hot(clk, assert_data_bus_one_hot_ena, data_out_dut3, "DUT 3 signal should always be one-hot", ERROR, msg_id => ID_POS_ACK);

  -- UVVM assertion that will check the `bus_end_dut3` signal comes high within a certain number of clock cycles after `packet_start_dut3` goes high
  assert_change_to_value_from_min_to_max_cycles_after_trigger(
    clk             => clk,
    ena             => assert_window_1_ena,
    tracked_value   => bus_end_dut3,
    trigger         => packet_start_dut3,
    min_cycles      => 1,     -- Must have 1 cycle min (because a CHANGE must require a non '1' as previous value)
    max_cycles      => 10*100 + 2, -- (GC_PACKET_LENGTH*GC_NUM_PACKETS + 2) to allow for some margin in the DUT
    exp_value       => '1',
    msg             => "'bus_end_dut3' did not go high within expected number of cycles after 'packet_start_dut3'",
    alert_level     => ERROR
  );


  i_dut_4 : entity work.dummy_data_bus
  generic map (
      GC_DATA_WIDTH    => 8,
      GC_PACKET_LENGTH => 500, -- using one giant packet to test using two triggers
      GC_NUM_PACKETS   => 1
  )
  port map (
      clk                  => clk,
      rst                  => rst,
      packet_read_ena      => '1', -- this will cause the DUT to start a new packet when previous packet is done (with 3 clk cycles delay)
      data_out             => data_out_dut4,
      data_vld             => data_vld_dut4,
      packet_start         => packet_start_dut4,
      packet_end           => packet_end_dut4,
      bus_end              => bus_end_dut4
  );

  assert_change_to_value_from_start_to_end_trigger(
      clk               => clk,
      ena               => assert_window_2_ena,
      tracked_value     => packet_end_dut4,
      start_trigger     => packet_start_dut4,
      end_trigger       => bus_end_dut4,
      exp_value         => '1',
      msg               => "packet_end_dut4 did not go high within 'packet_start_dut4' to 'bus_end_dut4' window",
      alert_level       => TB_ERROR,
      pos_ack_kind      => FIRST
  );


end architecture func;