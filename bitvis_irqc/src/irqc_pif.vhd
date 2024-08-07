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
-- VHDL unit     : Bitvis IRQC Library : irqc_pif
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.irqc_pif_pkg.all;

entity irqc_pif is
  port(
    arst : in  std_logic;
    clk  : in  std_logic;
    -- CPU interface
    cs   : in  std_logic;
    addr : in  unsigned;
    wr   : in  std_logic;
    rd   : in  std_logic;
    din  : in  std_logic_vector(7 downto 0);
    dout : out std_logic_vector(7 downto 0) := (others => '0');
    --
    p2c  : out t_p2c;
    c2p  : in  t_c2p
  );
end irqc_pif;

architecture rtl of irqc_pif is
  signal p2c_i  : t_p2c;                -- internal version of output
  signal dout_i : std_logic_vector(7 downto 0) := (others => '0');

begin

  -- Assigning internally used signals to outputs
  p2c <= p2c_i;

  p_read_reg : process(cs, addr, rd, c2p, p2c_i)
  begin
    -- default values
    dout_i <= (others => '0');

    if cs = '1' and rd = '1' then
      case to_integer(addr) is
        when C_ADDR_IRR =>
          dout_i(C_NUM_SOURCES - 1 downto 0) <= c2p.aro_irr;
        when C_ADDR_IER =>
          dout_i(C_NUM_SOURCES - 1 downto 0) <= p2c_i.rw_ier;
        when C_ADDR_IPR =>
          dout_i(C_NUM_SOURCES - 1 downto 0) <= c2p.aro_ipr;
        when C_ADDR_IRQ2CPU_ALLOWED =>
          dout_i(0) <= c2p.aro_irq2cpu_allowed;
        when others =>
          null;
      end case;
    end if;
  end process p_read_reg;

  dout <= dout_i;

  -- Writing to registers that are not functionally manipulated
  p_write_reg : process(clk, arst)
  begin
    if arst = '1' then
      p2c_i.rw_ier <= (others => '0');

    elsif rising_edge(clk) then
      if cs = '1' and wr = '1' then
        case to_integer(addr) is
          when C_ADDR_IER =>
            p2c_i.rw_ier <= din(C_NUM_SOURCES - 1 downto 0);
          -- Auxiliary write (below)
          when others =>
            null;
        end case;
      end if;
    end if;
  end process p_write_reg;

  -- Writing to registers that are functionally manipulated and/or located outside PIF (or dummy registers)
  p_aux : process(wr, addr, din)
  begin
    -- Note that arst is not considered here, but must be considered in any clocked process in the core
    -- Default - always to return to these values
    p2c_i.awt_icr(C_NUM_SOURCES - 1 downto 0) <= (others => '0');
    p2c_i.awt_itr(C_NUM_SOURCES - 1 downto 0) <= (others => '0');
    p2c_i.awt_irq2cpu_ena                     <= '0';
    p2c_i.awt_irq2cpu_disable                 <= '0';

    if (cs = '1' and wr = '1') then
      case to_integer(addr) is
        when C_ADDR_ITR =>
          p2c_i.awt_itr <= din(C_NUM_SOURCES - 1 downto 0);
        when C_ADDR_ICR =>
          p2c_i.awt_icr <= din(C_NUM_SOURCES - 1 downto 0);
        when C_ADDR_IRQ2CPU_ENA =>
          p2c_i.awt_irq2cpu_ena <= din(0);
        when C_ADDR_IRQ2CPU_DISABLE =>
          p2c_i.awt_irq2cpu_disable <= din(0);
        when others =>
          null;
      end case;
    end if;
  end process p_aux;

end rtl;
