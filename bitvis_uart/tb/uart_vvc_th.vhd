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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_sbi;
library bitvis_vip_uart;
library bitvis_uart;


-- Test harness entity
entity uart_vvc_th is
end entity;

-- Test harness architecture
architecture struct of uart_vvc_th is

  -- DSP interface and general control signals
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

  constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart: entity work.uart
    port map (
      -- DSP interface and general control signals
      clk             => clk,
      arst            => arst,
      -- CPU interface
      cs              => cs,
      addr            => addr,
      wr              => wr,
      rd              => rd,
      wdata           => wdata,
      rdata           => rdata,
      -- UART signals
      rx_a            => uart_vvc_tx,
      tx              => uart_vvc_rx
  );


  -----------------------------------------------------------------------------
  -- SBI VVC
  -----------------------------------------------------------------------------
  i1_sbi_vvc: entity bitvis_vip_sbi.sbi_vvc
  generic map(
    GC_ADDR_WIDTH     => 3,
    GC_DATA_WIDTH     => 8,
    GC_INSTANCE_IDX   => 1
  )
  port map(
    clk                         => clk,
    sbi_vvc_master_if.cs        => cs,
    sbi_vvc_master_if.rena      => rd,
    sbi_vvc_master_if.wena      => wr,
    sbi_vvc_master_if.addr      => addr,
    sbi_vvc_master_if.wdata     => wdata,
    sbi_vvc_master_if.ready     => ready,
    sbi_vvc_master_if.rdata     => rdata
  );

 
  -----------------------------------------------------------------------------
  -- UART VVC
  -----------------------------------------------------------------------------  
  i1_uart_vvc: entity bitvis_vip_uart.uart_vvc
  generic map(
    GC_DATA_WIDTH     => 8,
    GC_INSTANCE_IDX   => 1
  )
  port map(
    uart_vvc_rx         => uart_vvc_rx,
    uart_vvc_tx         => uart_vvc_tx
  );
 
 
  -- Static '1' ready signal for the SBI VVC
  ready <= '1';
 
  -- Toggle the reset after 5 clock periods
  p_arst: arst <= '1', '0' after 5 *C_CLK_PERIOD;

  -----------------------------------------------------------------------------
  -- Clock process
  -----------------------------------------------------------------------------  
  p_clk: process
  begin
    clk <= '0', '1' after C_CLK_PERIOD / 2;
    wait for C_CLK_PERIOD;
  end process;

end struct;
