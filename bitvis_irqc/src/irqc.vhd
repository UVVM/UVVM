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
-- VHDL unit     : Bitvis IRQC Library : irqc
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.irqc_pif_pkg.all;

entity irqc is
  port(
    -- DSP interface and general control signals
    clk                   : in  std_logic;
    arst                  : in  std_logic;
    -- CPU interface
    cs  : in  std_logic;
    addr: in  unsigned(2 downto 0);
    wr  : in  std_logic;
    rd  : in  std_logic;
    din : in  std_logic_vector(7 downto 0);
    dout: out std_logic_vector(7 downto 0) := (others => '0');
    -- Interrupt related signals
    irq_source            : in  std_logic_vector(C_NUM_SOURCES-1 downto 0);
    irq2cpu               : out std_logic;
    irq2cpu_ack           : in  std_logic
  );
end irqc;

architecture rtl of irqc is

  -- PIF-core interface
  signal p2c      :  t_p2c;                 --
  signal c2p      :  t_c2p;                 --


begin

  i_irqc_pif: entity work.irqc_pif
    port map (
        arst           => arst,           --
        clk            => clk,            --
    -- CPU interface
        cs             => cs,             --
        addr           => addr,           --
        wr             => wr,             --
        rd             => rd,             --
        din            => din,            --
        dout           => dout,           --
    --
        p2c            => p2c,            --
        c2p            => c2p             --
        );



  i_irqc_core: entity work.irqc_core
    port map (
        clk            => clk,            --
        arst           => arst,           --
    -- PIF-core interface
        p2c            => p2c,            --
        c2p            => c2p,            --
    -- Interrupt related signals
        irq_source     => irq_source,     --
        irq2cpu        => irq2cpu,        --
        irq2cpu_ack    => irq2cpu_ack    --
        );




end rtl;
