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

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_uart;
library bitvis_vip_uart;
library bitvis_vip_sbi;
library bitvis_vip_avalon_mm;
use bitvis_vip_avalon_mm.avalon_mm_bfm_pkg.all;

-- Test harness entity
entity vvc_th is
  port(
    clk          : in  std_logic;
    arst         : in  std_logic;
    -- CPU interface to UART 0
    uart_0_cs    : in  std_logic;
    uart_0_addr  : in  unsigned(2 downto 0);
    uart_0_wr    : in  std_logic;
    uart_0_rd    : in  std_logic;
    uart_0_wdata : in  std_logic_vector(7 downto 0);
    uart_0_rdata : out std_logic_vector(7 downto 0) := (others => '0');
    -- UART 0 RX/TX
    uart_0_rx_a  : in  std_logic;
    uart_0_tx    : out std_logic;
    -- UART 1 RX/TX
    uart_1_rx_a  : in  std_logic;
    uart_1_tx    : out std_logic;
    -- CPU interface to UART 2
    uart_2_cs    : in  std_logic;
    uart_2_addr  : in  unsigned(2 downto 0);
    uart_2_wr    : in  std_logic;
    uart_2_rd    : in  std_logic;
    uart_2_wdata : in  std_logic_vector(7 downto 0);
    uart_2_rdata : out std_logic_vector(7 downto 0) := (others => '0')
  );
end entity;

