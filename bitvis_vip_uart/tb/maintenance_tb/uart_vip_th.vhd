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

library bitvis_vip_sbi;
use bitvis_vip_sbi.sbi_bfm_pkg.all;

library bitvis_vip_uart;

library bitvis_uart;

-- Test case entity
entity test_harness is
end entity;

-- Test case architecture
architecture struct of test_harness is

  -- DSP interface and general control signals
  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  signal cs    : std_logic;
  signal addr  : unsigned(2 downto 0);
  signal wr    : std_logic;
  signal rd    : std_logic;
  signal wdata : std_logic_vector(7 downto 0);
  signal rdata : std_logic_vector(7 downto 0);
  signal ready : std_logic;

  signal uart_vvc_rx : std_logic;
  signal uart_vvc_tx : std_logic;

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz
  constant C_CLK_JITTER : time := 0.2 ns;

  constant C_SBI_BFM_CONFIG : t_sbi_bfm_config := (
    max_wait_cycles            => 10000000,
    max_wait_cycles_severity   => failure,
    use_fixed_wait_cycles_read => false,
    fixed_wait_cycles_read     => 0,
    clock_period               => C_CLK_PERIOD,
    clock_period_margin        => C_CLK_JITTER,
    clock_margin_severity      => TB_ERROR,
    setup_time                 => C_CLK_PERIOD / 4,
    hold_time                  => C_CLK_PERIOD / 4,
    bfm_sync                   => SYNC_ON_CLOCK_ONLY,
    match_strictness           => MATCH_EXACT,
    id_for_bfm                 => ID_BFM,
    id_for_bfm_wait            => ID_BFM_WAIT,
    id_for_bfm_poll            => ID_BFM_POLL,
    use_ready_signal           => true
  );

begin
  ready <= '1';

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart : entity bitvis_uart.uart
    generic map(
      GC_MIN_EQUAL_SAMPLES_PER_BIT => 9
    )
    port map(
      -- DSP interface and general control signals
      clk   => clk,                     --
      arst  => arst,                    --
      -- CPU interface
      cs    => cs,                      --
      addr  => addr,                    --
      wr    => wr,                      --
      rd    => rd,                      --
      wdata => wdata,                   --
      rdata => rdata,                   --
      -- Interrupt related signals
      rx_a  => uart_vvc_tx,
      tx    => uart_vvc_rx
    );

  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3,             -- integer := 8;
      GC_DATA_WIDTH   => 8,             -- integer := 32;
      GC_INSTANCE_IDX => 1,
      GC_SBI_CONFIG   => C_SBI_BFM_CONFIG
    )
    port map(
      clk                     => clk,   -- in  std_logic;
      sbi_vvc_master_if.cs    => cs,    -- out  std_logic;
      sbi_vvc_master_if.addr  => addr,  -- out  unsigned(GC_ADDR_WIDTH-1 downto 0);
      sbi_vvc_master_if.rena  => rd,    -- out  std_logic;
      sbi_vvc_master_if.wena  => wr,    -- out  std_logic;
      sbi_vvc_master_if.wdata => wdata, -- out  std_logic_vector(GC_DATA_WIDTH-1 downto 0);
      sbi_vvc_master_if.ready => ready, -- in  std_logic; constant '1'
      sbi_vvc_master_if.rdata => rdata  -- in std_logic_vector(GC_DATA_WIDTH-1 downto 0)
    );

  i1_uart_vvc : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => uart_vvc_tx
    );

  p_arst : arst <= '1', '0' after 5 * C_CLK_PERIOD;

  p_clk : process
  begin
    clk <= '0', '1' after C_CLK_PERIOD / 2;
    wait for C_CLK_PERIOD - C_CLK_JITTER; -- provoke jitter on the clock, half a clock period faster per 12 clock periods: - ((bit period/2) / (bit period*12/clk period)) / 2
  end process;

end struct;
