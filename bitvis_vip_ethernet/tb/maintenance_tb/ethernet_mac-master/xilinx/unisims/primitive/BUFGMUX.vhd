-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/BUFGMUX.vhd,v 1.4 2009/11/23 22:47:31 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Global Clock Mux Buffer with Output State 0
-- /___/   /\     Filename : BUFGMUX.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:16 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    01/11/08 - Add CLK_SEL_TYPE attribute.
--    05/20/08 - Recoding same as verilog model. (CR467336)
--    02/19/09 - Add initial to q0_t and q1_t (CR507901)
--    11/23/09 - Change Q to 0 instead of L (CR538513)
-- End Revision


----- CELL BUFGMUX -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

entity BUFGMUX is
  generic (
      CLK_SEL_TYPE : string  := "SYNC"
  );

  port(
    O : out std_ulogic := '0';

    I0 : in std_ulogic := '0';
    I1 : in std_ulogic := '0';
    S  : in std_ulogic := '0'
    );

  attribute VITAL_LEVEL0 of
    BUFGMUX : entity is true;
end BUFGMUX;

architecture BUFGMUX_V of BUFGMUX is
  signal clk_sel_in : std_ulogic := '0';
  signal q0 : std_ulogic := '1';
  signal q0_t : std_ulogic := '1';
  signal q0_enable : std_ulogic := '1';
  signal q1 : std_ulogic := '0';
  signal q1_t : std_ulogic := '0';
  signal q1_enable : std_ulogic := '0';
begin

  clk_sel_in <= '1' when (CLK_SEL_TYPE = "ASYNC") else '0';
  q0_t <= not S when clk_sel_in = '1' else q0;
  q1_t <=  S when clk_sel_in = '1' else q1;
                                                                                   
  O <= I0 when (q0_t = '1') else I1 when (q1_t = '1') else 'X' when (q0_t = 'X' or q1_t = 'X') else '0';

  q0_p : process(I0, S, q0_enable)
  begin
     if (I0 /= '1') then
        q0 <= (not S) and q0_enable;
     end if;
  end process;

  q1_p : process(I1, S, q1_enable)
  begin
     if (I1 /= '1') then
        q1 <= S and q1_enable;
     end if;
  end process;

  q0_en_p : process(q1, I0)
  begin
      if (q1 = '1') then
          q0_enable <= '0';
      elsif (I0 /= '0') then
          q0_enable <=  not q1;
      end if;
  end process;

  q1_en_p : process(q0, I1)
  begin
      if (q0 = '1') then
          q1_enable <= '0';
      elsif (I1 /= '0') then
          q1_enable <=  not q0;
      end if;
  end process;

end BUFGMUX_V;


