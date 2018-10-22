-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/MUXF7.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-to-1 Lookup Table Multiplexer with General Output
-- /___/   /\     Filename : MUXF7.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:04 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

--    08/23/07 - Handle S= X case. CR434611 
----- CELL MUXF7 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF7 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    S  : in std_ulogic
    );
end MUXF7;

architecture MUXF7_V of MUXF7 is
begin
  VITALBehavior   : process (I0, I1, S)
  begin
    if (S = '0') then
      O <= I0;      
    else
      O <= I1;            
    end if;                    
  end process;
end MUXF7_V;


