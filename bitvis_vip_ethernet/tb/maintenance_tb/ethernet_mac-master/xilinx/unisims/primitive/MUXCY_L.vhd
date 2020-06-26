-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/MUXCY_L.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-to-1 Multiplexer for Carry Logic with Local Output
-- /___/   /\     Filename : MUXCY_L.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

--    08/23/07 - Handle S= X case. CR434611 
----- CELL MUXCY_L -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXCY_L is
  port(
    LO : out std_ulogic;

    CI : in std_ulogic;
    DI : in std_ulogic;
    S  : in std_ulogic
    );
end MUXCY_L;

architecture MUXCY_L_V of MUXCY_L is
begin
  VITALBehavior    : process (CI, DI, S)
  begin
    if (S = '0') then
      LO <= DI;
    else
      LO <= CI;      
    end if;    
  end process;
end MUXCY_L_V;


