-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/FDSE.vhd,v 1.2 2008/11/04 22:39:33 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  D Flip-Flop with Synchronous Set and Clock Enable
-- /___/   /\     Filename : FDSE.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:25 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL FDSE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDSE is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    S  : in std_ulogic
    );
end FDSE;

architecture FDSE_V of FDSE is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
  VITALBehavior         : process(C)

  begin


    if (rising_edge(C)) then
      if (S = '1') then
        q_o <= '1' after 100 ps;
      elsif (CE = '1') then
        q_o <= D after 100 ps;
      end if;
    end if;
  end process;
end FDSE_V;


