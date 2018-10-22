-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/FDS_1.vhd,v 1.2 2008/11/04 22:39:33 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  D Flip-Flop with Synchronous Set and Negative-Edge Clock
-- /___/   /\     Filename : FDS_1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:25 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL FDS_1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDS_1 is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    C : in std_ulogic;
    D : in std_ulogic;
    S : in std_ulogic
    );
end FDS_1;

architecture FDS_1_V of FDS_1 is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
  VITALBehavior         : process(C)

  begin


    if (falling_edge(C)) then
      if (S = '1') then
        q_o <= '1' after 100 ps;
      else
        q_o <= D after 100 ps;
      end if;
    end if;
  end process;
end FDS_1_V;


