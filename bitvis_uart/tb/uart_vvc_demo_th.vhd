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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
library bitvis_vip_uart;
library bitvis_uart;
library bitvis_vip_clock_generator;

-- Test harness entity
entity uart_vvc_demo_th is
end entity uart_vvc_demo_th;

-- Test harness architecture
architecture struct of uart_vvc_demo_th is

  -- DSP interface and general control signals
  signal clk  : std_logic := '0';
  signal arst : std_logic := '0';

  -- SBI VVC signals
  signal cs    : std_logic;
  signal addr  : unsigned(2 downto 0);
  signal wr    : std_logic;
  signal rd    : std_logic;
  signal wdata : std_logic_vector(7 downto 0);
  signal rdata : std_logic_vector(7 downto 0);
  signal ready : std_logic;

  -- UART VVC signals
  signal uart_vvc_rx : std_logic := '1';
  signal uart_vvc_tx : std_logic := '1';

  constant C_CLK_PERIOD : time    := 10 ns; -- 100 MHz
  constant C_CLOCK_GEN  : natural := 1;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart : entity work.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => cs,
      addr  => addr,
      wr    => wr,
      rd    => rd,
      wdata => wdata,
      rdata => rdata,
      -- UART signals
      rx_a  => uart_vvc_tx,
      tx    => uart_vvc_rx
    );

  -----------------------------------------------------------------------------
  -- SBI VVC
  -----------------------------------------------------------------------------
  i1_sbi_vvc : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3,
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => 1
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => cs,
      sbi_vvc_master_if.rena  => rd,
      sbi_vvc_master_if.wena  => wr,
      sbi_vvc_master_if.addr  => addr,
      sbi_vvc_master_if.wdata => wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => rdata
    );

  -----------------------------------------------------------------------------
  -- UART VVC
  -----------------------------------------------------------------------------
  i1_uart_vvc : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => uart_vvc_tx
    );

  -- Static '1' ready signal for the SBI VVC
  ready <= '1';

  -- Toggle the reset after 5 clock periods
  p_arst : arst <= '1', '0' after 5 * C_CLK_PERIOD;

  -----------------------------------------------------------------------------
  -- Clock Generator VVC
  -----------------------------------------------------------------------------
  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => C_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
    )
    port map(
      clk => clk
    );

end struct;
