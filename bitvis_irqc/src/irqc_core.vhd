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
-- VHDL unit     : Bitvis IRQC Library : irqc_core
--
-- Description   : See dedicated powerpoint presentation and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.irqc_pif_pkg.all;

entity irqc_core is
  port(
    -- DSP interface and general control signals
    clk         : in  std_logic;
    arst        : in  std_logic;
    -- PIF-core interface
    p2c         : in  t_p2c;
    c2p         : out t_c2p;
    -- Interrupt related signals
    irq_source  : in  std_logic_vector(C_NUM_SOURCES - 1 downto 0);
    irq2cpu     : out std_logic;
    irq2cpu_ack : in  std_logic
  );
end irqc_core;

architecture rtl of irqc_core is

  signal c2p_i : t_c2p;                 -- Internal version of output
  signal igr   : std_logic;

  function or_reduce(
    constant value : std_logic_vector
  ) return std_logic is
    variable v_tmp : std_logic := '0';
  begin
    for i in value'range loop
      v_tmp := v_tmp or value(i);
    end loop;
    return v_tmp;
  end;

begin

  p_irr : process(clk, arst)
  begin
    if arst = '1' then
      c2p_i.aro_irr <= (others => '0');
    elsif rising_edge(clk) then
      for i in 0 to C_NUM_SOURCES - 1 loop
        if p2c.awt_itr(i) = '1' then
          c2p_i.aro_irr(i) <= '1';
        elsif p2c.awt_icr(i) = '1' then
          c2p_i.aro_irr(i) <= '0';
        elsif irq_source(i) = '1' then
          c2p_i.aro_irr(i) <= '1';
        else
          null;                         -- Keep value if none above
        end if;
      end loop;
    end if;
  end process;

  c2p_i.aro_ipr <= c2p_i.aro_irr and p2c.rw_ier;
  igr           <= or_reduce(c2p_i.aro_ipr);

  p_irq2cpu : process(clk, arst)
  begin
    if arst = '1' then
      c2p_i.aro_irq2cpu_allowed <= '0';
    elsif rising_edge(clk) then
      if p2c.awt_irq2cpu_ena = '1' then
        c2p_i.aro_irq2cpu_allowed <= '1';
      -- NOTE: No way to disallow irq2cpu without the following two lines  (However not included in the specification)
      elsif p2c.awt_irq2cpu_disable = '1' then
        c2p_i.aro_irq2cpu_allowed <= '0';
      elsif irq2cpu_ack = '1' then
        c2p_i.aro_irq2cpu_allowed <= '0';
      else
        null;                           -- Keep value if none above
      end if;
    end if;
  end process;

  irq2cpu <= '1' when (igr = '1' and c2p_i.aro_irq2cpu_allowed = '1') else '0';

  c2p <= c2p_i;

end rtl;
