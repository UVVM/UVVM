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

use work.uart_pif_pkg.all;

entity uart is
  generic (
    GC_START_BIT                 : std_logic := '0';
    GC_STOP_BIT                  : std_logic := '1';
    GC_CLOCKS_PER_BIT            : integer   := 16;
    GC_MIN_EQUAL_SAMPLES_PER_BIT : integer   := 15); -- Number of equal samples needed for valid bit, uart samples on every clock
  port(
    -- DSP interface and general control signals
    clk  : in  std_logic;
    arst : in  std_logic;
    -- CPU interface
    cs   : in  std_logic;
    addr : in  unsigned(2 downto 0);
    wr   : in  std_logic;
    rd   : in  std_logic;
    wdata : in  std_logic_vector(7 downto 0);
    rdata : out std_logic_vector(7 downto 0) := (others => '0');
    -- UART related signals
    rx_a : in  std_logic;
    tx   : out std_logic
    );
begin
  assert GC_MIN_EQUAL_SAMPLES_PER_BIT > GC_CLOCKS_PER_BIT/2 and GC_MIN_EQUAL_SAMPLES_PER_BIT < GC_CLOCKS_PER_BIT
  report "GC_MIN_EQUAL_SAMPLES_PER_BIT must be between GC_CLOCKS_PER_BIT/2 and GC_CLOCKS_PER_BIT"
  severity FAILURE;
end uart;



architecture rtl of uart is

  -- PIF-core interface
  signal p2c : t_p2c;                   --
  signal c2p : t_c2p;                   --


begin

  i_uart_pif : entity work.uart_pif
    port map (
      arst => arst,                     --
      clk  => clk,                      --
      -- CPU interface
      cs   => cs,                       --
      addr => addr,                     --
      wr   => wr,                       --
      rd   => rd,                       --
      wdata  => wdata,                      --
      rdata => rdata,                     --
      --
      p2c  => p2c,                      --
      c2p  => c2p                       --
      );



  i_uart_core : entity work.uart_core
    generic map(
    GC_START_BIT                 => GC_START_BIT,
    GC_STOP_BIT                  => GC_STOP_BIT,
    GC_CLOCKS_PER_BIT            => GC_CLOCKS_PER_BIT,
    GC_MIN_EQUAL_SAMPLES_PER_BIT => GC_MIN_EQUAL_SAMPLES_PER_BIT
    )
    port map (
      clk  => clk,                      --
      arst => arst,                     --
      -- PIF-core interface
      p2c  => p2c,                      --
      c2p  => c2p,                      --
      -- Interrupt related signals
      rx_a => rx_a,                     --
      tx   => tx
      );




end rtl;

