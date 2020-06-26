-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/spartan4/VITAL/STARTUP_SPARTAN3E.vhd,v 1.1 2008/06/19 16:59:22 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  User Interface to Global Clock, Reset and 3-State Controls for SPARTAN3E
-- /___/   /\     Filename : STARTUP_SPARTAN3E.vhd
-- \   \  /  \    Timestamp : Tue Jul  27 21:56:59 PDT 2004
--  \___\/\___\
--
-- Revision:
--    07/27/04 - Initial version.

----- CELL STARTUP_SPARTAN3E -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity STARTUP_SPARTAN3E is
  port(
    CLK : in std_ulogic := 'X';
    GSR : in std_ulogic := 'X';
    GTS : in std_ulogic := 'X';
    MBT : in std_ulogic := 'X'
    );
end STARTUP_SPARTAN3E;

architecture STARTUP_SPARTAN3E_V of STARTUP_SPARTAN3E is
constant MINIMUM_PULSE_LOW : time := 300 ns;
begin
   prcs_mbt:process(MBT)
   variable disable_mbt : boolean := false;
   variable init_time, min_time : time := 0 ps;
   begin
       if(not disable_mbt) then
          if(MBT = '0') then
             if(now /= 0 ns ) then
                init_time := now;
             end if;
          elsif(MBT = '1') then
             min_time := now - init_time;
             if(min_time >= MINIMUM_PULSE_LOW) then
                assert false
                report "Soft Boot has been initiated."
                severity note;
                
                disable_mbt := true;
             end if;
          end if;
       end if;   -- if (not disable_mbt)
   end process prcs_mbt; 
end STARTUP_SPARTAN3E_V;
