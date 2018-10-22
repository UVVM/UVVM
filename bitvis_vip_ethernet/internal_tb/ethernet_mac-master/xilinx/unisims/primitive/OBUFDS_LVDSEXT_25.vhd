-- $Header: /devl/xcs/repo/env/Databases/CAEInterfaces/vhdsclibs/data/unisims/unisim/VITAL/OBUFDS_LVDSEXT_25.vhd,v 1.1 2008/06/19 16:59:24 vandanad Exp $
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 11.1
--  \   \         Description : Xilinx Functional Simulation Library Component
--  /   /                  Differential Signaling Output Buffer with LVDSEXT_25 I/O Standard
-- /___/   /\     Filename : OBUFDS_LVDSEXT_25.vhd
-- \   \  /  \    Timestamp : Thu Apr  8 10:56:25 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.

----- CELL OBUFDS_LVDSEXT_25 -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity OBUFDS_LVDSEXT_25 is
  port(
    O  : out std_ulogic;
    OB : out std_ulogic;

    I : in std_ulogic
    );
end OBUFDS_LVDSEXT_25;

architecture OBUFDS_LVDSEXT_25_V of OBUFDS_LVDSEXT_25 is
begin
  VITALBehavior    : process (I)
    variable O_zd  : std_ulogic;
    variable OB_zd : std_ulogic;

  begin
    O_zd  := TO_X01(I);
    OB_zd := (not O_zd);
    O  <= O_zd;
    OB <= OB_zd;
  end process;
end OBUFDS_LVDSEXT_25_V;


