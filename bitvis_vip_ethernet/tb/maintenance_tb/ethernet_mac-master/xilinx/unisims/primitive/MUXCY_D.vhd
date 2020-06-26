-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/MUXCY_D.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  2-to-1 Multiplexer for Carry Logic with Dual Output
-- /___/   /\     Filename : MUXCY_D.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:03 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

--    08/23/07 - Handle S= X case. CR434611 
----- CELL MUXCY_D -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXCY_D is
  port(
    LO : out std_ulogic;
    O  : out std_ulogic;

    CI : in std_ulogic;
    DI : in std_ulogic;
    S  : in std_ulogic
    );
end MUXCY_D;

architecture MUXCY_D_V of MUXCY_D is
begin
  VITALBehavior    : process (CI, DI, S)
  begin
    if (S = '0') then
      O <= DI;
      LO <= DI;      
    else
      O <= CI;
      LO <= CI;            
    end if;    
  end process;
end MUXCY_D_V;


