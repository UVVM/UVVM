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

use work.uart_pif_pkg.all;

entity uart is
  generic(
    GC_START_BIT                 : std_logic := '0';
    GC_STOP_BIT                  : std_logic := '1';
    GC_CLOCKS_PER_BIT            : integer   := 16;
    GC_MIN_EQUAL_SAMPLES_PER_BIT : integer   := 15); -- Number of equal samples needed for valid bit, uart samples on every clock
  port(
    -- DSP interface and general control signals
    clk   : in  std_logic;
    arst  : in  std_logic;
    -- CPU interface
    cs    : in  std_logic;
    addr  : in  unsigned(2 downto 0);
    wr    : in  std_logic;
    rd    : in  std_logic;
    wdata : in  std_logic_vector(7 downto 0);
    rdata : out std_logic_vector(7 downto 0) := (others => '0');
    -- UART related signals
    rx_a  : in  std_logic;
    tx    : out std_logic
  );
begin
  assert GC_MIN_EQUAL_SAMPLES_PER_BIT > GC_CLOCKS_PER_BIT / 2 and GC_MIN_EQUAL_SAMPLES_PER_BIT < GC_CLOCKS_PER_BIT
  report "GC_MIN_EQUAL_SAMPLES_PER_BIT must be between GC_CLOCKS_PER_BIT/2 and GC_CLOCKS_PER_BIT"
  severity FAILURE;
end uart;

architecture rtl of uart is

  -- PIF-core interface
  signal p2c : t_p2c;                   --
  signal c2p : t_c2p;                   --

begin

  i_uart_pif : entity work.uart_pif
    port map(
      arst  => arst,                    --
      clk   => clk,                     --
      -- CPU interface
      cs    => cs,                      --
      addr  => addr,                    --
      wr    => wr,                      --
      rd    => rd,                      --
      wdata => wdata,                   --
      rdata => rdata,                   --
      --
      p2c   => p2c,                     --
      c2p   => c2p                      --
    );

  i_uart_core : entity work.uart_core
    generic map(
      GC_START_BIT                 => GC_START_BIT,
      GC_STOP_BIT                  => GC_STOP_BIT,
      GC_CLOCKS_PER_BIT            => GC_CLOCKS_PER_BIT,
      GC_MIN_EQUAL_SAMPLES_PER_BIT => GC_MIN_EQUAL_SAMPLES_PER_BIT
    )
    port map(
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