-- Test harness architecture
architecture struct of vvc_th is

  -- UART 1 signals
  signal uart_1_cs    : std_logic;
  signal uart_1_addr  : unsigned(2 downto 0);
  signal uart_1_wr    : std_logic;
  signal uart_1_rd    : std_logic;
  signal uart_1_wdata : std_logic_vector(7 downto 0);
  signal uart_1_rdata : std_logic_vector(7 downto 0);

  -- UART 2 signals
  signal uart_2_rx_a : std_logic;
  signal uart_2_tx   : std_logic;

  -- UART 3 signals
  signal uart_3_cs    : std_logic;
  signal uart_3_addr  : unsigned(2 downto 0);
  signal uart_3_wr    : std_logic;
  signal uart_3_rd    : std_logic;
  signal uart_3_wdata : std_logic_vector(7 downto 0);
  signal uart_3_rdata : std_logic_vector(7 downto 0);
  signal uart_3_rx_a  : std_logic;
  signal uart_3_tx    : std_logic;

  -- UART 4 signals
  signal uart_4_cs    : std_logic;
  signal uart_4_addr  : unsigned(2 downto 0);
  signal uart_4_wr    : std_logic;
  signal uart_4_rd    : std_logic;
  signal uart_4_wdata : std_logic_vector(7 downto 0);
  signal uart_4_rdata : std_logic_vector(7 downto 0);
  signal uart_4_rx_a  : std_logic;
  signal uart_4_tx    : std_logic;

  -- UART 5 signals
  signal uart_5_cs    : std_logic;
  signal uart_5_addr  : unsigned(2 downto 0);
  signal uart_5_wr    : std_logic;
  signal uart_5_rd    : std_logic;
  signal uart_5_wdata : std_logic_vector(7 downto 0);
  signal uart_5_rdata : std_logic_vector(7 downto 0);
  signal uart_5_rx_a  : std_logic;
  signal uart_5_tx    : std_logic;

  signal ready : std_logic;

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

  -- Avalon-MM signals
  signal avalon_mm_if : t_avalon_mm_if(address(31 downto 0), byte_enable(3 downto 0), writedata(31 downto 0), readdata(31 downto 0));

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUTs
  -----------------------------------------------------------------------------
  i_uart_0 : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => uart_0_cs,
      addr  => uart_0_addr,
      wr    => uart_0_wr,
      rd    => uart_0_rd,
      wdata => uart_0_wdata,
      rdata => uart_0_rdata,
      -- UART signals
      rx_a  => uart_0_rx_a,
      tx    => uart_0_tx
    );
  i_uart_1 : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => uart_1_cs,
      addr  => uart_1_addr,
      wr    => uart_1_wr,
      rd    => uart_1_rd,
      wdata => uart_1_wdata,
      rdata => uart_1_rdata,
      -- UART signals
      rx_a  => uart_1_rx_a,
      tx    => uart_1_tx
    );
  i_uart_2 : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => uart_2_cs,
      addr  => uart_2_addr,
      wr    => uart_2_wr,
      rd    => uart_2_rd,
      wdata => uart_2_wdata,
      rdata => uart_2_rdata,
      -- UART signals
      rx_a  => uart_2_rx_a,
      tx    => uart_2_tx
    );
  i_uart_3 : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => uart_3_cs,
      addr  => uart_3_addr,
      wr    => uart_3_wr,
      rd    => uart_3_rd,
      wdata => uart_3_wdata,
      rdata => uart_3_rdata,
      -- UART signals
      rx_a  => uart_3_rx_a,
      tx    => uart_3_tx
    );
  i_uart_4 : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => uart_4_cs,
      addr  => uart_4_addr,
      wr    => uart_4_wr,
      rd    => uart_4_rd,
      wdata => uart_4_wdata,
      rdata => uart_4_rdata,
      -- UART signals
      rx_a  => uart_4_rx_a,
      tx    => uart_4_tx
    );
  i_uart_5 : entity bitvis_uart.uart
    port map(
      -- DSP interface and general control signals
      clk   => clk,
      arst  => arst,
      -- CPU interface
      cs    => uart_5_cs,
      addr  => uart_5_addr,
      wr    => uart_5_wr,
      rd    => uart_5_rd,
      wdata => uart_5_wdata,
      rdata => uart_5_rdata,
      -- UART signals
      rx_a  => uart_5_rx_a,
      tx    => uart_5_tx
    );

  -----------------------------------------------------------------------------
  -- SBI VVC
  -----------------------------------------------------------------------------
  i_sbi_vvc_1 : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3,
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => 1
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => uart_1_cs,
      sbi_vvc_master_if.rena  => uart_1_rd,
      sbi_vvc_master_if.wena  => uart_1_wr,
      sbi_vvc_master_if.addr  => uart_1_addr,
      sbi_vvc_master_if.wdata => uart_1_wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => uart_1_rdata
    );

  i_sbi_vvc_2 : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3,
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => 2
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => uart_3_cs,
      sbi_vvc_master_if.rena  => uart_3_rd,
      sbi_vvc_master_if.wena  => uart_3_wr,
      sbi_vvc_master_if.addr  => uart_3_addr,
      sbi_vvc_master_if.wdata => uart_3_wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => uart_3_rdata
    );

  i_sbi_vvc_3 : entity bitvis_vip_sbi.sbi_vvc
    generic map(
      GC_ADDR_WIDTH   => 3,
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => 3
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => uart_4_cs,
      sbi_vvc_master_if.rena  => uart_4_rd,
      sbi_vvc_master_if.wena  => uart_4_wr,
      sbi_vvc_master_if.addr  => uart_4_addr,
      sbi_vvc_master_if.wdata => uart_4_wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => uart_4_rdata
    );

  -- IMPORTANT: This VVC is only meant to be used for testing await_completion &
  -- await_any_completion old mechanism compatibility with the new mechanism.
  i_sbi_vvc_4 : entity bitvis_vip_sbi.sbi_vvc_old
    generic map(
      GC_ADDR_WIDTH   => 3,
      GC_DATA_WIDTH   => 8,
      GC_INSTANCE_IDX => 4
    )
    port map(
      clk                     => clk,
      sbi_vvc_master_if.cs    => uart_5_cs,
      sbi_vvc_master_if.rena  => uart_5_rd,
      sbi_vvc_master_if.wena  => uart_5_wr,
      sbi_vvc_master_if.addr  => uart_5_addr,
      sbi_vvc_master_if.wdata => uart_5_wdata,
      sbi_vvc_master_if.ready => ready,
      sbi_vvc_master_if.rdata => uart_5_rdata
    );

  -- Static '1' ready signal for the SBI VVC
  ready <= '1';

  -----------------------------------------------------------------------------
  -- UART VVC
  -----------------------------------------------------------------------------  
  i_uart_vvc_1 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 1
    )
    port map(
      uart_vvc_tx => uart_2_rx_a,
      uart_vvc_rx => uart_2_tx
    );

  i_uart_vvc_2 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 2
    )
    port map(
      uart_vvc_tx => uart_3_rx_a,
      uart_vvc_rx => uart_3_tx
    );

  i_uart_vvc_3 : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => 3
    )
    port map(
      uart_vvc_tx => uart_4_rx_a,
      uart_vvc_rx => uart_4_tx
    );

  -- IMPORTANT: This VVC is only meant to be used for testing await_completion &
  -- await_any_completion old mechanism compatibility with the new mechanism.
  i_uart_vvc_4 : entity bitvis_vip_uart.uart_vvc_old
    generic map(
      GC_INSTANCE_IDX => 4
    )
    port map(
      uart_vvc_tx => uart_5_rx_a,
      uart_vvc_rx => uart_5_tx
    );

  -----------------------------------------------------------------------------
  -- Avalon-MM VVC
  -----------------------------------------------------------------------------
  i_avalon_mm_vvc_1 : entity bitvis_vip_avalon_mm.avalon_mm_vvc
    generic map(
      GC_ADDR_WIDTH   => 32,
      GC_DATA_WIDTH   => 32,
      GC_INSTANCE_IDX => 1
    )
    port map(
      clk                     => clk,
      avalon_mm_vvc_master_if => avalon_mm_if
    );

  -- Static data from the "DUT"
  avalon_mm_if.readdata      <= (others => '1');
  avalon_mm_if.response      <= (others => '0');
  avalon_mm_if.waitrequest   <= '0';
  avalon_mm_if.irq           <= '0';
  -- Simulate a delay in the read response
  avalon_mm_if.readdatavalid <= transport avalon_mm_if.read after C_CLK_PERIOD * 5;

end struct;
