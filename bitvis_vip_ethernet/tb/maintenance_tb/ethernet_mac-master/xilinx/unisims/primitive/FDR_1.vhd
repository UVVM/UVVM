-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/FDR_1.vhd,v 1.2 2008/11/04 22:39:33 yanx Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  D Flip-Flop with Synchronous Reset and Negative-Edge Clock
-- /___/   /\     Filename : FDR_1.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:55:24 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    11/03/08 - Initial Q. CR49409
-- End Revision

----- CELL FDR_1 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDR_1 is
   generic(
      INIT                           :  bit := '0'  
);
   
      port(
      Q                              :	out   STD_ULOGIC;
      
      C                              :	in    STD_ULOGIC;      
      D                              :	in    STD_ULOGIC;
      R                              :	in    STD_ULOGIC
      );
end FDR_1;

architecture FDR_1_V of FDR_1 is
  signal q_o : std_ulogic := TO_X01(INIT);
begin
 
  Q <=  q_o;
   VITALBehavior : process(C) 
   VARIABLE FIRST_TIME : boolean := True ;
   begin


    if (falling_edge(C)) then
      if (R = '1') then
        q_o <= '0' after 100 ps;
      else
        q_o <= D after 100 ps;
      end if;
    end if;     
end process;
end FDR_1_V;


