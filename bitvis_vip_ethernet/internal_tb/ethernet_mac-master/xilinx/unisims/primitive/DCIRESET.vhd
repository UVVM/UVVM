-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/virtex4/VITAL/DCIRESET.vhd,v 1.3 2009/08/22 00:26:02 harikr Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Reset for DCI State Machine
-- /___/   /\     Filename : DCIRESET.vhd
-- \   \  /  \    Timestamp : Fri Mar 26 08:17:58 PST 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    08/17/09 - CR 531087 -- re-installation of the model  
-- End Revision

----- CELL DCIRESET -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity DCIRESET is

  port(
      LOCKED	: out std_ulogic;

      RST	: in  std_ulogic
    );

end DCIRESET;

architecture DCIRESET_V OF DCIRESET is

begin

  --------------------
  --  BEHAVIOR SECTION
  --------------------


--####################################################################
--#####                           OUTPUT                         #####
--####################################################################
  prcs_rst:process(RST)
  variable RiseTime  : time := 0 ps;
  variable FallTime  : time := 0 ps;
  variable HighPuLse : time := 0 ps;
  variable LowPuLse  : time := 0 ps;

  begin

     if(rising_edge(RST)) then
        RiseTime := now;
        if(RiseTime > 0 ps) then
           LowPulse := RiseTIme - FallTime;
        end if;
        
        if(LowPulse < 100 ns) then
           assert false
           report "Timing Violation Error : The low  pulse of RST signal in DCIRESET has to be greater than 100 ns" 
           severity Error; 
        end if;
     end if; 

     if(falling_edge(RST)) then
        FallTime := now;
        if(FallTime > 0 ps) then
           HighPulse := FallTime - RiseTime;
        end if;
        
        if(HighPulse < 100 ns) then
           assert false
           report "Timing Violation Error : The high pulse of RST signal in DCIRESET has to be greater than 100 ns" 
           severity Error; 
        end if;
     end if; 

     if(RST = '1') then
        LOCKED <= '0' after 0 ns;
     elsif(RST = '0') then
        LOCKED <= '1' after 100 ns;
     end if;
  end process prcs_rst;
end DCIRESET_V;
