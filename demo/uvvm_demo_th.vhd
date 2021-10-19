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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_uart;
library bitvis_vip_sbi;
library bitvis_vip_uart;
library bitvis_vip_clock_generator;


-- Test harness entity
entity uvvm_demo_th is
  generic (
    -- Clock and bit period settings
    GC_CLK_PERIOD         : time := 10 ns;
    GC_BIT_PERIOD         : time := 16 * GC_CLK_PERIOD;
    -- DUT addresses
    GC_ADDR_RX_DATA       : unsigned(2 downto 0) := "000";
    GC_ADDR_RX_DATA_VALID : unsigned(2 downto 0) := "001";
    GC_ADDR_TX_DATA       : unsigned(2 downto 0) := "010";
    GC_ADDR_TX_READY      : unsigned(2 downto 0) := "011"
  );
end entity;

-- Test harness architecture
architecture struct of uvvm_demo_th is

  -- VVC idx
  constant C_SBI_VVC        : natural := 1;
  constant C_UART_VVC       : natural := 1;
  constant C_CLOCK_GEN_VVC  : natural := 1;

  -- UART if
  constant C_DATA_WIDTH     : natural := 8;
  constant C_ADDR_WIDTH     : natural := 3;

  -- Clock and reset signals
  signal clk            : std_logic  := '0';
  signal arst           : std_logic  := '0';

  -- SBI VVC signals
  signal cs             : std_logic;
  signal addr           : unsigned(2 downto 0);
  signal wr             : std_logic;
  signal rd             : std_logic;
  signal wdata          : std_logic_vector(7 downto 0);
  signal rdata          : std_logic_vector(7 downto 0);
  signal ready          : std_logic;

  -- UART VVC signals
  signal uart_vvc_rx    : std_logic := '1';
  signal uart_vvc_tx    : std_logic := '1';

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart: entity bitvis_uart.uart
    port map (
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
  i_sbi_vvc: entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => C_ADDR_WIDTH,
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => C_SBI_VVC
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
  i_uart_vvc: entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_DATA_WIDTH   => C_DATA_WIDTH,
      GC_INSTANCE_IDX => C_UART_VVC
    )
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => uart_vvc_tx
    );

  -- Static '1' ready signal for the SBI VVC
  ready <= '1';


  -----------------------------------------------------------------------------
  -- Clock Generator VVC
  -----------------------------------------------------------------------------
  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN_VVC,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => GC_CLK_PERIOD,
      GC_CLOCK_HIGH_TIME => GC_CLK_PERIOD / 2
    )
    port map(
      clk => clk
    );


  -----------------------------------------------------------------------------
  -- Reset
  -----------------------------------------------------------------------------
  -- Toggle the reset after 5 clock periods
  p_arst: arst <= '1', '0' after 5 *GC_CLK_PERIOD;


end architecture struct;
